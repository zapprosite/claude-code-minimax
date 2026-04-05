# Claude Code MiniMax Setup

### One-Command Setup for Claude Code with MiniMax M2.7 + Claude Pro OAuth

<p align="center">
  <img src="https://img.shields.io/badge/MiniMax-M2.7-00ff88?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDAgMTAwIj48Y2lyY2xlIGN4PSI1MCIgY3k9IjUwIiByPSI0NSIgZmlsbD0id2hpdGUiLz48Y2lyY2xlIGN4PSI1MCIgY3k9IjUwIiByPSIyMCIgZmlsbD0iIzAwZmY4OCIvPjwvc3ZnPg==&logoColor=white" alt="MiniMax M2.7"/>
  <img src="https://img.shields.io/badge/Claude%20Pro-ff6644?style=for-the-badge&logo=anthropic&logoColor=white" alt="Claude Pro"/>
  <img src="https://img.shields.io/badge/7-Agents-4488ff?style=for-the-badge" alt="Agents"/>
  <img src="https://img.shields.io/badge/14-Skills-aa66ff?style=for-the-badge" alt="Skills"/>
  <img src="https://img.shields.io/badge/Cron-00ccff?style=for-the-badge" alt="Cron Automation"/>
  <img src="https://img.shields.io/badge/7-MCPs-f59e0b?style=for-the-badge" alt="MCP Servers"/>
</p>

<p align="center">
  <a href="https://github.com/zapprosite/claude-code-minimax/stargazers">
    <img src="https://img.shields.io/github/stars/zapprosite/claude-code-minimax?style=flat-square&color=ffdd00" alt="Stars"/>
  </a>
  <a href="https://github.com/zapprosite/claude-code-minimax/network/members">
    <img src="https://img.shields.io/github/forks/zapprosite/claude-code-minimax?style=flat-square&color=00ff88" alt="Forks"/>
  </a>
  <a href="https://github.com/zapprosite/claude-code-minimax/issues">
    <img src="https://img.shields.io/github/issues/zapprosite/claude-code-minimax?style=flat-square&color=ff6644" alt="Issues"/>
  </a>
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License"/>
</p>

---

## ⚡ 30-Second Setup

```bash
# Clone
git clone https://github.com/zapprosite/claude-code-minimax.git
cd claude-code-minimax

# Install (copies everything to ~/.claude/)
cp -r .claude ~/
mkdir -p ~/.mcp-data/memory-keeper ~/.claude/logs ~/.claude/pipelines

# Add API key
echo 'export MINIMAX_API_KEY="your_key_here"' >> ~/.claude/.secrets
chmod 600 ~/.claude/.secrets

# Reload & test
source ~/.bashrc
cm -p "Hello"
```

---

## 🤖 7 Custom Agents

| Command | Alias | What It Does |
|---------|-------|-------------|
| `/agent modo-dormir` | `/md` | 🔥 Scan repos while you sleep — generates pipeline + tests |
| `/agent review-zappro` | `/rr` | Deep code review with security focus |
| `/agent security-audit` | `/sa` | OWASP Top 10 + secrets detection |
| `/agent deploy-check` | `/dc` | Snapshot + health check + rollback |
| `/agent context-optimizer` | `/co` | Optimize context window usage |
| `/agent repo-onboard` | `/ro` | Bootstrap new repos with template |
| `/agent executive-ceo` | `/ec` | Strategic architecture decisions |

---

## ⚙️ 13 Productivity Skills

| Command | Alias | What It Does |
|---------|-------|-------------|
| `--skill snapshot-safe` | `/ss` | ZFS snapshot with preflight checklist |
| `--skill deploy-validate` | `/dv` | Pre-deploy health validation |
| `--skill context-prune` | `/cp` | Clean old memory-keeper sessions |
| `--skill secrets-audit` | `/sec` | Scan for exposed secrets |
| `--skill mcp-health` | `/mcp` | Diagnose all MCP servers |
| `--skill repo-scan` | `/rs` | Detect tasks in TASKMASTER/ADR/slices |
| `--skill pipeline-gen` | `/pg` | Generate pipeline.json |
| `--skill smoke-test-gen` | `/st` | Generate smoke tests + curl scripts |
| `--skill human-gates` | `/hg` | Identify approval blockers |
| `--skill skill-auditor` | `/sau` | Scan skills for security issues |
| `--skill release-notes` | `/rn` | Auto-changelog from git history |
| `--skill devops-pipeline` | `/dp` | Generate CI/CD + pre-commit hooks |
| `--skill test-coverage` | `/tc` | Find untested branches, generate tests |
| `--skill oss-ready` | `/oss` | Generate README, CONTRIBUTING, LICENSE |
| `--skill skill-creator` | `/sc` | Interactive 4-phase skill builder |

