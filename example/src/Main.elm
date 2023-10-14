module Main exposing (main)

import Browser
import Css exposing (..)
import Css.Extra exposing (..)
import Css.Global exposing (Snippet)
import Css.Palette exposing (paletteWith, paletteWithBackgroundImage)
import DesignToken.Palette as Palette
import Emaki.Props as Props exposing (Props)
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes exposing (css)


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
    { progress : Float }


init : () -> ( Model, Cmd Msg )
init () =
    ( { progress = 0 }, Cmd.none )



-- UPDATE


type Msg
    = IncrementClicked
    | DecrementClicked


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        IncrementClicked ->
            ( { model | progress = model.progress + 1 }, Cmd.none )

        DecrementClicked ->
            ( { model | progress = model.progress - 1 }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    main_
        [ css
            [ padding (Css.em 1)
            , paletteWithBackgroundImage (linearGradient2 toBottomRight (stop (hex "FFF")) (stop <| hex "999") [])
                Palette.light
            ]
        ]
        [ resetCSS
        , article []
            [ h2 [] [ text "Progress" ]
            , playground
                { preview = div [] [ text ("progress: " ++ String.fromFloat model.progress) ]
                , props =
                    [ Props.field
                        { label = "count"
                        , props =
                            Props.counter
                                { value = model.progress
                                , toString = \progress -> " " ++ String.fromFloat progress ++ " "
                                , onClickPlus = IncrementClicked
                                , onClickMinus = DecrementClicked
                                }
                        , note = ""
                        }
                    ]
                }
            ]
        ]


playground :
    { preview : Html msg
    , props : List (Props msg)
    }
    -> Html msg
playground { preview, props } =
    section
        [ css
            [ padding (Css.em 0.5)
            , borderRadius (Css.em 1)
            , display grid
            , gridTemplateColumns [ fr 2, fr 1 ]
            , paletteWith (border3 (px 1) solid) Palette.light
            ]
        ]
        [ div [ css [ placeSelfCenter ] ] [ preview ]
        , div
            [ css
                [ padding (Css.em 0.5)
                , borderRadius (Css.em 0.5)
                , paletteWith (border3 (px 1) solid) Palette.light
                ]
            ]
            (List.map Props.render props)
        ]



-- RESET CSS


resetCSS : Html msg
resetCSS =
    let
        where_ : String -> List Style -> Snippet
        where_ selector_ styles =
            Css.Global.selector (":where(" ++ selector_ ++ ")") styles
    in
    Css.Global.global
        [ Css.Global.selector "*, ::before, ::after"
            [ boxSizing borderBox ]
        , Css.Global.everything
            [ margin zero ]
        , where_ ":root"
            [ fontFamily sansSerif ]
        ]
