on_step = mainframe_own_event("step");
on_step.add_handler(function() {
    effect_create_layer(layer, ef_smokeup, room_width div 2, room_height div 2, current_second mod 3, c_white);
});
on_second = mainframe_own_event("second");
on_second.add_handler(function(_value) {
    show_debug_message(_value);
});

previous_second = current_second;
