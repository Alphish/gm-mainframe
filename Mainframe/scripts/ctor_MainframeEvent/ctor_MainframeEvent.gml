/// @func MainframeEvent(name)
/// @desc A mainframe event, managing and executing its actions.
/// @arg {String} name      The name of the event.
function MainframeEvent(_name) constructor {
    
    /// @desc The name of the event.
    /// @type {String}
    name = _name;
    
    /// @ignore
    actions = [];
    
    // --------------
    // Adding actions
    // --------------
    
    /// @func add_action(callback,[order])
    /// @desc Adds a callback action to the mainframe event and returns the action.
    /// @arg {Function} callback        The action callback to execute during event processing.
    /// @arg {Real} [order]             The value of the execution order (actions with a lower order are executed first).
    /// @returns {Struct.MainframeEventAction}
    static add_action = function(_callback, _order = 0) {
        var _action = new MainframeEventAction(self, _callback, _order);
        var _idx = array_length(actions);
        while (_idx > 0 && actions[_idx - 1].order > _order) {
            _idx--;
        }
        array_insert(actions, _idx, _action);
        return _action;
    }
    
    /// @func add_user_event(object,number,[order])
    /// @desc Adds a user event action to the mainframe event and returns the action.
    /// @arg {Asset.GMObject,Id.Instance} object        The object or instance to execute the user event of.
    /// @arg {Real} number                              The number of the user event.
    /// @arg {Real} [order]                             The value of the execution order (actions with a lower order are executed first).
    /// @returns {Struct.MainframeEventAction}
    static add_user_event = function(_object, _number, _order = 0) {
        var _callback = mainframe_callback_user_event(_object, _number);
        return add_action(_callback, _order);
    }
    
    /// @func add_method_call(caller,name,[order])
    /// @desc Adds a method call action to the mainframe event and returns the action.
    /// @arg {Any} caller               The object, instance or struct to execute the method of.
    /// @arg {String} name              The name of the method.
    /// @arg {Real} [order]             The value of the execution order (actions with a lower order are executed first).
    /// @returns {Struct.MainframeEventAction}
    static add_method_call = function(_caller, _name, _order = 0) {
        var _callback = mainframe_callback_method_call(_caller, _name);
        return add_action(_callback, _order);
    }
    
    // ----------------
    // Removing actions
    // ----------------
    
    /// @func remove(action)
    /// @desc Removes the given action from the mainframe event.
    /// @arg {Struct.MainframeEventAction} action       The action to remove.
    static remove = function(_action) {
        var _idx = array_get_index(actions, _action);
        if (_idx >= 0) {
            array_delete(actions, _idx, 1);
        }
    }
    
    /// @func clear()
    /// @desc Removes all actions from the mainframe event.
    static clear = function() {
        array_resize(actions, 0);
    }
    
    // ------------------
    // Performing actions
    // ------------------
    
    /// @func perform()
    /// @desc Performs all the active actions currently associated with the event.
    static perform = function() {
        for (var i = 0, _count = array_length(actions); i < _count; i++) {
            actions[i].perform();
        }
    }
}
