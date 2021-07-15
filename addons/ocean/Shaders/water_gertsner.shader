shader_type spatial;
//render_mode unshaded;
render_mode blend_mix,depth_draw_always,cull_disabled,diffuse_burley,specular_schlick_ggx, world_vertex_coords;
uniform vec4 WaveColor : hint_color;
uniform float Metallic : hint_range(0,1);
uniform float Roughness : hint_range(0,1);
uniform float Specular : hint_range(0,1);
uniform sampler2D FoamTexture;
uniform vec2 FoamTiling = vec2(1.0,1.0);
uniform sampler2D Normals: hint_normal;
uniform float NormalsAScale = 1;
uniform float NormalsBScale = 0.5;
uniform float NormalsASpeed = 1;
uniform float NormalsBSpeed = 1;
uniform float NormalsDepth = 0.2;
uniform sampler2D foamParticleMask;
uniform vec2 foamMaskWorldPos;
uniform float BorderFoamFade = 0.2;
uniform vec2 WaveFoamHeightMinMax = vec2(2.0,4);
uniform float RefractionStrength = 0.025;
uniform float WaterDepthFade = 2.0;
uniform vec4 Wave1;
uniform vec4 Wave2;
uniform vec4 Wave3;
uniform vec4 Wave4;
const float pi = 3.14159265359;

varying vec3 pos;
varying vec3 finalPos;
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
	float result = dot(normal, vec3(direction.x, 0.4, direction.y));
	result = remap(result, -1, 1, 0, 1);
	return result;
}

