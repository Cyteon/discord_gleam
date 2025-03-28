import gleam/json
import gleam/list

pub type Embed {
  Embed(title: String, description: String, color: Int)
}

pub type Message {
  Message(content: String, embeds: List(Embed))
}

pub fn to_string(msg: Message) -> String {
  let embeds_json = list.map(msg.embeds, embed_to_json)
  json.object([
    #("content", json.string(msg.content)),
    #("embeds", json.array(embeds_json, of: fn(x) { x })),
  ])
  |> json.to_string
}

pub fn embed_to_json(embed: Embed) -> json.Json {
  json.object([
    #("title", json.string(embed.title)),
    #("description", json.string(embed.description)),
    #("color", json.int(embed.color)),
  ])
}
