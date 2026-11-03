draw_set_font(fnt_Demo);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);

for (var i = 0, _count = array_length(task_log); i < _count; i++) {
    var _task = task_log[i];
    
    var _text = "";
    if (_task.is_canceled) {
        draw_set_color(c_gray);
        _text = $"TASK CANCELED AT {_task.processor.current_step}/{_task.processor.total_steps}";
    } else if (!is_undefined(_task.processor.error)) {
        draw_set_color(c_orange);
        _text = _task.processor.error;
    } else {
        draw_set_color(c_lime);
        _text = $"TASK COMPLETED WITH {_task.processor.result}";
    }
    
    draw_text(x, y + 20 * i, _text);
}

draw_set_color(c_white);
