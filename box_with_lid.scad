include <common.scad>;

// 

use <vendor/fonts/NotoEmoji-Regular.ttf>;
emoji_font = "Noto Emoji, Regular";

use <vendor/fonts/Cinzel-Regular.ttf>;
roman_font = "Cinzel";


use <vendor/fonts/Gaeilge.ttf>;
sax_font = "Gaeilge";

labels = false;
render_lids = false;


box_width = 218;
box_length = 294;
box_height = 74;

rules = 35.0;


faction_depth = 14;
faction_height = (box_height - rules) / 2;
faction_width_bottom = 184;
faction_width_up = 144;
factions_stack = 170;
factions_add_cmp_width = 10;

faction_fr = 6;

inner_chamfer = 4;
inner_chamfer_gap = 1;
inner_chamfer_add_vector = [
  2 * inner_chamfer + inner_chamfer_gap, 
  2 * inner_chamfer + inner_chamfer_gap, 
  0
];

   
function last_size(box_dim, comps) = 
  box_dim - 2 * ext_walls - sum(comps) - walls * len(comps);
  
function cmp_offset_y_centered(cmp_arr, i, box_size) = 
    [0, (box_size.y - 2 * ext_walls - cmp_arr[i].y) / 2];
    
function cmp_offset_y_centered_arr(cmp_arr, i, box_size) = 
    echo("cmp_arr")
    echo(cmp_arr)
    let (y_components = map(cmp_arr, function (v) v.y))
    let (av_space = box_size.y - 2 * ext_walls - sum(y_components))
    let (gap = av_space / (len (cmp_arr) + 1))
    [0, sum(slice(y_components, end = i)) + gap * (i + 1)];


function comp8(box_size, cmp_arr, index, cmp_arr_y = [], index_y = 0, label = []) = 
    let (gap = 1)
    let (cmp_arr_y_real = len(cmp_arr_y) == 0 ? [cmp_arr[index]] : cmp_arr_y)
    
    [ BOX_FEATURE,
        [ FTR_SHAPE, SQUARE ],    
        [ CHAMFER_N, inner_chamfer ],
        [ FTR_COMPARTMENT_SIZE_XYZ, cmp_arr[index]],
        [ POSITION_XY, vecsum2(
            cmp_offset(cmp_arr, index),
            cmp_offset_y_centered_arr(cmp_arr_y_real, index_y, box_size)
        )],
        label,
    ];
    
// Extends selected cmp to max available or keep intact
function extend_cmp_x(box_size, cmp_arr, index_arr) = 
    let (x_components = map(cmp_arr, function (v) v.x))
    let (available_space = box_size.x - 2 * ext_walls - sum(x_components) - (len(cmp_arr) - 1) * walls)
    let (addition = available_space > 0 ? available_space / len (index_arr) : 0)
    
    echo("extend_cmp_x.available_space")
    echo(available_space)
    
    [for (i = 0; i < len(cmp_arr); i = i + 1) 
        len(search(i, index_arr)) == 0 ? 
            cmp_arr[i] : 
            vecsum(cmp_arr[i], [addition , 0, 0])
    ];
    
function rom_label(text = "") = 
    [ LABEL, 
        [ ENABLED_B, labels ],
        [ LBL_TEXT, [[ text ]]],
        [ LBL_SIZE, 6 ],
        [ LBL_FONT, roman_font ],
    ];
    


dux_box_size = [faction_width_bottom, factions_stack * 0.32, faction_height - lid_down_space];
dux_cmp_pure = [
  [50, 40, faction_depth],
  [70, 32, faction_depth],
  [30, 40, faction_depth],
];
dux_cmp_chamfered = append_each(dux_cmp_pure, inner_chamfer_add_vector);
dux_cmp = extend_cmp_x(dux_box_size, dux_cmp_chamfered, [2]);

dux_box = [ OBJECT_BOX,
    [ NAME, "dux" ],
    [ BOX_SIZE_XYZ, dux_box_size ],
    [ CHAMFER_N, 1 ],
    [ BOX_STACKABLE_B, false ],
    comp8(dux_box_size, dux_cmp, 0, label = rom_label("20 CAVALRY")),
    comp8(dux_box_size, dux_cmp, 1, label = rom_label("10 FORTS")),
    comp8(dux_box_size, dux_cmp, 2, label = rom_label("MISC")),
    render_lids ? lid("DUX", roman_font, 24, 0, 4) : no_lid(),
];

civ_box_size = [
    faction_width_bottom, 
    factions_stack - dux_box_size.y, 
    faction_height - lid_down_space
];

civ_cmp_pure = [
  [50, 30, faction_depth],
  [70, 45, faction_depth],
  [30, 45, faction_depth],
];
civ_cmp_chamfered = append_each(civ_cmp_pure, inner_chamfer_add_vector);
civ_cmp = extend_cmp_x(civ_box_size, civ_cmp_chamfered, [2]);

