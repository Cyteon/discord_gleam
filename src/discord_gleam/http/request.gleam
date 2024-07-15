import gleam/http
import gleam/http/request

pub fn new(method: http.Method, path: String) -> request.Request(String) {
  request.new()
  |> request.set_method(method)
  |> request.set_host("discord.com")
  |> request.set_path("/api/v10" <> path)
  |> request.prepend_header("accept", "application/json")
  |> request.prepend_header(
    "User-Agent",
    "DiscordBot using Gleam and cyteon/discord_gleam",
  )
}

/// Some endpoints requires token authentication
pub fn new_auth(
  method: http.Method,
  path: String,
  token: String,
) -> request.Request(String) {
  new(method, path)
  |> request.prepend_header("Authorization", "Bot " <> token)
}
