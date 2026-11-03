on_step = mainframe_own_event("step");
on_step.add_handler(function() {
    effect_create_layer(layer, ef_smokeup, room_width - 160, room_height div 2, current_second mod 3, c_white);
});
on_second = mainframe_own_event("second");
on_second.add_handler(function(_value) {
    show_debug_message(_value);
});

previous_second = current_second;

worker = new MainframeQueueWorker();
worker.when_tasks_changed().add_handler(function(_data, _sender) {
    with (ui_TaskManager) {
        if (task == _sender.ongoing_task)
            y = 20;
        else
            y = 100 + 60 * array_get_index(_sender.pending_tasks, task);
    }
});
task_index = 1;

instance_create_depth(room_width div 4 + 20, 20, depth, ui_TaskLog);

create_task = function(_title, _processor) {
    var _task = new MainframeTask(_processor);
    instance_create_depth(20, 20, depth, ui_TaskManager, { title: $"{_title} #{task_index++}", task: _task, image_xscale: 8, image_yscale: 1.5 });
    worker.schedule_task(_task);
}
