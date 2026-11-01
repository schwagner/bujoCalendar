// Hobonichi-style monthly spread for an A5 notebook with a 5 mm dot grid, pen tracing.
// Two plates: the left page holds four days of the week, the right page holds the other
// three plus a notes column. Six week rows, each cell 6 x 5 dots (30 x 25 mm).
// Render each page separately:
//   openscad -D 'page="left"'  -o stencil_month_left.stl  stencil_month.scad
//   openscad -D 'page="right"' -o stencil_month_right.stl stencil_month.scad

/* [Page] */
page = "left"; // [left, right]
week_start = "mon"; // [mon, sun]

/* [Notebook] */
page_w = 148;
page_h = 210;
grid_pitch = 5;
// Left page: first dot column, measured from the outer (fore) edge
grid_ox_left = 4;
// Right page: first dot column, measured from the spine edge
grid_ox_right = 4;
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

left = page == "left";
grid_ox = left ? grid_ox_left : grid_ox_right;
plate_x0 = left ? outer_margin : spine_gap;
plate_x1 = left ? page_w - spine_gap : page_w - outer_margin;

days = day_names(week_start);
// Dot columns of the vertical grid lines. Right page: three days, then a 7-dot notes column.
xs = left ? [2, 8, 14, 20, 26] : [2, 8, 14, 20, 27];
ys = [for (r = [5 : 5 : 35]) r];
names = left ? [for (i = [0 : 3]) days[i]] : [for (i = [4 : 6]) days[i]];

module cuts() {
    grid_lines(xs, ys);
    // Month box above the grid on the left page
    if (left) corners(G(2, 0), G(8, 3), 3);
    // Registration windows, centred on dots
    for (p = left ? [G(24, 1), G(14, 38)] : [G(4, 1), G(24, 38)]) translate(p) circle(r = reg_r);
}

module labels() {
    for (i = [0 : len(names) - 1]) translate(G((xs[i] + xs[i + 1]) / 2, ys[0]) + [0, 1.6])
        text(names[i], size = label_size, font = label_font, halign = "center");
    if (!left) translate(G((xs[3] + xs[4]) / 2, ys[0]) + [0, 1.6])
        text("NOTES", size = label_size, font = label_font, halign = "center");
}

place() stencil_body(plate_x0, plate_x1) { cuts(); labels(); }
