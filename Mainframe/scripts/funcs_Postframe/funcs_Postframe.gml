/// @desc Retrieves the worker running background tasks in Mainframe post-frame processing.
/// @returns {Struct.MainframeQueueWorker}
function postframe_get_worker() {
    return sys_Mainframe.postframe_worker;
}

/// @desc Sets the minimum number of task steps and a minimum duration executed each frame.
/// @arg {Real} minsteps            The minimum number of task processing steps executed each frame.
/// @arg {Real} minduration         The minimum number of microseconds spent on task processing each frame.
function postframe_set_minimum(_minsteps, _minduration) {
    sys_Mainframe.postframe_min_steps = _minsteps;
    sys_Mainframe.postframe_min_duration = _minduration;
}

/// @desc Sets the target game frame duration and, optionally, a margin left for long steps and between-frame processing.
/// @arg {Real} total               The total frame duration the post-frame processing will target.
/// @arg {Real} [margin]            The margin cut from the post-frame processing to prevent accidental lag; by default, the current margin is kept.
function postframe_set_frame_duration(_total, _margin = undefined) {
    sys_Mainframe.postframe_frame_duration = _total;
    sys_Mainframe.postframe_margin = _margin ?? sys_Mainframe.postframe_margin;
}

/// @desc Unsets the target game frame duration, so that the duration based on game speed is used instead.
function postframe_unset_frame_duration() {
    sys_Mainframe.postframe_frame_duration = undefined;
}

/// @desc Gets the minimum number of task processing steps executed each frame.
/// @returns {Real}
function postframe_get_minimum_steps() {
    return sys_Mainframe.postframe_min_steps;
}

/// @desc Gets the minimum duration spent on task processing each frame.
/// @returns {Real}
function postframe_get_minimum_duration() {
    return sys_Mainframe.postframe_min_duration;
}

/// @desc Gets the total game frame duration the post-frame processing will aim to preserve.
/// @returns {Real,Undefined}
function postframe_get_frame_duration() {
    return sys_Mainframe.postframe_frame_duration;
}

/// @desc Gets the post-frame processing margin reserved for potentially long task steps and between-frame processing.
/// @returns {Real}
function postframe_get_margin() {
    return sys_Mainframe.postframe_margin;
}

/// @desc Schedules a potentially long running task for post-frame background processing.
/// @arg {Struct.MainframeTask} task        The task to schedule for post-frame processing.
function postframe_schedule_task(_task) {
    postframe_get_worker().schedule_task(_task);
}

/// @desc Gets the currently ongoing task from the post-frame processing.
/// @returns {Struct.MainframeTask,Undefined}
function postframe_get_ongoing_task() {
    return postframe_get_worker().ongoing_task;
}

/// @desc Immediately executes all the remaining post-frame tasks.
function postframe_run_to_end() {
    postframe_get_worker().run_to_end();
}

/// @desc Cancels an individual task (running or scheduled) from the post-frame processing.
/// @arg {Struct.MainframeTask} task        The post-frame processed task to cancel.
function postframe_try_cancel_task(_task) {
    postframe_get_worker().try_cancel(_task);
}

/// @desc Cancels all the tasks scheduled for the post-frame processing.
function postframe_try_cancel_all() {
    postframe_get_worker().try_cancel(undefined);
}
