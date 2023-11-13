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

And the loading the `flights-2023.geoparquet` database in [DuckDB](https://duckdb.org/docs/extensions/spatial.html):

```
$> duckdb
v0.8.1 6536a77232
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.

D LOAD spatial;

D SELECT "wof:name", ST_GeomFromWkb(geometry) AS geometry FROM read_parquet('flights-2023.geoparquet') WHERE "wof:name" LIKE 'DL%' LIMIT 10;
┌──────────────────┬──────────────────────────────────────────────────────────┐
│     wof:name     │                         geometry                         │
│     varchar      │                         geometry                         │
├──────────────────┼──────────────────────────────────────────────────────────┤
│ DL1007 (MSP-SFO) │ MULTIPOINT (-93.200317 44.883321, -122.370943 37.61799)  │
│ DL1012 (MSP-SFO) │ MULTIPOINT (-93.200317 44.883321, -122.370943 37.61799)  │
│ DL2188 (DTW-SFO) │ MULTIPOINT (-83.351709 42.21886, -122.370943 37.61799)   │
│ DL2202 (MSP-SFO) │ MULTIPOINT (-93.200317 44.883321, -122.370943 37.61799)  │
│ DL2250 (SEA-SFO) │ MULTIPOINT (-122.304268 47.441823, -122.370943 37.61799) │
│ DL2267 (LAX-SFO) │ MULTIPOINT (-118.38951 33.942593, -122.370943 37.61799)  │
│ DL2272 (LAX-SFO) │ MULTIPOINT (-118.38951 33.942593, -122.370943 37.61799)  │
│ DL2348 (SLC-SFO) │ MULTIPOINT (-111.980566 40.78217, -122.370943 37.61799)  │
│ DL2414 (SLC-SFO) │ MULTIPOINT (-111.980566 40.78217, -122.370943 37.61799)  │
│ DL2443 (SLC-SFO) │ MULTIPOINT (-111.980566 40.78217, -122.370943 37.61799)  │
├──────────────────┴──────────────────────────────────────────────────────────┤
│ 10 rows                                                           2 columns │
└─────────────────────────────────────────────────────────────────────────────┘
```

There is also a handy `index` target in the Makefile for wrapping some of the details creating geoparquet files. For example, this:

```
$> make index SOURCE='whosonfirst-data://?prefix=whosonfirst-data-admin-us' DEST=us.geoparquet
```

Will execute this:

```
$> ./bin/features \
		-as-spr \
		-monitor-uri null:// \
		-writer-uri 'constant://?val=featurecollection://?writer=stdout://' \
		-iterator-uri org:///tmp \
		"whosonfirst-data://?prefix=whosonfirst-data-admin-us" \
		| \
		gpq convert \
		--from geojson \
		--to geoparquet \
		> us.geoparquet
```

## See also

* https://github.com/whosonfirst/go-whosonfirst-iterwriter
* https://github.com/whosonfirst/go-whosonfirst-iterate
* https://github.com/whosonfirst/go-whosonfirst-iterate-organization
* https://github.com/whosonfirst/go-writer-featurecollection
* https://github.com/planetlabs/gpq
* https://duckdb.org/