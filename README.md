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

## Chapter API

よりユーザの入力負荷を減らすための Chapter API を開発中です。
一つのチャプターを表示するには、次のようなコードを書くことでチャプターを表示するアプリケーション
が作成できます。

```elm
import Emaki exposing (runChapter)
import Emaki.Chapter exposing (chapter)
import Emaki.Chapter.Control as Control


-- elm-emakiで表示したいviewをimport
import YourProject.UserProfileCard (view)


-- viewはこんな感じのものを想定
-- view : { userName : String, active : Bool } -> Html msg


main : Program () (Emaki.Model { userName : String, active : Bool }) Emaki.Msg
main =
    runChapter <|
        chapter
            { init = { userName = "", active = False }
            , view = view
            , controls =
                [ Control.text
                    { init = ""
                    , label = "user name"
                    , onChange = \newValue viewProps -> { viewProps | userName = newValue }
                    }
                , Control.toggle
                    { init = False
                    , label = "active?"
                    , onChange = \newValue viewProps -> { viewProps | active = newValue }
                    }
                ]
            }
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
                [ Control.text
                    { init = ""
                    , label = "user name"
                    , onChange = \newValue viewProps -> { viewProps | userName = newValue }
                    }
                , Control.toggle
                    { init = False
                    , label = "active?"
                    , onChange = \newValue viewProps -> { viewProps | active = newValue }
                    }
                ]
            }
        ]
```
