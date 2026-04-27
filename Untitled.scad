include <vendor/boardgame_insert_toolkit_lib.4.scad>;

Make([
  [ OBJECT_BOX,
    [ BOX_SIZE_XYZ, [50, 50, 20] ],
    [ BOX_FEATURE,
        [ FTR_SHAPE, FILLET ],    
        [ FTR_FILLET_RADIUS, 6 ],
        [ FTR_COMPARTMENT_SIZE_XYZ, [45, 45, 10]],
    ],
    [ BOX_NO_LID_B, true ]
  ]
]);