defmodule Saxaboom.Mapper do
  @moduledoc """
  The main user interface for defining mapping definitions.

  `Saxaboom.Mapper` exposes a micro-DSL for describing the expected structure of a given document. There are three
  components to the `Saxaboom.Mapper` interface:

  - `document/1`: a directive describing the "envelope" of the incoming document (read: the whole document). This exposes the internal DSL.
  - `element/2`: a directive to match zero to one element and collect into a single struct field
  - `elements/2`: a directive to match zero to N elements and collect in a list in the order they are encountered
  - `attribute/2`: a directive to match zero to one attribute and collect into a single struct field.

  Please note that the `element/2` and `attribute/2` macros take a "last argument wins" approach, which is to say that
  if an element or attribute of the same name appears later in the document, the value extracted will overwrite any previously
  held value.

  ## Examples

  For example, the following mapper defines a bookstore catalog of books (see also: [examples](https://github.com/ducharmemp/saxaboom/tree/main/examples/bookstore)):

      defmodule Book do
        use Saxaboom.Mapper

        document do
          element :book, as: :id, value: :id
          element :author
          element :title
          element :genre
          element :price, cast: :float
          element :publish_date, cast: &__MODULE__.parse_date/1
          element :description
        end

        def parse_date(value), do: Date.from_iso8601(value)
      end


      defmodule Catalog do
        use Saxaboom.Mapper

        document do
          elements :book, as: :books, into: %Book{}
        end
      end

  Which intuitively maps against the following XML body:

      xml = \"\"\"
        <?xml version="1.0"?>
        <catalog>
          <book id="bk101">
              <author>Gambardella, Matthew</author>
              <title>XML Developer's Guide</title>
              <genre>Computer</genre>
              <price>44.95</price>
              <publish_date>2000-10-01</publish_date>
              <description>An in-depth look at creating applications
              with XML.</description>
          </book>
        </catalog>
        \"\"\"

  Usage:

      Saxaboom.parse(xml, %Catalog{})
      #=> {:ok,
      #  %Catalog{
      #    books: [
      #      %Book{
      #        id: "bk101",
      #        author: "Gambardella, Matthew",
      #        title: "XML Developer's Guide",
      #        genre: "Computer",
      #       price: 44.95,
      #        publish_date: {:ok, ~D[2000-10-01]},
      #        description: "An in-depth look at creating applications\\n        with XML."
      #      }
      #    ]
      #  }}


  > #### `use Saxaboom.Mapper` {: .info}
  >
  > When you `use Saxaboom.Mapper`, the mapper module will import
  > the `element/2` and `elements/2` macros into the current scope.

  > #### Consolidation {: .warning}
  >
  > Saxaboom currently relies on dynamic dispatch via protocols, which are consolidated at compile time for a performance
  > boost. If you'd like to use Saxaboom in iex and dynamically create `Saxaboom.Mapper`s, you should read the docs
  > on [consolidation](https://hexdocs.pm/elixir/1.14/Protocol.html#module-consolidation) for the finer details and config
  > options available. Turning off protocol consolidation is not generally recommended for production environments.

  """

  @spec __using__(any) ::
          {:import, [{:column, 7} | {:context, Saxaboom.Mapper}, ...],
           [[{any, any}, ...] | {:__aliases__, [...], [...]}, ...]}
  @doc false
  defmacro __using__(_opts) do
    quote do
      import Saxaboom.Mapper, only: [document: 1]
    end
  end

  @doc """
  Begins the definition of a "document", that is, a section of parseable content.
  """
  defmacro document(do: block) do
    quote do
      unquote(prelude())
      unquote(block)
      unquote(postlude())
      unquote(protocol_impl())
    end
  end

  defp prelude do
    quote do
      Module.register_attribute(__MODULE__, :xml_sax_element_metadata, accumulate: true)
      Module.register_attribute(__MODULE__, :xml_sax_attribute_metadata, accumulate: true)

      import Saxaboom.Mapper
      alias Saxaboom.Element
      alias Saxaboom.Utils.Caster
    end
  end

  defp postlude do
    quote do
      defstruct @xml_sax_element_metadata
                |> Enum.concat(@xml_sax_attribute_metadata)
                |> Enum.reverse()
                |> Enum.map(fn metadata -> {metadata.field_name, metadata.default} end)
                |> Enum.uniq()

      Module.put_attribute(
        __MODULE__,
        :xml_mapped_sax_attribute_metadata,
        @xml_sax_attribute_metadata
        |> Enum.map(fn metadata -> {metadata.matcher_name, metadata} end)
        |> Enum.into(%{})
      )
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp protocol_impl do
    quote unquote: false do
      defimpl Saxaboom.ElementCollectable do
        Module.get_attribute(@for, :xml_sax_element_metadata)
        |> Enum.reverse()
        |> Enum.each(fn %{matcher_name: matcher_name, with: with_match} = metadata ->
          def element_definition(
                mapper,
                %Element{
                  name: unquote(matcher_name),
                  attributes: unquote(Macro.escape(with_match))
                }
              ) do
            unquote(Macro.escape(metadata))
          end
        end)

        def element_definition(_mapper, _elem), do: nil

        def attribute_definitions(
              mapper,
              %Element{
                attributes: attributes
              }
            ) do
          attributes
          |> Map.intersect(
            unquote(Macro.escape(Module.get_attribute(@for, :xml_mapped_sax_attribute_metadata)))
          )
          |> Map.values()
        end

        def cast_characters(
              mapper,
              element,
              characters
            ) do
          definition = element_definition(mapper, element)
          extracted = extract_value(element, definition) || characters
          cast = cast_value(extracted, definition)
          update_field(mapper, definition, cast)
        end

        def cast_attributes(
              mapper,
              element
            ) do
          [element_definition(mapper, element)]
          |> Enum.concat(attribute_definitions(mapper, element))
          |> Enum.reduce(mapper, fn definition, acc ->
            extracted = extract_value(element, definition)
            cast = cast_value(extracted, definition)
            update_field(acc, definition, cast)
          end)
        end

        def cast_nested(
              mapper,
              element,
              nested
            ) do
          definition = element_definition(mapper, element)
          cast = cast_value(nested, definition)
          update_field(mapper, definition, cast)
        end

        # No definition, can't do anything
        defp extract_value(element, nil), do: nil
        # We don't want anything out of the element tag
        defp extract_value(element, %{value: nil}), do: nil
        # We want something out of the element tag
        defp extract_value(%{attributes: attributes}, %{value: value}),
          do: Access.get(attributes, value, nil)

        defp cast_value(value, nil), do: nil
        defp cast_value(nil, definition), do: nil
        defp cast_value(value, %{cast: cast}), do: Caster.cast_value(cast, value)

        defp update_field(mapper, definition, nil), do: mapper

        defp update_field(mapper, %{kind: :element, field_name: field_name}, value),
          do: %{mapper | field_name => value}

        defp update_field(mapper, %{kind: :attribute, field_name: field_name}, value),
          do: %{mapper | field_name => value}

        defp update_field(mapper, %{kind: :elements, field_name: field_name}, value) do
          current = Map.get(mapper, field_name) || []
          %{mapper | field_name => current ++ [value]}
        end
      end
    end
  end

  @doc """
  Defines a structure field that can match against 0 or 1 elements in the given document.

  Arguments:
    - `name` is the name of the tag to match against, case sensitive

  Options:
    - `:as` provides the name to be used on the struct when parsing, defaults to the name of the tag
    - `:value` identifies the property to extract from the tag. Can be an attribute name, defaults to the text content of the node
    - `:with` is a keyword list of attributes and expected attribute values. The `:with` must perfectly match against a subset of the node attributes
    - `:cast` is a symbol or a user-defined function to transform the extracted `:value`, see `Saxaboom.Utils.Caster` for more details.
    - `:into` is another mapper or type that implements the `Saxaboom.ElementCollectable` protocol. Child nodes will be parsed into this structure until the parser has encountered the closing tag of the node that began the `:into`.
    - `:default` is the default value of the node, if no tags are parsed. `nil` by default

  """
  defmacro element(name, opts \\ []) do
    quote do
      metadata = Saxaboom.FieldMetadata.from(unquote(name), unquote(opts), :element)
      Module.put_attribute(__MODULE__, :xml_sax_element_metadata, metadata)
    end
  end

  @doc """
  Defines a structure field that can match against 0 or N elements in the given document. The list will be parsed and extracted
  in document order.
  Defaults to an empty list.

  Arguments:
    - `name` is the name of the tag to match against, case sensitive

  Options:
    - `:as` provides the name to be used on the struct when parsing, defaults to the name of the tag
    - `:value` identifies the property to extract from the tag. Can be an attribute name, defaults to the text content of the node
    - `:with` is a keyword list of attributes and expected attribute values. The `:with` must perfectly match against a subset of the node attributes
    - `:cast` is a symbol or a user-defined function to transform the extracted `:value`, see `Saxaboom.Utils.Caster` for more details.
    - `:into` is another mapper or type that implements the `Saxaboom.ElementCollectable` protocol. Child nodes will be parsed into this structure until the parser has encountered the closing tag of the node that began the `:into`.
  """
  defmacro elements(name, opts \\ []) do
    quote do
      metadata =
        Saxaboom.FieldMetadata.from(
          unquote(name),
          unquote(opts) |> Keyword.put(:default, []),
          :elements
        )

      Module.put_attribute(__MODULE__, :xml_sax_element_metadata, metadata)
    end
  end

  @doc """
  Defines a structure field that can match against an attribute in the given document. Note that the element it extracts from is
  unspecified, it will extract from any element that has the given attribute.

  Arguments:
    - `name` is the name of the tag to match against, case sensitive

  Options:
    - `:as` provides the name to be used on the struct when parsing, defaults to the name of the tag
    - `:cast` is a symbol or a user-defined function to transform the extracted `:value`, see `Saxaboom.Utils.Caster` for more details.
  """
  defmacro attribute(name, opts \\ []) do
    quote do
      metadata =
        Saxaboom.FieldMetadata.from(
          unquote(name),
          unquote(opts) |> Keyword.put(:value, unquote(name)),
          :attribute
        )

      Module.put_attribute(__MODULE__, :xml_sax_attribute_metadata, metadata)
    end
  end
end
