import discord_gleam/http/endpoints
import gleam/io

pub fn main(token: String) {
  // For debugging
  //io.println("Token: " <> token)

  let response = endpoints.me(token)
  case response {
    Ok(me) -> {
      io.println(
        "Hello from "
        <> me.username
        <> "#"
        <> me.discriminator
        <> " with the ID "
        <> me.id,
      )
    }
    Error(_) -> {
      io.println("Error")
    }
  }
}
