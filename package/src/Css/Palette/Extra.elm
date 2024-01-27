module Css.Palette.Extra exposing (light_dark, paletteByState)

import Css exposing (ColorValue, Style)
import Css.Palette exposing (Palette, palette)


paletteByState : ( Palette (ColorValue c), List ( List Style -> Style, Palette (ColorValue c) ) ) -> Style
paletteByState ( default, palettes ) =
    List.map (\( pseudoClass, p ) -> pseudoClass [ palette p ]) palettes
        |> (::) (palette default)
        |> Css.batch


light_dark : Bool -> { light : palette, dark : palette } -> palette
light_dark isDarkMode { light, dark } =
    if isDarkMode then
        dark

    else
        light
