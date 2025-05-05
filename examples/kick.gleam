import discord_gleam
import discord_gleam/discord/intents
import discord_gleam/event_handler
import discord_gleam/types/message
import gleam/list
import gleam/option.{Some}
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
    event_handler.ReadyPacket(ready) -> {
      logging.log(logging.Info, "Logged in as " <> ready.d.user.username)

      Nil
    }
    event_handler.MessagePacket(message) -> {
      logging.log(logging.Info, "Message: " <> message.d.content)

      case string.starts_with(message.d.content, "!kick "), message.d.guild_id {
        True, Some(guild_id) -> {
          let args = string.split(message.d.content, " ")

          let args = case list.pop(args, fn(x) { x == "!kick" }) {
            Ok(args) -> args.1
            Error(_) -> [""]
          }

          let user = case list.first(args) {
            Ok(x) -> x
            Error(_) -> ""
          }

          let args = case list.pop(args, fn(x) { x == user }) {
            Ok(args) -> args.1
            Error(_) -> [""]
          }

          let user = string.replace(user, "<@", "")
          let user = string.replace(user, ">", "")

          let reason = string.join(args, " ")

          let resp = discord_gleam.kick_member(bot, guild_id, user, reason)

          case resp.0 {
            "OK" -> {
              discord_gleam.send_message(
                bot,
                message.d.channel_id,
                "Kicked user!",
                [],
              )
            }
            _ -> {
              discord_gleam.send_message(
                bot,
                message.d.channel_id,
                "Failed to kick user!",
                [],
              )
            }
          }
        }
        _, _ -> Nil
      }
    }
    _ -> Nil
  }
}
