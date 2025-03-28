import discord_gleam/discord/snowflake.{type Snowflake}
import gleam/dynamic
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

pub fn string_to_data(encoded: String) -> Result(InteractionCreate, String) {
  let decoder =
    dynamic.decode4(
      InteractionCreate,
      dynamic.field("t", of: dynamic.string),
      dynamic.field("s", of: dynamic.int),
      dynamic.field("op", of: dynamic.int),
      dynamic.field(
        "d",
        of: dynamic.decode6(
          InteractionCreateData,
          dynamic.field("token", of: dynamic.string),
          dynamic.field(
            "member",
            of: dynamic.decode1(
              InteractionCreateMember,
              dynamic.field(
                "user",
                of: dynamic.decode2(
                  InteractionUser,
                  dynamic.field("username", of: dynamic.string),
                  dynamic.field("id", of: snowflake.from_dynamic),
                ),
              ),
            ),
          ),
          dynamic.field("id", of: snowflake.from_dynamic),
          dynamic.field("guild_id", of: snowflake.from_dynamic),
          dynamic.field(
            "data",
            of: dynamic.decode3(
              InteractionCommand,
              dynamic.field("type", of: dynamic.int),
              dynamic.field("name", of: dynamic.string),
              dynamic.field("id", of: snowflake.from_dynamic),
            ),
          ),
          dynamic.field("channel_id", of: snowflake.from_dynamic),
        ),
      ),
    )

  json.decode(from: encoded, using: decoder)
  |> result.map_error(fn(err) {
    logging.log(logging.Error, "Failed to decode InteractionCreate: ")
    io.debug(err)
    "Failed to decode InteractionCreate"
  })
}
