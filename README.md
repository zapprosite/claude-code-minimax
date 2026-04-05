# Claude Code MiniMax Setup

### One-Command Setup for Claude Code with MiniMax M2.7 — $50/month

<p align="center">
  <img src="https://img.shields.io/badge/MiniMax-M2.7-00ff88?style=for-the-badge&logo=anthropic&logoColor=white" alt="MiniMax">
  <img src="https://img.shields.io/badge/Claude%20Code-Pro-ff6644?style=for-the-badge&logo=anthropic&logoColor=white" alt="Claude Pro">
  <img src="https://img.shields.io/badge/7-Agents-4488ff?style=for-the-badge" alt="Agents">
  <img src="https://img.shields.io/badge/9-Skills-aa66ff?style=for-the-badge" alt="Skills">
  <img src="https://img.shields.io/badge/Modo-Dormir-00ccff?style=for-the-badge" alt="Modo Dormir">
</p>

<p align="center">
  <a href="https://github.com/zapprosite/claude-code-minimax/stargazers">
    <img src="https://img.shields.io/github/stars/zapprosite/claude-code-minimax?style=flat-square&color=ffdd00" alt="Stars">
  </a>
  <a href="https://github.com/zapprosite/claude-code-minimax/issues">
    <img src="https://img.shields.io/github/issues/zapprosite/claude-code-minimax?style=flat-square&color=00ff88" alt="Issues">
  </a>
  <a href="https://github.com/zapprosite/claude-code-minimax/blob/master/LICENSE">
    <img src="https://img.shields.io/github/license/zapprosite/claude-code-minimax?style=flat-square" alt="License">
  </a>
</p>

---

## ✨ What You Get

| Category | What's Included |
|----------|----------------|
| **Models** | MiniMax M2.7 via proxy ($50) + Claude Pro OAuth ($20) |
| **Agents** | 7 custom agents including `modo-dormir` (sleep mode scanner) |
| **Skills** | 9 productivity skills (snapshot, deploy, secrets audit, etc) |
| **Hooks** | 4 security hooks (Bash validation, Edit protection, Session logging) |
| **MCP** | 7 MCP servers pre-configured (filesystem, git, github, tavily, etc) |
| **Templates** | Project initialization template |
| **Dashboard** | Web dashboard with all commands |

---

## 🚀 Quick Start

```bash
# Clone
git clone https://github.com/zapprosite/claude-code-minimax.git
cd claude-code-minimax

# Copy to home
cp -r .claude ~/
cp -r .claude/scripts ~/

# Create directories
mkdir -p ~/.mcp-data/memory-keeper
mkdir -p ~/.claude/pipelines

# Add to ~/.bashrc (MINIMAX_API_KEY=your_key)
echo 'export MINIMAX_API_KEY="your_key"' >> ~/.bashrc
echo 'export MINIMAX_API_KEY="your_key"' >> ~/.claude/.secrets
chmod 600 ~/.claude/.secrets

# Reload shell
source ~/.bashrc

# Test
cm -p "Hello"
```

---

## 🤖 Agents

| Command | Alias | Description |
|---------|-------|-------------|
| `/agent modo-dormir` | `/md` | Scans repo while you sleep, generates pipeline + tests |
| `/agent review-zappro` | `/rr` | Deep code review with security focus |
| `/agent security-audit` | `/sa` | OWASP Top 10 + secrets detection |
| `/agent deploy-check` | `/dc` | Snapshot + health check + rollback plan |
| `/agent context-optimizer` | `/co` | Analyzes context window, suggests compression |
| `/agent repo-onboard` | `/ro` | Initializes new repo with template |
| `/agent executive-ceo` | `/ec` | Strategic decision-making agent |

---

## ⚙️ Skills

| Command | Alias | Description |
|---------|-------|-------------|
| `--skill snapshot-safe` | `/ss` | ZFS snapshot with preflight checklist |
| `--skill deploy-validate` | `/dv` | Pre-deploy health check + rollback |
| `--skill context-prune` | `/cp` | Cleans old memory-keeper sessions |
| `--skill secrets-audit` | `/sec` | Scans for exposed secrets before git push |
| `--skill mcp-health` | `/mcp` | Diagnoses all 7 MCP servers |
| `--skill repo-scan` | `/rs` | Detects tasks in TASKMASTER, ADR, slices, TODO |
| `--skill pipeline-gen` | `/pg` | Generates pipeline.json with phases + gates |
| `--skill smoke-test-gen` | `/st` | Generates smoke tests + curl scripts |
| `--skill human-gates` | `/hg` | Identifies human approval points |

---

## 🔌 MCP Servers (7 Pre-configured)

| Server | Package | Purpose |
|--------|---------|---------|
| `filesystem` | @j0hanz/filesystem-mcp | Advanced file operations |
| `git` | @cyanheads/git-mcp-server | Complete Git integration |
| `context7` | @upstash/context7-mcp | Code context for any codebase |
| `memory-keeper` | mcp-memory-keeper | Persistent SQLite knowledge graph |
| `github` | @modelcontextprotocol/server-github | Issues + PRs + repos |
| `playwright` | chrome-devtools-mcp | Browser automation + screenshots |
| `tavily` | @modelcontextprotocol/server-tavily | Web search |

