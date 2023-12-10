module Emaki.Controls exposing (..)

import Css exposing (..)
import Css.Palette exposing (paletteWith)
import DesignToken.Palette as Palette
import Html.Styled as Html exposing (Html, input, text)
import Html.Styled.Attributes exposing (css, placeholder, selected, type_, value)
import Html.Styled.Events exposing (onInput)


type alias Control a =
    a -> Html a


string : { placeholder : String } -> Control String
string r m =
    input
        [ type_ "text"
        , value m
        , onInput identity
        , placeholder r.placeholder
        , css
            [ property "appearance" "none"
            , padding (em 0.75)
            , fontSize inherit
            , borderRadius (em 0.25)
            , paletteWith (border3 (px 1) solid) Palette.formField
            ]
        ]
        []


select : { placeHolder : String, options : List String } -> Control String
select r m =
    Html.select
        [ onInput identity
        , css
            [ property "appearance" "none"
            , padding (em 0.75)
            , fontSize inherit
            , borderRadius (em 0.25)
            , paletteWith (border3 (px 1) solid) Palette.formField
            ]
        ]
        (List.map
            (\option ->
                Html.option
                    [ value option
                    , selected (m == option)
                    ]
                    [ text option ]
            )
            r.options
        )
