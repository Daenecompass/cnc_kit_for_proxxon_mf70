include <cnc_kit_for_proxxon_mf70_common.scad>;

overlap=moduleOverlap;

*translate([0,0,0]) {
*    translate([15.9,26.05,0]) rotate([90,0,0])
        import("ref_imports\\m70zplate-626-bearing-lower.STL");
*    translate([15.9,26.05,0]) rotate([90,0,0])
        import("ref_imports\\m70zplate-626-bearing-upper.STL");
    translate([0,77.3,0]) rotate([-90,180,180]) 
        import("ref_imports\\m70zplate-626-plate.STL");
*    translate([6,34.5,0]) rotate([90,0,0])
        import("ref_imports\\m70zplate-626-stepper.STL");
}

// This controls how much of the top of the mill headstock
// is covered (or how much overhang there is on the sides
// Note: It does _not_ adjust the distance from the center
// of the front mount holes.  motorMountPlateWidth does that.
bottomPlateWidth=70.25;
bottomPlateLength=77.5;

bottomPlateSquarePartLength=37.5;
bottomPlateTaperAngle=14;

bottomPlateLeftSideNotchLength=13.25;

// This controls how much of a riser there is around the screws
// to allow using the original hardware (screws).
bottomPlateMountHoleDepth=14.4;

mountHoleDia=3.9;

// This controls how far from the center the stanchions
// and front mounting holes are.
// Note: Printed at 57 with black ABS and the front
// mounting holes were slightly too close together.
motorMountPlateWidth=58;
motorMountPlateLength=42;

// This controls the front/back center of the lead-screw hole
// and the bearing.
motorMountPlateFrontOverhang=6.5;

stanchionLength=30;
stanchionWidth=9;
stanchionHeight=66.25;
wrenchClearanceGrooveDia=6.5;

mountHoleRiserTopDia=wrenchClearanceGrooveDia+overlap;
mountHoleRiserBaseDia=mountHoleRiserTopDia+3;

topBearingRecessDepth=2;
bottomBearingRecessDepth=4.5;

bearingShaftPassThruDia=9;

frontMountHoleOffsetY=23.25;

rearMountHoleXInset=15;
rearMountHoleOffsetY=68.9;

cornerRoundnessDia=moduleCornerRoundnessDia;
cornerRoundnessFn=moduleCornerRoundnessFn;

// calculated

// Center the top plate relative to the bottom plate on the x-axis
motorMountPlatePositionOffsetX = bottomPlateWidth/2 - motorMountPlateWidth/2;

bottomPlateLeftSideNotchWidth=motorMountPlatePositionOffsetX; 

motorMountPlateMotorShaftThruHoleOffsetX=motorMountPlateWidth/2;
motorMountPlateMotorShaftThruHoleOffsetY=motorMountPlateLength/2;

bottomPlateMotorShaftThruHoleOffsetX=bottomPlateWidth/2;
bottomPlateMotorShaftThruHoleOffsetY=
        motorMountPlateMotorShaftThruHoleOffsetY-motorMountPlateFrontOverhang;

nema17HolesOffsetX = motorMountPlateWidth/2 - nema17MountingHolesWidth/2;
nema17HolesOffsetY = motorMountPlateLength/2 - nema17MountingHolesLength/2;

// calculated to make the bearing recesses and shaft 
// pass-thru line up with the center of the top-plate 
// motor-shaft pass-thru hole
bearingCarrierLength=(motorMountPlateLength/2-motorMountPlateFrontOverhang)*2;

bearingCarrierWidth=motorMountPlateWidth-stanchionWidth*2;
bearingCarrierCenterX=bearingCarrierWidth/2;
bearingCarrierCenterY=bearingCarrierLength/2;

mountHoleRiserHeight=bottomPlateMountHoleDepth-axisMountPlateThickness;


union() {
    bottomPlate();
    translate([motorMountPlatePositionOffsetX,-motorMountPlateFrontOverhang,
        axisMountPlateThickness+stanchionHeight]) 
        motorMountPlate();
    translate([motorMountPlatePositionOffsetX,0,
            axisMountPlateThickness-overlap])
        leftStanchion();
    translate([motorMountPlatePositionOffsetX+motorMountPlateWidth-stanchionWidth,0,
            axisMountPlateThickness-overlap])
        rightStanchion();
    translate([motorMountPlatePositionOffsetX+stanchionWidth,
            0, axisMountPlateThickness-overlap])
        bearingCarrier();
}

