#!/bin/sed -Ef

s/(.+) E (.+)/\x1b[31;1m\1 E | \2\x1b[0m/
s/(.+) W (.+)/\x1b[33;1m\1 W | \2\x1b[0m/

