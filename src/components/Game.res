open SharedTypes

type action =
    | ClickSquare(string)
    | Restart

type winner =
    | Cross
    | Circle
    | NoOne

type winningRows = list<list<int>>
let winningCombs = list{
    list{ 0, 1, 2 },
    list{ 3, 4, 5 },
    list{ 6, 7, 8 },
    list{ 0, 3, 6 },
    list{ 1, 4, 7 },
    list{ 2, 5, 8 },
    list{ 0, 4, 8 },
    list{ 2, 4, 6 },
}

let gameEnded = board =>
    List.for_all(
        field => field == Marked(Circle) || field == Marked(Cross),
        board
    )

let whosPlaying = (gameState: gameState) =>
    switch (gameState) {
        | Playing(Cross) => Playing(Circle)
        | _ => Playing(Cross)
    }

let getWinner = (flattenBoard, coords) =>
    switch (
        List.nth(flattenBoard, List.nth(coords, 0)),
        List.nth(flattenBoard, List.nth(coords, 1)),
        List.nth(flattenBoard, List.nth(coords, 2))
    ) {
        | (Marked(Cross), Marked(Cross), Marked(Cross)) => Cross
        | (Marked(Circle), Marked(Circle), Marked(Circle)) => Circle
        | (_, _, _) => NoOne
    }

let checkGameState = (
    winningRows: winningRows,
    updatedBoard: board,
    oldBoard: board,
    gameState: gameState
) =>
    oldBoard == updatedBoard ?
        gameState : {
            let flattenBoard = List.flatten(updatedBoard)
            let rec check = (rest: winningRows) => {
                let head = List.hd(rest)
                let tail = List.tl(rest)
                switch (
                    getWinner(flattenBoard, head),
                    gameEnded(flattenBoard),
                    tail
                ) {
                    | (Cross, _, _) => Winner(Cross)
                    | (Circle, _, _) => Winner(Circle)
                    | (_, true, list{}) => Draw
                    | (_, false, list{}) => whosPlaying(gameState)
                    | _ => check(tail)
                }
            }

            check(winningRows)
        }

let checkGameState3x3 = checkGameState(winningCombs)

let updateBoard = (board: board, gameState: gameState, id) =>
    board
    |> List.mapi((ind: int, row: row) =>
        row
        |> List.mapi((index: int, value: field) =>
            string_of_int(ind) ++ string_of_int(index) === id ?
                switch (gameState, value) {
                    | (Playing(_), Marked(_)) => value
                    | (Playing(player), Empty) => Marked(player)
                    | (_, _) => Empty
                } : value))

let initialState = {
    board: list{
        list{ Empty, Empty, Empty },
        list{ Empty, Empty, Empty },
        list{ Empty, Empty, Empty }
    },
    gameState: Playing(Cross)
}

let reducer = (state, action) =>
    switch (action) {
        | Restart => initialState
        | ClickSquare(id) =>
            let updatedBoard = updateBoard(state.board, state.gameState, id)
            {
                board: updatedBoard,
                gameState: checkGameState3x3(updatedBoard, state.board, state.gameState)
            }
    }

@react.component
let make = () => {
    let (state, dispatch) = React.useReducer(reducer, initialState)

    <div className="game">
        <Board
            state
            onRestart=(_ => dispatch(Restart))
            onMark=(id => dispatch(ClickSquare(id)))
        />
    </div>
}
// let component = ReasonReact.reducerComponent("Game");

// let make = _children => {
//   ...component,
//   initialState: () => initialState,
//   reducer: (action: action, state: state) =>
//     switch (action) {
//     | Restart => ReasonReact.Update(initialState)
//     | ClickSquare((id: string)) =>
//       let updatedBoard = updateBoard(state.board, state.gameState, id);
//       ReasonReact.Update({
//         board: updatedBoard,
//         gameState:
//           checkGameState3x3(updatedBoard, state.board, state.gameState),
//       });
//     },
//   render: ({state, send}) =>
//     <div className="game">
//       <Board
//         state
//         onRestart=(_evt => send(Restart))
//         onMark=(id => send(ClickSquare(id)))
//       />
//     </div>,
// };