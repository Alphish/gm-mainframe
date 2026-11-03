draw_self();

draw_set_font(fnt_Demo);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);

draw_text(x + 60, y + 20, title);
draw_text(x + 60, y + 40, ctrl_Demo.worker.ongoing_task == task ? $"{floor(100 * task.processor.current_step / task.processor.total_steps)}%" : "Pending");
