#!/bin/zsh

# If the file exists remove it and then make a new one
# [[ -s "./rspec_errors.txt" ]] && rm rspec_errors.txt
# touch rspec_errors.txt

for f in $(find ./spec -name '*.rb')
do
  bundle exec rspec $f
  exit_code=$?
  if [ $exit_code -ne 0 ]
  then
    echo "This file failed $f"
    echo "Exit Code: $exit_code"
    exit 1
  fi
done
