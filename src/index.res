%%raw(`
    import './index.css'
    import reportWebVitals from './reportWebVitals'
`)

switch ReactDOM.querySelector("#root") {
    | None => ()
    | Some(root) => ReactDOM.render(<App/>, root)
}

%%raw(`reportWebVitals()`)