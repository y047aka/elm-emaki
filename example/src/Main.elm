module Main exposing (main)

import Browser
import Css exposing (..)
import Css.Extra exposing (..)
import Css.Global exposing (Snippet, children, everything)
import Css.Palette exposing (palette, paletteWithBorder)
import Css.TextBlock as TextBlock exposing (OverflowWrap(..), TextBlock, WordBreak(..), textBlock)
import Css.Typography as Typography exposing (TextAlign(..), Typography, WebkitFontSmoothing(..), typography)
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
    { progressModel : Progress.Model
    , typographyModel : TypographyModel
    }


type alias TypographyModel =
    { webkitFontSmoothing : WebkitFontSmoothing
    , typography : Typography
    , textBlock : TextBlock
    , fontSize : Float
    , textAlign : TextAlign
    , lineHeight : Float
    , letterSpacing : Float
    }


init : () -> ( Model, Cmd Msg )
init () =
    let
        ( progressModel, progressCmd ) =
            Progress.init
    in
    ( { progressModel = progressModel
      , typographyModel = init_TypographyModel
      }
    , Cmd.map ProgressMsg progressCmd
    )


init_TypographyModel : TypographyModel
init_TypographyModel =
    { webkitFontSmoothing = Auto
    , typography =
        Typography.init
            |> Typography.setFontFamilies [ "sans-serif" ]
            |> Typography.setFontSize (px 16)
            |> Typography.setFontWeight Css.normal
            |> Typography.setLineHeight (num 1.5)
            |> Typography.setTextDecoration Css.none
            |> Typography.setTextTransform Css.none
    , textBlock =
        TextBlock.init
            |> TextBlock.setWordBreak Normal_WordBreak
            |> TextBlock.setOverflowWrap Normal_OverflowWrap
    , fontSize = 16
    , textAlign = Left
    , lineHeight = 1.5
    , letterSpacing = 0
    }



-- UPDATE


type Msg
    = UpdateProgress (Progress.Model -> Progress.Model)
    | UpdateTypography (TypographyModel -> TypographyModel)
    | ProgressMsg Progress.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateProgress updater ->
            ( { model | progressModel = updater model.progressModel }, Cmd.none )

        UpdateTypography updater ->
            ( { model | typographyModel = updater model.typographyModel }, Cmd.none )

        ProgressMsg progressMsg ->
            let
                ( progressModel, progressCmd ) =
                    Progress.update progressMsg model.progressModel
            in
            ( { model | progressModel = progressModel }, Cmd.map ProgressMsg progressCmd )



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
            , progressPlayground model.progressModel
            , h2 [] [ text "Typography" ]
            , typographyPlayground model.typographyModel
            ]
        ]


progressPlayground : Progress.Model -> Html Msg
progressPlayground pm =
    playground
        { preview = Progress.progressWithProps pm
        , props =
            [ Props.FieldSet "Bar"
                [ Props.field
                    { label = ""
                    , props =
                        Props.counter
                            { value = pm.value
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
                            , value = pm.indicating
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
                                    |> UpdateProgress
                            }
                    , note = "An indicating progress bar visually indicates the current level of progress of a task"
                    }
                ]
            , Props.FieldSet "States"
                [ Props.field
                    { label = ""
                    , props =
                        Props.select
                            { value = Progress.stateToString pm.state
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
                                    >> UpdateProgress
                            }
                    , note =
                        case pm.state of
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
                            { value = pm.unit
                            , onInput = (\string ps -> { ps | unit = string }) >> UpdateProgress
                            , placeholder = ""
                            }
                    , note = "A progress bar can contain a text value indicating current progress"
                    }
                , Props.field
                    { label = "Caption"
                    , props =
                        Props.string
                            { value = pm.caption
                            , onInput = (\string ps -> { ps | caption = string }) >> UpdateProgress
                            , placeholder = ""
                            }
                    , note = "A progress element can contain a label"
                    }
                ]
            ]
        }


