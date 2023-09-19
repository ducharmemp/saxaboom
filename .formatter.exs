# Used by "mix format"
locals_without_parens = [
  document: 1,
  element: 1,
  element: 2,
  elements: 1,
  elements: 2
]

[
  locals_without_parens: locals_without_parens,
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
