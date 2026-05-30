# Course log

Running log of the external CKAD course: what was studied, which catalog building block / lab it maps to, and which coverage-matrix cell(s) it advances.

Keep copyrighted course content OUT of git (use `tmp/`). This log only records
*pointers* and *my own* notes.

| Date | Course section | Topic(s) | Maps to | Coverage cell(s) | Tracking issue |
| --- | --- | --- | --- | --- | --- |
| _yyyy-mm-dd_ | _e.g. Module 3_ | _e.g. probes_ | `building-blocks/observability/probes.yaml` | Domain 3: liveness/readiness/startup | #NNN |

## Workflow per course task

1. Study the section; note the topic(s).
2. Create a small `[TASK]` issue on `pkuppens/pkuppens` labelled `ckad`, stating which coverage cell(s) it covers.
3. Implement the building block / lab here on the kind cluster.
4. Tick the cell in `docs/coverage-matrix.md` and EPIC #109; add a row above.
