// Photosphere phone holder. Experimental. Quick'n dirty for now.
// CC-BY-SA <h.zeller@acm.org>
//--

$fs=0.2;
$fa=1;

epsilon=0.1;
slack=0.3;

phone_inner=11.3;  // inner thickness.
phone_outer=7;     // outer frame is thinner.
phone_wide=65 + slack;
phone_lens_radius=12/2;
cam_center=21;
phone_hood=cam_center+1;
phone_holder_thick=1;

mechanic_thick=2;
gear_tooth_depth=4;

leg_high=16;
leg_width=3;
nut_high=6;
nut_dia=12.5 + 2*slack;
nut_mount_dia=nut_dia + 4;
thread_drill=6.2 + 2*slack;
thread_mount_dia=nut_dia+3;
thread_stud_len=25;

holder_mount_width=phone_wide + 20;
holder_mount_back=-30;

tripod_mount_width=holder_mount_width + 120;
tripod_mount_side_back=-50;
tripod_mount_back=holder_mount_back - 90;
tripod_foot_dia=thread_mount_dia+4;
tripod_foot_thick=leg_high-6;

tripod_holder_distance=270;

phone_above_holder=50;

module phone(rim=0,extra_height=0) {
    hull() {
	translate([-cam_center, -phone_wide/2 - rim, 0]) cube([phone_hood + extra_height, phone_wide + 2 * rim, phone_outer]);
	translate([-cam_center, -phone_wide/4 - rim, 0]) cube([phone_hood + extra_height, phone_wide/2 + 2 * rim, phone_inner]);
    }
}

module camera_cone(distance=300) {
    fraction = distance/1000;
    hull() {
	rotate([-90,0,0]) cylinder(r=1.5, h=1);
	translate([0,fraction * 1000,0]) cube([fraction*692,1,fraction*1230], center=true);
    }
}

module bushing_drill(thick=8,hole=thread_drill,wall=3) {
    translate([0,0,-epsilon]) cylinder(r=thread_drill/2,h=thick+2*epsilon);
}

module bushing(thick=8,hole=thread_drill,wall=3) {
    difference() {
	cylinder(r=(thread_drill/2)+wall,h=thick);
	bushing_drill();
    }
}

// Phone holder, centered around lens.
module phone_base(rim=phone_holder_thick) {
    difference() {
	union(){
	    translate([-rim, 0, rim]) phone(rim);
	    hull() {
		translate([0,-phone_wide/2,phone_hood/2]) rotate([90,0,0]) bushing();
		translate([-cam_center-rim,-phone_wide/2-2,rim]) cube([cam_center/2,22,phone_outer]);
	    }
	    hull() {
		translate([0,phone_wide/2,phone_hood/2]) rotate([-90,0,0]) bushing();
	    	translate([-cam_center-rim,phone_wide/2-22,rim]) cube([cam_center/2,22,phone_outer]);
	    }
	}
	translate([0, 0, 0]) phone(extra_height=10);
	cylinder(r=phone_lens_radius, h=phone_inner+rim+epsilon); // lens hole.
	translate([0,-phone_wide/2,phone_hood/2]) rotate([90,0,0]) bushing_drill();
	translate([0,phone_wide/2,phone_hood/2]) rotate([-90,0,0]) bushing_drill();
    }

    // Cover for screen but with cutout to see it :) So a frame essentially.
    difference() {
	translate([-cam_center - rim, -phone_wide/2 - rim, 0]) cube([phone_hood, phone_wide + 2 * rim, rim]);
	translate([-phone_hood/2 + 4, 0, 0]) cube([phone_hood, phone_wide - 8, 5], center=true);
    }
}

// Actual phone holder, facing forwards.
module phone_holder(rim=phone_holder_thick) {
    rotate([-90,-90,0]) translate([0,0,-phone_hood/2,]) phone_base(rim=rim);
    %camera_cone();
}

function distance(a=[0,0,0], b=[1,1,1]) = sqrt(
    (b[0]-a[0])*(b[0]-a[0]) +
    (b[1]-a[1])*(b[1]-a[1]) +
    (b[2]-a[2])*(b[2]-a[2]));

