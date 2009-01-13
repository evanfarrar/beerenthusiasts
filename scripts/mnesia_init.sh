#!/bin/sh
cd `dirname $0`

echo Starting Nitrogen.
erl \
	-name nitrogen@localhost \
	-mnesia dir '"'$MNESIADB_DIR'"' \
	-pa ../ebin -pa ../include/ \
	-s make all \
	-eval "db_inits:mnesia_init()" \
	-s erlang halt
