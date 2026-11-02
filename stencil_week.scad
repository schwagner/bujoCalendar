// Hobonichi Techo Cousin-style weekly spread for an A5 notebook with a 5 mm dot grid,
// pen tracing. Left-hand page: a vertical week of seven 3-dot (15 mm) day columns with an
// hourly timeline on the outer edge, a header band for day names and dates, and a free
// band at the bottom of each day. The right-hand page of the spread is the free memo page,
// which the dot grid already covers, so it has no plate.
//   openscad -o stencil_week.stl stencil_week.scad

/* [Layout] */
week_start = "mon"; // [mon, sun]
// Timeline, one hour per dot row
hour_from = 8;
hour_to = 23;

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
// Cut day names through the plate so you can trace them; off etches them instead
day_stencil = true;
letter_h = 5;
letter_w = 3.5;
letter_gap = 1.75;
// Chamfer on letter corners
letter_c = 0.8;
// Material left in the gap that holds the inside of A, D, O and R
letter_bridge = 1.0;
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
x0 = 2;                                   // outer edge: week box, hour numbers
xt = 5;                                   // timeline rail = left edge of Monday
xs = [for (i = [0 : 7]) xt + 3 * i];      // day column lines, ends at dot column 26
y_top = 3;                                // top of the day header band
y_head = 6;                               // header band | timeline (hour_from)
y_time = y_head + hour_to - hour_from;    // timeline | free band (hour_to)
y_end = 38;                               // bottom of the week

module cuts() {
    // Week box: month or dates
    corners(G(x0, 0), G(8, 2), 3);
    grid_lines(xs, [y_top, y_head, y_time, y_end]);
    // Hour ticks on the timeline rail, longer every third hour
    for (h = [hour_from : hour_to])
        seg(G(xt, y_head + h - hour_from) - [h % 3 == 0 ? 6 : 3, 0], G(xt, y_head + h - hour_from));
    // Day names, two letters, centred at the top of each header cell; date goes below
    if (day_stencil) for (i = [0 : 6]) stencil_word(short(days[i]),
        G((xs[i] + xs[i + 1]) / 2, y_top) - [0, 2.25 + letter_h]);
    // Registration windows, centred on dots
    for (p = [G(24, 1), G(14, 39)]) translate(p) circle(r = reg_r);
}

function short(d) = str(d[0], d[1]);

module labels() {
    // Hour numbers beside the ticks
    for (h = [hour_from : hour_to]) translate(G(xt, y_head + h - hour_from) + [-7.8, -0.8])
        text(str(h), size = label_size, font = label_font, halign = "right");
    if (!day_stencil) for (i = [0 : 6]) translate(G((xs[i] + xs[i + 1]) / 2, y_top) + [0, -1.7])
        text(short(days[i]), size = label_size, font = label_font, halign = "center", valign = "top");
}

place() stencil_body(outer_margin, page_w - spine_gap) { cuts(); labels(); }
