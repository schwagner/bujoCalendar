// Hobonichi-style weekly spread for an A5 notebook with a 5 mm dot grid, pen tracing.
// Left-hand page: seven day rows of 5 dots (25 mm), each with a date column on the outer
// side. The right-hand page of the spread is the free memo page, which the dot grid
// already covers, so it has no plate.
//   openscad -o stencil_week.stl stencil_week.scad

/* [Layout] */
week_start = "mon"; // [mon, sun]

/* [Notebook] */
page_w = 148;
page_h = 210;
grid_pitch = 5;
// First dot column, measured from the outer (fore) edge of the left page
grid_ox = 4;
// First dot row, measured from the top edge
grid_oy = 5;

/* [Plate] */
plate_t = 1.4;
// Gap kept clear of the spine so the plate lies flat in a hardcover
spine_gap = 10;
outer_margin = 2;
plate_y1 = 208;
corner_r = 3;

/* [Lip] */
lip_t = 1.6;
lip_drop = 3;
lip_clear = 0.15;

/* [Slots] */
slot_w = 1.0;
bridge_w = 2.5;
bridge_span = 40;
// Undercut on the paper side so ink doesn't wick under the plate; 0 to disable
relief_w = 0.25;
relief_d = 0.4;

/* [Labels] */
etch_labels = true;
etch_d = 0.4;
label_size = 2.2;
label_font = "Liberation Mono:style=Bold";
reg_r = 1.3;

/* [Output] */
print_orientation = true;

$fn = 48;

include <stencil_lib.scad>

days = day_names(week_start);
x0 = 2;      // outer end of the day rules
xd = 6;      // date column rule
x1 = 26;     // spine end of the day rules
rows = [for (i = [0 : 7]) 3 + 5 * i];  // rules at dot rows 3, 8, ... 38

module cuts() {
    // Week box: dates or week number
    corners(G(x0, 0), G(8, 2), 3);
    // Day rules. Nothing closes the rows at either end, so no bridge is needed to hold
    // a piece in; the default spacing just keeps the long strips stiff.
    for (r = rows) bridged(G(x0, r), G(x1, r));
    // Date column rule, bridged once per day
    for (i = [0 : 6]) mid_bridged(G(xd, rows[i]), G(xd, rows[i + 1]));
    // Registration windows, centred on dots
    for (p = [G(24, 1), G(14, 39)]) translate(p) circle(r = reg_r);
}

module labels() {
    for (i = [0 : 6]) translate(G(x0, rows[i]) + [1, -1.7])
        text(days[i], size = label_size, font = label_font, valign = "top");
}

place() stencil_body(outer_margin, page_w - spine_gap) { cuts(); labels(); }
