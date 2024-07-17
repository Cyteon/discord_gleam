import discord_gleam/event_handler
import discord_gleam/http/endpoints
import discord_gleam/types/bot
import discord_gleam/types/message
import discord_gleam/ws/event_loop

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
