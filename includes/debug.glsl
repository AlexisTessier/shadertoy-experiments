#define INCLUDE_DEBUG

vec4 debug(bool condition){
	return condition ? vec4(0.0, 0.5, 0.0, 1.0) : vec4(0.5, 0.0, 0.0, 1.0);
}