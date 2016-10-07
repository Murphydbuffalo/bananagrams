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
  MoveTile Player Tile Board |
  TakeTile Player Tile |
  TradeTile Player Tile |
  GameOver Player

type alias Tile = Html Msg
type alias Square = Html Msg
type alias Board = Html Msg
type alias Player =
  {
    id : Int,
    name : String,
    tiles : List (Tile),
    board : Board
  }

type alias Model =
  {
    players : List Player,
    tiles : List (Tile),
    winner : Maybe Player
  }

-- INITIALIZE STATE
init : { playerNames : List String } -> (Model, Cmd Msg)
init { playerNames } =
  let
    shuffledLetters = List.concatMap repeatedLetterList (Dict.keys letterRatios) |> shuffle
    shuffledTiles = List.map (\letter -> (tile letter)) shuffledLetters
    players = generatePlayers playerNames shuffledTiles

    numberOfTilesUsed = (List.length players) * tilesPerPlayer
    remainingTiles = List.take (numberOfTiles - numberOfTilesUsed) (List.reverse shuffledTiles)
  in
    (Model players remainingTiles Nothing, Cmd.none)

tile : String -> Tile
tile string =
  let
    tileStyles = ("background-color" => "#FFCD9D") :: squareStyles
  in
    div [class "tile", style tileStyles] [text string]

newSquare : Square
newSquare =
  div [class "square", style squareStyles] []

newBoard : Board
newBoard =
  let
    squares = List.repeat 9 newSquare
    rows = List.repeat 9 (div [class "row", style flexContainerStyles] squares)
  in
    div [class "board"] rows

shuffle : List String -> List String
shuffle letters =
  let
    randomListGenerator = Random.list numberOfTiles (Random.int 1 numberOfTiles)
    indexes = Random.step randomListGenerator (Random.initialSeed 432750601478) |> fst
    indexedList = List.map2 (,) indexes letters
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

generatePlayers : List String -> List (Tile) -> List Player
generatePlayers playerNames tiles =
  let
    n = List.length playerNames
    ids = Array.initialize n identity |> Array.toList |> List.map (\num -> (num + 1))
    playerTiles = divyUpTiles ids tiles
  in
    List.map3 (\id name tiles -> (
      Player id name tiles newBoard
    )) ids playerNames playerTiles

divyUpTiles : List Int -> List Tile -> List (List Tile)
divyUpTiles ids tiles =
  List.map (\id ->
    ((List.take (tilesPerPlayer * id) tiles) |> List.reverse |> List.take tilesPerPlayer)
  ) ids

-- UPDATE STATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MoveTile actingPlayer tile updatedBoard ->
      let
        player = List.filter (\p -> (actingPlayer.id == p.id)) model.players |> List.head
        updatedTiles = List.filter (\t -> (not (t == tile))) actingPlayer.tiles
        updatedPlayer = { actingPlayer | board = updatedBoard, tiles = updatedTiles }
        updatedPlayers = List.map (\p -> (
          if p.id == updatedPlayer.id then
            updatedPlayer
          else
            p
        )) model.players
      in
        ({ model | players = updatedPlayers }, Cmd.none)
    TakeTile tile player ->
      (model, Cmd.none)
    TradeTile tile player ->
      (model, Cmd.none)
    GameOver winningPlayer ->
      (model, Cmd.none)

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- VIEW
view : Model -> Html Msg
view model =
  div [] [
    h1 [id "#title"] [text "Bananagrams Mothertrucker!"],
    br [] [],
    div [id "#tiles", style flexContainerStyles] model.tiles,
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
