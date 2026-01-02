"""
Tests for mojo-config library.
"""

from testing import assert_equal, assert_true, assert_false

from mojo_config import env, env_int, env_bool, env_float
from mojo_config import Config, ConfigBuilder
from mojo_config import TomlParser


fn test_env_with_default():
    """Test env() returns default when not set."""
    var value = env("NONEXISTENT_VAR_12345", default="fallback")
    assert_equal(value, "fallback")


fn test_env_int_with_default():
    """Test env_int() returns default when not set."""
    var value = env_int("NONEXISTENT_INT_12345", default=42)
    assert_equal(value, 42)


fn test_env_bool_with_default():
    """Test env_bool() returns default when not set."""
    var value = env_bool("NONEXISTENT_BOOL_12345", default=True)
    assert_true(value)


fn test_env_float_with_default():
    """Test env_float() returns default when not set."""
    var value = env_float("NONEXISTENT_FLOAT_12345", default=3.14)
    assert_equal(value, 3.14)


fn test_config_set_get():
    """Test Config set and get."""
    var config = Config()
    config.set("port", "8080")
    config.set("host", "localhost")

    assert_equal(config.get("port"), "8080")
    assert_equal(config.get("host"), "localhost")
    assert_equal(config.get_int("port"), 8080)


fn test_config_builder():
    """Test ConfigBuilder fluent API."""
    var config = ConfigBuilder("")
        .string("host", default="0.0.0.0")
        .int("port", default=3000)
        .bool("debug", default=False)
        .build()

    assert_equal(config.get("host"), "0.0.0.0")
    assert_equal(config.get_int("port"), 3000)
    assert_false(config.get_bool("debug"))


fn test_toml_parser_basic():
    """Test TomlParser with basic TOML."""
    var content = """
# Comment
port = 8080
host = "localhost"
debug = true
rate = 1.5

[database]
url = "postgres://localhost/db"
pool_size = 10
"""

    var parser = TomlParser()
    try:
        parser.parse(content)

        assert_equal(parser.get_int("port"), 8080)
        assert_equal(parser.get_string("host"), "localhost")
        assert_true(parser.get_bool("debug"))
        assert_equal(parser.get_float("rate"), 1.5)
        assert_equal(parser.get_string("database.url"), "postgres://localhost/db")
        assert_equal(parser.get_int("database.pool_size"), 10)
    except e:
        print("TOML parse error:", e)


fn main():
    """Run all tests."""
    print("Running mojo-config tests...")

    test_env_with_default()
    print("  [PASS] test_env_with_default")

    test_env_int_with_default()
    print("  [PASS] test_env_int_with_default")

    test_env_bool_with_default()
    print("  [PASS] test_env_bool_with_default")

    test_env_float_with_default()
    print("  [PASS] test_env_float_with_default")

    test_config_set_get()
    print("  [PASS] test_config_set_get")

    test_config_builder()
    print("  [PASS] test_config_builder")

    test_toml_parser_basic()
    print("  [PASS] test_toml_parser_basic")

    print("\nAll tests passed!")
