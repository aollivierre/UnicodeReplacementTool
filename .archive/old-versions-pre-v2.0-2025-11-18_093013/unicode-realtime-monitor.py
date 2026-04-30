#!/usr/bin/env python3
"""
Ultra-Fast Real-Time Unicode Monitor
Responds to file changes in milliseconds, not minutes
Perfect for rapid agentic coding workflows
"""

import os
import sys
import time
import threading
import queue
import subprocess
from datetime import datetime
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import json

# Configuration
MONITOR_PATHS = ["C:\\code", "C:\\temp", "C:\\code\\vscode.ext"]
UNICODE_REPLACER = "C:\\code\\UnicodeReplacementTool\\unicode_replacer.py"
LOG_FILE = "C:\\code\\vscode.ext\\Logs\\unicode-realtime.log"
FILE_EXTENSIONS = {'.ps1', '.psm1', '.py'}  # Only PowerShell and Python files
DEBOUNCE_MS = 100  # Milliseconds to wait before processing (prevents duplicate events)
MAX_WORKERS = 4  # Number of parallel processing threads

class FastUnicodeHandler(FileSystemEventHandler):
    """Ultra-fast file system event handler"""

    def __init__(self):
        self.processing_queue = queue.Queue()
        self.processed_files = {}
        self.lock = threading.Lock()
        # Capture EXACT startup time - only process files after this
        self.startup_time = datetime.now()
        self.startup_timestamp = time.time()
        self.start_workers()

    def start_workers(self):
        """Start worker threads for parallel processing"""
        for i in range(MAX_WORKERS):
            worker = threading.Thread(target=self.process_worker, daemon=True)
            worker.start()

    def on_created(self, event):
        """Handle file creation events"""
        if not event.is_directory:
            self.queue_file(event.src_path, "created")

    def on_modified(self, event):
        """Handle file modification events"""
        if not event.is_directory:
            self.queue_file(event.src_path, "modified")

    def queue_file(self, filepath, event_type):
        """Queue file for processing with debouncing"""
        # DYNAMIC SAFETY CHECK - Only process files modified AFTER monitor startup
        try:
            file_modified_time = os.path.getmtime(filepath)

            if file_modified_time < self.startup_timestamp:
                # File was last modified BEFORE monitor started - skip it
                return  # Silently skip old files
        except:
            return  # If we can't check date, don't process

        # Skip files in Logs directory to prevent infinite loop
        if 'Logs' in filepath or '\\Logs\\' in filepath:
            return  # Silently skip log files

        # CRITICAL: Skip the Unicode replacement tool itself to prevent self-corruption
        if 'UnicodeReplacementTool' in filepath or 'unicode_replacer.py' in filepath:
            return  # Never process the tool itself!

        # Skip the monitor script itself
        if 'unicode-realtime-monitor.py' in filepath or 'unicode-monitor' in filepath:
            return  # Never process monitor scripts

        # Check if it's a file we care about
        if not any(filepath.lower().endswith(ext) for ext in FILE_EXTENSIONS):
            # Don't log skipped files - too verbose
            return

        # Skip temp files
        filename = os.path.basename(filepath)
        if '.tmp' in filename or filename.startswith('~') or filename.startswith('.'):
            return  # Silently skip temp files

        # Debounce - prevent processing same file multiple times in quick succession
        with self.lock:
            now = time.time() * 1000  # Convert to milliseconds
            last_processed = self.processed_files.get(filepath, 0)

            if now - last_processed < DEBOUNCE_MS:
                return  # Skip if processed very recently

            self.processed_files[filepath] = now

        # Queue for processing
        self.processing_queue.put((filepath, event_type, datetime.now()))
        self.log(f"[QUEUED] {event_type.upper()}: {filepath}")

    def process_worker(self):
        """Worker thread that processes files from queue"""
        while True:
            try:
                filepath, event_type, timestamp = self.processing_queue.get(timeout=1)

                # Calculate response time
                response_ms = (datetime.now() - timestamp).total_seconds() * 1000

                # Process the file immediately - no delays for FAST agentic coding!
                start_time = time.time()
                replacements = self.process_file(filepath)
                process_ms = (time.time() - start_time) * 1000

                if replacements > 0:
                    self.log(f"[SUCCESS] {filepath}: {replacements} replacements in {process_ms:.1f}ms (response: {response_ms:.1f}ms)")
                elif replacements == 0:
                    self.log(f"[CLEAN] {filepath}: No Unicode found ({process_ms:.1f}ms)")
                else:
                    self.log(f"[ERROR] {filepath}: Processing failed", "ERROR")

                self.processing_queue.task_done()

            except queue.Empty:
                continue
            except Exception as e:
                self.log(f"[ERROR] Worker exception: {e}", "ERROR")

    def process_file(self, filepath):
        """Process a single file for Unicode replacement"""
        try:
            # DOUBLE-CHECK: Only process files modified after monitor startup
            file_modified_time = os.path.getmtime(filepath)

            if file_modified_time < self.startup_timestamp:
                self.log(f"[SKIPPED] {filepath}: File predates monitor startup. PROTECTED.")
                return 0  # DO NOT PROCESS OLD FILES

            # Quick check if file has Unicode before processing
            # COMMENTED OUT - This check was incorrectly reporting "No Unicode found"
            # The detection logic was failing to identify Unicode characters properly
            # Now always running the replacer to ensure Unicode is caught
            # try:
            #     with open(filepath, 'r', encoding='utf-8') as f:
            #         content = f.read()
            #         # Quick check for common Unicode ranges
            #         if not any(ord(char) > 127 for char in content):
            #             return 0  # No Unicode, skip processing
            # except:
            #     pass  # If we can't read, let the replacer handle it

            # Run the Unicode replacer
            cmd = [sys.executable, UNICODE_REPLACER, filepath]
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=5  # Fast timeout for responsiveness
            )

            if result.returncode == 0:
                # Parse replacement count from output
                if "Total replacements: 0" in result.stdout:
                    return 0
                elif "Total replacements:" in result.stdout:
                    for line in result.stdout.split('\n'):
                        if "Total replacements:" in line:
                            try:
                                count = int(line.split(':')[1].strip())
                                return count
                            except:
                                return 1
                return 1
            else:
                # Log the actual error from stderr
                self.log(f"[SUBPROCESS ERROR] {filepath}: {result.stderr}", "ERROR")
                return -1

        except subprocess.TimeoutExpired:
            self.log(f"[TIMEOUT] {filepath}", "ERROR")
            return -1
        except Exception as e:
            self.log(f"[EXCEPTION] {filepath}: {e}", "ERROR")
            return -1

    def log(self, message, level="INFO"):
        """Fast logging with minimal overhead"""
        # Only log INFO level and above, skip DEBUG to reduce verbosity
        if level == "DEBUG":
            return
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]  # Include milliseconds
        entry = f"[{timestamp}] {message}"
        print(entry)

        # Async write to log file
        try:
            with open(LOG_FILE, 'a', encoding='utf-8') as f:
                f.write(entry + '\n')
        except:
            pass

