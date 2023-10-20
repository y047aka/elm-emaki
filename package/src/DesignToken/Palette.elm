module DesignToken.Palette exposing
    ( light, dark
    , playground, propsPanel, propsField
    )

{-|

@docs light, dark
@docs playground, propsPanel, propsField

-}

import Css exposing (Color, hsla)
import Css.Palette exposing (Palette)
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
        | background = light.background |> Maybe.map (setAlpha_fixme 0.35)
        , border = Just <| hsla 0 0 1 0.1
    }


propsPanel : Palette
propsPanel =
    { dark
        | background = dark.background |> Maybe.map (setAlpha_fixme 0.05)
        , border = Nothing
    }


propsField : Palette
propsField =
    { light
        | background = light.background |> Maybe.map (setAlpha_fixme 0.25)
        , border = Just <| hsla 0 0 1 0.1
    }



-- HELPERS


setAlpha_fixme : Float -> Color -> Color
setAlpha_fixme alpha { red, green, blue } =
    Css.rgba (red * 255) (green * 255) (blue * 255) alpha