float LinearDepth(sampler2D depthTex, vec2 screenuv, mat4 invprojectionmatrix){
	float depth = texture(depthTex,screenuv).x;
	vec3 ndc = vec3(screenuv,depth) * 2.0 - 1.0;
	vec4 view = invprojectionmatrix * vec4(ndc,1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	return linear_depth;
}

float DepthFoamMask(sampler2D depthTex,vec2 screenuv, mat4 invprojectionmatrix, float vertexdepth){
	float depth_tex = textureLod(depthTex,screenuv,0.0).r;
	vec4 world_pos = invprojectionmatrix * vec4(screenuv*2.0-1.0,depth_tex*2.0-1.0,1.0);
	world_pos.xyz /= world_pos.w;
	float depthfoammask = clamp(1.0-smoothstep(world_pos.z+BorderFoamFade,world_pos.z,vertexdepth),WaveFoamHeightMinMax.y,WaveFoamHeightMinMax.x);
	return 1.0 - depthfoammask;
}

float FoamParticleMask(){
	float foamparticlemask = texture(foamParticleMask,((finalPos.xz + vec2(64.0,64.0) + foamMaskWorldPos) / 128.0)).r;
	return clamp(foamparticlemask,0,1);
}

vec2 RefractedUVs(vec2 screenPos, vec2 tangentspaceNormals, float lineardepth, float surfacedepth){
	vec2 uvOffset = tangentspaceNormals;
	float depthDifference = lineardepth + surfacedepth;
	uvOffset *= depthDifference * RefractionStrength;
	vec2 refraction = (screenPos.xy + uvOffset);
	return refraction;
}

vec2 rotate(vec2 uv, vec2 pivot, float angle){
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						 vec2(cos(angle), sin(angle)));
	
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

void vertex(){
	pos = VERTEX;
	WaveMask = 0.0;
	vec3 tangent = vec3(1,0,0);
	vec3 binormal = vec3(0,0,1);
	vec3 p = pos;
	
	vec3 g1tangent = tangent;
	vec3 g1binormal = binormal;
	vec3 g1 = GertsnerWave(Wave1,pos,TIME,g1tangent,g1binormal);
	vec3 g1Normal = normalize(cross(g1binormal,g1tangent));
	WaveMask += WaveFoamMask(g1Normal,vec2(Wave1.z,Wave1.w));
	
	vec3 g2tangent = g1tangent;
	vec3 g2binormal = g1binormal;
	vec3 g2 = GertsnerWave(Wave2,pos,TIME,g2tangent,g2binormal);
	vec3 g2Normal = normalize(cross(g2binormal,g2tangent));
	WaveMask = max(WaveMask, WaveFoamMask(g2Normal,vec2(Wave2.z,Wave2.w)));
	
	vec3 g3tangent = g2tangent;
	vec3 g3binormal = g2binormal;
	vec3 g3 = GertsnerWave(Wave3,pos,TIME,g3tangent,g3binormal);
	vec3 g3Normal = normalize(cross(g3binormal,g3tangent));
	WaveMask = max(WaveMask,WaveFoamMask(g3Normal,vec2(Wave3.z,Wave3.w)));
	
	
	vec3 g4tangent = g3tangent;
	vec3 g4binormal = g3binormal;
	vec3 g4 = GertsnerWave(Wave4,pos,TIME,g4tangent,g4binormal);
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
	finalPos = p;
}

void fragment(){
	vec3 normal1 = texture(Normals,(pos.xz / NormalsAScale) + ((normalize(Wave1.zw) * TIME * -NormalsASpeed))).xyz;
	vec3 n1_unpacked = normal1 * 2.0 - 1.0;
	vec3 normal2 = texture(Normals,(pos.xz / NormalsBScale) + ((normalize(Wave4.zw) * TIME * -NormalsBSpeed))).xyz;
	vec3 n2_unpacked = normal2 * 2.0 - 1.0;
	vec3 r = normalize(vec3(n1_unpacked.xy + n2_unpacked.xy, n1_unpacked.z*n2_unpacked.z));
	
	NORMALMAP = r * 0.5 + 0.5;
	NORMALMAP_DEPTH = NormalsDepth;
	
	float FoamMask = smoothstep(WaveMask,0.55,0.8);
	FoamMask = 0.0;
	
	float depthfoammask = DepthFoamMask(DEPTH_TEXTURE,SCREEN_UV,INV_PROJECTION_MATRIX,VERTEX.z);
	FoamMask = max(FoamMask,depthfoammask);
	float foamparticlemaskfinal = FoamParticleMask();
	FoamMask = max(FoamMask,foamparticlemaskfinal);
	FoamMask = texture(FoamTexture,pos.xz / FoamTiling).r * FoamMask;
	
	vec3 n_unpacked = NORMALMAP * 2.0 - 1.0;
	vec3 n_t = n_unpacked.x * TANGENT;
	vec3 n_b = n_unpacked.y * BINORMAL;
	vec3 vs_n = n_t + n_b;
	
	
	float linear_depth = LinearDepth(DEPTH_TEXTURE,SCREEN_UV,INV_PROJECTION_MATRIX);
	
	vec2 refractedScreenUV = RefractedUVs(SCREEN_UV,NORMAL.xy + (vs_n.xy * NORMALMAP_DEPTH), linear_depth,VERTEX.z);
	float refracteddepth_tex = textureLod(DEPTH_TEXTURE,refractedScreenUV,0.0).r;
	vec4 refractedworld_pos = INV_PROJECTION_MATRIX * vec4((refractedScreenUV)*2.0-1.0,refracteddepth_tex*2.0-1.0,1.0);
	refractedworld_pos.xyz /= refractedworld_pos.w;	
	
	float depthwatermask = clamp(1.0-smoothstep(refractedworld_pos.z+WaterDepthFade,refractedworld_pos.z,VERTEX.z),0.0,1.0);
	vec3 screen = texture(SCREEN_TEXTURE,refractedScreenUV).rgb;
	vec3 colorfinal = mix(screen.rgb, WaveColor.rgb,depthwatermask);
	ALBEDO = mix(colorfinal,vec3(1,1,1), FoamMask);
	//METALLIC = Metallic;
	METALLIC = mix(Metallic,0,FoamMask);
	//ROUGHNESS = Roughness;
	ROUGHNESS = mix(Roughness,1,FoamMask);
	SPECULAR = Specular;
	//linear_depth = clamp((linear_depth + VERTEX.z) * 0.0025 ,0.0,1.0);
	//ALBEDO = vec3(linear_depth ,linear_depth,linear_depth);
	//ALBEDO = vec3(depthfoammask,depthfoammask,depthfoammask);
	//ALBEDO = NORMAL;
	//RIM = 1.0;
	float depthAlpha = smoothstep(linear_depth + VERTEX.z,-0.05,0.25);
	//ALPHA = depthAlpha;
}