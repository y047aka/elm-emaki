module Emaki.Chapter.Internal exposing (Chapter, Model, Msg(..))

import Html.Styled exposing (Html)
import Json.Encode exposing (Value)


type alias Chapter props =
    { init : Model props
    , view : Model props -> Html Msg
    , update : Msg -> Model props -> Model props
    }


type alias Model props =
    { viewState : props
    , controlsState : Value
    }


type alias ControlIndex =
    Int


type Msg
    = UpdateControlAt ControlIndex Value
