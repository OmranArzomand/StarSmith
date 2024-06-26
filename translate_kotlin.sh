#!/bin/bash

set -e
LC_NUMERIC="C.UTF-8"

COLOR_YELLOW="\033[1;33m"
COLOR_BLUE="\033[1;36m"
COLOR_NONE="\033[0m"

function print_step {
  printf "${COLOR_YELLOW}======[ ${1} ]======${COLOR_NONE}\n"
}

compile_args=$@

out_dirs=('kotlin')


# == TRANSLATE RUNTIME CLASSES
print_step "translate runtime classes"
for i in $(echo ${!out_dirs[@]} | tr ' ' '\n' | sort -u | tr '\n' ' ') ; do
  out_dir="out/${out_dirs[$i]}"
  pushd "$out_dir/runtime" > /dev/null ; ./compile_all.sh ; popd > /dev/null
done


# == TRANSLATE SPECIFICATIONS
print_step "translate specifications"

translate_spec() { # <spec file> <out dir> <java file> <max depth> <feature option>
  spec_file="specs/$1"
  out_dir="out/$2"
  java_file="$out_dir/$3"
  max_depth="$4"
  feature_option="$5"

  echo "- $spec_file => $java_file"

  ./translate_spec.sh --spec "$spec_file" --maxDepth "$max_depth" $feature_option --toJava "$java_file" $compile_args
  pushd "$out_dir" > /dev/null ; ./compile.sh "$(basename $java_file)" ; popd > /dev/null
}

translate_spec "kotlin.ls"              "kotlin/"          "kotlin.java"                    11 --allFeatures

