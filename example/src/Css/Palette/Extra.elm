module Css.Palette.Extra exposing (..)

import Css exposing (Style)
import Css.Palette exposing (Palette, palette)


paletteByState : ( Palette, List ( List Style -> Style, Palette ) ) -> Style
paletteByState ( default, palettes ) =
    List.map (\( pseudoClass, p ) -> pseudoClass [ palette p ]) palettes
        |> (::) (palette default)
        |> Css.batch
