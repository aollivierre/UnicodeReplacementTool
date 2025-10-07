#!/usr/bin/env python3
"""
Test script for HyperSpeed Monitor Performance
Creates test files with Unicode and measures processing speed
"""

import os
import time
import shutil
from pathlib import Path

# Test content with Unicode characters
TEST_CONTENT = """
# PowerShell Test Script with Unicode
Write-Host "Testing → arrows ← and ↑ ↓ directions"
$config = @{
    'Name' = 'Test 🚀 Rocket Deployment'
    'Status' = '✅ Complete Successfully'
    'Warning' = '⚠ Check this issue'
    'Math' = '∑ ∞ ≈ π calculations'
    'Currency' = '€100 £50 ¥1000'
}
# Smart quotes: "Hello" and 'World'
# Em dash — and en dash –
# Bullets: • First • Second • Third
# Box drawing: ┌─┐ │ └─┘
"""

def create_test_files(num_files=10):
    """Create test files with Unicode content"""
    test_dir = Path("C:\\temp\\hyperspeed-test")
    test_dir.mkdir(exist_ok=True)

    files = []
    for i in range(num_files):
        file_path = test_dir / f"test-{i:03d}.ps1"
        file_path.write_text(TEST_CONTENT, encoding='utf-8')
        files.append(file_path)

    return files

def measure_monitor_performance():
    """Test the hyperspeed monitor performance"""
    print("="*60)
    print("HYPERSPEED MONITOR PERFORMANCE TEST")
    print("="*60)

    # Clean up any previous test
    test_dir = Path("C:\\temp\\hyperspeed-test")
    if test_dir.exists():
        shutil.rmtree(test_dir)

    print("\n1. Creating 10 test files with Unicode...")
    files = create_test_files(10)
    print(f"   Created {len(files)} files")

    print("\n2. Waiting for monitor to process...")
    print("   (Monitor should detect and process within milliseconds)")

    # Give monitor time to process
    time.sleep(2)

    print("\n3. Checking results...")
    processed = 0
    for file_path in files:
        content = file_path.read_text(encoding='utf-8', errors='ignore')
        # Check if Unicode was replaced
        if '→' not in content and '[' in content:
            processed += 1

    print(f"   Processed: {processed}/{len(files)} files")

    print("\n4. Testing rapid file creation...")
    print("   Creating 100 files as fast as possible...")

    start_time = time.perf_counter()
    rapid_files = []
    for i in range(100):
        file_path = test_dir / f"rapid-{i:03d}.ps1"
        file_path.write_text(TEST_CONTENT, encoding='utf-8')
        rapid_files.append(file_path)

    creation_time = (time.perf_counter() - start_time) * 1000
    print(f"   Created 100 files in {creation_time:.1f}ms")
    print(f"   Average: {creation_time/100:.2f}ms per file")

    # Wait for processing
    time.sleep(3)

    # Check how many were processed
    rapid_processed = 0
    for file_path in rapid_files:
        content = file_path.read_text(encoding='utf-8', errors='ignore')
        if '→' not in content:
            rapid_processed += 1

    print(f"   Monitor processed: {rapid_processed}/100 files")

    print("\n5. Performance Summary:")
    if rapid_processed > 0:
        # Estimate processing speed
        # Assuming monitor processed them all within the wait time
        estimated_speed = (3000 / rapid_processed)  # ms per file
        print(f"   Estimated speed: <{estimated_speed:.1f}ms per file")

        if estimated_speed < 0.5:
            print("   ✓ ACHIEVED SUB-0.5ms TARGET!")
        elif estimated_speed < 1.0:
            print("   ✓ Sub-1ms performance (excellent)")
        elif estimated_speed < 2.0:
            print("   ✓ Sub-2ms performance (good)")
        else:
            print("   → Performance needs optimization")

    print("\n6. Cleanup...")
    shutil.rmtree(test_dir)
    print("   Test files removed")

    print("\n" + "="*60)
    print("TEST COMPLETE")
    print("="*60)
    print("\nCheck the monitor log for detailed timing:")
    print("C:\\code\\vscode.ext\\Logs\\unicode-hyperspeed.log")

if __name__ == "__main__":
    measure_monitor_performance()