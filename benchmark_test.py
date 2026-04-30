#!/usr/bin/env python3
"""
Performance Benchmark Test for Unicode Replacer
Creates test data and measures performance before/after optimization
"""

import os
import sys
import time
import tempfile
import shutil
from pathlib import Path
from typing import List, Dict

# Test data patterns - representative of real-world usage
TEST_PATTERNS = {
    'small_clean': {
        'size': 100,  # lines
        'unicode_density': 0.0,  # no unicode
        'description': 'Small clean file (100 lines, 0% unicode)'
    },
    'small_dirty': {
        'size': 100,
        'unicode_density': 0.2,  # 20% of lines have unicode
        'description': 'Small file with unicode (100 lines, 20% unicode)'
    },
    'medium_clean': {
        'size': 1000,
        'unicode_density': 0.0,
        'description': 'Medium clean file (1K lines, 0% unicode)'
    },
    'medium_dirty': {
        'size': 1000,
        'unicode_density': 0.15,
        'description': 'Medium file with unicode (1K lines, 15% unicode)'
    },
    'large_clean': {
        'size': 5000,
        'unicode_density': 0.0,
        'description': 'Large clean file (5K lines, 0% unicode)'
    },
    'large_dirty': {
        'size': 5000,
        'unicode_density': 0.10,
        'description': 'Large file with unicode (5K lines, 10% unicode)'
    }
}

# Unicode characters to inject (same as used in real files)
UNICODE_SAMPLES = ['✓', '✔', '✗', '→', '←', '🔧', '📁', '💾', '⚠', 'ℹ', '…', '—', '–', '"', '"']

def generate_test_line(line_num: int, has_unicode: bool) -> str:
    """Generate a realistic PowerShell script line"""
    base_lines = [
        f'# Comment line {line_num}',
        f'$variable{line_num} = "Some string value"',
        f'if ($condition{line_num}) {{',
        f'    Write-Host "Processing item {line_num}"',
        f'    Get-Process | Where-Object {{ $_.Name -eq "test{line_num}" }}',
        f'}}',
        f'function Test-Function{line_num} {{',
        f'    param($param{line_num})',
        f'    return $param{line_num} * 2',
    ]

    line = base_lines[line_num % len(base_lines)]

    if has_unicode:
        # Insert unicode at random position
        import random
        unicode_char = random.choice(UNICODE_SAMPLES)
        pos = len(line) // 2
        line = line[:pos] + unicode_char + line[pos:]

    return line

def create_test_file(filepath: Path, size: int, unicode_density: float):
    """Create a test file with specified characteristics"""
    import random
    lines = []

    for i in range(size):
        has_unicode = random.random() < unicode_density
        lines.append(generate_test_line(i, has_unicode))

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

def create_test_dataset(base_dir: Path, num_files_per_pattern: int = 5) -> Dict[str, List[Path]]:
    """Create a comprehensive test dataset"""
    print(f"Creating test dataset in {base_dir}")
    test_files = {}

    for pattern_name, config in TEST_PATTERNS.items():
        pattern_dir = base_dir / pattern_name
        pattern_dir.mkdir(parents=True, exist_ok=True)

        files = []
        for i in range(num_files_per_pattern):
            filepath = pattern_dir / f"test_{i}.ps1"
            create_test_file(filepath, config['size'], config['unicode_density'])
            files.append(filepath)

        test_files[pattern_name] = files
        print(f"  ✓ Created {len(files)} files for '{config['description']}'")

    return test_files

def count_total_lines(files: List[Path]) -> int:
    """Count total lines in all files"""
    total = 0
    for f in files:
        with open(f, 'r', encoding='utf-8') as fp:
            total += len(fp.readlines())
    return total

