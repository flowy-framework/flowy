# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  export: [
    locals_without_parens: [
      assert_enqueued: 1,
      assert_enqueued: 2,
      refute_enqueued: 1,
      refute_enqueued: 2
    ]
  ],
  locals_without_parens: [
    assert_enqueued: 1,
    assert_enqueued: 2,
    refute_enqueued: 1,
    refute_enqueued: 2
  ]
]
