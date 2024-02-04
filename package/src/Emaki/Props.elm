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
import Css.Global exposing (children, everything, generalSiblings, selector, typeSelector)
import Css.Palette as Palette exposing (Palette, palette, paletteWithBorder, setBackground, setBorder, setColor)
import Css.Palette.Extra exposing (paletteByState)
import DesignToken.Palette as Palette
import Html.Styled as Html exposing (Attribute, Html, div, input, legend, text)
import Html.Styled.Attributes as Attributes exposing (css, for, id, placeholder, selected, type_, value)
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
    | Field String (Props msg)
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


field : String -> Props msg -> Props msg
field label props =
    Field label props


customize : Html msg -> Props msg
customize =
    Customize



-- VIEW


render : Props msg -> Html msg
render props =
    case props of
        Comment str ->
            Html.div
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
                { id = ps.label
                , label = ps.label
                , checked = ps.value
                , onClick = ps.onClick
                }

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
                legend [ css [ fontWeight bold, empty [ display none ] ] ] [ text label ]
                    :: List.map render childProps

        Field label ps ->
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


toggleCheckbox :
    { id : String
    , label : String
    , checked : Bool
    , onClick : msg
    }
    -> Html msg
toggleCheckbox props =
    Html.styled Html.div
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
        , toggleLabel [ for props.id ] [ text props.label ]
        ]


toggleInput : List (Attribute msg) -> List (Html msg) -> Html msg
toggleInput =
    Html.styled Html.input
        [ cursor pointer
        , opacity zero
        , active
            [ generalSiblings
                [ Css.Global.label
                    [ -- .ui.checkbox input:active ~ label
                      color (rgba 0 0 0 0.95)
                    ]
                ]
            ]
        , focus
            [ generalSiblings
                [ Css.Global.label
                    [ -- .ui.checkbox input:focus ~ label
                      color (rgba 0 0 0 0.95)

                    -- .ui.checkbox input:focus ~ label:before
                    , before
                        [ palette
                            (Palette.init
                                |> setBackground (hex "#FFFFFF")
                                |> setBorder (hex "#96C8DA")
                            )
                        ]

                    -- .ui.checkbox input:focus ~ label:after
                    , after
                        [ color (rgba 0 0 0 0.95) ]
                    ]
                ]
            ]
        , checked
            [ generalSiblings
                [ Css.Global.label
                    [ -- .ui.checkbox input:checked ~ label:before
                      before
                        [ palette
                            (Palette.init
                                |> setBackground (hex "#FFFFFF")
                                |> setBorder (rgba 34 36 38 0.35)
                            )
                        ]

                    -- .ui.checkbox input:checked ~ label:after
                    , after
                        [ opacity (int 1)
                        , color (rgba 0 0 0 0.95)
                        ]

                    -- .ui.checkbox input:checked ~ .box:after
                    -- .ui.checkbox input:checked ~ label:after
                    , after
                        [ property "content" "url(\"data:image/svg+xml,%3csvg viewBox='0 0 16 16' fill='black' xmlns='http://www.w3.org/2000/svg'%3e%3cpath d='M5.707 7.293a1 1 0 0 0-1.414 1.414l2 2a1 1 0 0 0 1.414 0l4-4a1 1 0 0 0-1.414-1.414L7 8.586 5.707 7.293z'/%3e%3c/svg%3e\")" ]
                    ]
                ]
            ]
        , -- .ui.toggle.checkbox input
          width (rem 3.5)
        , height (rem 1.5)

        -- .ui.toggle.checkbox input:focus ~ label:before
        , focus
            [ generalSiblings
                [ Css.Global.label
                    [ before
                        [ backgroundColor (rgba 0 0 0 0.15)
                        , property "border" "none"
                        ]
                    ]
                ]
            ]

        -- .ui.toggle.checkbox input:checked ~ label
        , checked
            [ generalSiblings
                [ Css.Global.label
                    [ color (rgba 0 0 0 0.95) |> important

                    -- .ui.toggle.checkbox input:checked ~ label:before
                    , before
                        [ backgroundColor (hex "#2185D0") |> important ]

                    -- .ui.toggle.checkbox input:checked ~ label:after
                    , after
                        [ left (rem 2.15)
                        , property "-webkit-box-shadow" "0 1px 2px 0 rgba(34, 36, 38, 0.15), 0 0 0 1px rgba(34, 36, 38, 0.15) inset"
                        , property "box-shadow" "0 1px 2px 0 rgba(34, 36, 38, 0.15), 0 0 0 1px rgba(34, 36, 38, 0.15) inset"
                        ]
                    ]
                ]

            -- .ui.toggle.checkbox input:focus:checked ~ label
            , focus
                [ generalSiblings
                    [ Css.Global.label
                        [ color (rgba 0 0 0 0.95) |> important

                        -- .ui.toggle.checkbox input:focus:checked ~ label:before
                        , before
                            [ backgroundColor (hex "#0d71bb") |> important ]
                        ]
                    ]
                ]
            ]
        ]