class UltraFastMonitor:
    """Main monitor controller"""

    def __init__(self):
        self.observer = Observer()
        self.handler = FastUnicodeHandler()

    def start(self):
        """Start monitoring all configured paths"""
        startup_time = self.handler.startup_time
        print("="*60)
        print("ULTRA-FAST UNICODE MONITOR - MILLISECOND RESPONSE")
        print("="*60)
        print(f"Startup time: {startup_time.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]}")
        print(f"Processing: ONLY files modified AFTER startup")
        print(f"Monitoring paths: {', '.join(MONITOR_PATHS)}")
        print(f"File types: {', '.join(sorted(FILE_EXTENSIONS))}")
        print(f"Response time: <{DEBOUNCE_MS}ms")
        print(f"Worker threads: {MAX_WORKERS}")
        print("="*60)

        # Ensure log directory exists
        os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)

        # Schedule observers for each path
        for path in MONITOR_PATHS:
            if os.path.exists(path):
                self.observer.schedule(self.handler, path, recursive=True)
                print(f"[WATCHING] {path}")
            else:
                print(f"[SKIPPED] {path} (not found)")

        # Start the observer
        self.observer.start()
        print("\n[RUNNING] Monitor active. Press Ctrl+C to stop.")
        print("[READY] Millisecond response time enabled!\n")

        try:
            while True:
                time.sleep(1)
                # Print queue status periodically
                queue_size = self.handler.processing_queue.qsize()
                if queue_size > 0:
                    print(f"[QUEUE] {queue_size} files pending...")
        except KeyboardInterrupt:
            print("\n[STOPPING] Shutting down monitor...")
            self.observer.stop()
            print("[STOPPED] Monitor stopped.")

        self.observer.join()

def main():
    """Entry point"""
    # Check if watchdog is installed
    try:
        import watchdog
    except ImportError:
        print("[ERROR] watchdog library not installed!")
        print("Install with: pip install watchdog")
        sys.exit(1)

    # Check if Unicode replacer exists
    if not os.path.exists(UNICODE_REPLACER):
        print(f"[ERROR] Unicode replacer not found at: {UNICODE_REPLACER}")
        sys.exit(1)

    # Start the monitor
    monitor = UltraFastMonitor()
    monitor.start()

if __name__ == "__main__":
    main()
