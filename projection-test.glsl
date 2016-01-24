vec4 debug(bool condition){
	return condition ? vec4(0.0,0.5,0.0,1.0) : vec4(0.5, 0.0,0.0,1.0);
}

mat4 translationMatrix(vec3 t){
	return mat4(
		1.0, 0.0, 0.0, t.x,
		0.0, 1.0, 0.0, t.y,
		0.0, 0.0, 1.0, t.z,
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

mat4 scalingMatrix(vec3 s){
	return mat4(
		s.x, 0.0, 0.0, 0.0,
		0.0, s.y, 0.0, 0.0,
		0.0, 0.0, s.z, 0.0,
		0.0, 0.0, 0.0, 1.0
	);
}

vec3 apply_matrix(inout vec3 vertex, mat4 matrix){
	vec4 v = vec4(vertex.xyz, 1.0)*matrix;
	vertex = v.xyz;
    return vertex;
}

vec3 translate(inout vec3 vertex, vec3 t){
	return apply_matrix(vertex, translationMatrix(t));
}

vec3 rotate(inout vec3 vertex, vec4 r){
	return apply_matrix(vertex, rotationMatrix(r));
}

vec3 scale(inout vec3 vertex, vec3 s){
	return apply_matrix(vertex, scalingMatrix(s));
}

vec3 transform(inout vec3 vertex, vec3 s, vec4 r, vec3 t){
	vertex = scale(vertex, s);
	vertex = rotate(vertex, r);
	vertex = translate(vertex, t);
    return vertex;
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

mat4 projectionMatrix(
    float fov,
    float aspect_ratio,
    float z_near,
    float z_far
) {
	float d = 1.0/(tan(radians(fov)/2.0));
	float znf = (z_near-z_far);
	
	/*return mat4(
		d/aspect_ratio, 0.0, 0.0, 0.0,
		0.0, d, 0.0, 0.0,
		0.0, 0.0, (z_near+z_far)/znf, (2.0*z_near*z_far)/znf,
		0.0, 0.0, -1.0, 0.0
	);*/
	float near2 = 2.0*z_near;
	float l = -0.2;
	float r = -l;
	float t = r/aspect_ratio;
	float b = -t;

	return mat4(
		near2/(r-l), 0.0, (r+l)/(r-l), 0.0,
		0.0, near2/(t-b), (t+b)/(t-b), 0.0,
		0.0, 0.0, (z_near+z_far)/(znf), near2*z_far/znf,
		0.0, 0.0, -1.0, 0.0
	);
}

struct Camera{
	vec3 position;
	vec3 target;
	vec3 up;
	float fov;
	float ratio;
	float near;
	float far;
};

mat4 viewportMatrix(
	vec2 origin, 
	float width, float height, float near, float far
){
	float halfWidth = width/2.0, halfHeight = height/2.0;

	return mat4(
		halfWidth, 0.0, 0.0, (-origin.x*halfWidth)+halfWidth,
		0.0, halfHeight, 0.0, (-origin.y*halfHeight)+halfHeight,
		0.0, 0.0, (far-near)/2.0, (near+far)/2.0,
		0.0, 0.0, 0.0, 1.0
	);
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

bool pixel_render(vec2 fragCoord, vec3 pixel){
	if(pixel.z == 0.0){return false;}
	float xmin = floor(pixel.x), ymin = floor(pixel.y);
	float xmax = xmin+1.0, ymax = ymin+1.0;
	return(fragCoord.x >= xmin && fragCoord.x <= xmax && fragCoord.y >= ymin && fragCoord.y <= ymax);
}

bool cube_render(vec2 fragCoord, vec3 cube[CubeVerticesCount]){
	for(int i=0;i<CubeVerticesCount;i++){
		if(pixel_render(fragCoord, cube[i])){
			return true;
		}
	}
	return false;
}

vec3 canonical(inout vec3 vertex){
    float zi = 1.0/vertex.z;
	vertex = zi <= 0.0 ? vec3(iResolution.xy+2.0, vertex.z) : scale(vertex, vec3(zi, zi, 1.0));
	return vertex;
}

void cube_canonical(inout vec3 vertices[CubeVerticesCount]){
	for(int i = 0; i<CubeVerticesCount; i++){
        vertices[i] = canonical(vertices[i]);
	}
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 x = vec3(1.0, 0.0, 0.0);
	vec3 y = vec3(0.0, 1.0, 0.0);
	vec3 z = vec3(0.0, 0.0, 1.0);

	//place a point
	vec3 center = vec3(0.0, 0.0, 0.0);
	//translate(cubeCenter, vec3(0.0));
    
	vec3 cube[CubeVerticesCount];
	cube_world(cube, vec3(0.2), vec4(z, -0.0), vec3(0.0, 0.0, 0.25));
    vec3 cube2[CubeVerticesCount];
	cube_world(cube2, vec3(0.2), vec4(z, 0.0), vec3(0.0, 0.0, 1.0));
    
    vec3 camTarget = cube[5];

	Camera cam = Camera(
		/*position*/cube2[3] + vec3(0.01, 0.02, 0.5),
		/*target*/camTarget,
		/*up*/y,
		/*fov*/80.0,
		/*ratio*/iResolution.x / iResolution.y,
		/*near*/0.1,
		/*far*/ 100.0
	);

	mat4 view = viewMatrix(
		/*origin*/cam.position,
		/*target*/cam.target,
		/*up*/cam.up
	);
    
	apply_matrix(center, view);
    cube_apply_matrix(cube, view);
    cube_apply_matrix(cube2, view);
    apply_matrix(camTarget, view);
    
    mat4 projection = projectionMatrix(
        /*fov*/cam.fov,
        /*aspect_ratio*/cam.ratio,
        /*near*/cam.near,
        /*far*/cam.far
    );
    
    apply_matrix(center, projection);
    cube_apply_matrix(cube, projection);
    cube_apply_matrix(cube2, projection);
    apply_matrix(camTarget, projection);
    
    canonical(center);
    cube_canonical(cube);
    cube_canonical(cube2);
    canonical(camTarget);

    mat4 viewport = viewportMatrix(
    	/*origin*/camTarget.xy,
    	/*width*/iResolution.x,
    	/*height*/iResolution.y,
    	/*near*/0.0,
    	/*far*/1.0
    );
    
    apply_matrix(center, viewport);
    cube_apply_matrix(cube, viewport);
    cube_apply_matrix(cube2, viewport);

    fragColor = vec4(0.0);
    
   	fragColor = cube_render(fragCoord, cube) ?
        vec4(0.0, 1.0, 0.0, 1.0) : fragColor;
    fragColor = cube_render(fragCoord, cube2) ?
        vec4(0.0, 0.0, 1.0, 1.0) : fragColor;
    /*fragColor = pixel_render(fragCoord, cube[5]) ?
        vec4(1.0, 0.0, 0.0, 1.0) : fragColor;
    fragColor = pixel_render(fragCoord, cube2[3]) ?
        vec4(1.0, 1.0, 0.0, 1.0) : fragColor;*/
}