#!/nix/store/zj0vnpa0a1y4ym0g1i9rjyc4rdg9cc1z-system-path/bin/bash

me=`whoami`
me_name=`getent passwd ${me} | cut -d ':' -f 5 | cut -d ',' -f 1`
class=powermenu

echo -e "{\"text\":\""$me_name"\", \"class\":\""$class"\"}"
