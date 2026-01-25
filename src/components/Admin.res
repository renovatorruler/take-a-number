// Admin.res - Operator admin panel

@react.component
let make = (~adminId: string) => {
  <div className="page" dataTestId="admin-page">
    <div className="page-header">
      <h1 className="page-title"> {React.string("Admin Panel")} </h1>
      <p className="page-subtitle"> {React.string(`Admin: ${adminId}`)} </p>
    </div>
    <div className="container">
      <p className="text-center"> {React.string("Admin panel - coming soon")} </p>
    </div>
  </div>
}

// Expose to window for HTM usage
let expose = () => {
  Preact.setWindowProperty("Admin", make)
}
