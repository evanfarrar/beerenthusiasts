#!/bin/sh
cd `dirname $0`

echo Starting Nitrogen.
erl \
	-name nitrogen@localhost \
	-pa ../ebin -pa ../include/ \
	-s make all \
	-eval "db_inits:couchdb_init()" \
	-s erlang halt
