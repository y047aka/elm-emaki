module DesignToken.Palette exposing (dark, default)

import Css.Palette exposing (Palette)
import DesignToken.Color exposing (black, grey050, white)


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
