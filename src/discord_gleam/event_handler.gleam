import discord_gleam/ws/packets/generic
import discord_gleam/ws/packets/message
import discord_gleam/ws/packets/ready
import gleam/list
import gleam/result

pub type EventHandler =
  fn(Packet) -> Nil

pub type Packet {
  MessagePacket(message.MessagePacket)
  ReadyPacket(ready.ReadyPacket)
  UnknownPacket(generic.GenericPacket)
}

pub fn handle_event(msg: String, handlers: List(EventHandler)) -> Nil {
  let packet = decode_packet(msg)

  list.each(handlers, fn(handler) { handler(packet) })
}

fn decode_packet(msg: String) -> Packet {
  let generic_packet = generic.string_to_data(msg)
  case generic_packet.t {
    "MESSAGE_CREATE" ->
      message.string_to_data(msg)
      |> result.map(MessagePacket)
      |> result.unwrap(UnknownPacket(generic_packet))
    "READY" ->
      ready.string_to_data(msg)
      |> result.map(ReadyPacket)
      |> result.unwrap(UnknownPacket(generic_packet))
    _ -> UnknownPacket(generic_packet)
  }
}
