function DemoTaskProcessor(_total) constructor {
    status = false;
    result = undefined;
    error = undefined;
    
    current_step = 0;
    total_steps = _total;
    
    static init = function() {
        // nothing by default
    }
    
    static process_step = function() {
        if (keyboard_check_pressed(ord("E")))
            throw $"ERROR AT {current_step}/{total_steps}";
        
        current_step += 1;
        if (current_step >= total_steps)
            return complete_with(current_step);
        else
            return false;
    }
    
    static handle_exception = function(_exception) {
        fail_with(_exception);
    }
    
    static finish = function() {
        status = true;
        process_step = function() { return true; };
        return true;
    }
    
    static complete_with = function(_result) {
        result = _result;
        return finish();
    }
    
    static fail_with = function(_error) {
        error = _error;
        return finish();
    }
    
    static is_finished = function() {
        return bool(status);
    }
    
    static cleanup = function(_auto = false) {
        finish();
    }
}
