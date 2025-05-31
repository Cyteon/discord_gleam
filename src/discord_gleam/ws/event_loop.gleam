import bravo
import bravo/uset
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

/// Start the event loop, with a set of event handlers.
pub fn main(bot: bot.Bot, event_handlers: List(event_handler.EventHandler)) {
  logging.log(logging.Debug, "Requesting gateway")

  let assert Ok(state_uset) = uset.new("State", 1, bravo.Public)

  uset.insert(state_uset, [#("sequence", 0)])

  let req =
    request.new()
    |> request.set_host("gateway.discord.gg")
    |> request.set_scheme(http.Https)
    |> request.set_path("/?v=10&encoding=json")
    |> request.set_header(
      "User-Agent",
      "DiscordBot (https://github.com/cyteon/discord_gleam, 1.0.0)",
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
                let identify = identify.create_packet(bot.token, bot.intents)
                let _ = stratus.send_text_message(conn, identify)

                let new_state = State(has_received_hello: True, s: 0)

                let heartbeat = hello.string_to_data(msg)

                process.start(
                  fn() {
                    repeatedly.call(heartbeat, Nil, fn(_state, _count_) {
                      let sequence = case uset.lookup(state_uset, "sequence") {
                        Ok(sequence) -> sequence.1
                        Error(_) -> 0
                      }

                      let packet =
                        "{\"op\": 1, \"d\": null, \"s\": "
                        <> int.to_string(sequence)
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

                case generic_packet.s {
                  0 -> Nil

                  _ -> {
                    uset.insert(state_uset, [#("sequence", generic_packet.s)])

                    Nil
                  }
                }

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
      uset.delete(state_uset)

      Nil
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
