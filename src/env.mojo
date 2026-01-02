"""
Environment Variable Loading

Type-safe environment variable loading with defaults.
Uses Python os.environ for cross-platform compatibility.
"""

from python import Python


fn _get_env(key: String) raises -> String:
    """Get environment variable value using Python os module."""
    var os = Python.import_module("os")
    var value = os.environ.get(key, "")
    return str(value)


fn env(key: String, default: String = "") -> String:
    """Get string environment variable with optional default.

    Args:
        key: Environment variable name
        default: Default value if not set

    Returns:
        Environment variable value or default
    """
    try:
        var value = _get_env(key)
        if len(value) == 0:
            return default
        return value
    except:
        return default


fn env_int(key: String, default: Int = 0) -> Int:
    """Get integer environment variable with optional default.

    Args:
        key: Environment variable name
        default: Default value if not set or invalid

    Returns:
        Environment variable as Int or default
    """
    try:
        var value = _get_env(key)
        if len(value) == 0:
            return default
        return atol(value)
    except:
        return default


fn env_float(key: String, default: Float64 = 0.0) -> Float64:
    """Get float environment variable with optional default.

    Args:
        key: Environment variable name
        default: Default value if not set or invalid

    Returns:
        Environment variable as Float64 or default
    """
    try:
        var value = _get_env(key)
        if len(value) == 0:
            return default
        return atof(value)
    except:
        return default


fn env_bool(key: String, default: Bool = False) -> Bool:
    """Get boolean environment variable with optional default.

    Truthy values: "true", "1", "yes", "on" (case-insensitive)
    Falsy values: "false", "0", "no", "off" (case-insensitive)

    Args:
        key: Environment variable name
        default: Default value if not set

    Returns:
        Environment variable as Bool or default
    """
    try:
        var value = _get_env(key).lower()
        if len(value) == 0:
            return default

        # Truthy values
        if value == "true" or value == "1" or value == "yes" or value == "on":
            return True

        # Falsy values
        if value == "false" or value == "0" or value == "no" or value == "off":
            return False

        return default
    except:
        return default


fn env_list(key: String, separator: String = ",", default: List[String] = List[String]()) -> List[String]:
    """Get list environment variable with optional default.

    Splits value by separator (default: comma).

    Args:
        key: Environment variable name
        separator: Value separator (default: ",")
        default: Default list if not set

    Returns:
        Environment variable as List[String] or default
    """
    try:
        var value = _get_env(key)
        if len(value) == 0:
            return default

        var result = List[String]()
        var parts = value.split(separator)
        for part in parts:
            var trimmed = part.strip()
            if len(trimmed) > 0:
                result.append(trimmed)
        return result
    except:
        return default


fn require_env(key: String) raises -> String:
    """Get required environment variable, raising if not set.

    Args:
        key: Environment variable name

    Returns:
        Environment variable value

    Raises:
        Error if environment variable is not set
    """
    var value = _get_env(key)
    if len(value) == 0:
        raise Error("Required environment variable not set: " + key)
    return value


struct EnvPrefix:
    """Helper for loading environment variables with a prefix.

    Usage:
        var cfg = EnvPrefix("MYAPP_")
        var port = cfg.get_int("PORT", default=8080)  # Reads MYAPP_PORT
    """

    var prefix: String

    fn __init__(out self, prefix: String):
        """Create environment loader with prefix."""
        self.prefix = prefix

    fn get(self, key: String, default: String = "") -> String:
        """Get string with prefix."""
        return env(self.prefix + key, default)

    fn get_int(self, key: String, default: Int = 0) -> Int:
        """Get int with prefix."""
        return env_int(self.prefix + key, default)

    fn get_float(self, key: String, default: Float64 = 0.0) -> Float64:
        """Get float with prefix."""
        return env_float(self.prefix + key, default)

    fn get_bool(self, key: String, default: Bool = False) -> Bool:
        """Get bool with prefix."""
        return env_bool(self.prefix + key, default)

    fn require(self, key: String) raises -> String:
        """Get required with prefix."""
        return require_env(self.prefix + key)
