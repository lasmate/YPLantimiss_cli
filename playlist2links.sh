#!/bin/bash

if [ -z "$1" ];
then
	echo "Please, specify the playlist code as argument" 1>&2
	exit 1
fi
URL="https://www.youtube.com/playlist?list=$1"
YOUTUBE_VIDEO_URL_PREFIX="https:\/\/youtube.com\/watch?v="
OUT_FILE="playlist_$1.txt"

withnames=false
if [[ "$2" = "withnames" ]];
then
	withnames=true
fi
TMPFILE=$(mktemp "/tmp/$0.tmp.XXXXXX") || {
	echo "Temporary file creation failed" 1>&2
	exit 1
}

COMMAND=""
if [[ -n $(type -p wget) ]];
then
	COMMAND="wget -o /dev/null -O '$TMPFILE' '$URL'"
fi
if [ -z "$COMMAND" ] && [[ -n $(type -p curl) ]];
then
	COMMAND="curl -s -o '$TMPFILE' '$URL'"
fi
if [ -z "$COMMAND" ];
then
	echo "Please, install wget or curl to use this script" 1>&2
	exit 1
fi

eval "$COMMAND"

if $withnames;
then
	grep -o -P '"videoId":"[^"]+","thumb|\}\]\},"title":\{"runs":\[\{"text":"([^"]+)"' $TMPFILE | head -n -1 | sed 's/.*:\|,"thumb\|"//g' | sed 'N;s/^//g' | sed -rz 's/\n([^\n]*\n)/\t\1/g' | sed "s/^/$YOUTUBE_VIDEO_URL_PREFIX/g" > $OUT_FILE
else
	grep -o -P '"videoId":"[^"]+","thumb' $TMPFILE | head -n -1 | sed 's/.*:\|,"thumb\|"//g' | sed "s/^/$YOUTUBE_VIDEO_URL_PREFIX/g" > $OUT_FILE
fi

CONTINUATION=$(grep 'continuation=' $TMPFILE | head -n1 | cut -d ';' -f2-3 | cut -d '"' -f 1 | cut -d '\' -f1)

while [[ "$CONTINUATION" =~ ^continuation.* ]]
do
	URL='https://www.youtube.com/browse_ajax?action_continuation=1&'$CONTINUATION

	if [[ -n $(type -p wget) ]];
	then
		wget -o /dev/null -O "$TMPFILE" "$URL"
	else
		curl -s -o "$TMPFILE" "$URL"
	fi
	if $withnames;
	then
		sed 's/\\n/\'$'\n''/g' "$TMPFILE" | grep -e "data-title=" | sed 's/.*data-title=\\"/\'$'\n''/g'| sed 's/\\"/\'$'\n''/'| sed 's/.*watch/https:\/\/www.youtube.com\//g'| sed 's/\\u0026amp.*//g' | grep -v '^$' >> "playlist_$1.txt"
	else
		tr -s '\\|/' '\n' < "$TMPFILE" | grep "^watch" | sed 's/\\u0026amp;\(.*\)//g' | sed 's/watch/https:\/\/www.youtube.com\/watch/g' | sort -u >> "playlist_$1.txt"
	fi

	CONTINUATION=$(sed 's/action_continuation=1\\u0026amp;/\'$'\n''/g' $TMPFILE | tail -n1 | cut -d '\' -f1)
done

rm -f $TMPFILE