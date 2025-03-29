import discord_gleam/discord/snowflake.{type Snowflake}
import gleam/dynamic/decode
import gleam/json
import gleam/result

pub type ReadyUser {
  ReadyUser(username: String, id: Snowflake, discriminator: String, bot: Bool)
}

pub type ReadyData {
  ReadyData(v: Int, user: ReadyUser)
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
        use id <- decode.field("id", decode.string)
        //snowflake.from_dynamic),
        use discriminator <- decode.field("discriminator", decode.string)
        use bot <- decode.field("bot", decode.bool)
        decode.success(ReadyUser(username:, id:, discriminator:, bot:))
      })
      decode.success(ReadyData(v:, user:))
    })
    decode.success(ReadyPacket(t:, s:, op:, d:))
  }

  json.parse(from: encoded, using: decoder)
  |> result.map_error(fn(_) { "Failed to decode MessagePacket" })
}
