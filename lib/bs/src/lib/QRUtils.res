// QRUtils.res - QR Code generation utility

// Generate QR code as data URL
let generateQRCode = async (text: string, ~options: option<QRCode.options>=?): string => {
  if !QRCode.isQRCodeAvailable() {
    Err.throw("QRCode library is not loaded")
  }

  await QRCode.generateQRCode(text, ~options?)
}

// Download QR code as PNG
let downloadQRCode = (dataUrl: string, ~filename: string="qrcode.png"): unit => {
  let link = Browser.Document.createElement("a")
  link->Browser.Element.setDownload(filename)
  link->Browser.Element.setHref(dataUrl)
  Browser.Document.appendChild(link)
  link->Browser.Element.click
  Browser.Document.removeChild(link)
}

// Generate customer queue URL
let generateCustomerURL = (storeId: string): string => {
  let baseUrl = Browser.Location.origin ++ Browser.Location.pathname
  `${baseUrl}#/q/${storeId}`
}

// Generate admin URL
let generateAdminURL = (adminId: string): string => {
  let baseUrl = Browser.Location.origin ++ Browser.Location.pathname
  `${baseUrl}#/admin/${adminId}`
}

// Generate display URL
let generateDisplayURL = (storeId: string): string => {
  let baseUrl = Browser.Location.origin ++ Browser.Location.pathname
  `${baseUrl}#/display/${storeId}`
}

// Export for browser global access
let expose = (): unit => {
  Preact.setWindowProperty(
    "QRUtils",
    {
      "generateQRCode": generateQRCode,
      "downloadQRCode": downloadQRCode,
      "generateCustomerURL": generateCustomerURL,
      "generateAdminURL": generateAdminURL,
      "generateDisplayURL": generateDisplayURL,
    },
  )
}
