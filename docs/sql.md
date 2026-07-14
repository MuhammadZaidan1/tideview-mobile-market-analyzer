-- Task 6: Migration buat data-binding watchlist/alert ke akun (Fase 3)
-- Jalankan SATU-SATU di Supabase SQL Editor, urut dari atas ke bawah.

-- 1. user_watchlist: tambah kolom `symbol` biar bisa di-upsert langsung dari
--    client tanpa perlu lookup asset_id (UUID) dulu. asset_id dibiarkan ada
--    tapi jadi opsional (gak dipakai lagi dari client).
alter table user_watchlist add column if not exists symbol text;
alter table user_watchlist alter column asset_id drop not null;

-- Unique constraint biar upsert(onConflict: 'user_id,symbol') bisa jalan
create unique index if not exists user_watchlist_user_symbol_idx
  on user_watchlist(user_id, symbol);

-- 2. price_alerts: unique constraint biar upsert(onConflict:
--    'user_id,symbol,target_price,is_above') bisa jalan
create unique index if not exists price_alerts_user_symbol_price_above_idx
  on price_alerts(user_id, symbol, target_price, is_above);

-- 3. watchlist_categories: unique constraint biar upsert(onConflict:
--    'user_id,name') bisa jalan
create unique index if not exists watchlist_categories_user_name_idx
  on watchlist_categories(user_id, name);

-- Verifikasi (opsional, jalanin buat mastiin ketiga index di atas kebuat):
-- select indexname, tablename from pg_indexes
-- where tablename in ('user_watchlist', 'price_alerts', 'watchlist_categories')
-- and indexname like '%_idx';