module bearingCarrier() {
    // Note: This position adjustment works together with the
    // expanded size of the cube below.
    translate([-overlap,0,0]) {
        union() {
            difference() {
                // GEOMETRY TWEAK: Adding 1/2 stanchion width * 2 to 
                // completely overlap the roundness on the stanchions.
                translate([-stanchionWidth/2,0,0])
                    cube([bearingCarrierWidth+stanchionWidth,
                            bearingCarrierLength, bearingCarrierThickness]);
                // cut for top bearing recess
                //   Note: 2nd overlap is to align with center of cube
                translate([bearingCarrierCenterX+overlap+overlap,
                        bearingCarrierCenterY+overlap,
                        bearingCarrierThickness-topBearingRecessDepth])
                    bearingRecessCutout(bearingOuterDia,
                        bearingThickness,
                        bearingRimThickness-overlap*2); 
                // cut for bottom bearing recess
                //   Note: 2nd overlap is to align with center of cube
                translate([bearingCarrierCenterX+overlap+overlap,
                        bearingCarrierCenterY+overlap,
                        -bearingThickness+bottomBearingRecessDepth])
                    bearingRecessCutout(bearingOuterDia,
                        bearingThickness,
                        bearingRimThickness-overlap*2);
                // shaft pass thru
                translate([bearingCarrierCenterX,
                        bearingCarrierCenterY,0]) {
                    cylinder(d=bearingShaftPassThruDia, 
                            h=bearingCarrierThickness, $fn=30);
                }
                
            }
            // top bearing recess
            translate([bearingCarrierCenterX,
                        bearingCarrierCenterY,
                        bearingCarrierThickness-topBearingRecessDepth-overlap]) 
                bearingRecess(bearingOuterDia,
                    bearingThickness+overlap,
                    bearingRimThickness); 
            // bottom bearing recess
            translate([bearingCarrierCenterX,
                        bearingCarrierCenterY,
                        -bearingThickness+bottomBearingRecessDepth+overlap]) 
                bearingRecess(bearingOuterDia,
                        bearingThickness+overlap,
                        bearingRimThickness,reverse=true); 
        }
    }
}

/*
 * The plate that replaces the cap plate on the mill.
 */
module bottomPlate() {
    union() {
        difference() {
            shrinkMinkowskiVerticalRound(axisMountPlateThickness,
                    cornerRoundnessDia, cornerRoundnessFn,
                    bottomPlateWidth, bottomPlateLength) { 
                difference() {
                    // Note: minkowski adds the height of the cylinder to this
                    cube([bottomPlateWidth, 
                        bottomPlateLength, 
                        axisMountPlateThickness]);
                    // taper left
                    translate([0,bottomPlateSquarePartLength,-overlap])
                        rotate([0,0,-bottomPlateTaperAngle]) 
                            translate([-(bottomPlateWidth/2),0,0])
                                cube([bottomPlateWidth/2,bottomPlateLength,
                                        axisMountPlateThickness+overlap*2]);
                    // taper right
                    translate([(bottomPlateWidth),bottomPlateSquarePartLength,-overlap])
                        rotate([0,0,bottomPlateTaperAngle]) 
                            cube([bottomPlateWidth/2,bottomPlateLength,
                                    axisMountPlateThickness+overlap*2]);
                    // left side notch
                    translate([-overlap,-overlap,-overlap]) 
                        cube([bottomPlateLeftSideNotchWidth+overlap*2, 
                            bottomPlateLeftSideNotchLength+overlap*2,
                            axisMountPlateThickness+overlap*2]);
                }
            }
            // motor shaft hole
            translate([bottomPlateMotorShaftThruHoleOffsetX,
                    bottomPlateMotorShaftThruHoleOffsetY,0]) {
                plateThruHole(axisMountPlateThickness,motorShaftThruHoleDiameter);
            }
            // left front mount hole
            translate([motorMountPlatePositionOffsetX,
                    frontMountHoleOffsetY,
                    0]) {
                plateThruHole(axisMountPlateThickness,mountHoleDia);
            }
            // right front mount hole
            translate([motorMountPlatePositionOffsetX+motorMountPlateWidth,
                    frontMountHoleOffsetY,
                    0]) {
                plateThruHole(axisMountPlateThickness,mountHoleDia);
            }
            // left rear mount hole
            translate([rearMountHoleXInset,
                    rearMountHoleOffsetY,
                    0]) {
                plateThruHole(axisMountPlateThickness,mountHoleDia);
            }
            // right rear mount hole
            translate([bottomPlateWidth-rearMountHoleXInset,
                    rearMountHoleOffsetY,
                    0]) {
                plateThruHole(axisMountPlateThickness,mountHoleDia);
            }
        }
        // front left
        translate([motorMountPlatePositionOffsetX,
                frontMountHoleOffsetY,axisMountPlateThickness-overlap]) 
            mountHoleRiser();
        // front right
        translate([motorMountPlatePositionOffsetX+motorMountPlateWidth,
                    frontMountHoleOffsetY,axisMountPlateThickness-overlap]) 
            mountHoleRiser();
        // rear left
        translate([rearMountHoleXInset,
                    rearMountHoleOffsetY,axisMountPlateThickness-overlap]) 
            mountHoleRiser();
        // rear right
        translate([bottomPlateWidth-rearMountHoleXInset,
                    rearMountHoleOffsetY,axisMountPlateThickness-overlap]) 
            mountHoleRiser();

    }
}

