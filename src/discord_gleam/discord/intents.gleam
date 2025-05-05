pub type Intents {
  Intents(guild_messages: Bool, message_content: Bool, direct_messages: Bool)
}

pub fn intents_to_bitfield(intents: Intents) -> Int {
  let bitfield = 0

  let bitfield = case intents.guild_messages {
    True -> bitfield + 512
    // 1 << 9
    False -> bitfield
  }

  let bitfield = case intents.direct_messages {
    True -> bitfield + 4096
    // 1 << 12
    False -> bitfield
  }

  let bitfield = case intents.message_content {
    True -> bitfield + 32_768
    // 1 << 15
    False -> bitfield
  }

  bitfield
}