civ_cmp_2_pure = [
  [50, 60, faction_depth],
  [70, 45, faction_depth],
  [30, 45, faction_depth],
];
civ_cmp_2_chamfered = append_each(civ_cmp_2_pure, inner_chamfer_add_vector);
civ_cmp_2 = extend_cmp_x(civ_box_size, civ_cmp_2_chamfered, [2]);


civ_box = [ OBJECT_BOX,
    [ NAME, "civ" ],
    [ BOX_SIZE_XYZ, civ_box_size ],
    [ BOX_STACKABLE_B, false ],
    comp8(civ_box_size, civ_cmp, 0, [civ_cmp[0], civ_cmp_2[0]], 0, label = rom_label("15 COMITATES")),
    comp8(civ_box_size, civ_cmp_2, 0, [civ_cmp[0], civ_cmp_2[0]], 1, label = rom_label("30 MILITIA")),
    comp8(civ_box_size, civ_cmp, 1, [civ_cmp[1], civ_cmp_2[1]], 0, label = rom_label("15 HILLFORTS")),
    comp8(civ_box_size, civ_cmp_2, 1, [civ_cmp[1], civ_cmp_2[1]], 1, label = rom_label("15 TOWNS")),
    comp8(civ_box_size, civ_cmp, 2, [civ_cmp[2], civ_cmp_2[2]], 0, label = rom_label("MISC")),
    comp8(civ_box_size, civ_cmp_2, 2, [civ_cmp[2], civ_cmp_2[2]], 1, label = rom_label("MISC")),
    render_lids ? lid("CIVITATES", roman_font, AUTO, 0, 4) : no_lid(),
];

// Scotti
// 6 Settlements
// 12 Warbands
// 30 Raiders

// Saxons
// 12 Settlements
// 25 Warbands
// 25 Raiders

sax_box_size = [faction_width_up, factions_stack * 0.55, faction_height - lid_down_space];

sax_cmp = [
  [54, 52, faction_depth],
  [54, 52, faction_depth],
  [30, 70, faction_depth],
];

sax_cmp_2 = [
  [85, 35, faction_depth],
];
/*
sax_box = [ OBJECT_BOX,
    [ BOX_SIZE_XYZ, sax_box_size ],
    [ BOX_STACKABLE_B, false ],
    [ BOX_FEATURE,
        [ FTR_SHAPE, FILLET ],    
        [ FTR_SHAPE_ROTATED_B, true ],
        [ FTR_FILLET_RADIUS, faction_fr ],
        [ FTR_COMPARTMENT_SIZE_XYZ, sax_cmp[0]],
        [ FTR_PADDING_XY, [walls, walls]],
        [ POSITION_XY, cmp_offset(sax_cmp, 0) ],
        [ LABEL, 
            [ ENABLED_B, labels ],
            [ LBL_TEXT, [[ "25 Warbands" ]]],
            [ LBL_SIZE, 6 ],
            [ LBL_FONT, sax_font ],
        ],
    ],
    [ BOX_FEATURE,
        [ FTR_SHAPE, FILLET ],    
        [ FTR_SHAPE_ROTATED_B, true ],
        [ FTR_FILLET_RADIUS, faction_fr ],
        [ FTR_COMPARTMENT_SIZE_XYZ, sax_cmp[1]],
        [ FTR_PADDING_XY, [walls, walls]],
        [ POSITION_XY, cmp_offset(sax_cmp, 1) ],
        [ LABEL, 
            [ ENABLED_B, labels ],
            [ LBL_TEXT, [[ "25 Raiders" ]]],
            [ LBL_SIZE, 6 ],
            [ LBL_FONT, sax_font ],
        ],
    ],
    [ BOX_FEATURE, 
        [ FTR_SHAPE, FILLET ],    
        [ FTR_SHAPE_ROTATED_B, true ],
        [ FTR_FILLET_RADIUS, faction_fr ],
        [ FTR_COMPARTMENT_SIZE_XYZ, sax_cmp[2]],
        [ FTR_PADDING_XY, [walls, walls]],
        [ POSITION_XY, cmp_offset(sax_cmp, 2) ],
    ],
    [ BOX_FEATURE,
        [ FTR_SHAPE, FILLET ],    
        [ FTR_SHAPE_ROTATED_B, true ],
        [ FTR_FILLET_RADIUS, faction_fr ],
        [ FTR_COMPARTMENT_SIZE_XYZ, sax_cmp_2[0]],
        [ FTR_PADDING_XY, [walls, walls]],
        [ POSITION_XY, vecsum(cmp_offset(sax_cmp_2, 0), cmp_offset_y(sax_cmp, 1)) ],
        [ LABEL, 
            [ ENABLED_B, labels ],
            [ LBL_TEXT, [[ "12 Settlements" ]]],
            [ LBL_SIZE, 6 ],
            [ LBL_FONT, sax_font ],
        ],
    ],
    //lid("Saxons", sax_font, AUTO, 0, 4),
    no_lid(),
];*/

