module Emaki exposing (..)

{-|


# Elm-Emaki

    import App.Button exposing (view) -- view : { label: String, onClick : msg } -> Html msg

    button : Emaki
    button = emakiOf (\label -> msg -> view { label = label, onClick = msg } )
      |> stringProps { label = "change me" } }
      |> actionLogger msg

-}

-- type alias Model =
--     { element :
--      props : Array NewProp.Model
--     }
-- type Msg
--     = PropsMsg Int NewProp.Msg
-- update : Msg -> Model -> Model
-- update msg model =
--     case msg of
--         PropsMsg index newPropMsg ->
--             Array.Extra.update index (NewProp.update newPropMsg) model

import Browser
import Html exposing (..)
import Html.Attributes exposing (checked, type_, value)
import Html.Events exposing (onCheck, onInput)
import Maybe.Extra



-- type ParamModifier viewParam
--     = ParamModifier (viewParam -> viewParam)
--     | NoOp


type alias Lens s a =
    { get : s -> a
    , set : a -> s -> s
    }


type alias Props model =
    model -> Html (model -> model)


bool : String -> Lens params Bool -> Props params
bool labelStr l params =
    div []
        [ label []
            [ text labelStr
            , input [ type_ "checkbox", onCheck l.set, checked (l.get params) ] []
            ]
        ]


int : String -> Lens params Int -> Props params
int labelStr l params =
    div []
        [ label []
            [ text labelStr
            , input
                [ type_ "number"
                , onInput (String.toInt >> Maybe.Extra.unwrap identity l.set)
                , value (String.fromInt (l.get params))
                ]
                []
            ]
        ]


string : String -> Lens params String -> Props params
string labelStr l params =
    div []
        [ label []
            [ text labelStr
            , input [ onInput l.set, value (l.get params) ] []
            ]
        ]


type alias SampleViewParams =
    { name : String
    , age : Int
    , isMale : Bool
    }


sampleProps : List (Props SampleViewParams)
sampleProps =
    [ string "name" (Lens .name (\name r -> { r | name = name }))
    , int "age" (Lens .age (\age r -> { r | age = age }))
    , bool "isMale" (Lens .isMale (\isMale r -> { r | isMale = isMale }))
    ]


sampleView : SampleViewParams -> Html msg
sampleView r =
    text <|
        String.concat
            [ r.name
            , String.fromInt r.age
            , if r.isMale then
                "true"

              else
                "false"
            ]


type StatelessMsg params
    = UpdateParams params


runStateless :
    { default : model
    , view : model -> Html (model -> model)
    , props : List (Props (model -> model))
    }
    -> Program () model (StatelessMsg model)
runStateless { default, view, props } =
    Browser.sandbox
        { init = default
        , view = \s -> view s |> Html.map (\f -> UpdateParams (f s))
        , update = \(UpdateParams new) _ -> new
        }
