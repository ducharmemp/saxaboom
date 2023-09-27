defmodule Saxaboom.Mapper do
  @moduledoc """
  The main user interface for defining mapping definitions.

  `Saxaboom.Mapper` exposes a micro-DSL for describing the expected structure of a given document. There are three
  components to the `Saxaboom.Mapper` interface: `

  - `document`: a directive describing the "envelope" of the incoming document (read: the whole document). This exposes the internal DSL.
  - `element`: a directive to match zero to one element and collect into a single struct field
  - `elements`: a directive to match zero to N elements and collect in a list in the order they are encountered
  """

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

      import Saxaboom.Mapper
      alias Saxaboom.Caster
      alias Saxaboom.Element
    end
  end

  defp postlude do
    quote do
      defstruct @xml_sax_element_metadata
                |> Enum.reverse()
                |> Enum.map(fn metadata -> metadata.field_name end)
                |> Enum.uniq()

      Module.put_attribute(
        __MODULE__,
        :xml_grouped_sax_element_metadata,
        @xml_sax_element_metadata
        |> Enum.group_by(fn metadata -> metadata.element_name end)
        |> Map.new(fn {key, values} -> {key, Enum.reverse(values)} end)
      )
    end
  end

  defp protocol_impl do
    quote do
      def matchers do
        @xml_grouped_sax_element_metadata
      end

      defimpl Saxaboom.ElementCollectable do
        def element_definition(mapper, %Element{name: name} = element) do
          @for.matchers
          |> Map.get(name, [])
          |> Enum.find(&Saxaboom.FieldMetadata.matches_attributes?(&1, element))
        end

        defp update_field(mapper, nil, element) do
          mapper
        end

        defp update_field(
               mapper,
               %{kind: :element, cast: cast_type} = definition,
               %Element{} = element
             ) do
          extracted = Access.get(element.attributes, definition.value, element.text)
          cast = Caster.cast_value(cast_type, extracted)
          %{mapper | definition.field_name => cast}
        end

        defp update_field(
               mapper,
               %{kind: :elements, cast: cast_type} = definition,
               %Element{} = element
             ) do
          extracted = Access.get(element.attributes, definition.value, element.text)
          cast = Caster.cast_value(cast_type, extracted)
          current = Map.get(mapper, definition.field_name) || []
          %{mapper | definition.field_name => current ++ [cast]}
        end

        defp update_field(mapper, %{kind: :element, cast: cast} = definition, value) do
          cast = Caster.cast_value(cast, value)
          %{mapper | definition.field_name => cast}
        end

        defp update_field(
               mapper,
               %{kind: :elements, field_name: field_name, cast: cast} = definition,
               value
             ) do
          current = Map.get(mapper, field_name) || []
          cast = Caster.cast_value(cast, value)
          %{mapper | definition.field_name => current ++ [value]}
        end

        def cast_element(
              mapper,
              %Element{name: name, attributes: attributes} = element
            ) do
          definition = element_definition(mapper, element)
          update_field(mapper, definition, element)
        end

        def cast_nested(
              mapper,
              %Element{name: name, attributes: attributes} = element,
              nested
            ) do
          definition = element_definition(mapper, element)
          update_field(mapper, definition, nested)
        end
      end
    end
  end

  @doc """
  Defines a structure that can match against 0 or 1 elements in the given document.
  """
  defmacro element(name, opts \\ []) do
    quote do
      metadata = Saxaboom.FieldMetadata.from(unquote(name), unquote(opts), :element)
      Module.put_attribute(__MODULE__, :xml_sax_element_metadata, metadata)
    end
  end

  @doc """
  Defines a structure that can match against 0 or N elements in the given document.
  """
  defmacro elements(name, opts \\ []) do
    quote do
      metadata = Saxaboom.FieldMetadata.from(unquote(name), unquote(opts), :elements)
      Module.put_attribute(__MODULE__, :xml_sax_element_metadata, metadata)
    end
  end
end
