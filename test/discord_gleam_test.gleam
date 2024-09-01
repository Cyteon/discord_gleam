import example_bot
import gleam/erlang/os
import gleam/io
import gleam/result

pub fn main() {
  case
    {
      use token <- result.try(get_env("TEST_BOT_TOKEN"))
      use client_id <- result.try(get_env("TEST_BOT_CLIENT_ID"))
      use guild_id <- result.try(get_env("TEST_BOT_GUILD_ID"))

      Ok(example_bot.main(token, client_id, guild_id))
    }
  {
    Ok(_) -> Nil
    Error(msg) -> io.println(msg)
  }
}

fn get_env(var: String) -> Result(String, String) {
  case os.get_env(var) {
    Ok(value) -> Ok(value)
    Error(_) -> Error("Environment variable " <> var <> " not found")
  }
}
