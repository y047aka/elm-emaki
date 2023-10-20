module Css.Extra exposing
    ( fr
    , gap, gap2, rowGap, columnGap
    , placeItemsCenter, placeContentCenter, placeSelfCenter
    , grid, gridTemplateColumns, gridTemplateRows, gridAutoColumns, gridAutoRows, gridColumn, gridRow
    )

{-|

@docs fr
@docs gap, gap2, rowGap, columnGap
@docs placeItemsCenter, placeContentCenter, placeSelfCenter
@docs grid, gridTemplateColumns, gridTemplateRows, gridAutoColumns, gridAutoRows, gridColumn, gridRow

-}

import Css exposing (Compatible, Display, ExplicitLength, Length, Style, Value, property)



-- COMPATIBLE


dummyCompatible : Compatible
dummyCompatible =
    Css.initial.all



-- LENGTHS


type alias Fr =
    ExplicitLength FrUnits


fr : Float -> Fr
fr =
    lengthConverter_ FrUnits "fr"


type FrUnits
    = FrUnits


lengthConverter_ : units -> String -> Float -> ExplicitLength units
lengthConverter_ units unitLabel numericValue =
    { value = String.fromFloat numericValue ++ unitLabel
    , numericValue = numericValue
    , units = units
    , unitLabel = unitLabel
    , length = dummyCompatible
    , lengthOrAuto = dummyCompatible
    , lengthOrNumber = dummyCompatible
    , lengthOrNone = dummyCompatible
    , lengthOrMinMaxDimension = dummyCompatible
    , lengthOrNoneOrMinMaxDimension = dummyCompatible
    , textIndent = dummyCompatible
    , flexBasis = dummyCompatible
    , lengthOrNumberOrAutoOrNoneOrContent = dummyCompatible
    , fontSize = dummyCompatible
    , absoluteLength = dummyCompatible
    , lengthOrAutoOrCoverOrContain = dummyCompatible
    , lineHeight = dummyCompatible
    , calc = dummyCompatible
    }



-- PROPERTIES


prop1 : String -> Value a -> Style
prop1 key arg =
    property key arg.value


prop2 : String -> Value a -> Value b -> Style
prop2 key argA argB =
    property key (argA.value ++ " " ++ argB.value)


gap : Length compatible units -> Style
gap =
    prop1 "gap"


gap2 : Length compatible units -> Length compatible units -> Style
gap2 =
    prop2 "gap"


rowGap : Length compatible units -> Style
rowGap =
    prop1 "row-gap"


columnGap : Length compatible units -> Style
columnGap =
    prop1 "column-gap"


placeItemsCenter : Style
placeItemsCenter =
    property "place-items" "center"


placeContentCenter : Style
placeContentCenter =
    property "place-content" "center"


placeSelfCenter : Style
placeSelfCenter =
    property "place-self" "center"



-- GRID LAYOUT


grid : Display {}
grid =
    { value = "grid", display = dummyCompatible }


gridTemplateColumns : List (Length compatible units) -> Style
gridTemplateColumns units =
    property "grid-template-columns" (String.join " " <| List.map .value units)


gridTemplateRows : List (Length compatible units) -> Style
gridTemplateRows units =
    property "grid-template-rows" (String.join " " <| List.map .value units)


gridAutoColumns : Length compatible units -> Style
gridAutoColumns =
    prop1 "grid-auto-columns"


gridAutoRows : Length compatible units -> Style
gridAutoRows =
    prop1 "grid-auto-rows"


gridColumn : String -> Style
gridColumn =
    property "grid-column"


gridRow : String -> Style
gridRow =
    property "grid-row"
