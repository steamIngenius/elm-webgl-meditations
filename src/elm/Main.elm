module Main exposing (main)

import Window exposing (Size)
import Html exposing (Html)
import Html.Attributes as Att
import WebGL exposing (Mesh, Shader, toHtml, entity)
import Math.Vector3 exposing (Vec3, vec3)
import Task


main : Program Never Model Msg
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


init : ( Model, Cmd Msg )
init =
    ( Model (Size 0 0), Task.perform WindowResize Window.size )



-- UPDATE --


type Msg
    = WindowResize Size


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WindowResize size ->
            ( Model size, Cmd.none )



-- VIEW --


view : Model -> Html Msg
view { size } =
    toHtml
        [ Att.id "canvas"
        , Att.width size.width
        , Att.height size.height
        , Att.style
            [ ( "display", "block" )
            , ( "width", toString size.width ++ "px" )
            , ( "height", toString size.height ++ "px" )
            , ( "background", "#000" )
            ]
        ]
        [ entity
            vertexShader
            fragmentShader
            mesh
            {}
        ]



-- MESH --


type alias Vertex =
    { position : Vec3
    , color : Vec3
    }


mesh : Mesh Vertex
mesh =
    WebGL.triangles
        [ ( Vertex (vec3 0.0 1.0 0.0) (vec3 1 0 0)
          , Vertex (vec3 -1.0 -1.0 0.0) (vec3 0 1 0)
          , Vertex (vec3 1.0 -1.0 0.0) (vec3 0 0 1)
          )
        ]



-- SHADERS --


type alias Uniforms =
    {}


type alias Varying =
    { vcolor : Vec3 }


vertexShader : Shader Vertex Uniforms Varying
vertexShader =
    [glsl|

    precision mediump float;

    attribute vec3 position;
    attribute vec3 color;
    varying vec3 vcolor;

    void main () {
        gl_Position = vec4(position, 1.0);
        vcolor = color;
    }

    |]


fragmentShader : Shader {} Uniforms Varying
fragmentShader =
    [glsl|

    precision mediump float;

    varying vec3 vcolor;

    void main () {
        gl_FragColor = vec4(vcolor, 1.0);
    }

|]
