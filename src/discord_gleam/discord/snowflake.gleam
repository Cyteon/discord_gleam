//// Snowflakes is discord's type for unique identifiers. \
//// They are 64-bit unsigned integers, represented as strings. \
//// See https://discord.com/developers/docs/reference#snowflakes

import gleam/dynamic/decode
import gleam/int

pub type Snowflake =
  String

/// API should not give a int, but incase it does we will convert to string.
pub fn decoder() {
  decode.one_of(decode.string, [decode.int |> decode.map(int.to_string)])
}
