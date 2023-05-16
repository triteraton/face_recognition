$fs=0.5;
$fa=6;

// Type of model 
TYPE = "preview"; // [preview, front, back, standoff]

// Create some example cutouts. See module cutouts()
CREATE_CUTOUTS = true; // [true, false]

//M3 hole
M3_HOLE_DIA = 3.8;
//M3 hole for tapping
M3_TAP_DIA = 2.8;

// Front panel width
FRONT_OUTER_WIDTH = 120;
// Front panel height
FRONT_OUTER_HEIGHT = 80;
// Diameter of rounded front edges
FRONT_EDGE_DIA = 8;
// Thickness of front panel
FRONT_THICKNESS = 3;

// length of front mount holes (M3, for tapping)
FRONT_MOUNT_LENGTH = 30;

// Top length (from front to edge)
TOP_LENGTH = 30;
// Bottom length (from front to back)
BOTTOM_LENGTH = 90;
// Angle of front panel
FRONT_ANGLE=65;

// Thickness of case walls
WALL_THICKNESS = 3;

// Width of LCD cutout
LCD_CUTOUT_WIDTH =98;
// Height of LCD cutout
LCD_CUTOUT_HEIGHT = 40;

// LCD PCB height
LCD_BASE_HEIGHT = 60.1;
// LCD PCB width
LCD_BASE_WIDTH = 98.3;
// LCD mounting holes diameter
LCD_BASE_HOLE_DIA = M3_HOLE_DIA;
// Distance LCD mounting holes (long side, center to center)
LCD_BASE_HOLE_X = 93;
// Distance LCD mounting holes (short side, center to center)
LCD_BASE_HOLE_Y = 55;
// Distance LCD front to PCB
LCD_THICKNESS = 9.6;


module top_hole()
{
  TH_X = 2.9;
  TH_Y = 10.1;
  TH_X_OFF = (57/2)-4.3+TH_X + FRONT_OUTER_WIDTH/2;
  TH_Y_OFF = TOP_LENGTH/2 - TH_Y/2;

  TOP_HOLE=[
   [TH_X_OFF, TH_Y_OFF],
   [TH_X_OFF+TH_X, TH_Y_OFF], 
   [TH_X_OFF+TH_X, TH_Y_OFF+TH_Y],
   [TH_X_OFF, TH_Y_OFF + TH_Y]
  ];  //57 4.3


  translate([0,FRONT_OUTER_HEIGHT+0.01,0])rotate([90,0,0])linear_extrude(3*WALL_THICKNESS) polygon(TOP_HOLE);
  
}

module side_hole()
{
  translate([0,FRONT_OUTER_HEIGHT/2,TOP_LENGTH*2/3])rotate([0,90,0])cylinder(d=26.2, h=9);
  
}

function sinr(x) = sin(180 * x / PI);
function cosr(x) = cos(180 * x / PI);

module 2dflower(n, dia, fDia)
{
  r = dia/2;
  
  delta = (2*PI)/n;
  
  circle(d=fDia);
  
  for (step = [0:n-1]) {
    translate([r * cosr(step*delta), r * sinr(step*delta), 0])
      circle(d=fDia); 
  }
  
}

module sound_hole()
{
  B = BOTTOM_LENGTH;
  Z = B * sin(FRONT_ANGLE);
  Y = B * cos(FRONT_ANGLE);
 
  G = Z-TOP_LENGTH;
  A = (FRONT_OUTER_HEIGHT-Y);
  res = atan(G/A );
  
  res2 = 180-90-res;
  
  translate([FRONT_OUTER_WIDTH/2,Y+(FRONT_OUTER_HEIGHT-Y)/2,TOP_LENGTH+(Z-TOP_LENGTH)/2]) 
  
  rotate([-90+res2,0,0]) {
    //cylinder(d=5, h=Z+1);
    translate([0,0,-WALL_THICKNESS*2])linear_extrude(WALL_THICKNESS*4) 2dflower(7, 22, 3);
    
  }
  
}


module back_hole()
{
  B = BOTTOM_LENGTH;
  Z = B * sin(FRONT_ANGLE);
  Y = B * cos(FRONT_ANGLE);
  W=11.2;
  H = 6.5;
  
  hull() {
    translate([FRONT_OUTER_WIDTH/2-W/2+H/2,Y,0])cylinder(d=H, h=Z+1);
    translate([FRONT_OUTER_WIDTH/2+W/2-H/2,Y,0])cylinder(d=H, h=Z+1);
  }
  
}

module front_base()
{
  H = FRONT_EDGE_DIA / 2;
  hull()
  {
    translate([H,H,0]) circle(d=FRONT_EDGE_DIA);
    translate([FRONT_OUTER_WIDTH-H,H,0]) circle(d=FRONT_EDGE_DIA);
    translate([FRONT_OUTER_WIDTH-H,FRONT_OUTER_HEIGHT-H,0]) circle(d=FRONT_EDGE_DIA);
    translate([H,FRONT_OUTER_HEIGHT-H,0]) circle(d=FRONT_EDGE_DIA);
  }
  
}

module front_mount_holes(D = M3_TAP_DIA)
{
    
