Log battery wear and charge behavior on Windows laptops over time. Built for old laptops where `powercfg /batteryreport` is blank or incomplete.

Periodic logger, not a live monitor or battery repair tool.

## Quick start

1. Download a prebuilt binary from [Releases](https://github.com/tinyscr/batcap/releases), or build `bin/batcap.exe` with `build.ps1`.
2. Set `DesignCapacity` in `bin/.conf` to your battery's design capacity in mWh. The default `44021` is the author's EliteBook value, not a generic default.
3. Enable `WearPercent=true` and `EquivCycles=true` if you want computed health fields.
4. Run `bin/batcap.exe`. It appends a line to `logs/batcap.log`.
5. Schedule the exe daily or weekly with Task Scheduler. Clear the AC-power conditions so it runs on battery.

## Output

```
[2026-07-23 15:01:15] Design=44021mWh Full=44494mWh Remaining=39555mWh Voltage=11794mV ChargeRate=0mW DischargeRate=12949mW Charging=False
```

Fields are optional and configured in `bin/.conf`. `WearPercent` and `EquivCycles` add computed health fields.

## Requirements

- Windows 7 or later with .NET Framework 4.0 or later.
- Battery data exposed through WMI. Some laptops do not expose it.
- Keep `bin` and `logs` as sibling folders.

## Limitations

- Design capacity is manual. A wrong value makes `WearPercent` and `EquivCycles` wrong.
- `EquivCycles` is an estimate, not the firmware cycle count.
- Samples on a schedule. It misses short power events between runs.
- Windows only. No alerts, CSV/JSON, retention policy, or multiple batteries.
- No data if the battery no longer reports capacity through WMI.

## Docs

- [Usage](docs/usage.md)
- [Configuration](docs/config.md)
- [Troubleshooting](docs/troubleshooting.md)
- [How it works](docs/how-it-works.md)
- [Project history](docs/STORY.md)
