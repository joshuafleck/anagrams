module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder, value, class, type_)
import Html.Events exposing (onInput, onSubmit)
import Json.Encode
import Json.Decode
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push

main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

-- MODEL

type alias Result =
    { requestedAt : String
    , word : String
    , lookupTime : String
    , anagrams : List String
    }

type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , word : String
    , results : List Result
    }

init : ( Model, Cmd Msg )
init =
    let
        channel =
            Phoenix.Channel.init "room:lobby"

        ( initSocket, phxCmd ) =
            Phoenix.Socket.init "ws://localhost:4000/socket/websocket"
                |> Phoenix.Socket.withDebug
                |> Phoenix.Socket.join channel

        model =
            { phxSocket = initSocket
            , word = ""
            , results = []
            }
    in
        ( model, Cmd.map PhoenixMsg phxCmd )

-- UPDATE

type Msg
  = PhoenixMsg (Phoenix.Socket.Msg Msg)
  | InputProvided String
  | AnagramsRequested
  | RequestFailed Json.Encode.Value
  | AnagramsReceived Json.Encode.Value

requestAnagram : Model -> ( Phoenix.Socket.Socket Msg, Cmd (Phoenix.Socket.Msg Msg) )
requestAnagram model =
    let
        phxPush =
            Phoenix.Push.init "search" "room:lobby"
                |> Phoenix.Push.withPayload (Json.Encode.string model.word)
                |> Phoenix.Push.onOk AnagramsReceived
                |> Phoenix.Push.onError RequestFailed

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.push phxPush model.phxSocket
    in
        ( phxSocket, phxCmd )

decodeAnagramResult: Json.Decode.Decoder Result
decodeAnagramResult =
    Json.Decode.map4 Result
        (Json.Decode.field "requestedAt" Json.Decode.string)
        (Json.Decode.field "word" Json.Decode.string)
        (Json.Decode.field "lookupTime" Json.Decode.string)
        (Json.Decode.field "anagrams" (Json.Decode.list Json.Decode.string))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
      PhoenixMsg msg ->
          let
              ( phxSocket, phxCmd ) = Phoenix.Socket.update msg model.phxSocket
          in
              ( { model | phxSocket = phxSocket }
              , Cmd.map PhoenixMsg phxCmd
              )
      InputProvided word ->
          ({model
               | word = word
           }
          , Cmd.none
          )
      AnagramsRequested ->
          let
              (phxSocket, phxCmd) =
                  requestAnagram model
          in
              ( { model
                    | word = ""
                    , phxSocket = phxSocket
                }
                , Cmd.map PhoenixMsg phxCmd
              )
      RequestFailed raw ->
          let _ = Debug.log "failed to search for anagrams" raw
          in
              (model, Cmd.none)
      AnagramsReceived raw ->
          let
              decodeResult =
                  Json.Decode.decodeValue decodeAnagramResult raw
            in
                case decodeResult of
                    Ok result ->
                        ( { model | results = result :: model.results }
                        , Cmd.none
                        )

                    Err error ->
                        let _ = Debug.log "anagram search failed" error
                        in
                            (model, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =
    div [] [ form [ class "form-inline"
                  , onSubmit AnagramsRequested
                  ]
                 [ div [ class "form-group"]
                       [ input [ class "form-control"
                               , placeholder "Enter a word"
                               , onInput InputProvided
                               , value model.word
                               ]
                             []
                       , button [ type_ "submit"
                                , class "btn btn-primary"
                                ]
                             [ text "Go"]
                       ]
                 ]
           , div [] (allResults model)
           ]

allResults : Model -> List (Html Msg)
allResults model =
    List.map (\result -> viewResult result) model.results

viewResult : Result -> Html Msg
viewResult result =
    div [ class "card" ]
        [ div [ class "card-block" ]
              [ h4 [ class "card-title" ]
                   [ text result.requestedAt]
              , h6 [ class "card-subtitle mb-2 text-muted" ]
                   [ text (toString(List.length result.anagrams) ++ " anagrams found for " ++ result.word ++ " in " ++ result.lookupTime ++ "ms") ]
              , p [ class "card-text" ]
                  [ text (String.join " " result.anagrams) ]
              ]
        ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Phoenix.Socket.listen model.phxSocket PhoenixMsg
