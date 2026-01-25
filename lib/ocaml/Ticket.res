// Ticket.res - Red paper ticket component

// Style object helper
let makeStyle: {..} => ReactDOM.style = %raw(`function(s) { return s; }`)

@react.component
let make = (~number: int, ~storeName: option<string>=?, ~isRevealing: bool=false) => {
  let (revealed, setRevealed) = React.useState(() => !isRevealing)

  React.useEffect1(() => {
    if isRevealing {
      let timerId = setTimeout(() => setRevealed(_ => true), 100)
      Some(() => clearTimeout(timerId))
    } else {
      None
    }
  }, [isRevealing])

  let style = makeStyle({
    "opacity": revealed ? "1" : "0",
    "transform": revealed ? "scale(1)" : "scale(0.9)",
    "transition": "all 0.3s ease-out",
  })

  <div className={`paper-ticket ${revealed ? "revealed" : ""}`} dataTestId="ticket" style>
    {switch storeName {
    | Some(name) =>
      <div className="ticket-store-name" dataTestId="ticket-store-name">
        {React.string(name)}
      </div>
    | None => React.null
    }}
    <div className="ticket-number-display" dataTestId="ticket-number">
      {React.string(`#${Int.toString(number)}`)}
    </div>
    <div className="ticket-your-number"> {React.string("Your Number")} </div>
  </div>
}

// Expose to window for HTM usage
let expose = () => {
  Preact.setWindowProperty("Ticket", make)
}
