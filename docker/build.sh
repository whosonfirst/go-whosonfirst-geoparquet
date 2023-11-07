#!/bin/sh

SOURCES=""		# for example: -s 'sfomuseum-data://?prefix=sfomuseum-data-whosonfirst'
TARGET=""		# for example: -t s3blob://bucket?region=us-east-1&credentials=iam:

WRITE_FEATURES=""
HELP=""

NAME="whosonfirst"	# for example -n whosonfirst"
ITERATOR="org:///tmp"
ZOOM="12"

LAYER_NAME=""	# tippecanoe layer name
PROPERTIES=""	# for example: -p 'wof:hierarchy wof:concordances'

while getopts "i:l:n:p:s:t:z:fh" opt; do
    case "$opt" in
	f)
	    WRITE_FEATURES=1
	    ;;
	h)
	    HELP=1
	    ;;
	i)
	    ITERATOR=$OPTARG
	    ;;
	l)
	    LAYER_NAME=$OPTARG
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
	t )
	    TARGET=$OPTARG
	    ;;
	z )
	    ZOOM=$OPTARG
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

for PROP in ${PROPERTIES}
do
    FEATURES_ARGS="${FEATURES_ARGS} -spr-append-property ${PROP}"
done

for SRC in ${SOURCES}
do
    FEATURES_ARGS="${FEATURES_ARGS} ${SRC}"
done

GPQ_ARGS="convert -from geojson -to geoparquet /usr/local/data/${NAME}.geoparquet"

echo "wof-geoparquet-features ${FEATURES_ARGS} | gpq ${GPQ_ARGS}"

wof-geoparquet-features ${FEATURES_ARGS} | gpq ${GPQ_ARGS}

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
