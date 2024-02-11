# Emaki

## Quick Start

### 1. Install `elm-emaki` cli & Emaki Package

```shell
$ npm install git@github.com:y047aka/elm-emaki.git#main
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

## 将来的な emaki の例

動作を見たい view 関数の実装`someView : Args -> Html msg`があった時、emaki ファイルをこんな
感じに書くと動作確認できる画面ができる予定。

```elm
import Emaki
import Emaki.Control as Control


-- elm-emakiで表示したいviewをimport
import YourProject.UserProfileCard (view)


-- viewはこんな感じのものを想定
-- view : { userName : String, active : Bool } -> Html msg


main : Emaki.Emaki
main =
    Emaki.chapters
        [ Emaki.chapter
            { view = view
            , controls =
                [ Emaki.text
                    { init = ""
                    , label = "user name"
                    , onChange = \newValue viewProps -> { viewProps | userName = newValue }
                    }
                , Emaki.toggle
                    { init = False
                    , label = "active?"
                    , onChange = \newValue viewProps -> { viewProps | active = newValue }
                    }
                ]
            }
        ]
```
