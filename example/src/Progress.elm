module Progress exposing
    ( Model, State(..), init
    , Msg(..), update, clampValue, updateCaptionOnIndicating
    , progressWithProps, stateFromString, stateToString
    )

{-|

@docs Model, State, init
@docs Msg, update, clampValue, updateCaptionOnIndicating
@docs progressWithProps, stateFromString, stateToString

-}

import Css exposing (..)
import Css.Animations as Animations exposing (keyframes)
import Html.Styled as Html exposing (Attribute, Html, text)
import Random



-- MODEL


type alias Model =
    { value : Float
    , unit : String
    , indicating : Bool
    , state : State
    , caption : String
    }


type State
    = Default
    | Active
    | Success
    | Warning
    | Error
    | Disabled


init : ( Model, Cmd Msg )
init =
    ( { value = 0
      , unit = "%"
      , indicating = False
      , state = Default
      , caption = "Uploading Files"
      }
    , Random.generate SetValue (Random.int 10 50)
    )



-- UPDATE


type Msg
    = SetValue Int
    | CounterPlus
    | CounterMinus


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetValue int ->
            let
                sum =
                    model.value + toFloat int

                clamped =
                    if sum > 100 then
                        100

                    else if sum < 0 then
                        0

                    else
                        sum
            in
            ( { model | value = clamped }
                |> updateCaptionOnIndicating
            , Cmd.none
            )

        CounterPlus ->
            ( model, Random.generate SetValue (Random.int 10 15) )

        CounterMinus ->
            ( model, Random.generate SetValue (Random.int -15 -10) )


clampValue : Float -> Float
clampValue =
    max 0 >> min 100


updateCaptionOnIndicating : Model -> Model
updateCaptionOnIndicating m =
    { m
        | caption =
            case ( m.indicating, m.value == 100 ) of
                ( True, True ) ->
                    "Project Funded!"

                ( True, False ) ->
                    String.fromFloat m.value ++ "% Funded"

                ( False, _ ) ->
                    m.caption
    }



-- VIEW


progressWithProps : Model -> Html msg
progressWithProps props =
    progressInternal
        { wrapper = basis { disabled = props.state == Disabled }
        , bar = bar props
        , caption =
            case props.caption of
                "" ->
                    text ""

                _ ->
                    label props [] [ text props.caption ]
        }


progressInternal :
    { wrapper : List (Attribute msg) -> List (Html msg) -> Html msg
    , bar : Html msg
    , caption : Html msg
    }
    -> Html msg
progressInternal options =
    options.wrapper []
        [ options.bar
        , options.caption
        ]


basis : { disabled : Bool } -> List (Attribute msg) -> List (Html msg) -> Html msg
basis { disabled } =
    Html.styled Html.div
        [ -- .ui.progress
          position relative
        , displayFlex
        , maxWidth (pct 100)
        , property "border" "none"
        , margin3 (em 1) zero (em 2.5)
        , property "background" "rgba(0, 0, 0, 0.1)"
        , padding zero
        , borderRadius (rem 0.28571429)

        -- .ui.progress:first-child
        , firstChild
            [ margin3 zero zero (em 2.5) ]

        -- .ui.progress:last-child
        , lastChild
            [ margin3 zero zero (em 1.5) ]

        -- .ui.progress
        , fontSize (rem 1)

        -- Disabled
        , batch <|
            if disabled then
                [ opacity (num 0.35) ]

            else
                []
        ]


barBasis :
    { a
        | value : Float
        , indicating : Bool
        , state : State
    }
    -> List (Attribute msg)
    -> List (Html msg)
    -> Html msg
