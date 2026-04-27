include <common.scad>;

// 

use <vendor/fonts/NotoEmoji-Regular.ttf>;
emoji_font = "Noto Emoji, Regular";

use <vendor/fonts/Cinzel-Regular.ttf>;
roman_font = "Cinzel";


use <vendor/fonts/Gaeilge.ttf>;
sax_font = "Gaeilge";


profiles = "labels lids";
//profiles = "labels";
//profiles = "";

labels = contains(profiles, "labels");
render_lids = contains(profiles, "lids");


box_width = 218;
box_length = 294;
box_height = 74;

rules = 35.0;



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
    
function rom_label(text = "", size = AUTO) = 
    [ LABEL, 
        [ ENABLED_B, labels ],
        [ LBL_TEXT, [[ text ]]],
        [ LBL_SIZE, size ],
        [ LBL_FONT, roman_font ],
    ];
    
function sax_label(text = "", size = AUTO) = 
    [ LABEL, 
        [ ENABLED_B, labels ],
        [ LBL_TEXT, [[ text ]]],
        [ LBL_SIZE, size ],
        [ LBL_FONT, sax_font ],
    ];

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

faction_depth = 14;
faction_height = (box_height - rules) / 2;
faction_width_bottom = box_width - 35; // box_length - cards_box_size.y;
faction_width_up = faction_width_bottom - 10;
factions_stack = box_length - cards_box_size.y;


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
    comp8(dux_box_size, dux_cmp, 0, label = rom_label("20 CAVALRY", 5)),
    comp8(dux_box_size, dux_cmp, 1, label = rom_label("10 FORTS", 5)),
    comp8(dux_box_size, dux_cmp, 2, label = rom_label("MISC", 5)),
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
civ_cmp_chamferred = append_each(civ_cmp_pure, inner_chamfer_add_vector);
civ_cmp = extend_cmp_x(civ_box_size, civ_cmp_chamferred, [2]);

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
    [ CHAMFER_N, 1 ],
    [ BOX_STACKABLE_B, false ],
    comp8(civ_box_size, civ_cmp, 0, [civ_cmp[0], civ_cmp_2[0]], 0, label = rom_label("15 COMITATES", 5)),
    comp8(civ_box_size, civ_cmp_2, 0, [civ_cmp[0], civ_cmp_2[0]], 1, label = rom_label("30 MILITIA", 5)),
    comp8(civ_box_size, civ_cmp, 1, [civ_cmp[1], civ_cmp_2[1]], 0, label = rom_label("15 HILLFORTS", 5)),
    comp8(civ_box_size, civ_cmp_2, 1, [civ_cmp[1], civ_cmp_2[1]], 1, label = rom_label("15 TOWNS", 5)),
    comp8(civ_box_size, civ_cmp, 2, [civ_cmp[2], civ_cmp_2[2]], 0, label = rom_label("MISC", 5)),
    comp8(civ_box_size, civ_cmp_2, 2, [civ_cmp[2], civ_cmp_2[2]], 1, label = rom_label("MISC", 5)),
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

sax_cmp_pure = [
  [50, 50, faction_depth],
  [50, 50, faction_depth],
  [30, 50, faction_depth],
];
sax_cmp_chamferred = append_each(sax_cmp_pure, inner_chamfer_add_vector);
sax_cmp = extend_cmp_x(sax_box_size, sax_cmp_chamferred, [2]);

sax_cmp_2_pure = [
  [83, 32, faction_depth],
  [30, 32, faction_depth],
];
sax_cmp_2_chamferred = append_each(sax_cmp_2_pure, inner_chamfer_add_vector);
sax_cmp_2 = extend_cmp_x(sax_box_size, sax_cmp_2_chamferred, [1]);

sax_box = [ OBJECT_BOX,
    [ BOX_SIZE_XYZ, sax_box_size ],
    [ CHAMFER_N, 1 ],
    [ BOX_STACKABLE_B, false ],
    comp8(sax_box_size, sax_cmp, 0, [sax_cmp[0], sax_cmp_2[0]], 0, label = sax_label("25 Raiders")),
    comp8(sax_box_size, sax_cmp, 1, [sax_cmp[1], sax_cmp_2[0]], 0, label = sax_label("25 Warbands")),
    comp8(sax_box_size, sax_cmp, 2, [sax_cmp[2], sax_cmp_2[1]], 0, label = sax_label("Misc")),
    comp8(sax_box_size, sax_cmp_2, 0, [sax_cmp[0], sax_cmp_2[0]], 1, label = sax_label("12 Settlements")),
    comp8(sax_box_size, sax_cmp_2, 1, [sax_cmp[2], sax_cmp_2[1]], 1, label = sax_label("Misc")),
    render_lids ? lid("Saxons", sax_font, AUTO, 0, 4) : no_lid(),
];

sco_box_size = [
    faction_width_up, 
    factions_stack - sax_box_size.y, 
    faction_height - lid_down_space
];

sco_cmp_pure = [
  [50, 60, faction_depth],
  [40, 30, faction_depth],
  [30, 30, faction_depth],
];
sco_cmp_chamferred = append_each(sco_cmp_pure, inner_chamfer_add_vector);
sco_cmp = extend_cmp_x(sco_box_size, sco_cmp_chamferred, [2]);

sco_cmp_2_pure = [
  [50, 60, faction_depth],
  [45, 32, faction_depth],
  [30, 32, faction_depth],
];
sco_cmp_2_chamferred = append_each(sco_cmp_2_pure, inner_chamfer_add_vector);
sco_cmp_2 = extend_cmp_x(sco_box_size, sco_cmp_2_chamferred, [2]);

