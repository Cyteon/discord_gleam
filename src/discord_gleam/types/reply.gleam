import discord_gleam/types/message.{type Embed}
import gleam/json
import gleam/list

/// Our reply type, which is used to send replies to messages
pub type Reply {
  Reply(content: String, message_id: String, embeds: List(Embed))
}

/// Convert a reply to a JSON string
pub fn to_string(msg: Reply) -> String {
  let embeds_json = list.map(msg.embeds, embed_to_json)
  json.object([
    #("content", json.string(msg.content)),
    #("embeds", json.array(embeds_json, of: fn(x) { x })),
    #(
      "message_reference",
      json.object([#("message_id", json.string(msg.message_id))]),
    ),
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
