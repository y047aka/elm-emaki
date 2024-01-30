module DesignToken.Color exposing
    ( white, black
    , grey020, grey030, grey050, grey060, grey070, grey085, grey090, grey095
    , red050, green050, blue050
    )

{-|

@docs white, black
@docs grey020, grey030, grey050, grey060, grey070, grey085, grey090, grey095
@docs red050, green050, blue050

-}

import Css.Color exposing (Hsl360, hsl)


white : Hsl360
white =
    hsl 0 0 1


black : Hsl360
black =
    hsl 0 0 0


grey020 : Hsl360
grey020 =
    hsl 0 0 0.2


grey030 : Hsl360
grey030 =
    hsl 0 0 0.3


grey050 : Hsl360
grey050 =
    hsl 0 0 0.5


grey060 : Hsl360
grey060 =
    hsl 0 0 0.6


grey070 : Hsl360
grey070 =
    hsl 0 0 0.7


grey085 : Hsl360
grey085 =
    hsl 0 0 0.85


grey090 : Hsl360
grey090 =
    hsl 0 0 0.9


grey095 : Hsl360
grey095 =
    hsl 0 0 0.95


red050 : Hsl360
red050 =
    hsl 0 1 0.5


green050 : Hsl360
green050 =
    hsl 120 1 0.5


blue050 : Hsl360
blue050 =
    hsl 240 1 0.5
