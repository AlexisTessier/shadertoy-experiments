//P : control point

const float ustep = 1.0 / 200.0;

#define P_count 4
#define P_count_f 4.0
highp vec2 P_list[P_count];
highp vec2 norm_P_list[P_count];
highp float P_weight_list[P_count];

//bc : binomial coef
highp float bc[P_count];

vec2 P(vec2 p_dot){
   /* vec2 start = P_list[0]*iResolution.xy;
    vec2 end = P_list[2]*iResolution.xy;
    vec2 size = end - start;
    vec2 box = iResolution.xy;*/
    
	return (P_list[0]+p_dot)*iResolution.xy;
}

void init_P_list()
{
	P_list[0] = vec2(.4, .2);
    P_list[1] = vec2(.2, 0.9);
    P_list[2] = vec2(.6, .8);
    //P_list[3] = vec2(.8, .3);
    P_list[3] = iMouse.xy / iResolution.xy;
    
    /*---------------*/
    for(int i = 0; i < P_count; i++){
    	norm_P_list[i] = P_list[i] - P_list[0];
    }
}

void init_bc()
{
    //avec m = 3 => 4 points
    //( m // i )
    //m! / (i! * (m - i)!)
	bc[0] = 0.0;
    bc[1] = 3.0;
    bc[2] = 3.0;
    bc[3] = 1.0;
}

void set_P_weight_list(float u)
{
    for(int i = 0; i < P_count; i++){
        float fi = float(i);
        P_weight_list[i] = bc[i] * pow(u, fi) * pow(1.0 - u, (P_count_f - 1.0)-fi);
    }
}


vec2 bezierUV(float u){
    set_P_weight_list(u);
    
    vec2 uv = vec2(0.0);
    for(int i = 0; i < P_count; i++){
    	uv += norm_P_list[i] * P_weight_list[i];
    }
    
	return uv;
}


bool shouldRenderDot(in vec2 dotCoord, in vec2 fragCoord){
    vec2 rounded = floor(dotCoord);
    vec2 minCoord = rounded - .5;
    vec2 maxCoord = rounded + .5;
    
    if(
        fragCoord.x >= minCoord.x && fragCoord.x < maxCoord.x &&
        fragCoord.y >= minCoord.y && fragCoord.y < maxCoord.y
    ){
    	return true;
    }
    return false;
}

vec4 renderDot(vec2 dotCoord, vec4 dotColor, vec2 fragCoord, vec4 fragColor){
    if(shouldRenderDot(dotCoord, fragCoord)){
    	return dotColor;
    }
    
    return fragColor;
}

bool shouldRenderBDot(in vec2 dotCoord, in vec2 fragCoord){
    vec2 rounded = floor(dotCoord);
    vec2 minCoord = rounded - 5.5;
    vec2 maxCoord = rounded + 5.5;
    
    if(
        fragCoord.x >= minCoord.x && fragCoord.x <= maxCoord.x &&
        fragCoord.y >= minCoord.y && fragCoord.y <= maxCoord.y
    ){
    	return true;
    }
    return false;
}

vec4 renderBDot(vec2 dotCoord, vec4 dotColor, vec2 fragCoord, vec4 fragColor){
    if(shouldRenderBDot(dotCoord, fragCoord)){
    	return dotColor;
    }
    
    return fragColor;
}

/*--------------------*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{  	
    init_P_list();
    init_bc();
    
	fragColor = vec4(.0);
    
    float loopDuration = 3.0;
    float cursor = (iGlobalTime - floor(iGlobalTime/loopDuration)*loopDuration)/loopDuration;
    
    for(float u = 0.0; u <= 1.0; u += ustep){
    	 fragColor = renderDot(
            P(bezierUV(u)), vec4(0.0, 0.5, 0.1, 1.0),
            fragCoord, fragColor
    	);
   }
    
     for(int i = 0; i <= P_count; i++){
    	fragColor = renderDot(
           vec2(P_list[i].x*iResolution.x, P_list[i].y*iResolution.y), vec4(1.0, 0.2, 0.1, 1.0),
            fragCoord, fragColor
        );
    }
    
    fragColor = renderBDot(
            P(bezierUV(cursor)), vec4(0.0, 0.5, 0.1, 1.0),
            fragCoord, fragColor
    	);
}
