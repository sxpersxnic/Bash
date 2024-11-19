#!/usr/bin/bash

target="xy"

echo "Target: ${target}"

gh repo create xy-example --private
gh repo create xy-blabla --private
gh repo create x-blabla --private

echo "Test init done"