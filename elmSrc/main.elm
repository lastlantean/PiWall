import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- TYPES
type alias Model =
  {wifiNetworks : List WifiNetwork
  , connectSSID : String
  , key : String
  , currentWifi : String
  }

type alias WifiNetwork =
  {essid : String
  , encrypted : Bool
  }

-- MODEL

init : (Model, Cmd Msg)
init =
  (Model [WifiNetwork "Test" True, WifiNetwork "Test2" False] "" "" "Not connected", getWifiNetworks "wlan1")

-- UPDATE

type Msg
   = ScanWifi
   | NewWifi (Result Http.Error (List WifiNetwork))
   | KeyChange String
   | Connect
   | Connected (Result Http.Error WifiNetwork)
   | CheckCurrent
   | CurrentWifi (Result Http.Error WifiNetwork)
   | UpdateSSID String
   | HttpResp (Result Http.Error String) -- For use when we don't really care about the response
   | SendShutDown

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
   case msg of
   ScanWifi ->
      (model, getWifiNetworks "wlan1")

   NewWifi (Ok newUrl) ->
      ({model | wifiNetworks =  newUrl}, Cmd.none)

   NewWifi (Err _) ->
      (model, Cmd.none)

   KeyChange key ->
      ({model | key = key}, Cmd.none)

   Connect ->
      (model, sendConnReq model.connectSSID model.key)

   Connected ssid ->
      (model, Cmd.none)

   CheckCurrent ->
      (model, getCurrentWifi "wlan1")

   CurrentWifi (Ok data) ->
      ({model | currentWifi =  data.essid}, Cmd.none)

   CurrentWifi (Err _) ->
      (model, Cmd.none)

   UpdateSSID val ->
      ({ model | connectSSID = val },  Cmd.none)

   HttpResp (Ok resp) ->
      (model, Cmd.none)
   HttpResp (Err _) ->
      (model, Cmd.none)
   SendShutDown ->
      (model, sendShutdown)

-- VIEW


view : Model -> Html Msg
view model =
  div []
    [  div [] [
           b [] [text "Wifi Connection"]
      ]
      , div [] [
        text ("Currently connected to: " ++ model.currentWifi)
        , button [onClick CheckCurrent] [text "Check"]
      ]
    , viewWifiSelect model
    , button [ onClick ScanWifi ] [ text "Scan!" ]
    , br [] []
    , input [ placeholder "Password", onInput KeyChange ] []
    , br [] []
    , button [onClick Connect] [text "Connect"]
    , br [] []
    , br [] []
    , viewVPN model
    , br [] []
    , viewSystem model
    ]


viewWifiSelect : Model -> Html Msg
viewWifiSelect model =
    select
        [ value model.connectSSID
          , onInput UpdateSSID
        ] (List.map viewWifiSelectOptions model.wifiNetworks)


viewWifiSelectOptions : WifiNetwork -> Html Msg
viewWifiSelectOptions wifi =
  option [ value wifi.essid ] [ text (wifi.essid ++ " (" ++ (isEncryped wifi) ++ ", " ++ "70% signal"  ++")") ]

isEncryped : WifiNetwork -> String
isEncryped wifi =
  if wifi.encrypted then
    "Encrypted"
  else
    "Open"

-- VIEW VPN

viewVPN : Model -> Html Msg
viewVPN model =
  div [] [
    div [] [
           b [] [text "openVPN"]
      ]
      , div [] [
        text "Provider"
        , br [] []
        , text "Username"
        , br [] []
        , text "Password"
        , br [] []
        , text "Country"
      ]
  ]

viewSystem : Model -> Html Msg
viewSystem model =
   div [] [
      button [onClick SendShutDown] [text "Shut down"]
   ]

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- HTTP
sendShutdown : Cmd Msg
sendShutdown =
   Http.send HttpResp (Http.getString "/shutdown") 

getWifiNetworks : String -> Cmd Msg
getWifiNetworks interface =
  let
    url =
      "/scan?interface="++interface
  in
    Http.send NewWifi (Http.get url decodeWifiData)


decodeWifiData : Decode.Decoder (List WifiNetwork)
decodeWifiData =
  Decode.list decodeWifiNetwork

decodeWifiNetwork : Decode.Decoder WifiNetwork
decodeWifiNetwork =
  decode WifiNetwork
    |> Json.Decode.Pipeline.required "ESSID" Decode.string
    |> Json.Decode.Pipeline.required "Encrypted" Decode.bool


sendConnReq : String -> String -> Cmd Msg
sendConnReq ssid key =
  let
    url =
      "/connect?ssid="++ssid++"&key="++key
  in
    Http.send Connected (Http.get url decodeWifiNetwork)

getCurrentWifi : String -> Cmd Msg
getCurrentWifi interface =
  let
    url =
      "/currentWifi"
  in
    Http.send CurrentWifi (Http.get url decodeWifiNetwork)
