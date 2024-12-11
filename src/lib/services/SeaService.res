type keyPair = {
  pub: string,
  priv: string,
  epub: string,
  epriv: string,
}

// Get SEA directly
@module("gun/sea") external sea: {..} = "default"

// Get methods directly from SEA object
@module("gun/sea") external createPair: unit => promise<keyPair> = "pair"

// Use SEA.work for signing and verification
@module("gun/sea") external work: (string, string) => promise<Js.Nullable.t<string>> = "work"

let generateKeyPair = () => createPair()

let signData = (~data: string, ~privateKey: string) => {
  work(data, privateKey)->Promise.then(signed =>
    switch Js.Nullable.toOption(signed) {
    | None => Promise.resolve("")
    | Some(s) => Promise.resolve(s)
    }
  )
}

let verifyData = (~signedData: string, ~publicKey: string) => {
  work(signedData, publicKey)
}
