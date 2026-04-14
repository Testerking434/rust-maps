---
name: persuasion-auditor
description: Audit marketing content against Cialdini's 7 persuasion levers from the book "Influence"
allowed-tools:
  - Read
  - WebFetch
invocation: user
---

# Persuasion Auditor

Use this skill to score any marketing content against Robert Cialdini's 7 levers of persuasion. Identifies which levers are present, missing, or underutilized.

## When to Use

- Auditing landing pages before launch
- Reviewing onboarding flows
- Evaluating competitor marketing
- Improving conversion rates on existing copy

## The 7 Levers

### 1. Authority
**Definition**: People follow perceived experts
**Signals to Look For**:
- Expert endorsements
- Credentials and certifications
- "As seen in..." press logos
- Founder credentials
- Industry awards

**Score 0-10**: 0 = No authority signals, 10 = Multiple strong authority indicators

### 2. Social Proof
**Definition**: People follow the crowd
**Signals to Look For**:
- User/customer counts
- Star ratings and reviews
- Testimonials with names/photos
- Case studies
- Logo walls of customers

**Score 0-10**: 0 = No social proof, 10 = Overwhelming evidence of adoption

### 3. Commitment & Consistency
**Definition**: People honor commitments they've made
**Signals to Look For**:
- Progressive disclosure in onboarding
- Small asks before big asks
- Free trials that require setup
- Personalization steps
- "You've already completed X..."

**Score 0-10**: 0 = No commitment mechanics, 10 = Strong sunk cost / commitment ladder

### 4. Liking
**Definition**: People buy from those they like or identify with
**Signals to Look For**:
- Relatable brand voice
- Founder story
- Values alignment
- Visual design matching audience
- Cultural references audience understands

**Score 0-10**: 0 = Generic/unlikeable brand, 10 = Strong identity match

### 5. Reciprocity
**Definition**: People return favors
**Signals to Look For**:
- Free value before asking (calculators, audits, templates)
- Generous free tier
- Educational content
- Helpful onboarding
- Gifts or bonuses

**Score 0-10**: 0 = Asks before giving, 10 = Generous value-first approach

### 6. Scarcity
**Definition**: People want what's rare
**Signals to Look For**:
- Limited time offers
- Limited seats/spots
- Exclusive access
- Countdown timers
- "Only X left..."

**Score 0-10**: 0 = No urgency/scarcity, 10 = Genuine, believable scarcity

### 7. Unity
**Definition**: People join tribes
**Signals to Look For**:
- Community membership
- "Us vs them" positioning
- Shared identity language
- Exclusive groups
- Movement language ("Join the revolution")

**Score 0-10**: 0 = No community/tribe aspect, 10 = Strong tribal identity

## Audit Process

### Step 1: Collect the Content
Read or fetch the marketing content (landing page, email, README, etc.)

### Step 2: Score Each Lever
For each of the 7 levers:
1. Identify specific examples in the content
2. Assign a score 0-10
3. Note what's working and what's missing

### Step 3: Calculate Overall Score
- Sum all 7 lever scores (max 70)
- Convert to percentage (score/70 * 100)

### Step 4: Prioritize Improvements
Identify the lowest-scoring levers with highest potential impact

## Output Format

```markdown
## Persuasion Audit Report

### Content Analyzed
[Description of content audited]

### Lever Scores

| Lever | Score | Evidence | Improvement Opportunity |
|-------|-------|----------|------------------------|
| Authority | X/10 | [What was found] | [What's missing] |
| Social Proof | X/10 | [What was found] | [What's missing] |
| Commitment | X/10 | [What was found] | [What's missing] |
| Liking | X/10 | [What was found] | [What's missing] |
| Reciprocity | X/10 | [What was found] | [What's missing] |
| Scarcity | X/10 | [What was found] | [What's missing] |
| Unity | X/10 | [What was found] | [What's missing] |

### Overall Score: XX/70 (XX%)

### Top 3 Priority Improvements

1. **[Lever Name]**: [Specific recommendation]
2. **[Lever Name]**: [Specific recommendation]
3. **[Lever Name]**: [Specific recommendation]

### Quick Wins
- [Easy improvements that can be made immediately]

### Strategic Improvements
- [Bigger changes that require more effort]
```

## Scoring Guidelines

### What Makes a 10/10
- **Authority**: Multiple expert endorsements, press logos, certifications, founder credentials prominently displayed
- **Social Proof**: Specific numbers, named testimonials with photos, case studies, logo wall
- **Commitment**: Multi-step onboarding that invests user before asking for payment
- **Liking**: Strong brand personality that mirrors target audience exactly
- **Reciprocity**: Generous free tier, free tools, educational content library
- **Scarcity**: Genuine limited availability with countdown and specific numbers
- **Unity**: Strong community, clear enemy, movement language throughout

### Red Flags (Auto-Deduct Points)
- Fake testimonials (obvious stock photos)
- Unbelievable scarcity ("Only 3 spots left!" for a SaaS)
- Authority claims without proof
- Asking for payment before any value delivered
