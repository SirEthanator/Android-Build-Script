#!/bin/bash

# Install ccache and b2 cli
sudo apt update; sudo apt install -y ccache
sudo pip install 'b2[full]'


# Sync Everest sources and add local manifest
echo -ne '\n\n\n'
echo '===================================='
echo '========== Beginning sync =========='
echo '===================================='
echo -ne '\n\n\n'

rm -rf .repo/local_manifests
repo init -u https://github.com/ProjectEverest/manifest -b 14 --git-lfs
git clone https://github.com/SirEthanator/bluejay_local_manifest.git --depth 1 .repo/local_manifests
/opt/crave/resync.sh

echo -ne '\n\n\n'
echo '==================================='
echo '========== Sync complete =========='
echo '==================================='
echo -ne '\n\n\n'


# Build
echo -ne '\n\n\n'
echo '==================================='
echo '========== Starting build ========='
echo '==================================='
echo -ne '\n\n\n'

# Build type selection
sed -i "s/.*WITH_GAPPS.*/WITH_GAPPS := true/" device/google/bluejay/lineage_bluejay.mk

buildType=$(echo "$1" | tr '[:upper:]' '[:lower:]')
if [[ $buildType == 'vanilla' ]]; then
  sed -i "s/.*WITH_GAPPS.*/WITH_GAPPS := false/" device/google/bluejay/lineage_bluejay.mk
  echo 'Build type: Vanilla'
elif [[ $buildType != 'gapps' ]]; then
  echo 'Build type invalid or not specified. Defaulting to GAPPS.'
else
  echo 'Build type: GAPPS'
fi
echo -ne '\n'

. build/envsetup.sh
lunch lineage_bluejay-user
# mka everest
mka target-files-package
exitStatus=$?
if [[ $exitStatus -eq 0 ]]; then /opt/crave/crave_sign.sh; fi

echo -ne '\n\n\n'
echo '===================================='
echo '========== Build complete =========='
echo '===================================='
echo -ne '\n'
echo "Exit status: $exitStatus"
exit $exitStatus

