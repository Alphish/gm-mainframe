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
    // the method might be used by an event action or a post-frame process action alike
    // so "steps" and "time" argument are passed to the resulting callback
    // for event actions, no arguments will be passed
    // so a method used for an event action should be parameterless as well
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

/// @func mainframe_event_add_action(event,callback,[order])
/// @desc Adds a callback action to the given mainframe event and returns the action.
/// @arg {Struct.MainframeEvent,String} event       The event to add the action to.
/// @arg {Function} callback                        The action callback to execute during the event processing.
/// @arg {Real} [order]                             The value of the execution order (actions with a lower order are executed first).
/// @returns {Struct.MainframeEventAction}
function mainframe_event_add_action(_event, _callback, _order = 0) {
    var _resolved_event = mainframe_get_event(_event);
    return _resolved_event.add_action(_callback, _order);
}

/// @func mainframe_event_add_user_event(event,object,number,[order])
/// @desc Adds a user event action to the given mainframe event and returns the action.
/// @arg {Struct.MainframeEvent,String} event       The event to add the action to.
/// @arg {Asset.GMObject,Id.Instance} object        The object or instance to execute the user event of.
/// @arg {Real} number                              The number of the user event.
/// @arg {Real} [order]                             The value of the execution order (actions with a lower order are executed first).
/// @returns {Struct.MainframeEventAction}
function mainframe_event_add_user_event(_event, _object, _number, _order = 0) {
    var _resolved_event = mainframe_get_event(_event);
    return _resolved_event.add_user_event(_object, _number, _order);
}

/// @func mainframe_event_add_method_call(event,caller,name,[order])
/// @desc Adds a method call action to the given mainframe event and returns the action.
/// @arg {Struct.MainframeEvent,String} event       The event to add the action to.
/// @arg {Any} caller                               The object, instance or struct to execute the method of.
/// @arg {String} name                              The name of the method.
/// @arg {Real} [order]                             The value of the execution order (actions with a lower order are executed first).
/// @returns {Struct.MainframeEventAction}
function mainframe_event_add_method_call(_event, _caller, _name, _order = 0) {
    var _resolved_event = mainframe_get_event(_event);
    return _resolved_event.add_method_call(_caller, _name, _order);
}

/// @func mainframe_begin_step_add_action(callback,[order])
/// @desc Adds a callback action to the Begin Step mainframe event and returns the action.
/// @arg {Function} callback        The action callback to execute during the event processing.
/// @arg {Real} [order]             The value of the execution order (actions with a lower order are executed first).
/// @returns {Struct.MainframeEventAction}
function mainframe_begin_step_add_action(_callback, _order = 0) {
    return mainframe_event_add_action("begin_step", _callback, _order);
}

/// @func mainframe_begin_step_add_user_event(object,number,[order])
/// @desc Adds a user event action to the Begin Step mainframe event and returns the action.
/// @arg {Asset.GMObject,Id.Instance} object        The object or instance to execute the user event of.
/// @arg {Real} number                              The number of the user event.
/// @arg {Real} [order]                             The value of the execution order (actions with a lower order are executed first).
/// @returns {Struct.MainframeEventAction}
function mainframe_begin_step_add_user_event(_object, _number, _order = 0) {
    return mainframe_event_add_user_event("begin_step", _object, _number, _order);
}

/// @func mainframe_begin_step_add_method_call(caller,name,[order])
/// @desc Adds a method call action to the Begin Step mainframe event and returns the action.
/// @arg {Any} caller       The object, instance or struct to execute the method of.
/// @arg {String} name      The name of the method.
/// @arg {Real} [order]     The value of the execution order (actions with a lower order are executed first).
/// @returns {Struct.MainframeEventAction}
function mainframe_begin_step_add_method_call(_caller, _name, _order = 0) {
    return mainframe_event_add_method_call("begin_step", _caller, _name, _order);
}

/// @func mainframe_step_add_action(callback,[order])
/// @desc Adds a callback action to the Step mainframe event and returns the action.
/// @arg {Function} callback        The action callback to execute during the event processing.
/// @arg {Real} [order]             The value of the execution order (actions with a lower order are executed first).
/// @returns {Struct.MainframeEventAction}
function mainframe_step_add_action(_callback, _order = 0) {
    return mainframe_event_add_action("step", _callback, _order);
}

/// @func mainframe_step_add_user_event(object,number,[order])
/// @desc Adds a user event action to the Step mainframe event and returns the action.
/// @arg {Asset.GMObject,Id.Instance} object        The object or instance to execute the user event of.
/// @arg {Real} number                              The number of the user event.
/// @arg {Real} [order]                             The value of the execution order (actions with a lower order are executed first).
/// @returns {Struct.MainframeEventAction}
function mainframe_step_add_user_event(_object, _number, _order = 0) {
    return mainframe_event_add_user_event("step", _object, _number, _order);
}

