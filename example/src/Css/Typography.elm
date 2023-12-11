module Css.Typography exposing
    ( Typography, init
    , typography
    , TextAlign(..), textAlignToString
    , WebkitFontSmoothing(..), webkitFontSmoothingToString, webkitFontSmoothing
    , setFontFamilies, setFontSize, setFontStyle, setFontWeight, setTextAlign, setLineHeight, setLetterSpacing, setTextDecoration, setTextTransform
    )

{-|

@docs Typography, init
@docs typography
@docs TextAlign, textAlignToString
@docs WebkitFontSmoothing, webkitFontSmoothingToString, webkitFontSmoothing
@docs setFontFamilies, setFontSize, setFontStyle, setFontWeight, setTextAlign, setLineHeight, setLetterSpacing, setTextDecoration, setTextTransform

-}

import Css exposing (Compatible, ExplicitLength, FontSize, FontStyle, FontWeight, IncompatibleUnits, Length, Style, TextDecorationLine, TextTransform)


{-| -}
type alias Typography =
    { fontFamilies : List String
    , fontSize : Maybe (FontSize {})
    , fontStyle : Maybe (FontStyle {})
    , fontWeight : Maybe (FontWeight {})
    , textAlign : Maybe (ExplicitLength IncompatibleUnits -> Style)
    , lineHeight : Maybe (LineHeight {})
    , letterSpacing : Maybe (Length {} {})
    , textDecoration : Maybe (TextDecorationLine {})
    , textTransform : Maybe (TextTransform {})
    }


type TextAlign
    = Left
    | Right
    | Center
    | Justify


type alias LineHeight compatible =
    { compatible | value : String, lineHeight : Compatible }


{-| -}
init : Typography
init =
    { fontFamilies = []
    , fontSize = Nothing
    , fontStyle = Nothing
    , fontWeight = Nothing
    , textAlign = Nothing
    , lineHeight = Nothing
    , letterSpacing = Nothing
    , textDecoration = Nothing
    , textTransform = Nothing
    }


{-| -}
typography : Typography -> Style
typography t =
    [ case t.fontFamilies of
        [] ->
            Nothing

        _ ->
            Just (Css.fontFamilies t.fontFamilies)
    , Maybe.map Css.fontSize t.fontSize
    , Maybe.map Css.fontStyle t.fontStyle
    , Maybe.map Css.fontWeight t.fontWeight
    , Maybe.map Css.textAlign t.textAlign
    , Maybe.map Css.lineHeight t.lineHeight
    , Maybe.map Css.letterSpacing t.letterSpacing
    , Maybe.map Css.textDecoration t.textDecoration
    , Maybe.map Css.textTransform t.textTransform
    ]
        |> List.filterMap identity
        |> Css.batch



-- SETTER


{-| -}
setFontFamilies : List String -> Typography -> Typography
setFontFamilies families t =
    { t | fontFamilies = families }


{-| -}
setFontSize : FontSize a -> Typography -> Typography
setFontSize { value, fontSize } t =
    { t | fontSize = Just { value = value, fontSize = fontSize } }


{-| -}
setFontStyle : FontStyle a -> Typography -> Typography
setFontStyle { value, fontStyle } t =
    { t | fontStyle = Just { value = value, fontStyle = fontStyle } }


{-| -}
setFontWeight : FontWeight a -> Typography -> Typography
setFontWeight { value, fontWeight } t =
    { t | fontWeight = Just { value = value, fontWeight = fontWeight } }


{-| -}
setTextAlign : (ExplicitLength IncompatibleUnits -> Style) -> Typography -> Typography
setTextAlign textAlign t =
    { t | textAlign = Just textAlign }


{-| -}
setLineHeight : LineHeight compatible -> Typography -> Typography
setLineHeight { value, lineHeight } t =
    { t | lineHeight = Just { value = value, lineHeight = lineHeight } }


{-| -}
setLetterSpacing : Length compatible unit -> Typography -> Typography
setLetterSpacing { value, length, numericValue, unitLabel } t =
    { t | letterSpacing = Just { value = value, length = length, numericValue = numericValue, units = {}, unitLabel = unitLabel } }


{-| -}
setTextDecoration : TextDecorationLine a -> Typography -> Typography
setTextDecoration { value, textDecorationLine } t =
    { t | textDecoration = Just { value = value, textDecorationLine = textDecorationLine } }


{-| -}
setTextTransform : TextTransform compatible -> Typography -> Typography
setTextTransform { value, textTransform } t =
    { t | textTransform = Just { value = value, textTransform = textTransform } }



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
