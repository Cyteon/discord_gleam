import discord_gleam/event_handler
import discord_gleam/types/bot
import discord_gleam/ws/packets/generic
import discord_gleam/ws/packets/hello
import discord_gleam/ws/packets/identify
import gleam/erlang/process
import gleam/function
import gleam/http
import gleam/http/request
import gleam/int
import gleam/option
import gleam/otp/actor
import logging
import repeatedly
import stratus

pub type Msg {
  Close
  TimeUpdated(String)
}

pub type State {
  State(has_received_hello: Bool, s: Int)
}

pub fn main(bot: bot.Bot, event_handlers: List(event_handler.EventHandler)) {
  logging.log(logging.Debug, "Requesting gateway")

  let req =
    request.new()
    |> request.set_host("gateway.discord.gg")
    |> request.set_scheme(http.Https)
    |> request.set_path("/?v=10&encoding=json")
    |> request.set_header(
      "User-Agent",
      "DiscordBot (https://github.com/cyteon/discord_gleam, 0.0.5)",
    )
    |> request.set_header("Host", "gateway.discord.gg")
    |> request.set_header("Connection", "Upgrade")
    |> request.set_header("Upgrade", "websocket")
    |> request.set_header("Sec-WebSocket-Version", "13")

  logging.log(logging.Debug, "Creating builder")

  let initial_state = State(has_received_hello: False, s: 0)
  let builder =
    stratus.websocket(
      request: req,
      init: fn() {
        logging.log(logging.Debug, "Builder init")
        #(initial_state, option.None)
      },
      loop: fn(msg, state, conn) {
        case msg {
          stratus.Text(msg) -> {
            logging.log(logging.Debug, msg)
            case state.has_received_hello {
              False -> {
                let identify = identify.create_packet(bot.token)
                let _ = stratus.send_text_message(conn, identify)

                let new_state = State(has_received_hello: True, s: 0)

                let heartbeat = hello.string_to_data(msg)

                process.start(
                  fn() {
                    repeatedly.call(heartbeat, Nil, fn(_state, _count_) {
                      let packet =
                        "{\"op\": 1, \"d\": null, \"s\": "
                        <> int.to_string(state.s)
                        // TODO: This is wrong, its always 0???
                        // Might be an issue with state cause this is in a process
                        <> "}"

                      logging.log(
                        logging.Debug,
                        "Sending heartbeat: " <> packet,
                      )

                      stratus.send_text_message(conn, packet)
                    })
                  },
                  False,
                )

                actor.continue(new_state)
              }
              True -> {
                let generic_packet = generic.string_to_data(msg)

                let new_state =
                  State(has_received_hello: True, s: generic_packet.s)

                event_handler.handle_event(bot, msg, event_handlers)

                actor.continue(new_state)
              }
            }
          }
          stratus.User(msg) -> {
            logging.log(logging.Debug, msg)
            actor.continue(state)
          }
          stratus.Binary(_) -> {
            logging.log(logging.Debug, "Binary message")
            actor.continue(state)
          }
        }
      },
    )
    |> stratus.on_close(fn(_) {
      logging.log(logging.Error, "oh nyo, discord closed websocket :c")
    })

  let assert Ok(subj) = stratus.initialize(builder)

  process.new_selector()
    |> process.selecting_process_down(
      process.monitor_process(process.subject_owner(subj)),
      function.identity,
    )
    |> process.select_forever

  process.sleep(10_000)

  logging.log(logging.Info, "websocket go bye bye")
}
