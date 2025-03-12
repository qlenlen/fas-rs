MODDIR=${0%/*}

am start -n com.omarea.vtools/.activities.ActivityMain > /dev/null 2>&1
sh $MODDIR/vtools/scene-patcher.sh
am start -n com.omarea.vtools/.activities.ActivityMain > /dev/null 2>&1