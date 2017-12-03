include <cnc_kit_for_proxxon_mf70_common.scad>;

*translate([]) {
    translate([66,0,58])
        rotate([180,0,180])
            import("ref_imports\\mf70lowerplate-626-stepper.STL");
    translate([68.5,8.68,58])
        rotate([180,0,180])
            import("ref_imports\\mf70lowerplate-626-plate.STL");
    translate([52.3,12.78,85])
        rotate([0,180,0])
            import("ref_imports\\mf70lowerplate-626-internal.STL");
}

stanchionWidth=8.25;
stanchionLength=27;
stanchionHeight=43.5;

motorMountPlateWidth=61;
motorMountPlateLength=41;

motorMountPlateWrenchAccessHoleDia=6.6;
motorMountPlateWrenchAccessYOffset=16.6;

motorMountPlateXOffset=5;

// Note: In the original bubblegum-cnc objects, the motor and shaft 
// holes are not exactly centered.  This adjustment is applied to
// the position of all of the motor-shaft, mount, lead-screw, etc.
// holes to line them up with the original drawing.
// TODO: review whether this is required or is maybe an error in the
// original design.
motorShaftCenterAdjustmentX = -0.7;

axisMountPlateWidth=motorMountPlateWidth+motorMountPlateXOffset;
axisMountPlateLength=stanchionLength;

leadScrewHoleDia=9.5;

axisInsertionBlockLength=26.9;
// TODO Calculate and align these on the leadscrew hole centers instead.
axisInsertionBlockXOffset=14.7;
axisInsertionBlockYOffset=12.8;

// calculated

motorMountPlateMotorShaftThruHoleOffsetX=motorMountPlateWidth/2;
motorMountPlateMotorShaftThruHoleOffsetY=motorMountPlateLength/2;


nema17HolesOffsetX = motorMountPlateWidth/2 - nema17MountingHolesWidth/2;
nema17HolesOffsetY = motorMountPlateLength/2 - nema17MountingHolesLength/2;

stanchionYOffset=motorMountPlateLength/2-stanchionLength/2;
axisMountPlateYOffset=stanchionYOffset;

// Calculated by matching the center of the hole in the axis mount plate
// and subtracting the offset of the insertion block
axisPlateLeadScrewHoleX=motorMountPlateXOffset+motorMountPlateWidth/2
        -axisInsertionBlockXOffset;
axisPlateLeadScrewHoleY=motorMountPlateLength/2
        -axisInsertionBlockYOffset;

axisMountScrewDia=3.5;
// Note: These are relative to the corner of the axis mount plate.
axisPlateLeftMountScrewX=axisInsertionBlockXOffset+1.9;
axisPlateRightMountScrewX=axisInsertionBlockXOffset+39.6;
axisPlateMountScrewYOffset=9.75;

// Note: This is used to subtract a bit from the depth of the
// bearing recess in the axis mount plate, so it is applied
// as a negative value.
bearingRecessHeight=2;

cornerRoundnessDia=moduleCornerRoundnessDia;
cornerRoundnessFn=moduleCornerRoundnessFn;

motorMountPlateWrenchAccessXInset=stanchionWidth
        + motorMountPlateWrenchAccessHoleDia/2;
overlap=moduleOverlap;

union() {
    translate([motorMountPlateXOffset,0,0])
        motorMountPlate();
    translate([0,axisMountPlateYOffset,motorMountPlateThickness+stanchionHeight])
        axisMountPlate();
    translate([motorMountPlateXOffset,
            stanchionYOffset,motorMountPlateThickness-overlap])
        stanchion();
    translate([motorMountPlateXOffset+motorMountPlateWidth-stanchionWidth,
            stanchionYOffset,motorMountPlateThickness-overlap])
        stanchion();
    translate([axisInsertionBlockXOffset,axisInsertionBlockYOffset,
            motorMountPlateThickness+stanchionHeight+axisMountPlateThickness])
        axisInsertionBlock();
}

// TODO Factor this out for the other table axis if it is the same
// Note: polygon left/right designation is as viewed from the
//   front of the table.  
module axisInsertionBlock() {
    catchRidgeThickness=1.5;
    catchRidgeHeight=1.1;
    
