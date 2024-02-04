module Emaki.Props exposing
    ( Props(..)
    , StringProps, BoolProps, SelectProps, RadioProps, CounterProps, BoolAndStringProps
    , render
    , comment, string, bool, select, radio, counter, boolAndString
    , list, fieldset
    , field
    , customize
    )

{-|

@docs Props
@docs StringProps, BoolProps, SelectProps, RadioProps, CounterProps, BoolAndStringProps
@docs render
@docs comment, string, bool, select, radio, counter, boolAndString
@docs list, fieldset
@docs field
@docs customize

-}

import Css exposing (..)
import Css.Extra exposing (fr, grid, gridColumn, gridRow, gridTemplateColumns, rowGap)
import Css.Global exposing (children, selector, typeSelector)
import Css.Palette as Palette exposing (Palette, palette, paletteWithBorder, setBackground, setColor)
import Css.Palette.Extra exposing (paletteByState)
import DesignToken.Palette as Palette
import Html.Styled as Html exposing (Attribute, Html, div, input, legend, text)
import Html.Styled.Attributes as Attributes exposing (css, placeholder, selected, type_, value)
import Html.Styled.Events exposing (onClick, onInput)


type Props msg
    = Comment String
    | String (StringProps msg)
    | Bool (BoolProps msg)
    | Select (SelectProps msg)
    | Radio (RadioProps msg)
    | Counter (CounterProps msg)
    | BoolAndString (BoolAndStringProps msg)
    | List (List (Props msg))
    | FieldSet String (List (Props msg))
    | Field { label : String } (Props msg)
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


comment : String -> Props msg
comment =
    Comment


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
    }
    -> Props msg
field { label, props } =
    Field { label = label } props


customize : Html msg -> Props msg
customize =
    Customize



-- VIEW


render : Props msg -> Html msg
render props =
    case props of
        Comment str ->
            Html.div [ css [ palette Palette.textOptional ] ] [ text str ]

        String ps ->
            input
                [ type_ "text"
                , value ps.value
                , onInput ps.onInput
                , placeholder ps.placeholder
                , css
                    [ property "appearance" "none"
                    , width (pct 100)
                    , padding (em 0.75)
                    , fontSize inherit
                    , lineHeight (em 1)
                    , borderRadius (em 0.25)
                    , paletteWithBorder (border3 (px 1) solid) Palette.formField
                    , focus
                        [ palette
                            { background = Nothing
                            , color = Just (rgba 0 0 0 0.95)
                            , border = Just (hex "#85b7d9")
                            }
                        , outline none
                        ]
                    ]
                ]
                []

        Bool ps ->
            Html.label []
                [ input [ type_ "checkbox", Attributes.checked ps.value, onClick ps.onClick ] []
                , text ps.label
                ]

        Select ps ->
            Html.div
                [ css
                    [ display grid
                    , property "grid-template-columns" "1fr auto"
                    , alignItems center
                    , before
                        [ property "content" (qt "▼")
                        , gridColumn "2"
                        , gridRow "1"
                        , padding (em 1)
                        , fontSize (em 0.6)
                        ]
                    ]
                ]
                [ Html.select
                    [ onInput ps.onChange
                    , css
                        [ gridColumn "1 / -1"
                        , gridRow "1"
                        , property "appearance" "none"
                        , width (pct 100)
                        , padding (em 0.75)
                        , fontSize inherit
                        , lineHeight (em 1)
                        , borderRadius (em 0.25)
                        , paletteWithBorder (border3 (px 1) solid) Palette.formField
                        , focus
                            [ palette
                                { background = Nothing
                                , color = Just (rgba 0 0 0 0.95)
                                , border = Just (hex "#85b7d9")
                                }
                            , outline none
                            ]
                        ]
                    ]
                    (List.map (\option -> Html.option [ value option, selected (ps.value == option) ] [ text option ])
                        ps.options
                    )
                ]

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
            labeledButtons []
                [ button_ [ onClick ps.onClickMinus ] [ text "-" ]
                , basicLabel [] [ text (ps.toString ps.value) ]
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
            div [ css [ displayFlex, flexDirection column, rowGap (Css.em 1) ] ]
                (List.map render childProps)

        FieldSet label childProps ->
            Html.div
                [ css
                    [ displayFlex
                    , flexDirection column
                    , rowGap (Css.em 1)
                    , borderWidth zero
                    ]
                ]
            <|
                legend [ css [ fontWeight bold ] ] [ text label ]
                    :: List.map render childProps

        Field { label } ps ->
            div
                [ css
                    [ display grid
                    , gridTemplateColumns [ fr 1, fr 1 ]
                    , alignItems center
                    ]
                ]
                [ Html.label [] [ text label ]
                , render ps
                ]

        Customize view ->
            view



-- VIEW HELPERS


labeledButtons : List (Attribute msg) -> List (Html msg) -> Html msg
labeledButtons attributes =
    Html.div <|
        css
            [ cursor pointer
            , display grid
            , property "grid-template-columns" "auto 1fr auto"
            , children
                [ typeSelector "button"
                    [ firstChild
                        [ borderTopRightRadius zero
                        , borderBottomRightRadius zero
                        ]
                    , lastChild
                        [ borderTopLeftRadius zero
                        , borderBottomLeftRadius zero
                        ]
                    ]
                , selector "*:not(button)"
                    [ displayFlex
                    , alignItems center
                    , justifyContent center
                    , fontSize (em 1)
                    , borderColor (rgba 34 36 38 0.15)

                    -- Extra Styles
                    , borderRadius zero
                    ]
                ]
            ]
            :: attributes


button_ : List (Attribute msg) -> List (Html msg) -> Html msg
button_ =
    Html.styled Html.button
        [ cursor pointer
        , minHeight (em 1)
        , outline none
        , borderStyle none
        , textAlign center
        , lineHeight (em 1)
        , fontWeight bold
        , padding2 (em 0.75) (em 1.5)
        , borderRadius (em 0.25)
        , property "user-select" "none"
        , paletteByState defaultPalettes
        , disabled
            [ cursor default
            , opacity (num 0.45)
            , backgroundImage none
            , pointerEvents none
            ]
        ]


defaultPalettes : ( Palette (ColorValue Color), List ( List Style -> Style, Palette (ColorValue Color) ) )
defaultPalettes =
    let
        default =
            { background = Just (hex "#E0E1E2")
            , color = Just (rgba 0 0 0 0.6)
            , border = Nothing
            }
    in
    ( default
    , [ ( hover, default |> setBackground (hex "#CACBCD") |> setColor (rgba 0 0 0 0.8) )
      , ( focus, default |> setBackground (hex "#CACBCD") |> setColor (rgba 0 0 0 0.8) )
      , ( active, default |> setBackground (hex "#BABBBC") |> setColor (rgba 0 0 0 0.9) )
      ]
    )


basicLabel : List (Attribute msg) -> List (Html msg) -> Html msg
basicLabel =
    Html.styled Html.div
        [ display inlineBlock
        , fontSize (rem 0.85714286)
        , lineHeight (num 1)
        , palette
            { background = Nothing
            , color = Just (rgba 0 0 0 0.87)
            , border = Nothing
            }
        , border3 (px 1) solid (rgba 34 36 38 0.15)
        , borderRadius (rem 0.25)
        , property "-webkit-transition" "background 0.1s ease"
        , property "transition" "background 0.1s ease"
        ]
