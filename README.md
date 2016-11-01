# coreutils-echox
customized by echo(from GNU coreutils)

# usage
add use stdin option(-) from echo

```shell
$ echo -n Hello | echox - World
Hello World

$ echo -n Hello | echox World -
World Hello

$ echo abc | echox - def
abc
def

$ echo abc | echox def - ghi
def abc
ghi
```

# About repository
this repository forked from [GNU coreutils](https://ftp.gnu.org/gnu/coreutils/) - [coreutils-8.25.tar.xz](https://ftp.gnu.org/gnu/coreutils/coreutils-8.25.tar.xz)

# LICENSE

GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
