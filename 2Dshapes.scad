/*
 *  OpenSCAD 2D Shapes Library (www.openscad.org)
 *  Copyright (C) 2012 Peter Uithoven
 *
 *  License: LGPL 2.1 or later

 *  2D Shapes
 *  ngon(sides, radius, center=false);
 *  complexRoundSquare(size,rads1=[0,0], rads2=[0,0], rads3=[0,0], rads4=[0,0], center=true)
 *  roundedSquare(pos=[10,10],r=2)
 *  ellipsePart(width,height,numQuarters)
 *  donutSlice(innerSize,outerSize, start_angle, end_angle)
 *  pieSlice(size, start_angle, end_angle) //size in radius(es)
 *  ellipse(width, height) {
*/
// set true to run the built in tests
do_tests = true;

use <layouts.scad>

example2DShapes();

// Examples - (layouts.scad is required for examples)
// example2DShapes(); use <layouts.scad>;

module example2DShapes() {
    grid(105,105,true,4)
        {
        // ellipse
        ellipse(50,75);
        // part of ellipse (a number of quarters)
        ellipsePart(50,75,3);
        ellipsePart(50,75,2);
        ellipsePart(50,75,1);

        // complexRoundSquare examples
        complexRoundSquare([75,100],[20,10],[20,10],[20,10],[20,10]);
        complexRoundSquare([75,100],[0,0],[0,0],[30,50],[20,10]);
        complexRoundSquare([50,50],[10,20],[10,20],[10,20],[10,20],false);
        complexRoundSquare([100,100]);
        //complexRoundSquare([100,100],rads1=[20,20],rads3=[20,20]);

        // pie slice
        pieSlice(50,0,10);
        pieSlice(50,45,190);
        pieSlice([50],45,190);
        pieSlice([50,20],180,270);

        // donut slice
        donutSlice(20,50,0,350);
        donutSlice(30,50,190,270);
        donutSlice([40,22],[50,30],180,270);
        donutSlice([50,20],50,180,270);
        //donutSlice([20,30],[50,40],0,270);
 
        ngon();
        ngon(5,50,true);
        ngon(12,50);
    }
}
// end examples ----------------------

module complexRoundSquare(
    size, // Size
    rads1=[0,0], // Top left radius
    rads2=[0,0], // Top right radius
    rads3=[0,0], // Bottom right radius
    rads4=[0,0], // Bottom left radius
    center=true // center
)   {
    assert( is_list(size)  && is_list(rads1) &&
            is_list(rads2) && is_list(rads3) &&
            is_list(rads4) );
    width  = size[0];
    height = size[1];
    if( do_tests )
        %square(size=[width, height],center=center);
    x1 = 0-width/2  +rads1[0];
    y1 = 0-height/2 +rads1[1];
    x2 =   width/2  -rads2[0];
    y2 = 0-height/2 +rads2[1];
    x3 =   width/2  -rads3[0];
    y3 =   height/2 -rads3[1];
    x4 = 0-width/2  +rads4[0];
    y4 =   height/2 -rads4[1];

    scs = 0.1; // straight corner size

    x = center ? 0: width/2;
    y = center ? 0: height/2;

    translate([x,y,0])
        hull()
        {
        // top left
        if(rads1[0] > 0 && rads1[1] > 0)
            translate([x1,y1])
                mirror([1,0])
                ellipsePart(rads1[0]*2,rads1[1]*2,1);
        else
            translate([x1,y1])
                square(size=[scs, scs]);

        // top right
        if(rads2[0] > 0 && rads2[1] > 0)
            translate([x2,y2])
                ellipsePart(rads2[0]*2,rads2[1]*2,1);
        else
            translate([width/2-scs,0-height/2])
                square(size=[scs, scs]);

        // bottom right
        if(rads3[0] > 0 && rads3[1] > 0)
            translate([x3,y3])
                mirror([0,1])
                ellipsePart(rads3[0]*2,rads3[1]*2,1);
        else
            translate([width/2-scs,height/2-scs])
                square(size=[scs, scs]);

        // bottom left
        if(rads4[0] > 0 && rads4[1] > 0)
            translate([x4,y4])
                rotate([0,0,-180])
                ellipsePart(rads4[0]*2,rads4[1]*2,1);
        else
            #translate([x4,height/2-scs])
                square(size=[scs, scs]);
    }
}

module roundedSquare(pos=[10,10],r=2)
    {
    assert( is_list(pos) );
    minkowski()
        {
        square([pos[0]-r*2,pos[1]-r*2],center=true);
        circle(r=r);
        }
    }

// round shapes
/* The orientation might change with the
    implementation of circle
    NB circle does not have a center param
 */
module ngon(sides=3, radius=1, center=false)
    {
    circle(r=radius, $fn=sides);
    if( do_tests )
        %circle(r=radius, $fn=80);
    }

/*
    width  is the diameter in the x direction
    height is the diameter in the y direction

module ellipse(width, height) {
    scale([1, height/width, 1])
    circle(r=width/2);
}
 */
module ellipse(width, height) {
    resize( [ width, height, 0] )
        circle(r=1,$fn=50);
}

module ellipsePart(width,height,numQuarters)
    {
    o = 1; //slight overlap to fix a bug
    difference()
        {
        ellipse(width,height);

        if(numQuarters <= 3)
            translate([0-width/2-o,0-height/2-o,0])
                square([width/2+o,height/2+o]);
        if(numQuarters <= 2)
            translate([0-width/2-o,-o,0])
                square([width/2+o,height/2+o*2]);
        if(numQuarters < 2)
            translate([-o,0,0])
                square([width/2+o*2,height/2+o]);
        }
    }

module donutSlice(innerSize,outerSize, start_angle, end_angle)
    {
    difference()
        {
        pieSlice(outerSize, start_angle, end_angle);

        if(is_list(innerSize) && len(innerSize) > 1)
             ellipse(innerSize[0]*2,innerSize[1]*2);
        else
            circle( r=innerSize);
        }
    }

/*
  size is either <radius> or [rx,ry]. [radius] == <radius>
 */
module pieSlice( size, start_angle, end_angle)
    {
    rx = is_list(size) ? size[0] : size;
    ry = is_list(size) ? len(size) > 1 ? size[1] : size[0] : size;
    
    sqp1 = sqrt(2) + 1;
    trx = rx* sqp1;
    try = ry* sqp1;

    if(end_angle > start_angle)
        intersection()
            {
            if(is_list(size) && len(size) > 1)
                ellipse(rx*2,ry*2);
            else
                circle(rx);

            a0 = (4 * start_angle + 0 * end_angle) / 4;
            a1 = (3 * start_angle + 1 * end_angle) / 4;
            a2 = (2 * start_angle + 2 * end_angle) / 4;
            a3 = (1 * start_angle + 3 * end_angle) / 4;
            a4 = (0 * start_angle + 4 * end_angle) / 4;

            polygon([
                [0,0],
                [trx * cos(a0), try * sin(a0)],
                [trx * cos(a1), try * sin(a1)],
                [trx * cos(a2), try * sin(a2)],
                [trx * cos(a3), try * sin(a3)],
                [trx * cos(a4), try * sin(a4)],
                [0,0]
                ]);
            }
    }

