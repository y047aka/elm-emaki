module Emaki exposing (Chapter, Control, main, runChapter, text)

import Array
import Browser
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (type_, value)
import Html.Styled.Events exposing (onInput)
import Json.Decode as JD
import Json.Encode as JE


type Control props
    = Control
        { init : JE.Value
        , view : JE.Value -> Styled.Html JE.Value
        , updateProp : JE.Value -> props -> props
        }


type alias ChapterModel props =
    { viewState : props
    , controlsState : JE.Value
    }


type Chapter props
    = Chapter
        { init : ChapterModel props
        , view : ChapterModel props -> Styled.Html ChapterMsg
        , update : ChapterMsg -> ChapterModel props -> ChapterModel props
        }


type alias ControlIndex =
    Int


type ChapterMsg
    = UpdateControlAt ControlIndex JE.Value


runChapter : Chapter props -> Program () (ChapterModel props) ChapterMsg
runChapter (Chapter r) =
    Browser.sandbox
        { init = r.init
        , update = r.update
        , view = Styled.toUnstyled << r.view
        }


chapter :
    { init : props
    , view : props -> Html ChapterMsg
    , controls : List (Control props)
    }
    -> Chapter props
chapter { init, view, controls } =
    let
        controlInits =
            List.map (\(Control r) -> r.init) controls

        controlViews =
            List.map (\(Control r) -> r.view) controls

        controlOnChanges =
            List.map (\(Control r) -> r.updateProp) controls
                |> Array.fromList

        chapterView : ChapterModel props -> Styled.Html ChapterMsg
        chapterView { viewState, controlsState } =
            Styled.div []
                [ Styled.fromUnstyled (view viewState)
                , controlsState
                    |> JD.decodeValue (JD.list JD.value)
                    |> Result.withDefault controlInits
                    |> List.map2 (<|) controlViews
                    |> List.map (Styled.li [] << List.singleton)
                    |> List.indexedMap (\i -> Styled.map (UpdateControlAt i))
                    |> Styled.ul []
                ]

        update (UpdateControlAt idx newValue) { viewState, controlsState } =
            { viewState = Maybe.withDefault (always identity) (Array.get idx controlOnChanges) newValue viewState
            , controlsState =
                controlsState
                    |> JD.decodeValue (JD.array JD.value)
                    |> Result.map (Array.set idx newValue >> JE.array identity)
                    |> Result.withDefault controlsState
            }
    in
    Chapter
        { init = ChapterModel init (JE.list identity controlInits)
        , view = chapterView
        , update = update
        }


text : { init : String, label : String, onChange : String -> props -> props } -> Control props
text { init, label, onChange } =
    Control
        { init = JE.string init
        , view =
            \v ->
                Styled.input
                    [ type_ "text"
                    , onInput JE.string
                    , value (Result.withDefault init (JD.decodeValue JD.string v))
                    ]
                    []
        , updateProp =
            \value state ->
                JD.decodeValue JD.string value
                    |> Result.map onChange
                    |> Result.withDefault identity
                    |> (\update -> update state)
        }


exampleView : { userName : String } -> Html msg
exampleView { userName } =
    Html.text ("User Name: " ++ userName)


main : Program () (ChapterModel { userName : String }) ChapterMsg
main =
    runChapter <|
        chapter
            { init = { userName = "" }
            , view = exampleView
            , controls =
                [ text
                    { init = "default"
                    , label = "user name"
                    , onChange = \newValue viewProp -> { viewProp | userName = newValue }
                    }
                ]
            }
