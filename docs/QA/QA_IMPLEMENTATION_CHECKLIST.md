# TideView QA Findings - Prioritized Checklist

## 🔴 CRITICAL ISSUES (Do Immediately)

### C1: Unbounded IsarService Instances

- **File:** `lib/core/providers/api_provider.dart:13-16`
- **Status:** ⬜ NOT STARTED
- **Complexity:** HIGH
- **Time Est:** 1 hour
- **Impact:** Memory leak, race conditions
- **Fix:** Change `isarServiceProvider` to FutureProvider with singleton pattern
- [ ] Implement change
- [ ] Unit test
- [ ] Memory profile test

### C2: marketSyncProvider Recreated Per Reference

- **File:** `lib/core/providers/api_provider.dart:21-26`
- **Status:** ⬜ NOT STARTED
- **Complexity:** HIGH
- **Time Est:** 1 hour
- **Impact:** Duplicate resource creation, redundant syncs
- **Fix:** Convert to FutureProvider with caching
- [ ] Implement change
- [ ] Test sync deduplication
- [ ] Network monitoring

### C3: Missing Null Checks in CryptoRepository

- **File:** `lib/core/repositories/crypto_repository.dart:16-49`
- **Status:** ⬜ NOT STARTED
- **Complexity:** MEDIUM
- **Time Est:** 45 mins
- **Impact:** App crash on API schema change
- **Fix:** Add null validation and type checking
- [ ] Implement validation
- [ ] Test with malformed responses
- [ ] Test with empty response

### C4: Empty Catch Block in StocksRepository

- **File:** `lib/core/repositories/stocks_repository.dart:136`
- **Status:** ⬜ NOT STARTED
- **Complexity:** LOW
- **Time Est:** 15 mins
- **Impact:** Silent failures, fake data served
- **Fix:** Add proper error logging
- [ ] Add error logging
- [ ] Test error cases
- [ ] Verify fallback behavior

### C5: Unvalidated JSON in ForexRepository

- **File:** `lib/core/repositories/forex_repository.dart:33-55`
- **Status:** ⬜ NOT STARTED
- **Complexity:** MEDIUM
- **Time Est:** 45 mins
- **Impact:** Division by zero, unvalidated data
- **Fix:** Add type validation and safety checks
- [ ] Implement validation
- [ ] Test edge cases
- [ ] Test zero/negative rates

### C6: Generic Error Swallowing in background_service

- **File:** `lib/core/services/background_service.dart:153-155`
- **Status:** ⬜ NOT STARTED
- **Complexity:** LOW
- **Time Est:** 15 mins
- **Impact:** Invisible sync failures
- **Fix:** Add error logging and context
- [ ] Add debugPrint statements
- [ ] Test failure scenarios
- [ ] Verify crash reporting

### C7: O(n) Alert Symbol Lookup

- **File:** `lib/core/usecases/market_sync_usecase.dart:99-121` + `lib/core/services/background_service.dart:82-106`
- **Status:** ⬜ NOT STARTED
- **Complexity:** MEDIUM
- **Time Est:** 45 mins
- **Impact:** 25,000+ comparisons per sync, UI lag
- **Fix:** Create asset symbol map for O(1) lookup
- [ ] Implement map-based lookup
- [ ] Benchmark before/after
- [ ] Test with 100+ alerts

---

## 🟠 HIGH PRIORITY ISSUES (Next Sprint)

### H1: Multiple IsarService in ThemeNotifier

- **File:** `lib/core/theme/theme_provider.dart:56`
- **Status:** ⬜ NOT STARTED
- **Complexity:** LOW
- **Time Est:** 15 mins
- **Fix:** Use lazy initialization or FutureProvider
- [ ] Implement change
- [ ] Memory profile

### H2: AlertProvider Subscription Race

- **File:** `lib/core/providers/alert_provider.dart:8-23`
- **Status:** ⬜ NOT STARTED
- **Complexity:** MEDIUM
- **Time Est:** 30 mins
- **Fix:** Reorder subscription to prevent race condition
- [ ] Implement change
- [ ] Race condition test

### H3: Unsafe Null in IsarService.openDB()

- **File:** `lib/core/services/isar_service.dart:11-20`
- **Status:** ⬜ NOT STARTED
- **Complexity:** LOW
- **Time Est:** 15 mins
- **Fix:** Check null before returning getInstance()
- [ ] Implement change
- [ ] Null safety test

### H4: MarketSyncUseCase Error Fallback

- **File:** `lib/core/usecases/market_sync_usecase.dart:148+`
- **Status:** ⬜ NOT STARTED
- **Complexity:** LOW
- **Time Est:** 15 mins
- **Fix:** Add try-catch to fallback cache fetch
- [ ] Implement change
- [ ] Error scenario test

### H5: Unprotected writeTxn Calls

- **File:** `lib/core/services/isar_service.dart:27, 45, 53, 66, 73, 110, 121, 140, 150`
- **Status:** ⬜ NOT STARTED
- **Complexity:** MEDIUM
- **Time Est:** 1 hour
- **Fix:** Wrap all writeTxn with try-catch
- [ ] Add try-catch to all 9 methods
- [ ] Test transaction failures
- [ ] Test disk full scenario

### H6: Individual Puts in Alert Loop

- **File:** `lib/core/services/background_service.dart:101-104`
- **Status:** ⬜ NOT STARTED
- **Complexity:** MEDIUM
- **Time Est:** 30 mins
- **Fix:** Batch alert updates into single putAll()
- [ ] Implement batching
- [ ] Performance benchmark
- [ ] Transaction test

