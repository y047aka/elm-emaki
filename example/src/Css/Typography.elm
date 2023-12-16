module Css.Typography exposing
    ( Typography, init
    , typography
    , TextAlign(..), textAlignToString
    , setFontFamilies, setFontSize, setFontStyle, setFontWeight
    , setTextAlign, setLineHeight, setLetterSpacing
    , setTextDecoration, setTextTransform
    , setWordBreak, setOverflowWrap
    , WebkitFontSmoothing(..), webkitFontSmoothingToString, webkitFontSmoothing
    , WordBreak(..), wordBreakToString
    , OverflowWrap(..), overflowWrapToString
    )

{-|

@docs Typography, init
@docs typography
@docs TextAlign, textAlignToString

@docs setFontFamilies, setFontSize, setFontStyle, setFontWeight
@docs setTextAlign, setLineHeight, setLetterSpacing
@docs setTextDecoration, setTextTransform
@docs setWordBreak, setOverflowWrap

@docs WebkitFontSmoothing, webkitFontSmoothingToString, webkitFontSmoothing
@docs WordBreak, wordBreakToString
@docs OverflowWrap, overflowWrapToString

-}

import Css exposing (Compatible, ExplicitLength, FontSize, FontStyle, FontWeight, IncompatibleUnits, Length, Style, TextDecorationLine, TextTransform, property)


{-| -}
type alias Typography =
    { font : Font
    , geometry : Geometry
    , textSetting : TextSetting
    , textBlock : TextBlock
    }


type alias Font =
    { families : List String
    , weight : Maybe (FontWeight {})
    , style : Maybe (FontStyle {})
    , size : Maybe (FontSize {})
    }


type alias Geometry =
    { lineHeight : Maybe (LineHeight {})
    , letterSpacing : Maybe (Length {} {})
    , textAlign : Maybe (ExplicitLength IncompatibleUnits -> Style)
    }


type alias TextSetting =
    { textDecoration : Maybe (TextDecorationLine {})
    , textTransform : Maybe (TextTransform {})
    }


type alias TextBlock =
    { wordBreak : Maybe WordBreak
    , overflowWrap : Maybe OverflowWrap
    }


type TextAlign
    = Left
    | Right
    | Center
    | Justify


type alias LineHeight compatible =
    { compatible | value : String, lineHeight : Compatible }


type WordBreak
    = Normal_WordBreak
    | BreakAll
    | KeepAll
    | AutoPhrase


type OverflowWrap
    = Normal_OverflowWrap
    | BreakWord
    | Anywhere


{-| -}
init : Typography
init =
    { font =
        { families = []
        , weight = Nothing
        , style = Nothing
        , size = Nothing
        }
    , geometry =
        { lineHeight = Nothing
        , letterSpacing = Nothing
        , textAlign = Nothing
        }
    , textSetting =
        { textDecoration = Nothing
        , textTransform = Nothing
        }
    , textBlock =
        { wordBreak = Nothing
        , overflowWrap = Nothing
        }
    }


{-| -}
typography : Typography -> Style
typography t =
    [ font_ t.font
    , geometry_ t.geometry
    , textSetting_ t.textSetting
    , textBlock_ t.textBlock
    ]
        |> Css.batch


font_ : Font -> Style
font_ f =
    [ case f.families of
        [] ->
            Nothing

        _ ->
            Just (Css.fontFamilies f.families)
    , Maybe.map Css.fontWeight f.weight
    , Maybe.map Css.fontStyle f.style
    , Maybe.map Css.fontSize f.size
    ]
        |> List.filterMap identity
        |> Css.batch


geometry_ : Geometry -> Style
geometry_ g =
    [ Maybe.map Css.lineHeight g.lineHeight
    , Maybe.map Css.letterSpacing g.letterSpacing
    , Maybe.map Css.textAlign g.textAlign
    ]
        |> List.filterMap identity
        |> Css.batch


textSetting_ : TextSetting -> Style
textSetting_ ts =
    [ Maybe.map Css.textDecoration ts.textDecoration
    , Maybe.map Css.textTransform ts.textTransform
    ]
        |> List.filterMap identity
        |> Css.batch


textBlock_ : TextBlock -> Style
textBlock_ t =
    [ Maybe.map (wordBreakToString >> property "word-break") t.wordBreak
    , Maybe.map (overflowWrapToString >> property "overflow-wrap") t.overflowWrap
    ]
        |> List.filterMap identity
        |> Css.batch



-- SETTER


