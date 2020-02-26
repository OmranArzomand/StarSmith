#!/bin/bash

set -e

if [ $# -ne 2 ] ; then
  echo "USAGE: $0 <output directory> <sample size>"
  exit 1
fi

out_dir="$1"
mkdir -p "$out_dir"

sample_size="$2"

"$(dirname "$0")/../run.sh" paper_spec_generators --seed 0 --count "$sample_size" \
  --out "${out_dir}/batch_#{BATCH}/prog_#{SEED}.txt" \
  --batchSize 100000 \
  --stats "${out_dir}/stats.csv"
