module DesignToken.Palette exposing
    ( light, dark
    , playground, propsPanel, propsField
    )

{-|

@docs light, dark
@docs playground, propsPanel, propsField

-}

import Css exposing (Color)
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
        | background = light.background |> Maybe.map (setAlpha_fixme 0.8)
        , border = Nothing
    }


propsPanel : Palette
propsPanel =
    { dark
        | background = dark.background |> Maybe.map (setAlpha_fixme 0.1)
        , border = Nothing
    }


propsField : Palette
propsField =
    { light
        | background = light.background |> Maybe.map (setAlpha_fixme 0.7)
        , border = Nothing
    }



-- HELPERS


setAlpha_fixme : Float -> Color -> Color
setAlpha_fixme alpha { red, green, blue } =
    Css.rgba (red * 255) (green * 255) (blue * 255) alpha
