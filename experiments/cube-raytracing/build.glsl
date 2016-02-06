
/*------------*/
#define RENDERING_METHOD_RAYTRACING
#define NUMBER_OF_TRIANGLES 2
#define MATERIAL_TEST
/*------------*/


/*------------*/
#define INCLUDE_GLOBAL

#define EPSILON 0.00001
#define PI 3.141592653589793
#define INFINITY (1.0 / 0.0)
/*------------*/


/*------------*/
#define INCLUDE_COLOR

#define COLOR_BLACK vec4(0.0)
#define COLOR_WHITE vec4(1.0)
#define COLOR_RED vec4(1.0, 0.0, 0.0, 1.0)
#define COLOR_GREEN vec4(0.0, 1.0, 0.0, 1.0)
#define COLOR_BLUE vec4(0.0, 0.0, 1.0, 1.0)
#define COLOR_YELLOW vec4(1.0, 1.0, 0.0, 1.0)
#define COLOR_MANGENTA vec4(1.0, 0.0, 1.0, 1.0)
#define COLOR_CYAN vec4(0.0, 1.0, 1.0, 1.0)
#define COLOR_ORANGE vec4(1.0, 0.5, 0.0, 1.0)
#define COLOR_PURPLE vec4(0.5, 0.0, 1.0, 1.0)
#define COLOR_SPRING_GREEN vec4(0.0, 1.0, 0.5, 1.0)
/*------------*/


/*------------*/
#define INCLUDE_COORDINATE

#define AXIS_X vec3(1.0, 0.0, 0.0)
#define AXIS_Y vec3(0.0, 1.0, 0.0)
#define AXIS_Z vec3(0.0, 0.0, 1.0)

#define POINT_ZERO vec3(0.0)
/*------------*/


/*------------*/
#define INCLUDE_DEBUG

vec4 debug(bool condition){
	return condition ? vec4(0.0, 0.5, 0.0, 1.0) : vec4(0.5, 0.0, 0.0, 1.0);
}
/*------------*/


/*------------*/
#define INCLUDE_CGU_COMMON_COMPUTATIONS

vec3 normal(vec3 a, vec3 b){
	return cross(normalize(a), normalize(b));
}

float lightReceptionFactor(vec3 lightRayDirection, vec3 surfaceNormal){
	return abs(dot(lightRayDirection, surfaceNormal));
}
/*------------*/


/*------------*/
#define INCLUDE_TRANSFORMATION_MATRIX

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
#define INCLUDE_MATERIAL

struct Material{
	vec4 color;

#ifdef MATERIAL_TEST
	float reflection;
#endif
};
/*------------*/


/*------------*/
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
/*------------*/


/*------------*/
#define INCLUDE_RAYTRACING

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
		x, origin.x,
		y, origin.y,
		z, origin.z,
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
    vec3 orig, vec3 dir, mat3 triangle, 
    inout float t, inout float u, inout float v
){
    vec3 v0 = triangle[0];
    vec3 v0v1 = triangle[1] - v0;
    vec3 v0v2 = triangle[2] - v0;

    vec3 pvec = cross(dir, v0v2);
    float det = dot(v0v1, pvec);

    if (abs(det) < EPSILON) return false;
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

#ifdef INCLUDE_TRIANGLE
bool firstHitTriangle(inout Triangle _firstHitTriangle,
	vec3 position, vec3 direction, Triangle triangles[NUMBER_OF_TRIANGLES],
	inout float t, inout float u, inout float v 
){
	bool intersect = false, intersectEnsure = false;
	float prevT = INFINITY;
	t = prevT; u = 0.0; v=0.0;

	for(int i = 0;i<NUMBER_OF_TRIANGLES;i++){
		intersect = rayTriangleIntersect(
			position, direction, triangles[i].vertices, t, u, v
		);
		if(intersect){
			intersectEnsure = true;
			if(t <= prevT){
				prevT = t;
				_firstHitTriangle = triangles[i];
			}
		}
	}

	return intersectEnsure;
}

bool firstHitTriangle(inout Triangle _firstHitTriangle,
	vec3 position, vec3 direction, Triangle triangles[NUMBER_OF_TRIANGLES]
){
	float t, u, v;
	return firstHitTriangle(_firstHitTriangle, position, direction, triangles, t, u, v);
}
#endif
/*------------*/


/*------------*/
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
/*------------*/


/*------------*/
#define RAYCAST_MAXIMUM_DEPTH 4

const lowp vec4 backgroundColor = COLOR_BLACK;

vec4 castRay(vec3 origin, vec3 direction, Triangle triangles[NUMBER_OF_TRIANGLES]){
	vec4 color = backgroundColor;

	float t, u, v;
	Triangle closestTriangle;
	bool intersect = true;
	

	float depthReflexion = 1.0;
	for(int depth = 0;depth < RAYCAST_MAXIMUM_DEPTH;depth++){
		intersect = firstHitTriangle(closestTriangle,
			origin,
			direction,
			triangles, 
			t, u, v
		);

		if(intersect){
			vec3 triangleNormal = normal(closestTriangle);
			float reflection = dot(direction, triangleNormal);
			color += (closestTriangle.material.color*abs(reflection)*depthReflexion);

			depthReflexion *= closestTriangle.material.reflection;

			origin = direction*t;
			vec3 ax = cross(direction, triangleNormal);
			rotate(direction, ax, radians(180.0-2.0*degrees(reflection)));
		}else{
			break;
		}
	}

	return color;
}

vec4 trace(vec2 fragCoord, Camera cam, Triangle triangles[NUMBER_OF_TRIANGLES]){
	return castRay(
		cam.position, 
		normalize(pixelToWorld(fragCoord, cam.canvas) - cam.position),
		triangles
	);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
	Triangle triangles[NUMBER_OF_TRIANGLES];

	float rot = mod(25.0*iGlobalTime, 360.0);

	Triangle greenTriangle = Triangle(mat3(
		0.5, 0.5, 0.0,
		0.0, 0.0, 0.0,
		1.0, 0.0, 0.0),
		Material(COLOR_ORANGE, 0.5)
	);
	rotate(greenTriangle, AXIS_Y, rot);


	Triangle redTriangle = Triangle(mat3(
		1.5, 0.5, 0.0,
		0.0, 1.0, 0.0,
		0.8, 0.5, 0.0),
		Material(COLOR_PURPLE, 0.8)
	);

	triangles[0]=greenTriangle;
	triangles[1]=redTriangle;

	/*--------------*/
	Camera cam = initCamera(
		/*position*/greenTriangle.vertices[0]+vec3(0.0, 0.0, 4.2),
		/*target*/greenTriangle.vertices[0],
		/*fov*/80.0,
		/*roll*/0.0,
		/*resolution*/iResolution.xy
	);

	fragColor = trace(fragCoord, cam, triangles);
}
/*------------*/
