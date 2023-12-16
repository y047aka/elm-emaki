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
import DesignToken.Color exposing (black, grey020, grey030, grey060, grey070, grey080, white)


light : Palette
light =
    { background = Just (white |> setAlpha_fixme 0.8)
    , color = Just grey020
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


navigation : Palette
navigation =
    { dark | background = dark.background |> Maybe.map (setAlpha_fixme 0.9) }


navItem : ( Palette, List ( List Style -> Style, Palette ) )
navItem =
    let
        default =
            init |> setColor grey080
    in
    ( default
    , [ ( hover, default |> setBackground grey030 |> setColor white ) ]
    )


navItemSelected : Palette
navItemSelected =
    Tuple.first navItem
        |> setBackground grey020
        |> setColor white



-- PLAYGROUND


playground : Palette
playground =
    { light
        | background = light.background |> Maybe.map (setAlpha_fixme 0.8)
        , border = Just <| hsla 0 0 1 0.1
    }


propsPanel : Palette
propsPanel =
    { init | background = dark.background |> Maybe.map (setAlpha_fixme 0.05) }


propsField : Palette
propsField =
    light


formField : Palette
formField =
    { light | background = Just (hsla 0 0 0 0) }



-- HELPERS


setAlpha_fixme : Float -> Color -> Color
setAlpha_fixme alpha { red, green, blue } =
    Css.rgba (red * 255) (green * 255) (blue * 255) alpha
