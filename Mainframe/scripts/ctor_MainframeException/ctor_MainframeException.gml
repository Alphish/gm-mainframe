function MainframeException(_code, _description) constructor {
    if (!is_instanceof(self, MainframeException))
        return; // exiting early for static initialisation
    
    code = _code;
    description = _description;
    
    static instance_not_found = function() {
        return new MainframeException(
            $"mainframe_instance_not_found",
            $"Cannot use the mainframe functionality without an active mainframe instance."
            );
    }
    
    static instance_duplicate = function() {
        return new MainframeException(
            $"mainframe_instance_duplicate",
            $"Cannot create another mainframe instance. Only one mainframe instance can exist at once."
            );
    }
    
    static event_not_found = function(_description) {
        return new MainframeException(
            $"mainframe_event_not_found",
            _description
            );
    }
    
    static event_duplicate = function(_event) {
        return new MainframeException(
            $"mainframe_event_duplicate",
            $"Cannot create another '{_event.name}' event. '{_event.name}' already exists."
            );
    }
}

/// static initialisation
/// feather ignore GM1020
MainframeException();
