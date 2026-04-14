---
name: nesb-scorer
description: Score headlines and copy against the NEW-EASY-SAFE-BIG framework from "Take Their Money" by Kyle Milligan
allowed-tools:
  - Read
invocation: user
---

# NESB Scorer

Use this skill to score any headline, CTA, or copy against the 4 emotional quadrants that trigger buying decisions: NEW, EASY, SAFE, BIG.

## The Framework

Human brains are wired to respond to these 4 triggers:

| Trigger | Brain Response | What It Means |
|---------|----------------|---------------|
| **NEW** | Craves novelty | "This is different from what I've tried" |
| **EASY** | Conserves energy | "This won't take effort" |
| **SAFE** | Fears risk | "This won't backfire on me" |
| **BIG** | Wants status | "This will transform my situation" |

**Strong copy hits all 4.** Weak copy hits 1-2.

## Scoring Process

### For Each Piece of Copy

Rate each dimension 0-10:

#### NEW (Novelty)
- 0: Generic, heard-it-before claim
- 5: Somewhat fresh angle
- 10: Revolutionary, never-seen approach

**Signals**: "First", "Revolutionary", "New way", "Unlike anything", "Breakthrough"

#### EASY (Effort)
- 0: Sounds like a lot of work
- 5: Moderate effort implied
- 10: Effortless, instant results

**Signals**: "One-click", "In minutes", "No config", "Automated", "Instant"

#### SAFE (Risk)
- 0: Sounds risky, unproven
- 5: Some trust signals
- 10: Zero risk, fully proven

**Signals**: "Trusted by", "Guaranteed", "Bank-level security", "Fortune 500 approved"

#### BIG (Outcome)
- 0: Small, incremental improvement
- 5: Moderate benefit
- 10: Transformational, 10x result

**Signals**: "10x", "Dominate", "Transform", "Revolutionize", "Enterprise-grade"

## Output Format

```markdown
## NESB Score Report

### Copy Analyzed
> "[The headline or copy being scored]"

### Dimension Scores

| Dimension | Score | Evidence | Improvement |
|-----------|-------|----------|-------------|
| NEW | X/10 | [What makes it novel?] | [How to increase novelty] |
| EASY | X/10 | [What makes it easy?] | [How to reduce friction] |
| SAFE | X/10 | [What makes it safe?] | [How to add trust] |
| BIG | X/10 | [What's the big promise?] | [How to increase stakes] |

### Overall Score: XX/40 (XX%)

### Verdict
[Strong/Moderate/Weak - based on total score]

### Rewritten Alternatives

**Version 1 (Maximum NESB)**:
> [Rewrite hitting all 4 dimensions strongly]

**Version 2 (NEW + BIG focus)**:
> [Rewrite emphasizing novelty and outcome]

**Version 3 (EASY + SAFE focus)**:
> [Rewrite emphasizing low friction and trust]
```

## Examples

### Example 1: Weak Copy
**Original**: "AI-powered code completion"
- NEW: 3/10 (many tools do this)
- EASY: 4/10 (implied but not stated)
- SAFE: 2/10 (no trust signals)
- BIG: 3/10 (small improvement)
- **Total: 12/40 (30%)**

**Improved**: "The first AI that understands your entire codebase - ship 10x faster with zero setup. Trusted by 50,000 developers."
- NEW: 8/10 ("first", "entire codebase")
- EASY: 9/10 ("zero setup")
- SAFE: 8/10 ("trusted by 50,000")
- BIG: 9/10 ("10x faster")
- **Total: 34/40 (85%)**

### Example 2: Strong Copy (PagerDuty)
**Original**: "74% less downtime. Trusted by 30,000 companies."
- NEW: 5/10 (specific number is fresh)
- EASY: 6/10 (implied automation)
- SAFE: 9/10 ("30,000 companies")
- BIG: 9/10 ("74% less downtime")
- **Total: 29/40 (73%)**

## Common Patterns by Industry

### Developer Tools
- NEW: Unique mechanism (context-aware, codebase understanding)
- EASY: Zero config, one-click, works with existing tools
- SAFE: Open source, used by big companies, SOC 2
- BIG: 10x productivity, ship faster, fewer bugs

### B2B SaaS
- NEW: AI-powered, automated, intelligent
- EASY: No migration, instant setup, integrates with X
- SAFE: Enterprise-grade, Fortune 500 customers, compliance
- BIG: ROI numbers, cost savings, revenue growth

### Consumer Apps
- NEW: First app that..., new way to...
- EASY: Takes 2 minutes, no signup required
- SAFE: Millions of users, top-rated, privacy-focused
- BIG: Change your life, achieve your goals, transform

## Quick Win Templates

### Maximum NESB Headlines
```
"The first [mechanism] that [big outcome] - [easy claim]. [safe proof]."

"[Big outcome] in [easy timeframe] with [new mechanism]. [safe proof]."

"Stop [pain]. Start [big outcome]. [New mechanism] makes it [easy]. [Safe proof]."
```

### Examples
```
"The first AI that reads your entire codebase - 10x faster coding with zero setup. Trusted by 50,000 developers."

"Ship production code in minutes with context-aware AI. Used by Stripe, Shopify, and 10,000+ teams."

"Stop debugging. Start shipping. Our codebase-aware AI catches bugs before you do. SOC 2 certified."
```