---

## 🔌 7 Pre-configured MCP Servers

```
filesystem  → Advanced file ops
git         → Full Git integration  
context7    → Codebase context
memory-keeper → Persistent SQLite knowledge graph
github      → Issues + PRs + repos
playwright  → Browser automation
tavily      → Web search
```

---

## ⏰ Automated Cron Jobs

Everything runs automatically while you sleep:

```cron
# 02:00 — Backup memory
# 03:00 — 🔥 Modo Dormir (scan repo, generate pipeline)
# 04:00 — Code review
# 05:00 — Test coverage check
# 06:00 — Secrets audit
```

---

## 🌙 Modo Dormir — The Star Feature

```bash
# Run before sleep
/md scan /srv/monorepo

# Wake up to:
~/.claude/pipelines/
├── monorepo-20260405-pipeline.json    # Phases + human gates
├── monorepo-20260405-smoke-tests.sh  # Ready to run
├── monorepo-20260405-curl-scripts.sh
└── monorepo-20260405-report.md         # Summary
```

---

## 📊 Cost Breakdown

| Service | Monthly | Use |
|---------|---------|-----|
| MiniMax M2.7 | $50 | Primary model (daily tasks) |
| Claude Pro OAuth | $20 | Complex reasoning backup |
| Claude Code Pro | $20 | CLI tool |
| **Total** | **~$90/mo** | Full setup |

> 💡 MiniMax delivers **90% of Opus quality at 10% of the cost**

---

## 🎯 Daily Workflows

```bash
# Morning standup
/cm "health check"    # System status

# Development
/sec                # Before git push
/mcp                 # MCP servers OK?
/tc                  # Test coverage

# Code quality
/rr                  # Full review
/sa                  # Security audit

# Sleep mode
/md scan ~/projects  # Scan while sleeping
```

---

## 📁 What's Included

```
.claude/
├── settings.json          # MiniMax + 7 MCP servers
├── CLAUDE.md             # Your global directives
├── agents/               # 7 custom agents
│   ├── modo-dormir.md   # 🔥 THE MAIN FEATURE
│   ├── review-zappro.md
│   ├── security-audit.md
│   ├── deploy-check.md
│   ├── context-optimizer.md
│   ├── repo-onboard.md
│   └── executive-ceo.md
├── skills/               # 13 skills
│   ├── repo-scan.md
│   ├── pipeline-gen.md
│   ├── smoke-test-gen.md
│   ├── human-gates.md
│   ├── skill-auditor.md
│   ├── release-notes.md
│   ├── devops-pipeline.md
│   ├── test-coverage.md
│   ├── oss-ready.md
│   └── skill-creator.md
├── rules/                # 4 hooks
│   ├── PreToolUse-Bash-validate.bash
│   ├── PreToolUse-Edit-validate.bash
│   ├── Stop-session-log.bash
│   └── Stop-modo-dormir.bash
├── scripts/              # Utilities
│   ├── env-wrapper.sh
│   └── backup-memory.sh
└── templates/            # Project bootstrap
    └── default/.claude/

docs/
├── painel-dashboard.html  # Web dashboard
├── SETUP.md              # Full installation guide
├── GUIA-RAPIDO.md        # Portuguese quick ref
├── ALIASES.md            # All 2-letter aliases
├── CRON.md              # Cron setup guide
├── FORMATOS.md           # Task formats
└── PIPELINE.md          # Pipeline guide
```

---

## 🔐 Security Built-In

- ✅ API keys in `~/.claude/.secrets` (never committed)
- ✅ Pre-tool hooks block dangerous commands
- ✅ Secrets audit before every push
- ✅ Edit protection for immutable files
- ✅ Skill auditor scans for prompt injection

---

## 📖 Docs

| Doc | Language | What It Is |
|-----|----------|-------------|
| `README.md` | 🇺🇸 | This file |
| `SETUP.md` | 🇺🇸 | Full installation guide |
| `GUIA-RAPIDO.md` | 🇧🇷 | Quick reference (PT) |
| `ALIASES.md` | 🇧🇷 | All 2-letter commands |
| `CRON.md` | 🇧🇷 | Cron automation guide |
| `docs/FORMATOS.md` | 🇧🇷 | Task detection formats |
| `docs/PIPELINE.md` | 🇧🇷 | Pipeline.json guide |

---

## 🤝 Contributing

1. Fork it
2. Create branch: `git checkout -b feature/amazing`
3. Commit: `git commit -m "feat: Add amazing"`
4. Push: `git push origin feature/amazing`
5. PR on GitHub

---

## 📜 License

MIT — Use it, modify it, share it.

---

<p align="center">
  <b>⭐ Star this repo if it was useful</b><br>
  <sub>Setup in 10 minutes, not 10 hours</sub>
</p>
