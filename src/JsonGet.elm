module JsonGet exposing (Model(..), Msg(..), init, main, subscriptions, update, view, viewGif)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, string)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Model
    = Failure
    | Loading
    | Success String


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getRandomGif )



-- UPDATE


type Msg
    = MorePlease
    | GotGif (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MorePlease ->
            ( Loading, getRandomGif )

        GotGif result ->
            case result of
                Ok url ->
                    ( Success url, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ style "display" "grid"
        , style "height" "97vh"
        , style "align-content" "center"
        , style "justify-items" "center"
        ]
        [ h2 [] [ text "Random Gifs " ]
        , viewGif model
        ]


viewGif : Model -> Html Msg
viewGif model =
    case model of
        Failure ->
            div []
                [ text "I could not load a gif."
                , button [ onClick MorePlease ] [ text "Try Again!" ]
                ]

        Loading ->
            text "Loading ... "

        Success url ->
            div
                [ style "display" "grid"
                , style "justify-content" "center"
                , style "grid-gap" "15px"
                ]
                [ img
                    [ src url
                    , style "border-radius" "5px"
                    , style "box-shadow" "0px 0px 3px -2px rgba(0,0,0,0.75)"
                    , style "height" "200px"
                    , style "object-fit" "contain"
                    ]
                    []
                , button [ onClick MorePlease, style "display" "block" ] [ text "Another Please!" ]
                ]



-- HTTP


getRandomGif : Cmd Msg
getRandomGif =
    Http.get
        { url = "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC"
        , expect = Http.expectJson GotGif gifDecoder
        }


gifDecoder : Decoder String
gifDecoder =
    field "data" (field "image_url" string)
