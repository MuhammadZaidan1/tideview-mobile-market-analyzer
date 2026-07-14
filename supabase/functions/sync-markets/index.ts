// supabase/functions/sync-markets/index.ts
//
// Adaptasi langsung dari crypto_repository.dart, forex_repository.dart,
// stocks_repository.dart (logic top-50/friendly-name/currency-name persis sama).
// Dijadwalkan jalan tiap 15 menit lewat Supabase Cron.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, // service role, bypass RLS
)

// ============================================================
// 1. CRYPTO — CoinGecko, 1 request buat sampai 250 coin
//    (menggantikan pola lama: fetch Binance ticker/24hr + filter USDT + sort volume)
// ============================================================

// Dipindah persis dari _getFriendlyName() di crypto_repository.dart lama,
// dipakai sebagai fallback kalau nama dari CoinGecko kosong/beda format.
const cryptoFriendlyNames: Record<string, string> = {
  BTC: 'Bitcoin', ETH: 'Ethereum', USDT: 'Tether', BNB: 'BNB', SOL: 'Solana',
  USDC: 'USDC', XRP: 'Ripple', ADA: 'Cardano', AVAX: 'Avalanche', DOGE: 'Dogecoin',
  DOT: 'Polkadot', TRX: 'TRON', LINK: 'Chainlink', MATIC: 'Polygon', POL: 'Polygon (POL)',
  SHIB: 'Shiba Inu', LTC: 'Litecoin', BCH: 'Bitcoin Cash', PEPE: 'Pepe', NEAR: 'NEAR Protocol',
  APT: 'Aptos', ARB: 'Arbitrum', OP: 'Optimism', SUI: 'Sui', INJ: 'Injective',
  FDUSD: 'First Digital USD', WIF: 'dogwifhat', FLOKI: 'Floki', GALA: 'Gala', UNI: 'Uniswap',
  ATOM: 'Cosmos', XMR: 'Monero', ETC: 'Ethereum Classic', TON: 'Toncoin', XLM: 'Stellar',
  ICP: 'Internet Computer', FIL: 'Filecoin', HBAR: 'Hedera', VET: 'VeChain', MNT: 'Mantle',
  MKR: 'Maker', SAND: 'The Sandbox', GRT: 'The Graph', RNDR: 'Render', ALGO: 'Algorand',
  AAVE: 'Aave', MANA: 'Decentraland', THETA: 'Theta Network', STX: 'Stacks',
  EGLD: 'MultiversX', AXS: 'Axie Infinity',
}

async function syncCrypto(): Promise<{ synced: number; error?: string }> {
  try {
    const res = await fetch(
      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=false',
    )
    if (!res.ok) throw new Error(`CoinGecko HTTP ${res.status}`)
    const coins = await res.json()

    if (!Array.isArray(coins) || coins.length === 0) {
      throw new Error('Data CoinGecko kosong atau bukan array')
    }

    const rows = coins.map((c: any) => {
      const symbol = String(c.symbol ?? '').toUpperCase()
      return {
        symbol,
        name: c.name ?? cryptoFriendlyNames[symbol] ?? symbol,
        current_price: Number(c.current_price ?? 0),
        price_change_24h: Number(c.price_change_percentage_24h ?? 0),
        image: c.image ?? null,
        market_type: 'crypto',
      }
    })

    const { error } = await supabase.from('assets').upsert(rows, { onConflict: 'symbol' })
    if (error) throw error

    return { synced: rows.length }
  } catch (e) {
    console.error('syncCrypto error:', e)
    return { synced: 0, error: String(e) }
  }
}

// ============================================================
// 2. FOREX — Frankfurter, sama persis kayak forex_repository.dart lama
// ============================================================

