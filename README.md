# discord_gleam

[![Package Version](https://img.shields.io/hexpm/v/discord_gleam)](https://hex.pm/packages/discord_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/discord_gleam/)

```sh
gleam add discord_gleam
```

```gleam
import discord_gleam
import discord_gleam/event_handler
import discord_gleam/types/message
import discord_gleam/discord/intents
import gleam/list
import gleam/string
import logging

pub fn main() {
  logging.configure()
  logging.set_level(logging.Info)

  let bot = discord_gleam.bot("YOUR TOKEN", "YOUR CLIENT ID", intents.default())

  discord_gleam.run(bot, [event_handler])
}

fn event_handler(bot, packet: event_handler.Packet) {
  case packet {
    event_handler.MessagePacket(message) -> {
      logging.log(logging.Info, "Got message: " <> message.d.content)

      case message.d.content {
        "!ping" -> {
          discord_gleam.send_message(bot, message.d.channel_id, "Pong!", [])
        }

        _ -> Nil
      }
    }
    
    _ -> Nil
  }
}
```

Further documentation can be found at <https://hexdocs.pm/discord_gleam>.

## Development

```sh
gleam test  # Run the tests
```

## Features:

| Feature              | Status |
| -------------------- | ------ |
| Basic events         | ✅     |
| More events          | 🔨     |
| Sending messages     | ✅     |
| Ban/kick             | ✅     |
| Deleting messages    | ✅     |
| Embeds               | ✅     |
| Basic Slash commands | ✅     |
| Messge Cache         | ✅     |
| Intents              | 🔨     |

✅ - Done | 🔨 - In Progress | 📆 - Planned | ❌ - Not Planned

## Supported events:

- READY
- MESSAGE_CREATE
- MESSAGE_DELETE
- INTERACTION_CREATE
