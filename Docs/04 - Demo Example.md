[<< Back to home](https://github.com/Alphish/gm-mainframe)

[<< 03 - Post-frame Processing](/Docs/03%20-%20Post-frame%20Processing.md) | **04 - Demo Example**

-----

# Demo Example

The following page describes how Mainframe is applied in a demo example, available for download [here](http://www.example.com).

The demo showcases Mainframe events management and use of post-frame processing in a simple maze game.

**Note:** The demo example already has everything set up. Rather than creating everything from scratch according to the instructions below, it's recommended to follow along by checking code already present in the example.

## Mainframe setup

First of all, make sure the project has Mainframe properly installed. This involves importing all contents of the Mainframe package into the project and placing an instance of `sys_Mainframe` into the initial room. You can read more about the setup on the [Overview page](/Docs/01%20-%20Overview.md).

## Input system

Before implementing the core gameplay, let's set up a non-trivial input system. Every frame, it will process keyboard inputs (left arrow key, letter D, etc.) and determine the state of logical inputs (move left, move right, move up, move down).

With that in mind, create a `ctrl_Input` object with the following variable definitions in its **Create** event:

```gml
right_down = false;
up_down = false;
left_down = false;
down_down = false;
```

The inputs should be processed near the start of each frame, so that subsequent logic uses up-to-date input values. Normally, the Begin Step GameMaker event would be a good place for it. However, the demo will use post-frame processing alongside the core gameplay, so regular Basic Step and Draw GUI End events are out of question. Instead, input detection will be added to the Begin Step Mainframe event - still in the **Create** event - like so:

```gml
input_action = mainframe_begin_step_add_action(function() {
    right_down = keyboard_check(vk_right) || keyboard_check(ord("D"));
    up_down = keyboard_check(vk_up) || keyboard_check(ord("W"));
    left_down = keyboard_check(vk_left) || keyboard_check(ord("A"));
    down_down = keyboard_check(vk_down) || keyboard_check(ord("S"));
}, /* order */ 0);
```

Now every time Mainframe instance runs its Begin Step event, the input values will update accordingly, responding to both arrow keys and WASD for directional inputs.

However, an instnace that adds a Mainframe action should ideally remove it once it's gone. Thus, the following **Clean Up** event should be added to tie the loose ends:

```gml
input_action.remove();
```

## Core gameplay

The maze game needs the following entities:

- the player, moving around using the directional inputs
- enemies that restart the level upon colliding with the player
- walls that block the player movement

Since it's a simple demonstration, there are no win conditions, just walking around, enjoying the view and trying not to run into the enemy.

#### Wall

Let's start with a wall object, called `obj_Wall`. Make a sprite for it and mark it as "Solid". That's the easiest part done.

#### Player

Now, let's make the player object, called `obj_Player`. Make another sprite for it, and then set up a simple speed variable to 4 pixels per frame in its **Create** event:

```gml
spd = 4; // alas, "speed" variable is reserved
```

Then let's add **User Event 0** with the following movement logic:

```gml
var _hdir = ctrl_Input.right_down - ctrl_Input.left_down;
var _vdir = ctrl_Input.down_down - ctrl_Input.up_down;

if (place_free(x + _hdir * spd, y))
    x += _hdir * spd;

if (place_free(x, y + _vdir * spd))
    y += _vdir * spd;
``` 

This will implement a simple four-directional movement using the `ctrl_Input` logical inputs. It doesn't use precise collision detection, but as long as player and walls coordinates stay snapped to 4x4 grid, it's not a problem. Going out of room can be solved with a clever level design technique known as "place them walls around room edges".

#### Enemy

Finally, let's make the enemy object, called `obj_Enemy`. The enemy will move at a constant speed set at start, and if it meets a wall, it will turn back, bouncing between two points.

Make an enemy sprite and then add two Object Variables `xspd` and `yspd`, set to 0 by default. They determine the initial horizontal and vertical speed.

To enforce the bouncing movement, add **User Event 0** to the enemy object as follows:

```gml
// bounce back when facing an obstacle
if (!place_free(x + xspd, y + yspd)) {
    xspd = -xspd;
    yspd = -yspd;
}

// keep moving
x += xspd;
y += yspd;
```

Finally, add collision detection to the player object (not enemy!), so that the game restarts when colliding with the enemy. It can be done by putting the following code in **User Event 1**:

```gml
if (place_meeting(x, y, obj_Enemy))
    room_restart();
```

#### In-game controller

If you run the game - having placed the player, some walls and enemies - you'll notice they do a whole lot of nothing. That's because the player and enemies logic is in user-defined events which aren't executed automatically.

Thus, let's make the in-game controller object called `ctrl_Ingame`. The gameplay logic needs to be ordered properly - first the player and enemies make their movement, and only then the player checks if it collides with an enemy. To enforce the ordering, the Step Mainframe event will be used.

In the **Create** event of the in-game controller add Step event actions based on the user-defined events:

```gml
player_movement_action = mainframe_step_add_user_event(obj_Player, 0, /* order */ 0);
enemy_movement_action = mainframe_step_add_user_event(obj_Enemy, 0, /* order */ 1);
player_collision_action = mainframe_step_add_user_event(obj_Player, 1, /* order */ 2);
```

Also, make sure no actions are left over. Otherwise restarting the room will cause more and more repetitions of the movement and collision checking logic, eventually leading to a very dynamic but also very unplayable experience.

```gml
player_movement_action.remove();
enemy_movement_action.remove();
player_collision_action.remove();
```

Once the in-game controller is placed in the room, the player and enemies should behave properly.

## Needlessly expensive graphics effects

Before setting up background work for post-frame processing, let's make the game grittier by adding a bunch of random dirt patches. They will be drawn by an object called `ctrl_DirtGfx`.

First, set these up in the **Create** event like so:

```gml
dirt_patches = array_create_ext(20_000, function() {
   return {
       x: irandom_range(-10, room_width + 20),
       y: irandom_range(-10, room_height + 20),
       width: irandom_range(2, 5),
       height: irandom_range(2, 5),
   }
});
```

Then, dirt patches should be drawn properly in the **Draw** event:

```gml
// draw patches
draw_set_color(merge_color(c_orange, c_black, 0.75));
draw_set_alpha(0.2);

array_foreach(dirt_patches, function(_bit) {
    draw_rectangle(_bit.x, _bit.y, _bit.x + _bit.width - 1, _bit.y + _bit.height - 1, false);
});

// reset drawing settings
draw_set_color(c_white);
draw_set_alpha(1);
```

To make sure the game can run on a potato, add an option to disable the "high-quality" graphics with a space bar press. It can be done by simply toggling visibility in the **Key Press - Space** event:

```gml
visible = !visible;
```

With all that set up, put an instance of `ctrl_DirtGfx` in the demo room and feast your eyes on amazing procedural graphics. It will likely make the core frame processing take several times longer, but certain sacrifices need to be made for the *art*.

## Background work

Mainframe post-frame processing can be used for a variety of important background tasks, such as polling weak references in a custom garbage-collection system, parsing a dialogue file or executing AI opponent algorithms. Here, it will be used for counting up, one by one, to a very large value.

Let's create a count-up controller object, called `ctrl_Countup`, and define the starting and target value in the **Create** event:

```gml
counter = 0;
target = 100_000_000;
```

Additionally, the logic for the post-frame processing is needed. It will be stored in the `count_up` method, also defined in the **Create** event:

```gml
count_up = function(_steps, _time) {
    if (counter >= target)
        return;
    
    repeat (_steps) {
        counter++;
        
        if (counter >= target)
            return;
    }
    
    while (get_timer() <= _time) {
        counter++;
        
        if (counter >= target)
            return;
    }
}
```

First, it performs the number of increments matching the requested number of steps. Then it tries to perform as many increments as possible until reaching the target time. To prevent overshooting the target value, a few checks are added, exiting the processing as soon as the target value is reached.

In the **Create** event, the method call is added to the post-frame action like so:

```gml
count_up_action = mainframe_post_frame_add_method_call(id, "count_up");
```

It's possible to specify its order and reserved number of steps/duration as well:

```gml
count_up_action = mainframe_post_frame_add_method_call(id, "count_up", /* order */ 10, /* reserved steps*/ 100, /* reserved duration */ 0.1);
```

This will ensure that every frame, at least 100 increment steps will be attempted and at least 0.1ms will be reserved from the frame time for the processing. Of course, if there's no more processing to be done, the `count_up` method will exit early, freeing up some of the reserved time.

Similarly to Mainframe event actions, the count-up action needs to be removed from post-frame processing in the **Clean Up** event:

```gml
count_up_action.remove();
```

Finally, a user interface is needed to show basic instructions and the task progress. Strictly speaking, separation of concerns would require handling game instructions via another object, but it might be an overkill for something that isn't the main topic of the tutorial.

For drawing the text, create a simple font called `fnt_Default`. Then, add the following code to the **Draw GUI** event (since it's not Draw GUI *End* event, it's fine to use outside the Mainframe events):

```gml
// top and bottom bars to display instructions/informations
draw_set_alpha(0.7);
draw_set_color(c_black);
draw_rectangle(0, room_height - 20, room_width, room_height, false);
draw_rectangle(0, 0, room_width, 19, false);

// progress bar at the bottom
draw_set_alpha(0.7);
draw_set_color(c_teal);
draw_rectangle(0, room_height - 20, round(room_width * counter / target), room_height, false);

// instructions and informations text
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(fnt_Default);

draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text(10, 10, $"Use arrow keys or WASD to move | Press space to toggle dirt GFX");
draw_text(10, room_height - 10, $"Background work done: {string_format(100 * counter / target, 0, 0)}%");
draw_text(room_width - 280, room_height - 10, $"Effective FPS: {fps_real}");
```

This will show a bar with instructions at the top and a gradually filling progress bar at the bottom. Additionally, the count-up progress and effective FPS will be drawn on top of the progress bar. Just make sure to add an instance of `ctrl_Countup` to the room.

## Summary

Following these steps, a simple demonstration is made.

- in the Begin Step Mainframe event, logical inputs are updated according to the keyboard keys state
    - thanks to using Begin Step Mainframe event rather than the corresponding GameMaker event, there's no risk of distoring the post-frame processing
- in the Step Mainframe event, the following is executed in order:
    - player moves according to the logical inputs
    - enemies move according to their simple bounce-around behaviour
    - player checks for collision with enemies, restarting the room if a collision is detected
- some dirt visual effect is drawn, toggle-able with Space
- a count-up work is done in the post-frame processing
    - disabling the dirt visuals should significantly speed up the work, because the time earlier spent for needlessly expensive visuals goes into post-frame processing instead
    - the speed of the count-up work may vary depending on overall game performance, and by extension on individual computers specs

Thus, this demo should cover basic use of Mainframe events and/or post-frame processing.

**Note:** You can observe the impact of post-frame processing by checking the effective FPS. While the count-up task is still being processed - and assuming no slowdowns from the core processing - the effective FPS should be slightly above the target game framerate. Once the task finishes and no post-frame processing remains to be done, the effective FPS should roughly match the core processing time alone (e.g. if core processing takes about 5ms, effective FPS should be around 200).

-----

[<< 03 - Post-frame Processing](/Docs/03%20-%20Post-frame%20Processing.md) | **04 - Demo Example**
