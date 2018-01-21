# avro_fingerprint

This is an implementation of the
[Avro 64-bit Rabin fingerprint algorithm](https://avro.apache.org/docs/1.8.2/spec.html#schema_fingerprints)
in Erlang.

The constants were generated from the Avro Java example using `java/AvroFingerprint.java`.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `avro_fingerprint` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:avro_fingerprint, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/avro_fingerprint](https://hexdocs.pm/avro_fingerprint).
