shader_type spatial;
//render_mode unshaded;
uniform float WaveLength;
uniform float Steepness;
uniform vec2 Direction = vec2(1,0);
const float pi = 3.14159265359;

varying float k;
varying float c;
varying vec2 d;
varying float f;
varying float a;

void vertex(){
	k = 2.0 * pi / WaveLength;
	c = sqrt(9.8/k);
	d = normalize(Direction);
	f = k * (dot(d,vec2(VERTEX.x,VERTEX.z) - c * TIME));
	a = Steepness / k;
	VERTEX.x += d.x * (a * cos(f));
	VERTEX.y = a * sin(f);
	VERTEX.z += d.y * (a * cos(f));
}

void fragment(){

	vec3 tangent = vec3(
		1.0 - d.x * d.x * (Steepness * sin(f)),
		d.x * (Steepness * cos(f)),
		-d.x * d.y * (Steepness * sin(f))
	);
	vec3 binormal = vec3(
		-d.x * d.y * (Steepness * sin(f)),
		d.y* (Steepness * cos(f)),
		1.0 - d.y * d.y * (Steepness * sin(f))
	);
	vec3 finalnormal = normalize(cross(binormal,tangent));
	NORMAL = finalnormal;
	//ALBEDO = finalnormal;
}