toggleLabel : List (Attribute msg) -> List (Html msg) -> Html msg
toggleLabel =
    Html.styled Html.label
        [ -- .ui.checkbox label
          position relative
        , display block
        , paddingLeft (em 1.85714)
        , outline none

        -- .ui.checkbox label:before
        , before
            [ position absolute
            , top zero
            , left zero
            , property "content" "''"
            , borderRadius (rem 0.21428571)
            , property "-webkit-transition" "border 0.1s ease, opacity 0.1s ease, -webkit-transform 0.1s ease, -webkit-box-shadow 0.1s ease"
            , property "transition" "border 0.1s ease, opacity 0.1s ease, -webkit-transform 0.1s ease, -webkit-box-shadow 0.1s ease"
            , property "transition" "border 0.1s ease, opacity 0.1s ease, transform 0.1s ease, box-shadow 0.1s ease"
            , property "transition" "border 0.1s ease, opacity 0.1s ease, transform 0.1s ease, box-shadow 0.1s ease, -webkit-transform 0.1s ease, -webkit-box-shadow 0.1s ease"
            , paletteWithBorder (border3 (px 1) solid)
                (Palette.init
                    |> setBackground (hex "#FFFFFF")
                    |> setBorder (hex "#D4D4D5")
                )
            ]

        -- .ui.checkbox label:after
        , after
            [ position absolute
            , fontSize (px 14)
            , top zero
            , left zero
            , textAlign center
            , opacity zero
            , color (rgba 0 0 0 0.87)
            , property "-webkit-transition" "border 0.1s ease, opacity 0.1s ease, -webkit-transform 0.1s ease, -webkit-box-shadow 0.1s ease;"
            , property "transition" "border 0.1s ease, opacity 0.1s ease, -webkit-transform 0.1s ease, -webkit-box-shadow 0.1s ease;"
            , property "transition" "border 0.1s ease, opacity 0.1s ease, transform 0.1s ease, box-shadow 0.1s ease;"
            , property "transition" "border 0.1s ease, opacity 0.1s ease, transform 0.1s ease, box-shadow 0.1s ease, -webkit-transform 0.1s ease, -webkit-box-shadow 0.1s ease;"
            ]

        -- Hover
        , hover
            [ -- .ui.checkbox label:hover::before
              before
                [ palette
                    (Palette.init
                        |> setBackground (hex "#FFFFFF")
                        |> setBorder (rgba 34 36 38 0.35)
                    )
                ]

            -- .ui.checkbox label:hover
            -- .ui.checkbox + label:hover
            , color (rgba 0 0 0 0.8)
            ]

        -- Down
        , active
            [ -- .ui.checkbox label:active::before
              before
                [ palette
                    (Palette.init
                        |> setBackground (hex "#F9FAFB")
                        |> setBorder (rgba 34 36 38 0.35)
                    )
                ]

            -- .ui.checkbox label:active::after
            , after
                [ color (rgba 0 0 0 0.95) ]
            ]

        -- .ui.checkbox input.hidden + label
        , cursor pointer
        , property "-webkit-user-select" "none"
        , property "-moz-user-select" "none"
        , property "-ms-user-select" "none"
        , property "user-select" "none"

        -- .ui.toggle.checkbox label
        , minHeight (rem 1.5)
        , paddingLeft (rem 4.5)
        , color (rgba 0 0 0 0.87)

        -- .ui.toggle.checkbox label
        , paddingTop (em 0.15)

        -- .ui.toggle.checkbox label:before
        , before
            [ display block
            , position absolute
            , property "content" "''"
            , zIndex (int 1)
            , property "-webkit-transform" "none"
            , property "transform" "none"
            , property "border" "none"
            , top zero
            , backgroundColor (rgba 0 0 0 0.05)
            , property "-webkit-box-shadow" "none"
            , property "box-shadow" "none"
            , width (rem 3.5)
            , height (rem 1.5)
            , borderRadius (rem 500)
            ]

        -- .ui.toggle.checkbox label:after
        , after
            [ property "background" "#FFFFFF -webkit-gradient(linear, left top, left bottom, from(transparent), to(rgba(0, 0, 0, 0.05)))"
            , property "background" "#FFFFFF -webkit-linear-gradient(transparent, rgba(0, 0, 0, 0.05))"
            , property "background" "#FFFFFF linear-gradient(transparent, rgba(0, 0, 0, 0.05))"
            , position absolute
            , property "content" "''" |> important
            , opacity (int 1)
            , zIndex (int 2)
            , property "border" "none"
            , property "-webkit-box-shadow" "0 1px 2px 0 rgba(34, 36, 38, 0.15), 0 0 0 1px rgba(34, 36, 38, 0.15) inset"
            , property "box-shadow" "0 1px 2px 0 rgba(34, 36, 38, 0.15), 0 0 0 1px rgba(34, 36, 38, 0.15) inset"
            , width (rem 1.5)
            , height (rem 1.5)
            , top zero
            , left zero
            , borderRadius (rem 500)
            , property "-webkit-transition" "background 0.3s ease, left 0.3s ease"
            , property "transition" "background 0.3s ease, left 0.3s ease"

            -- .ui.toggle.checkbox input ~ label:after
            , left (rem -0.05)
            , property "-webkit-box-shadow" "0 1px 2px 0 rgba(34, 36, 38, 0.15), 0 0 0 1px rgba(34, 36, 38, 0.15) inset"
            , property "box-shadow" "0 1px 2px 0 rgba(34, 36, 38, 0.15), 0 0 0 1px rgba(34, 36, 38, 0.15) inset"
            ]

        -- .ui.toggle.checkbox label:hover::before {
        , hover
            [ before
                [ backgroundColor (rgba 0 0 0 0.15)
                , property "border" "none"
                ]
            ]
        ]


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
