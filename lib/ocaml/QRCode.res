// QRCode.res - QRCode library bindings

// QR code color options
type colorOptions = {
  dark: string,
  light: string,
}

// QR code options
type options = {
  width: int,
  height: int,
  margin: int,
  color: colorOptions,
  errorCorrectionLevel: string,
}

// Default options
let defaultOptions: options = {
  width: 256,
  height: 256,
  margin: 2,
  color: {
    dark: "#212121",
    light: "#FFFFFF",
  },
  errorCorrectionLevel: "M",
}

// Check if QRCode is available
@val @scope("window") @return(nullable)
external qrCodeAvailable: option<'a> = "QRCode"

let isQRCodeAvailable = (): bool => {
  qrCodeAvailable->Option.isSome
}

// Generate QR code to data URL (callback style)
@val @scope(("window", "QRCode"))
external toDataURL: (string, options, (Nullable.t<exn>, string) => unit) => unit = "toDataURL"

// Note: toCanvas binding removed since we only use toDataURL

// Promise wrapper for toDataURL
let generateQRCode = (text: string, ~options: option<options>=?): promise<string> => {
  let opts = options->Option.getOr(defaultOptions)
  Promise.make((resolve, reject) => {
    toDataURL(text, opts, (error, url) => {
      switch Nullable.toOption(error) {
      | Some(err) => reject(err)
      | None => resolve(url)
      }
    })
  })
}