// Dipindah persis dari _currencyNames di forex_repository.dart lama.
const currencyNames: Record<string, string> = {
  EUR: 'Euro', JPY: 'Japanese Yen', GBP: 'British Pound', AUD: 'Australian Dollar',
  CAD: 'Canadian Dollar', CHF: 'Swiss Franc', CNY: 'Chinese Yuan', HKD: 'Hong Kong Dollar',
  NZD: 'New Zealand Dollar', SGD: 'Singapore Dollar', IDR: 'Indonesian Rupiah',
  MYR: 'Malaysian Ringgit', THB: 'Thai Baht', INR: 'Indian Rupee', KRW: 'South Korean Won',
  PHP: 'Philippine Peso', ZAR: 'South African Rand', BRL: 'Brazilian Real', MXN: 'Mexican Peso',
}

async function syncForex(): Promise<{ synced: number; error?: string }> {
  try {
    // domain resmi udah pindah ke frankfurter.dev (v2) dari frankfurter.app (lama)
    const res = await fetch('https://api.frankfurter.dev/v1/latest?from=USD')
    if (!res.ok) throw new Error(`Frankfurter HTTP ${res.status}`)
    const data = await res.json()

    const rates = data?.rates
    if (!rates || typeof rates !== 'object') {
      throw new Error('Data rates Frankfurter tidak valid atau kosong')
    }

    const rows = []
    for (const [symbol, rateValue] of Object.entries(rates)) {
      const rate = Number(rateValue)
      if (!Number.isFinite(rate) || rate <= 0) continue

      rows.push({
        symbol,
        name: currencyNames[symbol] ?? `${symbol} Currency`,
        // sama seperti Dart lama: price yang disimpan itu 1/rate (harga USD dalam mata uang itu)
        current_price: 1 / rate,
        price_change_24h: 0, // Frankfurter gak kasih 24h change, sama seperti sebelumnya
        market_type: 'forex',
      })
    }

    if (rows.length === 0) throw new Error('Gak ada currency valid buat di-upsert')

    const { error } = await supabase.from('assets').upsert(rows, { onConflict: 'symbol' })
    if (error) throw error

    return { synced: rows.length }
  } catch (e) {
    console.error('syncForex error:', e)
    return { synced: 0, error: String(e) }
  }
}

// ============================================================
// 3. STOCKS — Finnhub, stagger 1 detik antar call + skip di luar jam bursa
//    (menggantikan pola lama: Future.wait 50 request bersamaan)
// ============================================================

// Dipindah persis dari top50Stocks + _stockNames di stocks_repository.dart lama.
const stockNames: Record<string, string> = {
  AAPL: 'Apple', MSFT: 'Microsoft', NVDA: 'NVIDIA', GOOGL: 'Alphabet', AMZN: 'Amazon',
  META: 'Meta', TSLA: 'Tesla', NFLX: 'Netflix', SBUX: 'Starbucks', MCD: "McDonald's",
  NKE: 'Nike', KO: 'Coca-Cola', DIS: 'Disney', INTC: 'Intel', AMD: 'AMD',
  WMT: 'Walmart', JNJ: 'Johnson & Johnson', V: 'Visa', PG: 'Procter & Gamble',
  JPM: 'JPMorgan Chase', UNH: 'UnitedHealth', HD: 'Home Depot', MA: 'Mastercard',
  BAC: 'Bank of America', XOM: 'Exxon Mobil', CVX: 'Chevron', LLY: 'Eli Lilly',
  ABBV: 'AbbVie', MRK: 'Merck', PEP: 'PepsiCo', AVGO: 'Broadcom', COST: 'Costco',
  ORCL: 'Oracle', ADBE: 'Adobe', CRM: 'Salesforce', CSCO: 'Cisco', ACN: 'Accenture',
  WFC: 'Wells Fargo', PM: 'Philip Morris', COP: 'ConocoPhillips', QCOM: 'Qualcomm',
  BA: 'Boeing', IBM: 'IBM', CAT: 'Caterpillar', GE: 'General Electric', F: 'Ford',
  GM: 'General Motors', MMM: '3M', T: 'AT&T', VZ: 'Verizon',
}
const stockSymbols = Object.keys(stockNames) // persis urutan top50Stocks lama