module slant_cyclinder(r=1,start=[0,0,0],end=[1,1,1],extra_len=0,print_len=0) {
    length = distance(start, end);
    dx=end[0]-start[0];
    dy=end[1]-start[1];
    dz=end[2]-start[2];
    b = acos(dz/length);
    c = (dx==0) ? sign(dy)*90 : ((dx>0) ? atan(dy/dx) : atan(dy/dx) + 180); 
    translate([start[0]+dx/2,start[1]+dy/2,start[2]+dz/2]) rotate([0, b, c])
    translate([0,0,-(length+extra_len)/2]) cylinder(h=length+extra_len, r=r);
    if (print_len) {
	echo("slant-len: ", length, " extra:", extra_len);
    }
}

module nut_punch(extra_height=0) {
    cylinder(r=nut_dia/2, h=nut_high+extra_height, $fn=6);
}

module tripod_mount() {
    difference() {
	cylinder(r=14, h=mechanic_thick);
	translate([0,0,-epsilon]) cylinder(r=thread_drill/2, h=4);
    }
    translate([0,0,mechanic_thick]) difference() {
	cylinder(r=nut_mount_dia, h=6);
	nut_punch(extra_height=2*epsilon);
    }
}

module foot(pos=[100,42],start=0.25,end=0.75) {
    hull() {
	cylinder(r=nut_mount_dia/2, h=nut_high+mechanic_thick);
	translate(start*pos) cylinder(r=leg_width/2,h=leg_high);
    }
    hull() {
	translate(pos) cylinder(r=tripod_foot_dia/2, h=tripod_foot_thick);
	translate(end*pos) cylinder(r=leg_width/2,h=leg_high);
    }
    hull() {
	translate(start*pos) cylinder(r=leg_width/2,h=leg_high);
	translate(end*pos) cylinder(r=leg_width/2,h=leg_high);
    }
}

module base_butterfly(p1=[0,0,80],p2=[0,0,80],p3=[0,0,80]) {
    foot([tripod_mount_width/2,tripod_mount_side_back]);    
    foot([-tripod_mount_width/2,tripod_mount_side_back]);
    foot([0,tripod_mount_back]);

    // Cross-connections.
    hull() {
	translate([tripod_mount_width/2,tripod_mount_side_back]) cylinder(r=leg_width/2,h=tripod_foot_thick);
	translate([0,tripod_mount_back]) cylinder(r=leg_width/2,h=tripod_foot_thick);
    }
    hull() {
	translate([-tripod_mount_width/2,tripod_mount_side_back]) cylinder(r=leg_width/2,h=tripod_foot_thick);
	translate([0,tripod_mount_back]) cylinder(r=leg_width/2,h=tripod_foot_thick);
    }

    difference() {
	slant_cyclinder(r=thread_mount_dia/2, start=[tripod_mount_width/2,tripod_mount_side_back,0], end=p1);
	slant_cyclinder(r=thread_mount_dia/2+2, start=[tripod_mount_width/2,tripod_mount_side_back,0], end=p1, extra_len=-2*thread_stud_len);
    }
    difference() {
	slant_cyclinder(r=thread_mount_dia/2, start=[-tripod_mount_width/2,tripod_mount_side_back,0], end=p2);	
	slant_cyclinder(r=thread_mount_dia/2+2, start=[-tripod_mount_width/2,tripod_mount_side_back,0], end=p2, extra_len=-2*thread_stud_len);
    }
    difference() {
	slant_cyclinder(r=thread_mount_dia/2, start=[0,tripod_mount_back,0], end=p3);
	slant_cyclinder(r=thread_mount_dia/2+2, start=[0,tripod_mount_back,0], end=p3, extra_len=-2*thread_stud_len);
    }

}

