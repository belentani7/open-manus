# OPEN-MANUS WINDOWS — PROJECT MASTER PROMPT

## Identity and source of truth
This repository is a Spanish-language Windows 11 onboarding and operations toolkit for running the **external upstream OpenManus project with local Ollama**. It is not the upstream OpenManus codebase, not a hosted agent platform, and not a reason to merge independent repos. Preserve the existing PDFs/transcripts as historical reference and keep scripts, config, guides, tests and dependency assumptions aligned with the current upstream installation flow.

## Maximum practical product
Enable a Windows user to safely install, configure, start, check, update and recover the local agent with clear errors, predictable permissions and no silent data loss. A complete delivery includes an offline-first preflight, repeatable provisioning, explicit local model selection, CLI/Web/MCP launchers with accurate entrypoint checks, secure update/rollback procedures, privacy guarantees and a checked compatibility matrix for supported upstream revisions.

## Engineering delivery milestones
1. **Reliable installation:** upfront tool checks, pinned/compatible Python, model availability validation, idempotent venv setup, clear nonzero exit handling, external network operations only on user command, and config initialization that never overwrites user secrets.
2. **Safe upgrades:** validate repository root/branch, protect uncommitted or untracked work, fast-forward-only pulls, explicit dependency-change summary, backup/restore of configuration, optional dry-run and rollback instructions.
3. **Runtime diagnostics:** CLI/Web/MCP entrypoint validation, process/port health, Ollama availability and model check, troubleshooting commands with redactable diagnostics.
4. **Security and privacy:** bind web UI locally by default; no arbitrary public exposure, credential printing or remote execution by default. Document exactly which upstream components might contact external services; protect user data and workspace directories.
5. **Quality:** offline unit tests, Windows PowerShell parser checks, local dummy Git remote integration tests, CI that executes instead of checkout-only baseline, explicit release gates for updating upstream to new revisions.

## Agent operating instruction
Inspect upstream compatibility and the repository's actual scripts and tests first. Implement source changes and regressions in THIS repository, not speculative pages. Respect original names, licensing and language. Never replace config.toml, rewrite local files, run paid models or upgrade user environments without explicit authorization. Verify PowerShell on actual Windows; a test written or a workflow that terminates without assigned runner is not evidence of passing. Open reviewable PRs with exact commits and remaining checks; move to a different older active project in subsequent Factory executions.
