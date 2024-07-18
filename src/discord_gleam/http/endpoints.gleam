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
  channel_id: String,
  message: message.Message,
) -> Nil {
  let data = message.to_string(message)

  io.debug(data)

  logging.log(logging.Debug, "Sending message: " <> data)

  let request =
    request.new_auth_post(
      http.Post,
      "/channels/" <> channel_id <> "/messages",
      token,
      data,
    )
  case hackney.send(request) {
    Ok(resp) -> {
      case resp.status {
        200 -> {
          logging.log(logging.Debug, "Message sent")
          Nil
        }
        _ -> {
          logging.log(logging.Error, "Failed to send message")
          io.debug(resp.body)

          Nil
        }
      }

      Nil
    }
    Error(err) -> {
      logging.log(logging.Error, "Failed to send message: ")
      io.debug(err)

      Nil
    }
  }
}

pub fn kick_member(
  token: String,
  guild_id: String,
  user_id: String,
  reason: String,
) -> #(String, String) {
  let request =
    request.new_auth_with_header(
      http.Delete,
      "/guilds/" <> guild_id <> "/members/" <> user_id,
      token,
      #("X-Audit-Log-Reason", reason),
    )

  case hackney.send(request) {
    Ok(resp) -> {
      case resp.status {
        204 -> {
          logging.log(logging.Debug, "Kicked member")
          #("OK", resp.body)
        }
        _ -> {
          logging.log(logging.Error, "Failed to kick member")
          io.debug(resp.body)

          #("FAILED", resp.body)
        }
      }
    }
    Error(err) -> {
      logging.log(logging.Error, "Failed to kick member: ")
      io.debug(err)

      #("FAILED", "ERROR")
    }
  }
}

pub fn ban_member(
  token: String,
  guild_id: String,
  user_id: String,
  reason: String,
) -> #(String, String) {
  let request =
    request.new_auth_with_header(
      http.Put,
      "/guilds/" <> guild_id <> "/bans/" <> user_id,
      token,
      #("X-Audit-Log-Reason", reason),
    )

  case hackney.send(request) {
    Ok(resp) -> {
      case resp.status {
        204 -> {
          logging.log(logging.Debug, "Banned member")
          #("OK", resp.body)
        }
        _ -> {
          logging.log(logging.Error, "Failed to ban member")
          io.debug(resp.body)

          #("FAILED", resp.body)
        }
      }
    }
    Error(err) -> {
      logging.log(logging.Error, "Failed to ban member: ")
      io.debug(err)

      #("FAILED", "ERROR")
    }
  }
}
