/// @desc Gets the Mainframe event manager.
/// @returns {Struct.MainframeEventManager}
function mainframe_get_event_manager() {
    return sys_Mainframe.event_manager;
}

/// @desc Gets or creates a Mainframe event subject for the given owner and key.
/// @arg {Any} owner        The event subject owner.
/// @arg {String} key       The event subject key.
/// @returns {Struct}
function mainframe_get_event(_owner, _key) {
    return sys_Mainframe.event_manager.get_event(_owner, _key);
}

/// @desc Gets or creates own Mainframe event subject with the given key.
/// @arg {String} key       The event subject key.
/// @returns {Struct}
function mainframe_own_event(_key) {
    if (instance_exists(self))
        return mainframe_get_event(id, _key);
    else
        return mainframe_get_event(self, _key);
}

/// @desc Attempts to send an event from the given owner, with an optional data and claimed sender. The event won't be sent in the absence of the owner or the subject.
/// @arg {Struct.MainframeEventOwnerManager} owner      The event owner.
/// @arg {String} key                                   The event subject key.
/// @arg {Any} [data]                                   The event data to send, if any.
/// @arg {Any} [sender]                                 The entity to claim as the event sender, if any.
function mainframe_owner_send_event(_owner, _key, _data = undefined, _sender = undefined) {
    if (!is_undefined(_owner))
        _owner.send_event(_key, _data, _sender);
}

/// @desc Cleans up an owner of Mainframe event subjects. Returns whether there was the owner to remove in the first place.
/// @arg {Any} owner        The event subject owner to remove.
/// @returns {Bool}
function mainframe_event_remove_owner(_owner) {
    return sys_Mainframe.event_manager.remove_owner(_owner);
}

/// @desc Cleans up own Mainframe event subjects. Returns whether self was registered as the event subjects owner in the first place.
/// @arg {Any} owner        The event subject owner to remove.
/// @returns {Bool}
function mainframe_event_remove_self() {
    if (instance_exists(self))
        return mainframe_event_remove_owner(id);
    else
        return mainframe_event_remove_owner(self);
}
