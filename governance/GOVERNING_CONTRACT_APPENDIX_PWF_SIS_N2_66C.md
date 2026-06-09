# Governing Contract Appendix — PWF-SIS N2.66C

## Script safety rule
PowerShell scripts must be ASCII-only unless non-ASCII content is encoded or applied through a source overlay.

## Variable interpolation rule
Do not place `:` immediately after a PowerShell variable name inside a double-quoted string. Use `-f` formatting or `${var}`.

## Closure rule
Analyzer clean after a failed script does not close the batch. The intended script must apply successfully first.
