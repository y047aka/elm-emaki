module Emaki.Chapter exposing (Chapter, Model, Msg, chapter)

import Array
import Emaki.Chapter.Control exposing (Control)
import Emaki.Chapter.Control.Internal as ControlInternal
import Emaki.Chapter.Internal as ChapterInternal
import Html exposing (Html)
import Html.Styled as Styled
import Json.Decode as JD
import Json.Encode as JE


type alias Chapter props =
    ChapterInternal.Chapter props


type alias Model props =
    ChapterInternal.Model props


type alias Msg =
    ChapterInternal.Msg


chapter :
    { init : props
    , view : props -> Html Msg
    , controls : List (Control props)
    }
    -> Chapter props
chapter { init, view, controls } =
    let
        controlInits =
            List.map (\(ControlInternal.Control r) -> r.init) controls

        controlViews =
            List.map (\(ControlInternal.Control r) -> r.view) controls

        controlOnChanges =
            List.map (\(ControlInternal.Control r) -> r.updateProps) controls
                |> Array.fromList

        chapterView : Model props -> Styled.Html Msg
        chapterView { viewState, controlsState } =
            Styled.div []
                [ Styled.fromUnstyled (view viewState)
                , controlsState
                    |> JD.decodeValue (JD.list JD.value)
                    |> Result.withDefault controlInits
                    |> List.map2 (<|) controlViews
                    |> List.map (Styled.li [] << List.singleton)
                    |> List.indexedMap (\i listItem -> Styled.map (ChapterInternal.UpdateControlAt i) listItem)
                    |> Styled.ul []
                ]

        update (ChapterInternal.UpdateControlAt idx newValue) { viewState, controlsState } =
            { viewState = Maybe.withDefault (always identity) (Array.get idx controlOnChanges) newValue viewState
            , controlsState =
                controlsState
                    |> JD.decodeValue (JD.array JD.value)
                    |> Result.map (Array.set idx newValue >> JE.array identity)
                    |> Result.withDefault controlsState
            }
    in
    { init = ChapterInternal.Model init (JE.list identity controlInits)
    , view = chapterView
    , update = update
    }
