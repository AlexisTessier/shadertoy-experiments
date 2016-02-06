#define INCLUDE_TRIANGLE

struct Triangle{
	mat3 vertices;
	#ifdef INCLUDE_MATERIAL
	Material material;
	#endif
};

Triangle apply_matrix(inout Triangle triangle, mat4 matrix){
	for(int i = 0; i<3; i++){
		triangle.vertices[i] = apply_matrix(triangle.vertices[i], matrix);
	}
	return triangle;
}

Triangle scale(inout Triangle triangle, vec3 s){
	for(int i = 0; i<3; i++){
		triangle.vertices[i] = scale(triangle.vertices[i], s);
	}
	return triangle;
}

Triangle scale(inout Triangle triangle, float s){
	for(int i = 0; i<3; i++){
		triangle.vertices[i] = scale(triangle.vertices[i], s);
	}
	return triangle;
}

Triangle rotate(inout Triangle triangle, vec4 r){
	for(int i = 0; i<3; i++){
		triangle.vertices[i] = rotate(triangle.vertices[i], r);
	}
	return triangle;
}

Triangle rotate(inout Triangle triangle, vec3 axis, float angle){
	for(int i = 0; i<3; i++){
		triangle.vertices[i] = rotate(triangle.vertices[i], axis, angle);
	}
	return triangle;
}

Triangle translate(inout Triangle triangle, vec3 t){
	for(int i = 0; i<3; i++){
		triangle.vertices[i] = translate(triangle.vertices[i], t);
	}
	return triangle;
}

Triangle transform(inout Triangle triangle, vec3 s, vec4 r, vec3 t){
	for(int i = 0; i<3; i++){
		triangle.vertices[i] = transform(triangle.vertices[i], s, r, t);
	}
	return triangle;
}

vec3 normal(mat3 triangle){
	return normal(
		triangle[1]-triangle[0],
		triangle[2]-triangle[0]
	);
}

vec3 normal(Triangle triangle){
	return normal(triangle.vertices);
}

float lightReceptionFactor(vec3 lightRayDirection, mat3 triangle){
	return lightReceptionFactor(lightRayDirection, normal(triangle));
}

float lightReceptionFactor(vec3 lightRayDirection, Triangle triangle){
	return lightReceptionFactor(lightRayDirection, normal(triangle));
}