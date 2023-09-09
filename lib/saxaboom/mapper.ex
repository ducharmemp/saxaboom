defmodule Saxaboom.Mapper do
  defmacro __using__(_opts) do
    quote do
      import Saxaboom.Mapper, only: [document: 1]
    end
  end

  defmacro document(do: block) do
    prelude =
      quote location: :keep do
        Module.register_attribute(__MODULE__, :xml_sax_struct_elements, accumulate: true)
        Module.register_attribute(__MODULE__, :xml_sax_element_metadata, accumulate: true)

        import Saxaboom.Mapper
        alias Saxaboom.Element

        unquote(block)

        defstruct Enum.reverse(@xml_sax_struct_elements)
      end

    postlude =
      quote unquote: false do
        @xml_sax_element_metadata
        |> Enum.group_by(&Access.get(&1, :element_name))
        |> Enum.each(fn {element_name, matchers} ->
          def __element_definition__(
                mapper,
                %Element{name: unquote(element_name), attributes: attributes} = element
              ) do
            unquote(Macro.escape(matchers))
            |> Enum.find(fn maybe_match ->
              attribute_matches =
                maybe_match.with
                |> Enum.map(fn {expected_attribute, expected_value} ->
                  Access.get(attributes, expected_attribute) == expected_value
                end)

              Enum.all?([maybe_match.element_name == element.name] ++ attribute_matches)
            end)
          end
        end)

        def __element_definition__(mapper, element), do: nil

        def __update_field__(mapper, nil, element) do
          mapper
        end

        def __update_field__(mapper, %{kind: :element} = definition, %Element{} = element) do
          extracted = Access.get(element.attributes, definition.value, element.text)
          %{mapper | definition.field_name => extracted}
        end

        def __update_field__(mapper, %{kind: :elements} = definition, %Element{} = element) do
          extracted = Access.get(element.attributes, definition.value, element.text)
          # TODO: This should be defaulted in the defstruct
          current = Map.get(mapper, definition.field_name) || []
          %{mapper | definition.field_name => [extracted | current]}
        end

        def __update_field__(mapper, %{kind: :element} = definition, value) do
          %{mapper | definition.field_name => value}
        end

        def __update_field__(mapper, %{kind: :elements} = definition, value) do
          # TODO: This should be defaulted in the defstruct
          current = Map.get(mapper, definition.field_name) || []
          # TODO: Annoying, this is in reverse order of appearance in the doc
          %{mapper | definition.field_name => [value | current]}
        end

        def __cast_element__(
              mapper,
              %Element{name: name, attributes: attributes} = element
            ) do
          definition = __element_definition__(mapper, element)
          __update_field__(mapper, definition, element)
        end

        def __cast_nested__(
              mapper,
              %Element{name: name, attributes: attributes} = element,
              nested
            ) do
          definition = __element_definition__(mapper, element)
          __update_field__(mapper, definition, nested)
        end
      end

    quote do
      unquote(prelude)
      unquote(postlude)
    end
  end

  def __map_field_info__(name, opts, kind) do
    {
      Access.get(opts, :as, name),
      %{
        field_name: Access.get(opts, :as, name),
        element_name: to_string(name),
        value: to_string(Access.get(opts, :value)),
        with: Access.get(opts, :with) || [],
        cast: Access.get(opts, :cast, :string),
        into: Access.get(opts, :into),
        kind: kind
      }
    }
  end

  defmacro element(name, opts \\ []) do
    quote location: :keep do
      {field_name, metadata} =
        Saxaboom.Mapper.__map_field_info__(unquote(name), unquote(opts), :element)

      Module.put_attribute(__MODULE__, :xml_sax_struct_elements, field_name)
      Module.put_attribute(__MODULE__, :xml_sax_element_metadata, metadata)
    end
  end

  defmacro elements(name, opts \\ []) do
    quote location: :keep do
      {field_name, metadata} =
        Saxaboom.Mapper.__map_field_info__(unquote(name), unquote(opts), :elements)

      Module.put_attribute(__MODULE__, :xml_sax_struct_elements, field_name)
      Module.put_attribute(__MODULE__, :xml_sax_element_metadata, metadata)
    end
  end
end
