module Emaki exposing
    ( Emaki
    , Painting
    , run
    , staticPainting
    , paintingList
    )

{-|

@docs Emaki
@docs Painting
@docs run
@docs staticPainting
@docs paintingList

-}

import Browser
import Html exposing (Html, div, h1, text)
import Emaki.Props exposing (Props)


{-| -}
type Emaki html
    = PaintingList (List (Painting html))


{-| -}
run : (html -> Html ()) -> Emaki html -> Program () () ()
run toHtml (PaintingList staticPaintings) =
    let
        runPainting (StaticPainting html) =
            toHtml html
    in
    Browser.sandbox
        { init = ()
        , update = \_ model -> model
        , view =
            \_ ->
                div []
                    [ h1 [] [ text "Emaki" ]
                    , div [] (staticPaintings |> List.map runPainting)
                    ]
        }


{-| -}
paintingList : List (Painting html) -> Emaki html
paintingList =
    PaintingList


{-| -}
type Painting html
    = StaticPainting html


staticPainting : html -> Painting html
staticPainting =
    StaticPainting


-- TODO: impl `dynamicPainting : Emaki.Props -> ???`
