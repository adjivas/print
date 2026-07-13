https://mouse.frama.io/blog/navi/blog.fr.pdf
https://mouse.frama.io/blog/mouse/blog.fr.pdf

```shell
for path in $(find . -type d -path "./Article*/ressources/feed"); do
  cat $path/mouse.json | atomize.bb -i -b ressources/feed/mouse.atom -n 100
  cat $path/navi.json | atomize.bb -i -b ressources/feed/navi.atom -n 100
done
```

```shell
nix-shell -p sourceHighlight
source-highlight --line-number-ref --title="Contains references to tags"  -s json -f html5 -i virtualisation.nix -o virtualisation.html
```

```shell
nix-shell -p svg2tikz
svg2tikz --standalone mouse.svg > mouse.tex
```

Aknowledge
https://www.smashingmagazine.com/2025/12/smashing-animations-part-7-recreating-toon-text-css-svg/
https://stuffandnonsense.co.uk/toon-text/tool.html
https://200ok.ch/posts/2025-03-17_atomize_a_simple_cli_tool_for_managing_atom_feeds.html
