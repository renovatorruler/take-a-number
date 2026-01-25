// ServedScreen.res - Thank you screen with social follow prompt

@react.component
let make = (~storeName: option<string>=?, ~onTakeAnother: option<unit => unit>=?) => {
  // Placeholder Twitter handle (would come from store settings in v2)
  let twitterHandle = "@storename"
  let displayName = storeName->Option.getOr("us")

  let handleTakeAnother = (_e: ReactEvent.Mouse.t) => {
    switch onTakeAnother {
    | Some(fn) => fn()
    | None => ()
    }
  }

  <div className="served-screen" dataTestId="served-screen">
    <div className="served-checkmark"> {React.string("✓")} </div>
    <h1 className="served-title"> {React.string("Thanks for visiting!")} </h1>
    <p className="served-message"> {React.string("We hope to see you again soon.")} </p>
    <div className="social-prompt" dataTestId="social-prompt">
      <h3> {React.string(`Follow ${displayName}`)} </h3>
      <p className="social-handle"> {React.string(twitterHandle)} </p>
      <a
        href={`https://twitter.com/${twitterHandle->String.slice(~start=1, ~end=100)}`}
        target="_blank"
        rel="noopener noreferrer"
        className="social-link"
        dataTestId="twitter-link">
        {React.string("🐦 Follow on Twitter")}
      </a>
    </div>
    <button className="btn btn-secondary" onClick=handleTakeAnother dataTestId="take-another-btn">
      {React.string("Take Another Number")}
    </button>
  </div>
}

// Expose to window for HTM usage
let expose = () => {
  Preact.setWindowProperty("ServedScreen", make)
}
