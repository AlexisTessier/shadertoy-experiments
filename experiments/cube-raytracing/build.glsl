
/*------------*/
#define COLOR_BLACK vec4(0.0)
#define COLOR_WHITE vec4(1.0)
#define COLOR_RED vec4(1.0, 0.0, 0.0, 1.0)
#define COLOR_GREEN vec4(0.0, 1.0, 0.0, 1.0)
#define COLOR_BLUE vec4(0.0, 0.0, 1.0, 1.0)
/*------------*/


/*------------*/
#define AXIS_X vec3(1.0, 0.0, 0.0)
#define AXIS_Y vec3(0.0, 1.0, 0.0)
#define AXIS_Z vec3(0.0, 0.0, 1.0)

#define POINT_ZERO vec3(0.0)
/*------------*/


/*------------*/
vec4 debug(bool condition){
	return condition ? vec4(0.0, 0.5, 0.0, 1.0) : vec4(0.5, 0.0, 0.0, 1.0);
}
/*------------*/


/*------------*/
mat4 identityMatrix(){
	return mat4(
		1.0, 0.0, 0.0, 0.0,
		0.0, 1.0, 0.0, 0.0,
		0.0, 0.0, 1.0, 0.0,
		0.0, 0.0, 0.0, 1.0
	);
}

mat4 scalingMatrix(vec3 s){
	return mat4(
		s.x, 0.0, 0.0, 0.0,
		0.0, s.y, 0.0, 0.0,
		0.0, 0.0, s.z, 0.0,
		0.0, 0.0, 0.0, 1.0
	);
}

mat4 scalingMatrix(float s){
	return scalingMatrix(vec3(s));
}

mat4 rotationMatrix(vec4 r){
	float angle = r.w;
	vec3 axis = normalize(r.xyz);
	float s = sin(angle);
	float c = cos(angle);
	float oc = 1.0 - c;
	
	return mat4(
		oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s, 0.0,
		oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0.0,
		oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c, 0.0,
		0.0, 0.0, 0.0, 1.0
	);
}

mat4 rotationMatrix(vec3 axis, float angle){
	return rotationMatrix(vec4(axis, angle));
}

mat4 translationMatrix(vec3 t){
	return mat4(
		1.0, 0.0, 0.0, t.x,
		0.0, 1.0, 0.0, t.y,
		0.0, 0.0, 1.0, t.z,
		0.0, 0.0, 0.0, 1.0
	);
}

vec3 apply_matrix(inout vec3 vertex, mat4 matrix){
	vec4 v = vec4(vertex.xyz, 1.0)*matrix;
	vertex = v.xyz;
	return vertex;
}

vec3 scale(inout vec3 vertex, vec3 s){
	return apply_matrix(vertex, scalingMatrix(s));
}

vec3 scale(inout vec3 vertex, float s){
	return apply_matrix(vertex, scalingMatrix(s));
}

vec3 rotate(inout vec3 vertex, vec4 r){
	return apply_matrix(vertex, rotationMatrix(r));
}

vec3 rotate(inout vec3 vertex, vec3 axis, float angle){
	return apply_matrix(vertex, rotationMatrix(axis, angle));
}

vec3 translate(inout vec3 vertex, vec3 t){
	return apply_matrix(vertex, translationMatrix(t));
}

vec3 transform(inout vec3 vertex, vec3 s, vec4 r, vec3 t){
	vertex = scale(vertex, s);
	vertex = rotate(vertex, r);
	vertex = translate(vertex, t);
	return vertex;
}

/*------------*/


/*------------*/
#define RENDERING_METHOD_RAYTRACING

struct Camera{
	vec3 position;
	vec3 target;
	vec2 fov;
	float roll;
	vec2 resolution;
	vec3 direction;
	mat4 canvas;
};

mat4 viewMatrix(vec3 origin, vec3 target, float roll) {
	vec3 up = vec3(sin(roll), cos(roll), 0.0);

	vec3 z = normalize(target - origin);
	vec3 x = normalize(cross(z, up));
	vec3 y = normalize(cross(x, z));

	return mat4(
		x.x, y.x, z.x, origin.x,
		x.y, y.y, z.y, origin.y,
		x.z, y.z, z.z, origin.z,
		0.0,0.0,0.0,1.0
	);
}

