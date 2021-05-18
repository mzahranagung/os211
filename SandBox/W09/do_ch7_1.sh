#!/bin/bash
# REV02 Sun 16 May 11:40:33 WIB 2021
# REV01 Sat 15 May 22:25:26 WIB 2021
# START Fri 14 May 14:29:10 WIB 2021

CHAPTER="07_1"
WEEK="09"
FILE="WEEK$WEEK-REPORT-CH$CHAPTER.txt"

WEEKDIR="$HOME/RESULT/W$WEEK/"
# WEEKDIR="$HOME/git/os211quiz/SandBox/W$WEEK/W$WEEK/"

LFSDIR="/mnt/lfs"
INPUTTOKEN="$(whoami)W$WEEK"

byebye()    { echo $1; exit -1; }
chktokenn() {
    STAMP=$(date +%M%S)
    echo "$(whoami) $STAMP-$(echo $STAMP$(whoami)$1 | sha1sum  | cut -c1-4 | tr '[:lower:]' '[:upper:]' )"
}
okSources() {
    pushd $LFSDIR/sources/                         2>&1 > /dev/null
    md5sum -c md5sums | grep OK | wc -l
    popd                                           2>&1 > /dev/null
}
verifyTokenn() {
    DATE="$(echo $3 | cut -d' ' -f2 | cut -d'-' -f1)"
    SHA="$(echo  $3 | cut -d' ' -f2 | cut -d'-' -f2 )"
    RESULT="$(echo $DATE$2$1 | sha1sum  | cut -c1-4 | tr '[:lower:]' '[:upper:]' )"
    [ $SHA == $RESULT ] && echo "Verified"  || echo "Error"
}
fecho(){
    echo "ZCZC $1" | tee -a $FILE
}

mkdir -pv $WEEKDIR
[ -d $WEEKDIR ] && cd $WEEKDIR || byebye "Error: No $WEEKDIR"
[ -d $LFSDIR ]                 || byebye "Error: No $LFSDIR"
[ -d $LFSDIR/sources/ ]        || byebye "Error: No $LFSDIR/sources/"
[ -f $LFSDIR/sources/md5sums ] || byebye "Error: No $LFSDIR/sources/md5sums"
rm -f $FILE
fecho "===== Chapter $CHAPTER =====  Week $WEEK ====="
fecho "pwd $(pwd)"
fecho "date $(date +%y%m%d-%H%M)"
fecho "hostname $(hostname)"
fecho "username $(whoami)"
fecho "Please Wait..."
fecho "okSources $(okSources)"
fecho "READY!"
fecho "Sources  $(du -h $LFSDIR/sources/)"

MaxLFS=0
MaxROOT=0
MaxMemory=0
MaxSwap="-1"
EXTRAS=60
while true ; do
    TOKEN=$(chktokenn $INPUTTOKEN)
    VERIFY=$(verifyTokenn $INPUTTOKEN $TOKEN)
    fecho "verifyTokenn $INPUTTOKEN $TOKEN $VERIFY"
    LOOP=10
    while (( LOOP-- )) ; do
        TMP1=$(($(df|awk '/ \/mnt\/lfs$/ {print $3}')/1024))
        (( "$MaxLFS" < "$TMP1" )) && { MaxLFS=$TMP1; fecho "MaxLFS ${MaxLFS}M" ; }
        TMP1=$(($(df|awk '/ \/$/ {print $3}')/1024))
        (( "$MaxROOT" < "$TMP1" )) && { MaxROOT=$TMP1; fecho "MaxROOT ${MaxROOT}M" ; }
        TMP1=$(($(free|awk '/Mem:/ {print $3}')/1024))
        (( "$MaxMemory" < "$TMP1" )) && { MaxMemory=$TMP1; fecho "MaxMemory ${MaxMemory}M" ; }
        TMP1=$(($(free|awk '/Swap:/ {print $3}')/1024))
        (( "$MaxSwap" < "$TMP1" )) && { MaxSwap=$TMP1; fecho "MaxSwap ${MaxSwap}M" ; }
        sleep 6
    done
    sleep $((1+(++EXTRAS/60)))
    (( "$EXTRAS" > "60" )) && EXTRAS=0
done
exit