### H7: StocksRepository Response Validation

- **File:** `lib/core/repositories/stocks_repository.dart:100-136`
- **Status:** ⬜ NOT STARTED
- **Complexity:** MEDIUM
- **Time Est:** 45 mins
- **Fix:** Validate response data structure
- [ ] Add null checks
- [ ] Validate array lengths
- [ ] Test error responses

### H8: Missing Null Check in CryptoRepository.fetchHistoricalData()

- **File:** `lib/core/repositories/crypto_repository.dart:159-163`
- **Status:** ⬜ NOT STARTED
- **Complexity:** LOW
- **Time Est:** 15 mins
- **Fix:** Add null check on cachedChart
- [ ] Implement change
- [ ] Test aging cache

### H9: HomeWidget Error Handling

- **File:** `lib/core/services/background_service.dart:136-146`
- **Status:** ⬜ NOT STARTED
- **Complexity:** LOW
- **Time Est:** 15 mins
- **Fix:** Wrap HomeWidget calls in try-catch
- [ ] Add error handling
- [ ] Test widget unavailability

---

## 🟡 MEDIUM PRIORITY ISSUES (Polish Phase)

### M1: FutureProvider Cache Invalidation

- **File:** `lib/core/providers/api_provider.dart:31-48`
- **Status:** ⬜ NOT STARTED
- **Complexity:** MEDIUM
- **Time Est:** 1 hour
- **Fix:** Add cache invalidation strategy
- [ ] Implement strategy
- [ ] Test manual invalidation
- [ ] Test auto-invalidation

### M2: Category Sort Order Optimization

- **File:** `lib/core/services/isar_service.dart:107-116`
- **Status:** ⬜ NOT STARTED
- **Complexity:** LOW
- **Time Est:** 15 mins
- **Fix:** Use putAll() instead of loop
- [ ] Implement change
- [ ] Performance test

### M3: Missing Database Indexes

- **File:** `lib/core/database/schemas.dart` (verify)
- **Status:** ⬜ NOT STARTED
- **Complexity:** LOW
- **Time Est:** 30 mins
- **Fix:** Verify/add indexes on frequently queried fields
- [ ] Check existing indexes
- [ ] Add missing indexes
- [ ] Query performance test

### M4: Race Condition in Parallel Sync

- **File:** `lib/core/usecases/market_sync_usecase.dart:36-88`
- **Status:** ⬜ NOT STARTED
- **Complexity:** HIGH
- **Time Est:** 1.5 hours
- **Fix:** Implement request deduplication or locks
- [ ] Identify race scenarios
- [ ] Implement solution
- [ ] Concurrent access test

---

## Summary Statistics

**Total Issues:** 21  
**Critical:** 7  
**High:** 9  
**Medium:** 5

**Estimated Total Time:**

- Phase 1 (Critical): 4 hours
- Phase 2 (High): 5 hours
- Phase 3 (Medium): 3 hours
- Testing: 3 hours

**Total: ~15 hours**

---

## Implementation Progress

### Phase 1: Critical Fixes (Target: This Sprint)

```
Progress: ⬜⬜⬜⬜⬜⬜⬜ 0/7

Week 1, Day 1-2:
- [ ] C1: IsarService singleton
- [ ] C2: marketSyncProvider caching
- [ ] C3: CryptoRepository nulls
- [ ] C4: StocksRepository logging
- [ ] C6: background_service logging

Week 1, Day 3:
- [ ] C5: ForexRepository validation
- [ ] C7: Alert lookup optimization
```

### Phase 2: High Priority (Target: Week 2)

```
Progress: ⬜⬜⬜⬜⬜⬜⬜⬜⬜ 0/9

- [ ] H1-H4: Quick fixes (60 mins)
- [ ] H5: writeTxn protection (60 mins)
- [ ] H6: Alert batching (30 mins)
- [ ] H7: StocksRepository validation (45 mins)
- [ ] H8-H9: Final tweaks (30 mins)
```

### Phase 3: Medium/Polish (Target: Week 3)

```
Progress: ⬜⬜⬜⬜⬜ 0/5

- [ ] M1: Cache invalidation
- [ ] M2: Sort optimization
- [ ] M3: Index verification
- [ ] M4: Race condition fix
```

---

## Quick Reference

**Most Critical Files to Fix:**

1. `lib/core/services/background_service.dart` - Add error logging + alert batching
2. `lib/core/repositories/crypto_repository.dart` - Add null validation
3. `lib/core/services/isar_service.dart` - Protect transactions + optimize
4. `lib/core/usecases/market_sync_usecase.dart` - Alert lookup optimization

**Easiest to Fix (15 mins each):**

- C4, C6, H1, H3, H4, H8, H9, M2

**Most Complex to Fix:**

- C1, C2, M1, M4

---

## Testing Checklist After Fixes

- [ ] Unit test: Null safety in all repositories
- [ ] Integration test: API failure scenarios
- [ ] Memory profile: 60min session, watch growth
- [ ] Background sync: Verify no silent failures
- [ ] Database: Simulate corruption/disk full
- [ ] Load test: 500 assets + 50 alerts
- [ ] Concurrency: Parallel sync requests
- [ ] UI: Verify no lag during large syncs

---

Generated: 2026-05-11  
Last Updated: Not yet implemented
