float easeInOutQuart(float t){
    return t<0.50 ? 8.00*t*t*t*t : 1.00-8.00*(--t)*t*t*t;
}

vec4 pointLight(vec2 fragCoord, vec4 light, float radius, vec4 color){
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
    
    float ambiant = d < radius ? idiv : idiv/(pow(ddiv, 2.0));
    
    return (color*(iexp))+(color*ambiant);
}

bool circle(vec2 fragCoord, vec3 c){
    //c.xy => center position
    //c.z => radius
    
    return (distance(fragCoord, vec2(c.xy)) <= c.z);
}

bool shadow_point_circle(vec2 fragCoord, vec2 light, vec3 c){
    vec2 ray = light - fragCoord;
    vec2 cToL = vec2(c.xy) - light;
                          
    float a = dot(ray, ray);
    float b = dot(2.0*cToL, ray) ;
    float cc = dot(cToL, cToL) - (c.z*c.z) ;
    
    float discriminant = b*b-4.0*a*cc;
    if( discriminant >= 0.0)
    {
        discriminant = sqrt( discriminant );
        float t1 = (-b - discriminant)/(2.0*a);
        float t2 = (-b + discriminant)/(2.0*a);
        
        if((t1 >= 0.0 && t1 <= 1.0) || ( t2 >= 0.0 && t2 <= 1.0 ))
        {
           return true;
        }
    }
    return circle(fragCoord, c);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 position = vec2(floor(fragCoord.x), floor(fragCoord.y));
    vec2 uv = fragCoord.xy / iResolution.xy;
    float loopDuration = 12.0, halfDuration = (loopDuration/2.0);
    float time = mod(iGlobalTime, loopDuration);
    float cursor = 2.0*((time < halfDuration ? time : (loopDuration-time))/loopDuration);
    float var = 0.6+easeInOutQuart(cursor)/2.0;
    
    fragColor = vec4(0.0);
    
    vec2 cl1 = (vec2(0.0)+iGlobalTime*30.0)-vec2(1.0, iGlobalTime*18.0)+iGlobalTime*5.0;
    vec2 cl2 = vec2(iResolution.xy) - ((vec2(0.0)+iGlobalTime*30.0)-vec2(1.0, iGlobalTime*18.0)+iGlobalTime*5.0);
    vec3 c = vec3(iResolution.xy/2.0+30.0, 20.0);
    
    fragColor = circle(fragCoord,
        /*center, radius*/c
    ) ? vec4(0.05) : fragColor;
    
    fragColor += shadow_point_circle(fragCoord,
        cl1, c
    ) ? vec4(0.0) : pointLight(
        fragCoord,
        /*light*/ vec4(cl1.xy, 2.0*var, 4.0*var),
        /*radius*/30.0,
        /*color*/ vec4(0.0, 0.7, 0.9, 1.0)
    );
    
    fragColor += shadow_point_circle(fragCoord,
        cl2, c
    ) ? vec4(0.0) : pointLight(
        fragCoord,
        /*light*/ vec4(cl2.xy, 1.2*var, 8.0*var),
        /*radius*/60.0,
        /*color*/ vec4(0.3, 0.2, 0.4, 1.0)
    );
}
