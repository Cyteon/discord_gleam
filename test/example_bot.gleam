import discord_gleam
import discord_gleam/event_handler
import discord_gleam/types/message
import discord_gleam/types/slash_command
import gleam/list
import gleam/string
import logging

pub fn main(token: String, client_id: String, guild_id: String) {
  logging.configure()
  logging.set_level(logging.Debug)

  let bot = discord_gleam.bot(token)

  let test_cmd =
    slash_command.SlashCommand(
      name: "test",
      type_: 1,
      description: "Test command",
      options: [
        slash_command.CommandOption(
          name: "test",
          description: "Test option",
          type_: 3,
          required: False,
        ),
      ],
    )

  let test_cmd2 =
    slash_command.SlashCommand(
      name: "test2",
      type_: 1,
      description: "Test command",
      options: [
        slash_command.CommandOption(
          name: "test",
          description: "Test option",
          type_: 3,
          required: False,
        ),
      ],
    )

  discord_gleam.wipe_global_commands(bot, client_id)
  discord_gleam.register_global_commands(bot, client_id, [test_cmd])

  discord_gleam.wipe_guild_commands(bot, client_id, guild_id)
  discord_gleam.register_guild_commands(bot, client_id, guild_id, [test_cmd2])

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
      case message.d.content {
        "!ping" -> {
          discord_gleam.send_message(bot, message.d.channel_id, "Pong!", [])
        }
        "!embed" -> {
          let embed1 =
            message.Embed(
              title: "Embed Title",
              description: "Embed Description",
              color: 0x00FF00,
            )

          discord_gleam.send_message(bot, message.d.channel_id, "Embed!", [
            embed1,
          ])
        }
        "!reply" -> {
          discord_gleam.reply(
            bot,
            message.d.channel_id,
            message.d.id,
            "Reply!",
            [],
          )
        }
        _ -> Nil
      }

      case string.starts_with(message.d.content, "!kick ") {
        True -> {
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

          let resp =
            discord_gleam.kick_member(bot, message.d.guild_id, user, reason)

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
        False -> Nil
      }
      case string.starts_with(message.d.content, "!ban ") {
        True -> {
          let args = string.split(message.d.content, " ")

          let args = case list.pop(args, fn(x) { x == "!ban" }) {
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

          let resp =
            discord_gleam.ban_member(bot, message.d.guild_id, user, reason)

          case resp.0 {
            "OK" -> {
              discord_gleam.send_message(
                bot,
                message.d.channel_id,
                "Banned user!",
                [],
              )
            }
            _ -> {
              discord_gleam.send_message(
                bot,
                message.d.channel_id,
                "Failed to ban user!",
                [],
              )
            }
          }
        }
        False -> Nil
      }
    }
    event_handler.MessageDeletePacket(deleted) -> {
      logging.log(logging.Info, "Deleted message: " <> deleted.d.id)
      Nil
    }
    event_handler.InteractionCreate(interaction) -> {
      logging.log(logging.Info, "Interaction: " <> interaction.d.data.name)

      case interaction.d.data.name {
        "test" -> {
          discord_gleam.interaction_reply_message(interaction, "test", True)

          Nil
        }
        "test2" -> {
          discord_gleam.interaction_reply_message(interaction, "test2", False)

          Nil
        }
        _ -> Nil
      }
    }
    _ -> Nil
  }
}
