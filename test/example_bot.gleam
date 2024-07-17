import discord_gleam
import discord_gleam/event_handler
import logging

pub fn main(token: String) {
  logging.configure()
  logging.set_level(logging.Info)

  discord_gleam.run(token, [event_handler])
}

fn event_handler(packet: event_handler.Packet) {
  case packet {
    event_handler.ReadyPacket(ready) -> {
      logging.log(logging.Info, "Logged in as " <> ready.d.user.username)
    }
    event_handler.MessagePacket(message) -> {
      logging.log(
        logging.Info,
        "Received message: '"
          <> message.d.content
          <> "' from "
          <> message.d.author.username,
      )
    }
    _ -> Nil
  }
}
