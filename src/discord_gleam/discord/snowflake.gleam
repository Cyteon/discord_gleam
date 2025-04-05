import gleam/dynamic/decode
import gleam/int

/// See https://discord.com/developers/docs/reference#snowflakes
pub type Snowflake =
  String

pub fn decoder() {
  decode.one_of(decode.string, [decode.int |> decode.map(int.to_string)])
}
