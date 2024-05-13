function MainframeException(_code, _description) constructor {
    if (!is_instanceof(self, MainframeException))
        return; // exiting early for static initialisation
    
    code = _code;
    description = _description;
    
    static instance_duplicate = function() {
        return new MainframeException(
            $"mainframe_instance_duplicate",
            $"Cannot create another mainframe instance. Only one mainframe instance can exist at once."
            );
    }
}

/// static initialisation
/// feather ignore GM1020
MainframeException();
