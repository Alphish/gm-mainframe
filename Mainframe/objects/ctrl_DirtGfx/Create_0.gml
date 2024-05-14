bits = array_create_ext(15_000, function() {
   return {
       x: irandom_range(10, room_width - 20),
       y: irandom_range(10, room_height - 20),
       width: irandom_range(2, 5),
       height: irandom_range(2, 5),
   }
});
