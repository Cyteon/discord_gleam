import discord_gleam
import discord_gleam/event_handler
import discord_gleam/types/message
import discord_gleam/types/slash_command
import discord_gleam/ws/packets/message_delete
import gleam/list
import gleam/string
import logging

pub fn main(token: String) {
  logging.configure()
  logging.set_level(logging.Info)

  let bot = discord_gleam.bot(token)

  let test_cmd =
    slash_command.SlashCommand(
      name: "ping",
      type_: 1,
      description: "returns pong",
      options: [
        slash_command.CommandOption(
          name: "test",
          description: "(options cant be used in events yet)",
          type_: 3,
          required: False,
        ),
      ],
    )

  let test_cmd2 =
    slash_command.SlashCommand(
      name: "pong",
      type_: 1,
      description: "returns ping",
      options: [],
    )

  discord_gleam.register_commands(bot, "1262338071874244650", [
    test_cmd,
    test_cmd2,
  ])

  discord_gleam.run(bot, [event_handler])
}

fn event_handler(bot, packet: event_handler.Packet) {
  case packet {
    event_handler.ReadyPacket(ready) -> {
      logging.log(logging.Info, "Logged in as " <> ready.d.user.username)

      Nil
    }
    event_handler.InteractionCreate(interaction) -> {
      logging.log(logging.Info, "Interaction: " <> interaction.d.data.name)

      case interaction.d.data.name {
        "ping" -> {
          discord_gleam.interaction_reply_message(interaction, "pong")

          Nil
        }
        "pong" -> {
          discord_gleam.interaction_reply_message(interaction, "ping")

          Nil
        }
        _ -> Nil
      }
    }
    _ -> Nil
  }
}
