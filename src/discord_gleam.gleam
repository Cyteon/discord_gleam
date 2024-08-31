import discord_gleam/event_handler
import discord_gleam/http/endpoints
import discord_gleam/types/bot
import discord_gleam/types/message
import discord_gleam/types/reply
import discord_gleam/types/slash_command
import discord_gleam/ws/event_loop
import discord_gleam/ws/packets/interaction_create
import gleam/list

pub fn bot(token: String) -> bot.Bot {
  bot.Bot(token: token)
}

pub fn run(
  bot: bot.Bot,
  event_handlers: List(event_handler.EventHandler),
) -> Nil {
  event_loop.main(bot, event_handlers)
}

pub fn send_message(
  bot: bot.Bot,
  channel_id: String,
  message: String,
  embeds: List(message.Embed),
) -> Nil {
  let msg = message.Message(content: message, embeds: embeds)

  endpoints.send_message(bot.token, channel_id, msg)
}

pub fn reply(
  bot: bot.Bot,
  channel_id: String,
  message_id: String,
  message: String,
  embeds: List(message.Embed),
) -> Nil {
  let msg =
    reply.Reply(content: message, message_id: message_id, embeds: embeds)

  endpoints.reply(bot.token, channel_id, msg)
}

pub fn kick_member(
  bot: bot.Bot,
  guild_id: String,
  user_id: String,
  reason: String,
) -> #(String, String) {
  endpoints.kick_member(bot.token, guild_id, user_id, reason)
}

pub fn ban_member(
  bot: bot.Bot,
  guild_id: String,
  user_id: String,
  reason: String,
) -> #(String, String) {
  endpoints.ban_member(bot.token, guild_id, user_id, reason)
}

pub fn delete_message(
  bot: bot.Bot,
  channel_id: String,
  message_id: String,
  reason: String,
) -> #(String, String) {
  endpoints.delete_message(bot.token, channel_id, message_id, reason)
}

pub fn wipe_slash_commands(bot: bot.Bot, client_id: String) -> #(String, String) {
  endpoints.wipe_slash_commands(bot.token, client_id)
}

pub fn register_commands(
  bot: bot.Bot,
  client_id: String,
  commands: List(slash_command.SlashCommand),
) {
  list.each(commands, fn(command) {
    endpoints.register_slash_command(bot.token, client_id, command)
  })
}

pub fn interaction_reply_message(
  interaction: interaction_create.InteractionCreate,
  message: String,
) -> #(String, String) {
  endpoints.interaction_send_text(interaction, message)
}
