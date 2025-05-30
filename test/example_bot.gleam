import bravo/uset
import discord_gleam
import discord_gleam/discord/intents
import discord_gleam/event_handler
import discord_gleam/types/bot
import discord_gleam/types/message
import discord_gleam/types/slash_command
import discord_gleam/ws/packets/interaction_create
import gleam/bool
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import logging

pub fn main(token: String, client_id: String, guild_id: String) {
  logging.configure()
  logging.set_level(logging.Debug)

  let bot = discord_gleam.bot(token, client_id, intents.default())

  let test_cmd =
    slash_command.SlashCommand(
      name: "test",
      description: "Test command",
      options: [
        slash_command.CommandOption(
          name: "string",
          description: "Test option",
          type_: slash_command.StringOption,
          required: False,
        ),
        slash_command.CommandOption(
          name: "int",
          description: "Test option",
          type_: slash_command.IntOption,
          required: False,
        ),
      ],
    )

  let test_cmd2 =
    slash_command.SlashCommand(
      name: "test2",
      description: "Test command",
      options: [
        slash_command.CommandOption(
          name: "bool",
          description: "Test option",
          type_: slash_command.BoolOption,
          required: False,
        ),
        slash_command.CommandOption(
          name: "float",
          description: "Test option",
          type_: slash_command.FloatOption,
          required: False,
        ),
      ],
    )

  discord_gleam.wipe_global_commands(bot)
  discord_gleam.register_global_commands(bot, [test_cmd])

  discord_gleam.wipe_guild_commands(bot, guild_id)
  discord_gleam.register_guild_commands(bot, guild_id, [test_cmd2])

  discord_gleam.run(bot, [handler])
}

fn handler(bot: bot.Bot, packet: event_handler.Packet) {
  case packet {
    event_handler.ReadyPacket(ready) -> {
      logging.log(logging.Info, "Logged in as " <> ready.d.user.username)

      Nil
    }

    event_handler.MessagePacket(message) -> {
      logging.log(logging.Info, "Got message: " <> message.d.content)

      case message.d.author.id != bot.client_id {
        True -> {
          case message.d.content {
            "!ping" -> {
              discord_gleam.send_message(bot, message.d.channel_id, "Pong!", [])
            }

            "!dm_channel" -> {
              let res =
                discord_gleam.create_dm_channel(bot, message.d.author.id)

              let _ = io.debug(res)

              case res {
                Ok(channel) -> {
                  discord_gleam.send_message(
                    bot,
                    message.d.channel_id,
                    "ID: "
                      <> channel.id
                      <> "\nLast message ID: "
                      <> case channel.last_message_id {
                      Some(id) -> id
                      None -> "None"
                    },
                    [],
                  )
                }

                Error(err) -> {
                  discord_gleam.send_message(
                    bot,
                    message.d.channel_id,
                    "Failed to create DM channel!",
                    [],
                  )

                  io.debug(err)

                  Nil
                }
              }
            }

            "!dm" -> {
              let res =
                discord_gleam.send_direct_message(
                  bot,
                  message.d.author.id,
                  "DM!",
                  [],
                )

              case res {
                Ok(_) -> {
                  discord_gleam.send_message(
                    bot,
                    message.d.channel_id,
                    "DM sent!",
                    [],
                  )
                }

                Error(err) -> {
                  discord_gleam.send_message(
                    bot,
                    message.d.channel_id,
                    "Failed to send DM!",
                    [],
                  )

                  io.debug(err)

                  Nil
                }
              }
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
          case interaction.d.data.options {
            Some(options) -> {
              let value = case list.first(options) {
                Ok(option) ->
                  case option.value {
                    interaction_create.StringValue(value) -> value
                    interaction_create.IntValue(value) -> int.to_string(value)
                    interaction_create.BoolValue(value) -> bool.to_string(value)
                    interaction_create.FloatValue(value) ->
                      float.to_string(value)
                  }

                Error(_) -> "No value"
              }

              discord_gleam.interaction_reply_message(
                interaction,
                "test: " <> value,
                True,
                // ephemeral
              )
            }

            None -> {
              discord_gleam.interaction_reply_message(
                interaction,
                "test: No options",
                True,
              )
            }
          }

          Nil
        }

        "test2" -> {
          case interaction.d.data.options {
            Some(options) -> {
              let value = case list.last(options) {
                Ok(option) ->
                  case option.value {
                    interaction_create.StringValue(value) -> value
                    interaction_create.IntValue(value) -> int.to_string(value)
                    interaction_create.BoolValue(value) -> bool.to_string(value)
                    interaction_create.FloatValue(value) ->
                      float.to_string(value)
                  }

                Error(_) -> "No value"
              }

              discord_gleam.interaction_reply_message(
                interaction,
                "test2: " <> value,
                False,
                // not ephemeral
              )
            }

            None -> {
              discord_gleam.interaction_reply_message(
                interaction,
                "test2: No options",
                False,
              )
            }
          }

          Nil
        }

        _ -> Nil
      }
    }

    _ -> Nil
  }
}