    ridgeHeight=9.3;
    topHeight=13.2;
    leftTopRidgeWidth=3.6;
    leftSlopeWidth=6.4;
    centerTopFlatWidth=17.6;
    rightSlopeWidth=6.4;
    rightTopRidgeWidth=3.6;
    rightSideX=leftTopRidgeWidth+leftSlopeWidth+centerTopFlatWidth
            +rightSlopeWidth+rightTopRidgeWidth;
    rightNotchHeight=7;
    rightNotchWidth=4.1;
    insertionShapeVertices = [
        [0,0],
        [0,ridgeHeight], 
        [leftTopRidgeWidth,ridgeHeight],
        [leftTopRidgeWidth+leftSlopeWidth,topHeight],
        [leftTopRidgeWidth+leftSlopeWidth+centerTopFlatWidth,topHeight],
        [rightSideX-rightTopRidgeWidth,ridgeHeight],
        [rightSideX,ridgeHeight],
        [rightSideX,rightNotchHeight],
        [rightSideX-rightNotchWidth,rightNotchHeight],
        [rightSideX-rightNotchWidth,0],
        [0,0]
    ];
    
    difference() {
        union() {
            linear_extrude(height=axisInsertionBlockLength) {
                translate([rightSideX,0]) mirror([1,0]) 
                    polygon(points=insertionShapeVertices);
            }
            translate([rightTopRidgeWidth+rightSlopeWidth,
                    topHeight,
                    axisInsertionBlockLength-catchRidgeThickness]) 
                cube([centerTopFlatWidth,catchRidgeHeight,catchRidgeThickness]);
        }
        translate([axisPlateLeadScrewHoleX+motorShaftCenterAdjustmentX
            , axisPlateLeadScrewHoleY, 0]) {
            plateThruHole(axisInsertionBlockLength, leadScrewHoleDia);
        }
    }    
}

module axisMountPlate() {
    union() {
        difference() {
            shrinkMinkowskiVerticalRound(axisMountPlateThickness,
                        cornerRoundnessDia, cornerRoundnessFn,
                        axisMountPlateWidth, axisMountPlateLength) {
                cube([axisMountPlateWidth,axisMountPlateLength,axisMountPlateThickness]);
            }
            // lead screw hole
            translate([motorMountPlateXOffset+motorMountPlateWidth/2
                    +motorShaftCenterAdjustmentX,
                    axisMountPlateLength/2,0])
                plateThruHole(axisMountPlateThickness, leadScrewHoleDia);
            
            // bearing recess cutout
            translate([motorMountPlateXOffset+motorMountPlateWidth/2
                    +motorShaftCenterAdjustmentX,
                    axisMountPlateLength/2,-overlap])
                bearingRecessCutout(bearingOuterDia,
                    bearingThickness,
                    bearingRimThickness-overlap*2);
            
            // left mounting screw hole
            translate([axisPlateLeftMountScrewX,
                    axisPlateMountScrewYOffset,0])
                plateThruHole(axisMountPlateThickness, axisMountScrewDia);
            // right mounting screw hole
            translate([axisPlateRightMountScrewX,
                    axisPlateMountScrewYOffset,0])
                plateThruHole(axisMountPlateThickness, axisMountScrewDia);
        }
        translate([motorMountPlateXOffset+motorMountPlateWidth/2
                +motorShaftCenterAdjustmentX,
                axisMountPlateLength/2,-bearingRecessHeight])
                bearingRecess(bearingOuterDia,
                        bearingThickness,
                        bearingRimThickness-overlap*2, reverse=true);
    }
}

module motorMountPlate() {
    difference() {
        shrinkMinkowskiVerticalRound(motorMountPlateThickness,
                motorMountPlateCornerRoundnessDia, cornerRoundnessFn,
                motorMountPlateWidth, motorMountPlateLength) {
            cube([motorMountPlateWidth,
                    motorMountPlateLength,
                    motorMountPlateThickness]);
        }
        translate([nema17HolesOffsetX+motorShaftCenterAdjustmentX,
                nema17HolesOffsetY,0]) {
            nema17MountingHoles();
        }
        // motor shaft hole
        translate([motorMountPlateMotorShaftThruHoleOffsetX+motorShaftCenterAdjustmentX,
                motorMountPlateMotorShaftThruHoleOffsetY,0]) {
            motorShaftThruHole();
        }
        // left mount screw wrench access
        translate([motorMountPlateWrenchAccessXInset,
                motorMountPlateWrenchAccessYOffset,0])
            plateThruHole(motorMountPlateThickness, motorMountPlateWrenchAccessHoleDia);
        // right mount screw wrench access
        translate([motorMountPlateWidth-motorMountPlateWrenchAccessXInset,
                motorMountPlateWrenchAccessYOffset,0])
            plateThruHole(motorMountPlateThickness, motorMountPlateWrenchAccessHoleDia);

    }
}

module stanchion() {
    translate([0,0,-overlap]) {
        shrinkMinkowskiVerticalRound(stanchionHeight+overlap*2,
                cornerRoundnessDia, cornerRoundnessFn,
                stanchionWidth, stanchionLength) { 
            cube([stanchionWidth,stanchionLength,
                stanchionHeight+overlap*2]);
        }
    }
}
