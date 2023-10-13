module Main exposing (main)

import Browser
import Html.Styled as Html exposing (Html, toUnstyled)
import Html.Styled.Events exposing (onClick)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { count : Int }


init : () -> ( Model, Cmd Msg )
init () =
    ( { count = 0 }, Cmd.none )



-- UPDATE


type Msg
    = IncrementClicked
    | DecrementClicked


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        IncrementClicked ->
            ( { model | count = model.count + 1 }, Cmd.none )

        DecrementClicked ->
            ( { model | count = model.count - 1 }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.button [ onClick DecrementClicked ]
            [ Html.text "-" ]
        , Html.text (" " ++ String.fromInt model.count ++ " ")
        , Html.button [ onClick IncrementClicked ]
            [ Html.text "+" ]
        ]
