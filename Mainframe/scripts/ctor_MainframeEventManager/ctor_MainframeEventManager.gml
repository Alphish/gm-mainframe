/// @desc An event manager, creating and cleaning up events as needed.
function MainframeEventManager() constructor {
    /// @ignore
    owner_managers = ds_map_create();
    
    /// @desc Checks whether an event for the given owner and key exists.
    /// @arg {Any} owner        The event subject owner.
    /// @returns {Struct.MainframeEventOwnerManager}
    static get_owner_manager = function(_owner) {
        if (is_undefined(owner_managers))
            throw MainframeException.event_manager_cleaned_up();
        
        var _owner_manager = owner_managers[? _owner];
        if (!is_undefined(_owner_manager))
            return _owner_manager;
        
        _owner_manager = new MainframeEventOwnerManager(self, _owner);
        owner_managers[? _owner] = _owner_manager;
        return _owner_manager;
    }
    
    /// @desc Checks whether an event for the given owner and key exists.
    /// @arg {Any} owner        The event subject owner.
    /// @arg {String} key       The event subject key.
    /// @returns {Bool}
    static has_event = function(_owner, _key) {
        if (is_undefined(owner_managers))
            return false;
        
        var _owner_manager = owner_managers[? _owner];
        return !is_undefined(_owner_manager) && _owner_manager.has_event(_key);
    }
    
    /// @desc Creates an event subject for the given owner and key.
    /// @arg {Any} owner            The event subject owner.
    /// @arg {String} key           The event subject key.
    /// @arg {Bool} [removeempty]   Whether the event should be automatically cleaned up and removed when turning empty.
    /// @returns {Struct.MainframeEventSubject}
    static create_event = function(_owner, _key, _removeempty = true) {
        var _owner_manager = get_owner_manager(_owner);
        return _owner_manager.create_event(_key, _removeempty);
    }
    
    /// @desc Gets or creates an event subject for the given owner and key.
    /// @arg {Any} owner        The event subject owner.
    /// @arg {String} key       The event subject key.
    /// @returns {Struct}
    static get_event = function(_owner, _key) {
        var _owner_manager = get_owner_manager(_owner);
        return _owner_manager.get_event(_key);
    }
    
    /// @desc Sets an event subject for the given owner and key. If another event already exists, it cleans it up.
    /// @arg {Any} owner        The event subject owner.
    /// @arg {String} key       The event subject key.
    /// @returns {Struct}
    static set_event = function(_owner, _key, _event) {
        var _owner_manager = get_owner_manager(_owner);
        return _owner_manager.set_event(_key, _event);
    }
    
    /// @desc Sets an event subject for the given owner and key. If another event already exists, it cleans it up.
    /// @arg {Any} owner        The event subject owner.
    /// @arg {String} key       The event subject key.
    /// @arg {Any} [data]       The data to send.
    /// @arg {Any} [sender]     The entity to report as the event sender.
    /// @returns {Struct}
    static send_event = function(_owner, _key, _data = undefined, _sender = undefined) {
        var _owner_manager = get_owner_manager(_owner);
        return _owner_manager.send_event(_key, _data, _sender);
    }
    
    /// @desc Cleans up and removes an event subject for the given owner and key. Returns whether there was an event subject to remove in the first place.
    /// @arg {Any} owner        The event subject owner.
    /// @arg {String} key       The event subject key.
    /// @returns {Bool}
    static remove_event = function(_owner, _key) {
        if (is_undefined(owner_managers))
            return false;
        
        var _owner_manager = owner_managers[? _owner];
        return !is_undefined(_owner_manager) ? _owner_manager.remove_event(_key) : false;
    }
    
    /// @desc Removes an event subject owner, cleaning up all of its subjects. Returns whether there was the owner to remove in the first place.
    /// @arg {Any} owner        The event subject owner to remove.
    /// @returns {Bool}
    static remove_owner = function(_owner) {
        if (is_undefined(owner_managers))
            return false;
        
        var _owner_manager = owner_managers[? _owner];
        if (!ds_map_exists(owner_managers, _owner))
            return false;
        
        ds_map_delete(owner_managers, _owner); // removing owner first to prevent potential remove-cleanup recursion
        return _owner_manager.remove();
    }
    
    /// @desc Cleans up all the event subjects and frees memory of the map tracking them.
    static cleanup = function() {
        if (is_undefined(owner_managers))
            return;
        
        while (!ds_map_empty(owner_managers)) {
            var _owner = ds_map_find_first(owner_managers);
            remove_owner(_owner);
            ds_map_delete(owner_managers, _owner);
        }
        ds_map_destroy(owner_managers);
        owner_managers = undefined;
    }
}
