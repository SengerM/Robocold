//
// Parametric NEMA 17 Stepper Motor
// https://www.thingiverse.com/thing:4322777

//
// Copyright 2020 Jon A. Cruz
//
// Parametric NEMA 17 Stepper Motor by Jon A. Cruz is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
//



epsilon = 0.01;

// Common lengths. Listed at https://reprap.org/wiki/NEMA_17_Stepper_motor
NEMA17_lengths = [
     34,
     36,
     40,
     42,
     47,
     48,
     60,
     ];

NEMA17_mat_metal = [.8, .8, .8];
NEMA17_mat_body = [.2, .2, .2];
NEMA17_mat_plastic = [.95, .95, .95];
NEMA17_mat_gold = [0.83, 0.67, 0.22];

//NEMA17_testNema17();
NEMA17_Stepper(h = 33.5, lores = false, colorize = true, show_screws = true, show_jst = true);


module NEMA17_testNema17()
{
     // Test one with many things turned on
     NEMA17_Stepper(h = 38, lores = false, colorize = true, show_screws = true, show_jst = true);

     // Next to one with all defaults
     translate([60, 0, 0])
       NEMA17_Stepper();
}

module NEMA17_Stepper(w = 0, h = 0, rotation = 0, lores = true, colorize = false, show_screws = false, show_jst = false)
{
     _w = (w > 42.3) ? 42.3 : ((w > 0) ? w : 42);
     _h = (h > 0) ? h : 34;
     
     _d2 = 8.6; // main hole for shaft
     _r2 = _d2 / 2;
     _d3 = 22; // Raised collar
     
     _shaft_d = 5;
     _shaft_l = 24;
     _notch_l = 15;
     _notch_d = .5;
     
     cut = 6 * cos(45);
     cut2 = 9 * cos(45);
     
     faces_sm = (lores) ? 8 : 12;
     faces_med = (lores) ? 10 : 16;
     faces_lrg = (lores) ? 12 : 24;

     metal = [[9.6, 0], [8, 1]];

     bottom_screw_depth = 1.5;


     color_shaft = (colorize) ? NEMA17_mat_metal : undef;
     color_casing = (colorize) ? NEMA17_mat_metal : undef;
     color_body = (colorize) ? NEMA17_mat_body : undef;
     color_plastic = (colorize) ? NEMA17_mat_plastic : undef;
     color_contact = (colorize) ? NEMA17_mat_gold : undef;

     translate([0, 0, -_h])
     {
          // Shaft
          rotate([0, 0, rotation])
               color(color_shaft)
               difference()
          {
               translate([0, 0, 2.5])
                    cylinder(d = _shaft_d, h = _h - 2.5 + _shaft_l, $fn = faces_med);
               translate([_shaft_d / 2 - _notch_d, -_shaft_d / 2 - epsilon, _h + _shaft_l - _notch_l + epsilon])
                    cube([_notch_d + epsilon, _shaft_d + 2 * epsilon, _notch_l + epsilon]);
          }

          // Collar
          translate([0, 0, _h])
               color(color_casing)
               difference()
          {
               cylinder(d = _d3, h = 1, $fn = faces_lrg);
               translate([0, 0, epsilon])
                    cylinder(d = _d2, h = 1 + 2 * epsilon, $fn = faces_lrg);
          }

          difference()
          {
               union()
               {
                    color(color_casing)
                         for (bands = metal)
                         {
                              translate([0, 0, (bands[1] > 0) ? _h - bands[0] : 0 ])
                                   NEMA17_layer(w = _w, h = bands[0], cut = cut, lores = lores);
                         }

                    color(color_body)
                         translate([0, 0, metal[0][0]])
                    {
                         NEMA17_layer(w = _w, h = _h - metal[0][0] - metal[1][0], cut = cut2, lores = lores, rounded = true);
                    }
               }
               union()
               {
                    // through holes for visibility
                    for (x = [-31/2, 31/2])
                    {
                         for (y = [-31/2, 31/2])
                         {
                              translate([x, y, -epsilon])
                                   cylinder(d = 2, h = _h + 2 * epsilon, $fn = faces_sm);
                         }
                    }

                    // Top M3 screw holes
                    for (x = [-31/2, 31/2])
                    {
                         for (y = [-31/2, 31/2])
                         {
                              translate([x, y, _h - 4.5 + epsilon])
                                   cylinder(d = 3, h = 4.5 + epsilon, $fn = faces_sm);
                         }
                    }

                    // Bottom philips screws
                    for (x = [-31/2, 31/2])
                    {
                         for (y = [-31/2, 31/2])
                         {
                              translate([x, y, - epsilon])
                                   cylinder(d = 6, h = bottom_screw_depth + epsilon, $fn = faces_med);
                         }
                    }

                    // Bottom shaft opening
                    translate([0, 0, -epsilon])
                         cylinder(d = _d2, h = 3 + epsilon, $fn = faces_med);

               }
          }

          if (show_screws)
          {
               color(color_casing)
                    for (x = [-31/2, 31/2])
                    {
                         for (y = [-31/2, 31/2])
                         {
                              translate([x, y, bottom_screw_depth])
                              {
                                   mirror([0, 0, 1])
                                        intersection()
                                   {
                                        translate([-6/2, -6/2, 0])
                                             cube([6, 6, bottom_screw_depth - epsilon]);

                                        difference()
                                        {
                                             slotw = .75;
                                             scale([1, 1, 1/2])
                                                  sphere(d = 6 - .25, $fn = faces_sm);
                                             union()
                                             {
                                                  translate([-slotw / 2, -7/2, .5])
                                                       cube([slotw, 7, 1]);
                                                  translate([-7/2, -slotw / 2, .5])
                                                       cube([7, slotw, 1]);
                                             }
                                        }
                                   }
                              }
                         }
                    }
          }

          if (show_jst)
          {
               ow = 16;
               oh = 4.5;
               iw = ow - 2;
               ih = oh - 2;

               bw = (6 - 2) * 2;
               translate([_w / 2 - 1, -16/2, 0])
                    color(color_casing)
                    cube([4.2 + 1, 16, 3]);

               if (!lores)
               {
                    color(color_contact)
                         for (i = [0:5])
                         {
                              translate([_w / 2, -5 + i * 2, 3 + .5 + 1.7])
                                   cube([6, .5, .5]);
                         }
               }
               
               difference()
               {
                    translate([_w / 2 - 1, -ow/2, 3])
                         color(color_plastic)
                         cube([6.5 + 1, 16, 4.5]);
                    union()
                    {
                         translate([_w / 2 - 1, -iw/2, 3 + (ow - iw) / 2])
                              cube([6.5 + 1 + epsilon, iw, ih]);
                         translate([_w / 2 - 1, -bw/2, 3 + oh - ih + epsilon])
                              cube([6.5 + 1 + epsilon, bw, ih]);
                    }
               }
          }
     }
}

