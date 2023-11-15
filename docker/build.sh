#!/bin/sh

SOURCES=""		# for example: -s 'sfomuseum-data://?prefix=sfomuseum-data-whosonfirst'
TARGET=""		# for example: -t s3blob://bucket?region=us-east-1&credentials=iam:

HELP=""

NAME="whosonfirst"	# for example -n whosonfirst"
ITERATOR="org:///tmp"

SKIP_INVALID_SPR=""

PROPERTIES=""	# for example: -p 'wof:hierarchy wof:concordances'

while getopts "i:n:p:s:t:hS" opt; do
    case "$opt" in
	h)
	    HELP=1
	    ;;
	i)
	    ITERATOR=$OPTARG
	    ;;
	n)
	    NAME=$OPTARG
	    ;;
	p)
	    PROPERTIES=$OPTARG
	    ;;
	s )
	    SOURCES=$OPTARG
	    ;;
	S )
	    SKIP_INVALID_SPR=1
	    ;;
	t )
	    TARGET=$OPTARG
	    ;;
	: )
	    echo "WHAT"
	    ;;
    esac
done

if [ "${HELP}" = "1" ]
then
    echo "Print this message"
    exit 0
fi

echo "Import ${SOURCE} FROM ${ITERATOR} as ${NAME} and copy to ${TARGET}"

FEATURES_ARGS="-as-spr -writer-uri constant://?val=featurecollection://?writer=stdout:// -iterator-uri ${ITERATOR}"

if [ "${SKIP_INVALID_SPR}" = "1" ]
then
    FEATURES_ARGS="${FEATURES_ARGS} -skip-invalid-spr"
fi

for PROP in ${PROPERTIES}
do
    FEATURES_ARGS="${FEATURES_ARGS} -spr-append-property ${PROP}"
done

for SRC in ${SOURCES}
do
    FEATURES_ARGS="${FEATURES_ARGS} ${SRC}"
done

GPQ_ARGS="convert --from geojson --to geoparquet"

echo "wof-geoparquet-features ${FEATURES_ARGS} | gpq ${GPQ_ARGS} > /usr/local/data/${NAME}.geoparquet"

wof-geoparquet-features ${FEATURES_ARGS} | gpq ${GPQ_ARGS} > /usr/local/data/${NAME}.geoparquet

if [ $? -ne 0 ]
then

    echo "Failed to create GeoParquet database"
    exit 1
fi

if [ "${TARGET}" != "" ]
then
    
    copy-uri -source-uri file:///usr/local/data/${NAME}.geoparquet -target-uri ${TARGET}
fi

exit 0
