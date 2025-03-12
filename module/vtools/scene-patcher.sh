PATCHDIR=${0%/*}
MODDIR=$(dirname $PATCHDIR)
VTOOLSDIR=/data/data/com.omarea.vtools/files
alias jq=$PATCHDIR/jq
scene_daemon=`pgrep -f "scene-daemon"`
patch=$(sed -n '1p' "$PATCHDIR/patch")
fas_rs_version=$(grep '^version=' "$MODDIR/module.prop" | cut -d '=' -f2)
fas_rs_codename=$(grep '^versionCodeName=' "$MODDIR/module.prop" | cut -d '=' -f2)
mod_version=$(grep '^mod_version=' "$MODDIR/module.prop" | cut -d '=' -f2)
mod_codename=$(grep '^mod_versionCodeName=' "$MODDIR/module.prop" | cut -d '=' -f2)
fas_rs_author=$(grep '^fas_rs_author=' "$MODDIR/module.prop" | cut -d '=' -f2)
fas_rs_mod_author=$(grep '^fas_rs_mod_author=' "$MODDIR/module.prop" | cut -d '=' -f2)
scene_version=$(jq -r '.version' $VTOOLSDIR/manifest.json)
scene_author=$(grep '^scene_author=' "$MODDIR/module.prop" | cut -d '=' -f2)
mod_exist=$(grep "fas_rs_mod" "$VTOOLSDIR/manifest.json")

if [ ! -n "$mod_exist" ]; then
    touch $PATCHDIR/tmp
    cp -f $PATCHDIR/_FASRS.json $VTOOLSDIR && chmod a+rwx $VTOOLSDIR/_FASRS.json
    sed -i '/games/,$d' $VTOOLSDIR/profile.json && echo $patch >> $VTOOLSDIR/profile.json
    jq '.alias.fas_rs = "/data/adb/fas-rs/mode"' $VTOOLSDIR/profile.json | jq '.schemes.powersave.game = []' | jq '.schemes.balance.game = []' | jq '.schemes.performance.game = []' | jq '.schemes.fast.game = []' | jq '.schemes.pedestal.game = []' > $PATCHDIR/tmp && cp -f $PATCHDIR/tmp $VTOOLSDIR/profile.json && chmod a+rwx $VTOOLSDIR/profile.json
    jq '.version = "\n🐶 - scene-patcher : _mod_version_ (_mod_codename_ / @_fas_rs_mod_author_)\n🐷 - (in-games) fas-rs : _fas_rs_version_ (_fas_rs_codename_ / @_fas_rs_author_)\n🛠 - (in-applications) scene :‭⁧(_scene_version_ / @_scene_author_) ⁧"' $VTOOLSDIR/manifest.json | jq '.features.pedestal = false' | jq '.features.fas = false' | jq '.features.fas_rs_mod = true' > $PATCHDIR/tmp
    cp -f $PATCHDIR/tmp $VTOOLSDIR/manifest.json
    sed -e "s/_fas_rs_version_/$fas_rs_version/" -e "s/_fas_rs_codename_/$fas_rs_codename/" -e "s/_mod_version_/$mod_version/" -e "s/_mod_codename_/$mod_codename/" -e "s/_fas_rs_mod_author_/$fas_rs_mod_author/" -e "s/_fas_rs_author_/$fas_rs_author/" -e "s/_scene_version_/$scene_version/" -e "s/_scene_author_/$scene_author/" $VTOOLSDIR/manifest.json > $PATCHDIR/tmp && cp -f $PATCHDIR/tmp $VTOOLSDIR/manifest.json && chmod a+rwx $VTOOLSDIR/manifest.json
    rm -rf $PATCHDIR/tmp
    kill -9 $scene_daemon 2>/dev/null
fi