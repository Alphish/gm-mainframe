/// @func MainframeException(code,description)
/// @desc An exception to be thrown when Mainframe functionality is improperly used or configured.
/// @arg {String} code              The exception code identifying the category of the problem.
/// @arg {String} description       The description explaining the problem.
function MainframeException(_code, _description) constructor {
    if (!is_instanceof(self, MainframeException))
        return; // exiting early for static initialisation
    
    /// @desc The exception code identifying the category of the problem.
    /// @type {String}
    code = _code;
    
    /// @desc The description explaining the problem.
    /// @type {String}
    description = _description;
    
    /// @ignore
    static instance_not_found = function() {
        return new MainframeException(
            $"mainframe_instance_not_found",
            $"Cannot use the mainframe functionality without an active mainframe instance."
            );
    }
    
    /// @ignore
    static instance_duplicate = function() {
        return new MainframeException(
            $"mainframe_instance_duplicate",
            $"Cannot create another mainframe instance. Only one mainframe instance can exist at once."
            );
    }
    
    /// @ignore
    static event_not_found = function(_description) {
        return new MainframeException(
            $"mainframe_event_not_found",
            _description
            );
    }
    
    /// @ignore
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
