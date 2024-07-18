import discord_gleam/discord/snowflake.{type Snowflake}
import discord_gleam/internal/error
import gleam/dynamic
import gleam/json
import gleam/option.{type Option}
import gleam/result
import gleam/string

/// User object containing PartialUser and FullUser
pub type User {
  PartialUser(
    id: Snowflake,
    username: String,
    discriminator: String,
    avatar: Option(String),
  )
  FullUser(
    id: Snowflake,
    username: String,
    discriminator: String,
    avatar: Option(String),
    bot: Bool,
    system: Bool,
    mfa_enabled: Bool,
    banner: Option(String),
    accent_color: Option(Int),
    verified: Bool,
    email: Option(String),
    flags: Int,
    premium_type: Int,
    public_flags: Int,
  )
}

/// Decode a string to a PartialUser
pub fn from_json_string(encoded: String) -> Result(User, error.DiscordError) {
  case string.contains(encoded, "401: Unauthorized") {
    True -> {
      Error(error.Unauthorized("Error, 401, Unauthorized :c, is token correct?"))
    }
    False -> {
      let decoder =
        dynamic.decode4(
          PartialUser,
          dynamic.field("id", of: snowflake.from_dynamic),
          dynamic.field("username", of: dynamic.string),
          dynamic.field("discriminator", of: dynamic.string),
          dynamic.field("avatar", of: dynamic.optional(dynamic.string)),
        )

      json.decode(from: encoded, using: decoder)
      |> result.map_error(error.InvalidJson)
    }
  }
}
