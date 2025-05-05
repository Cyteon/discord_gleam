import bravo/uset
import discord_gleam
import discord_gleam/discord/intents
import discord_gleam/event_handler
import discord_gleam/types/bot
import discord_gleam/types/message
import discord_gleam/types/slash_command
import gleam/option.{Some}
import gleam/string
import logging

pub fn main(token: String, client_id: String, guild_id: String) {
  logging.configure()
  logging.set_level(logging.Info)

  let bot =
    discord_gleam.bot(
      token,
      client_id,
      intents.default_intents(),
    )

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

  discord_gleam.wipe_global_commands(bot)
  discord_gleam.register_global_commands(bot, [test_cmd])

  discord_gleam.wipe_guild_commands(bot, guild_id)
  discord_gleam.register_guild_commands(bot, guild_id, [test_cmd2])

  discord_gleam.run(bot, [event_handler])
}

fn event_handler(bot: bot.Bot, packet: event_handler.Packet) {
  case packet {
    event_handler.ReadyPacket(ready) -> {
      logging.log(logging.Info, "Logged in as " <> ready.d.user.username)

      Nil
    }
    event_handler.MessagePacket(message) -> {
      logging.log(logging.Info, "Message: " <> message.d.content)
      case message.d.author.id != bot.client_id {
        True -> {
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
            "hello" -> {
              discord_gleam.reply(
                bot,
                message.d.channel_id,
                message.d.id,
                "hello",
                [],
              )
            }
            _ -> Nil
          }
        }
        False -> Nil
      }

      case message.d.content, message.d.guild_id {
        "!kick " <> args, Some(guild_id) -> {
          let args = string.split(args, " ")
          let #(user, args) = case args {
            [user, ..args] -> #(user, args)
            _ -> #("", [])
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
      case message.d.content, message.d.guild_id {
        "!ban " <> args, Some(guild_id) -> {
          let args = string.split(args, " ")
          let #(user, args) = case args {
            [user, ..args] -> #(user, args)
            _ -> #("", [])
          }

          let user = string.replace(user, "<@", "")
          let user = string.replace(user, ">", "")

          let reason = string.join(args, " ")

          let resp = discord_gleam.ban_member(bot, guild_id, user, reason)

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
        _, _ -> Nil
      }
    }
    event_handler.MessageDeletePacket(deleted) -> {
      logging.log(logging.Info, "Deleted message: " <> deleted.d.id)

      case bot.cache.messages {
        option.Some(cache) -> {
          let msg = uset.lookup(cache, deleted.d.id)

          case msg {
            Ok(msg) -> {
              logging.log(
                logging.Info,
                "Message content: " <> { msg.1 }.content,
              )
            }
            Error(_) -> {
              logging.log(logging.Info, "Deleted message not found")
            }
          }

          Nil
        }
        option.None -> Nil
      }
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
