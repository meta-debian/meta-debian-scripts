#!/bin/bash

USER=ystk
OUTPUTFILE="src-deby_all.txt"

function abort
{
	echo "ERROR: $@" 1>&2
	exit 1
}

# Get the last page number.
LASTPAGE=`curl -I "https://api.github.com/users/"$USER"/repos?per_page=100" 2> /dev/null \
			| grep "rel=\"last\"" | cut -d";" -f2 | cut -d"=" -f4 | cut -d">" -f1`
[ -z $LASTPAGE ] && abort "Cannot get the last page number from github."
LASTPAGE=`expr $LASTPAGE + 1`

if [ -f $OUTPUTFILE ]; then
	rm $OUTPUTFILE
fi

# Get all name of "debian-*" repository and write output files.
for ((i=1; i<$LASTPAGE; i++));
do
	curl "https://api.github.com/users/"$USER"/repos?page="$i"&per_page=100" 2> /dev/null \
		| jq '[.[] .name]' | grep -e "\"debian-" -e "\"gnu-config" -e "\"pseudo" \
		-e "\"qemu" -e "\"linux-ltsi" -e "\"linux-cip" | cut -d"\"" -f2 >> $OUTPUTFILE;
done
sed -e 's/^/ystk\//g' -i $OUTPUTFILE
