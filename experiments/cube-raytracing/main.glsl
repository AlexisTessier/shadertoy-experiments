const lowp vec4 backgroundColor = COLOR_BLACK;

vec4 trace(vec2 fragCoord, Camera cam, Triangle triangles[NUMBER_OF_TRIANGLES]){
	vec4 color = backgroundColor;

	Triangle closestTriangle;
	bool intersect = firstHitTriangle(closestTriangle,
		cam.position,
		normalize(pixelToWorld(fragCoord, cam.canvas) - cam.position),
		triangles
	);

	if(intersect){
		color = closestTriangle.material.color;
	}

	return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
	Triangle triangles[NUMBER_OF_TRIANGLES];

	Triangle greenTriangle = Triangle(mat3(
		0.5, 0.5, 0.5,
		0.0, 0.0, 0.0,
		1.0, 0.0, 1.0),
		Material(COLOR_ORANGE)
	);

	Triangle redTriangle = Triangle(mat3(
		1.5, 0.5, 0.5,
		0.0, 1.0, 0.0,
		0.8, 0.5, 1.0),
		Material(COLOR_PURPLE)
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