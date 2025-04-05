import discord_gleam/discord/snowflake.{type Snowflake}
import gleam/dynamic/decode
import gleam/json
import gleam/result

pub type MessageAuthor {
  MessageAuthor(id: Snowflake, username: String)
}

pub type MessagePacketData {
  MessagePacketData(
    content: String,
    id: Snowflake,
    guild_id: Snowflake,
    channel_id: Snowflake,
    author: MessageAuthor,
  )
}

pub type MessagePacket {
  MessagePacket(t: String, s: Int, op: Int, d: MessagePacketData)
}

pub fn string_to_data(encoded: String) -> Result(MessagePacket, String) {
  let decoder = {
    use t <- decode.field("t", decode.string)
    use s <- decode.field("s", decode.int)
    use op <- decode.field("op", decode.int)
    use d <- decode.field("d", {
      use content <- decode.field("content", decode.string)
      use id <- decode.field("id", snowflake.decoder())
      use guild_id <- decode.field("guild_id", snowflake.decoder())
      use channel_id <- decode.field("channel_id", snowflake.decoder())
      use author <- decode.field("author", {
        use id <- decode.field("id", snowflake.decoder())
        use username <- decode.field("username", decode.string)
        decode.success(MessageAuthor(id:, username:))
      })
      decode.success(MessagePacketData(
        content:,
        id:,
        guild_id:,
        channel_id:,
        author:,
      ))
    })
    decode.success(MessagePacket(t:, s:, op:, d:))
  }

  json.parse(from: encoded, using: decoder)
  |> result.map_error(fn(_) { "Failed to decode MessagePacket" })
}
