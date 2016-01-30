
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
#define RENDERING_METHOD_RASTERIZATION

struct Camera{
	vec3 position;
	vec3 target;
	vec3 up;
	vec2 fov;
	vec2 resolution;
	float aspectRatio;
	float near;
	float far;
	vec4 nearClip;
	vec4 farClip;
	mat4 mvp;
	mat4 viewport;
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
	vec4 near_clip,
	float z_near,
	float z_far
) {
	float znf = (z_near-z_far), near2 = 2.0*z_near,
	t = near_clip.x, r = near_clip.y, b = near_clip.z, l = near_clip.w;
	
	return mat4(
		near2/(r-l), 0.0, (r+l)/(r-l), 0.0,
		0.0, near2/(t-b), (t+b)/(t-b), 0.0,
		0.0, 0.0, (z_near+z_far)/(znf), near2*z_far/znf,
		0.0, 0.0, -1.0, 0.0
	);
}

vec3 perspective_division(
	inout vec3 vertex,
	float near, float far,
	vec4 near_clip, vec4 far_clip, vec2 resolution
){
	float w = vertex.z/(far-near);
	
	float f = far_clip.x, n = near_clip.x, h = resolution.y;
	float viewportFactor = (2.0*f*(f/n))/h;

	vec2 clipRatio = vec2(1.0) / (viewportFactor*(w*(near_clip.yx/far_clip.yx)));
	vertex = scale(vertex, vec3(clipRatio, 1.0));

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

vec3 rasterize(inout vec3 vertex, Camera cam){
	vertex = apply_matrix(vertex, cam.mvp);
	vertex = perspective_division(vertex,
		cam.near, cam.far, cam.nearClip, cam.farClip, cam.resolution
	);
	vertex = apply_matrix(vertex, cam.viewport);
	return vertex;
}

Camera initCamera(
	vec3 position,
	vec3 target,
	vec3 up,
	vec2 fov,
	vec2 resolution,
	float near,
	float far
){
	float aspect_ratio = resolution.x/resolution.y;

	vec2 v2_nearClip = vec2(
		tan(radians(fov.x/2.0))*near,
		tan(radians(fov.y/2.0))*near
	);

	vec2 v2_farClip = vec2(
		tan(radians(fov.x/2.0))*far,
		tan(radians(fov.y/2.0))*far
	);

	float nr = v2_nearClip.x;
	float nl = -nr;
	float nt = v2_nearClip.y/aspect_ratio;
	float nb = -nt;

	float fr = v2_farClip.x;
	float fl = -fr;
	float ft = v2_farClip.y/aspect_ratio;
	float fb = -ft;

	vec4 nearClip = vec4(nt, nr, nb, nl);
	vec4 farClip = vec4(ft, fr, fb, fl);

	mat4 mvp = viewMatrix(position, target, up)*projectionMatrix(nearClip, near, far);
	
	vec4 viewPortTarget = vec4(target, 1.0)*mvp;
	vec3 t = perspective_division(viewPortTarget.xyz, near, far, nearClip, farClip, resolution);
	mat4 viewport = viewportMatrix(t.xy, resolution, 0.0, 1.0);

	return Camera(
		position,
		target,
		up,
		fov,
		resolution,
		aspect_ratio,
		near,
		far,
		nearClip,
		farClip,
		mvp,
		viewport
	);
}

Camera initCamera(
	vec3 position,
	vec3 target,
	vec3 up,
	float fov,
	vec2 resolution,
	float near,
	float far
){
	return initCamera(position, target, up, vec2(fov), resolution, near, far);
}

bool render_vertex(vec2 fragCoord, vec3 vertex){
	if(vertex.z <= 0.0){return false;}
	float xmin = floor(vertex.x), ymin = floor(vertex.y);
	float xmax = xmin+1.0, ymax = ymin+1.0;
	return(fragCoord.x >= xmin && fragCoord.x <= xmax && fragCoord.y >= ymin && fragCoord.y <= ymax);
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

bool render_vertex(vec2 fragCoord, vec3 vertices[CubeVerticesCount]){
	for(int i=0;i<CubeVerticesCount;i++){
		if(render_vertex(fragCoord, vertices[i])){
			return true;
		}
	}
	return false;
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
void rasterize(inout vec3 vertices[CubeVerticesCount], Camera cam){
	for(int i = 0; i<CubeVerticesCount; i++){
		vertices[i] = rasterize(vertices[i], cam);
	}
}
#endif
/*------------*/


/*------------*/
void mainImage( out vec4 fragColor, in vec2 fragCoord){
	vec3 worldCenter = POINT_ZERO;
	vec3 whiteCubeCenter = vec3(0.0, 0.0, 60.0);

	MODEL_CUBE(greenCube)
	scale(greenCube, 0.2);

	MODEL_CUBE(whiteCube)
	scale(whiteCube, 0.3);
    rotate(whiteCube, AXIS_Y+AXIS_Z, radians(62.0+0.05*iGlobalTime));
	translate(whiteCube, whiteCubeCenter);

	/*--------------*/

	Camera cam = initCamera(
		/*position*/ whiteCubeCenter+vec3(4.18, 2.0, 680.0),
		/*target*/ whiteCubeCenter,
		/*up*/ AXIS_Y,
		/*fov*/ 85.0,
		/*resolution*/ iResolution.xy,
		/*near*/ 0.1,
		/*far*/ 100.0
	);

	rasterize(worldCenter, cam);
	rasterize(whiteCubeCenter, cam);
	rasterize(greenCube, cam);
	rasterize(whiteCube, cam);

	/*--------------*/
	fragColor = COLOR_BLACK;
	
	fragColor = render_vertex(fragCoord, worldCenter) ?
		COLOR_RED : fragColor;
    fragColor = render_vertex(fragCoord, whiteCube) ?
    	COLOR_WHITE : fragColor;
    fragColor = render_vertex(fragCoord, whiteCubeCenter) ?
    	COLOR_BLUE : fragColor;	
    fragColor = render_vertex(fragCoord, greenCube) ?
		COLOR_GREEN : fragColor;
}
/*------------*/
