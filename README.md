# Emaki

## Quick Start

### 1. Install `elm-emaki` cli & Emaki Package

```shell
$ npm install git@github.com:y047aka/emaki.git#main
$ npx tsc
$ chmod a+x dist/main.mjs
$ elm install y047aka/emaki
```

### 2. Write `Emaki.elm`

```elm
-- emaki/Emaki.elm
import Emaki exposing (..)

emaki : ???
emaki = [
   section "button" ???
]
```

### 3. View Emaki in browser

```shell
$ npx elm-emaki
```
