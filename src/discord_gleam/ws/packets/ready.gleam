import gleam/dynamic
import gleam/json
import gleam/result
import logging

pub type ReadyUser {
  ReadyUser(username: String, id: String, discriminator: String, bot: Bool)
}

pub type ReadyData {
  ReadyData(v: Int, user: ReadyUser)
}

pub type ReadyPacket {
  ReadyPacket(t: String, s: Int, op: Int, d: ReadyData)
}

pub fn string_to_data(encoded: String) -> Result(ReadyPacket, String) {
  let decoder =
    dynamic.decode4(
      ReadyPacket,
      dynamic.field("t", of: dynamic.string),
      dynamic.field("s", of: dynamic.int),
      dynamic.field("op", of: dynamic.int),
      dynamic.field(
        "d",
        of: dynamic.decode2(
          ReadyData,
          dynamic.field("v", of: dynamic.int),
          dynamic.field(
            "user",
            of: dynamic.decode4(
              ReadyUser,
              dynamic.field("username", of: dynamic.string),
              dynamic.field("id", of: dynamic.string),
              dynamic.field("discriminator", of: dynamic.string),
              dynamic.field("bot", of: dynamic.bool),
            ),
          ),
        ),
      ),
    )

  json.decode(from: encoded, using: decoder)
  |> result.map_error(fn(_) { "Failed to decode MessagePacket" })
}
