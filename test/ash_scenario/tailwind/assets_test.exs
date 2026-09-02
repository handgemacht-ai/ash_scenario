defmodule AshScenario.Tailwind.AssetsTest do
  use ExUnit.Case

  test "link_tag/1 HTML-escapes a caller-supplied path" do
    path = ~s|"><script>alert(1)</script>|

    assert {:safe, iodata} = AshScenario.Tailwind.Assets.link_tag(path: path)
    html = IO.iodata_to_binary(iodata)

    refute html =~ "<script>alert(1)</script>"
    assert html =~ "&quot;&gt;&lt;script&gt;alert(1)&lt;/script&gt;"
  end
end
