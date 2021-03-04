shader_type spatial;
//render_mode unshaded;
render_mode depth_draw_alpha_prepass,blend_mix,world_vertex_coords, diffuse_lambert, specular_schlick_ggx;
uniform vec4 WaveColor : hint_color;
uniform float Metallic : hint_range(0,1);
uniform float Roughness : hint_range(0,1);
uniform sampler2D NormalsA : hint_normal;
uniform float NormalsAScale = 1;
uniform sampler2D NormalsB : hint_normal;
uniform float NormalsBScale = 0.5;
uniform float NormalSpeed = 1;
uniform float NormalsDepth = 0.2;
uniform vec4 Wave1;
uniform vec4 Wave2;
uniform vec4 Wave3;
uniform vec4 Wave4;
const float pi = 3.14159265359;

varying vec3 pos;
varying float WaveMask;

float remap(float value, float InputA, float InputB, float OutputA, float OutputB){
    return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA;
}

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

float WaveFoamMask(vec3 normal, vec2 direction){
	direction = normalize(-direction);
	float result = dot(normal, vec3(direction.x, 0, direction.y));
	result = remap(result, -1, 1, 0, 1);
	return result;
}

void vertex(){
	pos = VERTEX;
	WaveMask = 0.0;
	vec3 gridPoint = VERTEX;
	vec3 tangent = vec3(1,0,0);
	vec3 binormal = vec3(0,0,1);
	vec3 p = gridPoint;
	
	vec3 g1tangent = tangent;
	vec3 g1binormal = binormal;
	vec3 g1 = GertsnerWave(Wave1,gridPoint,TIME,g1tangent,g1binormal);
	vec3 g1Normal = normalize(cross(g1binormal,g1tangent));
	WaveMask += WaveFoamMask(g1Normal,vec2(Wave1.z,Wave1.w));
	
	vec3 g2tangent = tangent;
	vec3 g2binormal = binormal;
	vec3 g2 = GertsnerWave(Wave2,gridPoint,TIME,g2tangent,g2binormal);
	vec3 g2Normal = normalize(cross(g2binormal,g2tangent));
	WaveMask = max(WaveMask, WaveFoamMask(g2Normal,vec2(Wave2.z,Wave2.w)));
	
	vec3 g3tangent = tangent;
	vec3 g3binormal = binormal;
	vec3 g3 = GertsnerWave(Wave3,gridPoint,TIME,g3tangent,g3binormal);
	vec3 g3Normal = normalize(cross(g3binormal,g3tangent));
	WaveMask = max(WaveMask,WaveFoamMask(g3Normal,vec2(Wave3.z,Wave3.w)));
	
	
	vec3 g4tangent = tangent;
	vec3 g4binormal = binormal;
	vec3 g4 = GertsnerWave(Wave4,gridPoint,TIME,g4tangent,g4binormal);
	vec3 g4Normal = normalize(cross(g4binormal,g4tangent));
	WaveMask =  max(WaveMask,WaveFoamMask(g4Normal,vec2(Wave4.z,Wave4.w)));
	
	//WaveMask = WaveMask / 4.0;
	
	p += g1;
	p += g2;
	p += g3;
	p += g4;
	//tangent += g1tangent + g2tangent + g3tangent + g4tangent;
	//binormal += g1binormal + g2binormal + g3binormal + g4binormal;
	
	NORMAL = normalize(cross(binormal,tangent));
	
	VERTEX = p;
}

void fragment(){
	METALLIC = Metallic;
	ROUGHNESS = Roughness;
	
	//ALBEDO = mix(WaveColor.xyz,vec3(1,1,1), smoothstep(COLOR.a,0.25,0.6));
	float WaveMaskFinal = smoothstep(WaveMask,0.3,0.55);
	ALBEDO = vec3(WaveMaskFinal,WaveMaskFinal,WaveMaskFinal);
	//ALBEDO = COLOR.rgb;
	ALPHA = WaveColor.a;
	
	vec3 normal1 = texture(NormalsA,(vec2(pos.x,pos.z) * NormalsAScale) + TIME * NormalSpeed).xyz * 2.0 - 1.0;
	vec3 normal2 = texture(NormalsB,(vec2(pos.x,pos.z) * NormalsBScale) - TIME * NormalSpeed).xyz * 2.0 - 1.0;
	vec2 pd = normal1.xy/normal1.z + normal2.xy/normal2.z;
	vec3 r = normalize(vec3(pd,1));
	NORMALMAP = r * 0.5 + 0.5;
	NORMALMAP_DEPTH = NormalsDepth;
}