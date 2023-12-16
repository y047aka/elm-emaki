module Emaki.Props exposing
    ( Props(..)
    , StringProps, BoolProps, SelectProps, RadioProps, CounterProps, BoolAndStringProps
    , render
    , string, bool, select, radio, counter, boolAndString
    , list, fieldset
    , field
    , customize
    )

{-|

@docs Props
@docs StringProps, BoolProps, SelectProps, RadioProps, CounterProps, BoolAndStringProps
@docs render
@docs string, bool, select, radio, counter, boolAndString
@docs list, fieldset
@docs field
@docs customize

-}

import Css exposing (..)
import Css.Extra exposing (columnGap, rowGap)
import Css.Palette exposing (palette, paletteWithBorder)
import DesignToken.Palette as Palette
import Html.Styled as Html exposing (Html, button, div, input, legend, text)
import Html.Styled.Attributes as Attributes exposing (css, placeholder, selected, type_, value)
import Html.Styled.Events exposing (onClick, onInput)


type Props msg
    = String (StringProps msg)
    | Bool (BoolProps msg)
    | Select (SelectProps msg)
    | Radio (RadioProps msg)
    | Counter (CounterProps msg)
    | BoolAndString (BoolAndStringProps msg)
    | List (List (Props msg))
    | FieldSet String (List (Props msg))
    | Field { label : String, note : String } (Props msg)
    | Customize (Html msg)


type alias StringProps msg =
    { value : String
    , onInput : String -> msg
    , placeholder : String
    }


type alias BoolProps msg =
    { label : String
    , value : Bool
    , onClick : msg
    }


type alias SelectProps msg =
    { value : String
    , options : List String
    , onChange : String -> msg
    }


type alias RadioProps msg =
    { value : String
    , options : List String
    , onChange : String -> msg
    }


type alias CounterProps msg =
    { value : Float
    , toString : Float -> String
    , onClickPlus : msg
    , onClickMinus : msg
    }


type alias BoolAndStringProps msg =
    { label : String
    , id : String
    , data : { visible : Bool, value : String }
    , onUpdate : { visible : Bool, value : String } -> msg
    , placeholder : String
    }


render : Props msg -> Html msg
render props =
    case props of
        String ps ->
            input
                [ type_ "text"
                , value ps.value
                , onInput ps.onInput
                , placeholder ps.placeholder
                , css
                    [ property "appearance" "none"
                    , padding (em 0.75)
                    , fontSize inherit
                    , borderRadius (em 0.25)
                    , paletteWithBorder (border3 (px 1) solid) Palette.formField
                    ]
                ]
                []

        Bool ps ->
            Html.label []
                [ input [ type_ "checkbox", Attributes.checked ps.value, onClick ps.onClick ] []
                , text ps.label
                ]

        Select ps ->
            Html.select
                [ onInput ps.onChange
                , css
                    [ property "appearance" "none"
                    , padding (em 0.75)
                    , fontSize inherit
                    , borderRadius (em 0.25)
                    , paletteWithBorder (border3 (px 1) solid) Palette.formField
                    ]
                ]
                (List.map (\option -> Html.option [ value option, selected (ps.value == option) ] [ text option ])
                    ps.options
                )

        Radio ps ->
            Html.div []
                (List.map
                    (\option ->
                        Html.label [ css [ display block ] ]
                            [ input
                                [ type_ "radio"
                                , value option
                                , Attributes.checked (ps.value == option)
                                , onInput ps.onChange
                                ]
                                []
                            , text option
                            ]
                    )
                    ps.options
                )

        Counter ps ->
            let
                button_ attributes =
                    button
                        (css
                            [ padding2 (em 0.25) (em 0.5)
                            , borderRadius (em 0.25)
                            , paletteWithBorder (border3 (px 1) solid) Palette.formField
                            ]
                            :: attributes
                        )
            in
            div [ css [ displayFlex, alignItems center, columnGap (em 0.5) ] ]
                [ button_ [ onClick ps.onClickMinus ] [ text "-" ]
                , text (ps.toString ps.value)
                , button_ [ onClick ps.onClickPlus ] [ text "+" ]
                ]

        BoolAndString ({ data } as ps) ->
            div []
                [ div []
                    [ Html.label []
                        [ input
                            [ type_ "checkbox"
                            , Attributes.checked data.visible
                            , Attributes.disabled False
                            , onClick (ps.onUpdate { data | visible = not data.visible })
                            ]
                            []
                        , text ps.label
                        ]
                    ]
                , input
                    [ type_ "text"
                    , value data.value
                    , onInput (\string_ -> ps.onUpdate { data | value = string_ })
                    , placeholder ps.placeholder
                    ]
                    []
                ]

        List childProps ->
            div [] (List.map render childProps)

        FieldSet label childProps ->
            Html.div [ css [ borderWidth zero ] ] <|
                legend [ css [ fontWeight bold ] ] [ text label ]
                    :: List.map render childProps

        Field { label, note } ps ->
            div
                [ css
                    [ displayFlex
                    , flexDirection column
                    , rowGap (em 0.25)
                    ]
                ]
                [ div [] [ Html.label [ css [ fontWeight bold ] ] [ text label ] ]
                , render ps
                , div [ css [ palette Palette.textOptional ] ] [ text note ]
                ]

        Customize view ->
            view


string : StringProps msg -> Props msg
string =
    String


bool : BoolProps msg -> Props msg
bool =
    Bool


select : SelectProps msg -> Props msg
select =
    Select


radio : RadioProps msg -> Props msg
radio =
    Radio


counter : CounterProps msg -> Props msg
counter =
    Counter


boolAndString : BoolAndStringProps msg -> Props msg
boolAndString =
    BoolAndString


list : List (Props msg) -> Props msg
list =
    List


fieldset : String -> List (Props msg) -> Props msg
fieldset =
    FieldSet


field :
    { label : String
    , props : Props msg
    , note : String
    }
    -> Props msg
field { label, note, props } =
    Field { label = label, note = note } props


customize : Html msg -> Props msg
customize =
    Customize
