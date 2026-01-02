# mojo-config

Configuration loading from environment variables and TOML files for Mojo applications.

## Features

- **Environment Variables**: Type-safe loading with defaults
- **TOML Parsing**: Simple TOML file parsing
- **Config Builder**: Fluent API for building configuration
- **Prefix Support**: Load env vars with a common prefix

## Installation

Add to your `pixi.toml`:

```toml
[workspace.dependencies]
mojo-config = { path = "../mojo-libs/mojo-config" }
```

## Usage

### Environment Variables

```mojo
from mojo_config import env, env_int, env_bool, env_float

# Load with defaults
var host = env("HOST", default="localhost")
var port = env_int("PORT", default=8080)
var debug = env_bool("DEBUG", default=False)
var rate = env_float("RATE_LIMIT", default=1.5)

# Required (raises if not set)
var api_key = require_env("API_KEY")

# Load with prefix
from mojo_config import EnvPrefix
var cfg = EnvPrefix("MYAPP_")
var db_host = cfg.get("DB_HOST", default="localhost")  # Reads MYAPP_DB_HOST
```

### Config Builder

```mojo
from mojo_config import ConfigBuilder

var config = ConfigBuilder("MYAPP_")
    .string("host", default="0.0.0.0")
    .int("port", default=8080)
    .bool("debug", default=False)
    .required("api_key")  # Raises if MYAPP_API_KEY not set
    .build()

print("Port:", config.get_int("port"))
print("Debug:", config.get_bool("debug"))
```

### TOML Files

```mojo
from mojo_config import TomlParser

var parser = TomlParser()
parser.parse_file("config.toml")

var port = parser.get_int("server.port", default=3000)
var host = parser.get_string("server.host", default="localhost")
```

Example `config.toml`:

```toml
# Application config
debug = true

[server]
host = "0.0.0.0"
port = 8080

[database]
url = "postgres://localhost/mydb"
pool_size = 10
```

## API Reference

### Environment Functions

| Function | Description |
|----------|-------------|
| `env(key, default="")` | Get string env var |
| `env_int(key, default=0)` | Get int env var |
| `env_float(key, default=0.0)` | Get float env var |
| `env_bool(key, default=False)` | Get bool env var |
| `env_list(key, separator=",")` | Get list env var |
| `require_env(key)` | Get required env var (raises if not set) |

### Config Class

| Method | Description |
|--------|-------------|
| `set(key, value)` | Set a config value |
| `get(key, default)` | Get string value |
| `get_int(key, default)` | Get int value |
| `get_float(key, default)` | Get float value |
| `get_bool(key, default)` | Get bool value |
| `has(key)` | Check if key exists |
| `validate()` | Validate required values |

### TomlParser Class

| Method | Description |
|--------|-------------|
| `parse(content)` | Parse TOML string |
| `parse_file(path)` | Parse TOML file |
| `get_string(key, default)` | Get string value |
| `get_int(key, default)` | Get int value |
| `get_float(key, default)` | Get float value |
| `get_bool(key, default)` | Get bool value |

## License

MIT
