/// @description Processing movement

var _hdir = ctrl_Input.right_down - ctrl_Input.left_down;
var _vdir = ctrl_Input.down_down - ctrl_Input.up_down;

if (place_free(x + _hdir * spd, y))
    x += _hdir * spd;

if (place_free(x, y + _vdir * spd))
    y += _vdir * spd;
