# discord_gleam

[![Package Version](https://img.shields.io/hexpm/v/discord_gleam)](https://hex.pm/packages/discord_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/discord_gleam/)

```sh
gleam add discord_gleam
```
```gleam
import discord_gleam

pub fn main() {
  todo
}
```

Further documentation can be found at <https://hexdocs.pm/discord_gleam>.

## Development

```sh
gleam test  # Run the tests
```

## Features:
| Feature | Status |
| --- | --- |
| Basic events         | ✅ |
| More events          | 🔨 |
| Sending messages     | ✅ |
| Ban/kick             | ✅ |
| Deleting messages    | ✅ |
| Embeds               | ✅ |
| Basic Slash commands | ✅ |

✅ - Done | 🔨 - In Progress | 📆 - Planned | ❌ - Not Planned

## Supported events:
- READY
- MESSAGE_CREATE
- MESSAGE_DELETE
- INTERACTION_CREATE
