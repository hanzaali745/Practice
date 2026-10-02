#!/usr/bin/env python3
class Disk:
    def __init__(self, mount: str, total_gb: float, used_gb: float):
        self.mount = mount
        self.total_gb = total_gb
        self.used_gb = used_gb

    @property
    def free_gb(self) -> float:
        return self.total_gb - self.used_gb

    @property
    def percent_used(self) -> float:
        return self.used_gb / self.total_gb * 100

    @property
    def status(self) -> str:
        if self.percent_used >= 90:
            return "CRIT"
        if self.percent_used >= 80:
            return "WARN"
        return "OK"

    @classmethod
    def from_df_line(cls, line: str) -> "Disk":
        """Parse a `df -h` style line: device size used avail use% mount."""
        _device, size, used, _avail, _pct, mount = line.split()
        return cls(mount, float(size.rstrip("G")), float(used.rstrip("G")))

    def __str__(self) -> str:
        return f"{self.mount}: {self.percent_used:.0f}% used, {self.free_gb:.0f}G free [{self.status}]"


if __name__ == "__main__":
    print(Disk.from_df_line("/dev/sda1  500G  455G  45G  91% /"))
    print(Disk("/data", 1000, 820))
    print(Disk("/home", 200, 50))
