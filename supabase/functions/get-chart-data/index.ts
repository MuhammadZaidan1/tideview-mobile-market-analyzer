// supabase/functions/get-chart-data/index.ts
//
// Adaptasi dari fetchHistoricalData() di crypto_repository.dart, forex_repository.dart,
// stocks_repository.dart -- logic caching 30 menit dan mapping timeframe->interval
// dipindah persis, cuma cache-nya sekarang di Postgres (chart_cache) bukan Isar lokal.
//
// Dipanggil ON-DEMAND oleh Flutter client pas user buka asset detail screen,
// BUKAN dijadwalkan cron -- beda pola dari sync-markets.
//
// Contoh pemanggilan dari client:
//   GET /functions/v1/get-chart-data?symbol=BTC&marketType=crypto&timeframe=1M

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, // service role, bypass RLS buat baca/tulis chart_cache
)

const CACHE_TTL_MINUTES = 30
const STABLECOIN_SYMBOLS = [
  'USDT', 'USDC', 'DAI', 'FDUSD', 'USDD', 'TUSD', 'USDE', 'PYUSD',
  'USDS', 'FRAX', 'GUSD', 'USDP', 'USD1',
]
const YAHOO_USER_AGENT =
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'

type PricePoint = [number, number] // [timestamp_ms, price]

// ============================================================
// Cache helpers
// ============================================================

async function getCachedChart(cacheKey: string): Promise<PricePoint[] | null> {
  const { data, error } = await supabase
    .from('chart_cache')
    .select('prices_json, updated_at')
    .eq('cache_key', cacheKey)
    .maybeSingle()

  if (error || !data) return null

  const ageMinutes = (Date.now() - new Date(data.updated_at).getTime()) / 60000
  if (ageMinutes >= CACHE_TTL_MINUTES) return null

  try {
    return data.prices_json as PricePoint[]
  } catch {
    return null
  }
}

async function saveChartCache(cacheKey: string, prices: PricePoint[]) {
  await supabase.from('chart_cache').upsert(
    { cache_key: cacheKey, prices_json: prices, updated_at: new Date().toISOString() },
    { onConflict: 'cache_key' },
  )
}

// ============================================================
// 1. CRYPTO — Binance klines (sama persis kayak crypto_repository.dart lama)
// ============================================================

function cryptoIntervalConfig(timeframe: string): { interval: string; limit: number } {
  switch (timeframe) {
    case '1D': return { interval: '15m', limit: 96 }
    case '1W': return { interval: '2h', limit: 84 }
    case '1M': return { interval: '6h', limit: 120 }
    case '3M': return { interval: '1d', limit: 90 }
    case '1Y': return { interval: '1w', limit: 52 }
    case 'ALL': return { interval: '1M', limit: 60 }
    default: return { interval: '1h', limit: 24 }
  }
}

async function fetchCryptoHistorical(symbol: string, timeframe: string): Promise<PricePoint[]> {
  const upperSymbol = symbol.toUpperCase()
  if (STABLECOIN_SYMBOLS.includes(upperSymbol)) return [] // sama kayak logic lama, stablecoin gak punya chart

  const { interval, limit } = cryptoIntervalConfig(timeframe)
  const binanceSymbol = `${upperSymbol}USDT`

  try {
    const res = await fetch(
      `https://data-api.binance.vision/api/v3/klines?symbol=${binanceSymbol}&interval=${interval}&limit=${limit}`,
    )
    if (!res.ok) {
      // Coin dari top-50 CoinGecko belum tentu listed di Binance sebagai USDT
      // pair -- ini kasus yang diharapkan (bukan error server), jadi gracefully
      // return kosong daripada throw, biar client cuma nampilin "no chart data"
      // bukan error 500.
      console.log(`Binance klines gak tersedia buat ${binanceSymbol}: HTTP ${res.status}`)
      return []
    }

    const klines = await res.json()
    if (!Array.isArray(klines)) return []

    return klines.map((k: any[]) => [Number(k[0]), Number(k[4])] as PricePoint)
  } catch (e) {
    console.error(`fetchCryptoHistorical error (${binanceSymbol}):`, e)
    return []
  }
}

