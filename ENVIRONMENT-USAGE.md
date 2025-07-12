# Environment-Specific Development Helper

## Usage

```bash
./dev.sh <command> [environment]
```

## Environments

- **`dev`** (default) - Development mode with debugging overrides
- **`prod`** - Production mode (no development overrides)

## Commands

| Command | Dev Mode | Prod Mode |
|---------|----------|-----------|
| `start` | Uses override (debug logs) | Base config only |
| `restart` | Uses override (debug logs) | Base config only |
| `build` | Uses override (debug logs) | Base config only |
| `rebuild` | Uses override (debug logs) | Base config only |
| `logs` | Full debug output | Standard logs |
| `status` | Shows debug containers | Shows prod containers |

## Examples

```bash
# Development (default)
./dev.sh start           # Uses docker-compose.override.yml
./dev.sh start dev       # Same as above (explicit)
./dev.sh logs dev api    # Show API logs with debug info

# Production
./dev.sh start prod      # Uses only compose.yaml
./dev.sh restart prod    # Production restart
./dev.sh logs prod api   # Show API logs (no debug)
```

## Key Differences

### Development Mode (dev)
- ✅ `LOKI_LOG_LEVEL=debug` (verbose logging)
- ✅ Custom Loki configuration mounted
- ✅ Development debugging options available
- ✅ Uses `docker-compose.override.yml`

### Production Mode (prod)
- ❌ No debug logging
- ❌ Standard Loki configuration
- ❌ No development overrides
- ✅ Uses only `compose.yaml`

## Environment Detection

The script automatically detects which mode you're using:

```bash
🔧 Running in DEVELOPMENT mode (with development overrides)
🚀 Running in PRODUCTION mode (no development overrides)
```
