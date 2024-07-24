import discord_gleam/discord/snowflake.{type Snowflake}
import gleam/dynamic
import gleam/json
import gleam/result

pub type MessageAuthor {
  MessageAuthor(id: Snowflake, username: String)
}

pub type MessagePacketData {
  MessagePacketData(
    content: String,
    id: String,
    guild_id: Snowflake,
    channel_id: Snowflake,
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
        of: dynamic.decode5(
          MessagePacketData,
          dynamic.field("content", of: dynamic.string),
          dynamic.field("id", of: snowflake.from_dynamic),
          dynamic.field("guild_id", of: snowflake.from_dynamic),
          dynamic.field("channel_id", of: snowflake.from_dynamic),
          dynamic.field(
            "author",
            of: dynamic.decode2(
              MessageAuthor,
              dynamic.field("id", of: snowflake.from_dynamic),
              dynamic.field("username", of: dynamic.string),
            ),
          ),
        ),
      ),
    )

  json.decode(from: encoded, using: decoder)
  |> result.map_error(fn(_) { "Failed to decode MessagePacket" })
}
