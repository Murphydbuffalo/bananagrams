# Bananagrams

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## TODO
+ Find out how to have `WebSocket.listen` accept different Msg sub types based on the content of the string returned from the server
  + The `elm-phoenix-socket` library may have clues as to how to do this.


+ JSON encoding and decoding so that Elm can communicate with Phoenix (there's an elm package for this)

+ How do you want to handle spelling? Passing the entire updated board as an argument? Only the diff?
  + Will need to subscribe to mouse drag events to handle the submission updates to the players' boards


+ Styling and layout: FlexBox? Drag n' drop tiles, no submit button, better favicon, font & graphics

+ Differentiate the user's player from the other players.
  + Their board should look distinct; be larger, centered, and styled differently.


+ Make sure players have unique identifiers

+ Break up App.elm into modules

+ Put our value for Random.initialSeed into an environment variable

+ Implement a varied `tilesPerPlayer` and `numberOfTiles` based on # of players
  + For a game with 4 or fewer players each player get 21 tiles.
  + For a game of 5 or 6 players each player gets 15 tiles.
  + For a game of 7 or 8 players each player gets 11 tiles.

+ Lobby/start screen: players should be able to join the game and chat before starting

+ In game chat (will be implemented as part of the start screen/lobby)

+ Victory UI: something should pop up when the game is over

+ Timer, track the length of the game

+ Sessions: players should be able to resume their game after network trouble (store state on server processes)

+ Persistence: Store player names, friends, wins/losses, longest/most uncommon words, etc
