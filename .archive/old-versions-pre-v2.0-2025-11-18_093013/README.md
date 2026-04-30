# Archived Old Versions - Pre v2.0

**Archive Date**: 2025-11-18
**Reason**: Superseded by optimized v2.0 versions

---

## Archived Files

### Old Replacer Versions

**unicode_replacer.py** (16KB)
- Original baseline replacer (v1.0)
- Single-threaded processing
- No early ASCII detection
- Labeled "Production Version" but superseded by optimized version

**unicode_replacer_async.py** (3.6KB)
- Experimental async version
- Abandoned in favor of ThreadPoolExecutor approach

### Old Monitor Versions

**unicode-monitor.py**
- Original file monitor
- Basic watchdog implementation

**unicode-realtime-monitor.py**
- Improved real-time monitoring
- Still slower than ultrafast version

**unicode-ultrafast-monitor.py**
- Pre-optimization ultrafast monitor
- Baseline before v2.0 optimizations

---

## Current Production Versions (NOT archived)

**DO NOT ARCHIVE THESE - ACTIVELY USED:**

### Batch Processing (Manual)
- `unicode_replacer_optimized.py` (20KB) - v2.0 with 1.94x speedup
  - ThreadPoolExecutor parallelization
  - Single-pass text processing
  - Early ASCII detection

### Real-Time Monitoring (Windows Service)
- `unicode-ultrafast-monitor-optimized.py` - v2.0 optimized service
  - 4 parallel workers
  - <3ms target response time
  - Python system file exclusions

### Log Viewer
- `view-monitor-logs.ps1` - Real-time colorized log viewer

---

## Replacement Matrix

| Old File | Replaced By | Status |
|----------|-------------|--------|
| unicode_replacer.py | unicode_replacer_optimized.py | ✅ Archived |
| unicode_replacer_async.py | unicode_replacer_optimized.py | ✅ Archived |
| unicode-monitor.py | unicode-ultrafast-monitor-optimized.py | ✅ Archived |
| unicode-realtime-monitor.py | unicode-ultrafast-monitor-optimized.py | ✅ Archived |
| unicode-ultrafast-monitor.py | unicode-ultrafast-monitor-optimized.py | ✅ Archived |

---

## Performance Comparison

### Before (v1.0 baseline)
- Single-threaded
- Three-pass text processing
- No early exit optimization
- **269ms** for 269 files

### After (v2.0 optimized)
- Multi-threaded (3-5 workers)
- Single-pass processing
- Early ASCII detection
- **139ms** for 269 files (**1.94x faster**)

---

**Archive Location**: `.archive/old-versions-pre-v2.0-2025-11-18_093013/`
**Safe to Delete**: Yes (after verification current versions work)
