open Utils

@react.component
let make = () =>
    <div>
        <div className="title">(renderString("Tic Tac Toe"))</div>
        <Game/>
    </div>