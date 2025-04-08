import discord_gleam/http/request
import discord_gleam/internal/error
import discord_gleam/types/message
import discord_gleam/types/reply
import discord_gleam/types/slash_command
import discord_gleam/types/user
import discord_gleam/ws/packets/interaction_create
import gleam/dynamic
import gleam/hackney
import gleam/http
import gleam/http/response
import gleam/int
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
          io.println("- Response: ")
          io.debug(resp.body)
          io.println("- Status: " <> int.to_string(resp.status))

          Nil
        }
      }

      Nil
    }
    Error(err) -> {
      logging.log(logging.Error, "Failed to send message: ")
      io.println("- Error: ")
      io.debug(err)

      Nil
    }
  }
}

pub fn reply(token: String, channel_id: String, message: reply.Reply) -> Nil {
  let data = reply.to_string(message)
  io.debug(data)

  logging.log(logging.Debug, "Replying: " <> data)

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
          logging.log(logging.Debug, "Reply sent")
          Nil
        }
        _ -> {
          logging.log(logging.Error, "Failed to send reply")
          io.debug(resp.body)

          Nil
        }
      }

      Nil
    }
    Error(err) -> {
      logging.log(logging.Error, "Failed to send reply: ")
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

pub fn delete_message(
  token: String,
  channel_id: String,
  message_id: String,
  reason: String,
) -> #(String, String) {
  let request =
    request.new_auth_with_header(
      http.Delete,
      "/channels/" <> channel_id <> "/messages/" <> message_id,
      token,
      #("X-Audit-Log-Reason", reason),
    )

  case hackney.send(request) {
    Ok(resp) -> {
      case resp.status {
        204 -> {
          logging.log(logging.Debug, "Deleted Message")
          #("OK", resp.body)
        }
        _ -> {
          logging.log(logging.Error, "Failed to delete message")
          io.debug(resp.body)

          #("FAILED", resp.body)
        }
      }
    }
    Error(err) -> {
      logging.log(logging.Error, "Failed to delete message")
      io.debug(err)

      #("FAILED", "ERROR")
    }
  }
}

pub fn wipe_global_commands(
  token: String,
  client_id: String,
) -> #(String, String) {
  let request =
    request.new_auth_post(
      http.Put,
      "/applications/" <> client_id <> "/commands",
      token,
      "{}",
    )

  case hackney.send(request) {
    Ok(resp) -> {
      case resp.status {
        200 -> {
          logging.log(logging.Debug, "Wiped global commands")
          #("OK", resp.body)
        }
        _ -> {
          logging.log(logging.Error, "Failed to wipe global commands")
          io.debug(resp.body)

          #("FAILED", resp.body)
        }
      }
    }
    Error(err) -> {
      logging.log(logging.Error, "Failed to wipe global commands")
      io.debug(err)

      #("FAILED", "ERROR")
    }
  }
}

pub fn wipe_guild_commands(
  token: String,
  client_id: String,
  guild_id: String,
) -> #(String, String) {
  let request =
    request.new_auth_post(
      http.Put,
      "/applications/" <> client_id <> "/guilds/" <> guild_id <> "/commands",
      token,
      "{}",
    )

  case hackney.send(request) {
    Ok(resp) -> {
      case resp.status {
        200 -> {
          logging.log(logging.Debug, "Wiped guild commands")
          #("OK", resp.body)
        }
        _ -> {
          logging.log(logging.Error, "Failed to wipe guild commands")
          io.debug(resp.body)

          #("FAILED", resp.body)
        }
      }
    }
    Error(err) -> {
      logging.log(logging.Error, "Failed to wipe guild commands")
      io.debug(err)

      #("FAILED", "ERROR")
    }
  }
}

pub fn register_global_command(
  token: String,
  client_id: String,
  command: slash_command.SlashCommand,
) -> #(String, String) {
  let request =
    request.new_auth_post(
      http.Post,
      "/applications/" <> client_id <> "/commands",
      token,
      slash_command.command_to_string(command),
    )

  case hackney.send(request) {
    Ok(resp) -> {
      case resp.status {
        201 -> {
          logging.log(logging.Debug, "Added global command " <> command.name)
          #("OK", resp.body)
        }
        200 -> {
          logging.log(logging.Debug, "Updated global command " <> command.name)
          #("OK", resp.body)
        }
        _ -> {
          logging.log(
            logging.Error,
            "Failed to add global command" <> command.name,
          )
          io.debug(resp.body)

          #("FAILED", resp.body)
        }
      }
    }
    Error(err) -> {
      logging.log(logging.Error, "Failed to add global command" <> command.name)
      io.debug(err)

      #("FAILED", "ERROR")
    }
  }
}

pub fn register_guild_command(
  token: String,
  client_id: String,
  guild_id: String,
  command: slash_command.SlashCommand,
) -> #(String, String) {
  let request =
    request.new_auth_post(
      http.Post,
      "/applications/" <> client_id <> "/guilds/" <> guild_id <> "/commands",
      token,
      slash_command.command_to_string(command),
    )

  case hackney.send(request) {
    Ok(resp) -> {
      case resp.status {
        201 -> {
          logging.log(logging.Debug, "Added guild command " <> command.name)
          #("OK", resp.body)
        }
        200 -> {
          logging.log(logging.Debug, "Updated guild command " <> command.name)
          #("OK", resp.body)
        }
        _ -> {
          logging.log(
            logging.Error,
            "Failed to add guild command" <> command.name,
          )
          io.debug(resp.body)

          #("FAILED", resp.body)
        }
      }
    }
    Error(err) -> {
      logging.log(logging.Error, "Failed to add guild command" <> command.name)
      io.debug(err)

      #("FAILED", "ERROR")
    }
  }
}

pub fn interaction_send_text(
  interaction: interaction_create.InteractionCreate,
  message: String,
  ephemeral: Bool,
) -> #(String, String) {
  let request =
    request.new_post(
      http.Post,
      "/interactions/"
        <> interaction.d.id
        <> "/"
        <> interaction.d.token
        <> "/callback",
      slash_command.make_basic_text_reply(message, ephemeral),
    )

  case hackney.send(request) {
    Ok(resp) -> {
      case resp.status {
        204 -> {
          logging.log(logging.Debug, "Sent Interaction Response")
          #("OK", resp.body)
        }
        _ -> {
          logging.log(logging.Error, "Failed to send Interaction Response")
          io.debug(resp.body)

          #("FAILED", resp.body)
        }
      }
    }
    Error(err) -> {
      logging.log(logging.Error, "Error when sending Interaction Response")
      io.debug(err)

      #("FAILED", "ERROR")
    }
  }
}
