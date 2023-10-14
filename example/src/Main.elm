module Main exposing (main)

import Browser
import Css exposing (..)
import Css.Extra exposing (..)
import Css.Palette exposing (palette, paletteWith)
import DesignToken.Palette as Palette
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes exposing (css)
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
    main_
        [ css
            [ boxSizing borderBox
            , fontFamily sansSerif
            , palette Palette.default
            ]
        ]
        [ article []
            [ h2 [] [ text "Progress" ]
            , playground
                { preview = div [] [ text ("progress: " ++ String.fromInt model.count) ]
                , props =
                    [ button [ onClick DecrementClicked ]
                        [ text "-" ]
                    , text (" " ++ String.fromInt model.count ++ " ")
                    , button [ onClick IncrementClicked ]
                        [ text "+" ]
                    ]
                }
            ]
        ]


playground :
    { preview : Html msg
    , props : List (Html msg)
    }
    -> Html msg
playground { preview, props } =
    section
        [ css
            [ padding (Css.em 0.5)
            , borderRadius (Css.em 1)
            , display grid
            , gridTemplateColumns [ fr 2, fr 1 ]
            , paletteWith (border3 (px 1) solid) Palette.default
            ]
        ]
        [ div [ css [ placeSelfCenter ] ] [ preview ]
        , div
            [ css
                [ padding (Css.em 0.5)
                , borderRadius (Css.em 0.5)
                , paletteWith (border3 (px 1) solid) Palette.default
                ]
            ]
            props
        ]
