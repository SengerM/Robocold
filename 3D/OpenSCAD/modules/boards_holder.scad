HOLDER_LENGTH = 520;

module column() {
    difference() {
        color([1,1,1]*.5) cube([88,26,170+5]);
        translate([88/2,26/2,170+5-55]) cylinder(d=8,h=55);
        translate([88/4,26/2,-1]) cylinder(d=5,h=12);
        translate([88/4*3,26/2,-1]) cylinder(d=5,h=12);
    }
}

module L_profil_1() {
    module perfil_L(L1, L2, length, thickness=2) {
        cube([length, L1+1, thickness]);
        cube([length,thickness,L2+1]);
    }
    difference() {
        perfil_L(8,8, length=HOLDER_LENGTH);
        translate([81,0,2]) for (i=[0:7]) {
            translate([i*41,4,4]) rotate(a=90,v=[1,0,0]) color("red") cylinder(d=3, h=2*3);
            translate([i*41+33,4,4]) rotate(a=90,v=[1,0,0]) color("red") cylinder(d=3, h=2*3);
        }
    }
}
module L_profil_2() {
    module perfil_L(L1, L2, length, thickness=2) {
        cube([length, L1+1, thickness]);
        cube([length,thickness,L2+1]);
    }
    difference() {
        perfil_L(8,8, length=HOLDER_LENGTH);
        translate([119,0,2]) for (i=[0:7]) {
            translate([i*41,4,4]) rotate(a=90,v=[1,0,0]) color("red") cylinder(d=3, h=2*3);
            translate([i*41+33,4,4]) rotate(a=90,v=[1,0,0]) color("red") cylinder(d=3, h=2*3);
        }
    }
}

module boards_holder() {
    translate([63.5,-26,198]) {
        translate([-21-1.7,0,0]) rotate(a=270, v=[0,-1,0]) rotate(a=90, v=[0,0,1]) L_profil_1();
        translate([21+1.7,0,0]) translate([0,HOLDER_LENGTH,0]) rotate(a=180, v=[0,0,1]) rotate(a=270, v=[0,-1,0]) rotate(a=90, v=[0,0,1]) L_profil_2();
        translate([-21,0,-2]) cube([42,22,2]);
        translate([-21,HOLDER_LENGTH-22,-2]) cube([42,22,2]);
    }
    translate([20,-28,-5]) color([1,1,1]*.5) column();
    translate([20,HOLDER_LENGTH-55+5,-5]) column();
    
    color([.5,.3,.3]) {
        translate([64,-15,144]) cylinder(d=8,h=80);
        translate([64,-15*2-7+HOLDER_LENGTH,144]) cylinder(d=8,h=80);
    }
}

module main_base() {
    difference() {
        translate([-44,-28,-5-5]) color([.5,1,.5]) cube([222,524,5]);
        translate([20,-28,-5-5]) {
            translate([88/4,26/2,-1]) cylinder(d=5,h=12);
            translate([88/4*3,26/2,-1]) cylinder(d=5,h=12);
        }
        translate([20,HOLDER_LENGTH-55+5,-5-5]) {
            translate([88/4,26/2,-1]) cylinder(d=5,h=12);
            translate([88/4*3,26/2,-1]) cylinder(d=5,h=12);
        }
    }
    
}

module boards_holder_with_main_base() {
    boards_holder();
    main_base();
}

boards_holder_with_main_base();