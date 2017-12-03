motorShaftThruHoleDiameter=24;
motorMountPlateThickness=6;
motorMountPlateCornerRoundnessDia=10;

dustSealClearance = 1;
bearingRaceThickness = 1.5;

axisMountPlateThickness=8.25;

// Center to center 
nema17MountingHoleSpacing=31;
nema17MountingHoleDia=3.8;
nema17MountingHoleInset=5.5;

bearingCarrierThickness=13;
bearingOuterDia=20;
bearingThickness=6;
bearingRimThickness=2.5;

// calculated
nema17MountingHolesWidth=
        nema17MountingHoleSpacing
        +nema17MountingHoleInset*2;
nema17MountingHolesLength=nema17MountingHolesWidth;

moduleCornerRoundnessDia=3;
moduleCornerRoundnessFn=20;

moduleOverlap=0.001;

*motorShaftThruHole();
*nema17MountingHoles();
*bearingRecess(19,6,3);
*shrinkMinkowskiVerticalRound(2, 3, 10, 20) {
  translate([0,0,0]) cube([10,20,2]);
}


/*
 * This is meant to produce a cut in a plate, so the height 
 * is increased by 2 * an overlap amount in order to cut
 * all the way through, and pre-positioned negative 
 * 1 * overlap on the Z axis.
 */
module motorShaftThruHole() {
    plateThruHole(motorMountPlateThickness,
            motorShaftThruHoleDiameter);
}

/*
 * This is meant to produce 4 cylindrical cuts in a plate
 * which align with the mounting holes in a standard Nema
 * 17 motor.
 */
module nema17MountingHoles() {
    translate([nema17MountingHoleInset,
            nema17MountingHoleInset,
            0]) {
        for(x = [0:1:1]) {
            for(y = [0:1:1]) {
                translate([x*nema17MountingHoleSpacing,
                        y*nema17MountingHoleSpacing, 0]) {
                    plateThruHole(motorMountPlateThickness,
                              nema17MountingHoleDia);  
                }
            }
        }
    }
}

/*
 * Note: The ridge around the bottom supports the outer race
 * on the bearing. 
 */
module bearingRecess(bearingOuterDiameter, 
        argBearingThickness,argRimThickness, reverse) {
    mirror([0,0, ((reverse) ? 1 : 0)]) 
    translate([0,0, ((reverse) ? -(argBearingThickness+dustSealClearance) : 0)])        
    difference() {
        // Make the outer ring by using the function that creates
        // the cutout in other objects so it will fit exactly.
        bearingRecessCutout(bearingOuterDiameter, 
                argBearingThickness,argRimThickness);
        // the recess where the bearing slides in
        translate([0,0,dustSealClearance])
            cylinder(d=bearingOuterDiameter,
                    h=argBearingThickness+moduleOverlap*2, $fn=30);
        // the recess that provides clearance inside the outer
        // race for a slighly protruding dust seal
        translate([0,0,-moduleOverlap])
            cylinder(d=bearingOuterDiameter-bearingRaceThickness*2, 
                    h=argBearingThickness+moduleOverlap*2, $fn=30);
    }
}

module bearingRecessCutout(bearingOuterDiameter, 
        argBearingThickness,argRimThickness) {
    cylinder(d=bearingOuterDiameter+argRimThickness*2,
            h=argBearingThickness+dustSealClearance, $fn=30);
}

/*
 * This factors out creation of a cylindrical object
 * for cutting a hole in a plate, increasing the height
 * of the object by 2 * overlap and offsetting its 
 * position by 1 * offset
 */
module plateThruHole(plateThickness, holeDiameter) {
    translate([0,0,-moduleOverlap]) {
        cylinder(d=holeDiameter,
                h=plateThickness
                    +moduleOverlap*2,
                $fn=30);
    }    
}

/*
 * Minkowski with cube and cylinder, but subtracts instead
 * of adds.  The overall thickness of the object is maintained
 * by cutting the additive "roller" cylinder in half, and
 * scaling the child object in half.
 * width and length are used as a basis for
 * scaling the original object.  Since these are
 * approximations, oddly shaped objects may not yield
 * the desired result.  Rectangle object should be close
 * to correct, but still may be off by a small margin of
 * calculation error.
 */
module shrinkMinkowskiVerticalRound(edgeHeight, 
        roundnessDia, roundnessFn, 
        width, length) {
    scaleX = (width - roundnessDia) / width;
    scaleY = (length - roundnessDia) / length;
    minkowski() {
        translate([roundnessDia/2,roundnessDia/2,0])
            scale([scaleX,scaleY,0.5]) 
                children(0);
        cylinder(h=edgeHeight/2, d=roundnessDia, 
            $fn=roundnessFn);
    }
}




