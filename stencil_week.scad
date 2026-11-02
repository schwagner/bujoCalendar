// Hobonichi Techo Cousin-style weekly spread for an A5 notebook with a 5 mm dot grid,
// pen tracing. A vertical week across both pages: an hourly timeline on the outer edge of
// the left page, then Mon-Thu on the left and Fri-Sun plus a notes column on the right.
// Each day column is 5 dots (25 mm) wide, with a header band for the day name and date,
// the timeline band, and a free band underneath.
//   openscad -D 'page="left"'  -o stencil_week_left.stl  stencil_week.scad
//   openscad -D 'page="right"' -o stencil_week_right.stl stencil_week.scad

/* [Page] */
page = "left"; // [left, right]
week_start = "mon"; // [mon, sun]
// Timeline, one hour per dot row
hour_from = 8;
hour_to = 23;

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

left = page == "left";
grid_ox = left ? grid_ox_left : grid_ox_right;
plate_x0 = left ? outer_margin : spine_gap;
plate_x1 = left ? page_w - spine_gap : page_w - outer_margin;

days = day_names(week_start);
x0 = 2;                                   // left page: outer edge for week box and hour numbers
xt = 6;                                   // left page: timeline rail = left edge of the first day
// Day column lines: four days on the left page, three on the right
xs = left ? [for (i = [0 : 4]) xt + 5 * i] : [for (i = [0 : 3]) 2 + 5 * i];
xn = 27;                                  // right page: outer edge of the notes column
names = left ? [for (i = [0 : 3]) days[i]] : [for (i = [4 : 6]) days[i]];
y_top = 3;                                // top of the day header band
y_head = 6;                               // header band | timeline (hour_from)
y_time = y_head + hour_to - hour_from;    // timeline | free band (hour_to)
y_end = 38;                               // bottom of the week
function row(h) = y_head + h - hour_from;
function top_mid(a, b) = G((a + b) / 2, y_top) - [0, 2.25 + letter_h];

module cuts() {
    grid_lines(xs, [y_top, y_head, y_time, y_end]);
    if (left) {
        // Week box: month or dates
        corners(G(x0, 0), G(xt + 2, 2), 3);
        // Hour ticks on the timeline rail, longer every third hour
        for (h = [hour_from : hour_to]) seg(G(xt, row(h)) - [h % 3 == 0 ? 6 : 3, 0], G(xt, row(h)));
    } else {
        // Notes column: shares the last day line, so only its own edges are cut here
        // (cutting a shared line twice would cut through its bridges)
        for (r = [y_top, y_head, y_end]) edge(G(xs[3], r), G(xn, r));
        edge(G(xn, y_top), G(xn, y_head));
        edge(G(xn, y_head), G(xn, y_end));
        if (day_stencil) stencil_word("NOTES", top_mid(xs[3], xn));
    }
    // Day names centred at the top of each header cell; the date goes below
    if (day_stencil) for (i = [0 : len(names) - 1]) stencil_word(names[i], top_mid(xs[i], xs[i + 1]));
    // Registration windows, centred on dots
    for (p = left ? [G(24, 1), G(16, 39)] : [G(4, 1), G(22, 39)]) translate(p) circle(r = reg_r);
}

module labels() {
    // Hour numbers beside the ticks
    if (left) for (h = [hour_from : hour_to]) translate(G(xt, row(h)) + [-7.8, -0.8])
        text(str(h), size = label_size, font = label_font, halign = "right");
    if (!day_stencil) {
        heads = left ? names : concat(names, ["NOTES"]);
        cols = left ? xs : concat(xs, [xn]);
        for (i = [0 : len(heads) - 1]) translate(G((cols[i] + cols[i + 1]) / 2, y_top) + [0, -1.7])
            text(heads[i], size = label_size, font = label_font, halign = "center", valign = "top");
    }
}

place() stencil_body(plate_x0, plate_x1) { cuts(); labels(); }
