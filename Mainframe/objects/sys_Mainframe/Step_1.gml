/// @description Estimate time + Begin Step actions

var _current_time = get_timer();
var _duration_us = !is_undefined(frame_duration)
    ? round(frame_duration * 1000)
    : game_get_speed(gamespeed_microseconds);
next_frame_time = _current_time + _duration_us;

begin_step_event.perform();
