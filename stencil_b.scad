// Hobonichi-style daily stencil, Plate B ("Techo"), for an A5 notebook with a 5 mm dot grid.
// Right-hand page, pen tracing. A fence lip on the underside seats against the top edge of
// the text block; two registration windows line up with printed dots for left/right position.
//
// Coordinates: x runs from the spine edge of the page, y runs down from the top edge.
// Layout features are placed on dot positions via G(col, row), so changing the grid offset
// moves the whole layout with the dots.

/* [Notebook] */
page_w = 148;
page_h = 210;
grid_pitch = 5;
// First dot column, measured from the spine edge
grid_ox = 4;
// First dot row, measured from the top edge
grid_oy = 5;

/* [Plate] */
plate_t = 1.4;
// Gap kept clear of the spine so the plate lies flat in a hardcover
plate_x0 = 12;
plate_x1 = 146;
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

/* [Layout] */
todo_count = 5;
etch_labels = true;
etch_d = 0.4;
label_size = 2.2;
label_font = "Liberation Mono:style=Bold";
reg_r = 1.3;

/* [Output] */
// Flip so the writing face sits on the bed and the lip points up
print_orientation = true;

$fn = 48;

function G(c, r) = [grid_ox + grid_pitch * c, -(grid_oy + grid_pitch * r)];

// ---- 2D cut primitives ----

module seg(a, b) hull() { translate(a) circle(d = slot_w); translate(b) circle(d = slot_w); }

module polyline(pts) for (i = [0 : len(pts) - 2]) seg(pts[i], pts[i + 1]);

// Straight slot split into bridged segments; bridge_w is the material left between slot ends.
// `at` optionally places bridge centres (mm along the slot) instead of spacing them evenly.
module bridged(a, b, at = undef) {
    L = norm(b - a);
    u = (b - a) / L;
    g = bridge_w + slot_w;
    n = L <= bridge_span + 5 ? 1 : ceil(L / bridge_span);
    s = (L - (n - 1) * g) / n;
    cs = is_undef(at) ? [for (i = [1 : 1 : n - 1]) i * (s + g) - g / 2] : at;
    ends = concat([0], [for (c = cs) each [c - g / 2, c + g / 2]], [L]);
    for (i = [0 : 2 : len(ends) - 1]) seg(a + u * ends[i], a + u * ends[i + 1]);
}

// Four L-shaped corner marks of a box, arms `a` mm long.
module corners(p0, p1, a) {
    x0 = p0[0]; y0 = p0[1]; x1 = p1[0]; y1 = p1[1];
    polyline([[x0, y0 - a], [x0, y0], [x0 + a, y0]]);
    polyline([[x1 - a, y0], [x1, y0], [x1, y0 - a]]);
    polyline([[x0, y1 + a], [x0, y1], [x0 + a, y1]]);
    polyline([[x1 - a, y1], [x1, y1], [x1, y1 + a]]);
}

// ---- Plate B layout ----

days = ["M", "T", "W", "T", "F", "S", "S"];

module cuts() {
    // Date box
    corners(G(2, 1), G(6, 4), 3);
    // Day-of-week circles
    for (i = [0 : 6]) translate(G(8 + 2 * i, 3)) circle(r = 1.75);
    // Header rule
    bridged(G(2, 5), G(28, 5));
    // Timeline 6-24, one hour per row, so the hour equals the grid row
    // Rail bridges sit between ticks at 11:30 and 17:30 so the 12 and 18 ticks stay joined
    bridged(G(5, 6), G(5, 24), at = [5.5 * grid_pitch, 11.5 * grid_pitch]);
    for (h = [6 : 24]) seg(G(5, h) - [h % 6 == 0 ? 7 : 3, 0], G(5, h));
    // To-do column
    bridged(G(17, 6), G(17, 32));
    for (i = [0 : todo_count - 1]) translate(G(18, 7 + 2 * i)) square(3, center = true);
    // Footer rule and quote box
    bridged(G(2, 33), G(28, 33));
    corners(G(3, 34), G(27, 38), 4);
    // Registration windows, centred on dots
    for (p = [G(27, 3), G(15, 39)]) translate(p) circle(r = reg_r);
}

module labels() {
    for (i = [0 : 6]) translate(G(8 + 2 * i, 3) + [0, 4.2])
        text(days[i], size = label_size, font = label_font, halign = "center");
    for (h = [6 : 6 : 24]) translate(G(5, h) + [-8, -0.8])
        text(str(h), size = label_size, font = label_font, halign = "right");
    translate(G(18, 5.8) - [1.5, 0]) text("TO DO", size = 2, font = label_font);
}

module outline() hull() {
    translate([plate_x0, lip_clear]) square([plate_x1 - plate_x0, lip_t]);
    for (x = [plate_x0 + corner_r, plate_x1 - corner_r]) translate([x, -plate_y1 + corner_r]) circle(r = corner_r);
}

// ---- 3D, in use orientation: paper face at z = 0, writing face at z = plate_t ----

module stencil() {
    difference() {
        union() {
            linear_extrude(plate_t) outline();
            // Fence lip that drops over the top edge of the text block
            translate([plate_x0, lip_clear, -lip_drop]) cube([plate_x1 - plate_x0, lip_t, lip_drop + plate_t]);
        }
        translate([0, 0, -1]) linear_extrude(plate_t + 2) cuts();
        if (relief_w > 0) translate([0, 0, -1]) linear_extrude(relief_d + 1) offset(delta = relief_w) cuts();
        if (etch_labels) translate([0, 0, plate_t - etch_d]) linear_extrude(etch_d + 1) labels();
    }
}

if (print_orientation) translate([0, 0, plate_t]) rotate([180, 0, 0]) stencil();
else stencil();
