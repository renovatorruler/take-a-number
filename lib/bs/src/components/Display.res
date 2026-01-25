// Display.res - TV display screen

@react.component
let make = (~storeId: string) => {
  <div className="page" dataTestId="display-page">
    <div className="page-header">
      <h1 className="page-title"> {React.string("Display")} </h1>
      <p className="page-subtitle"> {React.string(`Store: ${storeId}`)} </p>
    </div>
    <div className="container">
      <p className="text-center"> {React.string("Display screen - coming soon")} </p>
    </div>
  </div>
}

// Expose to window for HTM usage
let expose = () => {
  Preact.setWindowProperty("Display", make)
}
