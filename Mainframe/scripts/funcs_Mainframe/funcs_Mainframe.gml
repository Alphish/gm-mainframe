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

/// @desc Cleans up an owner of Mainframe event subjects. Returns whether there was the owner to remove in the first place.
/// @arg {Any} owner        The event subject owner to remove.
/// @returns {Bool}
function mainframe_event_remove_owner(_owner) {
    // checking sys_Mainframe for existence before removal unlike other functions
    // because removal is likely to occur on instance cleanup - including game end - and Mainframe may clean itself up before others
    if (!instance_exists(sys_Mainframe) || sys_Mainframe.event_manager.is_cleaned())
        return false;
    
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
