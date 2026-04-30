#!/usr/bin/env python3
"""
Benchmark: ThreadPoolExecutor vs asyncio/aiofiles
Real-world performance comparison for Unicode replacement
"""

import time
import sys
from pathlib import Path
from typing import List, Dict
import statistics

# Import both implementations
from unicode_replacer_optimized import process_files_parallel

sys.path.insert(0, str(Path(__file__).parent))


def create_test_files(test_dir: Path, count: int, size: str = "small") -> List[Path]:
    """Create test files with various Unicode content"""
    test_dir.mkdir(exist_ok=True)
    files = []

    # Size configurations
    sizes = {
        "small": (50, 100),      # 50-100 lines
        "medium": (500, 1000),   # 500-1K lines
        "large": (2000, 5000)    # 2K-5K lines
    }

    min_lines, max_lines = sizes.get(size, sizes["small"])

    for i in range(count):
        filepath = test_dir / f"test_file_{i}.ps1"

        # Mix of clean and dirty files
        if i % 3 == 0:
            # Clean file (no Unicode)
            content = "Write-Host 'Clean file' -ForegroundColor Green\n" * min_lines
        elif i % 3 == 1:
            # Light Unicode (10%) - using Unicode escape sequences
            base = "Write-Host 'Normal line' -ForegroundColor Green\n" * (min_lines // 2)
            unicode_lines = "Write-Host \u201CSmart quotes: \u201Ctest\u201D\u201D -ForegroundColor Yellow\n" * (min_lines // 10)
            content = base + unicode_lines + base
        else:
            # Heavy Unicode (30%) - using Unicode escape sequences
            base = "Write-Host 'Normal line' -ForegroundColor Green\n" * (min_lines // 3)
            unicode_lines = "Write-Host \u201CSmart quotes: \u201Ctest\u201D with \u2014dash\u2014 and \u2026ellipsis\u2026\u201D -ForegroundColor Yellow\n" * (min_lines // 3)
            content = base + unicode_lines + base

        # Write using Python with UTF-8 encoding to preserve Unicode
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        files.append(filepath)

    return files


def run_benchmark(files: List[Path], method: str, workers: int = None) -> Dict:
    """Run benchmark for specified method"""
    results = []
    iterations = 3

    for i in range(iterations):
        start = time.perf_counter()

        if method == "threads":
            from unicode_replacer_optimized import process_files_parallel
            process_files_parallel(files, preview_only=True, create_backup=False, max_workers=workers)
        elif method == "async":
            from unicode_replacer_async import process_files_async
            process_files_async(files, preview_only=True, max_concurrent=workers)

        elapsed = (time.perf_counter() - start) * 1000  # Convert to ms
        results.append(elapsed)

        # Small delay between iterations
        time.sleep(0.1)

    return {
        'method': method,
        'workers': workers,
        'iterations': iterations,
        'times_ms': results,
        'avg_ms': statistics.mean(results),
        'median_ms': statistics.median(results),
        'min_ms': min(results),
        'max_ms': max(results),
        'stddev_ms': statistics.stdev(results) if len(results) > 1 else 0
    }


def main():
    """Main benchmark runner"""
    print("=" * 80)
    print("BENCHMARK: ThreadPoolExecutor vs asyncio/aiofiles")
    print("=" * 80)
    print()

    # Check if aiofiles is installed
    try:
        import aiofiles
        print("[OK] aiofiles installed")
    except ImportError:
        print("[INFO] aiofiles NOT installed - installing now...")
        import subprocess
        result = subprocess.run([sys.executable, "-m", "pip", "install", "aiofiles"], capture_output=True, text=True)
        if result.returncode == 0:
            print("[OK] aiofiles installed successfully")
        else:
            print(f"[ERROR] Failed to install aiofiles: {result.stderr}")
            return

    print()

    # Test configurations
    test_configs = [
        {"name": "Small files (10 files, 50-100 lines)", "count": 10, "size": "small"},
        {"name": "Medium files (20 files, 500-1K lines)", "count": 20, "size": "medium"},
        {"name": "Large files (50 files, 2K-5K lines)", "count": 50, "size": "large"},
    ]

    test_dir = Path("C:/temp/unicode_benchmark_test")

    all_results = []

    for config in test_configs:
        print(f"\n{'=' * 80}")
        print(f"TEST: {config['name']}")
        print(f"{'=' * 80}")

        # Create test files
        print(f"Creating {config['count']} test files ({config['size']} size)...")
        files = create_test_files(test_dir, config['count'], config['size'])
        print(f"[OK] Created {len(files)} files")
        print()

        # Run benchmarks
        worker_counts = [None, 5, 10, 20]  # None = auto-detect

        for workers in worker_counts:
            worker_label = "auto" if workers is None else str(workers)

            print(f"Testing ThreadPoolExecutor (workers={worker_label})...", end=" ", flush=True)
            threads_result = run_benchmark(files, "threads", workers)
            print(f"{threads_result['avg_ms']:.1f}ms avg")

            print(f"Testing asyncio/aiofiles (concurrent={worker_label})...", end=" ", flush=True)
            async_result = run_benchmark(files, "async", workers)
            print(f"{async_result['avg_ms']:.1f}ms avg")

            speedup = threads_result['avg_ms'] / async_result['avg_ms']
            winner = "ASYNC" if speedup > 1 else "THREADS"
            improvement_pct = abs(speedup - 1) * 100

            print(f"  => {winner} is {improvement_pct:.1f}% faster (speedup: {speedup:.2f}x)")
            print()

            all_results.append({
                'config': config['name'],
                'workers': worker_label,
                'threads': threads_result,
                'async': async_result,
                'speedup': speedup,
                'winner': winner
            })

    # Summary
    print("\n" + "=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print()

    print(f"{'Test':<40} {'Workers':<10} {'Threads (ms)':<15} {'Async (ms)':<15} {'Winner':<10} {'Speedup'}")
    print("-" * 95)

    for result in all_results:
        print(f"{result['config']:<40} {result['workers']:<10} "
              f"{result['threads']['avg_ms']:<15.1f} {result['async']['avg_ms']:<15.1f} "
              f"{result['winner']:<10} {result['speedup']:.2f}x")

    # Overall winner
    async_wins = sum(1 for r in all_results if r['winner'] == 'ASYNC')
    thread_wins = sum(1 for r in all_results if r['winner'] == 'THREADS')

    print()
    print(f"Overall: Async wins {async_wins}/{len(all_results)} tests, Threads wins {thread_wins}/{len(all_results)} tests")

    avg_speedup = statistics.mean([r['speedup'] for r in all_results])
    if avg_speedup > 1:
        print(f"Average async advantage: {(avg_speedup - 1) * 100:.1f}% faster")
    else:
        print(f"Average threads advantage: {(1/avg_speedup - 1) * 100:.1f}% faster")

    print()
    print("=" * 80)
    print("RECOMMENDATION")
    print("=" * 80)

    if avg_speedup > 1.15:
        print("[RECOMMEND] ASYNC provides significant gains (>15%) - RECOMMEND switching to asyncio")
    elif avg_speedup > 1.05:
        print("[CONSIDER] ASYNC provides modest gains (5-15%) - Consider switching based on complexity trade-off")
    else:
        print("[KEEP] THREADS are competitive or better - RECOMMEND keeping ThreadPoolExecutor")

    print()

    # Cleanup
    import shutil
    shutil.rmtree(test_dir, ignore_errors=True)
    print(f"[OK] Cleaned up test directory: {test_dir}")


if __name__ == "__main__":
    main()
