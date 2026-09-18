# Arctic sea ice extent

An interactive R Shiny app for comparing recent Arctic sea ice extent with
historical daily values. The chart overlays recent years on the historical
minimum-to-maximum range, a selectable central percentile range, and the median.
Extent is displayed in millions of square kilometres.

## Requirements

- R 4.1 or later (the code uses the native `|>` pipe). Installed packages may
  require a newer R version.
- The `shiny`, `lubridate`, and `tidyverse` R packages.
- An internet connection to download the sea ice data.
- Optionally, RStudio to open the included project file.

## Installation and launch

Download or clone this repository, then open an R session in its root directory
(the directory containing `app.R`). Install the dependencies once:

```r
install.packages(c("shiny", "lubridate", "tidyverse"))
```

Start the app:

```r
shiny::runApp(".", launch.browser = TRUE)
```

Alternatively, open `seaice.Rproj` in RStudio, open `app.R`, and click **Run App**.
Stop the app with the RStudio Stop button or by interrupting the R console.

## Using the chart

The horizontal axis shows the months of the year. Each coloured line represents
one recent year, identified in the legend. The latest year means the latest year
present in the downloaded data, which may be incomplete.

| Control | Default | Behaviour |
| --- | --- | --- |
| **Inter-percentile range** | 50 | Selects the central percentage of historical daily extents shown by the darker band, from 0 to 100 in steps of 1. At 50, the bounds are the 25th and 75th percentiles. |
| **Years plotted** | 1 | Selects the number of recent years drawn as coloured lines, from 1 to 10. Those years are excluded from the historical reference period. |

The reference statistics are calculated separately for each calendar day:

- The lightest band spans the historical minimum and maximum.
- The darker band shows the selected central percentile range.
- The black line shows the historical median.

At 0 percent, the central band collapses to the median. At 100 percent, it covers
the full minimum-to-maximum range. These bands describe the historical data;
they are not forecast intervals.

Changing **Years plotted** also changes the reference period and therefore the
bands and median. For example, selecting 3 plots the latest three years and uses
all earlier years as the reference. The text beneath the controls reports the
reference period and selected percentage.

## Data and calculations

The data loader uses the NSIDC-hosted Northern Hemisphere daily sea ice extent
CSV at this configured address:

[N_seaice_extent_daily_v4.0.csv](https://noaadata.apps.nsidc.org/NOAA/G02135/north/daily/data/N_seaice_extent_daily_v4.0.csv)

`seaice_approx.R` reads the CSV, skips its first two header rows, and constructs
dates from the year, month, and day columns. It uses `stats::approx()` with its
default linear interpolation to produce an extent value for every day between
the first and last dates in the source. As a result, the plotted series can
include interpolated values as well as observations. The source's `Missing` and
`Source Data` columns are read but are not used in the chart calculations.

`app.R` preserves each value's original year, then maps dates to the common year
2001 to align the annual curves. Because 2001 is not a leap year, February 29
cannot be represented and is omitted by the subsequent missing-value removal.
Historical quantiles use R's `quantile(..., type = 8)`, with lower and upper
probabilities of `0.5 - percentage / 200` and `0.5 + percentage / 200`.

The data loader runs when each Shiny session starts. There is no local data cache
or scheduled refresh within an existing session. Start a new session to download
the source again. Slider changes recalculate the chart using the data already
loaded for that session.

## Project files

| File | Purpose |
| --- | --- |
| `app.R` | Shiny interface, reactive historical summaries, and chart rendering. |
| `seaice_approx.R` | CSV download, date construction, and daily interpolation. |
| `seaice.Rproj` | RStudio project settings. |
| `LICENSE.md` | GNU General Public License, version 3. |

## Troubleshooting

- **A package is missing:** run the installation command above in the same R
  installation used to launch the app.
- **`seaice_approx.R` cannot be found:** launch from the repository root, or open
  `seaice.Rproj` before running the app.
- **The data cannot be downloaded:** check your internet connection and access to
  the linked CSV. The app requires the remote source when a session starts and
  has no offline fallback.
- **The CSV no longer loads correctly:** the loader assumes two header rows and
  the column order `Year`, `Month`, `Day`, `Extent`, `Missing`, `Source Data`.
  Changes to the upstream format may require updating `seaice_approx.R`.

## License

See [LICENSE.md](LICENSE.md) for the GNU General Public License, version 3.
