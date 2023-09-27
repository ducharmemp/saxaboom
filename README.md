# Saxaboom

[![Test suite](https://github.com/ducharmemp/saxaboom/actions/workflows/elixir.yml/badge.svg?branch=main)](https://github.com/qcam/saxy/actions/workflows/test.yml)
[![Module Version](https://img.shields.io/hexpm/v/saxaboom.svg)](https://hex.pm/packages/saxaboom)


## Installation

Add `saxaboom` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:saxaboom, "~> 0.1.0"}
  ]
end
```

Optionally add an XML parsing libray based on your needs, view the benchmarks if you'd like to see a head-to-head comparison
between XML SAX parsers. If a third-party XML library is not desired, [xmerl](https://www.erldocs.com/18.0/xmerl/xmerl_sax_parser.html?i=652) will be used.

Saxaboom currently has adapters for:
- [Saxy](https://github.com/qcam/saxy)
- [Erlsom](https://github.com/willemdj/erlsom)
- [xmerl_sax_parser](https://www.erldocs.com/18.0/xmerl/xmerl_sax_parser.html?i=652)

If using Saxy, for example, your `mix.exs` would look something like:

```elixir
def deps do
  [
    {:saxaboom, "~> 0.1.0"},
    {:saxy, "~> ..."}
  ]
end
```

## About

Saxaboom is a data-mapper capable of transforming XML via SAX into a tree of structs. Think
of it as xpath selectors but with the ability to work on potentially infinite streams of data with low memory usage since it only
works with a few elements at a time relative to the rest of the document. If you're familiar with https://github.com/pauldix/sax-machine
then this library should more or less look exactly the same with some minor tweaks.

## Example
You can run the code for yourself in `examples/bookstore` via `mix run -e "Bookstore.list_books('books.xml')"`

Define a mapping layout of some kind using `Saxaboom.Mapper`:

```elixir
defmodule Bookstore.Book do
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

defmodule Bookstore.Catalog do
  use Saxaboom.Mapper

  document do
    elements :book, as: :books, into: %Book{}
  end
end
```

And the resulting (trunacated) output:
```
{:ok,
 %Bookstore.Catalog{
   books: [
     %Bookstore.Book{
       id: "bk101",
       author: "Gambardella, Matthew",
       title: "XML Developer's Guide",
       genre: "Computer",
       price: 44.95,
       publish_date: {:ok, ~D[2000-10-01]},
       description: "An in-depth look at creating applications\n      with XML."
     },
     %Bookstore.Book{
       id: "bk102",
       author: "Ralls, Kim",
       title: "Midnight Rain",
       genre: "Fantasy",
       price: 5.95,
       publish_date: {:ok, ~D[2000-12-16]},
       description: "A former architect battles corporate zombies,\n      an evil sorceress, and her own childhood to become queen\n      of the world."
     },
     ...
   ]
 }}
```

As you can see the overall structure looks good but there seems to be some extra whitespace present in the `description`. To begin playing around with the
library, a good place to start would be to modify the `Book` structure to remove said whitespace so the first entry simply reads:

```
%Bookstore.Book{
  id: "bk101",
  author: "Gambardella, Matthew",
  title: "XML Developer's Guide",
  genre: "Computer",
  price: 44.95,
  publish_date: {:ok, ~D[2000-10-01]},
  description: "An in-depth look at creating applications with XML."
},
```

## Caveats and Security

### On security for XML
Parsing untrusted input from external sources is always fraught with peril! Because there are a myriad of ways that attackers
can exploit XML parsers, Saxaboom allows the user to pass additional arguments directly to the underlying parsing library to control
things like DTD validation/expansion. Please refer to the XML library of choice for their recommendations/special considerations when
parsing untrusted input.

### On parsing semantics

#### How Saxaboom works
Saxaboom maintains a few stacks to maintain state while walking down the tree, a stack of elements that have been visited but not closed, and a stack of `Mapper` that can receive data. If an `into` field is encountered, Saxaboom pushes the `into` type onto the handler stack. If an element closing tag is encountered, Saxaboom sends the event to the handler at the top of the handler stack. Saxaboom continues this pushing and popping of `Mapper` and elements until the end of the document has been reached.

#### Semantics
- `element`: Last element in the current parsing tree wins
- `elements`: All elements are collected in document order.
- `element` and `elements` do not care about the depth of a given item within the tree. If they encounter a tag that matches something in the current `Mapper`, it'll be parsed into the type. This results in an auto-flattening of the tree, which is desirable in a lot of cases. If this is not desirable, consider defining a few nested `Mapper` types.
- `into` types receive the tag that starts the nested section
  - This is why we could extract the `id` from the `book` tag within the `Book` struct in the example above
- Mixed content is untested, it probably won't work right now. This includes characters mixed with CDATA sections
- The default behavior of both the `element` and `elements` types is to extract the characters present between the opening and closing tags if a `value` definition is not present
- The default behavior is to leave the value extracted from a tag as a `string` unless otherwise specified by a `cast` function.


