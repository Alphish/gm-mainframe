draw_set_color(merge_color(c_orange, c_black, 0.75));
draw_set_alpha(0.2);

array_foreach(bits, function(_bit) {
    draw_rectangle(_bit.x, _bit.y, _bit.x + _bit.width - 1, _bit.y + _bit.height - 1, false);
});

draw_set_color(c_white);
draw_set_alpha(1);
