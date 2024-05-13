/// @description Draw GUI End action + Post-Frame

draw_gui_end_event.perform();

var _frame_margin_us = round(1000 * frame_margin);
var _target_time = next_frame_time - _frame_margin_us;
post_frame_process.perform_minimum();
post_frame_process.perform_until(_target_time);
