---
name: xauusd-gold-trading
description: Expert knowledge for trading XAUUSD (Gold vs USD) and building profitable Expert Advisors on Gold. Use when user works on MT4/MT5 EAs for XAUUSD, Gold scalping/swing strategies, Gold-specific risk management, Gold session times, news events affecting Gold (NFP, CPI, FOMC), Gold volatility patterns, spread considerations, broker selection for Gold, or any topic around XAU/USD (Gold/USD), XAUUSD pip value, Gold lot sizing, or correlation of Gold with DXY/USDT/equities.
---

# XAUUSD (Gold) Trading Expertise

Deep knowledge for trading and building Expert Advisors on XAUUSD (Gold vs US Dollar).

## What makes Gold different from FX pairs

1. **Higher volatility**: Gold routinely moves 200-500 pips per day; EURUSD moves 50-100. Your stop losses, TP targets, and position sizing must account for this.
2. **Bigger spreads**: Typical XAUUSD spreads: 15-50 pips at ECN brokers, 30-100+ at market makers. Scalping strategies die if you ignore spread. A strategy needs to move ~2-3x the spread minimum to be profitable net of costs.
3. **Pip value ≠ FX**: On most brokers, XAUUSD is quoted to 2 decimals (e.g. 2050.45). "1 pip" = 0.01 = $0.01 per 0.01 lot. Some brokers quote 3 decimals (2050.455) with 10x smaller pip value. **Always confirm** with `MarketInfo(Symbol(), MODE_TICKSIZE)` and `MODE_POINT` in MQL5 before sizing.
4. **Commission on top of spread** at ECN brokers — add ~$7-10/lot round trip when you calculate profitability.
5. **Gap risk**: Gold gaps on Sunday open after weekend news. Avoid holding large positions over weekend unless you understand the risk.

## Gold-specific trading sessions (UTC)

| Session | UTC | Activity | Strategy fit |
|---|---|---|---|
| Asian (Tokyo) | 00:00 – 08:00 | Low volume, tight ranges | Mean reversion in range |
| London open | 08:00 – 12:00 | **Highest volatility spike** | Breakout, trend continuation |
| London/NY overlap | 13:00 – 16:00 | **Peak liquidity** | All strategies work, tightest spreads |
| NY session | 13:00 – 21:00 | Continues London volatility | Breakouts, news trades |
| NY close | 21:00 – 22:00 | Volume drops | Avoid, wide spreads |

**Rule of thumb for EAs**: disable trading between 22:00 and 08:00 UTC unless you have a specific Asian-range strategy. Spreads widen and fills get worse.

## News events that move Gold

Gold reacts strongest to:
- **US CPI / PPI** (inflation → bullish Gold if hot)
- **FOMC / Fed rate decisions** (dovish → bullish Gold)
- **NFP (Non-Farm Payrolls)** — first Friday of the month, 13:30 UTC
- **Fed Chair speeches** (Powell testimony)
- **Geopolitical risk spikes** (war, banking crisis → flight to Gold)
- **DXY (Dollar Index)** moves — Gold typically inverse to DXY
- **US Treasury yields** — especially real yields (TIPS). Higher real yields → bearish Gold

**EA rule**: Pause trading 30 min before and 15 min after high-impact news events. Use an economic calendar feed or hardcode the event times.

## Correlations to watch

- **DXY**: Strong inverse (~-0.8). Short DXY → long Gold setup
- **Silver (XAGUSD)**: Positive (~+0.85), but Silver is more volatile/leveraged
- **US10Y real yields**: Strong inverse (~-0.7)
- **SPX**: Weak, sometimes inverse in risk-off events
- **BTC**: Weak positive as alt-store-of-value thesis

## Common Gold-EA strategies — what works & what doesn't

### ✅ What tends to work (with proper risk management)

1. **London breakout**: Identify Asian range (00:00-08:00 UTC). Place buy stop above high + N pips, sell stop below low. Trade at 08:00.
2. **Mean reversion on M5/M15 during Asian session**: Gold respects ranges in Asian hours.
3. **Trend following on H1/H4** with ATR-based stops and trailing, especially around London/NY.
4. **News trades** with pre-positioned OCO (one-cancels-other) — high risk, only with tight risk per trade.
5. **Multi-timeframe confirmation** (H4 trend + M15 entry).

### ⚠️ What BLOWS UP accounts

1. **Martingale** (doubling after losses) — mathematically guaranteed blowup on Gold because of the volatility. You WILL hit a 10-loss streak eventually. `2^10 = 1024x` your starting size. Game over.
2. **Grid trading without strict TP exit** — same math problem.
3. **No stop loss** — Gold can gap or spike 300+ pips in minutes on news.
4. **Scalping without ECN + low latency** — you cannot beat spread + slippage at retail brokers.
5. **Overtrading in Asian session** — low liquidity, gets chopped up.
6. **Risk >1-2% per trade** — one losing streak liquidates you.

## Risk management rules for Gold EAs

