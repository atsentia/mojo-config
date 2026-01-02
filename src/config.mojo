"""
Typed Configuration

Provides ConfigBuilder for fluent configuration loading with validation.
"""

from .env import env, env_int, env_float, env_bool, env_list


struct ConfigError(Error):
    """Configuration error with details."""

    var key: String
    var message: String

    fn __init__(out self, key: String, message: String):
        self.key = key
        self.message = message

    fn __str__(self) -> String:
        return "ConfigError[" + self.key + "]: " + self.message


@value
struct ConfigValue:
    """A configuration value with metadata."""

    var key: String
    var value: String
    var source: String  # "env", "file", "default"
    var required: Bool

    fn as_string(self) -> String:
        return self.value

    fn as_int(self) -> Int:
        try:
            return atol(self.value)
        except:
            return 0

    fn as_float(self) -> Float64:
        try:
            return atof(self.value)
        except:
            return 0.0

    fn as_bool(self) -> Bool:
        var v = self.value.lower()
        return v == "true" or v == "1" or v == "yes" or v == "on"


struct Config:
    """Configuration container with typed accessors.

    Usage:
        var config = Config()
        config.set("port", "8080", source="env")
        var port = config.get_int("port", default=3000)
    """

    var values: Dict[String, ConfigValue]
    var prefix: String

    fn __init__(out self, prefix: String = ""):
        """Create empty config with optional prefix."""
        self.values = Dict[String, ConfigValue]()
        self.prefix = prefix

    fn set(inout self, key: String, value: String, source: String = "code", required: Bool = False):
        """Set a configuration value."""
        self.values[key] = ConfigValue(
            key=key,
            value=value,
            source=source,
            required=required,
        )

    fn get(self, key: String, default: String = "") -> String:
        """Get string value with default."""
        if key in self.values:
            return self.values[key].value
        return default

    fn get_int(self, key: String, default: Int = 0) -> Int:
        """Get int value with default."""
        if key in self.values:
            return self.values[key].as_int()
        return default

    fn get_float(self, key: String, default: Float64 = 0.0) -> Float64:
        """Get float value with default."""
        if key in self.values:
            return self.values[key].as_float()
        return default

    fn get_bool(self, key: String, default: Bool = False) -> Bool:
        """Get bool value with default."""
        if key in self.values:
            return self.values[key].as_bool()
        return default

    fn has(self, key: String) -> Bool:
        """Check if key exists."""
        return key in self.values

    fn keys(self) -> List[String]:
        """Get all config keys."""
        var result = List[String]()
        for key in self.values:
            result.append(key)
        return result

    fn validate(self) raises:
        """Validate all required values are set."""
        for key in self.values:
            var cv = self.values[key]
            if cv.required and len(cv.value) == 0:
                raise ConfigError(key, "Required configuration not set")


struct ConfigBuilder:
    """Fluent builder for Config.

    Usage:
        var config = ConfigBuilder("MYAPP_")
            .string("host", default="localhost")
            .int("port", default=8080)
            .bool("debug", default=False)
            .required("api_key")
            .build()
    """

    var config: Config
    var prefix: String

    fn __init__(out self, prefix: String = ""):
        """Create builder with optional environment prefix."""
        self.prefix = prefix
        self.config = Config(prefix)

    fn string(inout self, key: String, default: String = "") -> Self:
        """Add string config from environment."""
        var env_key = self.prefix + key.upper()
        var value = env(env_key, default)
        self.config.set(key, value, source="env")
        return self

    fn int(inout self, key: String, default: Int = 0) -> Self:
        """Add int config from environment."""
        var env_key = self.prefix + key.upper()
        var value = env_int(env_key, default)
        self.config.set(key, str(value), source="env")
        return self

    fn float(inout self, key: String, default: Float64 = 0.0) -> Self:
        """Add float config from environment."""
        var env_key = self.prefix + key.upper()
        var value = env_float(env_key, default)
        self.config.set(key, str(value), source="env")
        return self

    fn bool(inout self, key: String, default: Bool = False) -> Self:
        """Add bool config from environment."""
        var env_key = self.prefix + key.upper()
        var value = env_bool(env_key, default)
        self.config.set(key, str(value).lower(), source="env")
        return self

    fn required(inout self, key: String) raises -> Self:
        """Add required string config from environment."""
        var env_key = self.prefix + key.upper()
        var value = env(env_key, "")
        if len(value) == 0:
            raise ConfigError(key, "Required environment variable not set: " + env_key)
        self.config.set(key, value, source="env", required=True)
        return self

    fn build(self) -> Config:
        """Build and return the config."""
        return self.config
