use <modules/BetaSource.scad>
use <modules/ChubutBoard.scad>
use <modules/PhotonisPMT.scad>
use <modules/PMT_holding_piece.scad>
use <modules/stages.scad>
use <modules/boards_holder.scad>

$fn = 55;
//$vpr = [77, 0, 90+22*sin(360*$t)]; // This is for animation. See https://blog.prusaprinters.org/how-to-animate-models-in-openscad_29523/

module climate_chamber_volume() {
	color([.9,.9,.9,.8]) difference() {
        translate([-1,-1,-1]) cube([330, 542, 602]);
        cube([330, 540, 600]);
    }
}

module eight_chubut_boards() {
    for (i = [0:7]) {
        translate([0,i*41,0]) translate([0,39,1.7+3]) rotate(v=[1,0,0], a=180) ChubutBoard();
    }
}


////////////////////////////////////////////////////////////////////////
SOURCE_POSITION = 0;

the_two_stages_mounted();
translate([159-111,80-22,82]) {
    color([.4,.4,1]) PMT_holding_piece();
    color([.4,.4,1]) PMT_holding_cap();
    translate([35/2, 25/2, 44+11]) rotate(a=90, v=[0,0,1]) PhotonisPMT();
}
translate([44,52,193]) eight_chubut_boards();

boards_holder_with_main_base();
translate([-99,-33,-10]) climate_chamber_volume();
