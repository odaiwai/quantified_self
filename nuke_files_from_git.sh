#!/bin/bash

# script to nuke a file from the repo.
git filter-branch --index-filter 'git rm -rf --cached --ignore-unmatch apple_health_export/' --prune-empty --tag-name-filter cat -- --all
git filter-branch --index-filter 'git rm -rf --cached --ignore-unmatch fitbit_data/' --prune-empty --tag-name-filter cat -- --all
git filter-branch --index-filter 'git rm -rf --cached --ignore-unmatch myFitnessPal_data/' --prune-empty --tag-name-filter cat -- --all
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d
