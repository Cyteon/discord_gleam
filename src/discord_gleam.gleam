import bravo
import bravo/uset
import discord_gleam/discord/intents
import discord_gleam/event_handler
import discord_gleam/http/endpoints
import discord_gleam/types/bot
import discord_gleam/types/message
import discord_gleam/types/reply
import discord_gleam/types/slash_command
import discord_gleam/ws/event_loop
import discord_gleam/ws/packets/interaction_create
import gleam/list
import gleam/option

/// Create a new bot instance.
/// 
/// Example:
/// ```gleam
/// import discord_gleam/discord/intents
/// 
/// pub fn main() {
///   let bot = discord_gleam.bot("TOKEN", "CLIENT_ID", intents.default())
/// }
/// ```
pub fn bot(
  token: String,
  client_id: String,
  intents: intents.Intents,
) -> bot.Bot {
  bot.Bot(
    token: token,
    client_id: client_id,
    intents: intents,
    cache: bot.Cache(messages: case uset.new("MessagesCache", 1, bravo.Public) {
      Ok(cache) -> option.Some(cache)
      Error(_) -> option.None
    }),
  )
}

/// Start the event loop, with a set of event handlers.
///
/// Example:
/// ```gleam
/// import discord_gleam/discord/intents
/// import discord_gleam/event_handler
/// 
/// pub fn main() {
///  let bot = discord_gleam.bot("TOKEN", "CLIENT_ID", intents.default())
/// 
///  let event_handlers = [handler]
/// }
/// 
/// fn handler(bot: bot.Bot, packet: event_handler.Packet) {
///  case packet {
///   event_handler.ReadyPacket(ready) -> {
///     logging.log(logging.Info, "Logged in as " <> ready.d.user.username)
///   }
/// 
///   _ -> Nil
///  }
/// }
/// 
pub fn run(
  bot: bot.Bot,
  event_handlers: List(event_handler.EventHandler),
) -> Nil {
  event_loop.main(bot, event_handlers)
}

/// Send a message to a channel.
/// 
/// Example:
/// ```gleam
/// import discord_gleam
/// 
/// pub fn main() {
///  ...
/// 
///  let msg = discord_gleam.send_message(
///   bot,  
///  "CHANNEL_ID",
///  "Hello world!",
///  [] // embeds
/// )
pub fn send_message(
  bot: bot.Bot,
  channel_id: String,
  message: String,
  embeds: List(message.Embed),
) -> Nil {
  let msg = message.Message(content: message, embeds: embeds)

  endpoints.send_message(bot.token, channel_id, msg)
}

/// Send a direct message to a user.
/// Same use as `send_message`, but use user_id instead of channel_id.
/// `discord_gleam.send_direct_message(bot, "USER_ID", "Hello world!", [])`
pub fn send_direct_message(
  bot: bot.Bot,
  user_id: String,
  message: String,
  embeds: List(message.Embed),
) -> Nil {
  let msg = message.Message(content: message, embeds: embeds)

  endpoints.send_direct_message(bot.token, user_id, msg)
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

pub fn wipe_global_commands(bot: bot.Bot) -> #(String, String) {
  endpoints.wipe_global_commands(bot.token, bot.client_id)
}

pub fn wipe_guild_commands(bot: bot.Bot, guild_id: String) -> #(String, String) {
  endpoints.wipe_guild_commands(bot.token, bot.client_id, guild_id)
}

pub fn register_global_commands(
  bot: bot.Bot,
  commands: List(slash_command.SlashCommand),
) {
  list.each(commands, fn(command) {
    endpoints.register_global_command(bot.token, bot.client_id, command)
  })
}

pub fn register_guild_commands(
  bot: bot.Bot,
  guild_id: String,
  commands: List(slash_command.SlashCommand),
) {
  list.each(commands, fn(command) {
    endpoints.register_guild_command(
      bot.token,
      bot.client_id,
      guild_id,
      command,
    )
  })
}

pub fn interaction_reply_message(
  interaction: interaction_create.InteractionCreate,
  message: String,
  ephemeral: Bool,
) -> #(String, String) {
  endpoints.interaction_send_text(interaction, message, ephemeral)
}