typographyPlayground : TypographyModel -> Html Msg
typographyPlayground tm =
    playground
        { preview =
            div
                [ css
                    [ displayFlex
                    , flexDirection column
                    , rowGap (Css.em 1)
                    , typography tm.typography
                    , textBlock tm.textBlock
                    , children
                        [ everything
                            [ Typography.webkitFontSmoothing tm.webkitFontSmoothing ]
                        ]
                    ]
                ]
                [ p [] [ text """We the Peoples of the United Nations Determined
to save succeeding generations from the scourge of war, which twice in our lifetime has brought untold sorrow to mankind, and
to reaffirm faith in fundamental human rights, in the dignity and worth of the human person, in the equal rights of men and women and of nations large and small, and to establish conditions under which justice and respect for the obligations arising from treaties and other sources of international law can be maintained, and to promote social progress and better standards of life in larger freedom, And for these Ends
to practice tolerance and live together in peace with one another as good neighbors, and to unite our strength to maintain international peace and security, and
to ensure by the acceptance of principles and the institution of methods, that armed force shall not be used, save in the common interest, and
to employ international machinery for the promotion of the economic and social advancement of all peoples,
Have Resolved to Combine our Efforts to Accomplish these Aims""" ]
                , p [] [ text "Accordingly, our respective Governments, through representatives assembled in the city of San Francisco, who have exhibited their full powers found to be in good and due form, have agreed to the present Charter of the United Nations and do hereby establish an international organization to be known as the United Nations." ]
                , p [] [ text "われら連合国の人民は、われらの一生のうち二度まで言語に絶する悲哀を人類に与えた戦争の惨害から将来の世代を救い、基本的人権と人間の尊厳及び価値と男女及び大小各国の同権とに関する信念を改めて確認し、正義と条約その他の国際法の源泉から生ずる義務の尊重とを維持することができる条件を確立し、一層大きな自由の中で社会的進歩と生活水準の向上とを促進すること、並びに、このために、寛容を実行し、且つ、善良な隣人として互に平和に生活し、国際の平和および安全を維持するためにわれらの力を合わせ、共同の利益の場合を除く外は武力を用いないことを原則の受諾と方法の設定によって確保し、すべての人民の経済的及び社会的発達を促進するために国際機構を用いることを決意して、これらの目的を達成するために、われらの努力を結集することに決定した。" ]
                , p [] [ text "よって、われらの各自の政府は、サンフランシスコ市に会合し、全権委任状を示してそれが良好妥当であると認められた代表者を通じて、この国際連合憲章に同意したので、ここに国際連合という国際機構を設ける。" ]
                ]
        , props =
            [ Props.field
                { label = "-webkit-font-smoothing"
                , props =
                    Props.radio
                        { value = tm.webkitFontSmoothing |> Typography.webkitFontSmoothingToString
                        , options = [ "auto", "none", "antialiased", "subpixel-antialiased" ]
                        , onChange =
                            (\webkitFontSmoothing m ->
                                { m
                                    | webkitFontSmoothing =
                                        case webkitFontSmoothing of
                                            "auto" ->
                                                Auto

                                            "none" ->
                                                None

                                            "antialiased" ->
                                                Antialiased

                                            "subpixel-antialiased" ->
                                                SubpixelAntialiased

                                            _ ->
                                                m.webkitFontSmoothing
                                }
                            )
                                >> UpdateTypography
                        }
                , note = ""
                }
            , Props.FieldSet "Typography"
                [ Props.field
                    { label = "font-family"
                    , props =
                        Props.select
                            { value = tm.typography.fontFamilies |> String.concat
                            , options = [ Css.sansSerif.value, Css.serif.value ]
                            , onChange =
                                (\fontFamily m ->
                                    { m
                                        | typography =
                                            case fontFamily of
                                                "sans-serif" ->
                                                    m.typography |> Typography.setFontFamilies [ "sans-serif" ]

                                                "serif" ->
                                                    m.typography |> Typography.setFontFamilies [ "serif" ]

                                                _ ->
                                                    m.typography
                                    }
                                )
                                    >> UpdateTypography
                            }
                    , note = ""
                    }
                , Props.field
                    { label = "font-size"
                    , props =
                        Props.counter
                            { value = tm.fontSize
                            , toString = \value -> String.fromFloat value ++ "px"
                            , onClickPlus =
                                UpdateTypography
                                    (\m ->
                                        { m
                                            | fontSize = m.fontSize + 1
                                            , typography = m.typography |> Typography.setFontSize (px (m.fontSize + 1))
                                        }
                                    )
                            , onClickMinus =
                                UpdateTypography
                                    (\m ->
                                        { m
                                            | fontSize = m.fontSize - 1
                                            , typography = m.typography |> Typography.setFontSize (px (m.fontSize - 1))
                                        }
                                    )
                            }
                    , note = ""
                    }
                , Props.field
                    { label = "font-style"
                    , props =
                        Props.radio
                            { value = tm.typography.fontStyle |> Maybe.map .value |> Maybe.withDefault "-"
                            , options = [ Css.normal.value, Css.italic.value ]
                            , onChange =
                                (\style m ->
                                    { m
                                        | typography =
                                            case style of
                                                "normal" ->
                                                    m.typography |> Typography.setFontStyle Css.normal

                                                "italic" ->
                                                    m.typography |> Typography.setFontStyle Css.italic

                                                _ ->
                                                    m.typography
                                    }
                                )
                                    >> UpdateTypography
                            }
                    , note = ""
                    }
                , Props.field
                    { label = "font-weight"
                    , props =
                        Props.radio
                            { value = tm.typography.fontWeight |> Maybe.map .value |> Maybe.withDefault "-"
                            , options = [ Css.lighter.value, Css.normal.value, Css.bold.value, Css.bolder.value ]
                            , onChange =
                                (\weight m ->
                                    { m
                                        | typography =
                                            case weight of
                                                "lighter" ->
                                                    m.typography |> Typography.setFontWeight Css.lighter

                                                "normal" ->
                                                    m.typography |> Typography.setFontWeight Css.normal

                                                "bold" ->
                                                    m.typography |> Typography.setFontWeight Css.bold

                                                "bolder" ->
                                                    m.typography |> Typography.setFontWeight Css.bolder

                                                _ ->
                                                    m.typography
                                    }
                                )
                                    >> UpdateTypography
                            }
                    , note = ""
                    }
                , Props.field
                    { label = "text-align"
                    , props =
                        Props.radio
                            { value = tm.textAlign |> Typography.textAlignToString
                            , options = [ "left", "center", "right", "justify" ]
                            , onChange =
                                (\align m ->
                                    { m
                                        | textAlign =
                                            case align of
                                                "left" ->
                                                    Left

                                                "center" ->
                                                    Center

                                                "right" ->
                                                    Right

                                                "justify" ->
                                                    Justify

                                                _ ->
                                                    m.textAlign
                                        , typography =
                                            case align of
                                                "left" ->
                                                    m.typography |> Typography.setTextAlign Css.left

                                                "center" ->
                                                    m.typography |> Typography.setTextAlign Css.center

                                                "right" ->
                                                    m.typography |> Typography.setTextAlign Css.right

                                                "justify" ->
                                                    m.typography |> Typography.setTextAlign Css.justify

                                                _ ->
                                                    m.typography
                                    }
                                )
                                    >> UpdateTypography
                            }
                    , note = ""
                    }
                , Props.field
                    { label = "line-height"
                    , props =
                        Props.counter
                            { value = tm.lineHeight
                            , toString = \value -> String.fromFloat value
                            , onClickPlus =
                                UpdateTypography
                                    (\m ->
                                        { m
                                            | lineHeight = ((m.lineHeight * 10) + 1) / 10
                                            , typography = m.typography |> Typography.setLineHeight (num (((m.lineHeight * 10) + 1) / 10))
                                        }
                                    )
                            , onClickMinus =
                                UpdateTypography
                                    (\m ->
                                        { m
                                            | lineHeight = ((m.lineHeight * 10) - 1) / 10
                                            , typography = m.typography |> Typography.setLineHeight (num (((m.lineHeight * 10) - 1) / 10))
                                        }
                                    )
                            }
                    , note = ""
                    }
                , Props.field
                    { label = "text-decoration"
                    , props =
                        Props.radio
                            { value = tm.typography.textDecoration |> Maybe.map .value |> Maybe.withDefault "-"
                            , options = [ Css.none.value, Css.underline.value ]
                            , onChange =
                                (\decoration m ->
                                    { m
                                        | typography =
                                            case decoration of
                                                "none" ->
                                                    m.typography |> Typography.setTextDecoration Css.none

                                                "underline" ->
                                                    m.typography |> Typography.setTextDecoration Css.underline

                                                _ ->
                                                    m.typography
                                    }
                                )
                                    >> UpdateTypography
                            }
                    , note = ""
                    }
                , Props.field
                    { label = "letter-spacing"
                    , props =
                        Props.counter
                            { value = tm.letterSpacing
                            , toString = \value -> String.fromFloat value ++ "em"
                            , onClickPlus =
                                UpdateTypography
                                    (\m ->
                                        { m
                                            | letterSpacing = ((m.letterSpacing * 100) + 1) / 100
                                            , typography = m.typography |> Typography.setLetterSpacing (Css.em (((m.letterSpacing * 100) + 1) / 100))
                                        }
                                    )
                            , onClickMinus =
                                UpdateTypography
                                    (\m ->
                                        { m
                                            | letterSpacing = ((m.letterSpacing * 100) - 1) / 100
                                            , typography = m.typography |> Typography.setLetterSpacing (Css.em (((m.letterSpacing * 100) - 1) / 100))
                                        }
                                    )
                            }
                    , note = ""
                    }
                , Props.field
                    { label = "text-transform"
                    , props =
                        Props.radio
                            { value = tm.typography.textTransform |> Maybe.map .value |> Maybe.withDefault "-"
                            , options = [ Css.none.value, Css.uppercase.value, Css.lowercase.value, Css.capitalize.value ]
                            , onChange =
                                (\transform m ->
                                    { m
                                        | typography =
                                            case transform of
                                                "none" ->
                                                    m.typography |> Typography.setTextTransform Css.none

                                                "uppercase" ->
                                                    m.typography |> Typography.setTextTransform Css.uppercase

                                                "lowercase" ->
                                                    m.typography |> Typography.setTextTransform Css.lowercase

                                                "capitalize" ->
                                                    m.typography |> Typography.setTextTransform Css.capitalize

                                                _ ->
                                                    m.typography
                                    }
                                )
                                    >> UpdateTypography
                            }
                    , note = ""
                    }
                ]
            , Props.FieldSet "TextBlock"
                [ Props.field
                    { label = "word-break"
                    , props =
                        Props.radio
                            { value = tm.textBlock.wordBreak |> Maybe.map TextBlock.wordBreakToString |> Maybe.withDefault "-"
                            , options = [ "normal", "break-all", "keep-all", "auto-phrase" ]
                            , onChange =
                                (\wordBreak m ->
                                    { m
                                        | textBlock =
                                            case wordBreak of
                                                "normal" ->
                                                    m.textBlock |> TextBlock.setWordBreak Normal_WordBreak

                                                "break-all" ->
                                                    m.textBlock |> TextBlock.setWordBreak BreakAll

                                                "keep-all" ->
                                                    m.textBlock |> TextBlock.setWordBreak KeepAll

                                                "auto-phrase" ->
                                                    m.textBlock |> TextBlock.setWordBreak AutoPhrase

                                                _ ->
                                                    m.textBlock
                                    }
                                )
                                    >> UpdateTypography
                            }
                    , note = ""
                    }
                , Props.field
                    { label = "overflow-wrap"
                    , props =
                        Props.radio
                            { value = tm.textBlock.overflowWrap |> Maybe.map TextBlock.overflowWrapToString |> Maybe.withDefault "-"
                            , options = [ "normal", "break-word", "anywhere" ]
                            , onChange =
                                (\overflowWrap m ->
                                    { m
                                        | textBlock =
                                            case overflowWrap of
                                                "normal" ->
                                                    m.textBlock |> TextBlock.setOverflowWrap Normal_OverflowWrap

                                                "break-word" ->
                                                    m.textBlock |> TextBlock.setOverflowWrap BreakWord

                                                "anywhere" ->
                                                    m.textBlock |> TextBlock.setOverflowWrap Anywhere

                                                _ ->
                                                    m.textBlock
                                    }
                                )
                                    >> UpdateTypography
                            }
                    , note = ""
                    }
                ]
            ]
        }


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
