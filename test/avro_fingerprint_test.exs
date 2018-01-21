defmodule Avro.FingerprintTest do
  use ExUnit.Case, async: true

  describe ":avro_fingerprint.crc64/1" do
    test "Avro project test cases" do
      for c <- read_cases("./test/data/avro/schema-tests.txt"), Map.has_key?(c, "canonical"), Map.has_key?(c, "fingerprint") do
        # IO.inspect c
        {expected, _rest} = Integer.parse(c["fingerprint"])
        # IO.puts("#{c["canonical"]} #{c["fingerprint"]} #{expected}")
        crc = :avro_fingerprint.crc64(c["canonical"])
        assert <<expected :: integer-unsigned-64>> == <<crc :: integer-unsigned-64>>, "#{c["canonical"]} #{crc} != #{c["fingerprint"]}"
      end
    end
  end

  # @tag :skip
  test "normalize_schema" do
    # Runs test cases from the Avro project: https://github.com/apache/avro/blob/master/share/test/data/schema-tests.txt
    for c <- read_cases("./test/data/avro/schema-tests.txt"), Map.has_key?(c, "canonical") do
      # IO.puts("#{c["input"]} #{c["canonical"]}")

      # https://avro.apache.org/docs/1.8.2/spec.html#Transforming+into+Parsing+Canonical+Form
      schema = :avro_json_decoder.decode_schema(c["input"])
      output = :avro_json_encoder.encode_schema(schema)
      assert output == c["canonical"], "#{c["input"]}: #{output} != #{c["canonical"]} #{inspect schema}"
    end
  end

  # https://github.com/apache/avro/blob/master/lang/java/avro/src/test/java/org/apache/avro/util/CaseFinder.java

  @doc "Read test cases from Java project"
  def read_cases(path) do
    chunk_fun = fn
      <<"<<INPUT\n">> = _line, acc when map_size(acc) > 0 ->
        # IO.write("> #{line}")
        # IO.puts("= input start of here")
        {:cont, acc, %{"_here_label" => "input", "_here_value" => ""}}
      <<"<<INPUT\n">> = _line, _acc ->
        # IO.write("> #{line}")
        # IO.puts("= input start of here first in file")
        {:cont, %{"_here_label" => "input", "_here_value" => ""}}

      <<"INPUT\n">> = _line, %{"_here_label" => here_label, "_here_value" => here_value} = acc ->
        # IO.write("> #{line}")
        # IO.puts("= INPUT end of here")
        # here_value = String.trim_trailing(here_value)
        # Remove a *single* newline
        here_value = String.replace_suffix(here_value, "\n", "")
        acc = Map.put(acc, here_label, here_value)
        acc = Map.drop(acc, ["_here_label", "_here_value"])
        {:cont, acc}

      <<"<<INPUT ", value::binary>> = _line, acc when map_size(acc) > 0 ->
        # IO.write("> #{line}")
        # IO.puts("= input simple")
        value = String.trim_trailing(value)
        {:cont, acc, %{"input" => value}}
      <<"<<INPUT ", value::binary>> = _line, _acc ->
        # IO.write("> #{line}")
        # IO.puts("= input simple first in file")
        value = String.trim_trailing(value)
        {:cont, %{"input" => value}}

      here_data = _line, %{"_here_value" => here_value} = acc ->
        # IO.write("> #{line}")
        # IO.puts("= here data")
        # Newlines are included in data
        acc = Map.put(acc, "_here_value", here_value <> here_data)
        {:cont, acc}

      <<"<<", data::binary>> = _line, acc ->
        # IO.write("> #{line}")
        data = String.trim_trailing(data)
        [label, value] = String.split(data, " ")
        # IO.puts("= result #{label} #{value}")
        {:cont, Map.merge(acc, %{label => value})}

      <<"//", _rest::binary>> = _line, acc ->
        # IO.write("> #{line}")
        # IO.puts("= comment")
        {:cont, acc}
      <<"#", _rest::binary>> = _line, acc ->
        # IO.write("> #{line}")
        # IO.puts("= comment")
        {:cont, acc}
      <<"\n">> = _line, acc ->
        # IO.write("> #{line}")
        # IO.puts("= blank")
        {:cont, acc}

      line, acc ->
        IO.write("> #{line}")
        IO.puts("= unmatched")
        {:cont, acc}

      #     result = Regex.named_captures(~r|<<INPUT\s+(?<input>.*)|, line) ->
      #       IO.puts("= input #{inspect result}")
      #       if map_size(acc) > 0 do
      #         {:cont, acc, %{"input" => Map.get(result, "input")}}
      #       else
      #         {:cont, %{"input" => Map.get(result, "input")}}
      #       end

      # line, acc ->
      #   IO.puts("> #{line}")
      #   cond do
      #     Regex.match?(~r|^//|, line) ->
      #       IO.puts("= comment")
      #       {:cont, acc}
      #
      #     Regex.match?(~r|^$|, line) ->
      #       IO.puts("= blank")
      #       {:cont, acc}
      #
      #     result = Regex.named_captures(~r|<<INPUT\s+(?<input>.*)|, line) ->
      #       IO.puts("= input #{inspect result}")
      #       if map_size(acc) > 0 do
      #         {:cont, acc, %{"input" => Map.get(result, "input")}}
      #       else
      #         {:cont, %{"input" => Map.get(result, "input")}}
      #       end
      #
      #     result = Regex.named_captures(~r|<<(?<label>\w+)\s+(?<value>.*)|, line) ->
      #       IO.puts("= result #{inspect result}")
      #       {:cont, Map.merge(acc, %{Map.get(result, "label") => Map.get(result, "value")})}
      #
      #     true ->
      #       IO.puts("= unmatched #{line}")
      #       {:cont, acc}
      #   end
    end

    after_fun = fn
      acc when map_size(acc) == 0 -> {:cont, %{}}
      acc -> {:cont, acc, %{}}
    end

    path
    |> File.stream!
    |> Stream.map( &(String.replace(&1, "\r\n", "\n")) )
    # |> Stream.map( &(String.replace(&1, "\n", "")) )
    |> Stream.chunk_while(%{}, chunk_fun, after_fun)
  end
end
