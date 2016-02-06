#define INCLUDE_CGU_COMMON_COMPUTATIONS

vec3 normal(vec3 a, vec3 b){
	return cross(normalize(a), normalize(b));
}

float lightReceptionFactor(vec3 lightRayDirection, vec3 surfaceNormal){
	return abs(dot(lightRayDirection, surfaceNormal));
}