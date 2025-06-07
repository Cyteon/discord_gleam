import discord_gleam
import discord_gleam/discord/intents
import discord_gleam/event_handler
import discord_gleam/types/message
import gleam/list
import gleam/string
import logging

pub fn main() {
  logging.configure()
  logging.set_level(logging.Info)

  let bot = discord_gleam.bot("TOKEN", "CLIENT ID", intents.default())

  discord_gleam.run(bot, [event_handler])
}

fn event_handler(bot, packet: event_handler.Packet) {
  case packet {
    event_handler.ReadyPacket(ready) -> {
      logging.log(logging.Info, "Logged in as " <> ready.d.user.username)

      Nil
    }
    event_handler.MessagePacket(message) -> {
      logging.log(logging.Info, "Message: " <> message.d.content)

      case string.starts_with(message.d.content, "!delete") {
        True -> {
          let args = string.split(message.d.content, " ")
          let args = list.drop(args, 1)

          let reason = string.join(args, " ")

          discord_gleam.delete_message(
            bot,
            message.d.channel_id,
            message.d.id,
            reason,
          )

          Nil
        }
        False -> Nil
      }
    }
    _ -> Nil
  }
}
