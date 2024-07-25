import gleam/dynamic
import gleam/int

/// See https://discord.com/developers/docs/reference#snowflakes
pub type Snowflake =
  String

pub fn from_dynamic(
  dyn: dynamic.Dynamic,
) -> Result(Snowflake, List(dynamic.DecodeError)) {
  case dynamic.classify(dyn) {
    "String" -> {
      dynamic.string(dyn)
    }
    "Int" -> {
      case dynamic.int(dyn) {
        Ok(num) -> Ok(int.to_string(num))
        Error(errors) -> Error(errors)
      }
    }
    // Should be a String or Int, this should not happen
    _ ->
      Error([
        dynamic.DecodeError(
          expected: "String or Int",
          found: dynamic.classify(dyn),
          path: [],
        ),
      ])
  }
}
