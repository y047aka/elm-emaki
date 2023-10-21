module DesignToken.Palette exposing
    ( light, dark
    , playground, propsPanel, propsField
    )

{-|

@docs light, dark
@docs playground, propsPanel, propsField

-}

import Css exposing (Color, hsla)
import Css.Palette exposing (Palette, init)
import DesignToken.Color exposing (black, grey050, white)


light : Palette
light =
    { background = Just white
    , color = Just black
    , border = Just grey050
    }


dark : Palette
dark =
    { background = Just black
    , color = Just white
    , border = Just white
    }



-- SPECIFIC


playground : Palette
playground =
    { light
        | background = light.background |> Maybe.map (setAlpha_fixme 0.4)
        , border = Just <| hsla 0 0 1 0.1
    }


propsPanel : Palette
propsPanel =
    { init | background = dark.background |> Maybe.map (setAlpha_fixme 0.05) }


propsField : Palette
propsField =
    { init | color = Just black }



-- HELPERS


setAlpha_fixme : Float -> Color -> Color
setAlpha_fixme alpha { red, green, blue } =
    Css.rgba (red * 255) (green * 255) (blue * 255) alpha
