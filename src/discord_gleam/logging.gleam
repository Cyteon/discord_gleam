import birl
import gleam/dict.{type Dict}
import gleam/erlang/atom.{type Atom}
import gleam/io
import gleam/list
import gleam/string

fn get_date_string() -> String {
  let now = birl.now()
  let date_string_with_timezone = birl.to_date_string(now)
  let time_string_with_timezone = birl.to_time_string(now)

  // Removing timezone from date string
  let date_parts = string.split(date_string_with_timezone, "+")
  let date_without_timezone = case list.first(date_parts) {
    Ok(value) -> value
    Error(_) -> date_string_with_timezone
  }

  // Removing timezone from time string
  let time_parts = string.split(time_string_with_timezone, "+")
  let time_without_timezone = case list.first(time_parts) {
    Ok(value) -> value
    Error(_) -> date_string_with_timezone
  }

  date_without_timezone <> " " <> time_without_timezone
}

/// Logging types: log (default), info, warn, error
/// Prints like this: 2024-01-01 12:00:00 | LOG_TYPE | Content
/// Example: println("Hello, world!", "info")
pub fn println(content: String, log_type: String) {
  let log_splitter = case log_type {
    "info" -> "\u{001b}[34mINFO"
    "warn" -> "\u{001b}[33mWARN"
    "error" -> "\u{001b}[31mERROR"
    _ -> "\u{001b}[32mLOG"
  }

  io.println(
    get_date_string() <> " | " <> log_splitter <> "\u{001b}[0m | " <> content,
  )
}

/// Logging types: info, debug, warning (default), error, alert, critical, emergency
/// The selected level and all levels above are printed
pub fn set_logger_level(level: String) -> Nil {
  let _ =
    logger_update_primary_config(
      dict.from_list([
        #(atom.create_from_string("level"), atom.create_from_string(level)),
      ]),
    )

  Nil
}

@external(erlang, "logger", "update_primary_config")
fn logger_update_primary_config(config: Dict(Atom, Atom)) -> Result(Nil, any)

@external(erlang, "logger", "info")
pub fn log_info(message: String) -> Nil

@external(erlang, "logger", "debug")
pub fn log_debug(message: String) -> Nil

@external(erlang, "logger", "warning")
pub fn log_warn(message: String) -> Nil

@external(erlang, "logger", "error")
pub fn log_error(message: String) -> Nil

@external(erlang, "logger", "alert")
pub fn log_alert(message: String) -> Nil

@external(erlang, "logger", "critical")
pub fn log_critical(message: String) -> Nil

@external(erlang, "logger", "emergency")
pub fn log_emergency(message: String) -> Nil
