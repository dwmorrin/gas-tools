# gas-tools (work in progress)
Google Apps Script Command Line Tools

These are some bash shell scripts I'm using to help me make Google Apps Script projects.
I use Apps Script to make web apps with a lot of client-side JavaScript, and my current linting setup (vim + [ale](https://github.com/w0rp/ale) + eslint) doesn't work well with the GAS restriction of only .html files.
Could just be my workspace setup, but I wasn't getting good syntax highlighting or linting with the inline script files.

## installation
**Warning: This is a work in progress.  Please test before using.**

I have these scripts in my `~/bin`, and will run `degas` to edit files, and `regas` before commiting.

`install` will copy the contents of `tools` into `~/bin` without the .sh, .bash extensions and `chmod +x` them.
usage: `bash install`

Make a `.regasignore` file that points to the directory of your server-side .js files.  In my project, this is a `gs` directory.  If you do not have this file, you cannot run `regas` without an argument or your server-side code will get changed into .html files.

```
$ cat .regasignore
# using a '#' anywhere in the line makes it a comment
# this file tells `regas` to ignore the directory `gs`
gs
```

## usage
#### `degas [-iqr] [dir] [files...]`

`degas` is used to convert .html files to .js or .css.  It detects the file type by checking the first line for either a `<script>` tag or a `<style>` tag.  It will remove these tags and the matching closing tags.  *(Note: currenly just using `sed` to globally strip these tags - i.e. it's not "smart" in case you've got tags nested inside your file for some reason.)*

#### `regas [-iqr] [dir] [files...]`

`regas` is used to convert .js and .css files to .html by inserting the appropriate html tag into the first and last lines.  See note above on creating a `.regasignore` file to avoid turning server-side .js files into .html files.

##### `*egas` options
* -i will request confirmation for each file.
* -q suppresses output (todo: need to send error messages to standard error rather than standard output).
* -r will recursively walk (using `find`) from the current directory to apply the tool to multiple directories.
* `dir` - if the first argument is a directory, either command is invoked with an implicit `-r` option in `dir`.
* `files...` - targets only the specified `files`.

#### `clap`

`clap` is a wrapper for `clasp push` that you can call at any depth of your project unlike the bare command which requires you be in the project's root directory.
