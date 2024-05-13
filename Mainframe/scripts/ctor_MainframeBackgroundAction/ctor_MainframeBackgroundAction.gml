/// @func MainframeBackgroundAction(process,callback,[order],[minduration],[minsteps])
/// @desc A mainframe background action, to be executed by the background process. It reserves a given duration and number of steps for each background processing frame.
/// @arg {Struct.MainframeBackgroundProcess} process        The process the action belongs to.
/// @arg {Function} callback                                The action callback to execute during background processing; it should accept the minimum number of steps and the target time.
/// @arg {Real} [order]                                     The value of the execution order (actions with a lower order take priority).
/// @arg {Real} [minduration]                               The minimum processing duration reserved for each frame.
/// @arg {Real} [minsteps]                                  The minimum number of processing steps reserved for each frame.
function MainframeBackgroundAction(_process, _callback, _order = 0, _minduration = 0, _minsteps = 1) constructor {
    /// @ignore
    process = _process;
    /// @ignore
    callback = _callback;
    /// @ignore
    order = _order;
    
    /// @desc The minimum processing duration reserved for each frame.
    /// @type {Real}
    min_duration = _minduration;
    
    /// @desc The minimum number of processing steps reserved for each frame.
    /// @type {Real}
    min_steps = _minsteps;
    
    /// @desc Whether the action is executed during the background process or not.
    /// @type {Bool}
    is_active = true;
    
    // -------
    // Methods
    // -------
    
    /// @ignore
    /// Internal method for executing the minimum required amount of processing each frame.
    static perform_minimum = function() {
        if (!is_active)
            return;
        
        var _min_duration_us = round(1000 * min_duration);
        var _target_time = get_timer() + _min_duration_us;
        
        callback(min_steps, _target_time);
    }
    
    /// @ignore
    /// Internal method for using the remaining available processing time to do more processing.
    static perform_until = function(_time) {
        if (!is_active)
            return;
        
        callback(0, _time);
    }
    
    /// @func activate()
    /// @desc Marks the action as active, resuming its execution if earlier suspended.
    static activate = function() {
        is_active = true;
    }
    
    /// @func deactivate()
    /// @desc Marks the action as inactive, suspending its execution until reactivation.
    static deactivate = function() {
        is_active = false;
    }
    
    /// @func remove()
    /// @desc Removes the action from its background process, so it's no longer executed.
    static remove = function() {
        process.remove(self);
    }
}
