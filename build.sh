#!/bin/bash

# Install ccache
sudo apt install ccache


# Sync Everest sources and add local manifest
echo '==== Beginning sync ===='
rm -rf .repo/local_manifests
repo init -u https://github.com/ProjectEverest/manifest -b 14 --git-lfs
git clone https://github.com/SirEthanator/bluejay_local_manifest.git --depth 1 .repo/local_manifests
/opt/crave/resync.sh

echo '======================='
echo '==== Sync complete ===='
echo '======================='


# Signing
echo '==== Replacing make_key script ===='
rm -f development/tools/make_key
curl https://raw.githubusercontent.com/SirEthanator/development_tools_make_key/refs/heads/main/make_key > development/tools/make_key
chmod +x development/tools/make_key

echo '==== Beginning signing ===='
subject="/C=$COUNTRY/ST=$STATE/L=$CITY/O=$NAME/OU=$NAME/CN=$NAME/emailAddress=$EMAIL"
for x in releasekey platform shared media networkstack verity otakey testkey cyngn-priv-app sdk_sandbox bluetooth verifiedboot nfc; do
    ./development/tools/make_key vendor/lineage/signing/keys/$x "$subject"
done

echo '=========================='
echo '==== Signing complete ===='
echo '=========================='


# Build
echo '==== Starting build ===='
. build/envsetup.sh
lunch lineage_bluejay-user
mka everest

echo '========================'
echo '==== Build complete ===='
echo '========================'

