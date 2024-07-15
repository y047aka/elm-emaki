module DesignToken.Palette exposing
    ( light, dark
    , textOptional
    , navigation, navItem, navItemSelected
    , playground, controlPanel, controlSection, formField
    )

{-|

@docs light, dark
@docs textOptional

@docs navigation, navItem, navItemSelected
@docs playground, controlPanel, controlSection, formField

-}

import Css exposing (Color, rgba)
import Css.Color exposing (Hsl360, hsla)
import Css.Palette exposing (Palette, init, setBackground, setColor)
import Css.Palette.Extra exposing (PalettesByState, initPalettes, light_dark)
import DesignToken.Color exposing (black, grey020, grey030, grey060, grey070, grey085, grey090, grey095, white)


light : Palette Hsl360
light =
    { background = Just white
    , color = Just grey030
    , border = Just grey070
    }


dark : Palette Hsl360
dark =
    { background = Just black
    , color = Just grey095
    , border = Just white
    }


textOptional : Palette Hsl360
textOptional =
    { background = Nothing
    , color = Just grey060
    , border = Nothing
    }



-- NAVIGATION


navigation : Bool -> Palette Hsl360
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


navItem : { isDarkMode : Bool, isSelected : Bool } -> PalettesByState Hsl360
navItem { isDarkMode, isSelected } =
    light_dark isDarkMode
        { light =
            let
                default =
                    init |> setColor grey030
            in
            { initPalettes
                | default = default
                , selected = Just ( isSelected, default |> setBackground grey090 )
                , hover = Just (default |> setBackground grey085)
            }
        , dark =
            let
                default =
                    init |> setColor white
            in
            { initPalettes
                | default = default
                , selected = Just ( isSelected, default |> setBackground grey020 )
                , hover = Just (default |> setBackground grey030)
            }
        }



-- PLAYGROUND


playground : Bool -> Palette Hsl360
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


controlPanel : Bool -> Palette Hsl360
controlPanel isDarkMode =
    light_dark isDarkMode
        { light = { init | background = dark.background |> Maybe.map (setAlpha_fixme 0.1) }
        , dark = { init | background = light.background |> Maybe.map (setAlpha_fixme 0.1) }
        }


controlSection : Bool -> Palette Hsl360
controlSection isDarkMode =
    light_dark isDarkMode
        { light = { init | background = light.background |> Maybe.map (setAlpha_fixme 0.7) }
        , dark = { init | background = light.background |> Maybe.map (setAlpha_fixme 0.1) }
        }


formField : Palette Color
formField =
    { background = Just (rgba 0 0 0 0)
    , color = Just (rgba 0 0 0 0.87)
    , border = Just (rgba 34 36 38 0.15)
    }



-- HELPERS


setAlpha_fixme : Float -> Hsl360 -> Hsl360
setAlpha_fixme alpha { hue, saturation, lightness } =
    hsla hue saturation lightness alpha
