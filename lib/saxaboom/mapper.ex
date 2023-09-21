defmodule Saxaboom.Mapper do
  defmacro __using__(_opts) do
    quote do
      import Saxaboom.Mapper, only: [document: 1]
    end
  end

  defmacro document(do: block) do
    prelude =
      quote do
        Module.register_attribute(__MODULE__, :xml_sax_struct_elements, accumulate: true)
        Module.register_attribute(__MODULE__, :xml_sax_element_metadata, accumulate: true)

        import Saxaboom.Mapper
        alias Saxaboom.Element
        alias Saxaboom.Caster

        unquote(block)

        defstruct Enum.uniq(Enum.reverse(@xml_sax_struct_elements))

        Module.put_attribute(
          __MODULE__,
          :xml_grouped_sax_element_metadata,
          @xml_sax_element_metadata |> Enum.group_by(&Access.get(&1, :element_name))
        )

        Module.put_attribute(
          __MODULE__,
          :xml_sax_keys,
          @xml_grouped_sax_element_metadata |> Map.keys() |> MapSet.new()
        )
      end

    postlude =
      quote unquote: false do
        @xml_grouped_sax_element_metadata
        |> Enum.each(fn {element_name, matchers} ->
          def __inner_element_definition__(
                mapper,
                %Element{name: unquote(element_name), attributes: attributes} = element
              ) do
            attribute_keys = Map.keys(attributes) |> MapSet.new()

            Map.get(@xml_grouped_sax_element_metadata, unquote(element_name))
            |> Enum.find(fn maybe_match ->
              MapSet.subset?(maybe_match.with_keys, attribute_keys) &&
                Enum.all?(maybe_match.with, fn {expected_attribute, expected_value} ->
                  Access.get(attributes, expected_attribute) == expected_value
                end)
            end)
          end
        end)

        def __inner_element_definition__(mapper, element), do: nil

        def __maybe_handle__(mapper, %Element{name: name} = element) do
          MapSet.member?(@xml_sax_keys, name)
        end

        def __element_definition__(mapper, element) do
          if __maybe_handle__(mapper, element) do
            __inner_element_definition__(mapper, element)
          end
        end

        def __update_field__(mapper, nil, element) do
          mapper
        end

        def __update_field__(
              mapper,
              %{kind: :element, cast: cast_type} = definition,
              %Element{} = element
            ) do
          extracted = Access.get(element.attributes, definition.value, element.text)
          cast = Caster.cast_value(cast_type, extracted)
          %{mapper | definition.field_name => cast}
        end

        def __update_field__(
              mapper,
              %{kind: :elements, cast: cast_type} = definition,
              %Element{} = element
            ) do
          extracted = Access.get(element.attributes, definition.value, element.text)
          cast = Caster.cast_value(cast_type, extracted)
          current = Map.get(mapper, definition.field_name) || []
          %{mapper | definition.field_name => current ++ [cast]}
        end

        def __update_field__(mapper, %{kind: :element} = definition, value) do
          %{mapper | definition.field_name => value}
        end

        def __update_field__(mapper, %{kind: :elements} = definition, value) do
          current = Map.get(mapper, definition.field_name) || []
          %{mapper | definition.field_name => current ++ [value]}
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
        value:
          case Access.get(opts, :value) do
            nil -> nil
            value -> to_string(value)
          end,
        with:
          (Access.get(opts, :with) || [])
          |> Enum.into(%{})
          |> Map.new(fn {key, value} -> {to_string(key), value} end),
        with_keys:
          (Access.get(opts, :with) || [])
          |> Keyword.keys()
          |> Enum.map(&to_string/1)
          |> MapSet.new(),
        cast: Access.get(opts, :cast, :string),
        into: Access.get(opts, :into),
        kind: kind
      }
    }
  end

  defmacro element(name, opts \\ []) do
    quote do
      {field_name, metadata} =
        Saxaboom.Mapper.__map_field_info__(unquote(name), unquote(opts), :element)

      Module.put_attribute(__MODULE__, :xml_sax_struct_elements, field_name)
      Module.put_attribute(__MODULE__, :xml_sax_element_metadata, metadata)
    end
  end

  defmacro elements(name, opts \\ []) do
    quote do
      {field_name, metadata} =
        Saxaboom.Mapper.__map_field_info__(unquote(name), unquote(opts), :elements)

      Module.put_attribute(__MODULE__, :xml_sax_struct_elements, field_name)
      Module.put_attribute(__MODULE__, :xml_sax_element_metadata, metadata)
    end
  end
end
