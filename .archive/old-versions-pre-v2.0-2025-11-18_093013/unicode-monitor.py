#!/usr/bin/env python3
"""
Real-time Unicode File Monitor
Monitors directories for new PS1, PSM1, and PY files and replaces Unicode immediately
"""

import os
import sys
import time
import logging
import subprocess
from pathlib import Path
from datetime import datetime
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# Configuration
MONITOR_PATHS = ["C:\\code", "C:\\temp"]
UNICODE_REPLACER = "C:\\code\\UnicodeReplacementTool\\unicode_replacer.py"
LOG_FILE = "C:\\code\\vscode.ext\\Logs\\unicode-monitor-python.log"
FILE_EXTENSIONS = {'.ps1', '.psm1', '.py'}
PROCESSING_DELAY = 0.1  # Small delay to ensure file write is complete

# Setup logging
os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s.%(msecs)03d] [%(levelname)s] %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

class UnicodeReplacementHandler(FileSystemEventHandler):
    """Handles file system events and triggers Unicode replacement"""

    def __init__(self):
        self.processed_files = {}
        self.processing_files = set()

    def should_process(self, file_path):
        """Check if file should be processed"""
        path = Path(file_path)

        # Check extension
        if path.suffix.lower() not in FILE_EXTENSIONS:
            return False

        # Skip if already processing
        if file_path in self.processing_files:
            return False

        # Skip if recently processed (within 5 seconds)
        if file_path in self.processed_files:
            last_processed = self.processed_files[file_path]
            if (datetime.now() - last_processed).total_seconds() < 5:
                return False

        return True

    def process_file(self, file_path):
        """Process a file with Unicode replacement"""
        if not self.should_process(file_path):
            return

        try:
            # Mark as processing
            self.processing_files.add(file_path)
            logger.info(f"Processing file: {file_path}")

            # Small delay to ensure file write is complete
            time.sleep(PROCESSING_DELAY)

            # Check if file exists
            if not os.path.exists(file_path):
                logger.warning(f"File not found: {file_path}")
                return

            # Run Unicode replacer
            start_time = time.time()
            result = subprocess.run(
                [sys.executable, UNICODE_REPLACER, file_path],
                capture_output=True,
                text=True,
                timeout=30
            )

            processing_time = (time.time() - start_time) * 1000  # Convert to ms

            if result.returncode == 0:
                # Parse output for replacement count
                if "Total replacements:" in result.stdout:
                    for line in result.stdout.split('\n'):
                        if "Total replacements:" in line:
                            logger.info(f"SUCCESS: Processed {file_path} in {processing_time:.0f}ms - {line.strip()}")
                            break
                else:
                    logger.info(f"SUCCESS: Processed {file_path} in {processing_time:.0f}ms")
            else:
                logger.error(f"Failed to process {file_path}: {result.stderr}")

            # Mark as processed
            self.processed_files[file_path] = datetime.now()

            # Clean old entries (older than 1 minute)
            cutoff = datetime.now()
            self.processed_files = {
                k: v for k, v in self.processed_files.items()
                if (cutoff - v).total_seconds() < 60
            }

        except subprocess.TimeoutExpired:
            logger.error(f"Timeout processing {file_path}")
        except Exception as e:
            logger.error(f"Error processing {file_path}: {e}")
        finally:
            self.processing_files.discard(file_path)

    def on_created(self, event):
        """Handle file creation events"""
        if not event.is_directory:
            logger.info(f"Detected new file: {event.src_path}")
            self.process_file(event.src_path)

    def on_modified(self, event):
        """Handle file modification events (for very quick writes)"""
        if not event.is_directory:
            path = Path(event.src_path)

            # Only process if file is very new (created within 2 seconds)
            try:
                if path.exists():
                    creation_time = path.stat().st_ctime
                    if (time.time() - creation_time) < 2:
                        logger.info(f"Detected quick-write new file: {event.src_path}")
                        self.process_file(event.src_path)
            except:
                pass

def verify_setup():
    """Verify all prerequisites are met"""
    issues = []

    # Check Python version
    if sys.version_info < (3, 6):
        issues.append(f"Python 3.6+ required, found {sys.version}")

    # Check Unicode replacer exists
    if not os.path.exists(UNICODE_REPLACER):
        issues.append(f"Unicode replacer not found: {UNICODE_REPLACER}")

    # Check watchdog is installed
    try:
        import watchdog
    except ImportError:
        issues.append("Watchdog library not installed. Run: pip install watchdog")

    # Check monitor paths exist
    for path in MONITOR_PATHS:
        if not os.path.exists(path):
            logger.warning(f"Monitor path does not exist: {path}")

    return issues

def main():
    """Main monitoring loop"""
    logger.info("="*60)
    logger.info("Unicode File Monitor Starting (Python)")
    logger.info("="*60)
    logger.info(f"Monitor Paths: {', '.join(MONITOR_PATHS)}")
    logger.info(f"File Types: {', '.join(FILE_EXTENSIONS)}")
    logger.info(f"Unicode Replacer: {UNICODE_REPLACER}")
    logger.info(f"Log File: {LOG_FILE}")

    # Verify setup
    issues = verify_setup()
    if issues:
        for issue in issues:
            logger.error(issue)
        logger.error("Setup verification failed. Exiting.")
        return 1

    # Create event handler and observer
    event_handler = UnicodeReplacementHandler()
    observer = Observer()

    # Schedule observers for each path
    for path in MONITOR_PATHS:
        if os.path.exists(path):
            observer.schedule(event_handler, path, recursive=True)
            logger.info(f"Monitoring: {path}")

    # Start monitoring
    observer.start()
    logger.info("Monitoring started. Press Ctrl+C to stop.")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        logger.info("Stopping monitor...")
        observer.stop()

    observer.join()
    logger.info("Monitor stopped")
    return 0

if __name__ == "__main__":
    sys.exit(main())