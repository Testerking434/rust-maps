---
name: content-generator
description: Generate marketing content applying all 5 frameworks - for GitHub READMEs, landing pages, social media, and more
allowed-tools:
  - Read
  - Write
  - WebFetch
  - Task
invocation: user
---

# Content Generator

Use this skill to generate optimized marketing content that applies all 5 marketing frameworks. Supports multiple content types.

## Content Types Supported

1. **GitHub README** - Developer-focused, technical credibility
2. **Landing Page** - Conversion-focused, full persuasion stack
3. **X/Twitter Thread** - Viral-focused, hook-driven
4. **LinkedIn Post** - Professional, thought leadership
5. **YouTube Script Intro** - Hook-focused, retention-optimized
6. **Substack/Blog Article** - Long-form, value-driven
7. **Product Hunt Launch** - Launch-optimized, community-focused

## Generation Process

### Step 1: Gather Context
Required inputs:
- Product name and description
- Target audience
- Key features/benefits
- Voice profile (if available)
- Competitors (for differentiation)

### Step 2: Apply Framework Stack

For each piece of content, apply:

1. **Awareness Analyzer** → Determine messaging level
2. **NESB Scorer** → Ensure headlines hit all 4 quadrants
3. **Persuasion Auditor** → Include key levers
4. **Copy Optimizer** → Apply tactical techniques
5. **Tribe Builder** → Add movement elements

### Step 3: Adapt for Platform
Each platform has specific requirements:

| Platform | Tone | Length | Key Elements |
|----------|------|--------|--------------|
| GitHub | Technical, direct | Comprehensive | Code examples, badges, install |
| Landing | Persuasive | Scannable | Hero, benefits, social proof, CTA |
| Twitter/X | Punchy, hook-driven | 280 chars/tweet | Thread structure, engagement |
| LinkedIn | Professional | 1300 chars ideal | Story, insight, CTA |
| YouTube | Conversational | 30-60s intro | Hook, promise, curiosity gap |
| Blog | Educational | 1500-3000 words | Value first, soft sell |
| Product Hunt | Community-focused | Structured | Problem, solution, why now |

### Step 4: Generate with Voice
Match the user's extracted voice profile.

### Step 5: Score and Refine
Run generated content through scorers before presenting.

## Output Format

```markdown
## Generated Content

### Content Type: [Type]
### Target Audience: [Audience]
### Awareness Level: [Level]

---

### Generated Content

[The actual content, properly formatted for the platform]

---

### Framework Application

| Framework | How Applied |
|-----------|-------------|
| Awareness | [How awareness level was matched] |
| NESB | [NEW/EASY/SAFE/BIG elements] |
| Persuasion | [Levers used] |
| Tactics | [Specific techniques] |
| Tribe | [Movement elements] |

### NESB Score
- NEW: X/10
- EASY: X/10
- SAFE: X/10
- BIG: X/10
- **Total: XX/40**

### Suggested Variations
1. [Alternative version 1]
2. [Alternative version 2]
```

## Platform-Specific Templates

See supporting files:
- `github-readme.md` - GitHub README template
- `landing-page.md` - Landing page sections
- `social-posts.md` - Twitter and LinkedIn templates
- `blog-article.md` - Blog post structure

## Quick Generation Prompts

### GitHub README
"Generate a README for [product] targeting [audience]. Key differentiator: [unique mechanism]. Include: badges, quick start, features, why us."

### Landing Page Hero
"Generate hero section for [product]. Promise: [outcome]. Proof: [social proof]. Make it hit NEW, EASY, SAFE, BIG."

### Twitter Thread
"Generate a 5-tweet thread about [topic/product]. Hook with [problem], reveal [solution], end with [CTA]."

### LinkedIn Post
"Generate a LinkedIn post sharing [insight/story] that positions [product] as the solution. Professional tone, personal story."

## Interactive Workflow

When generating content interactively:

1. **Propose** → Generate initial draft
2. **Score** → Show framework scores
3. **Refine** → Iterate based on feedback
4. **Finalize** → Present polished version
5. **Variations** → Offer alternative angles

## Voice Matching

Before generating, check if a voice profile exists:
- If yes: Match the extracted voice patterns
- If no: Use platform-appropriate defaults or offer to extract voice first

## Examples

### Example: GitHub README Hero

**Input**: AI code review tool for Python developers

**Generated**:
```markdown
# CodeReviewAI

**Stop shipping bugs. Start shipping confidence.**

The first AI that actually understands your Python codebase - not just syntax, but intent.

[![Used by 5,000+ developers](badge)](link) [![SOC 2 Certified](badge)](link)

## Why CodeReviewAI?

Traditional linters catch typos. We catch logic errors, security holes, and "that thing that'll break in production at 3am."

- **Context-aware** - Reads your entire codebase, not just the diff
- **Zero config** - Works in 30 seconds, not 30 hours
- **Privacy-first** - Your code never leaves your infrastructure

> "Caught a critical bug in our payment flow that 3 human reviewers missed." - CTO, YC Startup
```

**NESB Score**: NEW 8, EASY 9, SAFE 8, BIG 8 = 33/40

### Example: Twitter Thread Hook

**Input**: Launch announcement for productivity app

**Generated**:
```
Tweet 1:
I spent 6 months building in silence.

Today I'm launching [Product].

It does one thing: makes your to-do list actually get done.

Here's why existing tools fail you 🧵

Tweet 2:
Every productivity app assumes you have infinite willpower.

"Just add tasks and check them off!"

But willpower is finite. By 2pm, you're drained.

That's why 89% of tasks never get completed.

Tweet 3:
[Product] works differently.

Instead of fighting your brain, it works WITH it...
```
