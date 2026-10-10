if (is_undefined(event_manager_constructor))
    event_manager = undefined;
else if (asset_has_tags(event_manager_constructor, ["@@constructor"], asset_script))
    event_manager = new event_manager_constructor();
else
    event_manager = event_manager_constructor();
