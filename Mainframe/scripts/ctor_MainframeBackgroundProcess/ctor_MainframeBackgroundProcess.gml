/// @func MainframeBackgroundProcess(name)
/// @desc The mainframe background process, managing its actions and performing as much processing as possible.
/// @arg {String} name      The name of the background process.
function MainframeBackgroundProcess(_name) constructor {
    
    /// @desc The name of the background process.
    /// @type {String}
    name = _name;
    
    /// @ignore
    actions = [];
    
    // --------------
    // Adding actions
    // --------------
    
    /// @func add_action(callback,[order],[minduration],[minsteps])
    /// @desc Adds a callback action to the mainframe background process and returns the action.
    /// @arg {Funciton} callback        The action callback to execute during background processing; it should accept the minimum number of steps and the target time.
    /// @arg {Real} [order]             The value of the execution order (actions with a lower order take priority).
    /// @arg {Real} [minduration]       The minimum processing duration reserved for each frame.
    /// @arg {Real} [minsteps]          The minimum number of processing steps reserved for each frame.
    /// @returns {Struct.MainframeBackgroundAction}
    static add_action = function(_callback, _order = 0, _minduration = 0, _minsteps = 1) {
        var _action = new MainframeBackgroundAction(self, _callback, _order, _minduration, _minsteps);
        var _idx = array_length(actions);
        while (_idx > 0 && actions[_idx - 1].order > _order) {
            _idx--;
        }
        array_insert(actions, _idx, _action);
        return _action;
    }
    
    /// @func add_method_call(caller,name,[order],[minduration],[minsteps])
    /// @desc Adds a method call action to the mainframe background process and returns the action.
    /// @arg {Any} caller               The object, instance or struct to execute the method of.
    /// @arg {String} name              The name of the method; it should accept the minimum number of steps and the target time.
    /// @arg {Real} [order]             The value of the execution order (actions with a lower order take priority).
    /// @arg {Real} [minduration]       The minimum processing duration reserved for each frame.
    /// @arg {Real} [minsteps]          The minimum number of processing steps reserved for each frame.
    /// @returns {Struct.MainframeBackgroundAction}
    static add_method_call = function(_caller, _name, _order = 0, _minduration = 0, _minsteps = 1) {
        var _callback = mainframe_callback_method_call(_caller, _name);
        return add_action(_callback, _order, _minduration, _minsteps);
    }
    
    // ----------------
    // Removing actions
    // ----------------
    
    /// @func remove(action)
    /// @desc Removes the given action from the mainframe background process.
    /// @arg {Struct.MainframeEventAction} action       The action to remove.
    static remove = function(_action) {
        var _idx = array_get_index(actions, _action);
        if (_idx >= 0) {
            array_delete(actions, _idx, 1);
        }
    }
    
    /// @func clear()
    /// @desc Removes all actions from the mainframe background process.
    static clear = function() {
        array_resize(actions, 0);
    }
    
    // ------------------
    // Performing actions
    // ------------------
    
    /// @func perform_minimum()
    /// @desc Performs the minimum required processing for all actions in the background process.
    static perform_minimum = function() {
        for (var i = 0, _count = array_length(actions); i < _count; i++) {
            actions[i].perform_minimum();
        }
    }
    
    /// @func perform_until(time)
    /// @desc Uses the remaining available time to perform the additional processing for the background process actions.
    /// @arg {Real} time        The moment until which the additional processing can be executed.
    static perform_until = function(_time) {
        for (var i = 0, _count = array_length(actions); i < _count; i++) {
            actions[i].perform_until(_time);
            if (get_timer() > _time)
                break;
        }
    }
}
