#!/usr/bin/env bash

expected_sha="ae1b797a19d393f781aedaefdd2140919ad4274885171eabdefd39fad6ec714c"
sha=$(./helm-package-sha.sh | tail -1)

if [ "$sha" = "$expected_sha" ]
then
  echo "OK"
else
  echo "FAIL: ${sha} != ${expected_sha}"
fi