module butterfly(p1,p2,p3,nut_space=7) {
    difference() {
	intersection() {
	    // This still contains some symmetric rod-holders from above. intersect to only get the bottom section.
	    base_butterfly(p1,p2,p3);
	    translate([0,0,25]) cube([300,300,50], center=true);
	}
	
	// Place for the threaded rod
	#slant_cyclinder(r=thread_drill/2, start=[tripod_mount_width/2,tripod_mount_side_back,0], end=p1, extra_len=20);
	#slant_cyclinder(r=thread_drill/2, start=[-tripod_mount_width/2,tripod_mount_side_back,0], end=p2, extra_len=20);
	#slant_cyclinder(r=thread_drill/2, start=[0,tripod_mount_back,0], end=p3, extra_len=20);

	// Nut space
	difference() {
	    slant_cyclinder(r=nut_dia/2, start=[tripod_mount_width/2,tripod_mount_side_back,0], end=p1, extra_len=20, $fn=6);
	    slant_cyclinder(r=nut_dia/2+2, start=[tripod_mount_width/2,tripod_mount_side_back,0], end=p1, extra_len=-2*nut_space, $fn=6);
	}
	difference() {
	    slant_cyclinder(r=nut_dia/2, start=[-tripod_mount_width/2,tripod_mount_side_back,0], end=p2, extra_len=20, $fn=6);
	    slant_cyclinder(r=nut_dia/2, start=[-tripod_mount_width/2,tripod_mount_side_back,0], end=p2, extra_len=-2*nut_space, $fn=6);
	}
	difference() {
	    slant_cyclinder(r=nut_dia/2, start=[0,tripod_mount_back,0], end=p3, extra_len=20, $fn=6);
	    slant_cyclinder(r=nut_dia/2, start=[0,tripod_mount_back,0], end=p3, extra_len=-2*nut_space, $fn=6);
	}
    }
}

module phone_with_tilt() {
    rotate([0,0,0]) phone_holder();
}

module base_top_baseplate() {
    translate([holder_mount_width/2,0,0]) cylinder(r=tripod_foot_dia/2, h=mechanic_thick);
    translate([-holder_mount_width/2,0,0]) cylinder(r=tripod_foot_dia/2, h=mechanic_thick);
    translate([0,holder_mount_back,0]) cylinder(r=tripod_foot_dia/2, h=mechanic_thick);

    difference() {
	union() {
	    difference() {
		scale([1,2*holder_mount_back/holder_mount_width,1]) cylinder(r=holder_mount_width/2+3,h=mechanic_thick);
		translate([0,0,-1]) scale([1,2*holder_mount_back/holder_mount_width,1]) cylinder(r=holder_mount_width/2-3,h=mechanic_thick+2);
	    }
	    difference() {
		scale([1,2*holder_mount_back/holder_mount_width,1]) cylinder(r=holder_mount_width/2+1,h=3*mechanic_thick);
		translate([0,0,-1]) scale([1,2*holder_mount_back/holder_mount_width,1]) cylinder(r=holder_mount_width/2-1,h=3*mechanic_thick+2);
	    }
	}
	translate([-holder_mount_width/2-20, 0, -1]) cube([holder_mount_width+40, holder_mount_width, 4*mechanic_thick]);
    }

    difference() {
	slant_cyclinder(r=thread_mount_dia/2, start=[tripod_mount_width/2,tripod_mount_side_back,-tripod_holder_distance], end=[holder_mount_width/2,0,0], extra_len=thread_stud_len);
	slant_cyclinder(r=thread_mount_dia/2+1, start=[tripod_mount_width/2,tripod_mount_side_back,-tripod_holder_distance], end=[holder_mount_width/2,0,0]);
    }
    difference() {
	slant_cyclinder(r=thread_mount_dia/2, start=[-tripod_mount_width/2,tripod_mount_side_back,-tripod_holder_distance], end=[-holder_mount_width/2,0,0], extra_len=thread_stud_len);
	slant_cyclinder(r=thread_mount_dia/2+1, start=[-tripod_mount_width/2,tripod_mount_side_back,-tripod_holder_distance], end=[-holder_mount_width/2,0,0]);
    }
    difference() {
	slant_cyclinder(r=thread_mount_dia/2, start=[0,tripod_mount_back,-tripod_holder_distance], end=[0,holder_mount_back,0], extra_len=thread_stud_len);
	slant_cyclinder(r=thread_mount_dia/2+1, start=[0,tripod_mount_back,-tripod_holder_distance], end=[0,holder_mount_back,0]);
    }
}

