import discord_gleam/http/request
import discord_gleam/internal/error
import discord_gleam/types/message
import discord_gleam/types/user
import gleam/dynamic
import gleam/hackney
import gleam/http
import gleam/http/response
import gleam/io
import logging

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

pub fn send_message(
  token: String,
  message: message.Message,
  channel_id: String,
) -> Nil {
  let data = message.to_string(message)

  io.debug(data)

  logging.log(logging.Debug, "Sending message: " <> message.content)

  let request =
    request.new_auth_post(
      http.Post,
      "/channels/" <> channel_id <> "/messages",
      token,
      data,
    )
  case hackney.send(request) {
    Ok(resp) -> {
      io.debug(resp)

      Nil
    }
    Error(err) -> {
      logging.log(logging.Error, "Failed to send message: ")
      io.debug(err)

      Nil
    }
  }
}
