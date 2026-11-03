task_log = [];

log_task = function(_task) {
    array_insert(task_log, 0, _task);
    if (array_length(task_log) > 15)
        array_pop(task_log);
}
