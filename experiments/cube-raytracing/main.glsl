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