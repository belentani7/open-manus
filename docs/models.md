# Model Guide

## Recommended defaults

### Balanced

- model: `qwen2.5:7b`
- use case: general assistant work, coding help, tool orchestration

### Lightweight

- model: `qwen2.5:3b`
- use case: lower RAM machines, faster local iteration

## Ollama commands

```powershell
ollama pull qwen2.5:7b
ollama pull qwen2.5:3b
ollama list
```

## Config example

```toml
[llm]
model = "qwen2.5:7b"
base_url = "http://localhost:11434/v1"
api_key = "ollama"
max_tokens = 4096
temperature = 0.7
```

## Selection advice

- choose `7b` if the machine is stable and has enough memory
- choose `3b` for quick local testing
- keep one default model in config and swap only when needed

## Notes

- model availability depends on local Ollama pulls
- performance varies by CPU, RAM, disk, and GPU support
