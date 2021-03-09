shader_type spatial;
//render_mode unshaded;
render_mode blend_mix,depth_draw_always,cull_back,diffuse_burley,specular_schlick_ggx, world_vertex_coords;
uniform vec4 WaveColor : hint_color;
uniform float Metallic : hint_range(0,1);
uniform float Roughness : hint_range(0,1);
uniform float Specular : hint_range(0,1);
uniform sampler2D FoamTexture;
uniform sampler2D NormalsA : hint_normal;
uniform float NormalsAScale = 1;
uniform sampler2D NormalsB : hint_normal;
uniform float NormalsBScale = 0.5;
uniform float NormalSpeed = 1;
uniform float NormalsDepth = 0.2;
uniform float BorderFoamFade = 0.2;
uniform sampler2D RefractionTexture;
uniform vec2 RefractionScale;
uniform float RefractionStrength;
uniform float WaterDepthFade = 2.0;
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

float depth_fade(float distance){
	return 1.0;
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
	float result = dot(normal, vec3(direction.x, 0.4, direction.y));
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
	
	vec3 g2tangent = g1tangent;
	vec3 g2binormal = g1binormal;
	vec3 g2 = GertsnerWave(Wave2,gridPoint,TIME,g2tangent,g2binormal);
	vec3 g2Normal = normalize(cross(g2binormal,g2tangent));
	WaveMask = max(WaveMask, WaveFoamMask(g2Normal,vec2(Wave2.z,Wave2.w)));
	
	vec3 g3tangent = g2tangent;
	vec3 g3binormal = g2binormal;
	vec3 g3 = GertsnerWave(Wave3,gridPoint,TIME,g3tangent,g3binormal);
	vec3 g3Normal = normalize(cross(g3binormal,g3tangent));
	WaveMask = max(WaveMask,WaveFoamMask(g3Normal,vec2(Wave3.z,Wave3.w)));
	
	
	vec3 g4tangent = g3tangent;
	vec3 g4binormal = g3binormal;
	vec3 g4 = GertsnerWave(Wave4,gridPoint,TIME,g4tangent,g4binormal);
	vec3 g4Normal = normalize(cross(g4binormal,g4tangent));
	WaveMask =  max(WaveMask,WaveFoamMask(g4Normal,vec2(Wave4.z,Wave4.w)));
	
	WaveMask = clamp(WaveMask,0,1);
	
	p += g1;
	p += g2;
	p += g3;
	p += g4;
	tangent = g4tangent;
	binormal = g4binormal;
	
	
	NORMAL = normalize(cross(binormal,tangent));
	
	VERTEX = p;
}

void fragment(){
	vec3 normal1 = texture(NormalsA,(pos.xz * NormalsAScale) + TIME * NormalSpeed).xyz * 2.0 - 1.0;
	vec3 normal2 = texture(NormalsB,(pos.xz * NormalsBScale) - TIME * NormalSpeed).xyz * 2.0 - 1.0;
	vec2 pd = normal1.xy/normal1.z + normal2.xy/normal2.z;
	vec3 r = normalize(vec3(pd,1));
	
	NORMALMAP = r * 0.5 + 0.5;
	NORMALMAP = texture(NormalsA,(vec2(pos.x,pos.z)*NormalsAScale) + TIME * NormalSpeed).xyz;
	NORMALMAP_DEPTH = NormalsDepth;
	
	float WaveMaskFinal = smoothstep(WaveMask,0.55,0.8);
	float depth_tex = textureLod(DEPTH_TEXTURE,SCREEN_UV,0.0).r;
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV*2.0-1.0,depth_tex*2.0-1.0,1.0);
	world_pos.xyz /= world_pos.w;
	float depthfoammask = clamp(1.0-smoothstep(world_pos.z+BorderFoamFade,world_pos.z,VERTEX.z),0.0,1.0);
	WaveMaskFinal = max(WaveMaskFinal,1.0 - depthfoammask);
	//float WaveMaskFinal = step(WaveMask,0.4);
	WaveMaskFinal = texture(FoamTexture,pos.xz).r * WaveMaskFinal;
	
	//METALLIC = mix(Metallic,0,WaveMaskFinal);
	METALLIC = Metallic;
	//ROUGHNESS = mix(Roughness,1,WaveMaskFinal);
	ROUGHNESS = Roughness;
	SPECULAR = Specular;
	
	float refraction = texture(RefractionTexture,(pos.xz + (TIME * 0.25)) * RefractionScale.xy).r - 0.5;
	refraction = refraction * RefractionStrength;
	
	vec2 refractedScreenUV = SCREEN_UV + refraction;
	
	float refracteddepth_tex = textureLod(DEPTH_TEXTURE,refractedScreenUV,0.0).r;
	vec4 refractedworld_pos = INV_PROJECTION_MATRIX * vec4((refractedScreenUV)*2.0-1.0,refracteddepth_tex*2.0-1.0,1.0);
	refractedworld_pos.xyz /= refractedworld_pos.w;	
	float depthwatermask = clamp(1.0-smoothstep(refractedworld_pos.z+WaterDepthFade,refractedworld_pos.z,VERTEX.z),0.0,1.0);
	
	vec3 screen = texture(SCREEN_TEXTURE,SCREEN_UV + (refraction)).xyz;
	vec3 colorfinal = mix(screen.xyz, WaveColor.xyz,depthwatermask);
	//ALBEDO = vec3(depthwatermask,depthwatermask,depthwatermask);
	ALBEDO = mix(colorfinal,vec3(1,1,1), WaveMaskFinal);
	//ALBEDO = NORMAL;
	ALPHA = 1.0;
}