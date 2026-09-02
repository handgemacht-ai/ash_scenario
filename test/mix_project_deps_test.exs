defmodule AshScenario.MixProjectDepsTest do
  use ExUnit.Case

  test "mix.exs declares no path dependencies outside the repository" do
    project_root =
      Mix.Project.project_file()
      |> Path.dirname()
      |> Path.expand()

    outside_deps =
      Mix.Project.config()[:deps]
      |> Enum.filter(&path_dep?/1)
      |> Enum.reject(fn {_name, opts} ->
        target =
          opts[:path]
          |> Path.expand(project_root)

        within?(project_root, target)
      end)
      |> Enum.map(fn {name, opts} -> {name, opts[:path]} end)

    assert outside_deps == [],
           "standalone build is broken: path dependencies resolve outside the repository: #{inspect(outside_deps)}"
  end

  defp path_dep?({_name, opts}) when is_list(opts), do: Keyword.has_key?(opts, :path)
  defp path_dep?(_), do: false

  defp within?(root, target) do
    target == root or String.starts_with?(target, root <> "/")
  end
end
