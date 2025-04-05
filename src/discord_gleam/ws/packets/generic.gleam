import gleam/dynamic/decode
import gleam/json

pub type GenericPacket {
  GenericPacket(t: String, s: Int, op: Int)
}

pub fn string_to_data(encoded: String) -> GenericPacket {
  let decoder = {
    use t <- decode.field("t", decode.string)
    use s <- decode.field("s", decode.int)
    use op <- decode.field("op", decode.int)
    decode.success(GenericPacket(t:, s:, op:))
  }

  let data = json.parse(from: encoded, using: decoder)

  case data {
    Ok(decoded) -> decoded
    Error(_) -> GenericPacket("error", 0, 0)
  }
}
