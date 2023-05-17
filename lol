import time
import psutil
import os
import sys
import shutil
import winreg
from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import QApplication, QMainWindow

class BlockApplications(QApplication):
    def __init__(self, argv):
        super(BlockApplications, self).__init__(argv)
        self.main_window = QMainWindow()
        self.main_window.setWindowFlags(self.main_window.windowFlags() | Qt.WA_X11NetWmWindowTypeDesktop)

    def block_new_processes(self):
        blocked_processes = set(psutil.pids())

        while True:
            # Get the current set of running processes
            current_processes = set(psutil.pids())

            # Check if any new processes are launched
            new_processes = current_processes - blocked_processes
            if new_processes:
                print("New processes detected:", new_processes)

                # Terminate the new processes
                for pid in new_processes:
                    try:
                        process = psutil.Process(pid)
                        print("Terminating:", process.name())
                        process.terminate()
                    except (psutil.NoSuchProcess, psutil.AccessDenied):
                        pass

            # Sleep to reduce CPU usage
            time.sleep(1)

if __name__ == "__main__":
    print("Script started. Opening applications/files is blocked.")

    app = BlockApplications([])

    # Run the blocking mechanism
    app.block_new_processes()

    # Restore normal operation after the script ends
    print("Script ended. Opening applications/files is allowed.")

    # Check if the script is in startup and add it if not
    script_path = os.path.abspath(sys.argv[0])
    script_name = os.path.basename(script_path)
    startup_path = os.path.join(os.getenv('APPDATA'), 'Microsoft\\Windows\\Start Menu\\Programs\\Startup')
    startup_script_path = os.path.join(startup_path, script_name)

    if not os.path.exists(startup_script_path):
        print("Adding script to startup...")
        try:
            shutil.copyfile(script_path, startup_script_path)
            print("Script added to startup successfully.")

            # Restart the script immediately after adding it to startup
            os.system('start "" "' + startup_script_path + '"')
            sys.exit()

        except OSError:
            print("Failed to add script to startup.")

