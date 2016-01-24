#define COLOR_BLACK vec4(0.0)
#define COLOR_WHITE vec4(1.0)
#define COLOR_RED vec4(1.0, 0.0, 0.0, 1.0)
#define COLOR_GREEN vec4(0.0, 1.0, 0.0, 1.0)
#define COLOR_BLUE vec4(0.0, 0.0, 1.0, 1.0)

#define AXIS_X vec3(1.0, 0.0, 0.0)
#define AXIS_Y vec3(0.0, 1.0, 0.0)
#define AXIS_Z vec3(0.0, 0.0, 1.0)

#define POINT_ZERO vec3(0.0)

vec4 debug(bool condition){
	return condition ? COLOR_GREEN*0.5 : COLOR_RED*0.5;
}

mat4 scalingMatrix(vec3 s){
	return mat4(
		s.x, 0.0, 0.0, 0.0,
		0.0, s.y, 0.0, 0.0,
		0.0, 0.0, s.z, 0.0,
		0.0, 0.0, 0.0, 1.0
	);
}

mat4 rotationMatrix(vec4 r){
	//r.xyz => rotation axis
	//r.w => rotation angle in degrees
	float angle = radians(r.w);
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

vec3 rotate(inout vec3 vertex, vec4 r){
	return apply_matrix(vertex, rotationMatrix(r));
}

vec3 translate(inout vec3 vertex, vec3 t){
	return apply_matrix(vertex, translationMatrix(t));
}

vec3 scaleAndRotate(inout vec3 vertex, vec3 s, vec4 r){
	vertex = scale(vertex, s);
	vertex = rotate(vertex, r);
	return vertex;
}

vec3 scaleAndTranslate(inout vec3 vertex, vec3 s, vec3 t){
	vertex = scale(vertex, s);
	vertex = translate(vertex, t);
	return vertex;
}

vec3 rotateAndTranslate(inout vec3 vertex, vec4 r, vec3 t){
	vertex = rotate(vertex, r);
	vertex = translate(vertex, t);
	return vertex;
}

vec3 transform(inout vec3 vertex, vec3 s, vec4 r, vec3 t){
	vertex = scale(vertex, s);
	vertex = rotate(vertex, r);
	vertex = translate(vertex, t);
	return vertex;
}

/*-------------------------------*/

struct Camera{
	vec3 position;
	vec3 target;
	vec3 up;
	vec2 fov;
	vec2 resolution;
	float near;
	float far;
};

mat4 viewMatrix(vec3 origin, vec3 target, vec3 up) {
	vec3 d = normalize(target - origin);

	vec3 z = -d;
	vec3 x = normalize(cross(d, up));
	vec3 y = cross(z, x);

	return mat4(
		x.x, x.y, x.z, -origin.x,
		y.x, y.y, y.z, -origin.y,
		z.x, z.y, z.z, -origin.z,
		0.0,0.0,0.0,1.0
	);
}

mat4 projectionMatrix(
	vec2 fov,
	float aspect_ratio,
	float z_near,
	float z_far
) {
	vec2 angleOfView = vec2(
		tan(radians(fov.x/2.0))*z_near,
		tan(radians(fov.y/2.0))*z_near
	);

	float znf = (z_near-z_far);

	float near2 = 2.0*z_near;
	float r = angleOfView.x;
	float l = -r;
	float t = angleOfView.y/aspect_ratio;
	float b = -t;

	return mat4(
		near2/(r-l), 0.0, (r+l)/(r-l), 0.0,
		0.0, near2/(t-b), (t+b)/(t-b), 0.0,
		0.0, 0.0, (z_near+z_far)/(znf), near2*z_far/znf,
		0.0, 0.0, -1.0, 0.0
	);
}

vec3 canonical(inout vec3 vertex){
	float zi = 1.0/vertex.z;
	vertex = scale(vertex, vec3(zi, zi, 1.0));
	return vertex;
}

mat4 viewportMatrix(
	vec2 origin, 
	vec2 resolution,
	float near,
	float far
){
	float halfWidth = resolution.x/2.0, halfHeight = resolution.y/2.0;

	return mat4(
		halfWidth, 0.0, 0.0, (-origin.x*halfWidth)+halfWidth,
		0.0, halfHeight, 0.0, (-origin.y*halfHeight)+halfHeight,
		0.0, 0.0, (far-near)/2.0, (near+far)/2.0,
		0.0, 0.0, 0.0, 1.0
	);
}

mat4 viewportMatrix(Camera cam, mat4 mvp, float near, float far){
	vec4 target = vec4(cam.target, 1.0)*mvp;
	vec3 t = canonical(target.xyz);
	return viewportMatrix(
		/*origin*/t.xy,
		/*resolution*/cam.resolution,
		/*near*/near,
		/*far*/far
	);
}

mat4 viewportMatrix(Camera cam, mat4 mvp){
	return viewportMatrix(cam, mvp, 0.0, 1.0);
}

mat4 mvpMatrix(Camera cam){
	return
		viewMatrix(cam.position, cam.target, cam.up)*
		projectionMatrix(cam.fov, cam.resolution.x/cam.resolution.y, cam.near, cam.far);
}

bool vertex_render(vec2 fragCoord, vec3 vertex){
	if(vertex.z == 0.0){return false;}
	float xmin = floor(vertex.x), ymin = floor(vertex.y);
	float xmax = xmin+1.0, ymax = ymin+1.0;
	return(vertex.z > 0.0 && fragCoord.x >= xmin && fragCoord.x <= xmax && fragCoord.y >= ymin && fragCoord.y <= ymax);
}

#define CubeVerticesCount 8
#define CubeFacesCount 12
void cube_model(inout vec3 vertices[CubeVerticesCount]) {
	vertices[0] = vec3(-1.0, 1.0, 1.0);
	vertices[1] = vec3(-1.0, -1.0, 1.0);
	vertices[2] = vec3(1.0, -1.0, 1.0);
	vertices[3] = vec3(1.0, 1.0, 1.0);
	vertices[4] = vec3(-1.0, 1.0, -1.0);
	vertices[5] = vec3(1.0, 1.0, -1.0);
	vertices[6] = vec3(1.0, -1.0, -1.0);
	vertices[7] = vec3(-1.0, -1.0, -1.0);
}

void cube_apply_matrix(inout vec3 vertices[CubeVerticesCount], mat4 matrix){
	for(int i = 0; i<CubeVerticesCount; i++){
		vertices[i] = apply_matrix(vertices[i], matrix);
	}
}

void cube_transform(inout vec3 vertices[CubeVerticesCount], vec3 s, vec4 r, vec3 t){
	for(int i = 0; i<CubeVerticesCount; i++){
		vertices[i] = transform(vertices[i], s, r, t);;
	}
}

void cube_world(inout vec3 v[CubeVerticesCount], vec3 s, vec4 r, vec3 t){
	cube_model(v);
	cube_transform(v, s, r, t);
}

void cube_canonical(inout vec3 vertices[CubeVerticesCount]){
	for(int i = 0; i<CubeVerticesCount; i++){
		vertices[i] = canonical(vertices[i]);
	}
}

bool cube_render(vec2 fragCoord, vec3 cube[CubeVerticesCount]){
	for(int i=0;i<CubeVerticesCount;i++){
		if(vertex_render(fragCoord, cube[i])){
			return true;
		}
	}
	return false;
}

/*----------------*/

vec3 project(inout vec3 vertex, mat4 mvp, mat4 viewport){
	vertex = apply_matrix(vertex, mvp);
	vertex = canonical(vertex);
	vertex = apply_matrix(vertex, viewport);
	return vertex;
}

void project(inout vec3 cube[CubeVerticesCount], mat4 mvp, mat4 viewport){
	cube_apply_matrix(cube, mvp);
	cube_canonical(cube);
	cube_apply_matrix(cube, viewport);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

	/*----------------*/
	//Create world

	vec3 worldCenter = POINT_ZERO;
	
	vec3 cube[CubeVerticesCount];
	cube_world(cube, 
		/*scale*/vec3(0.2), 
		/*rotate*/vec4(AXIS_Z, -0.0), 
		/*translate*/vec3(0.0, 0.0, 0.25)
	);

	vec3 cube2[CubeVerticesCount];
	cube_world(cube2, 
		/*scale*/vec3(0.2), 
		/*rotate*/vec4(AXIS_Z, iGlobalTime), 
		/*translate*/vec3(0.0, 0.0, 1.0+0.05*iGlobalTime)
	);
	/*----------------*/

	/*----------------*/
	//projection to screen

	Camera cam = Camera(
		/*position*/cube2[3] + vec3(0.01, 0.02, 1.2),
		/*target*/POINT_ZERO,
		/*up*/AXIS_Y,
		/*fov*/vec2(85.0),
		/*resolution*/iResolution.xy,
		/*near*/0.1,
		/*far*/ 100.0
	);

	mat4 mvp = mvpMatrix(cam);
	mat4 viewport = viewportMatrix(cam, mvp);
	
	project(worldCenter, mvp, viewport);
	project(cube, mvp, viewport);
	project(cube2, mvp, viewport);
	/*-------------------*/

	/*----------------*/
	//render frag

	fragColor = COLOR_BLACK;
	
	fragColor = cube_render(fragCoord, cube) ?
		COLOR_GREEN : fragColor;
	fragColor = cube_render(fragCoord, cube2) ?
		COLOR_BLUE : fragColor;
	fragColor = vertex_render(fragCoord, worldCenter) ?
		COLOR_RED : fragColor;
	/*----------------*/
}