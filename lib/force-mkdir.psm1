# Thanks to raydric, this function should be used instead of `mkdir -force`.
#
# While `mkdir -force` works fine when dealing with regular folders, it behaves
# strange when using it at registry level. If the target registry key is
# already present, all values within that key are purged.
function force-mkdir($path) {

    # The PS-Drive mapping does not progress
    New-PSDrive HKU Registry HKEY_USERS | Out-Null

    if (!(Test-Path $path)) {
        #Silently creates the new Hive in the registry
        New-Item -ItemType Directory -Force -Path $path | Out-Null
    }
}
