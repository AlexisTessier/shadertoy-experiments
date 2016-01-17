mat4 translationMatrix(vec3 t){
	return mat4(
		1.0, 0.0, 0.0, t.x,
		0.0, 1.0, 0.0, t.y,
		0.0, 0.0, 1.0, t.z,
		0.0, 0.0, 0.0, 1.0
	);
}

mat4 rotationMatrix(vec4 r){
	//rotate.xyz => rotation axis
	//rotate.w => rotation angle in degrees
	vec3 axis = normalize(r.xyz);
	float s = sin(r.w);
	float c = cos(r.w);
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

void apply_matrix(inout vec3 vertex, mat4 matrix){
	vec4 v = vec4(vertex.xyz, 1.0)*matrix;
	vertex = v.xyz;
}

void translate(inout vec3 vertex, vec3 t){
	apply_matrix(vertex, translationMatrix(t));
}

void rotate(inout vec3 vertex, vec4 r){
	apply_matrix(vertex, rotationMatrix(r));
}

void scale(inout vec3 vertex, vec3 s){
	apply_matrix(vertex, scalingMatrix(s));
}

void transform(inout vec3 vertex, vec3 s, vec4 r, vec3 t){
	scale(vertex, s);
	rotate(vertex, r);
	translate(vertex, t);
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
	float d = 1.0/(tan(fov/2.0));
	float znf = (z_near-z_far);
	return mat4(
		d/aspect_ratio, 0.0, 0.0, 0.0,
		0.0, d, 0.0, 0.0,
		0.0, 0.0, (z_near+z_far)/znf, (2.0*z_near*z_far)/znf,
		0.0, 0.0, -1.0, 0.0
	);
}

mat4 viewportMatrix(
	vec2 origin, 
	float width, float height, float near, float far
){
	float halfWidth = width/2.0, halfHeight = height/2.0;

	return mat4(
		halfWidth, 0.0, 0.0, origin.x+halfWidth,
		0.0, halfHeight, 0.0, origin.y+halfHeight,
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

void cube_apply_matrix(inout vec3 v[CubeVerticesCount], mat4 matrix){
	for(int i = 0; i<CubeVerticesCount; i++){
		apply_matrix(v[i], matrix);
	}
}

void cube_transform(inout vec3 v[CubeVerticesCount], vec3 s, vec4 r, vec3 t){
	for(int i = 0; i<CubeVerticesCount; i++){
		transform(v[i], s, r, t);
	}
}

void cube_world(inout vec3 v[CubeVerticesCount], vec3 s, vec4 r, vec3 t){
	cube_model(v);
	cube_transform(v, s, r, t);
}

bool pixel_render(vec2 fragCoord, vec2 pixel){
	float xmin = floor(pixel.x), ymin = floor(pixel.y);
	float xmax = xmin+1.0, ymax = ymin+1.0;
	return(fragCoord.x >= xmin && fragCoord.x <= xmax && fragCoord.y >= ymin && fragCoord.y <= ymax);
}

bool cube_render(vec2 fragCoord, vec3 cube[CubeVerticesCount]){
	for(int i=0;i<CubeVerticesCount;i++){
		if(pixel_render(fragCoord, cube[i].xy)){
			return true;
		}
	}
	return false;
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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 x = vec3(1.0, 0.0, 0.0);
	vec3 y = vec3(0.0, 1.0, 0.0);
	vec3 z = vec3(0.0, 0.0, 1.0);

	//place a point
	vec3 cubeCenter = vec3(0.0);
	translate(cubeCenter, vec3(0.0));
    
    vec3 dot2 = vec3(0.0);
	translate(dot2, vec3(2.0));

	Camera cam = Camera(
		/*position*/cubeCenter + vec3(0.0, 0.0, -180.0),
		/*target*/vec3(0.0),
		/*up*/y,
		/*fov*/80.0,
		/*ratio*/iResolution.x / iResolution.y,
		/*near*/0.1,
		/*far*/ 600.0
	);

	mat4 view = viewMatrix(
		/*origin*/cam.position,
		/*target*/cam.target,
		/*up*/cam.up
	);
	
    mat4 projection = projectionMatrix(
        /*fov*/cam.fov,
        /*aspect_ratio*/cam.ratio,
        /*near*/cam.near,
        /*far*/cam.far
    );

    mat4 viewport = viewportMatrix(
    	/*origin*/vec2(0.0),
    	/*width*/iResolution.x,
    	/*height*/iResolution.y,
    	/*near*/0.0,
    	/*far*/1.0
    );
    
	apply_matrix(cubeCenter, view);
    apply_matrix(cubeCenter, projection);
    apply_matrix(cubeCenter, viewport);
    
    apply_matrix(dot2, view);
    apply_matrix(dot2, projection);
    apply_matrix(dot2, viewport);

	fragColor = pixel_render(fragCoord, cubeCenter.xy) ?
        vec4(0.0, 1.0, 0.0, 1.0) : vec4(0.0);
   	fragColor = pixel_render(fragCoord, dot2.xy) ?
        vec4(1.0, 0.0, 0.0, 1.0) : fragColor;
}
