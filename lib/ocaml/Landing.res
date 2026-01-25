// Landing.res - Create queue page with store name input, PoW, QR code generation

// Created store info
type createdStore = {
  storeId: string,
  adminId: string,
  store: Types.store,
  customerUrl: string,
  adminUrl: string,
}

// Validate store name
let validateStoreName = (name: string): option<string> => {
  let trimmed = name->String.trim
  if trimmed->String.length < 1 {
    Some("Store name is required")
  } else if trimmed->String.length > 50 {
    Some("Store name must be 50 characters or less")
  } else if %re("/<script|javascript:|on\w+=/i")->RegExp.test(trimmed) {
    Some("Invalid characters in store name")
  } else {
    None
  }
}

// Loading animation component
module LoadingAnimation = {
  @react.component
  let make = () => {
    <div className="loading-animation" dataTestId="loading-animation">
      <div className="spinner-container">
        <div className="ticket-spinner">
          <div className="ticket-front"> {React.string("🎫")} </div>
        </div>
      </div>
      <p className="loading-text"> {React.string("Creating your queue...")} </p>
      <p className="loading-subtext">
        {React.string("Generating secure keys (this takes a few seconds)")}
      </p>
    </div>
  }
}

@react.component
let make = () => {
  let (storeName, setStoreName) = React.useState(() => "")
  let (error, setError) = React.useState(() => None)
  let (isLoading, setIsLoading) = React.useState(() => false)
  let (createdStore, setCreatedStore) = React.useState(() => None)
  let (qrCodeUrl, setQrCodeUrl) = React.useState(() => "")

  // Handle store creation
  let handleCreateStore = async (e: ReactEvent.Form.t) => {
    ReactEvent.Form.preventDefault(e)

    // Validate
    switch validateStoreName(storeName) {
    | Some(validationError) => setError(_ => Some(validationError))
    | None => {
        setError(_ => None)
        setIsLoading(_ => true)

        try {
          // Initialize Gun
          let _ = GunHelpers.initGun()

          // Generate keypair (includes PoW - takes ~2-3 seconds)
          let _ = await Pow.generateKeyPair()

          // Create the store
          let result = await GunHelpers.createStore(storeName->String.trim)

          // Generate QR code for customer URL
          let customerUrl = QRUtils.generateCustomerURL(result.storeId)
          let qrDataUrl = await QRUtils.generateQRCode(customerUrl)

          setQrCodeUrl(_ => qrDataUrl)
          setCreatedStore(_ => Some({
            storeId: result.storeId,
            adminId: result.adminId,
            store: result.store,
            customerUrl: customerUrl,
            adminUrl: QRUtils.generateAdminURL(result.adminId),
          }))
        } catch {
        | JsExn(err) => {
            Browser.Console.error(err)
            let msg = JsExn.message(err)->Option.getOr("Failed to create queue. Please try again.")
            setError(_ => Some(msg))
          }
        }

        setIsLoading(_ => false)
      }
    }
  }

  // Handle QR code download
  let handleDownloadQR = (_e: ReactEvent.Mouse.t) => {
    switch createdStore {
    | Some(cs) => {
        let safeName = cs.store.name->String.replaceRegExp(%re("/[^a-zA-Z0-9]/g"), "-")
        QRUtils.downloadQRCode(qrCodeUrl, ~filename=`${safeName}-qrcode.png`)
      }
    | None => ()
    }
  }

  // Handle copy admin URL
  let copyAdminUrl = (_e: ReactEvent.Mouse.t) => {
    switch createdStore {
    | Some(cs) =>
      Browser.Clipboard.writeText(cs.adminUrl)->Promise.catch(_ => {
        Browser.Console.error("Failed to copy")
        Promise.resolve()
      })->ignore
    | None => ()
    }
  }

  // Success screen - show QR code and admin URL
  switch createdStore {
  | Some(cs) =>
    <div className="page" dataTestId="landing-page" id={`store-${cs.storeId}`}>
      <div className="page-header">
        <h1 className="page-title"> {React.string("🎉 Queue Created!")} </h1>
        <p className="page-subtitle"> {React.string(cs.store.name)} </p>
      </div>
      <div className="container">
        // Hidden element with customer URL for testing
        <input type_="hidden" dataTestId="customer-url" value={cs.customerUrl} />
        <div className="qr-section" dataTestId="qr-section">
          <h2> {React.string("Customer QR Code")} </h2>
          <p className="text-muted">
            {React.string("Print this and display at your counter")}
          </p>
          <div className="customer-url-container mt-2 mb-2">
            <a 
              href={cs.customerUrl} 
              target="_blank" 
              className="customer-url-link"
              dataTestId="customer-url-link">
              {React.string("🔗 Open Queue Page")}
            </a>
          </div>
          <div className="qr-code-container">
            <img
              src=qrCodeUrl
              alt="Queue QR Code"
              className="qr-code-image"
              dataTestId="qr-code"
            />
          </div>
          <button
            className="btn btn-primary mt-2"
            onClick=handleDownloadQR
            dataTestId="download-qr">
            {React.string("📥 Download QR Code")}
          </button>
        </div>
        <div className="admin-section mt-4">
          <h2> {React.string("Admin URL")} </h2>
          <p className="text-muted"> {React.string("Save this link to manage your queue")} </p>
          <div className="admin-url-container">
            <input
              type_="text"
              value={cs.adminUrl}
              readOnly=true
              className="admin-url-input"
              dataTestId="admin-url"
            />
            <button className="btn btn-secondary" onClick=copyAdminUrl dataTestId="copy-admin-url">
              {React.string("📋 Copy")}
            </button>
          </div>
          <p className="warning-text mt-2">
            {React.string("⚠️ Save this URL! It's the only way to access your admin panel.")}
          </p>
        </div>
        <div className="next-steps mt-4">
          <h3> {React.string("Next Steps")} </h3>
          <ol>
            <li> {React.string("Print the QR code and display it at your counter")} </li>
            <li> {React.string("Bookmark the admin URL to manage your queue")} </li>
            <li> {React.string("Customers scan the QR code to take a number")} </li>
          </ol>
        </div>
        <div className="actions mt-4">
          <a href={cs.adminUrl} className="btn btn-primary" dataTestId="go-to-admin">
            {React.string("Go to Admin Panel →")}
          </a>
        </div>
      </div>
    </div>

  | None =>
    // Main form
    <div className="page" dataTestId="landing-page">
      <div className="page-header">
        <h1 className="page-title"> {React.string("🎫 Take a Number")} </h1>
        <p className="page-subtitle">
          {React.string("Queue management for your store. No app needed.")}
        </p>
      </div>
      <div className="container">
        {isLoading
          ? <LoadingAnimation />
          : <form onSubmit={e => handleCreateStore(e)->ignore} className="create-form">
              <div className="form-group">
                <label htmlFor="storeName" className="form-label">
                  {React.string("Store Name")}
                </label>
                <input
                  type_="text"
                  id="storeName"
                  value=storeName
                  onInput={e => setStoreName(_ => ReactEvent.Form.target(e)["value"])}
                  placeholder="e.g., Joe's Bakery"
                  maxLength=50
                  className="form-input"
                  dataTestId="store-name-input"
                  disabled=isLoading
                />
                <p className="form-hint">
                  {React.string(`${Int.toString(storeName->String.length)}/50 characters`)}
                </p>
              </div>
              {switch error {
              | Some(msg) =>
                <div className="error-message" dataTestId="error-message">
                  {React.string(msg)}
                </div>
              | None => React.null
              }}
              <button
                type_="submit"
                className="btn btn-primary btn-full"
                disabled={isLoading || storeName->String.trim->String.length == 0}
                dataTestId="create-queue-btn">
                {React.string("Create My Queue")}
              </button>
            </form>}
        {isLoading
          ? React.null
          : <div className="features mt-4">
              <h3> {React.string("How it works")} </h3>
              <ul className="feature-list">
                <li> {React.string("✨ Create your queue in seconds")} </li>
                <li> {React.string("📱 Customers scan QR code to take a number")} </li>
                <li> {React.string("🔔 Real-time updates for everyone")} </li>
                <li> {React.string("🚫 No app download required")} </li>
              </ul>
            </div>}
      </div>
    </div>
  }
}

// Expose to window for HTM usage
let expose = () => {
  Preact.setWindowProperty("Landing", make)
}
