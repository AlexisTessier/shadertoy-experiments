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