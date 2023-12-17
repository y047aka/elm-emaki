module Emaki exposing
    ( staticView
    , controlledView
    , bind
    , ControlsMsg
    , BindedControl
    )

{-|


# Emaki


## Static

@docs staticView


## Controlled

@docs controlledView
@docs bind
@docs ControlsMsg
@docs BindedControl

-}

import Browser
import Css exposing (..)
import Css.Extra exposing (columnGap, rowGap)
import Css.Global exposing (children, everything)
import Css.Palette as Palette
import DesignToken.Palette exposing (playground, propsPanel)
import Emaki.Controls exposing (Control)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)


{-| simple (not controlled, static) view.

    main =
        staticView (text "simple view")

-}
staticView : Html msg -> Program () () msg
staticView html =
    Browser.sandbox
        { init = ()
        , view = always (toUnstyled html)
        , update = \_ m -> m
        }


{-| -}
type ControlsMsg params
    = ParamChanged params


{-| -}
type alias BindedControl model msg =
    model -> Html msg


{-| -}
bind :
    { from : model -> input
    , to : output -> msg
    }
    -> Control input output
    -> BindedControl model (ControlsMsg msg)
bind { from, to } control =
    Html.Styled.map (ParamChanged << to) << control << from


{-| show view with param controlled by `Control`
-}
controlledView :
    { view : params -> Html (ControlsMsg params)
    , defaultParams : params
    , controls : List (BindedControl params (ControlsMsg params))
    }
    -> Program () params (ControlsMsg params)
controlledView { defaultParams, view, controls } =
    Browser.sandbox
        { init = defaultParams
        , view =
            \model ->
                layout
                    { view = view model
                    , controls = List.map ((|>) model) controls
                    }
                    |> Html.Styled.toUnstyled
        , update = \(ParamChanged params) _ -> params
        }


layout :
    { view : Html msg
    , controls : List (Html msg)
    }
    -> Html msg
layout { view, controls } =
    section
        [ css
            [ padding4 (Css.em 0.5) (Css.em 0.5) (Css.em 0.5) (Css.em 1.5)
            , borderRadius (Css.em 1.5)
            , display Css.Extra.grid
            , property "grid-template-columns" "1fr 25em"
            , columnGap (Css.em 1.5)
            , fontSize (px 14)
            , Palette.paletteWithBorder (border3 (px 1) solid) playground
            , property "-webkit-backdrop-filter" "blur(300px)"
            , property "backdrop-filter" "blur(300px)"
            , property "box-shadow" "0 5px 20px hsl(0, 0%, 0%, 0.05)"
            ]
        ]
        [ div [ css [ displayFlex, flexDirection column, justifyContent center ] ]
            [ view ]
        , div
            [ css
                [ padding (Css.em 0.5)
                , displayFlex
                , flexDirection column
                , rowGap (Css.em 0.5)
                , borderRadius (Css.em 1)
                , Palette.palette propsPanel
                , children
                    [ everything
                        [ padding (Css.em 0.75)
                        , displayFlex
                        , flexDirection column
                        , rowGap (Css.em 0.5)
                        , borderRadius (Css.em 0.5)
                        , Palette.palette propsPanel
                        ]
                    ]
                ]
            ]
            controls
        ]
