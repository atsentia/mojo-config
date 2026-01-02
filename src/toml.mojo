"""
Simple TOML Parser

Basic TOML parsing for configuration files.
Supports: strings, integers, floats, booleans, arrays, tables.
"""


@value
struct TomlValue:
    """A TOML value that can be string, int, float, bool, or nested."""

    var string_value: String
    var int_value: Int
    var float_value: Float64
    var bool_value: Bool
    var value_type: String  # "string", "int", "float", "bool", "array", "table"

    fn __init__(out self):
        self.string_value = ""
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = False
        self.value_type = "string"

    @staticmethod
    fn from_string(value: String) -> TomlValue:
        var v = TomlValue()
        v.string_value = value
        v.value_type = "string"
        return v

    @staticmethod
    fn from_int(value: Int) -> TomlValue:
        var v = TomlValue()
        v.int_value = value
        v.value_type = "int"
        return v

    @staticmethod
    fn from_float(value: Float64) -> TomlValue:
        var v = TomlValue()
        v.float_value = value
        v.value_type = "float"
        return v

    @staticmethod
    fn from_bool(value: Bool) -> TomlValue:
        var v = TomlValue()
        v.bool_value = value
        v.value_type = "bool"
        return v

    fn as_string(self) -> String:
        if self.value_type == "string":
            return self.string_value
        elif self.value_type == "int":
            return str(self.int_value)
        elif self.value_type == "float":
            return str(self.float_value)
        elif self.value_type == "bool":
            return "true" if self.bool_value else "false"
        return ""

    fn as_int(self) -> Int:
        if self.value_type == "int":
            return self.int_value
        elif self.value_type == "string":
            try:
                return atol(self.string_value)
            except:
                return 0
        return 0

    fn as_float(self) -> Float64:
        if self.value_type == "float":
            return self.float_value
        elif self.value_type == "int":
            return Float64(self.int_value)
        elif self.value_type == "string":
            try:
                return atof(self.string_value)
            except:
                return 0.0
        return 0.0

    fn as_bool(self) -> Bool:
        if self.value_type == "bool":
            return self.bool_value
        elif self.value_type == "string":
            var v = self.string_value.lower()
            return v == "true" or v == "1" or v == "yes"
        return False


struct TomlParser:
    """Simple TOML parser.

    Usage:
        var parser = TomlParser()
        var data = parser.parse_file("config.toml")
        var port = data.get("server.port").as_int()
    """

    var data: Dict[String, TomlValue]
    var current_section: String

    fn __init__(out self):
        self.data = Dict[String, TomlValue]()
        self.current_section = ""

    fn parse(inout self, content: String) raises:
        """Parse TOML content string."""
        var lines = content.split("\n")

        for line in lines:
            var trimmed = line.strip()

            # Skip empty lines and comments
            if len(trimmed) == 0 or trimmed.startswith("#"):
                continue

            # Section header [section]
            if trimmed.startswith("[") and trimmed.endswith("]"):
                self.current_section = trimmed[1:-1]
                continue

            # Key = value
            if "=" in trimmed:
                var parts = trimmed.split("=", 1)
                if len(parts) == 2:
                    var key = parts[0].strip()
                    var value = parts[1].strip()

                    # Full key with section prefix
                    var full_key = key
                    if len(self.current_section) > 0:
                        full_key = self.current_section + "." + key

                    # Parse value
                    var parsed = self._parse_value(value)
                    self.data[full_key] = parsed

    fn parse_file(inout self, path: String) raises:
        """Parse TOML file."""
        from python import Python
        var pathlib = Python.import_module("pathlib")
        var content = str(pathlib.Path(path).read_text())
        self.parse(content)

    fn _parse_value(self, value: String) -> TomlValue:
        """Parse a TOML value string."""
        var v = value.strip()

        # Boolean
        if v == "true":
            return TomlValue.from_bool(True)
        if v == "false":
            return TomlValue.from_bool(False)

        # String (quoted)
        if (v.startswith('"') and v.endswith('"')) or (v.startswith("'") and v.endswith("'")):
            return TomlValue.from_string(v[1:-1])

        # Integer or Float
        try:
            if "." in v:
                return TomlValue.from_float(atof(v))
            else:
                return TomlValue.from_int(atol(v))
        except:
            pass

        # Unquoted string
        return TomlValue.from_string(v)

    fn get(self, key: String) -> TomlValue:
        """Get value by key (supports dotted keys)."""
        if key in self.data:
            return self.data[key]
        return TomlValue()

    fn get_string(self, key: String, default: String = "") -> String:
        """Get string value with default."""
        if key in self.data:
            return self.data[key].as_string()
        return default

    fn get_int(self, key: String, default: Int = 0) -> Int:
        """Get int value with default."""
        if key in self.data:
            return self.data[key].as_int()
        return default

    fn get_float(self, key: String, default: Float64 = 0.0) -> Float64:
        """Get float value with default."""
        if key in self.data:
            return self.data[key].as_float()
        return default

    fn get_bool(self, key: String, default: Bool = False) -> Bool:
        """Get bool value with default."""
        if key in self.data:
            return self.data[key].as_bool()
        return default

    fn has(self, key: String) -> Bool:
        """Check if key exists."""
        return key in self.data

    fn keys(self) -> List[String]:
        """Get all keys."""
        var result = List[String]()
        for key in self.data:
            result.append(key)
        return result
