shader_type canvas_item;

uniform float speed : hint_range(0.0, 10.0) = 1.0;
uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform float spatial_scale : hint_range(0.0, 10.0) = 4.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    float spatial = length(SCREEN_UV - vec2(0.5)) * spatial_scale * 4.0;

    float t = TIME * speed + spatial;

    float s = sin(t);
    float c = cos(t);

    mat3 rot = mat3(
        vec3(0.299 + 0.701*c + 0.168*s, 0.587 - 0.587*c + 0.330*s, 0.114 - 0.114*c - 0.497*s),
        vec3(0.299 - 0.299*c - 0.328*s, 0.587 + 0.413*c + 0.035*s, 0.114 - 0.114*c + 0.292*s),
        vec3(0.299 - 0.300*c + 1.250*s, 0.587 - 0.588*c - 1.050*s, 0.114 + 0.886*c - 0.203*s)
    );

    vec3 rotated = rot * tex.rgb;

    COLOR = vec4(mix(tex.rgb, rotated, intensity), tex.a);
}
