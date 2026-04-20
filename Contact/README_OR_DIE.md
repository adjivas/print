https://mouse.frama.io/blog/navi/blog.fr.pdf
https://mouse.frama.io/blog/mouse/blog.fr.pdf

TODO remove: \endinput

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
