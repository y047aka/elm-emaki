module Css.Palette exposing
    ( Palette, init
    , palette, paletteWith
    , setBackground, setColor, setBorder
    )

{-|

@docs Palette, init
@docs palette, paletteWith
@docs setBackground, setColor, setBorder

-}

import Css exposing (Color, Style, backgroundColor, batch, borderColor, color)


type alias Palette =
    { background : Maybe Color
    , color : Maybe Color
    , border : Maybe Color
    }


init : Palette
init =
    { background = Nothing
    , color = Nothing
    , border = Nothing
    }


palette : Palette -> Style
palette =
    paletteWith borderColor


paletteWith : (Color -> Style) -> Palette -> Style
paletteWith border p =
    [ Maybe.map backgroundColor p.background
    , Maybe.map color p.color
    , Maybe.map border p.border
    ]
        |> List.filterMap identity
        |> batch


setBackground : Color -> Palette -> Palette
setBackground c p =
    { p | background = Just c }


setColor : Color -> Palette -> Palette
setColor c p =
    { p | color = Just c }


setBorder : Color -> Palette -> Palette
setBorder c p =
    { p | border = Just c }
