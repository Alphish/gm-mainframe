/// @description Processing movement

// bounce back when facing an obstacle
if (!place_free(x + xspd, y + yspd)) {
    xspd = -xspd;
    yspd = -yspd;
}

// keep moving
x += xspd;
y += yspd;
