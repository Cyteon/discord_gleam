import discord_gleam
import discord_gleam/discord/intents
import discord_gleam/event_handler
import discord_gleam/types/message
import discord_gleam/types/slash_command
import gleam/list
import gleam/string
import logging

pub fn main() {
  logging.configure()
  logging.set_level(logging.Info)

  let bot =
    discord_gleam.bot("YOUR TOKEN", "YOUR CLIENT ID", intents.default_intents())

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

  discord_gleam.register_global_commands(bot, "YOUR BOT ID", [test_cmd])

  discord_gleam.register_guild_commands(bot, "YOUR BOT ID", "YOUR GUILD ID", [
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
          discord_gleam.interaction_reply_message(interaction, "pong", False)

          Nil
        }
        "pong" -> {
          discord_gleam.interaction_reply_message(interaction, "ping", False)

          Nil
        }
        _ -> Nil
      }
    }
    _ -> Nil
  }
}
