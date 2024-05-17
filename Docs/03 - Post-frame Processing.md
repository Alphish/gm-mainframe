[<< Back to home](https://github.com/Alphish/gm-mainframe)

[<< 02 - Mainframe Events](/Docs/02%20-%20Mainframe%20Events.md) | **03 - Post-frame Processing** | [04 - Demo Example >>](/Docs/04-%20-%20Demo%20Example.md)

-----

# Post-frame Processing

## How it works

The Mainframe system, among other things, provides a way to use leftover processing time to perform additional long-running tasks. This feature is called **post-frame processing**.

Broadly speaking, the individual frame time is divided between the **core processing** and the **post-frame processing**. The core processing encompasses the general gameplay logic and drawing; it will take as much or as little time as it needs. The remaining frame time is spent on the post-frame processing.

For example, if a game aims for 50 FPS framerate, each frame has 20 milliseconds to work with. If the core processing takes 12 milliseconds, it leaves about 8 milliseconds for the post-frame processing. In practice, the Mainframe system leaves some **frame margin** for GameMaker's internal processing; otherwise the framerate could slightly unstable. With a default margin of 0.5 milliseconds, it would leave 7.5 milliseconds for the post-frame processing overall.

Post-frame processing itself can be split into two phases:

- **reserved processing** - performing a minimum amount of work for each post-frame action, so that low framerate doesn't stop these altogether
- **additional processing** - using the remaining post-frame time to complete as much work as possible, starting from the highest priority task

For example, if three actions reserve 0.1 millisecond each, then - following up from the earlier example - about 0.3 milliseconds will be spent on the reserved processing and about 7.2 milliseconds on the additional processing.

**Note:** For the post-frame processing to work properly, you must not use Begin Step GameMaker events or Draw GUI End GameMaker events outside of the Mainframe instance. The more detailed explanation is given below, in the **Adjacent events problem** section.

## Basic structures

The Mainframe system contains a post-frame process, represented with a `MainframePostFrameProcess` struct instance and stored in the `post_frame_process` variable of the Mainframe instance. There should be only one post-frame process at a time, so it doesn't have a specific name like Mainframe events do.

The process can define various actions with their processing logic, represented with `MainframePostFrameAction` struct instances. Each action has:

- **callback** - a function or method containing the processing logic; it takes the number of steps and target time as its arguments
- **order value** - indicates the action priority; actions with a lower order value take priority during the *additional processing* phase
- **minimum steps** - the number of iterations to execute during the *reserved processing* phase
- **minimum duration** - the available processing time during the *reserved processing* phase, in milliseconds

## Example callback

Each post-frame callback should take into account the number of steps and the target time passed to them. Here is an example callback method for an action that counts up until reaching the target:

```gml
count_up = function(_steps, _time) {
    // "counter" and "target" are instance variables
    if (counter >= target)
        return;
    
    // performing the requested number of steps
    repeat (_steps) {
        counter++;
        
        if (counter >= target)
            break;
    }
    
    // performing additional processing until reaching the target time
    while (get_timer() <= _time) {
        counter++;
        
        if (counter >= target)
            break;
    }
}
```

**Note:** As can be seen from this example, the method execution stops only after the target time has been exceeded, rather than proactively predicting whether the next step will go over the target time or not. It means additional processing actually takes slightly longer than the time assigned to it. In practice, it's not much of a problem - the time won't be exceeded by more than a single iteration's worth. Thus, as long as iterations are small enough, they should be safely "absorbed" by the frame margin.

**Note:** The post-frame action callback may be executed up to two times during the post-frame processing.

During the reserved processing phase, it passes the action's *minimum steps* value as the *steps* argument, and the starting time plus *minimum duration* as the *time* argument.

During the additional processing phase, it passes 0 as the *steps* argument and the additional processing target time as the *time* argument.

## Registering actions

To register a post-frame action, you can use the following methods on the `MainframeEvent` struct:

- `add_action(callback,[order],[minsteps],[minduration])` - creates a post-frame action executing the given callback when performed
- `add_method_call(caller,name,[order])` - creates a post-frame action calling a method with the given name for an object, instance or struct; if an object asset is passed, the method will be executed for all its instances

Additionally, the following script functions are available:

- `mainframe_post_frame_add_action(callback,[order],[minsteps],[minduration])` - creates a post-frame action executing the given callback when performed
- `mainframe_post_frame_add_method_call(caller,name,[order],[minsteps],[minduration])` - creates a post-frame action executing the given method

Each of the aforementioned methods and script functions returns an instance of the newly created `MainframePostFrameAction` struct for further management. The default value of `order` is 0. The default value of `minsteps` is 1 (so that at least one iteration is executed each frame). The default value of `minduration` is 0 (so only a default single repetition is perform in the *reserved processing* phase).

**Note:** Similarly to Mainframe events, it's recommended to register few broad actions rather than many highly specific ones.

## Managing actions

Similarly to Mainframe event actions, you can toggle activation of post-frame actions and remove them.

Each `MainframePostFrameAction` instance has the following methods:

- `deactivate()` - prevents the post-frame action processing until it's reactivated
- `activate()` - re-enables the post-frame action processing
- `remove()` - removes the post-frame action, so it won't be processed anymore (regardless of the activation state)

Removing the action is recommended as a part of a cleanup (for example, an in-game controller may register player movement action in its Create event and remove it in its Cleanup event). In the context of post-frame processing, deactivation/reactivation might not be as useful as it is in the Mainframe events, but if some specific use-case requires these, it's there.

Additionally, `MainframePostFrameProcess` has the following methods for actions management:

- `remove(action)` - removes the given post-frame action so it's not performed anymore
- `clear()` - removes all post-frame actions

Finally, each `MainframePostFrameAction` instance has `min_steps` and `min_duration` variables, affecting the reserved number of iterations and duration for each frame. Changing these variables takes effect pretty much immediately; the very next reserved processing run for the given action will use the new values.

## Frame cycle and caveats

Every game frame, the following happens:

- in the *Begin Step GameMaker event* of the Mainframe instance:
    - the current frame time is measured and the **next frame expected time** is estimated
- from the *Begin Step GameMaker event* to the *Draw GUI End GameMaker event*:
    - the **core processing** is executed
    - this includes the Begin Step Mainframe event and Draw GUI End Mainframe event
- in the *Draw GUI End GameMaker event* of the Mainframe instance:
    - the **reserved post-frame processing** is executed, ensuring each post-frame action gets a reasonable minimum amount of work done regardless of potential slowdowns
    - the **additional processing target time** is calculated, based on the *next frame expected time* and the *frame margin*
    - the **additional post-frame processing** is executed starting from the lowest order actions, up to the additional processing target time

Ideally, such a cycle makes near-optimal use of the available frame time on the one hand, while matching the intended game speed on the other hand. However, certain problems can disrupt this process.
###### Long base processing

If core processing together with the reserved post-frame processing takes much longer than the expected frame time, then there's no escaping framerate drops - the computer simply can't keep up with the main computations, let alone has time to spare for the additional processing.

For some games, the issue may be alleviated by lowering the game speed (e.g. from 60 FPS to 30 FPS) and/or using delta time to compensate for the lag. Lowering the game speed can allow quicker completion of post-frame tasks, as it expands the available frame time and potentially opens up the room for additional processing each frame.

If post-frame work takes unreasonably long to execute, one may try increasing the reserved number of steps and/or duration; however, it will keep decreasing the framerate. Another option is moving some of the post-frame work in dedicated loading screens rather than squeezing enough processing time over the course of the game. At any rate, when the game runs slow, the primary problem isn't the lack of the additional post-frame processing, but the game running slow.

###### Final iteration remainder

Usually, a post-frame action will run a function with the following structure:

```gml
function(_steps, _time) {
    repeat (_steps) {
        // do the requested number of iterations
    }
    
    while (get_timer() <= _time) {
        // do another iteration
    }
}
```

You may notice such a method doesn't predict when the upcoming iteration will exceed the target processing time. Instead it keeps starting a new iteration as long as there's still some time. Thus, the final iteration will finish sometime after the target time; otherwise, there'd still be time left and another iteration would begin.

For example, if the final iteration starts 5 microseconds before the target time and then lasts for 20 microseconds, the post-frame execution will actually end 15 microseconds later than scheduled - the final iteration remainder. That said, as long as individual iterations don't take too long, the final iteration remainder will be safely absorbed by the frame margin. It only becomes a problem when a single iteration may take similar or greater time than the frame margin.

###### Adjacent events problem

Assuming the base processing doesn't use up the available frame time, there is enough room for additional processing without affecting the framerate. Properly estimated *next frame expected time* and a sufficient *frame margin* should mostly prevent lags. However, those estimations fail to take into account Begin Step GameMaker events executed before the Mainframe gets its turn, as well as Draw GUI End GameMaker events executed after post-frame additional processing.

For example, suppose a given frame starts at the time **T** and the desired frame duration is *20ms*. With the frame margin of *0.5ms*, the frame work should finish around **T+19.5ms** (plus the final iteration remainder).

Then, suppose there's an object with a Begin Step event executed before that of the Mainframe instance, and it takes *1ms* to execute the event. Once the Mainframe instance measures its *next frame expected time*, it will count from **T+1ms** rather than **T**, thus aiming to finish the current frame by **T+21ms** rather than **T+20ms**.

Additionally, suppose there's an object with a Draw GUI End event executed after that of the Mainframe instance, and it takes *2ms* to execute the event. First, the Mainframe instance will perform its post-frame processing until **T+20.5ms** (counted as *T+21ms* next frame expected time minus *0.5ms* frame margin). With the extra *2ms* from the adjacent Draw GUI End event, the frame will overall finish its work around **T+22.5ms** instead of **T+19.5ms** it was supposed to aim for.

Because of that, **when post-frame processing is used, no Begin Step or Draw GUI End GameMaker events should be used outside of the Mainframe instance**. Their logic should be moved to the corresponding Mainframe events instead (i.e. Begin Step and Draw GUI End Mainframe events). Conversely, the caveat doesn't apply if no post-frame processing is used; in such case, the post-frame processor will find no work to do and finish its part pretty much immediately.

## Tweaking the frame parameters

There are two Mainframe object variables that influence the post-frame processing:

- `frame_margin` - how much leeway (in milliseconds) should be left for the final iteration remainder and GameMaker runtime processing between frames
- `frame_duration` - how long the frame processing is allowed to be (in milliseconds); if not defined, the duration will match the game speed (e.g. 20 milliseconds for 50 FPS game speed)

The total time available for a single Mainframe processing loop is equal to `frame_duration - frame_margin` (with frame duration being either the explicitly given value or one matching the game speed). This includes the time spent on core processing (with gameplay logic and drawing) and post-frame processing alike. The longer the time available, the more efficient post-frame processing should get. For example, if core processing takes 10ms each frame, then a 15ms total frame time leaves 5ms for post-frame processing, while a 30ms total frame time leaves 20ms for post-frame processing. Within twice the total frame time four times larger work is done, doubling the efficiency overall.

By default, `frame_margin` is set to 0.5ms while `frame_duration` is left undefined to match the game speed. You can change these starting values by overriding the object variables of the Mainframe instance.

Those defaults should work reasonably well for background processing during the core gameplay. However, sometimes one might want to prioritise quick completion of background tasks over framerate (especially during loading screens). To tweak the frame time variables, the following functions are available:

- `mainframe_set_frame_margin(margin)` - sets the frame margin to the given value (in milliseconds)
- `mainframe_set_frame_duration(duration)` - explicitly sets the frame duration to the given value (in milliseconds) and overrides the game speed
- `mainframe_clear_frame_duration()` - resets the frame duration so that it matches the game speed

An alternative to tweaking the frame margin and duration is setting a lower game speed during loading segments in the first place (increasing available per-frame time). The difference is that lower game speed stays as such even after all post-frame actions have finished, while tweaking frame parameters makes the game return to original framerate after all work is done. It's up to the developer to decide which works better for them.

-----

[<< 02 - Mainframe Events](/Docs/02%20-%20Mainframe%20Events.md) | **03 - Post-frame Processing** | [04 - Demo Example >>](/Docs/04-%20-%20Demo%20Example.md)
