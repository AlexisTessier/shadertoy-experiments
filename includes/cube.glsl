#define INCLUDE_CUBE

#define CubeVerticesCount 8

#define MODEL_CUBE(varname) vec3 varname[8];model_cube(varname);

void model_cube(inout vec3 cube[CubeVerticesCount]) {
	cube[0] = vec3(-1.0, 1.0, 1.0);
	cube[1] = vec3(-1.0, -1.0, 1.0);
	cube[2] = vec3(1.0, -1.0, 1.0);
	cube[3] = vec3(1.0, 1.0, 1.0);
	cube[4] = vec3(-1.0, 1.0, -1.0);
	cube[5] = vec3(1.0, 1.0, -1.0);
	cube[6] = vec3(1.0, -1.0, -1.0);
	cube[7] = vec3(-1.0, -1.0, -1.0);
}

void apply_matrix(inout vec3 vertices[CubeVerticesCount], mat4 matrix){
	for(int i = 0; i<CubeVerticesCount; i++){
		vertices[i] = apply_matrix(vertices[i], matrix);
	}
}

void scale(inout vec3 vertices[CubeVerticesCount], vec3 s){
	for(int i = 0; i<CubeVerticesCount; i++){
		vertices[i] = scale(vertices[i], s);
	}
}

void scale(inout vec3 vertices[CubeVerticesCount], float s){
	for(int i = 0; i<CubeVerticesCount; i++){
		vertices[i] = scale(vertices[i], s);
	}
}

void rotate(inout vec3 vertices[CubeVerticesCount], vec4 r){
	for(int i = 0; i<CubeVerticesCount; i++){
		vertices[i] = rotate(vertices[i], r);
	}
}

void rotate(inout vec3 vertices[CubeVerticesCount], vec3 axis, float angle){
	for(int i = 0; i<CubeVerticesCount; i++){
		vertices[i] = rotate(vertices[i], axis, angle);
	}
}

void translate(inout vec3 vertices[CubeVerticesCount], vec3 t){
	for(int i = 0; i<CubeVerticesCount; i++){
		vertices[i] = translate(vertices[i], t);
	}
}

void transform(inout vec3 vertices[CubeVerticesCount], vec3 s, vec4 r, vec3 t){
	for(int i = 0; i<CubeVerticesCount; i++){
		vertices[i] = transform(vertices[i], s, r, t);
	}
}

#ifdef RENDERING_METHOD_RASTERIZATION
bool render_vertex(vec2 fragCoord, vec3 vertices[CubeVerticesCount]){
	for(int i=0;i<CubeVerticesCount;i++){
		if(render_vertex(fragCoord, vertices[i])){
			return true;
		}
	}
	return false;
}

void rasterize(inout vec3 vertices[CubeVerticesCount], Camera cam){
	for(int i = 0; i<CubeVerticesCount; i++){
		vertices[i] = rasterize(vertices[i], cam);
	}
}
#endif