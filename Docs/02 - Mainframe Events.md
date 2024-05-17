[<< Back to home](https://github.com/Alphish/gm-mainframe)

[<< 01 - Overview](/Docs/Overview/01%20-%20Overview.md) | **02 - Mainframe Events** | [03 - Post-frame Processing >>](/Docs/03-%20-%20Post-frame%20Processing.md)

-----

# Mainframe Events

## Overview

Mainframe events are represented by `MainframeEvent` struct instances. Each event has a unique name (stored, unsurprisingly, in the `name` variable). The name can be used for finding the corresponding event, using the `mainframe_get_event` function.

Each event can define various actions to perform, represented with `MainframeEventAction` struct instances. Each action has:

- **callback** - a function or method containing the action logic
- **order value** - indicates the processing order; within a given event, actions with a lower order value are performed earlier

Thanks to the order value, you can register various actions independently and ensure correct order regardless of which action got registered first. This avoids a common problem with GameMaker's built-in events, whose execution order is unspecified and subject to change between platforms and/or updates.

## Registering actions

To register a Mainframe event action, you can use the following methods on the `MainframeEvent` struct:

- `add_action(callback,[order])` - creates an event action executing the given callback when performed
- `add_user_event(object,number,[order])` - creates an event action performing the given user-defined event for the given object or instance; if an object asset is passed, the user-defined event will be executed for all its instances
- `add_method_call(caller,name,[order])` - creates an event action calling a method with the given name for an object, instance or struct; if an object asset is passed, the method will be executed for all its instances

Additionally, the following script functions are available:

- `mainframe_event_add_action(event,callback,[order])` - creates an event action executing the given callback for the given event
- `mainframe_event_add_user_event(event,object,number,[order])` - creates an event action executing the given user-defined event
- `mainframe_event_add_method_call(event,caller,name,[order])` - creates an event action executing the given method

For each of these script functions, `event` can be passed directly as a `MainframeEvent` instance or as the event's unique name. In methods and script functions alike `order` argument is optional and defaults to 0. Among actions with the same order value, those registered earlier are executed first.

Each of the aforementioned methods and script functions returns an instance of the newly created `MainframeEventAction` struct for further management. When the value of `order` is not given, a default value of 0 is used.

**Note:** Mainframe events have been designed to contain few, infrequently changing actions. Thus, it's recommended to register few broad actions like *"for all instances of obj_Player perform user-defined event 0"* or *"for all instances of obj_Enemy call move() method"*, rather than having each obj_Player or obj_Enemy instance register its own action.

## Managing actions

Each `MainframeEventAction` instance has the following methods:

- `deactivate()` - prevents the action execution in its event cycle until it's reactivated
- `activate()` - re-enables the action execution
- `remove()` - removes the action from its event, so it won't be executed anymore (regardless of the activation state)

Deactivation/reactivation may be used for temporarily suspending specific actions, which can be useful e.g. for pausing the gameplay. Removing the action is recommended as a part of a cleanup (for example, an in-game controller may register player movement action in its Create event and remove it in its Cleanup event).

Additionally, `MainframeEvent` has the following methods for actions management:

- `remove(action)` - removes the given action so it's not performed anymore, as long as the action belongs to the event
- `clear()` - removes all actions from the event

Generally, action's own `remove()` method is preferred, as there's no risk of trying to remove the action from the wrong event.

## Built-in events

The Mainframe system provides three built-in events out of the box:

- **Begin Step** - stored in the `begin_step_event` Mainframe variable, accessed via **"begin_step"** unique name
- **Step** - stored in the `step_event` Mainframe variable, accessed via **"step"** unique name
- **Draw GUI End** - stored in the `draw_gui_end_event` Mainframe variable, accessed via **"draw_gui_end"** unique name

It's recommended to consistently use either the Mainframe events or the corresponding GameMaker events. For example, if you decide to use Mainframe Step event for some actions, it's recommended not to use the GameMaker Step event outside the Mainframe. At the same time, it's fine to consistently use Mainframe Step event alongside Begin Step GameMaker events or vice versa; it depends on what works with the given game.

As a rule of thumb, if you need to enforce a specific ordering or use temporary deactivation within a certain event, the Mainframe event system is preferable. Otherwise, built-in GameMaker event system should work just fine.

**An important exception applies when you use the post-frame processing.** In such case, the entire Begin Step and Draw GUI End logic should go through the Mainframe events, rather than corresponding GameMaker events. You can read a more detailed explanation in the [Post-Frame Processing page](/Docs/03-%20-%20Post-frame%20Processing.md).

The following script functions can be used to register built-in Mainframe events actions:

- `mainframe_begin_step_add_action(callback,[order])`
- `mainframe_begin_step_add_user_event(object,number,[order])`
- `mainframe_begin_step_add_method_call(caller,name,[order])`
- `mainframe_step_add_action(callback,[order])`
- `mainframe_step_add_user_event(object,number,[order])`
- `mainframe_step_add_method_call(caller,name,[order])`
- `mainframe_draw_gui_end_step_add_action(callback,[order])`
- `mainframe_draw_gui_end_add_user_event(object,number,[order])`
- `mainframe_draw_gui_end_add_method_call(caller,name,[order])`

## Adding custom events

In some cases, you may want to use Mainframe events functionality outside of built-in events. For example, suppose that you have multiple objects performing their Room Start logic, and you need it to be executed in a specific order.

First, let's create your own version of the Mainframe. Create a new object, called e.g. `sys_TheCoolerMainframe`, and set its parent to the `sys_Mainframe` object. Make sure to mark it as persistent as well. Obviously, the custom mainframe object should replace the built-in one during setup.

Then, create a new Mainframe event in the Create event:

```gml
event_inherited(); // setup all the built-in functionality as well
room_start_event = new MainframeEvent("room_start");
```

Then, let's add the Room Start GameMaker event to perform its Mainframe counterpart:

```gml
room_start_event.perform();
```

In order to register actions, you can use the **"room_start"** unique name and pass it to the `mainframe_event_add_*` functions. Alternatively, you can make your own wrapper functions, to make things easier and less error-prone in the long run:

```gml
/// @func mainframe_room_start_add_action(callback,[order])
/// @desc Adds a callback action to the Room Start mainframe event and returns the action.
/// @arg {Function} callback        The action callback to execute during the event processing.
/// @arg {Real} [order]             The value of the execution order (actions with a lower order are executed first).
/// @returns {Struct.MainframeEventAction}
function mainframe_room_start_add_action(_callback, _order = 0) {
    return mainframe_event_add_action("room_start", _callback, _order);
}

/// @func mainframe_room_start_add_user_event(object,number,[order])
/// @desc Adds a user event action to the Room Start mainframe event and returns the action.
/// @arg {Asset.GMObject,Id.Instance} object        The object or instance to execute the user event of.
/// @arg {Real} number                              The number of the user event.
/// @arg {Real} [order]                             The value of the execution order (actions with a lower order are executed first).
/// @returns {Struct.MainframeEventAction}
function mainframe_room_start_add_user_event(_object, _number, _order = 0) {
    return mainframe_event_add_user_event("room_start", _object, _number, _order);
}

/// @func mainframe_room_start_add_method_call(caller,name,[order])
/// @desc Adds a method call action to the Room Start mainframe event and returns the action.
/// @arg {Any} caller       The object, instance or struct to execute the method of.
/// @arg {String} name      The name of the method.
/// @arg {Real} [order]     The value of the execution order (actions with a lower order are executed first).
/// @returns {Struct.MainframeEventAction}
function mainframe_room_start_add_method_call(_caller, _name, _order = 0) {
    return mainframe_event_add_method_call("room_start", _caller, _name, _order);
}
```

Then you can use the new functions like so:

```gml
// obj_RoomData Create event

// will determine the correct background music to play
mainframe_room_start_add_method_call(obj_RoomData, "resolve_data", /* order */ 0);
```

```gml
// obj_BgmPlayer Create event
mainframe_room_start_add_method_call(obj_BgmPlayer, "play_bgm", /* order */ 10);
```

-----

[<< 01 - Overview](/Docs/Overview/01%20-%20Overview.md) | **02 - Mainframe Events** | [03 - Post-frame Processing >>](/Docs/03-%20-%20Post-frame%20Processing.md)
