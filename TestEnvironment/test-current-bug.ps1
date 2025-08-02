# Test the current bug
$scriptPath = "C:\code\UnicodeReplacementTool\Replace-UnicodeInScripts.ps1"

# Test with a simple file
& $scriptPath -Path "C:\code\UnicodeReplacementTool\TestEnvironment\TestFiles\test-unicode-simple.ps1" -PreviewOnly