1. **Max 1-2% risk per trade** (calculated from SL distance, not hope)
2. **Max 5% portfolio heat** (total risk across all open positions)
3. **Daily loss limit**: close all, pause EA for the day if daily loss ≥ 3-5%
4. **Weekly drawdown stop**: pause if week down ≥ 10%
5. **ATR-based stops**: minimum SL distance = 1.5 × ATR(14) on entry timeframe
6. **Minimum R:R of 1.5:1**, prefer 2:1 or better
7. **No averaging down without a plan** (this is not DCA investing, it's leverage)
8. **Position size formula**:
   ```
   lot_size = (account_balance * risk_pct) / (SL_pips * pip_value * contract_size)
   ```
   In MQL5, use `AccountInfoDouble(ACCOUNT_BALANCE)` and compute dynamically on each entry.

## MQL5 boilerplate for a safe Gold EA

```mql5
// Risk management gate — call before OrderSend
bool CanOpenNewPosition() {
    // 1. Not during news blackout
    if(IsNewsEvent(30)) return false;
    // 2. Not outside allowed session
    int hour = TimeHour(TimeCurrent());
    if(hour < 8 || hour >= 22) return false;
    // 3. Daily loss limit not hit
    if(DailyPnL() < -AccountInfoDouble(ACCOUNT_BALANCE) * 0.03) return false;
    // 4. Max open positions
    if(PositionsTotal() >= MaxPositions) return false;
    // 5. Margin check
    if(AccountInfoDouble(ACCOUNT_MARGIN_FREE) < RequiredMargin(lots)) return false;
    return true;
}

// Dynamic lot sizing based on SL distance and risk %
double CalculateLotSize(double slDistancePips, double riskPercent) {
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double riskAmount = accountBalance * (riskPercent / 100.0);
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    double pipValue = tickValue * (_Point / tickSize);
    double lots = riskAmount / (slDistancePips * pipValue);
    // Normalize to broker's lot step
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    lots = MathFloor(lots / lotStep) * lotStep;
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    return MathMax(minLot, MathMin(maxLot, lots));
}
```

## Backtesting Gold EAs — gotchas

1. **Use tick data**, not M1 OHLC. Strategy tester with "every tick based on real ticks" mode only (mode 4 in MT5).
2. **Spread simulation**: Set realistic spread (15-40 points for Gold). Default "current" is misleading.
3. **Commission**: Add commission per lot in broker settings or subtract from result.
4. **Slippage**: Simulate 1-3 pips slippage on every entry and exit.
5. **Walk-forward, not curve-fit**: Split data 70/30, optimize on 70, test on 30. Reject strategies that don't survive out-of-sample.
6. **At least 2 years of data**, ideally 5+, covering different regimes (trending, ranging, crisis).
7. **Monte Carlo**: run 1000+ randomized equity curves to check robustness. If 95th percentile drawdown is catastrophic, reject.
8. **Expectancy > 0.2 and profit factor > 1.3** as minimum acceptable metrics.

## Broker considerations for Gold trading

- Prefer **ECN/STP brokers** with raw spreads + commission over market makers
- Confirm broker has **no requotes** and **fast fill times** (<100ms)
- Check **leverage limits on Gold** — some brokers cap at 1:20 or 1:50
- Test in **demo with live market conditions** (not synthetic) for at least 1 month
- Watch for **stop hunting** — some dealing desks widen spreads around your SL
- Use VPS near broker's server for <5ms ping for EA execution

## Related skills to load

- `mql-developer` — full MQL4/MQL5 reference, EA architecture, indicators
- `trading-risk-management` — portfolio-level controls, drawdown management
- `trading-kelly-criterion` — optimal fractional Kelly sizing (use ≤¼ Kelly for Gold)
- `trading-position-sizing` — fixed fractional, volatility-targeting, risk parity
- `trading-walk-forward-validation` — out-of-sample testing
- `trading-backtrader` / `trading-vectorbt` — Python backtesting (complementary to MT5 Strategy Tester)
- `trading-volatility-modeling` — ATR, GARCH, regime detection for dynamic SL/TP
- `trading-regime-detection` — trend vs range classification
- `trading-exit-strategies` — trailing stops, break-even, partial close
- `trading-sentiment-analysis` — news/social sentiment as filter
- `profitable-ea-patterns` — what separates working EAs from blowups

## Honest notes

- **"95% of retail EAs fail over 12 months"** is true for a reason — people skip risk management and curve-fit their backtests. If you build one that survives strict walk-forward testing AND real forward testing, you're in the top 5%.
- **Sharpe ratio >1 is great, >2 is excellent, >3 is probably overfit** — be skeptical.
- **Forward test for at least 3 months on demo** before any live money. Then start with 1% of capital.
- **Diversify across strategies** (trend + mean-reversion + news) rather than running one EA on 100% capital.
- **Gold is NOT a "safe" instrument to learn on** — it punishes beginners fastest due to volatility. Start EA development on EURUSD H1, graduate to Gold once the system survives.
