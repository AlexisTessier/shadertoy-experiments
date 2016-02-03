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