// Kasar, gak handle daylight saving -- cukup buat guard awal biar gak sync
// sia-sia di luar jam bursa. NYSE/NASDAQ: 09:30-16:00 ET = 21:30-04:00 WIB (EST)
// atau 20:30-03:00 WIB (EDT, musim panas AS). Kita pakai rentang yang sedikit
// lebih lebar (UTC-5, EST) biar aman di kedua musim -- efeknya cuma occasionally
// sync 1 jam lebih awal/lambat dari jam buka pasar sebenarnya, bukan blocker.
function isMarketHours(): boolean {
  const now = new Date()
  const etHour = (now.getUTCHours() - 5 + 24) % 24
  const day = now.getUTCDay() // 0 = Minggu, 6 = Sabtu
  const isWeekday = day >= 1 && day <= 5
  return isWeekday && etHour >= 9 && etHour < 16
}

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

async function syncStocks(forceRun: boolean): Promise<{ synced: number; skipped?: boolean; error?: string }> {
  if (!forceRun && !isMarketHours()) {
    console.log('Di luar jam bursa (NYSE/NASDAQ), skip sync stocks kali ini')
    return { synced: 0, skipped: true }
  }

  try {
    const finnhubKey = Deno.env.get('FINNHUB_API_KEY')
    if (!finnhubKey) throw new Error('FINNHUB_API_KEY belum di-set sebagai Supabase Secret')

    const rows = []

    for (const symbol of stockSymbols) {
      try {
        const res = await fetch(
          `https://finnhub.io/api/v1/quote?symbol=${symbol}&token=${finnhubKey}`,
        )
        if (res.ok) {
          const q = await res.json()
          const price = Number(q?.c ?? 0)
          if (Number.isFinite(price) && price > 0) {
            rows.push({
              symbol,
              name: stockNames[symbol] ?? symbol,
              current_price: price,
              price_change_24h: Number(q?.dp ?? 0),
              market_type: 'stocks',
            })
          }
        } else if (res.status === 401 || res.status === 403) {
          console.error(`Finnhub auth error buat ${symbol}: HTTP ${res.status}`)
        }
      } catch (e) {
        // Silently skip per-symbol -- 1 simbol gagal gak boleh gagalin semuanya,
        // sama seperti behaviour try-catch per-request di Future.wait yang lama
        console.error(`Gagal fetch ${symbol}:`, e)
      }

      // stagger 1 detik antar request -- hindari burst ke limit 60 call/menit Finnhub
      await sleep(1000)
    }

    if (rows.length === 0) throw new Error('Gagal fetch semua saham')

    const { error } = await supabase.from('assets').upsert(rows, { onConflict: 'symbol' })
    if (error) throw error

    return { synced: rows.length }
  } catch (e) {
    console.error('syncStocks error:', e)
    return { synced: 0, error: String(e) }
  }
}

// ============================================================
// Entry point
// ============================================================

async function runFullSync(forceStocks: boolean) {
  const [cryptoResult, forexResult, stocksResult] = await Promise.all([
    syncCrypto(),
    syncForex(),
    syncStocks(forceStocks),
  ])

  console.log('sync-markets selesai:', {
    syncedAt: new Date().toISOString(),
    crypto: cryptoResult,
    forex: forexResult,
    stocks: stocksResult,
  })
}

Deno.serve(async (req) => {
  const url = new URL(req.url)
  const forceStocks = url.searchParams.get('force') === 'true'

  // Fire-and-forget: kerjaan sebenarnya (bisa >1 menit karena stagger Finnhub)
  // dilanjutkan di background SETELAH response ini dikirim. Ini wajib karena
  // Cron Job trigger di Supabase cuma nunggu response maks 5 detik -- kalau
  // kita nunggu syncCrypto/syncForex/syncStocks selesai dulu baru response,
  // cron bakal keburu timeout duluan.
  // @ts-ignore -- EdgeRuntime tersedia di runtime Supabase Edge Functions
  EdgeRuntime.waitUntil(runFullSync(forceStocks))

  return new Response(
    JSON.stringify({ accepted: true, note: 'Sync jalan di background, cek Logs buat hasil lengkapnya' }),
    { status: 202, headers: { 'Content-Type': 'application/json' } },
  )
})