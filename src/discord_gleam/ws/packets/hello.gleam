import gleam/dynamic
import gleam/json

pub type HelloPacketData {
  HelloPacketData(heartbeat_interval: Int)
}

pub type HelloPacket {
  HelloPacket(op: Int, d: HelloPacketData)
}

pub fn string_to_data(encoded: String) -> Int {
  let decoder =
    dynamic.decode2(
      HelloPacket,
      dynamic.field("op", of: dynamic.int),
      dynamic.field(
        "d",
        of: dynamic.decode1(
          HelloPacketData,
          dynamic.field("heartbeat_interval", of: dynamic.int),
        ),
      ),
    )

  let data = json.decode(from: encoded, using: decoder)

  case data {
    Ok(decoded) -> decoded.d.heartbeat_interval
    Error(_) -> 0
  }
}
