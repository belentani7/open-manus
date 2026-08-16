# Contributing

## Scope

This repository packages a cleaner Windows onboarding experience for OpenManus with local Ollama models.

## Principles

- keep setup simple
- prefer local-first defaults
- document every operator-facing change
- avoid speculative abstractions

## Contribution checklist

1. keep PowerShell scripts readable
2. preserve Windows compatibility
3. update docs when behavior changes
4. do not commit secrets, caches, or virtual environments

## Suggested structure

- docs in `docs/`
- operator scripts in `scripts/`
- reusable templates in `config/`
- reusable prompt assets in `prompts/`
