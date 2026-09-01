# Repository instructions

## Publishing accepted changes

- Keep the default `master` bookmark synchronized with its Git remote.
- When a change is tested and the user accepts it, create a Jujutsu checkpoint with a Conventional Commit description, move `master` to that checkpoint, and push it.
- Publish accepted work incrementally instead of leaving it only in the working copy.
- Treat pushed history as append-only. After every push, run `jj new` before making more changes, and publish later updates as new descendant commits.
