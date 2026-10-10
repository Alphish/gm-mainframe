/// @desc An exception to be thrown due to invalid Mainframe usage.
/// @arg {String} code              The code of the exception to differentiate between different exception causes.
/// @arg {String} description       A detailed description explaining the exception.
function MainframeException(_code, _description) constructor {
    /// @desc The code of the exception to differentiate between different exception causes.
    /// @type {String}
    code = _code;
    
    /// @desc A detailed description explaining the exception.
    /// @type {String}
    description = _description;
    
    toString = function() {
        return $"MainframeException.{code}: {description}";
    }
}

// -------------------
// Creating exceptions
// -------------------

/// @desc Creates a Mainframe exception thrown when attempting to create a new event subject when one already exists.
/// @arg {Any} owner        The event subject owner.
/// @arg {String} key       The event subject key.
/// @returns {Struct.MainframeException}
MainframeException.event_subject_already_exists = function(_owner, _key) {
    return new MainframeException(
        nameof(event_subject_already_exists),
        $"Cannot create the event subject; the event subject '{_key}' for {_owner} already exists."
        );
}
