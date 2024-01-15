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
import Css.Palette.Extra exposing (light_dark)
import DesignToken.Color exposing (black, grey020, grey030, grey060, grey070, grey085, grey090, grey095, white)


light : Palette
light =
    { background = Just white
    , color = Just grey030
    , border = Just grey070
    }


dark : Palette
dark =
    { background = Just black
    , color = Just grey095
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
navigation isDarkMode =
    light_dark isDarkMode
        { light =
            { background = light.background |> Maybe.map (setAlpha_fixme 0.95)
            , color = Just grey030
            , border = Nothing
            }
        , dark =
            { background = dark.background |> Maybe.map (setAlpha_fixme 0.7)
            , color = Just grey095
            , border = Nothing
            }
        }


navItem : Bool -> ( Palette, List ( List Style -> Style, Palette ) )
navItem isDarkMode =
    light_dark isDarkMode
        { light =
            ( init |> setColor grey030
            , [ ( hover, init |> setBackground grey085 |> setColor grey030 ) ]
            )
        , dark =
            ( init |> setColor grey095
            , [ ( hover, init |> setBackground grey030 |> setColor white ) ]
            )
        }


navItemSelected : Bool -> Palette
navItemSelected isDarkMode =
    light_dark isDarkMode
        { light =
            Tuple.first (navItem isDarkMode)
                |> setBackground grey090
                |> setColor grey030
        , dark =
            Tuple.first (navItem isDarkMode)
                |> setBackground grey020
                |> setColor white
        }



-- PLAYGROUND


playground : Bool -> Palette
playground isDarkMode =
    light_dark isDarkMode
        { light =
            { light
                | background = light.background |> Maybe.map (setAlpha_fixme 0.95)
                , border = Nothing
            }
        , dark =
            { dark
                | background = dark.background |> Maybe.map (setAlpha_fixme 0.7)
                , border = Nothing
            }
        }


propsPanel : Bool -> Palette
propsPanel isDarkMode =
    light_dark isDarkMode
        { light = { init | background = dark.background |> Maybe.map (setAlpha_fixme 0.1) }
        , dark = { init | background = light.background |> Maybe.map (setAlpha_fixme 0.1) }
        }


propsField : Bool -> Palette
propsField isDarkMode =
    light_dark isDarkMode
        { light = { init | background = light.background |> Maybe.map (setAlpha_fixme 0.7) }
        , dark = { init | background = light.background |> Maybe.map (setAlpha_fixme 0.1) }
        }


formField : Palette
formField =
    { light | background = Just (hsla 0 0 0 0) }



-- HELPERS


setAlpha_fixme : Float -> Color -> Color
setAlpha_fixme alpha { red, green, blue } =
    Css.rgba (red * 255) (green * 255) (blue * 255) alpha
