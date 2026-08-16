# Security

## Local-first baseline

- use Ollama locally whenever possible
- avoid storing real API secrets in tracked files
- keep `.env`, local configs, caches, and logs untracked

## Repository hygiene

- review config before pushing
- do not commit private prompts with credentials
- do not commit upstream virtual environments

## Suggested practice

1. use `api_key = "ollama"` only for local Ollama
2. if switching to a hosted provider, move the real key to environment variables
3. keep the upstream `config.toml` personal and local when it contains secrets

## Risk areas

- accidental commit of edited config
- mixing local and hosted provider settings
- publishing logs with sensitive prompts or file paths