---

## 🌙 Modo Dormir — Sleep Mode

The star feature: set it and forget it.

```bash
# Scan any repo while you sleep
/agent modo-dormir scan /path/to/repo

# Next morning, check results:
ls ~/.claude/pipelines/
```

### What It Does

1. **Detects formats**: TASKMASTER, PRD, ADR, slices, TODO, TURBO, GitHub Issues
2. **Generates pipeline**: phases with human approval gates
3. **Creates tests**: smoke tests + curl scripts
4. **Reports**: what you need to approve vs what it can do alone

### Example Output

```json
{
  "phases": [
    {"name": "fase1_auth", "tasks": ["CRM-001"], "agent": "builder", "human_gate": false},
    {"name": "fase2_leads", "tasks": ["CRM-002"], "agent": "builder", "human_gate": true, "gate_reason": "needs-approval"}
  ],
  "smoke_tests": [...],
  "human_gates_summary": {"total": 5, "by_type": {"approval": 2, "security": 1}}
}
```

---

## 📊 Cost Breakdown

| Service | Monthly Cost | Use Case |
|---------|-------------|----------|
| MiniMax M2.7 | $50 | Primary model for daily tasks |
| Claude Pro OAuth | $20 | Backup + complex reasoning |
| Claude Code Pro | $20 | CLI tool (optional) |
| **Total** | **~$70-90/mo** | Full setup |

> 💡 **MiniMax is 10x cheaper** than Opus for most tasks while maintaining 90% quality.

---

## 📁 Repository Structure

```
claude-code-minimax/
├── .claude/
│   ├── settings.json          # MiniMax + MCP config
│   ├── CLAUDE.md             # Your global directives
│   ├── agents/               # 7 custom agents
│   │   ├── modo-dormir.md
│   │   ├── review-zappro.md
│   │   ├── security-audit.md
│   │   ├── deploy-check.md
│   │   ├── context-optimizer.md
│   │   ├── repo-onboard.md
│   │   └── executive-ceo.md
│   ├── skills/               # 9 skills
│   │   ├── snapshot-safe.md
│   │   ├── deploy-validate.md
│   │   ├── context-prune.md
│   │   ├── secrets-audit.md
│   │   ├── mcp-health.md
│   │   ├── repo-scan.md
│   │   ├── pipeline-gen.md
│   │   ├── smoke-test-gen.md
│   │   └── human-gates.md
│   ├── rules/                # 4 hooks
│   │   ├── PreToolUse-Bash-validate.bash
│   │   ├── PreToolUse-Edit-validate.bash
│   │   ├── Stop-session-log.bash
│   │   └── Stop-modo-dormir.bash
│   ├── scripts/              # Utility scripts
│   │   ├── env-wrapper.sh   # Infisical vault integration
│   │   └── backup-memory.sh
│   └── templates/            # Project templates
│       └── default/.claude/
├── docs/
│   ├── painel-dashboard.html # Web dashboard
│   ├── SETUP.md             # Detailed installation
│   ├── GUIA-RAPIDO.md       # Quick reference (Portuguese)
│   ├── ALIASES.md           # Alias commands
│   ├── FORMATOS.md          # Supported task formats
│   └── PIPELINE.md          # Pipeline.json guide
├── README.md
├── SETUP.md
├── GUIA-RAPIDO.md
├── ALIASES.md
└── LICENSE
```

---

## 🎯 Common Workflows

### Daily Development
```bash
cm "Implement auth JWT"           # MiniMax
/sec                               # Before commit
/mcp                               # Check MCP servers
```

### Code Review
```bash
/rr                                # Full review
/sa                                # Security audit
```

### Deploy
```bash
/dc                                # Deploy check
/ss                                # Snapshot
/dv                                # Validate
```

### Sleep Mode
```bash
/md scan ~/projects/my-app        # Scan while sleeping
```

---

## 🔐 Security

- API keys stored in `~/.claude/.secrets` (never committed)
- Pre-tool hooks block dangerous commands
- Secrets audit before every git push
- Edit protection for immutable files

---

## 📖 Documentation

| File | Language | Description |
|------|----------|-------------|
| `README.md` | 🇺🇸 EN | This file |
| `SETUP.md` | 🇺🇸 EN | Detailed installation guide |
| `GUIA-RAPIDO.md` | 🇧🇷 PT | Quick reference (Portuguese) |
| `ALIASES.md` | 🇧🇷 PT | All command aliases |
| `docs/FORMATOS.md` | 🇧🇷 PT | Supported task formats |
| `docs/PIPELINE.md` | 🇧🇷 PT | Pipeline.json guide |

---

## 🤝 Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

---

## 📝 License

MIT License - do whatever you want with it.

---

<p align="center">
  <b>Star ⭐ if this was useful</b><br>
  <sub>Setup Claude Code in 10 minutes, not 10 hours</sub>
</p>
