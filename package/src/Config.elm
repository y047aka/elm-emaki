module Config exposing
    ( Config, render
    , string, bool, select, counter
    , list, fieldset
    , field
    )

{-|

@docs Config, render
@docs string, bool, select, counter
@docs list, fieldset
@docs field

-}

import Html exposing (Html, button, div, input, legend, text)
import Html.Attributes exposing (checked, placeholder, selected, type_, value)
import Html.Events exposing (onInput)


type Config msg
    = String (StringProps msg)
    | Bool (BoolProps msg)
    | Select (SelectProps msg)
    | Radio (RadioProps msg)
    | Counter (CounterProps msg)
    | List (List (Config msg))
    | FieldSet String (List (Config msg))
    | Field String (Config msg)


type alias StringProps msg =
    { value : String
    , onInput : String -> msg
    , placeholder : String
    }


type alias BoolProps msg =
    { value : Bool, onClick : msg }


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
    , onClickPlus : msg
    , onClickMinus : msg
    }


render : Config msg -> Html msg
render config =
    case config of
        String props ->
            input
                [ type_ "text"
                , value props.value
                , onInput props.onInput
                , placeholder props.placeholder
                ]
                []

        Bool props ->
            input [ type_ "checkbox", checked props.value ] []

        Select props ->
            Html.select [ onInput props.onChange ]
                (List.map (\option -> Html.option [ value option, selected (props.value == option) ] [ text option ])
                    props.options
                )

        Radio props ->
            Html.fieldset []
                (List.map
                    (\option ->
                        Html.label []
                            [ input
                                [ type_ "radio"
                                , value option
                                , checked (props.value == option)
                                , onInput props.onChange
                                ]
                                []
                            ]
                    )
                    props.options
                )

        Counter props ->
            div []
                [ button [] [ text "-" ]
                , text (String.fromFloat props.value)
                , button [] [ text "+" ]
                ]

        List configs ->
            div [] (List.map render configs)

        FieldSet label configs ->
            Html.fieldset [] <|
                legend [] [ text label ]
                    :: List.map render configs

        Field label config_ ->
            div []
                [ Html.label [] [ text label ]
                , render config_
                ]


string : StringProps msg -> Config msg
string =
    String


bool : BoolProps msg -> Config msg
bool =
    Bool


select : SelectProps msg -> Config msg
select =
    Select


counter : CounterProps msg -> Config msg
counter =
    Counter


list : List (Config msg) -> Config msg
list =
    List


fieldset : String -> List (Config msg) -> Config msg
fieldset =
    FieldSet


field : String -> Config msg -> Config msg
field =
    Field
