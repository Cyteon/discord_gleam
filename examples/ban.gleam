import discord_gleam
import discord_gleam/discord/intents
import discord_gleam/event_handler
import discord_gleam/types/message
import gleam/list
import gleam/string
import gleam/io
import gleam/option
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

      case string.starts_with(message.d.content, "!ban ") {
        True -> {
          let args = string.split(message.d.content, " ")

          let args = list.drop(args, 1)

          let user = case list.first(args) {
            Ok(x) -> x
            Error(_) -> ""
          }

          let args = list.drop(args, 1)

          let user = string.replace(user, "<@", "")
          let user = string.replace(user, ">", "")

          let reason = string.join(args, " ")

          case message.d.guild_id {
            option.Some(id) -> {
              let resp =
                discord_gleam.ban_member(bot, id, user, reason)

              case resp {
                Ok(_) -> {
                  discord_gleam.send_message(
                    bot,
                    message.d.channel_id,
                    "Banned user!",
                    [],
                  )

                  Nil
                }

                Error(err) -> {
                  discord_gleam.send_message(
                    bot,
                    message.d.channel_id,
                    "Failed to ban user!",
                    [],
                  )

                  io.debug(err)

                  Nil
                }
              }
            }

            option.None -> {
              discord_gleam.send_message(
                bot,
                message.d.channel_id,
                "This command can only be used in a guild!",
                [],
              )

              Nil
            }
          }

          Nil
        }

        False -> Nil
      }
    }
    _ -> Nil
  }
}
