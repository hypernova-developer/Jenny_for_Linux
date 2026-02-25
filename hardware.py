import psutil
import platform
import subprocess
import os

class HardwareDetective:
    def get_system_summary(self):
        info = {}
        info["motherboard"] = self._get_cmd_output("cat /sys/class/dmi/id/board_vendor && cat /sys/class/dmi/id/board_name")
        info["cpu"] = self._get_cpu_model()
        info["ram"] = f"{round(psutil.virtual_memory().total / (1024**3), 2)} GB"
        info["resolution"] = self._get_cmd_output("xdpyinfo | grep dimensions | awk '{print $2}'")
        info["gpus"] = self._get_gpu_info()
        info["storage"] = self._get_storage_info()
        return info

    def _get_cpu_model(self):
        cmd = "grep 'model name' /proc/cpuinfo | head -n1 | cut -d':' -f2"
        return subprocess.check_output(cmd, shell=True).decode().strip()

    def _get_gpu_info(self):
        try:
            cmd = "lspci | grep -i vga | cut -d':' -f3"
            gpu_name = subprocess.check_output(cmd, shell=True).decode().strip()
            return [{"name": gpu_name, "driver": "NVIDIA/Mesa (Linux Native)"}]
        except: return []

    def _get_storage_info(self):
        cmd = "lsblk -d -o NAME,SIZE | grep -E 'sd|nvme'"
        return subprocess.check_output(cmd, shell=True).decode().strip().replace("\n", " | ")

    def _get_cmd_output(self, cmd):
        try: return subprocess.check_output(cmd, shell=True).decode().strip()
        except: return "Unknown"

    def check_app_updates(self):
        try:
            result = subprocess.run(['sudo', 'apt', 'update'], capture_output=True, text=True)
            return "Updates available. Use 'apt list --upgradable' for details."
        except: return "APT could not be accessed."

    def upgrade_apps(self, app_id=None):
        try:
            if app_id: subprocess.run(['sudo', 'apt', 'install', '--only-upgrade', app_id])
            else: subprocess.run(['sudo', 'apt', 'upgrade', '-y'])
            return True
        except: return False

    def check_driver_updates(self):
        return ["Kernels and drivers are managed via apt upgrade."]
