module Css.Color exposing
    ( Rgb255, rgba, rgb
    , Hsl360, hsla, hsl
    , Oklab, oklab
    )

{-|

@docs Rgb255, rgba, rgb
@docs Hsl360, hsla, hsl
@docs Oklab, oklab

-}

import Css exposing (ColorValue, Compatible)



-- COMPATIBLE


compatible_ : Compatible
compatible_ =
    Css.initial.all



-- RGB


type alias Rgb255 =
    ColorValue { red : Float, green : Float, blue : Float, alpha : Maybe Float }


rgba : Float -> Float -> Float -> Float -> Rgb255
rgba r g b alpha =
    { value =
        cssColorLevel4 "rgb"
            ( [ String.fromFloat (roundTo r)
              , String.fromFloat (roundTo g)
              , String.fromFloat (roundTo b)
              ]
            , (roundTo >> String.fromFloat >> Just) alpha
            )
    , color = compatible_
    , red = r
    , green = g
    , blue = b
    , alpha = Just alpha
    }


rgb : Float -> Float -> Float -> Rgb255
rgb r g b =
    { value =
        cssColorLevel4 "rgb"
            ( [ String.fromFloat (roundTo r)
              , String.fromFloat (roundTo g)
              , String.fromFloat (roundTo b)
              ]
            , Nothing
            )
    , color = compatible_
    , red = r
    , green = g
    , blue = b
    , alpha = Nothing
    }



-- HSL


type alias Hsl360 =
    ColorValue { hue : Float, saturation : Float, lightness : Float, alpha : Maybe Float }


hsla : Float -> Float -> Float -> Float -> Hsl360
hsla h s l alpha =
    { value =
        cssColorLevel4 "hsl"
            ( [ String.fromFloat (roundTo h)
              , String.fromFloat (pct s) ++ "%"
              , String.fromFloat (pct l) ++ "%"
              ]
            , (roundTo >> String.fromFloat >> Just) alpha
            )
    , color = compatible_
    , hue = h
    , saturation = s
    , lightness = l
    , alpha = Just alpha
    }


hsl : Float -> Float -> Float -> Hsl360
hsl h s l =
    { value =
        cssColorLevel4 "hsl"
            ( [ String.fromFloat (roundTo h)
              , String.fromFloat (pct s) ++ "%"
              , String.fromFloat (pct l) ++ "%"
              ]
            , Nothing
            )
    , color = compatible_
    , hue = h
    , saturation = s
    , lightness = l
    , alpha = Nothing
    }



-- OKLAB


type alias Oklab =
    ColorValue { lightness : Float, a : Float, b : Float, alpha : Maybe Float }


oklab : Float -> Float -> Float -> Float -> Oklab
oklab l a b alpha =
    { value =
        cssColorLevel4 "oklab"
            ( [ String.fromFloat (pct l) ++ "%"
              , String.fromFloat (roundTo a)
              , String.fromFloat (roundTo b)
              ]
            , Just ((roundTo >> String.fromFloat) alpha)
            )
    , color = compatible_
    , lightness = l
    , a = a
    , b = b
    , alpha = Just alpha
    }



-- HELPERS


pct : Float -> Float
pct x =
    ((x * 10000) |> round |> toFloat) / 100


roundTo : Float -> Float
roundTo x =
    ((x * 1000) |> round |> toFloat) / 1000


cssColorLevel4 : String -> ( List String, Maybe String ) -> String
cssColorLevel4 funcName ( args, maybeAlpha ) =
    let
        slashAndAplha =
            case maybeAlpha of
                Just a ->
                    [ "/", a ]

                Nothing ->
                    []
    in
    funcName
        ++ "("
        ++ String.join " " (args ++ slashAndAplha)
        ++ ")"
