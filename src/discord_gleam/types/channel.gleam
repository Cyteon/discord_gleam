import discord_gleam/discord/snowflake.{type Snowflake}
import gleam/dynamic/decode
import gleam/json
import gleam/option

/// See https://discord.com/developers/docs/resources/channel#channel-object \
/// This is a simplified version of the channel object.
pub type Channel {
  Channel(
    id: Snowflake,
    type_: Int,
    position: option.Option(Int),
    guild_id: option.Option(Snowflake),
    name: option.Option(String),
    topic: option.Option(String),
    nsfw: option.Option(Bool),
    last_message_id: option.Option(Snowflake),
  )
}

/// Convert a JSON string to a channel object
pub fn string_to_data(encoded: String) -> Result(Channel, json.DecodeError) {
  let decoder = {
    use id <- decode.field("id", snowflake.decoder())
    use type_ <- decode.field("type", decode.int)
    use position <- decode.optional_field(
      "position",
      option.None,
      decode.optional(decode.int),
    )
    use guild_id <- decode.optional_field(
      "guild_id",
      option.None,
      decode.optional(snowflake.decoder()),
    )
    use name <- decode.optional_field(
      "name",
      option.None,
      decode.optional(decode.string),
    )
    use topic <- decode.optional_field(
      "topic",
      option.None,
      decode.optional(decode.string),
    )
    use nsfw <- decode.optional_field(
      "nsfw",
      option.None,
      decode.optional(decode.bool),
    )
    use last_message_id <- decode.optional_field(
      "last_message_id",
      option.None,
      decode.optional(snowflake.decoder()),
    )

    decode.success(Channel(
      id:,
      type_:,
      position:,
      guild_id:,
      name:,
      topic:,
      nsfw:,
      last_message_id:,
    ))
  }

  json.parse(from: encoded, using: decoder)
}
