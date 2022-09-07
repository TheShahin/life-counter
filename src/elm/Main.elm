module Main exposing (main)

import Browser
import Browser.Events exposing (onClick, onKeyPress)
import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Json.Decode exposing (succeed)
import String.Extra
import Task
import Time exposing (Posix, every, millisToPosix, now, posixToMillis, toHour, toMinute, toSecond, utc)



-- CONSTANTS


millisPerYear : Float
millisPerYear =
    3.15576e10


landAnimalsKilledPerYear : Float
landAnimalsKilledPerYear =
    7.8e10


deathRatePerMillis : Float
deathRatePerMillis =
    landAnimalsKilledPerYear / millisPerYear



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Msg
    = Click
    | Start Posix
    | Tick Posix



-- MODEL


type alias Model =
    { isStarted : Bool
    , isHidden : Bool
    , startTime : Posix
    , elapsedTime : Posix
    , totalDeaths : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model
        False
        False
        (millisToPosix 0)
        (millisToPosix 0)
        0
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Click ->
            if model.isStarted then
                ( { model | isHidden = not model.isHidden }, Cmd.none )

            else
                ( { model | isStarted = True }
                , Task.perform Start now
                )

        Start time ->
            ( { model | startTime = time, elapsedTime = millisToPosix 0 }
            , Cmd.none
            )

        Tick now ->
            if model.isStarted then
                let
                    difference =
                        posixToMillis now - posixToMillis model.startTime
                in
                ( { model
                    | elapsedTime = millisToPosix difference
                    , totalDeaths = difference |> toFloat |> (*) deathRatePerMillis |> round
                  }
                , Cmd.none
                )

            else
                init ()



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ onClick (succeed Click)
        , onKeyPress (succeed Click)
        , every 50 Tick
        ]



-- VIEW


view : Model -> Html Msg
view model =
    let
        absolutePosition =
            style "position" "absolute"

        fontSize =
            style "font-size"

        timerDiv =
            div
                [ fontSize "4em"
                ]
                [ text
                    (String.join ":"
                        (List.map
                            (\unit -> unit utc model.elapsedTime |> String.fromInt >> String.padLeft 2 '0')
                            [ toHour, toMinute, toSecond ]
                        )
                    )
                ]

        counterDiv =
            let
                prettyCount : Int -> String
                prettyCount =
                    String.fromInt
                        >> String.reverse
                        >> String.Extra.break 3
                        >> String.join " "
                        >> String.reverse
            in
            div
                [ fontSize "10em"
                , absolutePosition
                , style "transform" "translate(-50%, -50%)"
                , style "top" "50%"
                , style "left" "50%"
                , style "overflow" "hidden"
                , style "white-space" "nowrap"
                ]
                [ text (prettyCount model.totalDeaths)
                ]
    in
    div
        [ style "font-family" "Verdana, sans-serif"
        , style "background-color" "black"
        , style "color" "white"
        , style "text-align" "center"
        , style "height" "100%"
        , style "width" "100%"
        , absolutePosition
        ]
        (if model.isHidden then
            [ timerDiv ]

         else
            [ timerDiv, counterDiv ]
        )
