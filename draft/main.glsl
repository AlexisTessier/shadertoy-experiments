/*-------------------------------*/

vec3 normal(vec3 a, vec3 b){
	return normalize(cross(normalize(a), normalize(b)));
}

vec3 normal(mat3 triangle){
	return normal(
		triangle[0]-triangle[1],
		triangle[0]-triangle[2]
	);
}

/*---------------------------------*/

//projection utils
struct Camera{
	vec3 position;
	vec3 target;
	vec3 up;
	vec2 fov;
	vec2 resolution;
	float near;
	float far;
};

vec3 cameraDirection(Camera cam){
	return normalize(cam.target - cam.position);
}

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

mat4 viewMatrix(Camera cam) {
	return viewMatrix(
		cam.position,
		cam.target,
		cam.up
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

mat4 projectionMatrix(Camera cam){
	return projectionMatrix(cam.fov, cam.resolution.x/cam.resolution.y, cam.near, cam.far);
}

mat4 mvpMatrix(Camera cam){
	return viewMatrix(cam)*projectionMatrix(cam);
}

mat4 viewportMatrix(
	vec2 origin, 
	vec2 resolution,
	float near,
	float far
){
	float halfWidth = resolution.x/2.0, halfHeight = resolution.y/2.0;

	return mat4(
		halfWidth, 0.0, 0.0, origin.x+halfWidth,
		0.0, halfHeight, 0.0, origin.y+halfHeight,
		0.0, 0.0, (far-near)/2.0, (near+far)/2.0,
		0.0, 0.0, 0.0, 1.0
	);
}

bool render_vertex(vec2 fragCoord, vec3 vertex){
	if(vertex.z < 0.0){return false;}
	vec2 pmin = vec2(floor(vertex.x), floor(vertex.y));
	vec2 pmax = pmin+vec2(1.0);
	return(fragCoord.x >= pmin.x && fragCoord.x <= pmax.x
		&& fragCoord.y >= pmin.y && fragCoord.y <= pmax.y);
}

/*--------------*/

void mainImage( out vec4 fragColor, in vec2 fragCoord){
	vec3 worldCenter = POINT_ZERO;

	Camera cam = Camera(
		/*position*/worldCenter + vec3(0.0, 0.0, 5.0),
		/*target*/worldCenter,
		/*up*/AXIS_Y,
		/*fov*/vec2(85.0),
		/*resolution*/iResolution.xy,
		/*near*/0.1,
		/*far*/ 100.0
	);

	/*----------------*/
	//vertex render
	fragColor = COLOR_BLACK;
	
	fragColor = render_vertex(fragCoord, worldCenter) ?
		COLOR_RED : fragColor;
	/*----------------*/

	/*proto algo*/
	/*
		from near, far and fov => compute the canvas position
		compute fragPosition in the canvas => v
		transpose v in the world coordinate (use the cam as origin)
		compute ray direction (v - cam.position)
		find the closest triangle hitten
		compute the triangle colors
	*/
	/**/
}