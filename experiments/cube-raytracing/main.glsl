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