sco_box_size = [
    faction_width_up, 
    factions_stack - sax_box_size.y, 
    faction_height - lid_down_space
];

sco_cmp = [
  [54, 62, faction_depth],
  [45, 32, faction_depth],
  [30, 70, faction_depth],
];

sco_cmp_2 = [
  [45, 35, faction_depth],
];
/*
sco_box = [ OBJECT_BOX,
    [ BOX_SIZE_XYZ, sco_box_size ],
    [ BOX_STACKABLE_B, false ],
    [ BOX_FEATURE,
        [ FTR_SHAPE, FILLET ],    
        [ FTR_SHAPE_ROTATED_B, true ],
        [ FTR_FILLET_RADIUS, faction_fr ],
        [ FTR_COMPARTMENT_SIZE_XYZ, sco_cmp[0]],
        [ FTR_PADDING_XY, [walls, walls]],
        [ POSITION_XY, cmp_offset(sco_cmp, 0) ],
        [ LABEL, 
            [ ENABLED_B, labels ],
            [ LBL_TEXT, [[ "30 Raiders" ]]],
            [ LBL_SIZE, 6 ],
            [ LBL_FONT, sax_font ],
        ],
    ],
    [ BOX_FEATURE,
        [ FTR_SHAPE, FILLET ],    
        [ FTR_SHAPE_ROTATED_B, true ],
        [ FTR_FILLET_RADIUS, faction_fr ],
        [ FTR_COMPARTMENT_SIZE_XYZ, sco_cmp[1]],
        [ FTR_PADDING_XY, [walls, walls]],
        [ POSITION_XY, cmp_offset(sco_cmp, 1) ],
        [ LABEL, 
            [ ENABLED_B, labels ],
            [ LBL_TEXT, [[ "6 Settlements" ]]],
            [ LBL_SIZE, 5.5 ],
            [ LBL_FONT, sax_font ],
        ],
    ],
    [ BOX_FEATURE,
        [ FTR_SHAPE, FILLET ],    
        [ FTR_SHAPE_ROTATED_B, true ],
        [ FTR_FILLET_RADIUS, faction_fr ],
        [ FTR_COMPARTMENT_SIZE_XYZ, sco_cmp[2]],
        [ FTR_PADDING_XY, [walls, walls]],
        [ POSITION_XY, cmp_offset(sco_cmp, 2) ],
    ],
    [ BOX_FEATURE,
        [ FTR_SHAPE, FILLET ],    
        [ FTR_SHAPE_ROTATED_B, true ],
        [ FTR_FILLET_RADIUS, faction_fr ],
        [ FTR_COMPARTMENT_SIZE_XYZ, sco_cmp_2[0]],
        [ FTR_PADDING_XY, [walls, walls]],
        [ POSITION_XY, vecsum(cmp_offset(sco_cmp, 1), [0, sco_cmp[1].y + walls]) ],
        [ LABEL, 
            [ ENABLED_B, labels ],
            [ LBL_TEXT, [[ "12 Warbands" ]]],
            [ LBL_SIZE, 5.5 ],
            [ LBL_FONT, sax_font ],
        ],
    ],
    //lid("Scotti", sax_font, AUTO, 0, 4),
    no_lid(),
];*/


cards_cmp_size_pure = [GMT_CARD_SLEEVED.x, GMT_CARD_SLEEVED.y, box_height - rules];
cards_cmp_size = vecsum(cards_cmp_size_pure, [2, 2, -2]);
cards_box_size = vecsum(cards_cmp_size, [ext_walls * 2, ext_walls * 2, +2]);
cards_box = [ OBJECT_BOX,
    [ BOX_SIZE_XYZ, cards_box_size ],
    [ BOX_STACKABLE_B, false ],
    [ CHAMFER_N, 1 ],
    [ BOX_FEATURE,
        [ FTR_COMPARTMENT_SIZE_XYZ, cards_cmp_size],
        [ CHAMFER_N, 0],
        [ FTR_CUTOUT_SIDES_4B , [t, t, f, f]],
        [ FTR_CUTOUT_DEPTH_PCT, 7.5 ],
        [ LABEL, 
            [ ENABLED_B, labels ],
            [ LBL_TEXT, [[ "Cards" ]]],
            [ LBL_SIZE, 12 ],
            [ LBL_FONT, roman_font ],
        ],
    ],
    no_lid(),
];

data = [
    dux_box,
    civ_box,
    //sax_box,
    //sco_box,
    //cards_box,
];

Make(data);
