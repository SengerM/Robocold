use <../external_modules/NEMA_17/files/nema17.scad>

$fn=50;
BASE_THICKNESS = 4;
// Values taken from the datasheet of the stages ---
AS = 16;
LB = 6.5;
LT = 22;
E1 = 19;
E2 = 25;
E3 = 35;
A = 58;
// -------------------------------------------------

module short_stage_with_motor(stage_color="gray") {
	rotate(a=90, v=[0,0,1]) rotate(a=90, v=[1,0,0]) color(stage_color) import("../external_modules/igus_linear_stages/SLT-BB-0415-ER-S0030RG-55-(27.5).stl");
	translate([0,55+45+22+17+24+1,0]) rotate(a=90, v=[1,0,0]) NEMA17_Stepper(h = 33.5, lores = false, colorize = true, show_screws = true, show_jst = true);
}

module long_stage_with_motor(stage_color="gray") {
	rotate(a=90, v=[0,0,1]) rotate(a=90, v=[1,0,0]) color(stage_color) import("../external_modules/igus_linear_stages/SLT-BB-0415-ER-S0030RG-300-(0).stl");
	translate([0,300+45+22+17+24+1,0]) rotate(a=90, v=[1,0,0]) NEMA17_Stepper(h = 33.5, lores = false, colorize = true, show_screws = true, show_jst = true);
}

module stage_base(stage_length, drill_holes_for_mounting_in_another_stage=false) {
    module stages_drill_holes() {
        cylinder(d=3, h=3*BASE_THICKNESS);
        translate([E2,0,0]) cylinder(d=3, h=3*BASE_THICKNESS);
        translate([0,E3,0]) cylinder(d=3, h=3*BASE_THICKNESS);
        translate([E2,E3,0]) cylinder(d=3, h=3*BASE_THICKNESS);
    }
    difference() {
        translate([-16-2-4,-22,-30/2-BASE_THICKNESS-6]) cube([64, stage_length+2*22+45+17+1+24,BASE_THICKNESS]);
        translate([-AS+A-LB,-LT+LB,-30/2-2*BASE_THICKNESS-6]) cylinder(d=5,h=3*BASE_THICKNESS);
        translate([-AS+A-LB-E1,-LT+LB,-30/2-2*BASE_THICKNESS-6]) cylinder(d=5,h=3*BASE_THICKNESS);
        translate([-AS+A-LB,stage_length+45+LT-LB,-30/2-2*BASE_THICKNESS-6]) cylinder(d=5,h=3*BASE_THICKNESS);
        translate([-AS+A-LB-E1,stage_length+45+LT-LB,-30/2-2*BASE_THICKNESS-6]) cylinder(d=5,h=3*BASE_THICKNESS);
        if (drill_holes_for_mounting_in_another_stage) {
            translate([27,55,-30/2-2*BASE_THICKNESS-6]) rotate(a=90, v=[0,0,1]) stages_drill_holes();
        }
    }
    difference() {
        translate([-16-2-4,stage_length+22+45+17+1+24-BASE_THICKNESS,-30/2-6]) cube([64,BASE_THICKNESS,44]);
        hull() {
            translate([0,stage_length+22+45+17+1+24+BASE_THICKNESS,0]) rotate(a=90, v=[1,0,0]) cylinder(d=23, h=3*BASE_THICKNESS);
            translate([0,stage_length+22+45+17+1+24+BASE_THICKNESS,33]) rotate(a=90, v=[1,0,0]) cylinder(d=23, h=3*BASE_THICKNESS);
        }
        translate([0,0,-5]) {
            hull() {
                translate([31/2,stage_length+22+45+17+1+24+BASE_THICKNESS,31/2]) rotate(a=90, v=[1,0,0]) cylinder(d=4, h=3*BASE_THICKNESS);
                translate([31/2,stage_length+22+45+17+1+24+BASE_THICKNESS,31/2+33]) rotate(a=90, v=[1,0,0]) cylinder(d=4, h=3*BASE_THICKNESS);
            }
            hull() {
                translate([-31/2,stage_length+22+45+17+1+24+BASE_THICKNESS,31/2]) rotate(a=90, v=[1,0,0]) cylinder(d=4, h=3*BASE_THICKNESS);
                translate([-31/2,stage_length+22+45+17+1+24+BASE_THICKNESS,31/2+33]) rotate(a=90, v=[1,0,0]) cylinder(d=4, h=3*BASE_THICKNESS);
            }
        }
    }
}

module piece_to_give_the_correct_height_to_the_stages_in_the_base() {
    difference() {
        color([.4,.1,.1]) cube([64,22,6]);
        translate([64-LB,LB,-6]) cylinder(d=5, h=6*3);
        translate([64-LB-E1,LB,-6]) cylinder(d=5, h=6*3);
    }
}

module piece_to_couple_motor_to_stage() {
    difference() {
        cylinder(d=20, h=18+18);
        cylinder(d=12, h=18);
        translate([0,0,18]) cylinder(d=5.1, h=18);
    }
}

module stage_complete_module(stage_length=55) {
    if (stage_length==55) {
        short_stage_with_motor();
    } else if (stage_length==300) {
        long_stage_with_motor();
    }
    translate([0,stage_length+22+45+1,0]) rotate(a=-90,v=[1,0,0]) piece_to_couple_motor_to_stage();
    color([.3,.5,.3]) stage_base(stage_length=stage_length, drill_holes_for_mounting_in_another_stage= stage_length==55? true : false);
    translate([-16-2-4,-22,-6-30/2]) piece_to_give_the_correct_height_to_the_stages_in_the_base();
    translate([-16-2-4,45+stage_length+22,-30/2]) rotate(a=180, v=[1,0,0]) piece_to_give_the_correct_height_to_the_stages_in_the_base();
}

module the_two_stages_mounted() {
    translate([30/2+7,22,30/2+6+BASE_THICKNESS]) {
        stage_complete_module(300);
        translate([93.5,13,30+6+BASE_THICKNESS+1]) rotate(a=90, v=[0,0,1]) stage_complete_module(55);
    }
}

the_two_stages_mounted();