// Types.res - Shared type definitions

// Ticket status - encoded as variant instead of strings
type ticketStatus =
  | Waiting
  | Served
  | Expired
  | Discarded

// Convert status to/from GunDB string representation
let ticketStatusToString = status =>
  switch status {
  | Waiting => "waiting"
  | Served => "served"
  | Expired => "expired"
  | Discarded => "discarded"
  }

let ticketStatusFromString = str =>
  switch str {
  | "waiting" => Some(Waiting)
  | "served" => Some(Served)
  | "expired" => Some(Expired)
  | "discarded" => Some(Discarded)
  | _ => None
  }

// Served by type
type servedBy =
  | Self
  | Operator

let servedByToString = servedBy =>
  switch servedBy {
  | Self => "self"
  | Operator => "operator"
  }

let servedByFromString = str =>
  switch str {
  | "self" => Some(Self)
  | "operator" => Some(Operator)
  | _ => None
  }

// Store settings
type storeSettings = {
  expiryHours: int,
  expiryAfterServed: int,
}

// Store data as stored in GunDB
type store = {
  id: string,
  name: string,
  createdAt: float,
  adminId: string,
  settings: storeSettings,
  currentNumber: int,
  nowServing: int,
  servedToday: int,
  servedLastHour: int,
  version: string,
}

// Ticket data
type ticket = {
  number: int,
  deviceId: string,
  issuedAt: float,
  status: string, // Stored as string in GunDB
  servedAt: Nullable.t<float>,
  servedBy: Nullable.t<string>,
}

// Parse ticket status from raw ticket
let getTicketStatus = (ticket: ticket): ticketStatus =>
  switch ticketStatusFromString(ticket.status) {
  | Some(status) => status
  | None => Waiting
  }

// Create store result
type createStoreResult = {
  storeId: string,
  adminId: string,
  store: store,
}

// SEA keypair
type keypair = {
  pub: string,
  priv: string,
  epub: string,
  epriv: string,
}
