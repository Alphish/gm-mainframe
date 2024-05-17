/// @description Draw GUI End action + Post-frame

draw_gui_end_event.perform();

post_frame_process.perform_reserved();

var _frame_margin_us = round(1000 * frame_margin);
var _target_time = next_frame_time - _frame_margin_us;
post_frame_process.perform_additional(_target_time);
