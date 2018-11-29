#!/bin/bash
# Do not run this directly. Instead run "npm run build"

set -e

rm -rf build
mkdir -p build
cp -r client/ common/ server/ build/
tstl -p tsconfig.json
find build/ -name "*.ts" -delete
