/// @desc The event subjects manager for a specific owner entity.
/// @arg {Struct.MainframeEventManager} manager     The broader events manager.
/// @arg {Any} owner                                The event subject owner.
function MainframeEventOwnerManager(_manager, _owner) constructor {
    /// @desc The events manager the owner manager belongs to.
    /// @returns {Struct.MainframeEventManager}
    manager = _manager;
    
    /// @desc The owner the events subjects belong to.
    /// @returns {Any}
    owner = _owner;
    
    /// @desc The event subjects.
    /// @returns {Struct}
    subjects = {};
    
    /// @desc Checks whether the owner has an active event with the given key.
    /// @arg {String} key       The event subject key.
    /// @returns {Bool}
    static has_event = function(_key) {
        return struct_exists(subjects, _key);
    }
    
    /// @desc Creates an event subject with the given key.
    /// @arg {String} key           The event subject key.
    /// @arg {Bool} [removeempty]   Whether the event should be automatically cleaned up and removed when turning empty.
    /// @returns {Struct.MainframeEventSubject}
    static create_event = function(_key, _removeempty = true) {
        if (struct_exists(subjects, _key))
            throw MainframeException.event_subject_already_exists(owner, _key);
        
        var _event = new MainframeEventSubject(self, _key, _removeempty);
        subjects[$ _key] = _event;
        return _event;
    }
    
    /// @desc Gets or creates an event subject with the given key.
    /// @arg {String} key       The event subject key.
    /// @returns {Struct}
    static get_event = function(_key) {
        var _event = subjects[$ _key];
        if (!is_undefined(_event))
            return _event;
        
        _event = new MainframeEventSubject(self, _key);
        subjects[$ _key] = _event;
        return _event;
    }
    
    /// @desc Sets an event subject with the given key. If another event already exists, it cleans it up.
    /// @arg {String} key       The event subject key.
    /// @arg {Struct} event     The event subject to use.
    /// @returns {Struct}
    static set_event = function(_key, _event) {
        var _previous_event = subjects[$ _key];
        if (!is_undefined(_previous_event))
            _previous_event.cleanup();
        
        subjects[$ _key] = _event;
        return _event;
    }
    
    /// @desc Attempts to send an event with a given optional data and claimed sender. No event is sent if there is no subject.
    /// @arg {String} key       The event subject key.
    /// @arg {Any} [data]       The data to send, if any.
    /// @arg {Any} [sender]     The entity to claim as the event sender, if any.
    static send_event = function(_key, _data = undefined, _sender = undefined) {
        var _event = subjects[$ _key];
        if (!is_undefined(_event))
            _event.send(_data, _sender);
    }
    
    /// @desc Cleans up and removes an event subject with the given key. Returns whether there was an event subject to remove in the first place.
    /// @arg {String} key       The event subject key.
    /// @returns {Bool}
    static remove_event = function(_owner, _key) {
        var _event = subjects[$ _key];
        if (is_undefined(_event))
            return false;
        
        struct_remove(subjects, _key); // removing event first to prevent potential remove-cleanup recursion
        _event.cleanup();
        return true;
    }
    
    /// @desc Cleans up all subjects. Returns true to indicate a successful removal from the top-level manager perspective.
    /// @returns {Bool}
    static remove = function() {
        struct_foreach(subjects, function(_key, _value) {
            _value.cleanup();
        });
        manager.remove_owner(owner);
        return true;
    }
}