import discord_gleam/types/message.{type Embed}
import gleam/json
import gleam/list

pub type Reply {
  Reply(content: String, message_id: String, embeds: List(Embed))
}

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

pub fn embed_to_json(embed: Embed) -> json.Json {
  json.object([
    #("title", json.string(embed.title)),
    #("description", json.string(embed.description)),
    #("color", json.int(embed.color)),
  ])
}
