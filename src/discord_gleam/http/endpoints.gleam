import discord_gleam/http/request
import discord_gleam/internal/error
import discord_gleam/types/user
import gleam/dynamic
import gleam/hackney
import gleam/http
import gleam/http/response
import gleam/json
import gleam/result

pub fn me(token: String) -> Result(user.User, error.DiscordError) {
  let request = request.new_auth(http.Get, "/users/@me", token)
  case hackney.send(request) {
    Ok(resp) -> {
      case response.get_header(resp, "content-type") {
        Ok("application/json") -> {
          user.from_json_string(resp.body)
        }
        _ ->
          Error(
            error.InvalidFormat(
              dynamic.DecodeError(
                expected: "application/json content-type",
                found: "unknown",
                path: [],
              ),
            ),
          )
      }
    }
    Error(err) -> Error(error.HttpError(err))
  }
}
