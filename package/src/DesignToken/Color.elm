module DesignToken.Color exposing
    ( white, black, grey050
    , red050, green050, blue050
    )

{-|

@docs white, black, grey050
@docs red050, green050, blue050

-}

import Css exposing (Color, hsl)


white : Color
white =
    hsl 0 0 1


black : Color
black =
    hsl 0 0 0


grey050 : Color
grey050 =
    hsl 0 0 0.5


red050 : Color
red050 =
    hsl 0 1 0.5


green050 : Color
green050 =
    hsl 120 1 0.5


blue050 : Color
blue050 =
    hsl 240 1 0.5
