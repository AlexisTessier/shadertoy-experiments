#define INCLUDE_MATERIAL

struct Material{
	vec4 color;

#ifdef MATERIAL_TEST
	float reflection;
#endif
};