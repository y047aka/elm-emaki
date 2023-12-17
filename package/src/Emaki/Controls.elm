module Emaki.Controls exposing
    ( Control
    , string
    , int
    , toggle
    , select
    , radio
    , action
    )

{-|


## controls

controlはUIパーツのパラメータを変更するためのコントロールです。

@docs Control


## Basics

@docs string
@docs int
@docs toggle
@docs select
@docs radio


## Advanced

@docs action

-}

import Css exposing (..)
import Css.Palette as Palette
import DesignToken.Palette as Palette
import Html.Styled as Html exposing (Html, input, text)
import Html.Styled.Attributes as Attributes exposing (css, placeholder, selected, type_, value)
import Html.Styled.Events exposing (onCheck, onClick, onInput)


type alias Control a b =
    Never


type alias Element model msg =
    { update : msg -> model -> ( model, Cmd msg )
    , view : model -> Html msg
    , subscriptions : model -> Sub msg
    }


{-| コントロール
-}
pure : a -> Element a msg
pure =
    Debug.todo "pure"


{-| フリーテキスト
-}
string : { placeholder : String } -> Control String String
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
            , Palette.paletteWithBorder (border3 (px 1) solid) Palette.formField
            ]
        ]
        []


{-| 数値
-}
int : { placeholder : String } -> Control Int (Maybe Int)
int r m =
    input
        [ type_ "number"
        , value (String.fromInt m)
        , onInput String.toInt
        , placeholder r.placeholder
        , css
            [ property "appearance" "none"
            , padding (em 0.75)
            , fontSize inherit
            , borderRadius (em 0.25)
            , Palette.paletteWithBorder (border3 (px 1) solid) Palette.formField
            ]
        ]
        []


{-| ブーリアンのコントロール
-}
toggle : { label : String } -> Control Bool Bool
toggle r m =
    Html.label []
        [ input [ type_ "checkbox", Attributes.checked m, onCheck identity ] []
        , text r.label
        ]


{-| Stringを一つ選択させるその1
-}
select : { placeHolder : String, options : List String } -> Control String String
select r m =
    Html.select
        [ onInput identity
        , css
            [ property "appearance" "none"
            , padding (em 0.75)
            , fontSize inherit
            , borderRadius (em 0.25)
            , Palette.paletteWithBorder (border3 (px 1) solid) Palette.formField
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


{-| Stringを一つ選択させるその2
-}
radio : { options : List String } -> Control String String
radio r m =
    Html.fieldset []
        (List.map
            (\option ->
                Html.label []
                    [ input
                        [ type_ "radio"
                        , value option
                        , Attributes.checked (m == option)
                        , onInput identity
                        ]
                        []
                    ]
            )
            r.options
        )



-- {-| 数値の増減のコントロール
-- -}
-- counter :
--     { incr : output
--     , decr : output
--     , show : input -> String
--     }
--     -> Control input output
-- counter =
--     let
--         button_ attributes =
--             button
--                 (css
--                     [ padding2 (em 0.25) (em 0.5)
--                     , borderRadius (em 0.25)
--                     , Palette.paletteWithBorder (border3 (px 1) solid) Palette.formField
--                     ]
--                     :: attributes
--                 )
--     in
--     \r m ->
--         div [ css [ displayFlex, alignItems center, columnGap (em 0.5) ] ]
--             [ button_ [ onClick r.decr ] [ text "-" ]
--             , text (r.show m)
--             , button_ [ onClick r.incr ] [ text "+" ]
--             ]


{-| 何らかのmsgを発火する為だけのコントロール
-}
action : { label : String, action : msg } -> Control () msg
action r _ =
    Html.label []
        [ input [ onClick r.action ] []
        , text r.label
        ]
