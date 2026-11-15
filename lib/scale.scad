// Printed number scales: plates with numbers, separators and a border, as inlay, raised or engraved.
// Use:  use <../../lib/scale.scad>   (also `use <../../lib/fonts.scad>` for font_for(); border_2d() is in core.scad)
// Conventions: a scale runs along +X at the label positions `xs`, centred on y=0. Plates sit on z=0.

PLATE_STYLES     = ["inlay", "raised", "engraved"];
SEPARATOR_STYLES = ["dot", "bar", "diamond", "none"];

// numbers (any list of numbers/strings) at x positions xs, with a separator between neighbours
module number_row_2d(labels, xs, size=5.2, font="Liberation Serif", sep="dot", sep_d=1.4) {
    for (i=[0:1:len(labels)-1]) translate([xs[i], 0])
        text(str(labels[i]), size=size, font=font, halign="center", valign="center");
    if (sep != "none") for (i=[0:1:len(labels)-2]) translate([(xs[i] + xs[i+1])/2, 0]) {
        if (sep == "bar") square([sep_d*0.45, size*0.9], center=true);
        else if (sep == "diamond") rotate(45) square(sep_d*0.9, center=true);
        else circle(d=sep_d, $fn=16);
    }
}

// rounded plate outline from x0 to x1, height h
module scale_plate_2d(x0, x1, h=10, r=1) { offset(r=r) offset(delta=-r) translate([x0, -h/2]) square([x1 - x0, h]); }

// plate body: children(0) = plate outline, children(1) = artwork (numbers, border)
//   inlay    -> plate with the artwork recessed `depth` (fill it with plate_art)
//   raised   -> plain plate (plate_art adds artwork on top)
//   engraved -> plate with the artwork recessed, no separate artwork part
module plate_body(t=2, style="inlay", depth=0.6) {
    difference() {
        linear_extrude(t) children(0);
        if (style != "raised") translate([0,0,t - depth]) linear_extrude(depth + 1) children(1);
    }
}
// separate artwork part for a 2-colour print (empty for "engraved")
module plate_art(t=2, style="inlay", depth=0.6) {
    if (style == "inlay") translate([0,0,t - depth]) linear_extrude(depth) intersection() { children(1); offset(delta=-0.3) children(0); }
    else if (style == "raised") translate([0,0,t]) linear_extrude(depth) intersection() { children(1); offset(delta=-0.3) children(0); }
}
