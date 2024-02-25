module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Navigation exposing (Key)
import Css exposing (..)
import Css.Extra exposing (..)
import Css.Global exposing (Snippet, children, everything)
import Css.Palette exposing (palette, paletteWithBorder, setColor)
import Css.Palette.Extra exposing (paletteByState)
import Css.Typography as Typography exposing (OverflowWrap(..), TextAlign(..), Typography, WebkitFontSmoothing(..), WordBreak(..), typography)
import DesignToken.Color exposing (grey095)
import DesignToken.Palette as Palette
import Emaki.Control as Control exposing (Control)
import Html.Styled as Html exposing (Html, a, div, h2, header, input, li, main_, nav, p, section, text, toUnstyled, ul)
import Html.Styled.Attributes as Attributes exposing (css, href, id, type_)
import Html.Styled.Events exposing (onClick)
import Progress exposing (State(..))
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }



-- MODEL


type alias Model =
    { url : Url
    , key : Key
    , isDarkMode : Bool
    , progressModel : Progress.Model
    , typographyModel : TypographyModel
    }


init : () -> Url -> Key -> ( Model, Cmd Msg )
init () url key =
    let
        ( progressModel, progressCmd ) =
            Progress.init
    in
    ( { url = url
      , key = key
      , isDarkMode = False
      , progressModel = progressModel
      , typographyModel = init_TypographyModel
      }
    , Cmd.map ProgressMsg progressCmd
    )



-- UPDATE


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url
    | ToggleDarkMode
    | UpdateProgress (Progress.Model -> Progress.Model)
    | UpdateTypography (TypographyModel -> TypographyModel)
    | ProgressMsg Progress.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    -- 現時点ではfragmentによる遷移のみを想定している
                    ( model, Navigation.load (Url.toString url) )

                Browser.External url ->
                    ( model, Navigation.load url )

        UrlChanged url ->
            ( { model | url = url }, Cmd.none )

        ToggleDarkMode ->
            ( { model | isDarkMode = not model.isDarkMode }, Cmd.none )

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


view : Model -> Document Msg
view m =
    { title = "elm-emaki"
    , body =
        List.map toUnstyled <|
            emakiView m
                [ { id = "progress"
                  , heading = "Progress"
                  , sectionContents = [ progressPlayground m.isDarkMode m.progressModel ]
                  }
                , { id = "typography"
                  , heading = "Typography"
                  , sectionContents = [ typographyPlayground m.isDarkMode m.typographyModel ]
                  }
                ]
    }


progressPlayground : Bool -> Progress.Model -> Html Msg
progressPlayground isDarkMode pm =
    playground
        { isDarkMode = isDarkMode
        , preview = Progress.progressWithProps pm
        , controlSections =
            [ { heading = ""
              , controls =
                    [ Field "Bar"
                        (Control.counter
                            { value = pm.value
                            , toString = \value -> String.fromFloat value ++ "%"
                            , onClickPlus = ProgressMsg Progress.CounterPlus
                            , onClickMinus = ProgressMsg Progress.CounterMinus
                            }
                        )
                    , Comment "A progress element can contain a bar visually indicating progress"
                    ]
              }
            , { heading = "Config"
              , controls =
                    [ Field "Indicating"
                        (Control.bool
                            { id = "indicating"
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
                        )
                    , Comment "An indicating progress bar visually indicates the current level of progress of a task"
                    , Field "States"
                        (Control.select
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
                        )
                    , Comment
                        (case pm.state of
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
                        )
                    ]
              }
            , { heading = "Content"
              , controls =
                    [ Field "Unit"
                        (Control.string
                            { value = pm.unit
                            , onInput = (\string ps -> { ps | unit = string }) >> UpdateProgress
                            , placeholder = ""
                            }
                        )
                    , Comment "A progress bar can contain a text value indicating current progress"
                    , Field "Caption"
                        (Control.string
                            { value = pm.caption
                            , onInput = (\string ps -> { ps | caption = string }) >> UpdateProgress
                            , placeholder = ""
                            }
                        )
                    , Comment "A progress element can contain a label"
                    ]
              }
            ]
        }


type alias TypographyModel =
    { webkitFontSmoothing : WebkitFontSmoothing
    , typography : Typography
    , fontSize : Float
    , textAlign : TextAlign
    , lineHeight : Float
    , letterSpacing : Float
    }


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
            |> Typography.setWordBreak Normal_WordBreak
            |> Typography.setOverflowWrap Normal_OverflowWrap
    , fontSize = 16
    , textAlign = Left
    , lineHeight = 1.5
    , letterSpacing = 0
    }


