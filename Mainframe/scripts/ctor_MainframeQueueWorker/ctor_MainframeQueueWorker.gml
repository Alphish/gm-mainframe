/// @desc A queue worker implementation, processing scheduled tasks one by one.
/// @arg {Struct.MainframeEventManager} [evmanager]     The event manager for task events.
function MainframeQueueWorker(_evmanager = undefined) constructor {
    /// @desc The currently running task.
    /// @returns {Struct}
    ongoing_task = undefined;
    
    /// @desc The queue of the remaining tasks.
    /// @returns {Struct}
    pending_tasks = [];
    
    _evmanager ??= mainframe_get_event_manager();
    
    /// @ignore
    worker_events = _evmanager.get_owner_manager(self);
    
    /// @desc Enqueues a given task for execution.
    /// @arg {Struct} task      The task to enqueue.
    static schedule_task = function(_task) {
        array_push(pending_tasks, _task);
        mainframe_owner_send_event(worker_events, "tasks_changed");
    }
    
    /// @desc Checks if the worker has any task to run.
    /// @returns {Bool}
    static is_busy = function() {
        return !is_undefined(ongoing_task) || array_length(pending_tasks) > 0;
    }
    
    /// @desc Prepares and retrieves the event subject notifying about the task status changing.
    /// @returns {Struct.MainframeEventSubject}
    static when_tasks_changed = function() {
        return !is_undefined(worker_events) ? worker_events.get_event("tasks_changed") : undefined;
    }
    
    /// @ignore
    static try_prepare_task = function() {
        if (!is_undefined(ongoing_task))
            return true;
        
        ongoing_task = array_shift(pending_tasks);
        if (is_undefined(ongoing_task))
            return false;
        
        ongoing_task.init();
        return true;
    }
    
    /// @ignore
    static try_complete_processing = function() {
        ongoing_task.check_updates(); // make sure the current task has its progress and completion fired properly
        ongoing_task = array_shift(pending_tasks);
        if (is_undefined(ongoing_task))
            return true;
        
        ongoing_task.init();
        return false;
    }
    
    /// @desc Performs a single step of the ongoing task and updates it. Returns whether the required tasks were processed.
    /// @returns {Bool}
    static run_step = function() {
        var _task_prepared = is_undefined(ongoing_task);
        if (!try_prepare_task())
            return true;
        
        var _task_finished = false;
        if (!ongoing_task.can_handle_exceptions) {
            _task_finished = ongoing_task.process();
        } else try {
            _task_finished = ongoing_task.process();
        } catch (_exception) {
            ongoing_task.handle_exception(_exception);
        }
        
        var _all_finished = _task_finished && try_complete_processing();
        if (_task_prepared || _task_finished)
            mainframe_owner_send_event(worker_events, "tasks_changed");
        
        return _all_finished;
    }
    
    /// @desc Executes the underlying tasks until the given time. Returns whether the required tasks were processed.
    /// @arg {Real} limit       The time limit after which processing should stop.
    /// @arg {Real} [steps]     A number of steps to perform regardless of time limit.
    /// @returns {Bool}
    static run_until = function(_limit, _steps = 1) {
        var _tasks_changed = is_undefined(ongoing_task);
        if (!try_prepare_task())
            return true;
        
        _steps = max(_steps, 1);
        
        // the outer loop iterations correspond to each ran task
        // the inner loop iterations correspond to the ongoing task steps
        while (_steps > 0) {
            // by putting process() result condition first, steps are decreased only if the task made a non-finishing step
            // that way steps will turn 0 if and only if the ongoing task returned false for its processing
            if (!ongoing_task.can_handle_exceptions) {
                while (!ongoing_task.process() && --_steps > 0) {}
            } else try {
                while (!ongoing_task.process() && --_steps > 0) {}
            } catch (_exception) {
                ongoing_task.handle_exception(_exception);
            }
            
            // a positive number of remaining steps indicates the current task has finished
            _tasks_changed = _steps > 0 || _tasks_changed;
            
            if (_steps > 0 && try_complete_processing()) {
                mainframe_owner_send_event(worker_events, "tasks_changed");
                return true;
            }
        }
        
        
        // the outer loop iterations correspond to each ran task
        // the inner loop iterations correspond to the ongoing task steps
        while (get_timer() <= _limit) {
            var _task_finished = false;
            if (!ongoing_task.can_handle_exceptions) {
                while (!_task_finished && get_timer() <= _limit) { _task_finished = ongoing_task.process(); }
            } else try {
                while (!_task_finished && get_timer() <= _limit) { _task_finished = ongoing_task.process(); }
            } catch (_exception) {
                ongoing_task.handle_exception(_exception);
                _task_finished = true;
            }
            
            _tasks_changed = _task_finished || _tasks_changed;
            if (_task_finished && try_complete_processing()) {
                mainframe_owner_send_event(worker_events, "tasks_changed");
                return true;
            }
        }
        
        ongoing_task.check_updates();
        if (_tasks_changed)
            mainframe_owner_send_event(worker_events, "tasks_changed");
        
        return false;
    }
    
    /// @desc Executes the underlying tasks until no more tasks are available.
    /// @returns {Bool}
    static run_to_end = function() {
        if (!try_prepare_task())
            return true;
        
        // the outer loop iterations correspond to each ran task
        // the inner loop iterations correspond to the ongoing task steps
        do {
            if (ongoing_task.can_handle_exceptions) {
                while (!ongoing_task.process()) {}
            } else try {
                while (!ongoing_task.process()) {}
            } catch (_exception) {
                ongoing_task.handle_exception(_exception);
            }
        } until (try_complete_processing());
        
        mainframe_owner_send_event(worker_events, "tasks_changed");
        return true;
    }
    
    /// @desc Attempts to cancel a given task or, when none was given, all tasks. Returns whether the task has been successfully canceled/removed.
    /// @arg {Struct} task      The task to cancel.
    /// @returns {Bool}
    static try_cancel = function(_task = undefined) {
        var _any_canceled = try_cancel_task(_task);
        if (_any_canceled)
            mainframe_owner_send_event(worker_events, "tasks_changed");
        
        return _any_canceled;
    }
    
    /// @ignore
    static try_cancel_task = function(_task = undefined) {
        if (is_undefined(_task)) {
            var _ongoing_result = try_cancel_ongoing();
            var _remove_pending = array_length(pending_tasks) > 0;
            if (_remove_pending) {
                array_foreach(pending_tasks, function(_task) { _task.try_cancel(); });
                array_resize(pending_tasks, 0);
            }
            
            return _ongoing_result || (is_undefined(ongoing_task) && _remove_pending);
        } else if (ongoing_task == _task) {
            return try_cancel_ongoing();
        } else {
            var _index = array_get_index(pending_tasks, _task);
            if (_index < 0)
                return false;
            
            pending_tasks[_index].try_cancel();
            array_delete(pending_tasks, _index, 1);
            return true;
        }
    }
    
    /// @ignore
    static try_cancel_ongoing = function() {
        if (is_undefined(ongoing_task))
            return false;
        
        var _result = ongoing_task.try_cancel();
        if (_result)
            ongoing_task = undefined;
        
        return _result;
    }
    
    /// @desc Cleans up the resources associated with the queue worker.
    static cleanup = function() {
        worker_events.remove();
        worker_events = undefined;
        try_cancel();
    }
}
