import discord_gleam/event_handler
import discord_gleam/ws/event_loop

pub fn run(
  token: String,
  event_handlers: List(event_handler.EventHandler),
) -> Nil {
  event_loop.main(token, event_handlers)
}
