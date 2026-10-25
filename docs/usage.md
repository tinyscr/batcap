# Usage

Batcap writes one line per run to `logs/batcap.log`. It has no window, service, or alert.

## Build

Skip this if you downloaded a release.

Run `build.ps1` from the repo root. It finds the .NET Framework 4.0 compiler and writes an AnyCPU `bin/batcap.exe`.

If PowerShell blocks the script, run `powershell -NoProfile -ExecutionPolicy Bypass -File .\build.ps1`.

## First run

1. Set `DesignCapacity` in `bin/.conf`. See [configuration](config.md).
2. Enable `WearPercent=true` and `EquivCycles=true` if you want computed health fields.
3. Run `bin/batcap.exe`. It appends a line to `logs/batcap.log`.
4. Check the log.

## Schedule

Use Task Scheduler with a daily or weekly trigger. Run hourly if you want charge and discharge detail.

1. Action: start `bin\batcap.exe` by full path.
2. Conditions: clear "Start the task only if the computer is on AC power" and "Stop if the computer switches to battery power".
3. Run the task once and check the log.

"Start in" is optional. Batcap resolves paths from the exe location. Keep `bin` and `logs` as sibling folders.

## Log format

```
[2026-07-23 15:01:15] Design=44021mWh Full=44494mWh Remaining=39555mWh Voltage=11794mV ChargeRate=0mW DischargeRate=12949mW Charging=False
```

Timestamp is local time. Fields are in a fixed order, but disabled or unavailable fields are omitted. Parse `key=value`, not columns.

| Field | Source | Unit |
|---|---|---|
| `Design` | `DesignCapacity` in `bin/.conf` | mWh |
| `Full` | `BatteryFullChargedCapacity` | mWh |
| `Remaining` | `BatteryStatus` | mWh |
| `Voltage` | `BatteryStatus` | mV |
| `ChargeRate` | `BatteryStatus` | mW |
| `DischargeRate` | `BatteryStatus` | mW |
| `Charging` | `BatteryStatus` | bool |
| `PowerOnline` | `BatteryStatus` | bool |
| `Critical` | `BatteryStatus` | bool |
| `Chemistry` | `Win32_Battery` | name |
| `EstimatedChargeRemaining` | `Win32_Battery` | % |
| `WearPercent` | computed | % |
| `EquivCycles` | computed | cycles (estimated) |

## Reading the numbers

`WearPercent` is `(Design - Full) / Design * 100`. Negative means `Full` is above `Design`; check both values.

`EquivCycles` is cumulative sampled discharge divided by `DesignCapacity`. It is a trend, not the firmware cycle count.

## Exit codes

- `0`: line written.
- `1`: error. See the `ERROR` line in the log.

## Limitations

- No retention policy. Archive or delete `logs/batcap.log` yourself.
- No alerts. Check the log or Task Scheduler history.
- No multiple batteries. Reads the first WMI battery object.
- No cycle count or battery temperature.
- WMI values can be stale or coarse.
- No CSV or JSON. Parse `key=value` pairs.
