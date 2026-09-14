# Review guidance for this repository

This repository follows the runedeck review ceremony: model-authored
commits, owner-authored pull requests, multiple review lanes, and
owner-signed release tags attesting the merged history.

Suppressions, learned from past rounds:

- Pagination on deliberately bounded sets (a repo's own workflows, a
  manifest's file list) is not a finding; flag pagination only where the set
  genuinely grows without bound.
- Do not re-report a finding another reviewer already posted on this pull
  request, and do not re-report a finding already addressed by a later
  commit; check the commit history first.
- Severity floor: report medium and above inline; fold nits into one
  comment.
- `language: system` prek hooks assume the tool is installed by INSTALL.md
  or CI; a missing-binary scenario is a finding only when no install path
  documents the tool.
