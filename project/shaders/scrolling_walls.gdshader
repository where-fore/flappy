shader_type canvas_item;

uniform float speed = 0.1;
uniform float scroll_offset = 0.0;

void vertex() {
    UV.x += scroll_offset;
}