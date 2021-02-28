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

varying vec3 pos;

vec3 GertsnerWave(vec4 Wave, vec3 p, float time, inout vec3 tangent, inout vec3 binormal){
	float steepness = Wave.y;
	float wavelength = Wave.x;
	float k = 2.0 * pi / wavelength;
	float c = sqrt(9.8 / k);
	vec2 d = normalize(Wave.zw);
	float f = k * (dot(d,p.xz) - c * time);
	float a = steepness/k;
	
	tangent += vec3(
		-d.x * d.x * (steepness * sin(f)),
		d.x * (steepness * cos(f)),
		-d.x * d.y * (steepness * sin(f))
	);
	
	binormal += vec3(
		-d.x * d.y * (steepness * sin(f)),
		d.y * (steepness * cos(f)),
		-d.y * d.y * (steepness * sin(f))
	);
	
	return vec3(
		d.x * (a * cos(f)),
		a * sin(f),
		d.y * (a * cos(f))
	);
}

void vertex(){
	pos = VERTEX;
	vec3 gridPoint = VERTEX;
	vec3 tangent = vec3(1,0,0);
	vec3 binormal = vec3(0,0,1);
	vec3 p = gridPoint;
	p += GertsnerWave(Wave1,gridPoint,TIME,tangent,binormal);
	p += GertsnerWave(Wave2,gridPoint,TIME,tangent,binormal);
	
	NORMAL = normalize(cross(binormal,tangent));
	VERTEX = p;
}

void fragment(){
	METALLIC = Metallic;
	ROUGHNESS = Roughness;
	ALBEDO = color.xyz;
	ALPHA = color.a;
	NORMALMAP = texture(WaveNormals,vec2(pos.x,pos.z)).xyz;
	NORMALMAP_DEPTH = NormalScale;
}