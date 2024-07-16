import discord_gleam
import logging

pub fn main(token: String) {
  logging.configure()
  logging.set_level(logging.Debug)

  discord_gleam.run(token)
}
