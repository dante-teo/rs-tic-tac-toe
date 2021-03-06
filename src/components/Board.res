open Utils
open SharedTypes

let setStatus = (gameState: gameState) =>
    switch (gameState) {
        | Playing(Cross) => "Cross is playing"
        | Playing(Circle) => "Circle is playing"
        | Winner(Cross) => "The winner is Cross"
        | Winner(Circle) => "The winner is Circle"
        | Draw => "Draw"
    }

@react.component
let make = (~state: state, ~onMark, ~onRestart) =>
    <div className="game-board">
        (
            state.board
            |> List.mapi((index: int, row: row) =>
                <BoardRow
                    key=(string_of_int(index))
                    gameState=state.gameState
                    row
                    onMark
                    index
                />
            )
            |> Array.of_list
            |> React.array
        )
        <div className="status">
            (state.gameState |> setStatus |> renderString)
        </div>
        (
            switch (state.gameState) {
                | Playing(_) => React.null
                | _ =>
                    <button className="restart" onClick=onRestart>
                        (renderString("Restart"))
                    </button>
            }
        )
    </div>