def benchmark_function(func, *args, warmup_runs: int = 1, timed_runs: int = 3, **kwargs):
    """Benchmark a function with warmup and multiple runs"""
    # Warmup
    for _ in range(warmup_runs):
        func(*args, **kwargs)

    # Timed runs
    times = []
    for _ in range(timed_runs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        end = time.perf_counter()
        times.append(end - start)

    return {
        'min': min(times),
        'max': max(times),
        'avg': sum(times) / len(times),
        'runs': timed_runs
    }

def run_benchmark_suite(test_base_dir: Path, script_path: Path, version_name: str) -> Dict:
    """Run complete benchmark suite on a version of the script"""
    print(f"\n{'='*70}")
    print(f"Benchmarking: {version_name}")
    print(f"{'='*70}")

    results = {}

    for pattern_name, config in TEST_PATTERNS.items():
        pattern_dir = test_base_dir / pattern_name
        if not pattern_dir.exists():
            continue

        print(f"\nTesting: {config['description']}")

        # Create temp directory for this run
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_pattern_dir = Path(temp_dir) / pattern_name
            shutil.copytree(pattern_dir, temp_pattern_dir)

            files = list(temp_pattern_dir.glob("*.ps1"))
            total_lines = count_total_lines(files)

            print(f"  Files: {len(files)}")
            print(f"  Total lines: {total_lines:,}")

            # Run benchmark
            def run_script():
                import subprocess
                result = subprocess.run(
                    [sys.executable, str(script_path), str(temp_pattern_dir), '--yes', '--no-backup'],
                    capture_output=True,
                    text=True
                )
                return result

            timing = benchmark_function(run_script, warmup_runs=1, timed_runs=3)

            print(f"  Time (avg): {timing['avg']:.4f}s")
            print(f"  Time (min): {timing['min']:.4f}s")
            print(f"  Time (max): {timing['max']:.4f}s")
            print(f"  Throughput: {total_lines / timing['avg']:,.0f} lines/sec")

            results[pattern_name] = {
                'config': config,
                'files': len(files),
                'total_lines': total_lines,
                'timing': timing,
                'throughput': total_lines / timing['avg']
            }

    return results

def generate_comparison_report(baseline_results: Dict, optimized_results: Dict):
    """Generate detailed comparison report"""
    print(f"\n{'='*70}")
    print("PERFORMANCE COMPARISON REPORT")
    print(f"{'='*70}\n")

    print(f"{'Pattern':<25} {'Baseline':<12} {'Optimized':<12} {'Speedup':<10} {'Status'}")
    print(f"{'-'*70}")

    total_baseline = 0
    total_optimized = 0

    for pattern_name in baseline_results.keys():
        baseline = baseline_results[pattern_name]
        optimized = optimized_results[pattern_name]

        baseline_time = baseline['timing']['avg']
        optimized_time = optimized['timing']['avg']
        speedup = baseline_time / optimized_time

        total_baseline += baseline_time
        total_optimized += optimized_time

        status = '🚀' if speedup > 2.0 else '✓' if speedup > 1.2 else '→'

        desc = baseline['config']['description'].split('(')[0].strip()
        print(f"{desc:<25} {baseline_time:>10.4f}s {optimized_time:>10.4f}s {speedup:>8.2f}x  {status}")

    print(f"{'-'*70}")
    overall_speedup = total_baseline / total_optimized
    print(f"{'TOTAL':<25} {total_baseline:>10.4f}s {total_optimized:>10.4f}s {overall_speedup:>8.2f}x")

    print(f"\n{'='*70}")
    print("DETAILED ANALYSIS")
    print(f"{'='*70}\n")

    # Throughput comparison
    print("Throughput (lines/sec):")
    print(f"{'Pattern':<25} {'Baseline':<15} {'Optimized':<15} {'Improvement'}")
    print(f"{'-'*70}")

    for pattern_name in baseline_results.keys():
        baseline = baseline_results[pattern_name]
        optimized = optimized_results[pattern_name]

        baseline_throughput = baseline['throughput']
        optimized_throughput = optimized['throughput']
        improvement = ((optimized_throughput - baseline_throughput) / baseline_throughput) * 100

        desc = baseline['config']['description'].split('(')[0].strip()
        print(f"{desc:<25} {baseline_throughput:>13,.0f} {optimized_throughput:>13,.0f} {improvement:>12.1f}%")

    print(f"\n{'='*70}")
    print("KEY FINDINGS")
    print(f"{'='*70}\n")

    # Find best and worst improvements
    speedups = []
    for pattern_name in baseline_results.keys():
        baseline_time = baseline_results[pattern_name]['timing']['avg']
        optimized_time = optimized_results[pattern_name]['timing']['avg']
        speedup = baseline_time / optimized_time
        speedups.append((pattern_name, speedup, baseline_results[pattern_name]['config']['description']))

    speedups.sort(key=lambda x: x[1], reverse=True)

    print(f"Best improvement: {speedups[0][1]:.2f}x - {speedups[0][2]}")
    print(f"Worst improvement: {speedups[-1][1]:.2f}x - {speedups[-1][2]}")
    print(f"Overall speedup: {overall_speedup:.2f}x")
    print(f"Total time saved: {total_baseline - total_optimized:.4f}s ({((total_baseline - total_optimized) / total_baseline * 100):.1f}%)")

def main():
    # Setup
    base_dir = Path(__file__).parent
    test_data_dir = base_dir / "benchmark_test_data"

    baseline_script = base_dir / "unicode_replacer.py"
    optimized_script = base_dir / "unicode_replacer_optimized.py"

    # Check if scripts exist
    if not baseline_script.exists():
        print(f"Error: Baseline script not found: {baseline_script}")
        return 1

    if not optimized_script.exists():
        print(f"Error: Optimized script not found: {optimized_script}")
        print("Run this benchmark after creating the optimized version")
        return 1

    # Create test dataset
    print("="*70)
    print("UNICODE REPLACER PERFORMANCE BENCHMARK")
    print("="*70)

    if test_data_dir.exists():
        print(f"\nUsing existing test data: {test_data_dir}")
    else:
        print(f"\nCreating test dataset...")
        test_files = create_test_dataset(test_data_dir, num_files_per_pattern=10)
        print(f"Test dataset created: {test_data_dir}")

    # Run benchmarks
    baseline_results = run_benchmark_suite(test_data_dir, baseline_script, "BASELINE (current)")
    optimized_results = run_benchmark_suite(test_data_dir, optimized_script, "OPTIMIZED (new)")

    # Generate comparison report
    generate_comparison_report(baseline_results, optimized_results)

    print(f"\n{'='*70}")
    print("Benchmark complete!")
    print(f"{'='*70}")

    return 0

if __name__ == '__main__':
    sys.exit(main())