// ============================================================
// 2. FOREX & 3. STOCKS — Yahoo Finance unofficial (sama persis kayak
//    forex_repository.dart / stocks_repository.dart lama)
// ============================================================

function yahooRangeConfig(timeframe: string): { range: string; interval: string } {
  switch (timeframe) {
    case '1D': return { range: '1d', interval: '15m' }
    case '1W': return { range: '5d', interval: '60m' }
    case '1M': return { range: '1mo', interval: '1d' }
    case '3M': return { range: '3mo', interval: '1d' }
    case '1Y': return { range: '1y', interval: '1wk' }
    case 'ALL': default: return { range: '5y', interval: '1mo' }
  }
}

async function fetchYahooHistorical(yahooSymbol: string, timeframe: string): Promise<PricePoint[]> {
  const { range, interval } = yahooRangeConfig(timeframe)

  const res = await fetch(
    `https://query1.finance.yahoo.com/v8/finance/chart/${yahooSymbol}?range=${range}&interval=${interval}`,
    { headers: { 'User-Agent': YAHOO_USER_AGENT, Accept: 'application/json' } },
  )
  if (!res.ok) return [] // silently fail, sama kayak behaviour lama

  const data = await res.json()
  const result = data?.chart?.result
  if (!result || result.length === 0) return []

  const timestamps: number[] | undefined = result[0]?.timestamp
  const closes: (number | null)[] | undefined = result[0]?.indicators?.quote?.[0]?.close

  if (!timestamps || !closes || timestamps.length !== closes.length || timestamps.length === 0) {
    return []
  }

  const prices: PricePoint[] = []
  for (let i = 0; i < timestamps.length; i++) {
    if (closes[i] !== null && closes[i] !== undefined) {
      prices.push([timestamps[i] * 1000, Number(closes[i])])
    }
  }
  return prices
}

// ============================================================
// Entry point
// ============================================================

Deno.serve(async (req) => {
  const url = new URL(req.url)
  const symbol = url.searchParams.get('symbol')
  const marketType = url.searchParams.get('marketType') // 'crypto' | 'forex' | 'stocks'
  const timeframe = url.searchParams.get('timeframe') ?? '1M'

  if (!symbol || !marketType) {
    return new Response(
      JSON.stringify({ error: 'Parameter symbol dan marketType wajib diisi' }),
      { status: 400, headers: { 'Content-Type': 'application/json' } },
    )
  }

  const cacheKey = `${symbol.toUpperCase()}_${timeframe}`

  // 1. Cek cache dulu (TTL 30 menit, sama seperti Isar cache yang lama)
  const cached = await getCachedChart(cacheKey)
  if (cached) {
    return new Response(JSON.stringify({ prices: cached, fromCache: true }), {
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // 2. Cache miss/stale -> fetch dari sumber sesuai marketType
  try {
    let prices: PricePoint[] = []

    if (marketType === 'crypto') {
      prices = await fetchCryptoHistorical(symbol, timeframe)
    } else if (marketType === 'forex') {
      prices = await fetchYahooHistorical(`${symbol.toUpperCase()}USD=X`, timeframe)
    } else if (marketType === 'stocks') {
      prices = await fetchYahooHistorical(symbol.toUpperCase(), timeframe)
    } else {
      return new Response(
        JSON.stringify({ error: `marketType tidak dikenali: ${marketType}` }),
        { status: 400, headers: { 'Content-Type': 'application/json' } },
      )
    }

    if (prices.length > 0) {
      await saveChartCache(cacheKey, prices) // fire-and-forget cache write
    }

    return new Response(JSON.stringify({ prices, fromCache: false }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (e) {
    console.error(`get-chart-data error (${symbol}/${marketType}/${timeframe}):`, e)
    return new Response(JSON.stringify({ error: String(e), prices: [] }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})