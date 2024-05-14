counter = 0;
target = 100_000_000;

count_up = function(_steps, _time) {
    if (counter >= target)
        return;
    
    repeat (_steps) {
        counter++;
        
        if (counter >= target)
            break;
    }
    
    while (get_timer() <= _time) {
        counter++;
        
        if (counter >= target)
            break;
    }
}

mainframe_background_add_method_call(id, "count_up");
