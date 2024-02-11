module Emaki.Control exposing
    ( Control
    , StringControl, BoolControl, SelectControl, RadioControl, CounterControl, BoolAndStringControl
    , render
    , comment, string, bool, select, radio, counter, boolAndString
    , field
    , customize
    )

{-|

@docs Control
@docs StringControl, BoolControl, SelectControl, RadioControl, CounterControl, BoolAndStringControl
@docs render
@docs comment, string, bool, select, radio, counter, boolAndString
@docs field
@docs customize

-}

import Css exposing (..)
import Css.Extra exposing (columnGap, fr, grid, gridColumn, gridRow, gridTemplateColumns)
import Css.Global exposing (children, everything, generalSiblings, selector, typeSelector)
import Css.Palette as Palette exposing (Palette, palette, paletteWithBorder, setBackground, setBorder, setColor)
import Css.Palette.Extra exposing (paletteByState)
import DesignToken.Palette as Palette
import Html.Styled as Html exposing (Attribute, Html, div, input, text)
import Html.Styled.Attributes as Attributes exposing (css, for, id, placeholder, selected, type_, value)
import Html.Styled.Events exposing (onClick, onInput)


type Control msg
    = Comment String
    | String (StringControl msg)
    | Bool (BoolControl msg)
    | Select (SelectControl msg)
    | Radio (RadioControl msg)
    | Counter (CounterControl msg)
    | BoolAndString (BoolAndStringControl msg)
    | Field String (Control msg)
    | Customize (Html msg)


type alias StringControl msg =
    { value : String
    , onInput : String -> msg
    , placeholder : String
    }


type alias BoolControl msg =
    { id : String
    , value : Bool
    , onClick : msg
    }


type alias SelectControl msg =
    { value : String
    , options : List String
    , onChange : String -> msg
    }


type alias RadioControl msg =
    { value : String
    , options : List String
    , onChange : String -> msg
    }


type alias CounterControl msg =
    { value : Float
    , toString : Float -> String
    , onClickPlus : msg
    , onClickMinus : msg
    }


type alias BoolAndStringControl msg =
    { label : String
    , id : String
    , data : { visible : Bool, value : String }
    , onUpdate : { visible : Bool, value : String } -> msg
    , placeholder : String
    }


comment : String -> Control msg
comment =
    Comment


string : StringControl msg -> Control msg
string =
    String


bool : BoolControl msg -> Control msg
bool =
    Bool


select : SelectControl msg -> Control msg
select =
    Select


radio : RadioControl msg -> Control msg
radio =
    Radio


counter : CounterControl msg -> Control msg
counter =
    Counter


boolAndString : BoolAndStringControl msg -> Control msg
boolAndString =
    BoolAndString


field : String -> Control msg -> Control msg
field label props =
    Field label props


customize : Html msg -> Control msg
customize =
    Customize



-- VIEW


render : Control msg -> Html msg
render props =
    case props of
        Comment str ->
            div
                [ css
                    [ palette Palette.textOptional
                    , empty [ display none ]
                    ]
                ]
                [ text str ]

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
            toggleCheckbox
                { id = ps.id
                , checked = ps.value
                , onClick = ps.onClick
                }

        Select ps ->
            div
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
            div []
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

        Field label ps ->
            div
                [ css
                    [ display grid
                    , gridTemplateColumns [ fr 1, fr 1 ]
                    , alignItems center
                    , columnGap (em 0.25)
                    ]
                ]
                [ Html.label [] [ text label ]
                , render ps
                ]

        Customize view ->
            view



-- VIEW HELPERS


toggleCheckbox :
    { id : String
    , checked : Bool
    , onClick : msg
    }
    -> Html msg
toggleCheckbox props =
    Html.styled div
        [ display grid
        , children [ everything [ gridColumn "1", gridRow "1" ] ]
        ]
        []
        [ toggleInput
            [ id props.id
            , type_ "checkbox"
            , Attributes.checked props.checked
            , onClick props.onClick
            ]
            []
        , toggleLabel [ for props.id ] []
        ]


