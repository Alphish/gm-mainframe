/// @desc A basic event subject implementation, managing its observers and sending events to them.
/// @arg {Struct.MainframeEventOwnerManager} manager    The owner's event manager.
/// @arg {Any} key                                      The key specifying the owner's event.
/// @arg {Bool} [removeempty]                           Whether the event subject should be automatically cleaned up and removed when turning empty.
function MainframeEventSubject(_manager, _key, _removeempty = true) constructor {
    /// @ignore
    manager = _manager;
    
    /// @ignore
    owner = manager.owner;
    
    /// @ignore
    key = _key;
    
    /// @ignore
    auto_remove_empty = _removeempty;
    
    /// @ignore
    observers = [];
    
    /// @desc Adds an observer to be notified when the event is sent. Also, returns the observer.
    /// @arg {Struct} observer      The observer to notify.
    /// @returns {Struct}
    static add_observer = function(_observer) {
        array_push(observers, _observer);
        return _observer;
    }
    
    /// @desc Creates and adds an observer calling a given handler when the event is sent. Returns the newly created observer.
    /// @arg {Function} handler     The function to call upon receiving the event.
    /// @returns {Struct.MainframeEventBasicObserver}
    static add_handler = function(_handler) {
        var _observer = new MainframeEventObserver(self, _handler);
        return add_observer(_observer);
    }
    
    /// @desc Checks whether the event has any associated observers or not.
    /// @returns {Bool}
    static is_empty = function() {
        return array_length(observers) == 0;
    }
    
    /// @desc Removes the observer so it's no longer notified about future events. Returns whether the observer was removed or not.
    /// @arg {Struct} observer      The observer to remove.
    /// @returns {Bool}
    static remove_observer = function(_observer) {
        var _index = array_get_index(observers, _observer);
        if (_index < 0)
            return false;
        
        _observer.cleanup();
        array_delete(observers, _index, 1);
        
        if (auto_remove_empty && array_length(observers) == 0)
            manager.remove_event(owner, key);
        
        return true;
    }
    
    /// @desc Removes all observers so they're no longer notified about future events.
    static clear_observers = function() {
        array_foreach(observers, function(_observer) {
            _observer.cleanup();
        });
        array_resize(observers, 0);
        
        if (auto_remove_empty)
            manager.remove_event(owner, key);
    }
    
    /// @desc Sends the event to notify the observers. Event data and a sender override can be optionally provided.
    /// @arg {Any} [data]           The data to send to observers.
    /// @arg {Any} [sender]         The entity to report as the event sender, as opposed to subject's owner.
    static send = function(_data = undefined, _sender = undefined) {
        _sender ??= owner;
        for (var i = 0, _count = array_length(observers); i < _count; i++) {
            observers[i].receive(_data, _sender);
        }
    }
    
    /// @desc Performs the cleanup once the event subject is removed.
    static cleanup = function() {
        manager.remove_event(owner, key);
        clear_observers();
    }
}
