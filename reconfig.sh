#!/bin/bash
#

redis_cli='/usr/local/bin/redis-cli -a Beekeango8eph5Go8Uquahng2iegh7owe0eighieraeKeud1ZievouG9ohrahTh7'
$redis_cli -h $4 -p $5 config set save "900 1 300 10 60 10000"
$redis_cli -h $4 -p $5 config set appendonly "yes"
$redis_cli -h $4 -p $5 config rewrite

$redis_cli -h $6 -p $7 config set save ""
$redis_cli -h $6 -p $7 config set appendonly "no"
$redis_cli -h $6 -p $7 config rewrite
