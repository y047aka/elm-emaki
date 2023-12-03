module DesignToken.Color exposing
    ( white, black
    , grey020, grey050, grey060, grey070
    , red050, green050, blue050
    )

{-|

@docs white, black
@docs grey020, grey050, grey060, grey070
@docs red050, green050, blue050

-}

import Css exposing (Color, hsl)


white : Color
white =
    hsl 0 0 1


black : Color
black =
    hsl 0 0 0


grey020 : Color
grey020 =
    hsl 0 0 0.2


grey050 : Color
grey050 =
    hsl 0 0 0.5


grey060 : Color
grey060 =
    hsl 0 0 0.6


grey070 : Color
grey070 =
    hsl 0 0 0.7


red050 : Color
red050 =
    hsl 0 1 0.5


green050 : Color
green050 =
    hsl 120 1 0.5


blue050 : Color
blue050 =
    hsl 240 1 0.5