toggleInput : List (Attribute msg) -> List (Html msg) -> Html msg
toggleInput =
    Html.styled Html.input
        [ cursor pointer
        , width (rem 3.5)
        , height (rem 1.5)
        , opacity zero
        , focus
            [ generalSiblings
                [ Css.Global.label
                    [ before [ palette (Palette.init |> setBackground (rgba 0 0 0 0.15)) ] ]
                ]
            ]
        , checked
            [ generalSiblings
                [ Css.Global.label
                    [ before
                        [ palette
                            (Palette.init
                                |> setBackground (hex "#2185D0")
                                |> setBorder (rgba 34 36 38 0.35)
                            )
                        ]
                    , after
                        [ left (rem 2.15) ]
                    ]
                ]
            , focus
                [ generalSiblings
                    [ Css.Global.label
                        [ before
                            [ backgroundColor (hex "#0d71bb") ]
                        ]
                    ]
                ]
            ]
        ]


toggleLabel : List (Attribute msg) -> List (Html msg) -> Html msg
toggleLabel =
    Html.styled Html.label
        [ position relative
        , outline none
        , before
            [ position absolute
            , top zero
            , left zero
            , zIndex (int 1)
            , property "content" "''"
            , display block
            , width (rem 3.5)
            , height (rem 1.5)
            , borderRadius (rem 500)
            , property "-webkit-transition" "border 0.1s ease, opacity 0.1s ease, -webkit-transform 0.1s ease, -webkit-box-shadow 0.1s ease"
            , property "transition" "border 0.1s ease, opacity 0.1s ease, -webkit-transform 0.1s ease, -webkit-box-shadow 0.1s ease"
            , property "transition" "border 0.1s ease, opacity 0.1s ease, transform 0.1s ease, box-shadow 0.1s ease"
            , property "transition" "border 0.1s ease, opacity 0.1s ease, transform 0.1s ease, box-shadow 0.1s ease, -webkit-transform 0.1s ease, -webkit-box-shadow 0.1s ease"
            , palette
                (Palette.init
                    |> setBackground (rgba 0 0 0 0.05)
                    |> setBorder (hex "#D4D4D5")
                )
            ]
        , after
            [ position absolute
            , top zero
            , left (rem -0.05)
            , zIndex (int 2)
            , property "content" "''"
            , width (rem 1.5)
            , height (rem 1.5)
            , borderRadius (rem 500)
            , property "-webkit-transition" "background 0.3s ease, left 0.3s ease"
            , property "transition" "background 0.3s ease, left 0.3s ease"
            , property "background" "#FFFFFF -webkit-gradient(linear, left top, left bottom, from(transparent), to(rgba(0, 0, 0, 0.05)))"
            , property "background" "#FFFFFF -webkit-linear-gradient(transparent, rgba(0, 0, 0, 0.05))"
            , property "background" "#FFFFFF linear-gradient(transparent, rgba(0, 0, 0, 0.05))"
            , property "-webkit-box-shadow" "0 1px 2px 0 rgba(34, 36, 38, 0.15), 0 0 0 1px rgba(34, 36, 38, 0.15) inset"
            , property "box-shadow" "0 1px 2px 0 rgba(34, 36, 38, 0.15), 0 0 0 1px rgba(34, 36, 38, 0.15) inset"
            ]
        , active
            [ before
                [ palette (Palette.init |> setBackground (hex "#F9FAFB")) ]
            , after
                [ color (rgba 0 0 0 0.95) ]
            ]
        , hover
            [ before
                [ palette (Palette.init |> setBackground (rgba 0 0 0 0.15)) ]
            ]
        ]


labeledButtons : List (Attribute msg) -> List (Html msg) -> Html msg
labeledButtons attributes =
    div <|
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
    Html.styled div
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
