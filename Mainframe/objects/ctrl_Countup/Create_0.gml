/// @description Counter setup

counter = 0;
target = 100_000_000;

count_up = function(_steps, _time) {
    if (counter >= target)
        return;
    
    repeat (_steps) {
        counter++;
        
        if (counter >= target)
            return;
    }
    
    while (get_timer() <= _time) {
        counter++;
        
        if (counter >= target)
            return;
    }
}

count_up_action = mainframe_post_frame_add_method_call(id, "count_up");
