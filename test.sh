#!/usr/bin/env bash

set -eux

export TF_PLUGIN_CACHE_DIR=$(mktemp -d)
find . -name .terraform | xargs rm -r
find . -name .terraform.lock.hcl | xargs rm -v
for f in `find . -name main.tf`; do pushd .; cd $(dirname $f); tofu init; tofu validate; popd; done
