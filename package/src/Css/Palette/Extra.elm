module Css.Palette.Extra exposing (PalettesByState, initPalettes, light_dark, palettesByState)

import Css exposing (ColorValue, Style)
import Css.Palette as Palette exposing (Palette, palette)


type alias PalettesByState color =
    { default : Maybe (Palette color)
    , selected : Maybe ( Bool, Palette color )
    , link : Maybe (Palette color)
    , visited : Maybe (Palette color)
    , hover : Maybe (Palette color)
    , focus : Maybe (Palette color)
    , active : Maybe (Palette color)
    }


palettesByState : PalettesByState (ColorValue c) -> Style
palettesByState ps =
    [ case ps.selected of
        Just ( True, selected ) ->
            Just (palette selected)

        _ ->
            Maybe.map palette ps.default

    -- https://meyerweb.com/eric/css/link-specificity.html
    , Maybe.map (\p -> Css.link [ palette p ]) ps.link
    , Maybe.map (\p -> Css.visited [ palette p ]) ps.visited
    , Maybe.map (\p -> Css.hover [ palette p ]) ps.hover
    , Maybe.map (\p -> Css.focus [ palette p ]) ps.focus
    , Maybe.map (\p -> Css.active [ palette p ]) ps.active
    ]
        |> List.filterMap identity
        |> Css.batch


initPalettes : PalettesByState (ColorValue c)
initPalettes =
    { default = Just Palette.init
    , selected = Nothing
    , link = Just Palette.init
    , visited = Just Palette.init
    , hover = Just Palette.init
    , focus = Just Palette.init
    , active = Just Palette.init
    }


light_dark : Bool -> { light : palette, dark : palette } -> palette
light_dark isDarkMode { light, dark } =
    if isDarkMode then
        dark

    else
        light
