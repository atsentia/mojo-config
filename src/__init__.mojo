"""
Mojo Config Library

Configuration loading from environment variables and TOML files.
Provides type-safe configuration with defaults and validation.

Usage:
    from mojo_config import Config, env, env_int, env_bool, env_float

    # Load from environment with defaults
    var port = env_int("PORT", default=8080)
    var debug = env_bool("DEBUG", default=False)
    var host = env("HOST", default="0.0.0.0")

    # Create typed config struct
    @value
    struct AppConfig:
        var port: Int
        var host: String
        var debug: Bool
        var log_level: String

        fn __init__(out self) raises:
            self.port = env_int("PORT", default=8080)
            self.host = env("HOST", default="0.0.0.0")
            self.debug = env_bool("DEBUG", default=False)
            self.log_level = env("LOG_LEVEL", default="info")

    var config = AppConfig()
"""

from .env import env, env_int, env_float, env_bool, env_list, require_env
from .config import Config, ConfigBuilder, ConfigError
from .toml import TomlParser, TomlValue
