#!/bin/bash

# Install ccache
sudo apt update; sudo apt install -y ccache


# Sync Everest sources and add local manifest
echo '==== Beginning sync ===='
rm -rf .repo/local_manifests
repo init -u https://github.com/ProjectEverest/manifest -b 14 --git-lfs
git clone https://github.com/SirEthanator/bluejay_local_manifest.git --depth 1 .repo/local_manifests
/opt/crave/resync.sh

echo '======================='
echo '==== Sync complete ===='
echo '======================='


# Build
echo '==== Starting build ===='
. build/envsetup.sh
lunch lineage_bluejay-user
mka everest

