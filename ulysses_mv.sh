#!/bin/bash
find . -name "index.md" | while read LINE; do mv -f "$LINE" "$(echo $LINE | sed 's/\/index.md$/.md/')"; done