sco_box = [ OBJECT_BOX,
    [ BOX_SIZE_XYZ, sco_box_size ],
    [ CHAMFER_N, 1 ],
    [ BOX_STACKABLE_B, false ],
    comp8(sco_box_size, sco_cmp, 0, [sco_cmp[0]], 0, label = sax_label("30 Raiders")),
    comp8(sco_box_size, sco_cmp, 1, [sco_cmp[1], sco_cmp_2[1]], 0, label = sax_label("30 Warbands")),
    comp8(sco_box_size, sco_cmp, 2, [sco_cmp[2], sco_cmp_2[2]], 0, label = sax_label("Misc")),
    comp8(sco_box_size, sco_cmp_2, 1, [sco_cmp[1], sco_cmp_2[1]], 1, label = sax_label("6 Settlements")),
    comp8(sco_box_size, sco_cmp_2, 2, [sco_cmp[2], sco_cmp_2[2]], 1, label = sax_label("Misc")),
    render_lids ? lid("Scotti", sax_font, AUTO, 0, 4) : no_lid(),
];


prosp_box_size = [factions_stack / 2, box_width - faction_width_bottom, faction_height - lid_down_space];
prosp_cmp_pure = [
    [80, prosp_box_size.y - 2 * ext_walls - inner_chamfer_add_vector.y, faction_depth]
];
prosp_cmp_chamferred = append_each(prosp_cmp_pure, inner_chamfer_add_vector);
prosp_cmp = extend_cmp_x(prosp_box_size, prosp_cmp_chamferred, [0]);

prosp_box = [ OBJECT_BOX,
    [ BOX_SIZE_XYZ, prosp_box_size ],
    [ CHAMFER_N, 1 ],
    [ BOX_STACKABLE_B, false ],
    comp8(prosp_box_size, prosp_cmp, 0, [prosp_cmp[0]], 0, label = roman_label("Prosperity")),
    render_lids ? lid("Prosperity", roman_font, AUTO, 0, 4) : no_lid(),
];

tok_box_size = [factions_stack, box_width - faction_width_up, faction_height - lid_down_space];
tok_cmp_y_max = tok_box_size.y - 2 * ext_walls - inner_chamfer_add_vector.y;
tok_cmp_pure = [
  [40, tok_cmp_y_max, faction_depth],
  [25, tok_cmp_y_max, faction_depth],
  [40, tok_cmp_y_max, faction_depth],
  [50, tok_cmp_y_max, faction_depth],
];
tok_cmp_chamferred = append_each(tok_cmp_pure, inner_chamfer_add_vector);
tok_cmp = extend_cmp_x(tok_box_size, tok_cmp_chamferred, [3]);

tok_box = [ OBJECT_BOX,
    [ BOX_SIZE_XYZ, tok_box_size ],
    [ CHAMFER_N, 1 ],
    [ BOX_STACKABLE_B, false ],
    comp8(tok_box_size, tok_cmp, 0, label = rom_label("Pop 0-1", 5)),
    comp8(tok_box_size, tok_cmp, 1, label = rom_label("Pop 2-4", 5)),
    comp8(tok_box_size, tok_cmp, 2, label = rom_label("Foederati", 5)),
    comp8(tok_box_size, tok_cmp, 3, label = rom_label("Other", 5)),
    render_lids ? lid("Markers", roman_font, AUTO, 0, 4) : no_lid(),
];

cubes_box_height = 20;
cubes_box_size = [box_width - 2 * cards_box_size.x, cards_box_size.y, cubes_box_height];
cubes_cmp = extend_cmp_x(cubes_box_size, [[10, 46, 18]], [0]);
cubes_cmp_2 = extend_cmp_x(cubes_box_size, [[10, 45, 18]], [0]);
cubes_box = [ OBJECT_BOX,
    [ BOX_SIZE_XYZ, cubes_box_size ],
    [ CHAMFER_N, 1 ],
    [ BOX_STACKABLE_B, false ],
    comp8(cubes_box_size, cubes_cmp, 0, [cubes_cmp[0], cubes_cmp_2[0]], 0, label = rom_label("Cubes", 8)),
    comp8(cubes_box_size, cubes_cmp_2, 0, [cubes_cmp[0], cubes_cmp_2[0]], 1, label = rom_label("Pawns", 8)),
    lid("ignore"),
];

control_box_size = [cubes_box_size.x, cubes_box_size.y, cards_box_size.z - cubes_box_height - lid_down_space - 1];
control_cmp = extend_cmp_x(control_box_size, [[10, 64, control_box_size - 2]], [0]);
control_cmp_2 = extend_cmp_x(control_box_size, [[10, 24, control_box_size - 2]], [0]);
control_box = [ OBJECT_BOX,
    [ BOX_SIZE_XYZ, control_box_size ],
    [ CHAMFER_N, 1 ],
    [ BOX_STACKABLE_B, true ],
    comp8(control_box_size, control_cmp, 0, [control_cmp[0], control_cmp_2[0]], 0, label = rom_label("Control", 8)),
    comp8(control_box_size, control_cmp_2, 0, [control_cmp[0], control_cmp_2[0]], 1, label = rom_label("Start", 8)),
    render_lids ? lid("Start & Control", roman_font, AUTO, 90, 4) : no_lid(),
];

data = [
    //cards_box,
    //dux_box,
    //civ_box,
    //sax_box,
    //sco_box,
    //prosp_box,
    //tok_box,
    //cubes_box,
    control_box,
];

Make(data);
