module Main exposing (main)

import Browser
import Browser.Events exposing (onClick)
import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (style)
import Json.Decode exposing (succeed)
import Task
import Time exposing (Posix, Zone, every, millisToPosix, now, posixToMillis, toHour, toMinute, toSecond, utc)



-- CONSTANTS


millisPerYear : Float
millisPerYear =
    3.15576e10


totalAnnualLandAnimals : Float
totalAnnualLandAnimals =
    7.3e10


deathRatePerMillis : Float
deathRatePerMillis =
    totalAnnualLandAnimals / millisPerYear



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
    , startTime : Posix
    , elapsedTime : Posix
    , totalDeaths : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model
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
                ( model, Cmd.none )

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
        , every 50 Tick
        ]



-- VIEW


view : Model -> Html Msg
view model =
    let
        time : Posix -> (Zone -> Posix -> Int) -> String
        time posix f =
            String.padLeft 2 '0' <| String.fromInt <| f utc posix

        fontSize : String -> Attribute msg
        fontSize =
            style "font-size"
    in
    div
        [ style "font-family" "Verdana, sans-serif"
        , style "text-align" "center"
        ]
        [ div
            [ fontSize "10em"
            , style "position" "absolute"
            , style "transform" "translate(-50%, -50%)"
            , style "top" "50%"
            , style "left" "50%"
            ]
            [ text (String.fromInt model.totalDeaths)
            ]
        , div
            [ fontSize "3em"
            ]
            [ text (List.map (time model.elapsedTime) [ toHour, toMinute, toSecond ] |> String.join ":")
            ]
        ]
