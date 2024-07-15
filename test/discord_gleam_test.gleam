import example_bot
import gleam/erlang/os
import gleam/io

pub fn main() {
  case os.get_env("TEST_BOT_TOKEN") {
    Ok(token) -> example_bot.main(token)
    Error(_) -> io.println("Token not found :c")
  }
}
