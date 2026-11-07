if (is_undefined(event_manager_constructor))
    event_manager = undefined;
else if (asset_has_tags(event_manager_constructor, ["@@constructor"], asset_script))
    event_manager = new event_manager_constructor();
else
    event_manager = event_manager_constructor();

if (is_undefined(postframe_worker_constructor))
    postframe_worker = undefined;
else if (asset_has_tags(postframe_worker_constructor, ["@@constructor"], asset_script))
    postframe_worker = new postframe_worker_constructor();
else
    postframe_worker = postframe_worker_constructor();

// the moment in time until which post-frame processing should run
postframe_limit = get_timer();
