shader_type spatial;
//render_mode unshaded;
render_mode depth_draw_alpha_prepass,blend_mix,world_vertex_coords,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 color : hint_color;
uniform float Metallic : hint_range(0,1);
uniform float Roughness : hint_range(0,1);
uniform sampler2D WaveNormals;
uniform float NormalScale = 1;
uniform vec4 Wave1;
uniform vec4 Wave2;
uniform vec4 Wave3;
uniform vec4 Wave4;
const float pi = 3.14159265359;

varying float k;
varying float c;
varying vec2 d;
varying float f;
varying float a;
varying vec3 pos;

vec3 CalculateNormals(){
	vec3 tangent = vec3(
		1.0 - d.x * d.x * (Wave1.y * sin(f)),
		d.x * (Wave1.y * cos(f)),
		-d.x * d.y * (Wave1.y * sin(f))
	);
	vec3 binormal = vec3(
		-d.x * d.y * (Wave1.y * sin(f)),
		d.y* (Wave1.y * cos(f)),
		1.0 - d.y * d.y * (Wave1.y * sin(f))
	);
	vec3 finalnormal = normalize(cross(binormal,tangent));
	return finalnormal;
}

void vertex(){
	pos = VERTEX;
	
	k = 2.0 * pi / Wave1.x;
	c = sqrt(9.8/k);
	d = normalize(vec2 (Wave1.z,Wave1.w));
	f = k * (dot(d,vec2(VERTEX.x,VERTEX.z) - c * TIME));
	a = Wave1.y / k;
	VERTEX.x += d.x * (a * cos(f));
	VERTEX.y = a * sin(f);
	VERTEX.z += d.y * (a * cos(f));
	NORMAL = CalculateNormals();
}

void fragment(){
	METALLIC = Metallic;
	ROUGHNESS = Roughness;
	ALBEDO = color.xyz;
	ALPHA = color.a;
	NORMALMAP = texture(WaveNormals,vec2(pos.x,pos.z)).xyz;
	NORMALMAP_DEPTH = NormalScale;
}