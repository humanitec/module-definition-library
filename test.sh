#!/usr/bin/env bash

set -eux

export TF_PLUGIN_CACHE_DIR=$(mktemp -d)
for f in $(find . -name .terraform); do rm -r ${f}; done
for f in $(find . -name .terraform.lock.hcl); do rm -r ${f}; done
for f in `find . -name main.tf`; do pushd .; cd $(dirname $f); tofu init; tofu validate; popd; done
