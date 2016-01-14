float easeInOutQuart(float t){
    return t<0.50 ? 8.00*t*t*t*t : 1.00-8.00*(--t)*t*t*t;
}

vec4 lightSpot(vec2 fragCoord, vec4 light, float radius, vec4 color){
    //light.xy => center position
    //light.z => intensity
    //light.w => power
    
    float p = light.w/radius;
    float d = distance(fragCoord, vec2(light.xy));
    
    float ddiv = d/radius;
    float r = clamp(ddiv, 0.0, 1.0);
    float i = 1.0 - r;
    float idiv = light.z/(10.0);
    float iexp = (i/r*p);
    
    float ambiant = d < radius ? idiv : idiv/(pow(ddiv, 3.0));
    
    return (color*(iexp))+(color*ambiant);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 position = vec2(floor(fragCoord.x), floor(fragCoord.y));
    vec2 uv = fragCoord.xy / iResolution.xy;
    float loopDuration = 25.0, halfDuration = (loopDuration/2.0);
    float time = mod(iGlobalTime, loopDuration);
    float cursor = 2.0*((time < halfDuration ? time : (loopDuration-time))/loopDuration);
    float var = easeInOutQuart(cursor);
    
    vec4 color = lightSpot(
        fragCoord,
        /*light*/ vec4(iResolution.xy/4.0, 1.4*var, 12.0*var),
        /*radius*/600.0,
        /*color*/ vec4(1.0, 0.2, 0.0, 1.0)
    );
    
    vec4 color2 = lightSpot(
        fragCoord,
        /*light*/ vec4(iResolution.xy/2.0, 2.4*var, 15.0*var),
        /*radius*/750.0,
        /*color*/ vec4(0.1, 0.4, 1.0, 1.0)
    );
    
    fragColor = color+color2;
}