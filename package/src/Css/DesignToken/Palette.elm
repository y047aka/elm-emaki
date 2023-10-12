module Css.DesignToken.Palette exposing (dark, default)

import Css.DesignToken.Color exposing (black, grey050, white)
import Css.Palette exposing (Palette)


default : Palette
default =
    { background = Just white
    , color = Just black
    , border = Just grey050
    }


dark : Palette
dark =
    { background = Just black
    , color = Just white
    , border = Just white
    }
