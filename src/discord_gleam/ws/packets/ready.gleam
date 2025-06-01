import discord_gleam/discord/snowflake.{type Snowflake}
import gleam/dynamic/decode
import gleam/json
import gleam/result

pub type ReadyUser {
  ReadyUser(username: String, id: Snowflake, discriminator: String, bot: Bool)
}

pub type ReadyData {
  ReadyData(
    v: Int,
    user: ReadyUser,
    session_id: String,
    resume_gateway_url: String,
  )
}

pub type ReadyPacket {
  ReadyPacket(t: String, s: Int, op: Int, d: ReadyData)
}

pub fn string_to_data(encoded: String) -> Result(ReadyPacket, String) {
  let decoder = {
    use t <- decode.field("t", decode.string)
    use s <- decode.field("s", decode.int)
    use op <- decode.field("op", decode.int)

    use d <- decode.field("d", {
      use v <- decode.field("v", decode.int)

      use user <- decode.field("user", {
        use username <- decode.field("username", decode.string)
        use id <- decode.field("id", snowflake.decoder())
        use discriminator <- decode.field("discriminator", decode.string)
        use bot <- decode.field("bot", decode.bool)
        decode.success(ReadyUser(username:, id:, discriminator:, bot:))
      })

      use session_id <- decode.field("session_id", decode.string)
      use resume_gateway_url <- decode.field(
        "resume_gateway_url",
        decode.string,
      )

      decode.success(ReadyData(v:, user:, session_id:, resume_gateway_url:))
    })

    decode.success(ReadyPacket(t:, s:, op:, d:))
  }

  json.parse(from: encoded, using: decoder)
  |> result.map_error(fn(_) { "Failed to decode MessagePacket" })
}
