# Disabled upstream workflows

This fork keeps upstream GitHub Actions workflows here for reference, but they
are intentionally outside `.github/workflows/` so GitHub will not run them.

The upstream workflows are designed for the canonical repository's release and
CI infrastructure, including signing secrets, self-hosted macOS runners, Xbox
UWP packaging, iOS release packaging, and full GitHub Release publishing.

For this zh-CN fork, the active workflow is:

- `.github/workflows/build-gen1tls.yml` — manually builds `gen1tls.dll` on a
  GitHub-hosted `windows-2022` runner and uploads it as an artifact.
