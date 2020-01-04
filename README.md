# gas-tools (deprecated)

This is a small collection of scripts to modify files within a Google Apps Script
project.  It was a hack to get syntax highlighting to work... but then I finally
realized how to do it the right way by adding just a couple of lines to my .vimrc!

While I no longer use these scripts, they are still instructive if you want a shell
script to examine directories and text files.  These scripts were looking for HTML
files with inline Javascript.  One script would find the appropriate files and
change the extension to get syntax highlighting to work (not the right way to do 
it, btw) and the complementary script would put the regular extensions back.

## installation

I have these scripts in my `~/bin`, and will run `degas` to edit files, and `regas` before commiting.

`install` will copy the contents of `tools` into `~/bin` without the .sh, .bash extensions and `chmod +x` them.
usage: `bash install`

You can make a `.regasignore` file that points to the directory of your server-side .js files.  In my project, this is a `gs` directory.  Then you can run `regas` without arguments.  If you do not have this file, `regas` will offer to work on any subdirectories of the working directory, or exit if there are no subdirectories (in that case, you must specify `regas [files...]` to use the program).
```
$ cat .regasignore
# using a '#' anywhere in the line makes it a comment
# this file tells `regas` to ignore the directory `gs`
gs
```

## usage
#### `degas [-iqr] [dir] [files...]`

`degas` is used to convert .html files to .js or .css.  It detects the file type by checking the first not blank line for either a `<script>` tag or a `<style>` tag.  It will remove any lines that begin with that tag (ignoring leading whitespace). _Be careful if you happen to have such tags embedded in your file (e.g. within a template literal)._

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