module NEMA17_layer(w = 0, h = 0, cut = -1, lores = true, rounded = false)
{
     _w = (w > 42.3) ? 42.3 : ((w > 0) ? w : 42);
     _h = (h > 0) ? h : 34;
     _cut = (cut >= 0) ? cut : 0;

     if (lores)
     {
          linear_extrude(height = _h, convexity = 10)
          {
               polygon(points = (rounded) ? NEMA17_cutcorners2(_w, _h, _cut) : NEMA17_cutcorners(_w, _h, _cut));
          }
     }
     else
     {
          hull()
          {
               for (where = [[.5, 0, .5], [_h - 1, .5, 0], [.5, _h - .5, .5]])
               {
                    translate([0, 0, where[1]])
                         linear_extrude(height = where[0], convexity = 10)
                    {
                         offset(delta = -where[2])
                         {
                              polygon(points = (rounded) ? NEMA17_cutcorners2(_w, _h, _cut) : NEMA17_cutcorners(_w, _h, _cut));
                         }
                    }
               }
          }
     }
}

function NEMA17_cutcorners(w = 0, h = 0, cut = 0) =
     let(_w = (w > 42.3) ? 42.3 : ((w > 0) ? w : 42),
         _h = (h > 0) ? h : 34,
         _cut = (cut >= 0) ? cut : 0
          ) [
               [_w/2 - _cut, _w/2],
               [_w/2, _w/2 - _cut],
               //
               [_w/2, -_w/2 + _cut],
               [_w/2 - _cut, -_w/2],
               //
               [-_w/2 + _cut, -_w/2],
               [-_w/2, -_w/2 + _cut],
               //
               [-_w/2, _w/2 - _cut],
               [-_w/2 + _cut, _w/2],
               ];

function NEMA17_cutcorners2(w = 0, h = 0, cut = 0) =
     let(_w = (w > 42.3) ? 42.3 : ((w > 0) ? w : 42),
         _h = (h > 0) ? h : 34,
         _cut = (cut >= 0) ? cut : 0,
         _bit = .5,
         _bit2 = _bit / cos(45)
          ) [
               [_w/2 - _cut - _bit2, _w/2],
               [_w/2 - _cut + _bit, _w/2 - _bit],

               [_w/2 - _bit, _w/2 - _cut + _bit],
               [_w/2, _w/2 - _cut - _bit2],
               //
               [_w/2, -_w/2 + _cut + _bit2],
               [_w/2 - _bit, -_w/2 + _cut - _bit],

               [_w/2 - _cut + _bit, -_w/2 + _bit],
               [_w/2 - _cut - _bit2, -_w/2],
               //
               [-_w/2 + _cut + _bit2, -_w/2],
               [-_w/2 + _cut - _bit, -_w/2 + _bit],

               [-_w/2 + _bit, -_w/2 + _cut - _bit],
               [-_w/2, -_w/2 + _cut + _bit2],
               //
               [-_w/2, _w/2 - _cut - _bit2],
               [-_w/2 + _bit, _w/2 - _cut + _bit],

               [-_w/2 + _cut - _bit, _w/2 - _bit],
               [-_w/2 + _cut + _bit2, _w/2],
               ];
