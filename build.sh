#!/bin/bash

# Install ccache
sudo apt update; sudo apt install -y ccache


# Sync Everest sources and add local manifest
echo '==== Beginning sync ===='
rm -rf .repo/local_manifests
repo init -u https://github.com/ProjectEverest/manifest -b 14 --git-lfs
git clone https://github.com/SirEthanator/bluejay_local_manifest.git --depth 1 .repo/local_manifests
/opt/crave/resync.sh

sed -i "s/.*WITH_GAPPS.*/WITH_GAPPS := true/" device/google/bluejay/lineage_bluejay.mk

buildType=$(echo "$1" | tr '[:upper:]' '[:lower:]')
if [[ $buildType == 'vanilla' ]]; then
  sed -i "s/.*WITH_GAPPS.*/WITH_GAPPS := false/" device/google/bluejay/lineage_bluejay.mk
  echo 'Build type: Vanilla'
elif [[ $buildType != 'gapps' ]]; then
  echo 'Buildtype not specified. Defaulting to GAPPS.'
else
  echo 'Build type: GAPPS'
fi

echo '======================='
echo '==== Sync complete ===='
echo '======================='


# Build
echo '==== Starting build ===='
. build/envsetup.sh
lunch lineage_bluejay-user
mka everest
exitStatus=$?

echo '========================'
echo '==== Build complete ===='
echo '========================'
echo ''
echo "Exit status: $exitStatus"
exit $exitStatus

