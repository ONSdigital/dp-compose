# make prep

Running `make prep` iterates over the repos for the given stack.

If it finds a directory (within this directory) named after the repo
(e.g., `v2/init/zebedee/` if the `zebedee` repo is in the current stack)
then it will look in that directory for:

- `*.patch` files to apply to the code in the repo
- `*.sh` files to run from the root of the repo

For example, if the patch file

- `v2/init/zebedee/changes.patch`

exists, then this will be applied (using `patch`) from the root of

- `$DP_REPO_DIR/zebedee`