Camera initCamera(
	vec3 position,
	vec3 target,
	vec2 fov,
	float roll,
	vec2 resolution
){
	float near = 1.0;
	vec3 direction = normalize(target - position);
	float aspect_ratio = resolution.x/resolution.y;

	fov.x = clamp(fov.x, 0.1, 179.5);
	fov.y = clamp(fov.y, 0.1, 179.5);

	vec2 nearClip = 2.0*vec2(
		tan(radians(fov.x/2.0))*near,
		(tan(radians(fov.y/2.0))*near)/aspect_ratio
	);
	
	mat4 canvasMatrix = translationMatrix(vec3(-(resolution.x*0.5)+0.5, -(resolution.y*0.5)+0.5, near))
		*scalingMatrix(vec3(nearClip.x/resolution.x, nearClip.y/resolution.y, 1.0))
		*viewMatrix(position, target, roll);

	return Camera(position, target, fov, roll, resolution, direction, canvasMatrix);
}

Camera initCamera(
	vec3 position,
	vec3 target,
	float fov,
	float roll,
	vec2 resolution
){
	return initCamera(position, target, vec2(fov), roll, resolution);
}

vec3 pixelToWorld(vec2 fragCoord, mat4 canvas){
	vec3 v = vec3(fragCoord, 0.0);
	return apply_matrix(v, canvas);
}

bool rayTriangleIntersect( 
    vec3 orig, vec3 dir, 
    mat3 triangle, 
    inout float t, inout float u, inout float v) 
{
    vec3 v0 = triangle[0];
    vec3 v0v1 = triangle[1] - v0;
    vec3 v0v2 = triangle[2] - v0;

    vec3 pvec = cross(dir, v0v2);
    float det = dot(v0v1, pvec);

    if (abs(det) < kEpsilon) return false;
    float invDet = 1.0 / det; 
 
    vec3 tvec = orig - v0; 
    u = dot(tvec, pvec) * invDet; 
    if (u < 0.0 || u > 1.0) return false; 
 
    vec3 qvec = cross(tvec, v0v1); 
    v = dot(dir, qvec) * invDet; 
    if (v < 0.0 || u + v > 1.0) return false;
 
    t = dot(v0v2, qvec) * invDet; 
 
    return true;
}
/*------------*/


/*------------*/
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
/*------------*/


/*------------*/
#define NUMBER_OF_TRIANGLES 250

struct Triangle{
	mat3 vertices;
	vec4 color;
};

vec4 trace(vec2 fragCoord, Camera cam, Triangle triangles[NUMBER_OF_TRIANGLES], int triangleCount){
	vec4 color = COLOR_BLACK;
	float infinity = 1.0 / 0.0;
	
	float t = infinity, prevT = infinity, u = 0.0, v=0.0;
	vec3 ray = normalize(pixelToWorld(fragCoord, cam.canvas) - cam.position);

	Triangle closestTriangle = triangles[0];
	bool intersect = false, intersectEnsure = false;
	for(int i = 0;i<triangleCount;i++){
		intersect = rayTriangleIntersect(
			cam.position, ray, triangles[i].vertices, t, u, v
		);
		if(intersect){
			intersectEnsure = true;
			if(t <= prevT){
				prevT = t;
				closestTriangle = triangles[i];
			}
		}
	}

	if(intersectEnsure){
		color = closestTriangle.color;
	}

	return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord){
	Triangle triangles[NUMBER_OF_TRIANGLES];
	int triangleCount = 0;

	Triangle greenTriangle = Triangle(mat3(
		0.5, 0.5, 0.5,
		0.0, 0.0, 0.0,
		1.0, 0.0, 1.0), COLOR_GREEN);

	Triangle redTriangle = Triangle(mat3(
		1.5, 0.5, 0.5,
		0.0, 1.0, 0.0,
		0.8, 0.5, 1.0), COLOR_RED);

	triangles[triangleCount]=greenTriangle;
	triangleCount++;
	triangles[triangleCount]=redTriangle;
	triangleCount++;

	/*--------------*/
	Camera cam = initCamera(
		/*position*/greenTriangle.vertices[0]+vec3(0.0, 0.0, 4.2),
		/*target*/greenTriangle.vertices[0],
		/*fov*/80.0,
		/*roll*/0.0,
		/*resolution*/iResolution.xy
	);

	fragColor = trace(fragCoord, cam, triangles, triangleCount);

	/*
		from near, far and fov => compute the canvas position
		compute fragPosition in the canvas => v
		transpose v in the world coordinate (use the cam as origin)
		compute ray direction (v - cam.position)

		find the closest triangle hitten
		compute the triangle colors
	*/
}
/*------------*/
