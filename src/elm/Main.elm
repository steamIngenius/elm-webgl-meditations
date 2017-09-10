module Main exposing (main)

import Html.Attributes as Att
import WebGL exposing (toHtml)


main =
    toHtml
        [ Att.id "canvas"
        , Att.width 400
        , Att.height 200
        , Att.style
            [ ( "width", toString 400 ++ "px" )
            , ( "height", toString 200 ++ "px" )
            , ( "background", "#000" )
            ]
        ]
        []
