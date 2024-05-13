// --------
// Instance
// --------

/// @func mainframe_get()
/// @desc Retrieves the mainframe instance, or throws an error if none is found.
/// @returns {Id.Instance<sys_Mainframe>}
function mainframe_get() {
    if (!instance_exists(sys_Mainframe))
        throw MainframeException.instance_not_found();
    
    return sys_Mainframe.id;
}

// ---------
// Callbacks
// ---------

/// @func mainframe_callback_user_event(object,number)
/// @desc Creates a callback that executes a user event for the given object or instance.
/// @arg {Asset.GMObject,Id.Instance} object        The object or instance to execute the user event of.
/// @arg {Real} number                              The number of the user event.
/// @returns {Function}
function mainframe_callback_user_event(_object, _number) {
    return method({ object: _object, number: _number }, function() {
        var _object = object;
        var _number = number;
        with (_object) {
            event_user(_number);
        }
    });
}

/// @func mainframe_callback_method_call(caller,name)
/// @desc Creates a callback that calls a method of the given object, instance or struct.
/// @arg {Any} caller       The object, instance or struct to execute the method of.
/// @arg {String} name      The name of the method.
/// @returns {Function}
function mainframe_callback_method_call(_caller, _name) {
    // the method might be used by an event action or a background process action, depending on a specific method
    // so "steps" and "time" argument are passed to the resulting callback
    // for event actions, these arguments will be skipped during the call
    // and they should be skipped by the referenced method as well
    return method({ caller: _caller, method_name: _name }, function(_steps, _time) {
        var _caller = caller;
        var _name = method_name;
        with (_caller) {
            var _method = self[$ _name];
            _method(_steps, _time);
        }
    });
}

// ------
// Events
// ------

/// @func mainframe_get_event(event)
/// @desc Retrieves a mainframe event to manage actions of.
/// @arg {Struct.MainframeEvent,String} event       The name of the event, or the event itself.
/// @returns {Struct.MainframeEvent}
function mainframe_get_event(_event) {
    if (is_instanceof(_event, MainframeEvent))
        return _event;
    
    if (is_string(_event)) {
        var _key = string_lower(_event);
        var _named_event = mainframe_get().events[$ _key];
        if (!is_instanceof(_named_event, MainframeEvent))
            throw MainframeException.event_not_found($"Could not find a mainframe event by name '{_event}'.");
        
        return _named_event;
    }
    
    if (is_struct(_event))
        throw MainframeException.event_not_found($"Cannot resolve a mainframe event using a {instanceof(_event)} structure.");
    else
        throw MainframeException.event_not_found($"Cannot resolve a mainframe event using a {typeof(_event)} value.");
}
