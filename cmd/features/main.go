package main

// To do: Reconcile with go-whosonfirst-tippecanoe and/or move in to a common package
//        Maybe move in to go-whosonfirst-iterwriter

import (
	_ "github.com/whosonfirst/go-whosonfirst-iterate-organization"
	_ "github.com/whosonfirst/go-writer-featurecollection/v3"
	_ "github.com/whosonfirst/go-writer-jsonl/v3"
)

import (
	"context"
	"log"

	"github.com/whosonfirst/go-whosonfirst-geoparquet/app/features"	
)

func main() {

	ctx := context.Background()
	logger := log.Default()

	err := features.Run(ctx, logger)

	if err != nil {
		logger.Fatalf("Failed to run iterwriter, %v", err)
	}
}
