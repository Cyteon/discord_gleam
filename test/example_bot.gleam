import discord_gleam/http/endpoints
import gleam/erlang/process
import gleam/io
import logging

pub fn main(token: String) {
  logging.configure()

  let response = endpoints.me(token)
  case response {
    Ok(me) -> {
      logging.log(
        logging.Info,
        "Hello from "
          <> me.username
          <> "#"
          <> me.discriminator
          <> " with the ID "
          <> me.id,
      )
      process.sleep(100)
    }
    Error(err) -> {
      io.debug(err)

      Nil
    }
  }
}
