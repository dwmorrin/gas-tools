# gas-tools (work in progress)
Google Apps Script Command Line Tools

These are some shell scripts I'm using to help me make Google Apps Script projects with Vim, ALE, eslint, etc.
I make web apps with a lot of client-side JavaScript, and I've had a hard time with the GAS restriction of only .html files.
Could just be my workspace setup, but I wasn't getting good syntax highlighting or linting with the inline script files.

## Typical usage
I have these scripts in my `~/bin`, and will run `degas` to edit files, and `regas` before commiting.
**Warning: This is a work in progress.  Not debugged.  Can ruin your files!**

`install` will copy the contents of `tools` into `~/bin` without the .sh, .bash extensions and `chmod +x` them.
usage: `chmod +x install && ./install`

## Summary
- `removetags.bash`: uses sed to delete the specified tag
- `addtags.bash`: uses sed to insert the specified tag at the first and last lines
- `chext.bash`: swaps around file extensions, e.g. .html => .js or .js => .html
- `degas.bash`: wrapper for a combo of removetags and chext
- `regas.bash`: wrapper for a combo of addtags and chext
