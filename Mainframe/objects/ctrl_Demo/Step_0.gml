on_step.send();
if (previous_second != current_second) {
    on_second.send($"{current_hour}:{current_minute}:{current_second}");
    previous_second = current_second;
}
