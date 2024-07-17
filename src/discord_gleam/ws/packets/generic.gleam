import gleam/dynamic
import gleam/json

pub type GenericPacket {
  GenericPacket(t: String, s: Int, op: Int)
}

pub fn string_to_data(encoded: String) -> GenericPacket {
  let decoder =
    dynamic.decode3(
      GenericPacket,
      dynamic.field("t", of: dynamic.string),
      dynamic.field("s", of: dynamic.int),
      dynamic.field("op", of: dynamic.int),
    )

  let data = json.decode(from: encoded, using: decoder)

  case data {
    Ok(decoded) -> decoded
    Error(_) -> GenericPacket("error", 0, 0)
  }
}
