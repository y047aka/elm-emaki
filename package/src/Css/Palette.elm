module Css.Palette exposing
    ( Palette, init
    , palette, paletteWith
    , paletteWithBackgroundImage
    , setBackground, setColor, setBorder
    )

{-|

@docs Palette, init
@docs palette, paletteWith
@docs paletteWithBackgroundImage
@docs setBackground, setColor, setBorder

-}

import Css exposing (..)


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
paletteWith fn p =
    [ Maybe.map backgroundColor p.background
    , Maybe.map color p.color
    , Maybe.map fn p.border
    ]
        |> List.filterMap identity
        |> batch


paletteWithBackgroundImage : BackgroundImage compatible -> Palette -> Style
paletteWithBackgroundImage bgImage p =
    [ Just (backgroundImage bgImage)
    , Maybe.map color p.color
    , Maybe.map borderColor p.border
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
