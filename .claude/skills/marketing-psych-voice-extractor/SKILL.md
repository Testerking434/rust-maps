---
name: voice-extractor
description: Analyze existing content to extract voice patterns for consistent brand messaging
allowed-tools:
  - Read
  - WebFetch
  - Task
  - Glob
  - Grep
invocation: user
---

# Voice Extractor

Use this skill to analyze a user's existing content (GitHub repos, blog posts, social profiles) and extract their unique voice patterns. This ensures generated content matches their authentic style.

## Why Voice Matters

Generic AI copy sounds like... generic AI copy. To create content that resonates:
1. Match the creator's existing voice
2. Maintain consistency across platforms
3. Sound authentic, not robotic

## What to Analyze

### Source Types (in priority order)
1. **GitHub README files** - Technical communication style
2. **Blog posts/articles** - Long-form voice
3. **Twitter/X posts** - Casual voice, hooks
4. **LinkedIn posts** - Professional voice
5. **About pages** - Self-description patterns
6. **Commit messages** - Micro-communication style

### Voice Dimensions to Extract

#### 1. Tone
- Formal ←→ Casual
- Serious ←→ Playful
- Authoritative ←→ Approachable
- Technical ←→ Accessible

#### 2. Vocabulary
- Jargon level (heavy technical vs simplified)
- Industry-specific terms used
- Avoided words/phrases
- Signature phrases

#### 3. Sentence Structure
- Short punchy ←→ Long flowing
- Simple ←→ Complex
- Active ←→ Passive
- Questions ←→ Statements

#### 4. Personality Traits
- Humor style (if any)
- Use of emojis
- Use of first person (I/we)
- Directness level

#### 5. Patterns
- How they open pieces
- How they structure arguments
- How they use examples
- How they close/CTA

## Extraction Process

### Step 1: Gather Content
Collect 3-5 pieces of existing content from the user.

### Step 2: Analyze Each Dimension
Rate each dimension and provide specific examples.

### Step 3: Identify Patterns
Find recurring elements across samples.

### Step 4: Create Voice Profile
Compile into a reusable voice guide.

## Output Format

```markdown
## Voice Profile

### Overview
**Voice in 3 words**: [Word 1], [Word 2], [Word 3]
**Overall tone**: [Description]

### Tone Spectrum
- Formality: [Rating 1-5, with 1 being very casual, 5 being very formal]
- Technical depth: [Rating 1-5]
- Humor level: [Rating 1-5]
- Directness: [Rating 1-5]

### Vocabulary Patterns

**Signature phrases** (use these):
- "[Phrase 1]"
- "[Phrase 2]"
- "[Phrase 3]"

**Technical terms used**:
- [Term 1] - [how they explain it]
- [Term 2] - [how they explain it]

**Words to avoid**:
- [Word 1] - they never use this
- [Word 2] - they avoid this

### Sentence Structure

**Typical opening patterns**:
- "[Pattern 1]"
- "[Pattern 2]"

**Typical sentence length**: [Short/Medium/Long]
**Paragraph style**: [Description]

### Personality Elements

- **First person**: [I/We/Both/Neither]
- **Emojis**: [Heavy/Light/None]
- **Questions**: [Frequent/Occasional/Rare]
- **Humor style**: [Description]

### Platform Adaptations

| Platform | Tone Adjustment | Length | Special Notes |
|----------|-----------------|--------|---------------|
| GitHub | [Adjustment] | [Length] | [Notes] |
| Twitter/X | [Adjustment] | [Length] | [Notes] |
| LinkedIn | [Adjustment] | [Length] | [Notes] |
| Blog | [Adjustment] | [Length] | [Notes] |

### Example Voice Samples

**GitHub README style**:
> [Example sentence in their GitHub voice]

**Social media style**:
> [Example sentence in their social voice]

**Professional/LinkedIn style**:
> [Example sentence in their professional voice]

### Generation Guidelines

When generating content for this user:
1. [Specific instruction 1]
2. [Specific instruction 2]
3. [Specific instruction 3]
4. [Specific instruction 4]
```

## Example Analysis

### Input: Developer's GitHub README

**Sample text**:
> "This tool does one thing well: it makes deploys boring. No drama, no 3am pages. Just push and forget. Built by someone who's been woken up by PagerDuty way too many times."

### Extracted Voice Profile

**Voice in 3 words**: Direct, Practical, Relatable

**Tone**:
- Formality: 2/5 (casual)
- Technical depth: 3/5 (moderate)
- Humor level: 3/5 (dry humor)
- Directness: 5/5 (very direct)

**Signature patterns**:
- Short, punchy sentences
- Personal anecdotes ("Built by someone who...")
- Focus on pain points
- Understatement humor ("makes deploys boring")

**Generation guidelines**:
1. Keep sentences short and punchy
2. Reference real developer pain points
3. Use dry humor, avoid try-hard jokes
4. Stay practical, not aspirational
5. Use first person sparingly but authentically

## Handling Multiple Sources

When analyzing multiple content sources:

1. **Look for consistency** - What's the same across all sources?
2. **Note platform variations** - How do they adapt for different contexts?
3. **Weight by recency** - Newer content shows current voice
4. **Weight by quality** - Their best content shows intentional voice

## Common Voice Archetypes

| Archetype | Characteristics | Good For |
|-----------|-----------------|----------|
| **The Expert** | Authoritative, detailed, formal | Enterprise, B2B |
| **The Friend** | Casual, relatable, warm | Consumer, community |
| **The Minimalist** | Direct, no-fluff, efficient | Dev tools, productivity |
| **The Evangelist** | Passionate, inspiring, vision-focused | Startups, movements |
| **The Teacher** | Patient, clear, step-by-step | Educational, documentation |
