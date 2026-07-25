---
name: profitable-ea-patterns
description: Patterns that separate profitable Expert Advisors from blowing up accounts. Use when building, reviewing, or debugging EAs for MT4/MT5 or any automated trading bot. Covers what actually works in production (risk management, regime filters, exit design) vs what marketing gurus sell (martingale, grid, "guaranteed profit"). Honest, math-first.
---

# Profitable EA Patterns — What Actually Works

Honest, math-first guide. Most "profitable EA" marketing is survivorship bias or outright scam. Here is what separates EAs that survive real markets from EAs that blow accounts.

## The brutal truth

- **~95% of retail EAs fail within 12 months.** This is well-documented.
- **No EA is "guaranteed profitable."** Anyone selling one with guaranteed returns is lying.
- **Backtest performance ≠ live performance.** Most backtests are overfit.
- **Sharpe > 2 in backtest is probably curve-fit.** Be skeptical.
- **The edge is small.** Profitable EAs typically have profit factor 1.2 – 1.8, not 5.0.

If you accept these, you can build something that works. If you don't, no skill will help you.

## The 7 laws of survivable EAs

### 1. Risk is fixed, profit is variable
- Risk per trade: **1 % max**, preferably 0.5 %
- Daily loss limit: halt for the day at -3 % to -5 %
- Weekly drawdown cap: halt for the week at -10 %
- Risk calculated from SL distance, **never** from fixed lot size

### 2. Every trade must have a stop loss before entry
- No exceptions
- SL placement is based on market structure (prior swing, ATR) not "what feels safe"
- Minimum SL distance ≥ 1.5 × ATR(14) on entry timeframe
- If you can't place a rational SL, don't take the trade

### 3. Expectancy > 0, checked rigorously
```
Expectancy = (WinRate × AvgWin) - (LossRate × AvgLoss)
```
- Minimum acceptable: **Expectancy > 0.2 R** (per unit risk)
- Profit factor > 1.3
- Sharpe ratio ideally > 1.0 on **out-of-sample** data
- If your strategy only works in sample, it doesn't work

### 4. Walk-forward validation or it's fiction
- Optimize on 70 % of data, validate on 30 % held-out
- If degradation > 50 %, reject
- Rolling walk-forward: re-optimize monthly or quarterly
- Include multiple market regimes (trending, ranging, high-vol, low-vol)

### 5. Regime awareness
- A trend-following EA must disable itself in ranging markets
- A mean-reversion EA must disable itself in trending markets
- Use ADX, Hurst exponent, ATR regime, Bollinger Band width, or realized volatility
- Better to skip 50 % of the market and trade well in the other 50 % than trade everything badly

### 6. Exits matter more than entries
Most amateur EAs obsess over entry rules. The profitable ones focus on:
- **Partial take-profits** (e.g. 50 % at 1 R, 25 % at 2 R, trail the rest)
- **Time-based exits** (close if trade hasn't moved in X bars)
- **Break-even stops** (after reaching 1 R, move SL to entry)
- **Volatility-adaptive trailing stops** (ATR or Chandelier Exit)
- **Hard take-profit at extreme volatility expansions**

### 7. Correlation and portfolio heat
- Running 5 EAs that all trade EURUSD isn't diversification — that's 5× the same bet
- Monitor total open risk across all positions ≤ 5 %
- Avoid correlated pairs simultaneously (EURUSD + GBPUSD + AUDUSD in the same direction = same trade)

## Patterns that BLOW UP accounts

### ❌ Martingale / Grid without exit
The math: probability of an N-loss streak is non-trivial. At `2^10 = 1024×` starting size, any margin-based account is liquidated. **Inevitable**, not "possible."

### ❌ "No stop loss, average down"
Same math. One gap eats everything.

### ❌ Over-optimization (curve fitting)
Adding parameters until backtest is beautiful. Live test will disappoint.

### ❌ Small sample size
Strategy that made $10k on 50 trades tells you nothing. Need **500+ trades** minimum for statistical significance.

### ❌ Trading everything
"My EA works on 28 pairs and all timeframes!" → It works on none of them, it's just cherry-picked from backtests.

### ❌ Ignoring broker costs
Spread + commission + swap + slippage. A strategy that's 1.05 profit factor before costs is a losing strategy after.

### ❌ Leveraging up after winners
"I'll just double my lot size now that I'm up." Then one losing streak wipes it all.

## What "profitable" actually looks like

A realistic profitable EA in production:

| Metric | Realistic target |
|---|---|
| Annual return (leveraged) | 15 – 40 % |
| Max drawdown | 10 – 20 % |
| Sharpe ratio (live) | 0.8 – 1.5 |
| Profit factor | 1.3 – 1.8 |
| Win rate | 45 – 60 % |
| Avg R per trade | 0.3 – 0.6 |
| Trades per month | 20 – 100 |
| Largest losing streak | 6 – 10 trades |

Anything claiming 200 %/year with 5 % drawdown is either short-sample luck, curve-fit, or a lie.

## Development workflow that survives

1. **Hypothesis** — written, falsifiable (e.g. "London breakout on EURUSD H1 with ADX > 25 filter has positive expectancy")
2. **Vectorized prototype** in Python (vectorbt, backtrader) — fast iteration
3. **In-sample backtest** (2020-2023) with realistic costs
4. **Out-of-sample test** (2024) — unchanged parameters
5. **Walk-forward** (rolling 6-month optimization → 1-month test)
6. **Monte Carlo** (1000+ randomized runs, check 95th percentile drawdown)
7. **Port to MQL5** exactly, no re-optimization
8. **MT5 Strategy Tester** with real tick data, spread simulation
9. **Demo forward test** minimum 3 months on VPS
10. **Live with 1 % of capital** for 3 months
11. **Scale up gradually** only after confirmed live edge
12. **Kill switch** — monthly review, kill if live Sharpe < 50 % of backtest

## Red flags in EA offerings

If you see someone selling an EA with any of these, **run**:
- "Guaranteed profits"
- "No stop loss needed"
- "100 % win rate"
- "$500 → $1M in 6 months"
- Backtest screenshots with no out-of-sample
- Cherry-picked short-term live screenshots
- No explanation of strategy logic
- "Secret algorithm"
- Martingale or grid with no exit strategy disclosed
- Uses `OrderSend` with no `SL` parameter

## Related skills to load

- `xauusd-gold-trading` — Gold-specific edge, sessions, news
- `mql-developer` — MQL4/MQL5 reference + EA architecture
- `trading-risk-management` — portfolio heat, drawdown control
- `trading-kelly-criterion` — fractional Kelly sizing
- `trading-walk-forward-validation` — out-of-sample testing framework
- `trading-vectorbt` / `trading-backtrader` — Python backtesting
- `trading-volatility-modeling` — regime-dependent sizing
- `trading-regime-detection` — trend/range classification
- `trading-exit-strategies` — stop/TP/trailing
- `trading-strategy-framework` — standard template
- `trading-position-sizing` — fixed fractional, vol targeting
- `trading-portfolio-analytics` — real performance measurement
- `trading-trade-journal` — review and iterate

## Honest summary

Building a profitable EA is not a code problem — it is a **discipline and math** problem. The code is the easy part. The hard parts are:
1. Not lying to yourself about backtest results
2. Keeping risk small when you're certain the next trade is a winner
3. Killing strategies that stopped working before they kill your account
4. Not chasing returns when a strategy is below expectation

If you can do those four, you are already ahead of 95 % of EA developers.
