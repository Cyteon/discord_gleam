import gleam/json
import gleam/list

/// An embed, simplified for now. \
/// See https://discord.com/developers/docs/resources/channel#embed-object
pub type Embed {
  Embed(title: String, description: String, color: Int)
  // TODO: add more fields
}

/// Our message type, holds content and embeds and is passed to the low-level networking functions
pub type Message {
  Message(content: String, embeds: List(Embed))
}

/// Convert a message to a JSON string
pub fn to_string(msg: Message) -> String {
  let embeds_json = list.map(msg.embeds, embed_to_json)
  json.object([
    #("content", json.string(msg.content)),
    #("embeds", json.array(embeds_json, of: fn(x) { x })),
  ])
  |> json.to_string
}

/// Convert an embed to a JSON object
pub fn embed_to_json(embed: Embed) -> json.Json {
  json.object([
    #("title", json.string(embed.title)),
    #("description", json.string(embed.description)),
    #("color", json.int(embed.color)),
  ])
}