/// @func mainframe_step_add_method_call(caller,name,[order])
/// @desc Adds a method call action to the Step mainframe event and returns the action.
/// @arg {Any} caller       The object, instance or struct to execute the method of.
/// @arg {String} name      The name of the method.
/// @arg {Real} [order]     The value of the execution order (actions with a lower order are executed first).
/// @returns {Struct.MainframeEventAction}
function mainframe_step_add_method_call(_caller, _name, _order = 00) {
    return mainframe_event_add_method_call("step", _caller, _name, _order);
}

/// @func mainframe_draw_gui_end_add_action(callback,[order])
/// @desc Adds a callback action to the Draw GUI End mainframe event and returns the action.
/// @arg {Function} callback        The action callback to execute during the event processing.
/// @arg {Real} [order]             The value of the execution order (actions with a lower order are executed first).
/// @returns {Struct.MainframeEventAction}
function mainframe_draw_gui_end_add_action(_callback, _order = 0) {
    return mainframe_event_add_action("draw_gui_end", _callback, _order);
}

/// @func mainframe_draw_gui_end_add_user_event(object,number,[order])
/// @desc Adds a user event action to the Draw GUI End mainframe event and returns the action.
/// @arg {Asset.GMObject,Id.Instance} object        The object or instance to execute the user event of.
/// @arg {Real} number                              The number of the user event.
/// @arg {Real} [order]                             The value of the execution order (actions with a lower order are executed first).
/// @returns {Struct.MainframeEventAction}
function mainframe_draw_gui_end_add_user_event(_object, _number, _order = 0) {
    return mainframe_event_add_user_event("draw_gui_end", _object, _number, _order);
}

/// @func mainframe_draw_gui_end_add_method_call(caller,name,[order])
/// @desc Adds a method call action to the Draw GUI End mainframe event and returns the action.
/// @arg {Any} caller       The object, instance or struct to execute the method of.
/// @arg {String} name      The name of the method.
/// @arg {Real} [order]     The value of the execution order (actions with a lower order are executed first).
/// @returns {Struct.MainframeEventAction}
function mainframe_draw_gui_end_add_method_call(_caller, _name, _order = 0) {
    return mainframe_event_add_method_call("draw_gui_end", _caller, _name, _order);
}

// ---------------------
// Post-frame processing
// ---------------------

/// @func mainframe_post_frame_add_action(callback,[order],[minduration],[minsteps])
/// @desc Adds a callback post-frame action and returns it.
/// @arg {Function} callback        The action callback to execute during post-frame processing; it should accept the minimum number of steps and the target time.
/// @arg {Real} [order]             The value of the execution order (actions with a lower order take priority).
/// @arg {Real} [minduration]       The minimum processing duration reserved for each frame.
/// @arg {Real} [minsteps]          The minimum number of processing steps reserved for each frame.
/// @returns {Struct.MainframePostFrameAction}
function mainframe_post_frame_add_action(_callback, _order = 0, _minduration = 0, _minsteps = 1) {
    var _process = mainframe_get().post_frame_process;
    return _process.add_action(_callback, _order, _minduration, _minsteps);
}

/// @func mainframe_post_frame_add_method_call(caller,name,[order],[minduration],[minsteps])
/// @desc Adds a method call post-frame action and returns it.
/// @arg {Any} caller               The object, instance or struct to execute the method of.
/// @arg {String} name              The name of the method; it should accept the minimum number of steps and the target time.
/// @arg {Real} [order]             The value of the execution order (actions with a lower order take priority).
/// @arg {Real} [minduration]       The minimum processing duration reserved for each frame.
/// @arg {Real} [minsteps]          The minimum number of processing steps reserved for each frame.
/// @returns {Struct.MainframePostFrameAction}
function mainframe_post_frame_add_method_call(_caller, _name, _order = 0, _minduration = 0, _minsteps = 1) {
    var _process = mainframe_get().post_frame_process;
    return _process.add_method_call(_caller, _name, _order, _minduration, _minsteps);
}

/// @func mainframe_set_frame_margin(margin)
/// @desc Sets the Mainframe frame margin (in milliseconds). Larger frame margins leave less time for post-frame processing, but leave more leeway to maintain a stable framerate.
/// @arg {Real} margin          The new frame margin (in milliseconds).
function mainframe_set_frame_margin(_margin) {
    mainframe_get().frame_margin = _margin;
}

/// @func mainframe_set_frame_duration(duration)
/// @desc Sets the Mainframe frame duration (in milliseconds), overriding the game speed based duration. Larger duration will leave more time for post-frame processing, but will lead to a lower framerate.
/// @arg {Real} duration        The new frame duration (in milliseconds).
function mainframe_set_frame_duration(_duration) {
    mainframe_get().frame_duration = _duration;
}

/// @func mainframe_clear_frame_duration()
/// @desc Clears the Mainframe frame duration, so that desired frame duration is based on the game speed instead.
function mainframe_clear_frame_duration() {
    mainframe_get().frame_duration = undefined;
}
