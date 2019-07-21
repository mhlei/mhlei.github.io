#!/bin/bash

cmd_dir=`dirname ${0}`
curr_dir=`cd $cmd_dir && pwd`
dirname=${curr_dir##*/}
echo "##$dirname\n"
for f in `ls`
do
  if [ "$f" != "mk.sh" ] && [ "$f" != "index.md" ]; then
    echo "[$f](./$f)|";
  fi
done

