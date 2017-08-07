#!/bin/bash

for file in `git status -s | awk '{print $2}' | grep '\.lua'`;
do
	luacheck ${file}
done
