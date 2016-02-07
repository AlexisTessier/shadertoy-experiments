#define RAYCAST_MAXIMUM_DEPTH 4

const lowp vec4 backgroundColor = COLOR_BLACK;

vec4 castRay(highp vec3 origin, highp vec3 direction, Triangle triangles[NUMBER_OF_TRIANGLES]){
	vec4 color = backgroundColor;

	float t, u, v;
	Triangle closestTriangle;
	
	float mixFactor = 1.0;
	for(int depth = 0;depth < RAYCAST_MAXIMUM_DEPTH;depth++){
		if(firstHitTriangle(closestTriangle,
			origin,
			direction,
			triangles, 
			t, u, v
		)){
			vec3 triangleNormal = normal(closestTriangle);
			
			color = mix(color, closestTriangle.material.color, mixFactor);

			if(closestTriangle.material.reflection > 0.0){
				mixFactor *= closestTriangle.material.reflection;

				float incidentAngle = acos(dot(-direction, triangleNormal));
				origin += (direction*t);
				rotate(direction, -cross(direction, triangleNormal), 2.0*incidentAngle);
			}
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

	Triangle greenTriangle = Triangle(mat3(
		0.5, 0.5, 0.0,
		0.0, 0.0, 0.0,
		1.0, 0.0, 0.0),
		Material(COLOR_GREEN, 0.8)
	);
	//rotate(greenTriangle, AXIS_Y, radians());


	Triangle orangeTriangle = Triangle(mat3(
		0.5, 0.5, 0.0,
		0.0, 0.0, 0.0,
		1.0, 0.0, 0.0),
		Material(COLOR_ORANGE, 0.0)
	);
	translate(orangeTriangle, vec3(0.5, 0.0, 1.0));

	triangles[0]=greenTriangle;
	triangles[1]=orangeTriangle;

	/*--------------*/
	Camera cam = initCamera(
		/*position*/vec3(-0.13, 0.12, 1.4),
		/*target*/POINT_ZERO,
		/*fov*/80.0,
		/*roll*/0.0,
		/*resolution*/iResolution.xy
	);

	fragColor = trace(fragCoord, cam, triangles);
}