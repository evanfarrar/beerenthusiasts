#!/bin/bash

cd `dirname $0`

#-mnesia dir '"'$MNESIADB_DIR'"' \

echo Creating link to nitrogen support files...
rm -rf wwwroot/nitrogen
ln -s $NITROGEN_SRC/www wwwroot/nitrogen

echo Starting Nitrogen on Inets...
erl \
  -name nitrogen@127.0.0.1 \
  -pa $PWD/apps $PWD/ebin $PWD/include \
  -pa $NITROGEN_SRC/ebin $NITROGEN_SRC/include \
  -s make all \
  -eval "application:start(beerenthusiasts)"

