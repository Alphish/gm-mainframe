/// @desc An event manager, creating and cleaning up events as needed.
function MainframeEventManager() constructor {
    /// @ignore
    subject_groups_by_owner = ds_map_create();
    
    /// @ignore
    static access_subject_group = function(_owner) {
        var _subject_group = subject_groups_by_owner[? _owner];
        if (!is_undefined(_subject_group))
            return _subject_group;
        
        _subject_group = {};
        subject_groups_by_owner[? _owner] = _subject_group;
        return _subject_group;
    }
    
    /// @desc Checks whether an event for the given owner and key exists.
    /// @arg {Any} owner        The event subject owner.
    /// @arg {String} key       The event subject key.
    /// @returns {Bool}
    static has_event = function(_owner, _key) {
        var _subject_group = subject_groups_by_owner[? _owner];
        return !is_undefined(_subject_group) && struct_exists(_subject_group, _key);
    }
    
    /// @desc Creates an event subject for the given owner and key.
    /// @arg {Any} owner            The event subject owner.
    /// @arg {String} key           The event subject key.
    /// @arg {Bool} [removeempty]   Whether the event should be automatically cleaned up and removed when turning empty.
    /// @returns {Struct.MainframeEventSubject}
    static create_event = function(_owner, _key, _removeempty = true) {
        var _subject_group = access_subject_group(_owner);
        if (struct_exists(_subject_group, _key))
            throw MainframeException.event_subject_already_exists(_owner, _key);
        
        var _event = new MainframeEventSubject(self, _owner, _key, _removeempty);
        _subject_group[$ _key] = _event;
        return _event;
    }
    
    /// @desc Gets or creates an event subject for the given owner and key.
    /// @arg {Any} owner        The event subject owner.
    /// @arg {String} key       The event subject key.
    /// @returns {Struct}
    static get_event = function(_owner, _key) {
        var _subject_group = access_subject_group(_owner);
        var _event = _subject_group[$ _key];
        if (!is_undefined(_event))
            return _event;
        
        _event = new MainframeEventSubject(self, _owner, _key);
        _subject_group[$ _key] = _event;
        return _event;
    }
    
    /// @desc Sets an event subject for the given owner and key. If another event already exists, it cleans it up.
    /// @arg {Any} owner        The event subject owner.
    /// @arg {String} key       The event subject key.
    /// @returns {Struct}
    static set_event = function(_owner, _key, _event) {
        var _subject_group = access_subject_group(_owner);
        var _previous_event = _subject_group[$ _key];
        if (!is_undefined(_previous_event))
            _previous_event.cleanup();
        
        _subject_group[$ _key] = _event;
        return _event;
    }
    
    /// @desc Cleans up and removes an event subject for the given owner and key. Returns whether there was an event subject to remove in the first place.
    /// @arg {Any} owner        The event subject owner.
    /// @arg {String} key       The event subject key.
    /// @returns {Bool}
    static remove_event = function(_owner, _key) {
        var _subject_group = subject_groups_by_owner[? _owner];
        if (is_undefined(_subject_group))
            return false;
        
        var _event = _subject_group[$ _key];
        if (is_undefined(_event))
            return false;
        
        struct_remove(_subject_group, _key); // removing event first to prevent potential remove-cleanup recursion
        _event.cleanup();
        return true;
    }
    
    /// @desc Removes an event subject owner, cleaning up all of its subjects. Returns whether there was the owner to remove in the first place.
    /// @arg {Any} owner        The event subject owner to remove.
    /// @returns {Bool}
    static remove_owner = function(_owner) {
        if (!ds_map_exists(subject_groups_by_owner, _owner))
            return false;
        
        var _subject_group = subject_groups_by_owner[? _owner];
        ds_map_delete(subject_groups_by_owner, _owner);
        struct_foreach(_subject_group, function(_key, _value) {
            _value.cleanup();
        });
        return true;
    }
    
    /// @desc Cleans up all the event subjects and frees memory of the map tracking them.
    static cleanup = function() {
        while (!ds_map_empty(subject_groups_by_owner)) {
            var _owner = ds_map_find_first(subject_groups_by_owner);
            remove_owner(_owner);
            ds_map_delete(subject_groups_by_owner, _owner);
        }
        ds_map_destroy(subject_groups_by_owner);
    }
    
    /// @ignore
    static is_cleaned = function() {
        return !ds_exists(subject_groups_by_owner, ds_type_map);
    }
}
