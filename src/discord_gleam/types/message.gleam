import gleam/json

pub type Message {
  Message(content: String)
}

pub fn to_string(msg: Message) -> String {
  json.object([#("content", json.string(msg.content))])
  |> json.to_string
}
