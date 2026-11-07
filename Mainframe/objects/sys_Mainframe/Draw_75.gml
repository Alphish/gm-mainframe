if (is_undefined(postframe_worker))
    return;

postframe_limit = max(postframe_limit, get_timer() + postframe_min_duration);

postframe_worker.run_until(postframe_limit, postframe_min_steps);