module motorMountPlate() {
    difference() {
        shrinkMinkowskiVerticalRound(motorMountPlateThickness,
                motorMountPlateCornerRoundnessDia, cornerRoundnessFn,
                motorMountPlateWidth, motorMountPlateLength) { 
            cube([motorMountPlateWidth, motorMountPlateLength, motorMountPlateThickness]);
        }
        translate([nema17HolesOffsetX,nema17HolesOffsetY,0]) {
            nema17MountingHoles();
        }
        // motor shaft hole
        translate([motorMountPlateMotorShaftThruHoleOffsetX,
                motorMountPlateMotorShaftThruHoleOffsetY,0]) {
            motorShaftThruHole();
        }
        // left wrench clearance cutout
        translate([0,
                    frontMountHoleOffsetY+motorMountPlateFrontOverhang,
                    -overlap]) 
            cylinder(d=wrenchClearanceGrooveDia,
                    h=motorMountPlateThickness+overlap*2,
                    $fn=20);
        // right wrench clearance cutout
        translate([motorMountPlateWidth,
                    frontMountHoleOffsetY+motorMountPlateFrontOverhang,
                    -overlap]) 
            cylinder(d=wrenchClearanceGrooveDia,
                    h=motorMountPlateThickness+overlap*2,
                    $fn=20);
    }
}

/*
 * Note: wrench clearance cut needs to overlap on each end
 * (2 * overlap) because the block is oversized by (1 * overlap)
 * on each end to make it merge with top and bottom plates.
 */
module leftStanchion() {
    translate([0,0,-overlap]) {
        difference() {
            union() {
                shrinkMinkowskiVerticalRound(stanchionHeight+overlap*2,
                        cornerRoundnessDia, cornerRoundnessFn,
                        stanchionWidth, stanchionLength) { 
                    cube([stanchionWidth,stanchionLength,
                        stanchionHeight+overlap*2]);
                }
                translate([stanchionWidth/6,stanchionLength-overlap,0])
                    stanchionBrace();
            }
            translate([0,frontMountHoleOffsetY,0]) 
                plateThruHole(stanchionHeight+overlap*2, 
                    wrenchClearanceGrooveDia);
        }
    }
}

module stanchionBrace() {
    braceWidth=stanchionWidth/3*2;
    frontSlantAngle=15;  // degrees
    // rotation moves two edges of the cylinder's end pos and neg on the z axis
    // this calculates how much it takes to move an edge back to the x/y plane.
    endHeightAfterRotation=sin(frontSlantAngle)*braceWidth/2;
    adjustedCylinderHeight=stanchionHeight+endHeightAfterRotation*4;
    topCenterDeflectionAfterRotation=sin(frontSlantAngle)*adjustedCylinderHeight;
    hull() {
        cube([braceWidth,1,stanchionHeight+overlap*2]);
        difference() {
            translate([stanchionWidth/3,20,0]) {
                difference() {  // shear off the bottom after rotation and adjustment
                    translate([0,0,-endHeightAfterRotation])
                        rotate([15,0,0]) 
                            cylinder(d=braceWidth,
                                h=adjustedCylinderHeight,
                                $fn=30);
                    translate([-braceWidth,-braceWidth,-braceWidth])
                        cube([braceWidth*2,braceWidth*2,braceWidth]);
                    translate([-braceWidth,
                            -topCenterDeflectionAfterRotation-braceWidth,
                            stanchionHeight])
                        cube([braceWidth*2,braceWidth*2,braceWidth]);
                }
            }
            // shear off the back (negative-y) part of the tilted cylinder
            translate([-braceWidth,-braceWidth,0])
                cube([braceWidth*2,braceWidth,stanchionHeight+overlap]);
        }
    }
}

module rightStanchion() {
    translate([stanchionWidth,0,0]) {
        mirror([1,0,0]) {
            leftStanchion();
        }
    }
}

module mountHoleRiser() {
    difference() {
        cylinder(d1=mountHoleRiserBaseDia, d2=mountHoleRiserTopDia,
                h=mountHoleRiserHeight, $fn=30);
        translate([0,0,-overlap])
            cylinder(d=mountHoleDia, 
                    h=mountHoleRiserHeight+overlap*2, $fn=30);
    }
}

