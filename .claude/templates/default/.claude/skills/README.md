# Skills

Place custom skills for this project here.

## Adding a Skill

Create a `skill.md` file with YAML frontmatter:

```yaml
---
name: <skill-name>
description: <1-line description>
context: fork
disable-model-invocation: true
allowed-tools:
  - Bash
  - Read
paths:
  - ~/.claude/skills/**
---
```

## Using a Skill

Invoke via `/skill <skill-name>` or `--skill <skill-name>` in command.

## Available Skills

| Skill | Purpose |
|-------|---------|
| (none yet) | Add your custom skills here |
