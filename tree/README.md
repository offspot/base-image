pi-gen tree replacements
===

- All files from this tree (except this one) are to be copied verbatim into the cloned pi-gen.
- Files with `.patch` suffix **will not be copied** but applied as patches instead.

## Patch creation

```sh
diff -u path/to/original path/to/updated > tree/path/to/original.patch

# or, if working from a git copy of the original tree (I use tree-arm54.orig)
git diff --no-prefix path/to/original > ../tree/path/to/original.patch
```
