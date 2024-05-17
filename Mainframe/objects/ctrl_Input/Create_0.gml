/// @description Setting up input detection

right_down = false;
up_down = false;
left_down = false;
down_down = false;

input_action = mainframe_begin_step_add_action(function() {
    right_down = keyboard_check(vk_right) || keyboard_check(ord("D"));
    up_down = keyboard_check(vk_up) || keyboard_check(ord("W"));
    left_down = keyboard_check(vk_left) || keyboard_check(ord("A"));
    down_down = keyboard_check(vk_down) || keyboard_check(ord("S"));
}, /* order */ 0);
