package features

// To do: Reconcile with go-whosonfirst-tippecanoe and/or move in to a common package
//        Maybe move in to go-whosonfirst-iterwriter

import (
	"context"
	"flag"
	"fmt"
	"log"

	"github.com/sfomuseum/go-flags/flagset"
	"github.com/whosonfirst/go-whosonfirst-geoparquet"
	"github.com/whosonfirst/go-whosonfirst-iterwriter/application/iterwriter"
)

func Run(ctx context.Context, logger *log.Logger) error {
	fs := DefaultFlagSet()
	return RunWithFlagSet(ctx, fs, logger)
}

func RunWithFlagSet(ctx context.Context, fs *flag.FlagSet, logger *log.Logger) error {

	flagset.Parse(fs)

	cb_opts := &geoparquet.IterwriterCallbackFuncBuilderOptions{
		AsSPR:               as_spr,
		RequirePolygon:      require_polygons,
		IncludeAltFiles:     include_alt_files,
		AppendSPRProperties: spr_properties,
		SkipInvalidSPR:      skip_invalid_spr,
	}

	cb := geoparquet.IterwriterCallbackFuncBuilder(cb_opts)

	opts := &iterwriter.RunOptions{
		Logger:          logger,
		FlagSet:         fs,
		FlagSetIsParsed: true,
		CallbackFunc:    cb,
	}

	err := iterwriter.RunWithOptions(ctx, opts)

	if err != nil {
		return fmt.Errorf("Failed to run iterwriter, %v", err)
	}

	return nil
}
