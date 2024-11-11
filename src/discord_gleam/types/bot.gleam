import discord_gleam/discord/snowflake.{type Snowflake}
import discord_gleam/ws/packets/message .{type MessagePacketData}
import bravo/uset
import gleam/option


pub type Bot {
  Bot(
    token: String,
    cache: Cache,
  )
}

pub type Cache {
  Cache(
    messages: option.Option(uset.USet(#(Snowflake, MessagePacketData))),
  )
}
