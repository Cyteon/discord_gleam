import gleam/json
import gleam/list

pub type CommandOption {
  CommandOption(name: String, description: String, type_: Int, required: Bool)
}

pub type SlashCommand {
  SlashCommand(
    name: String,
    type_: Int,
    description: String,
    options: List(CommandOption),
  )
}

pub fn command_to_string(raw: SlashCommand) -> String {
  let options = list.map(raw.options, options_to_string)

  json.object([
    #("name", json.string(raw.name)),
    #("type", json.int(raw.type_)),
    #("description", json.string(raw.description)),
    #("options", json.array(options, of: fn(x) { x })),
  ])
  |> json.to_string
}

pub fn options_to_string(option: CommandOption) -> json.Json {
  json.object([
    #("name", json.string(option.name)),
    #("description", json.string(option.description)),
    #("type", json.int(option.type_)),
    #("required", json.bool(option.required)),
  ])
}

type BasicResponseData {
  BasicResponseData(content: String)
}

type BasicResponse {
  BasicResponse(type_: Int, data: BasicResponseData)
}

pub fn make_basic_text_reply(message: String, ephemeral: Bool) -> String {
  let data = BasicResponseData(content: message)
  let response = BasicResponse(type_: 4, data: data)

  let flags = case ephemeral {
    True -> [#("content", json.string(data.content)), #("flags", json.int(64))]
    False -> [#("content", json.string(data.content))]
  }

  json.object([
    #("type", json.int(response.type_)),
    #("data", json.object(flags)),
  ])
  |> json.to_string
}
