/// @func MainframeEventAction(event,callback,[order])
/// @desc A mainframe event action, to be executed by the event.
/// @arg {Struct.MainframeEvent} event      The event the action belongs to.
/// @arg {Function} callback                The action callback to execute during the event processing.
/// @arg {Real} [order]                     The value of the execution order (actions with a lower order are executed first).
function MainframeEventAction(_event, _callback, _order = 0) constructor {
    /// @ignore
    event = _event;
    /// @ignore
    callback = _callback;
    /// @ignore
    order = _order;
    
    /// @desc Whether the action is executed during its event or not.
    /// @type {Bool}
    is_active = true;
    
    // -------
    // Methods
    // -------
    
    /// @ignore
    /// Internal method for executing the action if active.
    static perform = function() {
        if (!is_active)
            return;
        
        callback();
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
    /// @desc Removes the action from its events, so it's no longer executed.
    static remove = function() {
        event.remove(self);
    }
}
