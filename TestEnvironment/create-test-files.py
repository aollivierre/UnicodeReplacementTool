#!/usr/bin/env python3
"""Create test files with Unicode content"""

import os

test_dir = r"C:\code\UnicodeReplacementTool\TestEnvironment\ComprehensiveTest"
os.makedirs(test_dir, exist_ok=True)

# Test files
files = {
    "test-empty.ps1": "",
    "test-only-unicode.ps1": "✓✗⚠🚀💡",
    "test-no-unicode.ps1": "Write-Host 'Hello World'",
    "test-complex.ps1": """# PowerShell script with various Unicode scenarios
function Test-Unicode {
    # Single quotes with Unicode
    Write-Host '✓ Success'
    
    # Double quotes with Unicode
    Write-Host "✗ Failed: $error"
    
    # Here-string with Unicode
    $message = @"
🚀 Deployment starting...
⚠ Warning: Check configuration
✓ Done!
"@
    
    # Unicode in variables
    $status = "✓"
    $arrows = @{
        "right" = "→"
        "left" = "←"
        "both" = "↔"
    }
    
    # Unicode in comments
    # → This is a comment with arrow
    # π = 3.14159...
    
    # Math operations (conceptual)
    # ∑(1..10) = 55
    # ∞ loops should be avoided
}

# Edge case: Unicode at file boundaries
Write-Host "Start→Middle→End"
"""
}

for filename, content in files.items():
    filepath = os.path.join(test_dir, filename)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Created: {filename}")

print("Test files created successfully!")