module Emaki exposing (Model, Msg, runChapter)

import Browser
import Emaki.Chapter as Chapter exposing (Chapter)
import Html.Styled as Styled


type Model props
    = ChapterModel (Chapter.Model props)


type Msg
    = ChapterMsg Chapter.Msg


runChapter : Chapter props -> Program () (Model props) Msg
runChapter { init, view, update } =
    Browser.sandbox
        { init = ChapterModel init
        , update = \(ChapterMsg subMsg) (ChapterModel subModel) -> ChapterModel (update subMsg subModel)
        , view =
            \(ChapterModel chapterModel) ->
                view chapterModel
                    |> Styled.map ChapterMsg
                    |> Styled.toUnstyled
        }
