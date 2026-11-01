// Shared primitives for the weekly and monthly stencils.
// Pull this in with `include`, not `use`: it reads the settings (grid_*, slot_w, bridge_*,
// plate_*, lip_*, relief_*, etch_*) from the file that includes it.
//
// Coordinates: x runs from the left edge of the page (the fore edge on a left-hand page,
// the spine on a right-hand page), y runs down from the top edge, so y is negative.

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

// One bridge in the middle of the slot. Grid edges use this so the crossings are cut cleanly
// and every enclosed cell stays attached to all four neighbours.
module mid_bridged(a, b) bridged(a, b, at = [norm(b - a) / 2]);

// Closed grid whose lines sit on dot columns `xs` and dot rows `ys`.
module grid_lines(xs, ys) {
    for (r = ys) for (i = [0 : len(xs) - 2]) mid_bridged(G(xs[i], r), G(xs[i + 1], r));
    for (c = xs) for (j = [0 : len(ys) - 2]) mid_bridged(G(c, ys[j]), G(c, ys[j + 1]));
}

// Four L-shaped corner marks of a box, arms `a` mm long.
module corners(p0, p1, a) {
    x0 = p0[0]; y0 = p0[1]; x1 = p1[0]; y1 = p1[1];
    polyline([[x0, y0 - a], [x0, y0], [x0 + a, y0]]);
    polyline([[x1 - a, y0], [x1, y0], [x1, y0 - a]]);
    polyline([[x0, y1 + a], [x0, y1], [x0 + a, y1]]);
    polyline([[x1 - a, y1], [x1, y1], [x1, y1 + a]]);
}

// ---- Plate ----

module outline(x0, x1) hull() {
    translate([x0, lip_clear]) square([x1 - x0, lip_t]);
    for (x = [x0 + corner_r, x1 - corner_r]) translate([x, -plate_y1 + corner_r]) circle(r = corner_r);
}

// In use orientation: paper face at z = 0, writing face at z = plate_t.
// children(0) is the 2D cut-through layout, children(1) the 2D etched labels.
module stencil_body(x0, x1) {
    difference() {
        union() {
            linear_extrude(plate_t) outline(x0, x1);
            // Fence lip that drops over the top edge of the text block
            translate([x0, lip_clear, -lip_drop]) cube([x1 - x0, lip_t, lip_drop + plate_t]);
        }
        translate([0, 0, -1]) linear_extrude(plate_t + 2) children(0);
        if (relief_w > 0) translate([0, 0, -1]) linear_extrude(relief_d + 1) offset(delta = relief_w) children(0);
        if (etch_labels) translate([0, 0, plate_t - etch_d]) linear_extrude(etch_d + 1) children(1);
    }
}

// Flip so the writing face sits on the bed and the lip points up: no supports needed.
module place() {
    if (print_orientation) translate([0, 0, plate_t]) rotate([180, 0, 0]) children();
    else children();
}

function day_names(start) = start == "sun"
    ? ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    : ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
