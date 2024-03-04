module Emaki.Chapter.Control.Internal exposing (Control(..))

import Html.Styled exposing (Html)
import Json.Encode exposing (Value)


type Control props
    = Control
        { init : Value
        , view : Value -> Html Value
        , updateProps : Value -> props -> props
        }