  module h()
  {
    circle(d=D);
  }
  
  X = WALL_THICKNESS + (M3_TAP_DIA/2);
  Y = FRONT_OUTER_HEIGHT / 3;
  
  X_OFF = (FRONT_OUTER_WIDTH -X);
  Y_OFF = (FRONT_OUTER_HEIGHT - Y);
  
  translate([X, Y]) h();  
  translate([X_OFF, Y])h();  
  translate([X, Y_OFF ])h();  
  translate([X_OFF, Y_OFF ])h();  
}

module front_mount_tap_holes()
{
  D = M3_TAP_DIA * 3;
  linear_extrude(FRONT_MOUNT_LENGTH)
  difference() {
    front_mount_holes(D);
    front_mount_holes(); 
  }
}

module lcd_mount_holes(dia=LCD_BASE_HOLE_DIA)
{
  X_OFF = (LCD_BASE_WIDTH - LCD_BASE_HOLE_X) / 2;
  Y_OFF = (LCD_BASE_HEIGHT - LCD_BASE_HOLE_Y) / 2;
  X = LCD_BASE_HOLE_X;
  Y = LCD_BASE_HOLE_Y;
  
  translate([X_OFF, Y_OFF])circle(d=dia);  
  translate([X_OFF + X, Y_OFF])circle(d=dia);  
  translate([X_OFF + X, Y_OFF + Y])circle(d=dia);  
  translate([X_OFF, Y_OFF + Y])circle(d=dia);  
}

module lcd_dummy()
{
  PCB_THICKNESS = 2;
  
  difference() {
    union() {
      //pcb
      translate([0,0,-PCB_THICKNESS]) cube([LCD_BASE_WIDTH, LCD_BASE_HEIGHT, PCB_THICKNESS]);
      
      //LCD
      translate([ (LCD_BASE_WIDTH-LCD_CUTOUT_WIDTH)/2, (LCD_BASE_HEIGHT-LCD_CUTOUT_HEIGHT)/2,0]) 
        cube([LCD_CUTOUT_WIDTH, LCD_CUTOUT_HEIGHT, LCD_THICKNESS]);
    }
    translate([0,0,-2*PCB_THICKNESS])linear_extrude(3*PCB_THICKNESS) lcd_mount_holes(); 
  }  
}

module stand_off()
{
  linear_extrude(LCD_THICKNESS-FRONT_THICKNESS)
    difference()
    {
      circle(d=2*LCD_BASE_HOLE_DIA);
      circle(d=LCD_BASE_HOLE_DIA);
    }
}

module front_plate()
{
  X_OFF = (FRONT_OUTER_WIDTH - LCD_BASE_WIDTH)/2;
  Y_OFF = (FRONT_OUTER_HEIGHT - LCD_BASE_HEIGHT)/2;
  
  difference() {
    linear_extrude(FRONT_THICKNESS) front_base();  
    translate([X_OFF, Y_OFF,-0.01])  union() {
      lcd_dummy();
      linear_extrude(2*FRONT_THICKNESS) lcd_mount_holes();
    }
    translate([0,0,-0.01])
      linear_extrude(2*FRONT_THICKNESS) front_mount_holes(M3_HOLE_DIA);
  }
        
}

module side_profile()
{
  B = BOTTOM_LENGTH;
  Z = B * sin(FRONT_ANGLE);
  Y = B * cos(FRONT_ANGLE);
  
  
  polygon([[0,0],[Y,Z],[FRONT_OUTER_HEIGHT, TOP_LENGTH],[FRONT_OUTER_HEIGHT,0]]);
}

module side_block()
{
  rotate([0,90,0]) rotate([0,0,90]) 
  linear_extrude(FRONT_OUTER_WIDTH) 
  side_profile();
}

module inner_block()
{
  FACTOR = (100.0 - (100.0/FRONT_OUTER_HEIGHT * (2*WALL_THICKNESS)))/100.0;
  translate([WALL_THICKNESS,0,-0.01])
    rotate([0,90,0]) rotate([0,0,90]) 
      linear_extrude(FRONT_OUTER_WIDTH - 2*WALL_THICKNESS) 
        translate([WALL_THICKNESS,0,0])
          scale([FACTOR,FACTOR])side_profile();
  
}


module cutouts()
{
  top_hole();
  back_hole();
  sound_hole();
}

module back() {
  intersection() {
    linear_extrude(2*BOTTOM_LENGTH) front_base();
    difference() {
      side_block();
      inner_block();
      if (CREATE_CUTOUTS) {
        cutouts();
      }
    }
  }
  front_mount_tap_holes();
}


if (TYPE == "preview") {
  back();
  Z = -4*FRONT_THICKNESS;
  
  translate([0,0, Z]) front_plate(); 
  translate([FRONT_OUTER_WIDTH/2, FRONT_OUTER_HEIGHT/2,0])
    rotate([0,180,0])translate([-LCD_BASE_WIDTH/2,-LCD_BASE_HEIGHT/2,0]) %lcd_dummy(); 
} else if (TYPE == "front") {
  front_plate();  
} else if (TYPE == "back") {
  back();    
} else if (TYPE == "standoff") {
  stand_off();      
}

