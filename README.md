# bujoCalendar

3D-printable stencil for a Hobonichi Techo–style daily page in a generic A5 hardcover notebook with a 5 mm dot grid.

- `stencil_b.scad` — Plate B: date box, day-of-week circles, 6–24 timeline, to-do column, quote box. Right-hand page, for pen tracing.
- `mockups/index.html` — to-scale layout mockups of plates A, B and C, for pen and ink roller.

## Use

The lip on the underside seats against the top edge of the pages, which sets the vertical position. Slide the stencil sideways until a printed dot sits centred in each of the two round windows. Gaps in the long slots are bridges; join them by hand.

## Build

```sh
openscad -o stencil_b.stl stencil_b.scad
```

The default orientation prints writing face down with the lip pointing up, so it needs no supports. Measure your notebook and set `grid_ox` (first dot column from the spine edge) and `grid_oy` (first dot row from the top edge). Other settings, including `todo_count`, are in the Customizer.
