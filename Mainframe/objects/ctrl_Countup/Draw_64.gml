/// @description Drawing instructions + progress

// top and bottom bars to display instructions/informations
draw_set_alpha(0.7);
draw_set_color(c_black);
draw_rectangle(0, room_height - 20, room_width, room_height, false);
draw_rectangle(0, 0, room_width, 19, false);

// progress bar at the bottom
draw_set_alpha(0.7);
draw_set_color(c_teal);
draw_rectangle(0, room_height - 20, round(room_width * counter / target), room_height, false);

// instructions and informations text
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(fnt_Default);

draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text(10, 10, $"Use arrow keys or WASD to move | Press space to toggle dirt GFX");
draw_text(10, room_height - 10, $"Background work done: {string_format(100 * counter / target, 0, 0)}%");
draw_text(room_width - 280, room_height - 10, $"Effective FPS: {fps_real}");
