# Sync Everest sources and add local manifest
rm -rf .repo/local_manifests
repo init -u https://github.com/ProjectEverest/manifest -b 14 --git-lfs
git clone https://github.com/SirEthanator/bluejay_local_manifest.git --depth 1 .repo/local_manifests
/opt/crave/resync.sh

echo '======================='
echo '==== Sync complete ===='
echo '======================='

# Signing
subject="/C=$COUNTRY/ST=$STATE/L=$CITY/O=$NAME/OU=$NAME/CN=$NAME/emailAddress=$EMAIL"
for x in releasekey platform shared media networkstack verity otakey testkey cyngn-priv-app sdk_sandbox bluetooth verifiedboot nfc; do
    ./development/tools/make_key vendor/lineage/signing/keys/$x "$subject"
done

echo '=========================='
echo '==== Signing complete ===='
echo '=========================='

# Build
echo 'Starting build'
. build/envsetup.sh
lunch lineage_bluejay-user
mka everest

