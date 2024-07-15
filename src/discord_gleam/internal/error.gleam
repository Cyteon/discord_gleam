import gleam/dynamic
import gleam/hackney
import gleam/json
import gleam/otp/actor

pub type DiscordError {
  UnknownAccount
  EmptyOptionWhenRequired
  InvalidJson(json.DecodeError)
  InvalidDynamicList(List(dynamic.DecodeError))
  InvalidFormat(dynamic.DecodeError)
  WebsocketError(Nil)
  HttpError(hackney.Error)
  ActorError(actor.StartError)
  NilMapEntry(Nil)
  /// Used when a builder dosen't have all of the properties it requires
  BadBuilderProperties(String)
  Unauthorized(String)
}
