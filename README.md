# life-counter

A tiny HTML-file which displays [how many land animals are slaughtered](https://ourworldindata.org/grapher/animals-slaughtered-for-meat) for food on average since starting the counter. Start the counter by clicking the left-button on your mouse. Click again to turn visibility off or on.

## Installation

Follow instruction on [installing nix](https://nixos.org/download.html). Once that's done, in the repository's root folder, run the following:

```sh
# Wait for dependencies to install.
nix-shell 

# When in nix-shell, this will generate an index.html file in the repository's root directory.
elm make --optimize ./src/elm/Main.elm
```

## Viewing HTML

```sh
open ./index.html
```
