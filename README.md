# go-whosonfirst-geoparquet

Work in progress

## Example

Used in conjunction with the [planetlabs/gpq](https://github.com/planetlabs/gpq) tool:

```
$> ./bin/features \
	-as-spr \
	-monitor-uri null:// \
	-writer-uri 'constant://?val=featurecollection://?writer=stdout://' \
	-iterator-uri org:///tmp \
	'sfomuseum-data://?prefix=sfomuseum-data-flights-2023-' \

| gpq convert \
	--from geojson \
	--to geoparquet \
	> flights-2023.geoparquet
```

## See also

* https://github.com/planetlabs/gpq/tree/main