typographyPlayground : Bool -> TypographyModel -> Html Msg
typographyPlayground isDarkMode tm =
    playground
        { isDarkMode = isDarkMode
        , preview =
            div
                [ css
                    [ displayFlex
                    , flexDirection column
                    , rowGap (Css.em 1)
                    , typography tm.typography
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
        , controlSections =
            [ { heading = ""
              , controls =
                    [ Field "-webkit-font-smoothing"
                        (Control.select
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
                        )
                    ]
              }
            , { heading = "Typography"
              , controls =
                    [ Field "font-family"
                        (Control.select
                            { value = tm.typography.font.families |> String.concat
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
                        )
                    , Field "font-size"
                        (Control.counter
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
                        )
                    , Field "font-style"
                        (Control.radio
                            { value = tm.typography.font.style |> Maybe.map .value |> Maybe.withDefault "-"
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
                        )
                    , Field "font-weight"
                        (Control.select
                            { value = tm.typography.font.weight |> Maybe.map .value |> Maybe.withDefault "-"
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
                        )
                    , Field "text-align"
                        (Control.radio
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
                        )
                    , Field "line-height"
                        (Control.counter
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
                        )
                    , Field "text-decoration"
                        (Control.radio
                            { value = tm.typography.textSetting.textDecoration |> Maybe.map .value |> Maybe.withDefault "-"
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
                        )
                    , Field "letter-spacing"
                        (Control.counter
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
                        )
                    , Field "text-transform"
                        (Control.select
                            { value = tm.typography.textSetting.textTransform |> Maybe.map .value |> Maybe.withDefault "-"
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
                        )
                    ]
              }
            , { heading = "TextBlock"
              , controls =
                    [ Field "word-break"
                        (Control.select
                            { value = tm.typography.textBlock.wordBreak |> Maybe.map Typography.wordBreakToString |> Maybe.withDefault "-"
                            , options = [ "normal", "break-all", "keep-all", "auto-phrase" ]
                            , onChange =
                                (\wordBreak m ->
                                    { m
                                        | typography =
                                            case wordBreak of
                                                "normal" ->
                                                    m.typography |> Typography.setWordBreak Normal_WordBreak

                                                "break-all" ->
                                                    m.typography |> Typography.setWordBreak BreakAll

                                                "keep-all" ->
                                                    m.typography |> Typography.setWordBreak KeepAll

                                                "auto-phrase" ->
                                                    m.typography |> Typography.setWordBreak AutoPhrase

                                                _ ->
                                                    m.typography
                                    }
                                )
                                    >> UpdateTypography
                            }
                        )
                    , Field "overflow-wrap"
                        (Control.select
                            { value = tm.typography.textBlock.overflowWrap |> Maybe.map Typography.overflowWrapToString |> Maybe.withDefault "-"
                            , options = [ "normal", "break-word", "anywhere" ]
                            , onChange =
                                (\overflowWrap m ->
                                    { m
                                        | typography =
                                            case overflowWrap of
                                                "normal" ->
                                                    m.typography |> Typography.setOverflowWrap Normal_OverflowWrap

                                                "break-word" ->
                                                    m.typography |> Typography.setOverflowWrap BreakWord

                                                "anywhere" ->
                                                    m.typography |> Typography.setOverflowWrap Anywhere

                                                _ ->
                                                    m.typography
                                    }
                                )
                                    >> UpdateTypography
                            }
                        )
                    ]
              }
            ]
        }


type Node msg
    = Comment String
    | Field String (Control msg)


playground :
    { isDarkMode : Bool
    , preview : Html msg
    , controlSections : List { heading : String, controls : List (Node msg) }
    }
    -> Html msg
playground { isDarkMode, preview, controlSections } =
    let
        controlSection { heading, controls } =
            div
                [ css
                    [ padding (Css.em 0.75)
                    , displayFlex
                    , flexDirection column
                    , rowGap (Css.em 1)
                    , borderRadius (Css.em 0.5)
                    , palette (Palette.controlSection isDarkMode)
                    ]
                ]
                (header
                    [ css
                        [ displayFlex
                        , justifyContent spaceBetween
                        , alignItems center
                        , fontWeight bold
                        , empty [ display none ]
                        ]
                    ]
                    [ text heading ]
                    :: List.map controlField controls
                )

        controlField node =
            case node of
                Comment str ->
                    div
                        [ css
                            [ palette Palette.textOptional
                            , empty [ display none ]
                            ]
                        ]
                        [ text str ]

                Field label control ->
                    div
                        [ css
                            [ display grid
                            , gridTemplateColumns [ fr 1, fr 1 ]
                            , alignItems center
                            , columnGap (em 0.25)
                            ]
                        ]
                        [ Html.label [] [ text label ]
                        , Control.render control
                        ]
    in
    section
        [ css
            [ padding4 (Css.em 0.5) (Css.em 0.5) (Css.em 0.5) (Css.em 1.5)
            , borderRadius (Css.em 1.5)
            , display grid
            , property "grid-template-columns" "1fr 25em"
            , columnGap (Css.em 1.5)
            , fontSize (px 14)
            , paletteWithBorder (border3 (px 1) solid) (Palette.playground isDarkMode)
            , property "-webkit-backdrop-filter" "blur(300px)"
            , property "backdrop-filter" "blur(300px)"
            , property "box-shadow" "0 5px 20px hsl(0, 0%, 0%, 0.05)"
            ]
        ]
        [ div [ css [ displayFlex, flexDirection column, justifyContent center ] ]
            [ preview ]
        , div
            [ css
                [ alignSelf start
                , padding (Css.em 0.5)
                , displayFlex
                , flexDirection column
                , rowGap (Css.em 0.5)
                , borderRadius (Css.em 1)
                , palette (Palette.controlPanel isDarkMode)
                ]
            ]
            (List.map controlSection controlSections)
        ]


emakiView : Model -> List { id : String, heading : String, sectionContents : List (Html Msg) } -> List (Html Msg)
emakiView model contents =
    let
        section_ content =
            section [ id content.id, css [ displayFlex, flexDirection column, rowGap (Css.em 0.5) ] ] <|
                h2 [ css [ fontSize (px 20), palette (Css.Palette.init |> setColor grey095) ] ] [ text content.heading ]
                    :: content.sectionContents
    in
    [ Css.Global.global globalStyles
    , navigation model contents
    , main_
        [ css
            [ padding (Css.em 1.5)
            , displayFlex
            , flexDirection column
            , rowGap (Css.em 2)
            , children
                [ everything
                    [ target [ property "scroll-margin-top" "1em" ] ]
                ]
            ]
        ]
        (List.map section_ contents)
    ]


globalStyles : List Snippet
globalStyles =
    let
        resetCss =
            [ Css.Global.selector "*, ::before, ::after"
                [ boxSizing borderBox
                , property "-webkit-font-smoothing" "antialiased"
                ]
            , Css.Global.everything
                [ margin zero ]
            ]

        globalCustomize =
            [ where_ ":root"
                [ fontFamily sansSerif
                , property "scroll-behavior" "smooth"
                ]
            , Css.Global.selector "body"
                [ display grid
                , gridTemplateColumns [ fr 1, fr 4 ]
                , before
                    [ property "content" "''"
                    , position absolute
                    , property "inset" "0"
                    , zIndex (int -2)
                    , property "background" """
radial-gradient(at 80% 90%, hsl(200, 100%, 10%), hsl(200, 100%, 10%) 40%, transparent 40%),
radial-gradient(at 70% -5%, hsl(300, 100%, 10%), hsl(300, 100%, 10%) 30%, transparent 40%),
radial-gradient(at 5% 0%, hsl(200, 100%, 20%), hsl(200, 100%, 20%) 50%, transparent 50%)"""
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
    in
    resetCss ++ globalCustomize


where_ : String -> List Style -> Snippet
where_ selector_ styles =
    Css.Global.selector (":where(" ++ selector_ ++ ")") styles


navigation : { a | url : Url, isDarkMode : Bool } -> List { b | heading : String, id : String } -> Html Msg
navigation { url, isDarkMode } items =
    let
        isSelected id =
            url.fragment == Just id

        listItem { id, heading } =
            li [ css [ listStyle none ] ]
                [ a
                    [ href ("#" ++ id)
                    , css
                        [ display block
                        , padding2 (Css.em 0.5) (Css.em 1)
                        , borderRadius (Css.em 0.5)
                        , textDecoration none
                        , paletteByState (Palette.navItem isDarkMode)
                        , batchIf (isSelected id)
                            [ palette (Palette.navItemSelected isDarkMode) ]
                        ]
                    ]
                    [ text heading ]
                ]
    in
    nav
        [ css
            [ position sticky
            , top zero
            , height (vh 100)
            , padding (Css.em 0.5)
            , displayFlex
            , flexDirection column
            , rowGap (Css.em 1)
            , fontSize (px 14)
            , fontWeight bold
            , palette (Palette.navigation isDarkMode)
            , property "-webkit-backdrop-filter" "blur(300px)"
            , property "backdrop-filter" "blur(300px)"
            , property "box-shadow" "0 5px 20px hsl(0, 0%, 0%, 0.05)"
            ]
        ]
        [ Html.label []
            [ input [ type_ "checkbox", Attributes.checked isDarkMode, onClick ToggleDarkMode ] []
            , text "DarkMode"
            ]
        , ul
            [ css
                [ padding zero
                , displayFlex
                , flexDirection column
                , rowGap (Css.px 5)
                ]
            ]
            (List.map listItem items)
        ]
