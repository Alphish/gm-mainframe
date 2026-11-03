task.when_task_finished_subject().add_handler(function() {
    show_debug_message("FINISHED");
    ui_TaskLog.log_task(task);
    instance_destroy();
});
task.when_task_canceled_subject().add_handler(function() {
    show_debug_message("CANCELED");
    ui_TaskLog.log_task(task);
    instance_destroy();
});

remove_button = instance_create_depth(x + 10, y + 10, depth - 1, ui_TaskRemover, { task_manager: id });
