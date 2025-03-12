#!/system/bin/sh
# Copyright 2023-2024, shadow3 (@shadow3aaa)
#
# This file is part of fas-rs.
#
# fas-rs is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# fas-rs is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along
# with fas-rs. If not, see <https://www.gnu.org/licenses/>.

MODDIR=${0%/*}
DIR=/data/adb/fas-rs
INSTALLED=$DIR/fas-rs-mod-installed
MERGE_FLAG=$DIR/.need_merge
VTOOLSDIR=/data/data/com.omarea.vtools/files
PATCH_COMPLETE=$VTOOLSDIR/_FASRS.json
LOG=$DIR/log.txt
LOG_OFF=$(grep '^disable_log=' "$MODDIR/module.prop" | cut -d '=' -f2)
DEBUG=$(grep '^debug=' "$MODDIR/module.prop" | cut -d '=' -f2)
MANAGER=$(grep '^mod_fas_rs_ui_manager_support=' "$MODDIR/module.prop" | cut -d '=' -f2)
REUBEN=$(grep '^mod_show_reuben_in_scene=' "$MODDIR/module.prop" | cut -d '=' -f2)
FALLBACK=$(grep '^mod_fallback_standard_extensions_support=' "$MODDIR/module.prop" | cut -d '=' -f2)

until [ -d $DIR ]; do
	sleep 1
done

if [ -f $MERGE_FLAG ]; then
	$MODDIR/fas-rs merge $MODDIR/games.toml >$DIR/.update_games.toml
	rm $MERGE_FLAG
	mv $DIR/.update_games.toml $DIR/games.toml
fi

if [ ! -f $INSTALLED ]; then
	touch $INSTALLED
fi

until [ -d $VTOOLSDIR ]; do
	sleep 1
done

if [ "$MANAGER" = "1" ]; then
    sh $MODDIR/vtools/init_vtools.sh $(realpath $MODDIR/module.prop)
else
    rm -f /data/fas_rs_mod*
fi

sh $MODDIR/vtools/scene-patcher.sh

until [ -f $PATCH_COMPLETE ]; do
	sleep 1
done

killall fas-rs

if [ "$REUBEN" = "1" ]; then
    mkdir -p /dev/fas_rs/
    touch /dev/fas_rs/mode
elif [ "$REUBEN" = "0" ]; then
    rm -rf /dev/fas_rs/
fi

if [ "$FALLBACK" = "1" ]; then
    resetprop fas-rs-installed true
    rm -f $INSTALLED
elif [ "$FALLBACK" = "0" ] && [ ! -f $INSTALLED ]; then
	touch $INSTALLED
fi

if [ "$DEBUG" = "1" ]; then
	RUST_BACKTRACE=full nohup $MODDIR/debug/fas-rs run $MODDIR/games.toml >$LOG 2>&1 &
elif [ "$LOG_OFF" = "1" ]; then
	rm -f $LOG
	nohup $MODDIR/fas-rs run $MODDIR/games.toml > /dev/null 2>&1 &
else
	RUST_BACKTRACE=1 nohup $MODDIR/fas-rs run $MODDIR/games.toml >$LOG 2>&1 &
fi