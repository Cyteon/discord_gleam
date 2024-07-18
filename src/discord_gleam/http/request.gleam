import gleam/http
import gleam/http/request
import gleam/list

pub fn new(method: http.Method, path: String) -> request.Request(String) {
  request.new()
  |> request.set_method(method)
  |> request.set_host("discord.com")
  |> request.set_path("/api/v10" <> path)
  |> request.prepend_header("accept", "application/json")
  |> request.prepend_header(
    "User-Agent",
    "DiscordBot (https://github.com/cyteon/discord_gleam, 0.0.2)",
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

/// We have this to send post requests with token authentication
pub fn new_auth_post(
  method: http.Method,
  path: String,
  token: String,
  data: String,
) -> request.Request(String) {
  new(method, path)
  |> request.prepend_header("Authorization", "Bot " <> token)
  |> request.set_body(data)
  |> request.prepend_header("Content-Type", "application/json")
}

/// Some endpoints requires token authentication
pub fn new_auth_with_header(
  method: http.Method,
  path: String,
  token: String,
  header: #(String, String),
) -> request.Request(String) {
  new_auth(method, path, token)
  |> request.set_header(header.0, header.1)
}
