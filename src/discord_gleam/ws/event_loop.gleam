import gleam/erlang/process
import gleam/function
import gleam/http
import gleam/http/request
import gleam/option
import gleam/otp/actor
import logging
import stratus

pub type Msg {
  Close
  TimeUpdated(String)
}

pub fn main(token: String) {
  logging.log(logging.Debug, "Requesting gateway")

  let req =
    request.new()
    |> request.set_host("gateway.discord.gg")
    |> request.set_scheme(http.Http)
    //|> request.set_port(80)
    |> request.set_path("/?v=10&encoding=json")
    |> request.set_header(
      "User-Agent",
      "DiscordBot, lang: Gleam, library: https://github.com/cyteon/discord_gleam",
    )

  logging.log(logging.Debug, "Creating builder")

  let builder =
    stratus.websocket(
      request: req,
      init: fn() {
        logging.log(logging.Debug, "Builder init")

        #(Nil, option.None)
      },
      loop: fn(msg, state, conn) {
        case msg {
          stratus.Text(msg) -> {
            logging.log(logging.Debug, msg)
            actor.continue(state)
          }

          stratus.User(_) -> {
            logging.log(logging.Debug, "User message")
            actor.continue(state)
          }

          stratus.Binary(_) -> {
            logging.log(logging.Debug, "Binary message")
            actor.continue(state)
          }
        }
      },
    )
    |> stratus.on_close(fn(_state) { logging.log(logging.Info, "oh noooo") })

  let assert Ok(subj) = stratus.initialize(builder)

  //let id_packet = identify.create_packet(token)
  //stratus.send_message(subj, id_packet)

  let done =
    process.new_selector()
    |> process.selecting_process_down(
      process.monitor_process(process.subject_owner(subj)),
      function.identity,
    )
    |> process.select_forever

  process.sleep(10_000)

  logging.log(logging.Info, "websocket go bye bye")
}