setFont : Font -> Typography -> Typography
setFont f t =
    { t | font = f }


{-| -}
setFontFamilies : List String -> Typography -> Typography
setFontFamilies families ({ font } as t) =
    t |> setFont { font | families = families }


{-| -}
setFontSize : FontSize a -> Typography -> Typography
setFontSize { value, fontSize } ({ font } as t) =
    t |> setFont { font | size = Just { value = value, fontSize = fontSize } }


{-| -}
setFontStyle : FontStyle a -> Typography -> Typography
setFontStyle { value, fontStyle } ({ font } as t) =
    t |> setFont { font | style = Just { value = value, fontStyle = fontStyle } }


{-| -}
setFontWeight : FontWeight a -> Typography -> Typography
setFontWeight { value, fontWeight } ({ font } as t) =
    t |> setFont { font | weight = Just { value = value, fontWeight = fontWeight } }


setGeometry : Geometry -> Typography -> Typography
setGeometry g t =
    { t | geometry = g }


{-| -}
setLineHeight : LineHeight compatible -> Typography -> Typography
setLineHeight { value, lineHeight } ({ geometry } as t) =
    t |> setGeometry { geometry | lineHeight = Just { value = value, lineHeight = lineHeight } }


{-| -}
setLetterSpacing : Length compatible unit -> Typography -> Typography
setLetterSpacing { value, length, numericValue, unitLabel } ({ geometry } as t) =
    t |> setGeometry { geometry | letterSpacing = Just { value = value, length = length, numericValue = numericValue, units = {}, unitLabel = unitLabel } }


{-| -}
setTextAlign : (ExplicitLength IncompatibleUnits -> Style) -> Typography -> Typography
setTextAlign textAlign ({ geometry } as t) =
    t |> setGeometry { geometry | textAlign = Just textAlign }


setTextSetting : TextSetting -> Typography -> Typography
setTextSetting ts t =
    { t | textSetting = ts }


{-| -}
setTextDecoration : TextDecorationLine a -> Typography -> Typography
setTextDecoration { value, textDecorationLine } ({ textSetting } as t) =
    t |> setTextSetting { textSetting | textDecoration = Just { value = value, textDecorationLine = textDecorationLine } }


{-| -}
setTextTransform : TextTransform compatible -> Typography -> Typography
setTextTransform { value, textTransform } ({ textSetting } as t) =
    t |> setTextSetting { textSetting | textTransform = Just { value = value, textTransform = textTransform } }


setTextBlock : TextBlock -> Typography -> Typography
setTextBlock tb t =
    { t | textBlock = tb }


{-| -}
setWordBreak : WordBreak -> Typography -> Typography
setWordBreak wordBreak ({ textBlock } as t) =
    t |> setTextBlock { textBlock | wordBreak = Just wordBreak }


{-| -}
setOverflowWrap : OverflowWrap -> Typography -> Typography
setOverflowWrap wrap ({ textBlock } as t) =
    t |> setTextBlock { textBlock | overflowWrap = Just wrap }



-- TEXT ALIGN


textAlignToString : TextAlign -> String
textAlignToString textAlign =
    case textAlign of
        Left ->
            "left"

        Right ->
            "right"

        Center ->
            "center"

        Justify ->
            "justify"



-- FONT SMOOTHING


type WebkitFontSmoothing
    = Auto
    | None
    | Antialiased
    | SubpixelAntialiased


webkitFontSmoothingToString : WebkitFontSmoothing -> String
webkitFontSmoothingToString fm =
    case fm of
        Auto ->
            "auto"

        None ->
            "none"

        Antialiased ->
            "antialiased"

        SubpixelAntialiased ->
            "subpixel-antialiased"


webkitFontSmoothing : WebkitFontSmoothing -> Style
webkitFontSmoothing fs =
    Css.property "-webkit-font-smoothing" (webkitFontSmoothingToString fs)



-- WORD BREAK


wordBreakToString : WordBreak -> String
wordBreakToString wordBreak =
    case wordBreak of
        Normal_WordBreak ->
            "normal"

        BreakAll ->
            "break-all"

        KeepAll ->
            "keep-all"

        AutoPhrase ->
            "auto-phrase"



-- OVERFLOW WRAP


overflowWrapToString : OverflowWrap -> String
overflowWrapToString wrap =
    case wrap of
        Normal_OverflowWrap ->
            "normal"

        BreakWord ->
            "break-word"

        Anywhere ->
            "anywhere"
