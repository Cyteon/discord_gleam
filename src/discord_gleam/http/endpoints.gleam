/// Low-level functions for interacting with the Discord API. \
/// Preferrably use the higher-level functions in src/discord_gleam.gleam.
import discord_gleam/http/request
import discord_gleam/internal/error
import discord_gleam/types/channel
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
import gleam/json
import logging

/// Get the current user
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

/// Send a message to a channel
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
          logging.log(
            logging.Error,
            "Failed to send message (status: "
              <> int.to_string(resp.status)
              <> "):",
          )
          io.debug(resp.body)

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

/// Create a DM channel, can be used to send direct messages where a direct message function is not created
pub fn create_dm_channel(
  token: String,
  user_id: String,
) -> Result(channel.Channel, error.DiscordError) {
  let request =
    request.new_auth_post(
      http.Post,
      "/users/@me/channels",
      token,
      "{ \"recipient_id\": \"" <> user_id <> "\" }",
    )

  case hackney.send(request) {
    Ok(resp) -> {
      case resp.status {
        200 -> {
          logging.log(logging.Debug, "DM channel created")

          let channel: Result(channel.Channel, json.DecodeError) =
            channel.string_to_data(resp.body)

          case channel {
            Ok(channel) -> {
              Ok(channel)
            }

            Error(err) -> {
              logging.log(logging.Error, "Failed to decode DM channel: ")

              Error(error.JsonDecodeError(err))
            }
          }
        }

        v -> {
          Error(error.GenericHttpError(status_code: v, body: resp.body))
        }
      }
    }
    Error(err) -> {
      Error(error.HttpError(err))
    }
  }
}

/// Creates a DM channel, then sends a message with `send_message()`.
pub fn send_direct_message(
  token: String,
  user_id: String,
  message: message.Message,
) -> Result(Nil, error.DiscordError) {
  let data: String = message.to_string(message)
  logging.log(logging.Debug, "Sending DM: " <> data)

  let channel: Result(channel.Channel, error.DiscordError) =
    create_dm_channel(token, user_id)

  case channel {
    Ok(channel) -> {
      send_message(token, channel.id, message)

      Ok(Nil)
    }

    Error(err) -> {
      logging.log(logging.Error, "Failed to create DM channel")

      Error(err)
    }
  }
}

/// Reply to a message
pub fn reply(token: String, channel_id: String, message: reply.Reply) -> Nil {
  let data = reply.to_string(message)

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

/// Kick a member from a server
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

/// Ban a member from a server
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

/// Delete a message by channel id and message id
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

/// Wipes the global commands for the bot
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

/// Wipes the guild commands for the bot
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

/// Register a new global slash command
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

/// Register a new guild-specific slash command
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

/// Send a basic text reply to an interaction
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
