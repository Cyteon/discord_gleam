import discord_gleam
import discord_gleam/event_handler
import discord_gleam/types/message
import discord_gleam/discord/intents
import gleam/list
import gleam/string
import logging

pub fn main() {
  logging.configure()
  logging.set_level(logging.Info)

  let bot =
    discord_gleam.bot(
      "YOUR TOKEN",
      "YOUR CLIENT ID",
      intents.Intents(message_content: True, guild_messages: True),
    )

  discord_gleam.run(bot, [event_handler])
}

fn event_handler(bot, packet: event_handler.Packet) {
  case packet {
    event_handler.MessagePacket(message) -> {
      logging.log(logging.Info, "Message: " <> message.d.content)
      case message.d.content {
        "!ping" -> {
          discord_gleam.send_message(bot, message.d.channel_id, "Pong!", [])
        }
        _ -> Nil
      }
    }
    _ -> Nil
  }
}
