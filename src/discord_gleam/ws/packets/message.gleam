import gleam/dynamic
import gleam/json
import gleam/result

pub type MessageAuthor {
  MessageAuthor(id: String, username: String)
}

pub type MessagePacketData {
  MessagePacketData(
    content: String,
    guild_id: String,
    channel_id: String,
    author: MessageAuthor,
  )
}

pub type MessagePacket {
  MessagePacket(t: String, s: Int, op: Int, d: MessagePacketData)
}

pub fn string_to_data(encoded: String) -> Result(MessagePacket, String) {
  let decoder =
    dynamic.decode4(
      MessagePacket,
      dynamic.field("t", of: dynamic.string),
      dynamic.field("s", of: dynamic.int),
      dynamic.field("op", of: dynamic.int),
      dynamic.field(
        "d",
        of: dynamic.decode4(
          MessagePacketData,
          dynamic.field("content", of: dynamic.string),
          dynamic.field("channel_id", of: dynamic.string),
          dynamic.field("guild_id", of: dynamic.string),
          dynamic.field(
            "author",
            of: dynamic.decode2(
              MessageAuthor,
              dynamic.field("id", of: dynamic.string),
              dynamic.field("username", of: dynamic.string),
            ),
          ),
        ),
      ),
    )

  json.decode(from: encoded, using: decoder)
  |> result.map_error(fn(_) { "Failed to decode MessagePacket" })
}
