import gleam/json

pub type IdentifyProperties {
  IdentifyProperties(os: String, browser: String, device: String)
}

pub type IndentifyData {
  IndentifyData(token: String, intents: Int, properties: IdentifyProperties)
}

pub type IdentifyPacket {
  IdentifyPacket(op: Int, d: IndentifyData)
}

pub fn create_packet(token: String) -> String {
  let raw_packet =
    IdentifyPacket(
      op: 2,
      d: IndentifyData(
        token,
        513,
        IdentifyProperties("unix", "discord_gleam", "discord_gleam"),
      ),
    )

  json.object([
    #("op", json.int(raw_packet.op)),
    #(
      "d",
      json.object([
        #("token", json.string(raw_packet.d.token)),
        #("intents", json.int(raw_packet.d.intents)),
        #(
          "properties",
          json.object([
            #("os", json.string(raw_packet.d.properties.os)),
            #("browser", json.string(raw_packet.d.properties.browser)),
            #("device", json.string(raw_packet.d.properties.device)),
          ]),
        ),
      ]),
    ),
  ])
  |> json.to_string
}
