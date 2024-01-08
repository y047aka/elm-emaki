module DesignToken.Palette exposing
    ( light, dark
    , textOptional
    , navigation, navItem, navItemSelected
    , playground, propsPanel, propsField, formField
    )

{-|

@docs light, dark
@docs textOptional

@docs navigation, navItem, navItemSelected
@docs playground, propsPanel, propsField, formField

-}

import Css exposing (Color, Style, hover, hsla)
import Css.Palette exposing (Palette, init, setBackground, setColor)
import DesignToken.Color exposing (black, grey020, grey030, grey060, grey070, grey090, grey095, white)


light : Palette
light =
    { background = Just (white |> setAlpha_fixme 0.8)
    , color = Just grey030
    , border = Just grey070
    }


dark : Palette
dark =
    { background = Just black
    , color = Just white
    , border = Just white
    }


textOptional : Palette
textOptional =
    { background = Nothing
    , color = Just grey060
    , border = Nothing
    }



-- NAVIGATION


navigation : Bool -> Palette
navigation darkMode =
    if darkMode then
        { background = dark.background |> Maybe.map (setAlpha_fixme 0.9)
        , color = Just grey090
        , border = Nothing
        }

    else
        { background = light.background |> Maybe.map (setAlpha_fixme 0.9)
        , color = Just grey030
        , border = Nothing
        }


navItem : Bool -> ( Palette, List ( List Style -> Style, Palette ) )
navItem darkMode =
    if darkMode then
        ( init |> setColor grey090
        , [ ( hover, init |> setBackground grey030 |> setColor white ) ]
        )

    else
        ( init |> setColor grey030
        , [ ( hover, init |> setBackground grey090 |> setColor grey030 ) ]
        )


navItemSelected : Bool -> Palette
navItemSelected darkMode =
    if darkMode then
        Tuple.first (navItem darkMode)
            |> setBackground grey020
            |> setColor white

    else
        Tuple.first (navItem darkMode)
            |> setBackground grey095
            |> setColor grey020



-- PLAYGROUND


playground : Bool -> Palette
playground darkMode =
    if darkMode then
        { dark
            | background = dark.background |> Maybe.map (setAlpha_fixme 0.8)
            , border = Nothing
        }

    else
        { light
            | background = light.background |> Maybe.map (setAlpha_fixme 0.8)
            , border = Just <| hsla 0 0 1 0.1
        }


propsPanel : Bool -> Palette
propsPanel darkMode =
    if darkMode then
        { init | background = light.background |> Maybe.map (setAlpha_fixme 0.05) }

    else
        { init | background = dark.background |> Maybe.map (setAlpha_fixme 0.05) }


propsField : Bool -> Palette
propsField darkMode =
    if darkMode then
        dark

    else
        light


formField : Palette
formField =
    { light | background = Just (hsla 0 0 0 0) }



-- HELPERS


setAlpha_fixme : Float -> Color -> Color
setAlpha_fixme alpha { red, green, blue } =
    Css.rgba (red * 255) (green * 255) (blue * 255) alpha
