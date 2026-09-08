# Gen1RecompCN agent notes

## Packaging defaults

When the user asks to package/build the main project without narrowing the target list, default to building all of these targets:

- Windows
- macOS
- 34xx
- Android
- Switch

Switch packaging should produce only one zip package by default, and it should use the fused package variant unless the user asks otherwise.

Do not split packaged outputs into per-platform directories. Put all artifacts for the same project version together under one versioned output folder.

All packaged artifacts should keep the project version visible in filenames and/or output labels, aligned with the main project version instead of placeholder values such as `0.0.0 dev`.
