# Troubleshooting

## No new line

Run and check the exit code:

```
$p = Start-Process .\bin\batcap.exe -Wait -PassThru
$p.ExitCode
```

`0` means the line was written. `1` means an error; check the `ERROR` line in `logs/batcap.log`.

Log path is `..\logs\batcap.log` relative to the exe. Keep `bin` and `logs` as siblings.

## ERROR every enabled WMI query returned no data

Can mean one enabled source is missing. Test:

```
Get-WmiObject -Namespace root\WMI -Class BatteryFullChargedCapacity
Get-WmiObject -Namespace root\WMI -Class BatteryStatus
Get-WmiObject -Namespace root\cimv2 -Class Win32_Battery
```

If a class returns nothing, disable its fields:

- `BatteryFullChargedCapacity`: `Full`, `WearPercent`.
- `BatteryStatus`: `Remaining`, `Voltage`, `ChargeRate`, `DischargeRate`, `Charging`, `PowerOnline`, `Critical`, `EquivCycles`.
- `Win32_Battery`: `Chemistry`, `EstimatedChargeRemaining`.

Batcap has no fallback for `Full` or `Remaining`. A fully drained battery can also fail because `Remaining=0` is treated as no data.

## ERROR another instance is running

Another run holds `Local\batcap`. Wait up to 10 seconds.

## WearPercent missing or negative

Missing when disabled, `Full` unavailable, or `DesignCapacity` is not greater than zero. Negative when `Full` is above `Design`; check both values.

## EquivCycles wrong or resets

Estimate from sampled discharge, not firmware cycles. Deleting `bin/.cyclestate` resets it. Changing `DesignCapacity` changes the result. Run more often for finer data.

## DesignCapacity unknown

Check `powercfg /batteryreport`, the battery label, or the service manual. If unknown, leave the computed fields off.

## Task Scheduler runs but nothing happens

- Check Last Run Result: `0` success, `1` failure.
- Action must point to `bin\batcap.exe`.
- Clear the AC-power conditions in Conditions.
- Test WMI under the task account.
- A sleeping laptop cannot sample.
- No window is expected.

## Log grows forever

No retention. Archive or delete `logs/batcap.log`. The state file is separate.

## Data looks stale

WMI counters can update slowly or coarsely. A run is a sample.
