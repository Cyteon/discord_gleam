import discord_gleam/discord/snowflake.{type Snowflake}
import gleam/dynamic/decode
import gleam/io
import gleam/json
import gleam/result
import logging

pub type InteractionOption {
  InteractionOption(name: String, type_: Int, description: String)
}

pub type InteractionUser {
  InteractionUser(username: String, id: Snowflake)
}

pub type InteractionCreateMember {
  InteractionCreateMember(user: InteractionUser)
}

pub type InteractionCommand {
  InteractionCommand(type_: Int, name: String, id: Snowflake)
}

pub type InteractionCreateData {
  InteractionCreateData(
    token: String,
    member: InteractionCreateMember,
    id: Snowflake,
    guild_id: Snowflake,
    data: InteractionCommand,
    channel_id: Snowflake,
  )
}

pub type InteractionCreate {
  InteractionCreate(t: String, s: Int, op: Int, d: InteractionCreateData)
}

//decode.string)//
pub fn string_to_data(encoded: String) -> Result(InteractionCreate, String) {
  let decoder = {
    use t <- decode.field("t", decode.string)
    use s <- decode.field("s", decode.int)
    use op <- decode.field("op", decode.int)
    use d <- decode.field("d", {
      use token <- decode.field("token", decode.string)
      use member <- decode.field("member", {
        use user <- decode.field("user", {
          use username <- decode.field("username", decode.string)
          use id <- decode.field("id", snowflake.decoder())
          decode.success(InteractionUser(username:, id:))
        })
        decode.success(InteractionCreateMember(user:))
      })
      use id <- decode.field("id", snowflake.decoder())
      use guild_id <- decode.field("guild_id", snowflake.decoder())
      use data <- decode.field("data", {
        use type_ <- decode.field("type", decode.int)
        use name <- decode.field("name", decode.string)
        use id <- decode.field("id", snowflake.decoder())
        decode.success(InteractionCommand(type_:, name:, id:))
      })
      use channel_id <- decode.field("channel_id", snowflake.decoder())
      decode.success(InteractionCreateData(
        token:,
        member:,
        id:,
        guild_id:,
        data:,
        channel_id:,
      ))
    })
    decode.success(InteractionCreate(t:, s:, op:, d:))
  }

  json.parse(from: encoded, using: decoder)
  |> result.map_error(fn(err) {
    logging.log(logging.Error, "Failed to decode InteractionCreate: ")
    io.debug(err)
    "Failed to decode InteractionCreate"
  })
}
