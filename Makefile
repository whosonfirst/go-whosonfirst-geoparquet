GOMOD=$(shell test -f "go.work" && echo "readonly" || echo "vendor")

cli:
	go build -mod $(GOMOD) -ldflags="-s -w" -o bin/features cmd/features/main.go

index:
	./bin/features \
		-as-spr \
		-monitor-uri null:// \
		-writer-uri 'constant://?val=featurecollection://?writer=stdout://' \
		-iterator-uri org:///tmp \
		"$(SOURCE)" \
		| \
		gpq convert \
		--from geojson \
		--to geoparquet \
		> $(DEST)
