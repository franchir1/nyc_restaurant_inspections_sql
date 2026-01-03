#import "@preview/cetz:0.4.2": canvas
#import "@preview/cetz-plot:0.1.3": plot
#import "csv.typ": load-csv, colors

#set page(width: auto, height: auto, margin: 8pt, fill: rgb("#111111"))
#set text(fill: white, size: 9pt)

#let data = load-csv("2_QUERIES/Q3/score_history.csv")
  .filter(r => r.area_name != "")

#let years = data.map(r => int(r.inspection_year))
#let ys = data.map(r => float(r.avg_score))

#canvas({
  import cetz.draw: *

  set-style(stroke: white, axes: (tick: (stroke: white)))

  plot.plot(
    size: (12, 6),
    axis-style: "left",
    legend: "outer-south",
    legend-style: (fill: rgb("#111111"), stroke: white),
    x-min: calc.min(..years),
    x-max: calc.max(..years),
    y-min: calc.min(..ys),
    y-max: calc.max(..ys),
    x-label: "",
    y-label: "",
    {
      for area in colors.keys() {
        let pts = data
          .filter(r => r.area_name == area)
          .map(r => (int(r.inspection_year), float(r.avg_score)))

        plot.add(
          pts,
          label: area,
          mark: "o",
          style: (stroke: colors.at(area)),
        )
      }
    }
  )
})