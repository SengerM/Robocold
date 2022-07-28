module PhotonisPMT() {
    color([1,1,1]*.2) {
        cylinder(d=43, h=55-14.5);
        difference() {
            translate([0,0,55-14.5]) cylinder(d=38, h=14.5);
            translate([0,0,55-10]) cylinder(h=11, d=8.2);
        }
    }
    color([1,1,1]*.8) translate([-15/2,0,0]) rotate(v=[1,0,0], a=180) cylinder(d=10,h=23.2-9);
    color([1,1,0]*.8) translate([+15/2,0,0]) rotate(v=[1,0,0], a=180) cylinder(d=6,h=6);
}

PhotonisPMT();