barBasis { value, indicating, state } =
    Html.styled Html.div
        [ -- .ui.progress .bar
          display block
        , lineHeight (num 1)
        , position relative
        , width (pct value)
        , minWidth (em 2)
        , borderRadius (rem 0.28571429)
        , property "-webkit-transition" "width 0.1s ease, background-color 0.1s ease"
        , property "transition" "width 0.1s ease, background-color 0.1s ease"
        , overflow hidden

        -- .ui.progress .bar
        , height (em 1.75)

        -- progress.js
        , property "transition-duration" "300ms"

        -- States
        , case ( state, value > 0, indicating ) of
            ( Success, True, _ ) ->
                -- .ui.ui.progress.success .bar
                backgroundColor (hex "#21BA45")

            ( Warning, True, _ ) ->
                -- .ui.ui.progress.warning .bar
                backgroundColor (hex "#F2C037")

            ( Error, True, _ ) ->
                -- .ui.ui.progress.error .bar
                backgroundColor (hex "#DB2828")

            ( _, _, True ) ->
                if 0 < value && value < 30 then
                    -- .ui.indicating.progress[data-percent^="1"] .bar
                    -- .ui.indicating.progress[data-percent^="2"] .bar
                    backgroundColor (hex "#D95C5C")

                else if 30 <= value && value < 40 then
                    -- .ui.indicating.progress[data-percent^="3"] .bar
                    backgroundColor (hex "#EFBC72")

                else if 40 <= value && value < 60 then
                    -- .ui.indicating.progress[data-percent^="4"] .bar
                    -- .ui.indicating.progress[data-percent^="5"] .bar
                    backgroundColor (hex "#E6BB48")

                else if 60 <= value && value < 70 then
                    -- .ui.indicating.progress[data-percent^="6"] .bar
                    backgroundColor (hex "#DDC928")

                else if 70 <= value && value < 90 then
                    -- .ui.indicating.progress[data-percent^="7"] .bar
                    -- .ui.indicating.progress[data-percent^="8"] .bar
                    backgroundColor (hex "#B4D95C")

                else if 90 <= value && value < 100 then
                    -- .ui.indicating.progress[data-percent^="9"] .bar
                    -- .ui.indicating.progress[data-percent^="100"] .bar
                    backgroundColor (hex "#66DA81")

                else if value == 100 then
                    backgroundColor (hex "#21BA45")

                else
                    property "background" "transparent"

            ( _, _, False ) ->
                if value == 0 then
                    -- .ui.ui.ui.progress:not([data-percent]):not(.indeterminate) .bar
                    -- .ui.ui.ui.progress[data-percent="0"]:not(.indeterminate) .bar
                    property "background" "transparent"

                else if value == 100 then
                    -- .ui.ui.progress.success .bar
                    backgroundColor (hex "#21BA45")

                else
                    property "background" "#888888"
        , batch <|
            case ( state, value < 100 ) of
                ( Active, True ) ->
                    let
                        progress_active =
                            keyframes
                                [ ( 0
                                  , [ Animations.property "opacity" "0.3"
                                    , Animations.property "-webkit-transform" "scale(0, 1)"
                                    , Animations.transform [ scale2 0 1 ]
                                    ]
                                  )
                                , ( 100
                                  , [ Animations.property "opacity" "0"
                                    , Animations.property "-webkit-transform" "scale(1)"
                                    , Animations.transform [ scale 1 ]
                                    ]
                                  )
                                ]
                    in
                    [ -- .ui.active.progress .bar
                      position relative
                    , minWidth (em 2)

                    -- .ui.active.progress .bar::after
                    , after
                        [ property "content" (qt "")
                        , opacity zero
                        , position absolute
                        , top zero
                        , left zero
                        , right zero
                        , bottom zero
                        , property "background" "#FFFFFF"
                        , borderRadius (rem 0.28571429)
                        , property "animation" "progress-active 2s ease infinite;"
                        , property "transform-origin" "left"
                        , animationName progress_active
                        ]
                    ]

                _ ->
                    -- .ui.ui.progress.success .bar
                    -- .ui.ui.progress.success .bar::after
                    -- .ui.ui.progress.warning .bar
                    -- .ui.ui.progress.warning .bar::after
                    -- .ui.ui.progress.error .bar
                    -- .ui.ui.progress.error .bar::after
                    -- .ui.ui.disabled.progress .bar
                    -- .ui.ui.disabled.progress .bar::after
                    []
        ]


bar : Model -> Html msg
bar options =
    let
        progress =
            String.fromFloat options.value ++ options.unit
    in
    barBasis options [] <|
        case progress of
            "" ->
                []

            _ ->
                let
                    progress_ =
                        Html.styled Html.div
                            [ -- .ui.progress .bar > .progress
                              whiteSpace noWrap
                            , position absolute
                            , width auto
                            , top (pct 50)
                            , right (em 0.5)
                            , left auto
                            , bottom auto
                            , fontSize (em 0.92857143)
                            , fontWeight bold
                            , color <|
                                if options.value == 0 then
                                    -- .ui.progress[data-percent="0"] .bar .progress
                                    rgba 0 0 0 0.87

                                else
                                    rgba 255 255 255 0.7
                            , textShadow none
                            , marginTop (em -0.5)
                            , textAlign left
                            ]
                in
                [ progress_ [] [ text progress ] ]


label : { a | value : Float, indicating : Bool, state : State } -> List (Attribute msg) -> List (Html msg) -> Html msg
label { value, indicating, state } =
    Html.styled Html.div
        [ -- .ui.progress > .label
          position absolute
        , width (pct 100)
        , top (pct 100)
        , right auto
        , left zero
        , bottom auto
        , fontSize (em 1)
        , fontWeight bold
        , textShadow none
        , marginTop (em 0.2)
        , textAlign center
        , property "-webkit-transition" "color 0.4s ease"
        , property "transition" "color 0.4s ease"

        -- States
        , case state of
            Success ->
                -- .ui.progress.success > .label
                color (hex "#1A531B")

            Warning ->
                -- .ui.progress.warning > .label
                color (hex "#794B02")

            Error ->
                -- .ui.progress.error > .label
                color (hex "#912D2B")

            _ ->
                if indicating && value == 100 then
                    -- .ui.ui.indicating.progress.success .label
                    color (hex "#1A531B")

                else
                    color (rgba 0 0 0 0.87)
        ]



-- HELPER


stateFromString : String -> Maybe State
stateFromString string =
    case string of
        "Default" ->
            Just Default

        "Active" ->
            Just Active

        "Success" ->
            Just Success

        "Warning" ->
            Just Warning

        "Error" ->
            Just Error

        "Disabled" ->
            Just Disabled

        _ ->
            Nothing


stateToString : State -> String
stateToString state =
    case state of
        Default ->
            "Default"

        Active ->
            "Active"

        Success ->
            "Success"

        Warning ->
            "Warning"

        Error ->
            "Error"

        Disabled ->
            "Disabled"
