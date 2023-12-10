module Main exposing (main)

import Browser
import Css exposing (..)
import Css.Extra exposing (..)
import Css.Global exposing (Snippet, children, everything)
import Css.Palette exposing (palette, paletteWithBorder)
import DesignToken.Palette as Palette
import Emaki.Props as Props exposing (Props)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Progress exposing (State(..))


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    Progress.Model


init : () -> ( Model, Cmd Msg )
init () =
    Progress.init
        |> Tuple.mapSecond (Cmd.map ProgressMsg)



-- UPDATE


type Msg
    = UpdateConfig (Model -> Model)
    | ProgressMsg Progress.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateConfig updater ->
            ( updater model, Cmd.none )

        ProgressMsg progressMsg ->
            Progress.update progressMsg model
                |> Tuple.mapSecond (Cmd.map ProgressMsg)



-- VIEW


view : Model -> Html Msg
view model =
    main_
        [ css
            [ padding (Css.em 1)
            , before
                [ property "content" "''"
                , position absolute
                , property "inset" "0"
                , zIndex (int -2)
                , property "background" """
radial-gradient(at 80% 90%, hsl(200, 100%, 90%), hsl(200, 100%, 90%) 40%, transparent 40%),
radial-gradient(at 70% -5%, hsl(300, 100%, 90%), hsl(300, 100%, 90%) 30%, transparent 40%),
radial-gradient(at 5% 0%, hsl(200, 100%, 80%), hsl(200, 100%, 80%) 50%, transparent 50%)"""
                ]
            , after
                [ property "content" "''"
                , position absolute
                , property "inset" "0"
                , zIndex (int -1)
                , property "-webkit-backdrop-filter" "blur(100px) contrast(1.2)"
                , property "backdrop-filter" "blur(100px) contrast(1.2)"
                ]
            ]
        ]
        [ resetCSS
        , article
            [ css
                [ displayFlex
                , flexDirection column
                , rowGap (Css.em 0.5)
                ]
            ]
            [ h2 [ css [ fontSize (px 20) ] ] [ text "Progress" ]
            , playground
                { preview = Progress.progressWithProps model
                , props =
                    [ Props.FieldSet "Bar"
                        [ Props.field
                            { label = ""
                            , props =
                                Props.counter
                                    { value = model.value
                                    , toString = \value -> String.fromFloat value ++ "%"
                                    , onClickPlus = ProgressMsg Progress.CounterPlus
                                    , onClickMinus = ProgressMsg Progress.CounterMinus
                                    }
                            , note = "A progress element can contain a bar visually indicating progress"
                            }
                        ]
                    , Props.FieldSet "Types"
                        [ Props.field
                            { label = ""
                            , props =
                                Props.bool
                                    { label = "Indicating"
                                    , value = model.indicating
                                    , onClick =
                                        (\c ->
                                            let
                                                newIndicating =
                                                    not c.indicating
                                            in
                                            { c
                                                | indicating = newIndicating
                                                , caption =
                                                    if newIndicating then
                                                        c.caption

                                                    else
                                                        "Uploading Files"
                                            }
                                                |> Progress.updateCaptionOnIndicating
                                        )
                                            |> UpdateConfig
                                    }
                            , note = "An indicating progress bar visually indicates the current level of progress of a task"
                            }
                        ]
                    , Props.FieldSet "States"
                        [ Props.field
                            { label = ""
                            , props =
                                Props.select
                                    { value = Progress.stateToString model.state
                                    , options = List.map Progress.stateToString [ Default, Active, Success, Warning, Error, Disabled ]
                                    , onChange =
                                        (\prevState ps ->
                                            Progress.stateFromString prevState
                                                |> Maybe.map
                                                    (\state ->
                                                        { ps
                                                            | state = state
                                                            , caption =
                                                                case state of
                                                                    Success ->
                                                                        "Everything worked, your file is all ready."

                                                                    Warning ->
                                                                        "Your file didn't meet the minimum resolution requirements."

                                                                    Error ->
                                                                        "There was an error."

                                                                    _ ->
                                                                        ps.caption
                                                        }
                                                    )
                                                |> Maybe.withDefault ps
                                        )
                                            >> UpdateConfig
                                    }
                            , note =
                                case model.state of
                                    Active ->
                                        "A progress bar can show activity"

                                    Success ->
                                        "A progress bar can show a success state"

                                    Warning ->
                                        "A progress bar can show a warning state"

                                    Error ->
                                        "A progress bar can show an error state"

                                    Disabled ->
                                        "A progress bar can be disabled"

                                    _ ->
                                        ""
                            }
                        ]
                    , Props.FieldSet "Content"
                        [ Props.field
                            { label = "Unit"
                            , props =
                                Props.string
                                    { value = model.unit
                                    , onInput = (\string ps -> { ps | unit = string }) >> UpdateConfig
                                    , placeholder = ""
                                    }
                            , note = "A progress bar can contain a text value indicating current progress"
                            }
                        , Props.field
                            { label = "Caption"
                            , props =
                                Props.string
                                    { value = model.caption
                                    , onInput = (\string ps -> { ps | caption = string }) >> UpdateConfig
                                    , placeholder = ""
                                    }
                            , note = "A progress element can contain a label"
                            }
                        ]
                    ]
                }
            ]
        ]


playground :
    { preview : Html msg
    , props : List (Props msg)
    }
    -> Html msg
playground { preview, props } =
    section
        [ css
            [ padding4 (Css.em 0.5) (Css.em 0.5) (Css.em 0.5) (Css.em 1.5)
            , borderRadius (Css.em 1.5)
            , display grid
            , property "grid-template-columns" "1fr 25em"
            , columnGap (Css.em 1.5)
            , fontSize (px 14)
            , paletteWithBorder (border3 (px 1) solid) Palette.playground
            , property "-webkit-backdrop-filter" "blur(300px)"
            , property "backdrop-filter" "blur(300px)"
            , property "box-shadow" "0 5px 20px hsl(0, 0%, 0%, 0.05)"
            ]
        ]
        [ div [ css [ displayFlex, flexDirection column, justifyContent center ] ]
            [ preview ]
        , div
            [ css
                [ padding (Css.em 0.5)
                , displayFlex
                , flexDirection column
                , rowGap (Css.em 0.5)
                , borderRadius (Css.em 1)
                , palette Palette.propsPanel
                , children
                    [ everything
                        [ padding (Css.em 0.75)
                        , displayFlex
                        , flexDirection column
                        , rowGap (Css.em 0.5)
                        , borderRadius (Css.em 0.5)
                        , palette Palette.propsField
                        ]
                    ]
                ]
            ]
            (List.map Props.render props)
        ]



-- RESET CSS


resetCSS : Html msg
resetCSS =
    let
        where_ : String -> List Style -> Snippet
        where_ selector_ styles =
            Css.Global.selector (":where(" ++ selector_ ++ ")") styles
    in
    Css.Global.global
        [ Css.Global.selector "*, ::before, ::after"
            [ boxSizing borderBox
            , property "-webkit-font-smoothing" "antialiased"
            ]
        , Css.Global.everything
            [ margin zero ]
        , where_ ":root"
            [ fontFamily sansSerif ]
        ]
