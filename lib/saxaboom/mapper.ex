defmodule Saxaboom.Mapper do
  defmacro __using__(_opts) do
    quote do
      import Saxaboom.Mapper, only: [document: 1]
    end
  end

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

  defmacro element(name, opts \\ []) do
    quote do
      metadata = Saxaboom.FieldMetadata.from(unquote(name), unquote(opts), :element)
      Module.put_attribute(__MODULE__, :xml_sax_element_metadata, metadata)
    end
  end

  defmacro elements(name, opts \\ []) do
    quote do
      metadata = Saxaboom.FieldMetadata.from(unquote(name), unquote(opts), :elements)
      Module.put_attribute(__MODULE__, :xml_sax_element_metadata, metadata)
    end
  end
end
