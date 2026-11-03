/// @desc A basic task implementation, performing processing step by step until reaching the result.
/// @arg {Struct} processor                             The processor performing the task logic.
/// @arg {Struct.MainframeEventManager} [evmanager]     The event manager for task events.
function MainframeTask(_processor, _evmanager = undefined) constructor {
    /// @desc The processor performing the task logic.
    /// @returns {Struct}
    processor = _processor;
    
    _evmanager ??= mainframe_get_event_manager();
    
    /// @ignore
    task_events = _evmanager.get_owner_manager(self);
    
    /// @desc Indicates whether the task has finished (through success, failure or cancellation).
    /// @returns {Bool}
    is_finished = false;
    
    /// @desc Indicates whether the task has been canceled.
    /// @returns {Bool}
    is_canceled = false;
    
    /// @desc Indicates whether the task can handle processing exceptions or not.
    /// @returns {Bool}
    can_handle_exceptions = is_callable(processor[$ "handle_exception"]);
    
    /// @ignore
    previous_status = processor.status;
    
    /// @desc Prepares and retrieves the event subject notifying about the task status changing.
    /// @returns {Struct}
    static when_status_changed_subject = function() {
        return is_finished ? undefined : task_events.get_event("status_changed");
    }
    
    /// @desc Prepares and retrieves the event subject notifying about the task starting.
    /// @returns {Struct}
    static when_task_started_subject = function() {
        return is_finished ? undefined : task_events.get_event("task_started");
    }
    
    /// @desc Prepares and retrieves the event subject notifying about the task progress.
    /// @returns {Struct}
    static when_task_progressed_subject = function() {
        return is_finished ? undefined : task_events.get_event("task_progressed");
    }
    
    /// @desc Prepares and retrieves the event subject notifying about the task finishing.
    /// @returns {Struct}
    static when_task_finished_subject = function() {
        return is_finished ? undefined : task_events.get_event("task_finished");
    }
    
    /// @desc Prepares and retrieves the event subject notifying about the task successful completion.
    /// @returns {Struct}
    static when_task_completed_subject = function() {
        return is_finished ? undefined : task_events.get_event("task_completed");
    }
    
    /// @desc Prepares and retrieves the event subject notifying about the task failure.
    /// @returns {Struct}
    static when_task_failed_subject = function() {
        return is_finished ? undefined : task_events.get_event("task_failed");
    }
    
    /// @desc Prepares and retrieves the event subject notifying about the task cancellation.
    /// @returns {Struct}
    static when_task_canceled_subject = function() {
        return is_finished ? undefined : task_events.get_event("task_canceled");
    }
    
    /// @desc Gets whichever result the task produced, if any.
    /// @returns {Any}
    static get_result = function() {
        return processor.result;
    }
    
    /// @desc Gets whichever error happened during task processing, if any.
    /// @returns {Any}
    static get_error = function() {
        return processor.error;
    }
    
    /// @desc Prepares the task resources, if any.
    init = function() {
        processor.init();
        task_events.send_event("task_started", processor);
    }
    
    /// @desc Performs a single processing step and returns whether the processing should stop.
    /// @returns {Bool}
    process = method(processor, processor.process_step);
    
    /// @desc Handles an exception caught during the processing.
    /// @arg {Any} exception        The caught exception.
    handle_exception = function(_exception) {
        processor.handle_exception(_exception);
    }
    
    /// @desc Checks task changes and sends appropriate updates.
    static check_updates = function() {
        if (is_finished)
            return;
        
        if (processor.status != previous_status) {
            previous_status = processor.status;
            task_events.send_event("status_changed", processor.status);
        }
        
        task_events.send_event("task_progressed", processor);
        
        if (processor.is_finished()) {
            is_finished = true;
            task_events.send_event("task_finished", processor);
            
            if (is_undefined(processor.error))
                task_events.send_event("task_completed", processor.result);
            else
                task_events.send_event("task_failed", processor.error);
            
            task_events.remove(); // discard the owner event manager when it's no longer needed
            processor.cleanup(/* auto */ true);
        }
    }
    
    /// @desc Attempts to cancel the task if it's not finished and returns whether cancellation was successful.
    /// @returns {Bool}
    static try_cancel = function() {
        if (is_finished)
            return false;
        
        is_finished = true;
        is_canceled = true;
        task_events.send_event("task_canceled");
        
        task_events.remove(); // discard the owner event manager when it's no longer needed
        processor.cleanup(/* auto */ true);
        return true;
    }
}