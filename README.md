# bujoCalendar

3D-printable stencils for Hobonichi Techo–style daily, weekly and monthly pages in a generic A5 hardcover notebook with a 5 mm dot grid.

- `stencil_b.scad` — Plate B: date box, day-of-week circles, 6–24 timeline, to-do column, quote box. Right-hand page, for pen tracing.
- `stencil_week.scad` — weekly spread, left-hand page: seven day rows (25 mm each) with a date column and etched day names, plus a week box. The right-hand memo page is plain dot grid, so it has no plate.
- `stencil_month.scad` — monthly spread, two plates (`page = "left"` / `"right"`): six week rows of 30 × 25 mm day cells, Mon–Thu on the left page and Fri–Sun plus a notes column on the right. Set `week_start = "sun"` for a Sunday start.
- `stencil_lib.scad` — shared slot, bridge and plate code used by the weekly and monthly plates.
- `mockups/index.html` — to-scale layout mockups of plates A, B and C, for pen and ink roller.

## Use

The lip on the underside seats against the top edge of the pages, which sets the vertical position. Slide the stencil sideways until a printed dot sits centred in each of the two round windows. Gaps in the long slots are bridges; join them by hand. On the monthly grid every cell edge has one bridge at its midpoint, so the crossings come out exact and you only close short straight gaps.

Left-hand plates (weekly, monthly left) measure `grid_ox` from the outer edge of the page instead of the spine.

## Build

```sh
openscad -o stencil_b.stl stencil_b.scad
openscad -o stencil_week.stl stencil_week.scad
openscad -D 'page="left"'  -o stencil_month_left.stl  stencil_month.scad
openscad -D 'page="right"' -o stencil_month_right.stl stencil_month.scad
```

The default orientation prints writing face down with the lip pointing up, so it needs no supports. Measure your notebook and set `grid_ox` (first dot column from the spine edge) and `grid_oy` (first dot row from the top edge). Other settings, including `todo_count`, are in the Customizer.
