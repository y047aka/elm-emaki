module DesignToken.Palette exposing
    ( light, dark
    , textOptional
    , playground, propsPanel, propsField, formField
    )

{-|

@docs light, dark
@docs textOptional
@docs playground, propsPanel, propsField, formField

-}

import Css exposing (Color, hsla)
import Css.Palette exposing (Palette, init)
import DesignToken.Color exposing (black, grey020, grey060, grey070, white)


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



-- SPECIFIC


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
