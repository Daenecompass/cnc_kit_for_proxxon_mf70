// Radial Bearing Fit Sleeve

tolerance=0.1;
shaftDiameter=4.5;
bearingInsideDiameter=6;
bearingThickness=6;
sleeveRecess=0.2;
retainingRidgeWidth=0.75;
retainingRidgeThickness=0.25;
overlap=0.001;

difference() {
    union() {
        // retaining ridge
        cylinder(d=bearingInsideDiameter+retainingRidgeWidth*2, 
                h=retainingRidgeThickness, $fn=50);
        translate([0,0,retainingRidgeThickness-overlap]) 
            cylinder(d=bearingInsideDiameter-tolerance*2, 
                h=bearingThickness-sleeveRecess, $fn=50);
    }
    translate([0,0,-overlap]) 
        cylinder(d=shaftDiameter+tolerance*2, 
            h=bearingThickness+retainingRidgeThickness+overlap*2, 
            $fn=50);
} 