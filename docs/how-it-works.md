# How it works

Batcap reads `bin/.conf`, queries WMI, updates `bin/.cyclestate`, and appends one line to `logs/batcap.log`. It has no service or background loop.

## Run flow

1. Load `bin/.conf` from the exe folder.
2. Query only the WMI classes needed by enabled fields.
3. Update the discharge total if `Remaining` fell while not charging.
4. If an enabled source returns no usable data, log `ERROR` and exit 1.
5. Build the line, append it to `logs/batcap.log`, exit 0.

`Local\batcap` serializes runs. A second instance waits 10 seconds, then exits 1.

## WMI sources

| Source | Namespace | Fields | Notes |
|---|---|---|---|
| `BatteryFullChargedCapacity` | `root\WMI` | `Full` | First object only. |
| `BatteryStatus` | `root\WMI` | `Remaining`, `Voltage`, `ChargeRate`, `DischargeRate`, `Charging`, `PowerOnline`, `Critical` | All fields from the first object. |
| `Win32_Battery` | `root\cimv2` | `Chemistry`, `EstimatedChargeRemaining` | Separate query. |

Each query is isolated. A failure leaves its fields unset; the line omits them. A class with no enabled fields is not queried. `WearPercent` enables `BatteryFullChargedCapacity`; `EquivCycles` enables `BatteryStatus`.

## Design capacity

Batcap does not query `BatteryStaticData`. Design capacity comes from `bin/.conf` because that class fails on some laptops. A wrong value skews `WearPercent` and `EquivCycles`; raw fields are unaffected.

## Log and state

The log is append-only. Timestamp is local time. Parse `key=value`. Log path is `..\logs\batcap.log` relative to the exe; keep `bin` and `logs` as siblings.

`bin/.cyclestate` stores `LastRemaining` and `Total`. `EquivCycles` is `Total / DesignCapacity`. `Total` grows when `Remaining` falls while not charging; drops larger than `DesignCapacity` are ignored. This is an estimate, not the firmware cycle count.

Writes use a temp file and `File.Replace`. Errors are appended as `ERROR ...` lines. The exe is a Windows GUI app, so it has no console window.

## Source tree

```
batcap/
├── src/
│   ├── config.cs             config parser and field toggles
│   ├── batteryReader.cs      WMI queries, one try/catch per class
│   └── program.cs            run flow, line builder, cycle state
├── bin/
│   ├── batcap.exe            compiled binary
│   ├── .conf                 design capacity and field toggles
│   └── .cyclestate           discharge total (auto-managed)
├── docs/
│   ├── usage.md
│   ├── config.md
│   ├── troubleshooting.md
│   ├── how-it-works.md
│   └── STORY.md
├── logs/
│   └── batcap.log            append-only log
├── .github/                  release workflow and notes template
├── LICENSE
├── .gitignore
├── build.ps1
└── README.md
```
