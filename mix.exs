defmodule AvroFingerprint.Mixfile do
  use Mix.Project

  def project do
    [
      app: :avro_fingerprint,
      version: "0.1.0",
      elixir: "~> 1.5",
      language: :erlang,
      erlc_options: erlc_options(),
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  defp erlc_options do
    # Using Mix.Project.compile_path here raises an exception,
    options = [:debug_info, :warnings_as_errors, :warn_export_all, :warn_export_vars, :warn_shadow_vars, :warn_obsolete_guard]
    includes = Path.wildcard(Path.join(Mix.Project.deps_path, "*/include"))
    options ++ Enum.map(includes, fn(path) -> {:i, path} end)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:erlavro, github: "klarna/erlavro", tag: "2.3.0"}
    ]
  end
end
