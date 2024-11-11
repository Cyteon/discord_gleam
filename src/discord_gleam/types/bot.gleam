import bravo/uset
import discord_gleam/discord/intents
import discord_gleam/discord/snowflake.{type Snowflake}
import discord_gleam/ws/packets/message.{type MessagePacketData}
import gleam/option

pub type Bot {
  Bot(token: String, intents: intents.Intents, cache: Cache)
}

pub type Cache {
  Cache(messages: option.Option(uset.USet(#(Snowflake, MessagePacketData))))
}
