"""
Example: Configuration Management

Demonstrates:
- Loading from environment variables
- Type-safe configuration with defaults
- TOML file parsing
- Required vs optional configuration
"""

from mojo_config import Config, ConfigBuilder, ConfigError
from mojo_config import env, env_int, env_float, env_bool, env_list, require_env


fn environment_variables_example():
    """Load configuration from environment."""
    print("=== Environment Variables ===")

    # Basic types with defaults
    var host = env("HOST", default="0.0.0.0")
    var port = env_int("PORT", default=8080)
    var debug = env_bool("DEBUG", default=False)
    var timeout = env_float("TIMEOUT", default=30.0)

    print("HOST: " + host)
    print("PORT: " + String(port))
    print("DEBUG: " + String(debug))
    print("TIMEOUT: " + String(timeout))

    # List values (comma-separated)
    var allowed_origins = env_list("ALLOWED_ORIGINS", default="localhost,127.0.0.1")
    print("ALLOWED_ORIGINS: " + allowed_origins)
    print("")


fn required_config_example() raises:
    """Required configuration (fails if missing)."""
    print("=== Required Configuration ===")

    # This will raise if not set
    # var api_key = require_env("API_KEY")

    print("require_env('API_KEY') - raises if missing")
    print("Use for secrets and critical config")
    print("")


fn typed_config_example():
    """Create typed configuration struct."""
    print("=== Typed Config Struct ===")

    @value
    struct DatabaseConfig:
        var host: String
        var port: Int
        var name: String
        var pool_size: Int

        fn __init__(out self) raises:
            self.host = env("DB_HOST", default="localhost")
            self.port = env_int("DB_PORT", default=5432)
            self.name = env("DB_NAME", default="app")
            self.pool_size = env_int("DB_POOL_SIZE", default=10)

    @value
    struct AppConfig:
        var host: String
        var port: Int
        var debug: Bool
        var log_level: String

        fn __init__(out self) raises:
            self.host = env("HOST", default="0.0.0.0")
            self.port = env_int("PORT", default=8080)
            self.debug = env_bool("DEBUG", default=False)
            self.log_level = env("LOG_LEVEL", default="info")

    print("struct DatabaseConfig - DB settings")
    print("struct AppConfig - Application settings")
    print("Both load from env vars with defaults")
    print("")


fn config_builder_example():
    """Use ConfigBuilder for complex configuration."""
    print("=== Config Builder ===")

    var config = ConfigBuilder() \
        .set("app.name", "my-service") \
        .set("app.version", "1.0.0") \
        .set_from_env("app.port", "PORT", default="8080") \
        .set_from_env("app.debug", "DEBUG", default="false") \
        .build()

    print("ConfigBuilder for programmatic config")
    print('  .set("key", "value")')
    print('  .set_from_env("key", "ENV_VAR", default="default")')
    print("")


fn toml_config_example():
    """Parse configuration from TOML file."""
    print("=== TOML Configuration ===")

    var toml_content = """
[server]
host = "0.0.0.0"
port = 8080

[database]
host = "localhost"
port = 5432
name = "myapp"
pool_size = 10

[features]
enable_cache = true
enable_metrics = true
"""

    print("config.toml:")
    print(toml_content)

    # Parse TOML
    # var config = TomlParser.parse(toml_content)
    # var port = config.get_int("server.port")

    print("Access: config.get_int('server.port')")
    print("")


fn main() raises:
    print("mojo-config: Configuration Management\n")

    environment_variables_example()
    required_config_example()
    typed_config_example()
    config_builder_example()
    toml_config_example()

    print("=" * 50)
    print("Best practices:")
    print("  - Use env vars for runtime config")
    print("  - Use TOML for static config")
    print("  - Always provide sensible defaults")
    print("  - Use require_env() for secrets")
