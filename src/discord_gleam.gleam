import discord_gleam/http/endpoints
import discord_gleam/internal/error
import gleam/io
import gleam/result

pub fn run(token: String) -> Result(Nil, error.DiscordError) {
  let user = endpoints.me(token)
  case user {
    Ok(_) -> {
      io.debug("Successfully authenticated")
      Ok(Nil)
    }
    Error(err) -> {
      io.debug(err)
      Error(err)
    }
  }
}
