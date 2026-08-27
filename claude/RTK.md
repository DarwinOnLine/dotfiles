# RTK - Rust Token Killer

Token-optimized CLI proxy (60-90% savings). Commands are rewritten transparently
by the `PreToolUse` hook — just run `git status` normally, not `rtk git status`.

Use `rtk` directly only for its meta commands:

```bash
rtk gain [--history]  # Token savings analytics
rtk discover          # Find missed optimization opportunities
rtk proxy <cmd>       # Bypass filtering (debugging)
```

⚠️ If `rtk gain` fails: likely the wrong `rtk` binary (reachingforthejack/rtk).
