#!/bin/bash

# SYNTAX: build.sh build-type manifest-url manifest-branch local-manifest-branch target build-command

# ==== Set variables ==== #
if [[ "$1" ]]; then
  buildType=$(echo "$1" | tr '[:upper:]' '[:lower:]')
else
  buildType='gapps'
  echo 'No build type specified: Using default'
fi

if [[ "$2" ]]; then
  manifest="$2"
else
  manifest='https://github.com/ProjectEverest/manifest.git'
  echo 'No manifest specified: Using default'
fi

if [[ "$3" ]]; then
  branch="$3"
else
  branch='14'
  echo 'Branch not specified: Using default'
fi

if [[ "$4" ]]; then
  localManifest="$4"
else
  localManifest='everest'
  echo 'Local manifest branch not specified: Using default'
fi

if [[ "$5" ]]; then
  target="$5"
else
  target="lineage_bluejay-user"
  echo 'No target specified: Using default'
fi

if [[ "$6" ]]; then
  buildCmd="$6"
else
  buildCmd='mka everest'
  echo 'No build command specified: Using default'
fi

echo -ne '\n'

echo "Build type: $buildType"
echo "Manifest: $manifest"
echo "Branch: $branch"
echo "Local manifest branch: $localManifest"
echo "Target: $target"
echo "Build command: $buildCmd"


# ==== Sync sources and add local manifest ==== #
echo -ne '\n\n\n'
echo '===================================='
echo '========== Beginning sync =========='
echo '===================================='
echo -ne '\n\n\n'

rm -rf .repo/local_manifests
rm -rf device/google/bluejay
rm -rf device/google/bluejay-kernel
rm -rf device/google/bluejay-sepolicy
rm -rf device/google/gs101
rm -rf device/google/gs101-sepolicy
rm -rf device/google/gs-common
repo init -u "$manifest" -b "$branch" --git-lfs
git clone https://github.com/SirEthanator/bluejay_local_manifest.git -b "$localManifest" --depth 1 .repo/local_manifests
/opt/crave/resync.sh

echo -ne '\n\n\n'
echo '==================================='
echo '========== Sync complete =========='
echo '==================================='
echo -ne '\n\n\n'


# ==== Build ==== #
echo -ne '\n\n\n'
echo '==================================='
echo '========== Starting build ========='
echo '==================================='
echo -ne '\n'

# Build type selection
if [[ ! $buildType == 'unset' ]]; then
  sed -i "s/.*WITH_GAPPS.*/WITH_GAPPS := true/" device/google/bluejay/lineage_bluejay.mk

  if [[ $buildType == 'vanilla' ]]; then
    sed -i "s/.*WITH_GAPPS.*/WITH_GAPPS := false/" device/google/bluejay/lineage_bluejay.mk
  fi
fi
echo -ne '\n\n\n'

. build/envsetup.sh
if [[ ! $target == 'nolunch' ]]; then lunch "$target"; fi
eval "$buildCmd"
exitStatus=$?

echo -ne '\n\n\n'
echo '===================================='
echo '========== Build complete =========='
echo '===================================='
echo -ne '\n'
echo "Exit status: $exitStatus"
exit $exitStatus

