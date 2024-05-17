/// @description Setting up gameplay actions

player_movement_action = mainframe_step_add_user_event(obj_Player, 0, /* order */ 0);
enemy_movement_action = mainframe_step_add_user_event(obj_Enemy, 0, /* order */ 1);
player_collision_action = mainframe_step_add_user_event(obj_Player, 1, /* order */ 2);
