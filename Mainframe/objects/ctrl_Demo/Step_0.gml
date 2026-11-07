on_step.send();
if (previous_second != current_second) {
    on_second.send($"{current_hour}:{current_minute}:{current_second}");
    previous_second = current_second;
}

if (keyboard_check_pressed(49)) {
    create_task("100k steps", new DemoTaskProcessor(100_000));
}
if (keyboard_check_pressed(50)) {
    create_task("300k steps", new DemoTaskProcessor(300_000));
}
if (keyboard_check_pressed(51)) {
    create_task("1m steps", new DemoTaskProcessor(1_000_000));
}
if (keyboard_check_pressed(52)) {
    create_task("3m steps", new DemoTaskProcessor(3_000_000));
}
if (keyboard_check_pressed(53)) {
    create_task("10m steps", new DemoTaskProcessor(10_000_000));
}

if (keyboard_check_pressed(vk_end)) {
    postframe_run_to_end();
}
