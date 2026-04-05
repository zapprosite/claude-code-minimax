# Agents

Place custom agents for this project here.

## Adding an Agent

Create a `.md` file with the agent definition:

```yaml
---
name: <agent-name>
description: <1-line description>
type: general-purpose
model: inherit
memory: session
tools:
  allow:
    - Bash
    - Read
    - Grep
  deny:
    - Bash(zfs destroy*)
---
```

## Using an Agent

Invoke via `/agent <agent-name>` in conversation.

## Available Agents

| Agent | Purpose |
|-------|---------|
| (none yet) | Add your custom agents here |
