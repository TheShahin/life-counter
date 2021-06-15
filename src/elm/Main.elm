module Main exposing (main)

import Browser
import Browser.Events exposing (onClick)
import Html
import Html.Attributes exposing (style)
import Json.Decode exposing (succeed)
import Task
import Time



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
    | Start Time.Posix
    | Tick Time.Posix



-- MODEL


type alias Model =
    { isStarted : Bool
    , startTime : Time.Posix
    , elapsedTime : Time.Posix
    , totalDeaths : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model
        False
        (Time.millisToPosix 0)
        (Time.millisToPosix 0)
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
                , Task.perform Start Time.now
                )

        Start time ->
            ( { model | startTime = time, elapsedTime = time }
            , Cmd.none
            )

        Tick now ->
            if model.isStarted then
                let
                    difference =
                        Time.posixToMillis now - Time.posixToMillis model.startTime
                in
                ( { model
                    | elapsedTime = Time.millisToPosix difference
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
        , Time.every 50 Tick
        ]



-- VIEW


view : Model -> Html.Html Msg
view model =
    let
        padTime : Int -> String
        padTime unit =
            String.fromInt unit |> String.padLeft 2 '0'

        hour =
            padTime (Time.toHour Time.utc model.elapsedTime)

        minute =
            padTime (Time.toMinute Time.utc model.elapsedTime)

        second =
            padTime (Time.toSecond Time.utc model.elapsedTime)
    in
    Html.div
        [ style "font-family" "Verdana, sans-serif"
        , style "text-align" "center"
        ]
        [ Html.div
            [ style "font-size" "10em"
            , style "position" "absolute"
            , style "transform" "translate(-50%, -50%)"
            , style "top" "50%"
            , style "left" "50%"
            ]
            [ Html.text (String.fromInt model.totalDeaths)
            ]
        , Html.div
            [ style "font-size" "3em"
            ]
            [ Html.text (String.join ":" [ hour, minute, second ])
            ]
        ]
