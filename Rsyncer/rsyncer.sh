#!/usr/bin/env zsh
integer i
local args wherefrom whereto argvs x first all cmd usage
args=-vurltODc
#drop the c to make it use size + timestamp - use c if you need to ignore timestamp"
wherefrom=$1
whereto=$2
usage="USAGE: $0 <where from?> <where to?> [which file/directories in <where from?>]"
if [ -z $wherefrom ]
  then echo $usage && exit -1
fi
if [ -z $whereto ]
  then echo $usage && exit -1
fi
if [ ! -x $wherefrom ]
  then echo $usage "\n(BECAUSE $wherefrom is not accessible)" && exit -1
fi
if [ ! -x $whereto ]
  then echo $usage "\n(BECAUSE $whereto is not accessible)" && exit -1
fi
argvs=()
i=1
for x in $*; do
  argvs[$i]="$x"
  (( i++ ))
done  
first=$3
if [ -n "${3+x}" ]; then
  all=(${argvs[3,-1]})
else
  echo Moving all files in "'$wherefrom'"
  saveIFS=$IFS; IFS=$'\n' all=($(cd "$wherefrom" && ls -1))
fi
echo "About to transfer these files/folders:"
print -l $all
echo "... From this source folder:    '$wherefrom'"
echo "... To this destination folder: '$whereto'"
echo "... Using these args: [$args]"
echo "    * If args contain 'c' then size+timestamp is used to identify changes, and it is fast."
echo "    * With no 'c', SLOW but if you have somehow botched the timestamps on the source "
echo "      (e.g. if you did a simple cp -R into the source) you will need to omit the 'c'"
echo ""
echo "Type 'y' to proceed"
read resp
if [[ "$resp" != "y" ]]; then exit -1; fi

for x in $all ; do
  echo "@@@@@@@@@@@ '$wherefrom/$x' => '$whereto/$x' ..."
  if [ -d $x ]; then
    mkdir -p "$whereto/$x/" && rsync $args "$wherefrom/$x/" "$whereto/$x" 
  else
    rsync $args "$wherefrom/$x" "$whereto"
  fi
done
