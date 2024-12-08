shader_type spatial;

uniform float dot_size : hint_range(0.0, 1.0) = 0.1; // Size of each dot
uniform float dot_spacing : hint_range(0.0, 1.0) = 0.2; // Space between dots
uniform float speed : hint_range(0.0, 5.0) = 1.0; // Speed of dot movement
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Line color

void fragment() {
    // Calculate the length along the UV space
    float line_length = fract(UV.x + TIME * speed);

    // Create a repeating pattern using the dot size and spacing
    float pattern = step(line_length, dot_size);

    // Set the line color where the pattern is visible
    if (pattern > 0.0) {
        ALBEDO = line_color.rgb;
        ALPHA = line_color.a;
    } else {
        discard; // Make the non-dot areas transparent
    }
}
