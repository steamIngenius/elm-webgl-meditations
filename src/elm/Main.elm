module Main exposing (main)

import Window exposing (Size)
import Html exposing (Html)
import Html.Attributes as Att
import WebGL exposing (Mesh, Shader, toHtml, entity)
import Math.Vector3 exposing (Vec3, vec3)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Color exposing (Color)
import Task
import AnimationFrame
import Time exposing (Time)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes WindowResize
        , AnimationFrame.diffs TimeUpdate
        ]



-- MODEL --


type alias Model =
    { size : Size
    , time : Time
    }



-- INIT --


init : ( Model, Cmd Msg )
init =
    ( Model (Size 0 0) 0, Task.perform WindowResize Window.size )



-- UPDATE --


type Msg
    = WindowResize Size
    | TimeUpdate Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WindowResize size ->
            ( Model size model.time, Cmd.none )

        TimeUpdate time ->
            (model.time + time / 5000)
                |> Model model.size
                => Cmd.none



-- VIEW --


view : Model -> Html Msg
view { size, time } =
    toHtml
        [ Att.id "canvas"
        , Att.width size.width
        , Att.height size.height
        , Att.style
            [ ( "display", "block" )
            , ( "width", toString size.width ++ "px" )
            , ( "height", toString size.height ++ "px" )
            , ( "background", "#333" )
            ]
        ]
        [ entity
            vertexShader
            fragmentShader
            cube
            (uniforms time)
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


cube : Mesh Vertex
cube =
    let
        rft =
            vec3 1 1 1

        lft =
            vec3 -1 1 1

        lbt =
            vec3 -1 -1 1

        rbt =
            vec3 1 -1 1

        rbb =
            vec3 1 -1 -1

        rfb =
            vec3 1 1 -1

        lfb =
            vec3 -1 1 -1

        lbb =
            vec3 -1 -1 -1
    in
        [ face Color.green rft rfb rbb rbt
        , face Color.blue rft rfb lfb lft
        , face Color.yellow rft lft lbt rbt
        , face Color.red rfb lfb lbb rbb
        , face Color.purple lft lfb lbb lbt
        , face Color.orange rbt rbb lbb lbt
        ]
            |> List.concat
            |> WebGL.triangles


face : Color -> Vec3 -> Vec3 -> Vec3 -> Vec3 -> List ( Vertex, Vertex, Vertex )
face rawColor a b c d =
    let
        color =
            let
                c =
                    Color.toRgb rawColor
            in
                vec3
                    (toFloat c.red / 255)
                    (toFloat c.green / 255)
                    (toFloat c.blue / 255)

        vertex position =
            Vertex position color
    in
        [ ( vertex a, vertex b, vertex c )
        , ( vertex c, vertex d, vertex a )
        ]



-- SHADERS --


type alias Uniforms =
    { rotation : Mat4
    , perspective : Mat4
    , camera : Mat4
    , shade : Float
    }


uniforms : Float -> Uniforms
uniforms theta =
    { rotation =
        Mat4.mul
            (Mat4.makeRotate (3 * theta) (vec3 0 1 0))
            (Mat4.makeRotate (2 * theta) (vec3 1 0 0))
    , perspective = Mat4.makePerspective 45 1 0.01 100
    , camera = Mat4.makeLookAt (vec3 0 0 5) (vec3 0 0 0) (vec3 0 1 0)
    , shade = 0.8
    }


type alias Varying =
    { vcolor : Vec3 }


vertexShader : Shader Vertex Uniforms Varying
vertexShader =
    [glsl|

    attribute vec3 position;
    attribute vec3 color;
    uniform mat4 perspective;
    uniform mat4 camera;
    uniform mat4 rotation;
    varying vec3 vcolor;

    void main () {
        gl_Position = perspective * camera * rotation * vec4(position, 1.0);
        vcolor = color;
    }

    |]


fragmentShader : Shader {} Uniforms Varying
fragmentShader =
    [glsl|

    precision mediump float;

    uniform float shade;
    varying vec3 vcolor;

    void main () {
        gl_FragColor = shade * vec4(vcolor, 1.0);
    }

|]



-- UTILS --


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


{-| infixl 0 means the (=>) operator has the same precedence as (<|) and (|>),
meaning you can use it at the end of a pipeline and have the precedence work out.
-}
infixl 0 =>
