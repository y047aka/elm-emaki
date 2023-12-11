module Css.TextBlock exposing
    ( TextBlock, init
    , textBlock
    , WordBreak(..), wordBreakToString
    , OverflowWrap(..), overflowWrapToString
    , setWordBreak, setOverflowWrap
    )

{-|

@docs TextBlock, init
@docs textBlock
@docs WordBreak, wordBreakToString
@docs OverflowWrap, overflowWrapToString
@docs setWordBreak, setOverflowWrap

-}

import Css exposing (Style, property)


{-| -}
type alias TextBlock =
    { wordBreak : Maybe WordBreak
    , overflowWrap : Maybe OverflowWrap
    }


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
init : TextBlock
init =
    { wordBreak = Nothing
    , overflowWrap = Nothing
    }


{-| -}
textBlock : TextBlock -> Style
textBlock t =
    [ Maybe.map (wordBreakToString >> property "word-break") t.wordBreak
    , Maybe.map (overflowWrapToString >> property "overflow-wrap") t.overflowWrap
    ]
        |> List.filterMap identity
        |> Css.batch



-- SETTER


{-| -}
setWordBreak : WordBreak -> TextBlock -> TextBlock
setWordBreak wordBreak tb =
    { tb | wordBreak = Just wordBreak }


{-| -}
setOverflowWrap : OverflowWrap -> TextBlock -> TextBlock
setOverflowWrap wrap tb =
    { tb | overflowWrap = Just wrap }



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
