# Configuration

`bin/.conf` sits next to `bin/batcap.exe`. Plain text, one `Key=Value` per line. Keys are case-insensitive. Booleans accept `true`, `false`, `1`, `0`. `#` and `;` start comments. Missing file uses defaults.

## DesignCapacity

Battery design capacity in mWh. Not read from WMI. The default `44021` is the author's EliteBook 840 G2 value. Replace it.

Find it in `powercfg /batteryreport`, the battery label, or the laptop's service manual. If you cannot find it, leave `WearPercent` and `EquivCycles` off.

## Keys

Each flag toggles a field. Disabled fields are omitted. A WMI class with no enabled fields is not queried unless a computed field needs it.

| Key | Type | Default | Description |
|---|---|---|---|
| `DesignCapacity` | int (mWh) | `44021` | Design capacity from config. |
| `Design` | bool | `true` | Include `Design=`. |
| `Full` | bool | `true` | Include `Full=` from `BatteryFullChargedCapacity`. |
| `Remaining` | bool | `true` | Include `Remaining=` from `BatteryStatus`. |
| `Voltage` | bool | `true` | Include `Voltage=`. |
| `ChargeRate` | bool | `true` | Include `ChargeRate=`. |
| `DischargeRate` | bool | `true` | Include `DischargeRate=`. |
| `Charging` | bool | `true` | Include `Charging=`. |
| `PowerOnline` | bool | `false` | Include `PowerOnline=`. Adds no query. |
| `Critical` | bool | `false` | Include `Critical=`. Adds no query. |
| `Chemistry` | bool | `false` | Include `Chemistry=` from `Win32_Battery`. |
| `EstimatedChargeRemaining` | bool | `false` | Include `EstimatedChargeRemaining=` from `Win32_Battery`. |
| `WearPercent` | bool | `false` | Include computed `(DesignCapacity - Full) / DesignCapacity * 100`. |
| `EquivCycles` | bool | `false` | Include running discharge total / `DesignCapacity`. |

## State

`bin/.cyclestate` stores `LastRemaining` and `Total` (discharged mWh). It updates whenever `Remaining` and `Charging` are read, even if `EquivCycles` is off. Deleting it resets the cycle total.

Changing `DesignCapacity` changes the displayed `EquivCycles`; the stored total is not rescaled.

## Example

```
DesignCapacity=44021
WearPercent=true
EquivCycles=true
```

This keeps the default fields and adds the two computed health fields.

## Not supported

- Cycle count and battery temperature. Batcap does not read them.
- `BatteryStaticData` fields. Batcap does not query that class; design capacity comes from config.
