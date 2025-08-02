# Create backup of SetupLab before Unicode replacement
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "C:\code\SetupLab_Backup_$timestamp"

Write-Host "Creating backup of SetupLab to: $backupDir" -ForegroundColor Yellow

# Create backup using robocopy (preserves all attributes)
$robocopyArgs = @(
    "C:\code\SetupLab",
    $backupDir,
    "/E",           # Copy subdirectories including empty ones
    "/COPYALL",     # Copy all file attributes
    "/R:1",         # Retry once on failure
    "/W:1",         # Wait 1 second between retries
    "/NP",          # No progress percentage
    "/LOG:C:\code\SetupLab_Backup_$timestamp.log"
)

& robocopy @robocopyArgs

if ($LASTEXITCODE -le 7) {
    Write-Host "Backup completed successfully to: $backupDir" -ForegroundColor Green
    Write-Host "Log file: C:\code\SetupLab_Backup_$timestamp.log" -ForegroundColor Green
    
    # Verify backup
    $sourceCount = (Get-ChildItem "C:\code\SetupLab" -Recurse -File).Count
    $backupCount = (Get-ChildItem $backupDir -Recurse -File).Count
    Write-Host "Source files: $sourceCount" -ForegroundColor Cyan
    Write-Host "Backup files: $backupCount" -ForegroundColor Cyan
} else {
    Write-Host "Backup failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    exit 1
}