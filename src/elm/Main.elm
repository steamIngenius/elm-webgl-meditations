module Main exposing (main)

import Window exposing (Size)
import Html exposing (Html)
import Html.Attributes as Att
import WebGL exposing (toHtml)
import Task


main =
    Html.program
        { init = init
        , subscriptions = \_ -> Window.resizes WindowResize
        , update = update
        , view = view
        }



-- MODEL --


type alias Model =
    { size : Size
    }



-- INIT --


init =
    ( Model (Size 0 0), Task.perform WindowResize Window.size )



-- UPDATE --


type Msg
    = WindowResize Size


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WindowResize size ->
            let
                _ =
                    Debug.log "Current window size: " size
            in
                ( Model size, Cmd.none )



-- VIEW --


view model =
    toHtml
        [ Att.id "canvas"
        , Att.width model.size.width
        , Att.height model.size.height
        , Att.style
            [ ( "display", "block" )
            , ( "width", toString model.size.width ++ "px" )
            , ( "height", toString model.size.height ++ "px" )
            , ( "background", "#000" )
            ]
        ]
        []
