---
name: competitor-analyzer
description: Analyze competitor positioning using browser automation (Claude in Chrome + Chrome MCP)
allowed-tools:
  - Read
  - WebFetch
  - Task
  - mcp__claude-in-chrome__read_page
  - mcp__claude-in-chrome__navigate
  - mcp__claude-in-chrome__get_page_text
  - mcp__claude-in-chrome__computer
  - mcp__claude-in-chrome__tabs_context_mcp
  - mcp__claude-in-chrome__tabs_create_mcp
invocation: user
---

# Competitor Analyzer

Use this skill to analyze competitor websites and extract their positioning strategy. Uses browser automation to visit and analyze competitor pages.

## What to Analyze

### 1. Awareness Level Targeting
- What awareness level are they targeting? (Unaware → Most Aware)
- Are they explaining the problem or assuming awareness?
- How sophisticated is their messaging?

### 2. Persuasion Levers Used
Score their use of Cialdini's 7 levers:
- Authority signals
- Social proof
- Commitment mechanics
- Likeability/brand
- Reciprocity (free value)
- Scarcity
- Unity/community

### 3. NESB Scoring
Rate their headlines and copy:
- NEW: How novel is their positioning?
- EASY: How friction-free do they appear?
- SAFE: How trustworthy/proven?
- BIG: How transformational is the promise?

### 4. Tribe Building
- Do they have a defined enemy?
- Are they building a movement?
- What dreams do they encourage?
- What fears do they address?

### 5. Positioning Statement
Extract their core positioning:
- Who is it for?
- What problem do they solve?
- How are they different?
- What's their unique mechanism?

## Analysis Process

### Step 1: Navigate to Competitor Site
Use browser tools to navigate to the competitor's website.

### Step 2: Extract Key Content
Capture:
- Hero section/headline
- Subheadline
- Key features/benefits
- Social proof elements
- CTAs
- Pricing (if visible)

### Step 3: Apply Frameworks
Score against all 5 marketing frameworks.

### Step 4: Identify Opportunities
Find gaps and differentiation opportunities.

## Output Format

```markdown
## Competitor Analysis Report

### Competitor: [Name]
**URL**: [Website URL]
**Tagline**: "[Their main headline]"

---

### Positioning Summary

**Target audience**: [Who they're targeting]
**Problem they solve**: [Core problem]
**Unique mechanism**: [How they claim to be different]
**Awareness level targeted**: [Unaware/Problem/Solution/Product/Most Aware]

---

### Framework Scores

#### Awareness Level Analysis
- **Target level**: [Level]
- **Evidence**: [What makes you say this]
- **Market sophistication stage**: [1-5]

#### Persuasion Levers (Cialdini)

| Lever | Score | Evidence |
|-------|-------|----------|
| Authority | X/10 | [What they show] |
| Social Proof | X/10 | [What they show] |
| Commitment | X/10 | [Onboarding mechanics] |
| Liking | X/10 | [Brand personality] |
| Reciprocity | X/10 | [Free value offered] |
| Scarcity | X/10 | [Urgency tactics] |
| Unity | X/10 | [Community/tribe] |
| **Total** | XX/70 | |

#### NESB Score

| Dimension | Score | Evidence |
|-----------|-------|----------|
| NEW | X/10 | [Novelty claims] |
| EASY | X/10 | [Friction reduction] |
| SAFE | X/10 | [Trust signals] |
| BIG | X/10 | [Outcome promises] |
| **Total** | XX/40 | |

#### Tribe Building

| Element | Present? | How Used |
|---------|----------|----------|
| Encourage dreams | Y/N | [Example] |
| Justify failures | Y/N | [Example] |
| Allay fears | Y/N | [Example] |
| Confirm suspicions | Y/N | [Example] |
| Throw rocks at enemies | Y/N | [Example] |

---

### Key Messaging Elements

**Hero headline**:
> "[Their main headline]"

**Subheadline**:
> "[Their subheadline]"

**Key differentiators claimed**:
1. [Differentiator 1]
2. [Differentiator 2]
3. [Differentiator 3]

**Social proof shown**:
- [Customer logos]
- [Testimonials]
- [Numbers/stats]

**CTA used**:
> "[Their primary CTA text]"

---

### Competitive Opportunities

#### Gaps in Their Positioning
1. [Gap 1 - what they're not addressing]
2. [Gap 2 - what they're not addressing]

#### Differentiation Opportunities
1. [How to position differently]
2. [Underserved angle]

#### Messaging Weaknesses
1. [Weakness to exploit]
2. [Claim you can counter]

---

### Recommendations

**Position against them by**:
1. [Specific recommendation]
2. [Specific recommendation]

**Avoid**:
1. [What not to copy from them]
2. [Where they're strong - don't compete head-on]
```

## Browser Automation Notes

### Using Claude in Chrome
1. First check if Chrome extension is connected using `tabs_context_mcp`
2. Navigate to competitor URL
3. Take screenshot to capture visual layout
4. Use `read_page` to extract content
5. Use `get_page_text` for full text content

### Fallback: WebFetch
If browser automation fails:
1. Use WebFetch to retrieve page content
2. Parse HTML/text for key elements
3. Note that visual elements won't be captured

### Multiple Competitors
When analyzing multiple competitors:
1. Create comparison table
2. Identify category patterns
3. Find white space no one occupies
4. Recommend unique positioning

## Example Quick Analysis

**Competitor**: Linear (project management)

**Positioning**: "Linear is a purpose-built tool for planning and building products"

**Key strengths**:
- Strong design/brand (Liking: 9/10)
- Speed as differentiator (EASY: 8/10)
- "Built for modern teams" identity (Unity: 7/10)

**Key gaps**:
- Limited social proof on homepage
- No clear enemy defined
- Doesn't address migration fears

**Opportunity**: Position as "Linear for [specific use case]" or attack their enterprise gaps.