module top_baseplate() {
    difference() {
	intersection() {
	    base_top_baseplate();
	    translate([0,0,25]) cube([300,300,50], center=true);
	}

	// Threaded rod
	slant_cyclinder(r=thread_drill/2, start=[tripod_mount_width/2,tripod_mount_side_back,-tripod_holder_distance], end=[holder_mount_width/2,0,0], extra_len=2*thread_stud_len, print_len=1);
	slant_cyclinder(r=thread_drill/2, start=[-tripod_mount_width/2,tripod_mount_side_back,-tripod_holder_distance], end=[-holder_mount_width/2,0,0], extra_len=2*thread_stud_len, print_len=1);
	slant_cyclinder(r=thread_drill/2, start=[0,tripod_mount_back,-tripod_holder_distance], end=[0,holder_mount_back,0], extra_len=2*thread_stud_len, print_len=1);

	// nut-space
	slant_cyclinder(r=nut_dia/2, start=[tripod_mount_width/2,tripod_mount_side_back,-tripod_holder_distance], end=[holder_mount_width/2,0,0], extra_len=9, $fn=6);
	slant_cyclinder(r=nut_dia/2, start=[-tripod_mount_width/2,tripod_mount_side_back,-tripod_holder_distance], end=[-holder_mount_width/2,0,0], extra_len=9, $fn=6);
	slant_cyclinder(r=nut_dia/2, start=[0,tripod_mount_back,-tripod_holder_distance], end=[0,holder_mount_back,0], extra_len=9, $fn=6);
    }

    difference() {
	hull() {
	    translate([phone_wide/2+8+slack, 0, phone_above_holder]) rotate([0,90,0]) cylinder(r=thread_mount_dia/2, h=8);
	    translate([(holder_mount_width+thread_mount_dia)/2, -6, 0]) cube([4, 12, mechanic_thick]);
	}
	translate([phone_wide/2+8, 0, phone_above_holder]) rotate([0,90,0]) cylinder(r=thread_drill/2, h=20);
	translate([phone_wide/2+8, 0, phone_above_holder]) rotate([0,90,0]) cylinder(r=nut_dia/2, h=7, $fn=6);
    }
    difference() {
	hull() {
	    translate([-phone_wide/2-8-slack, 0, phone_above_holder]) rotate([0,-90,0]) cylinder(r=thread_mount_dia/2, h=8);
	    translate([-(holder_mount_width+thread_mount_dia)/2-4, -6, 0]) cube([4, 12, mechanic_thick]);
	}
	translate([-phone_wide/2-8, 0, phone_above_holder]) rotate([0,-90,0]) cylinder(r=thread_drill/2, h=20);
	translate([-phone_wide/2-8, 0, phone_above_holder]) rotate([0,-90,0]) cylinder(r=nut_dia/2, h=7, $fn=6);
    }

    // strengthening bars.
    hull() {
	translate([-(thread_mount_dia-2)/2,holder_mount_back,0]) cylinder(r=mechanic_thick/2,h=12);
	translate([-(holder_mount_width+thread_mount_dia-3)/2,-6,0.6*phone_above_holder]) cylinder(r=mechanic_thick/2,h=8);
    }
    hull() {
	translate([(thread_mount_dia-2)/2,holder_mount_back,0]) cylinder(r=mechanic_thick/2,h=12);
	translate([(holder_mount_width+thread_mount_dia-3)/2,-6,0.6*phone_above_holder]) cylinder(r=mechanic_thick/2,h=8);
    }
}

module bottom_baseplate() {
    difference() {
	butterfly(p1=[holder_mount_width/2,0,tripod_holder_distance],
            p2=[-holder_mount_width/2,0,tripod_holder_distance],
	    p3=[0,holder_mount_back,tripod_holder_distance]);
	translate([0,0,mechanic_thick]) nut_punch(10);
	translate([0,0,-epsilon]) cylinder(r=thread_drill/2,h=15);
    }
}

translate([0,0,phone_above_holder]) phone_with_tilt();
top_baseplate();
translate([0,0,-tripod_holder_distance]) bottom_baseplate();