module DesignToken.Palette exposing (dark, light)

import Css.Palette exposing (Palette)
import DesignToken.Color exposing (black, grey050, white)


light : Palette
light =
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
