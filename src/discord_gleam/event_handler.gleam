import bravo/uset
import discord_gleam/types/bot
import discord_gleam/ws/packets/generic
import discord_gleam/ws/packets/interaction_create
import discord_gleam/ws/packets/message
import discord_gleam/ws/packets/message_delete
import discord_gleam/ws/packets/message_update
import discord_gleam/ws/packets/ready
import gleam/list
import gleam/option
import gleam/result

pub type EventHandler =
  fn(bot.Bot, Packet) -> Nil

/// We currently only have some packets, need more
pub type Packet {
  /// `MESSAGE_CREATE` event
  MessagePacket(message.MessagePacket)
  /// `MESSAGE_UPDATE` event
  MessageUpdatePacket(message_update.MessageUpdatePacket)
  /// `READY` event
  ReadyPacket(ready.ReadyPacket)
  /// `MESSAGE_DELETE` event
  MessageDeletePacket(message_delete.MessageDeletePacket)
  /// `INTERACTION_CREATE` event
  InteractionCreate(interaction_create.InteractionCreate)
  UnknownPacket(generic.GenericPacket)
}

/// For handling some events the library needs to handle, for functionality
fn internal_handler(bot: bot.Bot, packet: Packet) -> Nil {
  case packet {
    MessagePacket(msg) -> {
      case bot.cache.messages {
        option.Some(cache) -> {
          uset.insert(cache, [#(msg.d.id, msg.d)])

          Nil
        }

        option.None -> {
          Nil
        }
      }
      Nil
    }

    MessageUpdatePacket(msg) -> {
      case bot.cache.messages {
        option.Some(cache) -> {
          uset.insert(cache, [#(msg.d.id, msg.d)])

          Nil
        }

        option.None -> {
          Nil
        }
      }
    }

    _ -> Nil
  }
}

/// Handle an event from the Discord API, using a set of event handlers.
pub fn handle_event(
  bot: bot.Bot,
  msg: String,
  handlers: List(EventHandler),
) -> Nil {
  let packet = decode_packet(msg)

  case packet {
    UnknownPacket(_) -> Nil
    _ -> internal_handler(bot, packet)
  }

  list.each(handlers, fn(handler) { handler(bot, packet) })
}

fn decode_packet(msg: String) -> Packet {
  let generic_packet = generic.string_to_data(msg)
  case generic_packet.t {
    "MESSAGE_CREATE" ->
      message.string_to_data(msg)
      |> result.map(MessagePacket)
      |> result.unwrap(UnknownPacket(generic_packet))
    "MESSAGE_UPDATE" ->
      message_update.string_to_data(msg)
      |> result.map(MessageUpdatePacket)
      |> result.unwrap(UnknownPacket(generic_packet))
    "READY" ->
      ready.string_to_data(msg)
      |> result.map(ReadyPacket)
      |> result.unwrap(UnknownPacket(generic_packet))
    "MESSAGE_DELETE" ->
      message_delete.string_to_data(msg)
      |> result.map(MessageDeletePacket)
      |> result.unwrap(UnknownPacket(generic_packet))
    "INTERACTION_CREATE" ->
      interaction_create.string_to_data(msg)
      |> result.map(InteractionCreate)
      |> result.unwrap(UnknownPacket(generic_packet))
    _ -> UnknownPacket(generic_packet)
  }
}
