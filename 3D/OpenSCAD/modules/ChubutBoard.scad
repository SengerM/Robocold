$fn = 50;

module Enclosure(x, y, z) {
    THICKNESS = .2;
    cube([x,THICKNESS,z]);
    cube([THICKNESS,y,z]);
    translate([0,y-THICKNESS,0]) cube([x,THICKNESS,z]);
    translate([x-THICKNESS,0,0]) cube([THICKNESS,y,z]);
}

module ChubutBoard() {
    translate([0,0,-.05]) color([0,.6,0]) difference() {
        cube([48, 39, 1.7]);
        translate([3,3,-1]) cylinder(d=3.25, h=3*1.7);
        translate([3,39-3,-1]) cylinder(d=3.25, h=3*1.7);
        translate([39-3,3,-1]) cylinder(d=3.25, h=3*1.7);
        translate([39-3,39-3,-1]) cylinder(d=3.25, h=3*1.7);
        translate([39/2,39/2,-1]) cylinder(d=1, h=3*1.7);
    }
    translate([0,6.8,0])
    for (i = [0,1,2]) {
        translate([48,i*26/2,0]) rotate(v=[0,1,0], a=90) cylinder(d=7, h=12);
    }
    color(.7*[1,1,1]) translate([(39-26)/2,(39-29)/2,1.7]) Enclosure(26,29,3);
//    translate([19.5,19.5,0]) rotate(a=90, v=[0,0,1]) import("../external_modules/chubut_board/chubut.stl");
}

ChubutBoard();

