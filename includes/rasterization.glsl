#define INCLUDE_RASTERIZATION

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