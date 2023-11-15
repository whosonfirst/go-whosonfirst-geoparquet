# go-whosonfirst-geoparquet

Go package to produce `planetlabs/gpq` -compatible input to generate GeoParquet files using the `whosonfirst/go-whosonfirst-iterwriter` and `whosonfirst/go-writer-featurecollection` packages.

_This should still be considered work in progress. Things are settling down but might still change._

## Example

Used in conjunction with the [planetlabs/gpq](https://github.com/planetlabs/gpq) tool. The hope is that [the internals of the `gpq` tool will be exposed as public-facing library code](https://github.com/planetlabs/gpq/issues/113) so that the final database can be written in a single command. That is still not possible today.

```
$> ./bin/features \
	-as-spr \
	-skip-invalid-spr \
	-monitor-uri null:// \
	-writer-uri 'constant://?val=featurecollection://?writer=stdout://' \
	-iterator-uri org:///tmp \
	'sfomuseum-data://?prefix=sfomuseum-data-flights-2023-' \

| gpq convert \
	--from geojson \
	--to geoparquet \
	> flights-2023.geoparquet
```

### Notes

#### The `-skip-invalid-spr` flag

This is a convenience flag to account for the fact that the code to derive [a "standard places response" (SPR)](https://github.com/whosonfirst/go-whosonfirst-spr) from a Who's On First (WOF) style document is very strict particularly about [Extended DateTime Format (EDTF) date strings](https://github.com/sfomuseum/go-edtf). While there shouldn't be any invalid EDTF dates in WOF documents the reality is that sometimes there are. If you are comfortable with dropping (n) number of documents from your final GeoParquet file because it is easier or faster than tracking down and fixing errant dates you should use this flag._

#### The `org://` iterator

This tool was orginally designed to use the [whosonfirst/go-whosonfirst-iterator-organization](https://github.com/whosonfirst/go-whosonfirst-iterate-organization) package, which takes loops through all the relevant repositories in an organization to produce a single GeoParquet database for the set of all the records in those repositories. This is convenient if you want a single GeoParquet database of, say, all the `whosonfirst-data-admin-` repositories.

Given that some databases, like DuckDB (details below), can load and process multiple GeoParquet databases in a single query it may not be necessary to produce a single "mono" database. That's your business. You can use any known  implementation of the [whosonfirst/go-whosonfirst-iterator/v2/iterator](https://github.com/whosonfirst/go-whosonfirst-iterate) interfaces (meaning that the relevant implementation been `import` -ed in to your code) with the `feature` tool. For example to create a GeoParquet database of a local repository on disk you might do:

```
$> ./bin/features \
	-as-spr \
	-skip-invalid-spr \
	-monitor-uri null:// \
	-writer-uri 'constant://?val=featurecollection://?writer=stdout://' \
	-iterator-uri repo:// \
	/usr/local/data/whosonfirst-data-admin-ca \
```

As of this writing it is not currently possible to use the `whosonfirst/go-whosonfirst-iterator-organization` to loop through multiple repositories and create multiple per-respository outputs. 

If you need to import custom, or non-standard `iterator` implementations have a look at the code for the [cmd/features/main.go](cmd/features/main.go) tool for an example of how to do that.

### DuckDB

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

### Makefile

There is also a handy `index` target in the Makefile for wrapping some of the details creating geoparquet files. For example, this:

```
$> make index SOURCE='whosonfirst-data://?prefix=whosonfirst-data-admin-us' DEST=us.geoparquet
```

Will execute this:

```
$> ./bin/features \
		-as-spr \
		-skip-invalid-spr \
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

Which will encode all of the `whosonfirst-data-admin-us` repository as a geoparquet file:

```
$> du -h us.geoparquet 
546M	us.geoparquet
```

And then:

```
$> duckdb
v0.9.1 401c8061c6
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.

D LOAD spatial;

D SELECT CAST("wof:id" AS BIGINT), "wof:name", "wof:placetype" FROM read_parquet('us.geoparquet') WHERE ST_Within(ST_GeomFromText('POINT(-122.395268 37.794893)'), 
100% ▕████████████████████████████████████████████████████████████▏ 
┌──────────────────────────┬────────────────────────────────┬───────────────┐
│ CAST("wof:id" AS BIGINT) │            wof:name            │ wof:placetype │
│          int64           │            varchar             │    varchar    │
├──────────────────────────┼────────────────────────────────┼───────────────┤
│                102087579 │ San Francisco                  │ county        │
│               1108830801 │ Downtown                       │ macrohood     │
│               1360665447 │ San Francisco-Oakland-San Jose │ marketarea    │
│                420561633 │ Super Bowl City                │ microhood     │
│                 85633793 │ United States                  │ country       │
│                 85688637 │ California                     │ region        │
│                 85865899 │ Financial District             │ neighbourhood │
│                 85922583 │ San Francisco                  │ locality      │
└──────────────────────────┴────────────────────────────────┴───────────────┘
D
```

## See also

* https://github.com/whosonfirst/go-whosonfirst-iterwriter
* https://github.com/whosonfirst/go-whosonfirst-iterate
* https://github.com/whosonfirst/go-whosonfirst-iterate-organization
* https://github.com/whosonfirst/go-writer-featurecollection
* https://github.com/whosonfirst/go-whosonfirst-spr
* https://github.com/planetlabs/gpq
* https://duckdb.org/
* https://duckdb.org/docs/extensions/spatial.html