if (instance_number(sys_Mainframe) > 1)
    throw MainframeException.instance_duplicate();

events = {};

begin_step_event = new MainframeEvent("begin_step");
step_event = new MainframeEvent("step");
draw_gui_end_event = new MainframeEvent("draw_gui_end");

post_frame_process = new MainframePostFrameProcess();
next_frame_time = get_timer();
