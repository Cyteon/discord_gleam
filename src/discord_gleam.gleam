import discord_gleam/ws/event_loop

pub fn run(token: String) -> Nil {
  event_loop.main(token)
}
