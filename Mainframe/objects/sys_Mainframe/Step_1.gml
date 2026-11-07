postframe_limit = get_timer() + (postframe_frame_duration ?? game_get_speed(gamespeed_microseconds)) - postframe_margin;
