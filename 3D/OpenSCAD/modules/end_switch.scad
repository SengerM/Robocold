use <../external_modules/produced_at_the_workshop/produced_at_the_workshop.scad>

$fn = 11;

// Values taken from Igus datasheet ------
E1 = 19;
E2 = 25;
E3 = 35;
AL = 45;
LB = 6.5;
SG = 3;
D = 17;
NOT_IN_DATSHEET = 3.5;
// ---------------------------------------

COLOR_METAL_GRAY = .8*[1,1,1];

module MS0850505F065C1A() {
    // https://www.digikey.ch/en/products/detail/e-switch/MS0850505F065C1A/2720255
    color(.5*[1,1,1]) difference() {
        cube([19.8,6.4,10.6]);
        for (x = [0, 9.5]) {
            translate([x+5.15,6.4*(2-1/3),2.9]) rotate(a=90,v=[1,0,0]) cylinder(d=2.5,h=6.4*2);
        }
    }
    color(COLOR_METAL_GRAY) for (x = [0,8.8,8.8+7.3]) {
        translate([x+(19.8-8.8-7.3)/2-.6/2,(6.4-2.8)/2,-7.85]) cube([.6,2.8,7.85]);
    }
    for (pt = [0,3]) {
        translate([5.15+14.5,(6.4-2.8)/2,14.9+pt]) rotate(a=-90, v=[1,0,0]) cylinder(d=3,h=2.8);
    }
}

module MS0850505F065C1A_holder(draw_end_switch=false) {
    if (draw_end_switch) {
        translate([0,10,-22]) rotate(a=-90,v=[1,0,0]) rotate(a=-90,v=[0,0,1]) MS0850505F065C1A();
    }
    difference() {
        translate([0,-1,-25]) cube([11,18,20+5+10]);
        translate([-6,-8,-23]) cube([9,18,22]);
        translate([-6,-13,-23]) cube([13,18,22]);
        translate([0,10,-22]) rotate(a=-90,v=[1,0,0]) rotate(a=-90,v=[0,0,1]) minkowski() {
            MS0850505F065C1A();
            sphere(d=.5);
        }
    }
    difference() {
        translate([-33,-1,0]) cube([33,18,10]);
        for (i = [0,19]) {
            translate([-6.5-i,6.5,-1]) cylinder(d=3.5,h=10+2);
            translate([-6.5-i,6.5,10-3]) cylinder(d=9,h=4);
        }
    }
}

module piece_for_the_car() {
    difference() {
        translate([0,-E2-2*LB-10,0]) cube([AL,E2+2*LB+10,2]);
        translate([(AL-E3)/2,-NOT_IN_DATSHEET,-1]) for (ix=[0,1]) {
            for (iy=[0,1]) {
                translate([ix*E3,-iy*E2,0]) cylinder(d=SG*1.1,h=4);
            }
        }
    }
    translate([0,0,-15+2]) cube([AL,10,15]);
}

//translate([-3,-222-12,45]) MS0850505F065C1A_holder(
//    draw_end_switch = true
//);
//translate([-3,166-12+1,45]) mirror([0,1,0]) MS0850505F065C1A_holder(
//    draw_end_switch = false
//);

//color([.5,.5,1]) produced_at_the_workshop();
translate([-24,-10.5,84]) piece_for_the_car();