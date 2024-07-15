import discord_gleam/http/endpoints
import discord_gleam/logging
import gleam/erlang/process
import gleam/io

pub fn main(token: String) {
  // For debugging
  //io.println("Token: " <> token)

  logging.set_logger_level("warning")

  let response = endpoints.me(token)
  case response {
    Ok(me) -> {
      logging.println(
        "Hello from "
          <> me.username
          <> "#"
          <> me.discriminator
          <> " with the ID "
          <> me.id,
        "info",
      )
      process.sleep(100)
    }
    Error(err) -> {
      logging.println("Error fetching user", "error")
      io.debug(err)

      Nil
    }
  }
}
