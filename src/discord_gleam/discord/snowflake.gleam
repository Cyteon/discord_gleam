import gleam/dynamic
import gleam/dynamic/decode
import gleam/int

/// See https://discord.com/developers/docs/reference#snowflakes
pub type Snowflake =
  String

pub fn from_dynamic(
  dyn: decode.Dynamic,
) -> Result(Snowflake, List(decode.DecodeError)) {
  case dynamic.classify(dyn) {
    "String" -> {
      decode.run(dyn, decode.string)
    }
    "Int" -> {
      case decode.run(dyn, decode.int) {
        Ok(num) -> Ok(int.to_string(num))
        Error(errors) -> Error(errors)
      }
    }
    // Should be a String or Int, this should not happen
    type_name ->
      Error([
        decode.DecodeError(
          expected: "String or Int",
          found: type_name,
          path: [],
        ),
      ])
  }
}
