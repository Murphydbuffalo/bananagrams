import Html exposing (Html, h1, div, text, button, br)
import Html.Attributes exposing (id, class, style)
import Html.App exposing (programWithFlags)
import String exposing (join, repeat, split)
-- import WebSocket exposing (listen, send)
import Dict exposing (Dict, fromList, get, keys)
import Random exposing (step, list, int)
import Array exposing (initialize, toList)

main : Program { playerNames : List String }
main =
  Html.App.programWithFlags {
    init = init,
    update = update,
    subscriptions = subscriptions,
    view = view
  }

numberOfTiles : Int
numberOfTiles = 144

tilesPerPlayer : Int
tilesPerPlayer = 21

letterRatios : Dict String Int
letterRatios =
  Dict.fromList [
    ("A", 13),
    ("B", 3),
    ("C", 3),
    ("D", 6),
    ("E", 18),
    ("F", 3),
    ("G", 4),
    ("H", 3),
    ("I", 12),
    ("J", 2),
    ("K", 2),
    ("L", 5),
    ("M", 3),
    ("N", 8),
    ("O", 11),
    ("P", 3),
    ("Q", 2),
    ("R", 9),
    ("S", 6),
    ("T", 9),
    ("U", 6),
    ("V", 3),
    ("W", 3),
    ("X", 2),
    ("Y", 3),
    ("Z", 2)
  ]

-- TYPE DEFINITIONS
type Msg =
  PlayLetter String |
  TakeLetter String |
  TradeLetter String |
  GameOver String

type alias Player =
  {
    id : Int,
    name : String,
    tiles : List (Html Msg),
    board : Html Msg
  }

type alias Model =
  {
    players : List Player,
    tiles : List (Html Msg),
    winner : Maybe Player
  }

-- INITIALIZE STATE
-- Hardcode the number of players for now (on the server).
-- Once you've implemented the lobby/start screen you can have that be its own Elm module
-- And one of its jobs will be to tell the server to add a player. That dynamic list
-- of players can then be passed as a flag to this module.
init : { playerNames : List String } -> (Model, Cmd Msg)
init { playerNames } =
  let
    shuffledLetters = List.concatMap repeatedLetterList (Dict.keys letterRatios) |> shuffleTiles
    shuffledTiles = List.map (\letter -> (tile letter)) shuffledLetters
    players = generatePlayers playerNames shuffledTiles

    numberOfTilesUsed = (List.length players) * tilesPerPlayer
    remainingTiles = List.take (numberOfTiles - numberOfTilesUsed) (List.reverse shuffledTiles)
  in
    (Model players remainingTiles Nothing, Cmd.none)

tile : String -> Html Msg
tile string =
  div [class "tile", style tileStyles] [text string]

newBoard : Html Msg
newBoard =
  let
    tiles = List.repeat 9 (tile "")
    rows = List.repeat 9 (div [class "row", style tileContainerStyles] tiles)
  in
    div [class "board"] rows

shuffleTiles : List a -> List a
shuffleTiles tiles =
  let
    randomListGenerator = Random.list numberOfTiles (Random.int 1 numberOfTiles)
    indexes = Random.step randomListGenerator (Random.initialSeed 432750601478) |> fst
    indexedList = List.map2 (,) indexes tiles
  in
    indexedList |> List.sortBy fst |> List.unzip |> snd

repeatedLetterList : String -> List String
repeatedLetterList letter =
  let
    letterCount = Dict.get (String.toUpper letter) letterRatios
    repeatedLetterString =
      case letterCount of
        Just n ->
           String.repeat n letter
        Nothing ->
          ""
  in
    String.split "" repeatedLetterString

generatePlayers : List String -> List (Html Msg) -> List Player
generatePlayers playerNames tiles =
  let
    n = List.length playerNames
    ids = Array.initialize n identity |> Array.toList |> List.map (\num -> (num + 1))
    playerTiles = divyUpTiles ids tiles
  in
    List.map3 (\id name tiles -> (
      Player id name tiles newBoard
    )) ids playerNames playerTiles

divyUpTiles : List Int -> List a -> List (List a)
divyUpTiles ids tiles =
  List.map (\id ->
    ((List.take (tilesPerPlayer * id) tiles) |> List.reverse |> List.take tilesPerPlayer)
  ) ids

-- UPDATE STATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    PlayLetter letter ->
      (model, Cmd.none)
    TakeLetter letter ->
      (model, Cmd.none)
    TradeLetter letter ->
      (model, Cmd.none)
    GameOver winner ->
      -- Must validate board: spellcheck, and more?
      -- Must provide the ID and name of the winner
      (model, Cmd.none)

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  -- Sub.batch [
  --   WebSocket.listen "ws://localhost:4000/socket/play_letter" PlayLetter,
  --   WebSocket.listen "ws://localhost:4000/socket/take_letter" TakeLetter,
  --   WebSocket.listen "ws://localhost:4000/socket/trade_letter" TradeLetter,
  --   WebSocket.listen "ws://localhost:4000/socket/game_over" GameOver
  -- ]
  Sub.none

-- VIEW
view : Model -> Html Msg
view model =
  div [] [
    h1 [id "#title"] [text "Bananagrams Mothertrucker!"],
    br [] [],
    div [id "#tiles", style tileContainerStyles] model.tiles,
    div [id "#players"] (List.map playerUI model.players)
  ]

playerUI : Player -> Html Msg
playerUI player =
  let
    playerId = "player-" ++ toString(player.id)
  in
    div [id playerId] [
      h1 [class "player-title"] [text player.name],
      br [] [],
      player.board,
      br [] [],
      div [class "player-tiles", style flexContainerStyles] player.tiles
    ]

(=>) : a -> b -> (a, b)
(=>) = (,)

-- Extract these styles to a stylesheet at some point
flexContainerStyles : List (String, String)
flexContainerStyles =
  [
    ("display" => "flex"),
    ("flex-direction" => "row"),
    ("flex-wrap" => "wrap"),
    ("justify-content" => "flex-start")
  ]

squareStyles : List (String, String)
squareStyles =
  [
    ("height" => "40px"),
    ("width" => "40px"),
    ("font-size" => "16px"),
    ("border" => "1px solid black"),
    ("border-radius" => "7px"),
    ("cursor" => "pointer"),
    ("text-align" => "center"),
    ("vertical-align" => "center"),
    ("line-height" => "40px")
  ]
