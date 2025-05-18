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

// this will have intents that are required for most bots such as messages, but not events like join/leave (when added)
pub fn default() -> Intents {
  Intents(guild_messages: True, message_content: True, direct_messages: True)
}

// will have all intents enabled
pub fn all() -> Intents {
  Intents(guild_messages: True, message_content: True, direct_messages: True)
}

// i dont know why you would want this, but its here
pub fn none() -> Intents {
  Intents(guild_messages: False, message_content: False, direct_messages: False)
}
