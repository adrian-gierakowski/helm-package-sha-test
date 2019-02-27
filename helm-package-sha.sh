#!/usr/bin/env bash

CHART_NAME="${1:-samplechart}"
TEMP_DIR="${2:-tmp}"

set -euo pipefail
IFS=$'\n\t'

# On macOS we need to use gtar.
# If its not installed then exit with an error.
tar=tar

if [[ "$OSTYPE" == "darwin"* ]]
then
  if [ -x "$(command -v gtar)" ]
  then
    echo 'got gtar'
    tar=gtar
  else
    (>&2 echo "ERROR: on darwin based system gtar is required. You can install it with 'brew install gnu-tar' and try again.")
    exit 1
  fi
fi

echo "CHART_NAME: $CHART_NAME"

helm_package_output=$(helm package $CHART_NAME)

# Get package path from `helm package` output.
prefix='Successfully packaged chart and saved it to: '
package_file_path=$(echo $helm_package_output | sed -e "s/^${prefix}//")

echo "${prefix}${package_file_path}"

# Remove and recreate the temporary directory.
rm -fr $TEMP_DIR
mkdir -p $TEMP_DIR

# # Unpack the package archive.
tar zxvf $package_file_path -C $TEMP_DIR > /dev/null 2>&1

# 1. Produce a deterministic tar archive (uncompressed) use commands based on: https://stackoverflow.com/a/54908072
# 2. Pipe it to shasum
# 3. shasum outputs a string containing the sha and file name (or - in case of
#    input was piped to it), separated by spaces, so we use 'cut' to split on
#    spaces and take first element.

PACKAGE_SHA256=$($tar --sort=name --owner=root:0 --group=root:0 \
  --mtime='UTC 2019-01-01' --exclude .DS_Store \
  -c $TEMP_DIR \
  | shasum -a 256 \
  | cut -d ' ' -f 1)

# Remove the temporary directory.
rm -rf $TEMP_DIR

echo "PACKAGE_SHA256:"
echo "$PACKAGE_SHA256"
