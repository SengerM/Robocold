use <PhotonisPMT.scad>

$fn = 88;

PMT_HEIGHT = 100;
WALL_THICKNESS = 9;
BASE_THICKNESS = 11;
TOP_SCREWS_DIAMETER = 2;
CAP_WALL_THICKNESS = 5;
X_OFFSET_FROM_SCREWS_IN_THE_BASE_FOR_TRIMMING = 11;
AIR_GAP_CAP_BASE = .2; // Silvan told me to add this gap.

module PMT_holding_piece(E2=25, E3=35, screws_diameter=3) {
	difference() { // Trimming excess.
		difference() {
			union() {
				translate([E3/2, E2/2, 0]) cylinder(d=43+2*WALL_THICKNESS, h=BASE_THICKNESS+PMT_HEIGHT+55-14.5);
				translate([E3/2, E2/2, 0]) cylinder(d=2*CAP_WALL_THICKNESS+43+2*WALL_THICKNESS, h=BASE_THICKNESS+PMT_HEIGHT+55-14.5-5);
			}
			translate([E3/2, E2/2, PMT_HEIGHT+BASE_THICKNESS]) cylinder(d=43, h=999);
			translate([E3/2, E2/2, BASE_THICKNESS]) cylinder(d=38, h=999);
			translate([-999/2, E2/2-(15+2*10)/2, BASE_THICKNESS]) cube([999, 15+2*10, 999]);
			translate([0,0,-1]) {// Holes for screws in the base.
				cylinder(d=screws_diameter, h=999);
				translate([E3,0,0]) cylinder(d=screws_diameter, h=999);
				translate([0,E2,0]) cylinder(d=screws_diameter, h=999);
				translate([E3,E2,0]) cylinder(d=screws_diameter, h=999);
			}
			{// Holes for screws for the top piece.
				translate([E3/2, E2/2-(43+2*WALL_THICKNESS-WALL_THICKNESS)/2,BASE_THICKNESS+PMT_HEIGHT+55-14.5-33]) cylinder(d=TOP_SCREWS_DIAMETER*.9, h=999);
				translate([E3/2, E2/2+(43+2*WALL_THICKNESS-WALL_THICKNESS)/2,BASE_THICKNESS+PMT_HEIGHT+55-14.5-33]) cylinder(d=TOP_SCREWS_DIAMETER*.9, h=999);
			}
		}
		translate([E3+X_OFFSET_FROM_SCREWS_IN_THE_BASE_FOR_TRIMMING,0,0]) translate(999/2*[0,-1,-1]) cube([999,999,999]);
		translate([-X_OFFSET_FROM_SCREWS_IN_THE_BASE_FOR_TRIMMING,0,0]) rotate(a=180, v=[0,0,1]) translate(999/2*[0,-1,-1]) cube([999,999,999]);
//		translate([0,-5+E2-4,BASE_THICKNESS-1]) {
//			linear_extrude(2) { 
//				text("Photonis", size=5);
//				translate([0,-6,0]) text("MCP-PMT", size=5);
//				translate([0,2*-6,0]) text("holder", size=5);
//			}
//		}
	}
}

module PMT_holding_cap(E2=25, E3=35) {
	difference() { // Trimming excess.
		difference() {
			translate([E3/2, E2/2, PMT_HEIGHT+BASE_THICKNESS+55-14.5-5]) cylinder(d=2*CAP_WALL_THICKNESS+43+2*WALL_THICKNESS, h=10);
			translate([E3/2, E2/2, PMT_HEIGHT+BASE_THICKNESS+55-14.5-10-1]) cylinder(d=39, h=999);
			translate([E3/2, E2/2, PMT_HEIGHT+BASE_THICKNESS+55-14.5]) rotate(a=180, v=[1,0,0]) cylinder(d=43+2*WALL_THICKNESS+AIR_GAP_CAP_BASE, h=999);
			{// Holes for screws for the top piece.
				translate([E3/2, E2/2-(43+2*WALL_THICKNESS-WALL_THICKNESS)/2,BASE_THICKNESS+PMT_HEIGHT+55-14.5-33]) cylinder(d=TOP_SCREWS_DIAMETER*1.2, h=999);
				translate([E3/2, E2/2+(43+2*WALL_THICKNESS-WALL_THICKNESS)/2,BASE_THICKNESS+PMT_HEIGHT+55-14.5-33]) cylinder(d=TOP_SCREWS_DIAMETER*1.2, h=999);
			}
		}
		translate([E3+X_OFFSET_FROM_SCREWS_IN_THE_BASE_FOR_TRIMMING,0,0]) translate(999/2*[0,-1,-1]) cube([999,999,999]);
		translate([-X_OFFSET_FROM_SCREWS_IN_THE_BASE_FOR_TRIMMING,0,0]) rotate(a=180, v=[0,0,1]) translate(999/2*[0,-1,-1]) cube([999,999,999]);
	}
}

A  = 58;
AL = 45;
AS = 16;
E2 = 25;
E3 = 35;
//translate([E3, E2, 0]) rotate(a=180, v=[0,0,1]) translate([-(AL-E3)/2,-AS+A-3.5,-30/2]) rotate(a=90, v=[1,0,0]) import("../external_modules/igus_linear_stages/SLT-BB-0415-ER-S0030RG-55-(0).stl");
translate([E3/2, E2/2, PMT_HEIGHT+BASE_THICKNESS]) rotate(a=90, v=[0,0,1]) PhotonisPMT();
color("red") PMT_holding_cap();
!PMT_holding_piece();
