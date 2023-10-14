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


translucentLight : Float -> Palette
translucentLight alpha =
    { light
        | background = light.background |> Maybe.map (setAlpha_fixme alpha)
        , border = Nothing
    }


dark : Palette
dark =
    { background = Just black
    , color = Just white
    , border = Just white
    }


translucentDark : Float -> Palette
translucentDark alpha =
    { dark
        | background = dark.background |> Maybe.map (setAlpha_fixme alpha)
        , border = Nothing
    }



-- SPECIFIC


playground : Palette
playground =
    translucentLight 0.8


propsPanel : Palette
propsPanel =
    translucentDark 0.1


propsField : Palette
propsField =
    translucentLight 0.7



-- HELPERS


setAlpha_fixme : Float -> Color -> Color
setAlpha_fixme alpha { red, green, blue } =
    Css.rgba (red * 255) (green * 255) (blue * 255) alpha
