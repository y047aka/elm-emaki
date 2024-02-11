module Emaki.Chapter.Control exposing (Control, text)

import Emaki.Chapter.Control.Internal as Internal
import Html.Styled exposing (input)
import Html.Styled.Attributes exposing (type_, value)
import Html.Styled.Events exposing (onInput)
import Json.Decode as JD
import Json.Encode as JE


type alias Control props =
    Internal.Control props


text :
    { init : String
    , label : String
    , onChange : String -> props -> props
    }
    -> Control props
text r =
    Internal.Control
        { init = JE.string r.init
        , view =
            \v ->
                input
                    [ type_ "text"
                    , onInput JE.string
                    , value (Result.withDefault r.init (JD.decodeValue JD.string v))
                    ]
                    []
        , updateProp =
            \value state ->
                value
                    |> JD.decodeValue JD.string
                    |> Result.map r.onChange
                    |> Result.withDefault identity
                    |> (\update -> update state)
        }
