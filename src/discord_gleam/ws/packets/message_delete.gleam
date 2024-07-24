import discord_gleam/discord/snowflake.{type Snowflake}
import gleam/dynamic
import gleam/json
import gleam/result

pub type MessageDeletePacketData {
  MessageDeletePacketData(
    id: Snowflake,
    guild_id: Snowflake,
    channel_id: Snowflake,
  )
}

pub type MessageDeletePacket {
  MessageDeletePacket(t: String, s: Int, op: Int, d: MessageDeletePacketData)
}

pub fn string_to_data(encoded: String) -> Result(MessageDeletePacket, String) {
  let decoder =
    dynamic.decode4(
      MessageDeletePacket,
      dynamic.field("t", of: dynamic.string),
      dynamic.field("s", of: dynamic.int),
      dynamic.field("op", of: dynamic.int),
      dynamic.field(
        "d",
        of: dynamic.decode3(
          MessageDeletePacketData,
          dynamic.field("id", of: snowflake.from_dynamic),
          dynamic.field("guild_id", of: snowflake.from_dynamic),
          dynamic.field("channel_id", of: snowflake.from_dynamic),
        ),
      ),
    )

  json.decode(from: encoded, using: decoder)
  |> result.map_error(fn(_) { "Failed to decode MessagePacket" })
}
