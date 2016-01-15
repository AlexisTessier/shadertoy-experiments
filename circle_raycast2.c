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
    
    float ambiant = d < radius ? idiv : idiv/(pow(ddiv, 8.0));
    
    return (color*(iexp))+(color*ambiant);
}

bool circle(vec2 fragCoord, vec3 c){
	//c.xy => center position
    //c.z => radius
    
    return (distance(fragCoord, vec2(c.xy)) <= c.z);
}

vec4 shadow(vec2 fragCoord, vec2 light, vec3 c, vec4 color, float lr){
    vec4 mcolor = color;
    float d = distance(fragCoord, light);
    float dd = distance(light, vec2(c.xy));
    float d2 = d - dd;
    float att = d2/d;
    float llr = lr - dd;
    mcolor*= clamp(pow(att*(d2/llr), 2.0), 0.0, att)*pow(att, 2.0);
    
    vec2 ray = light - fragCoord;
    vec2 cToL = vec2(c.xy) - light;
                          
    float a = dot(ray, ray);
    float b = dot(2.0*cToL, ray) ;
    float cc = dot(cToL, cToL) - (c.z*c.z) ;

    float discriminant = b*b-4.0*a*cc;
    if( discriminant < 0.0 )
    {
      return color;
    }
    else{
        discriminant = sqrt( discriminant );
        float t1 = (-b - discriminant)/(2.0*a);
  		float t2 = (-b + discriminant)/(2.0*a);
        
        if( t1 >= 0.0 && t1 <= 1.0 )
        {
           return mcolor;
        }
          if( t2 >= 0.0 && t2 <= 1.0 )
          {
            // ExitWound
            return mcolor;
          }
    }
    return color;
    
	
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 position = vec2(floor(fragCoord.x), floor(fragCoord.y));
    vec2 uv = fragCoord.xy / iResolution.xy;
    float loopDuration = 25.0, halfDuration = (loopDuration/2.0);
    float time = mod(iGlobalTime, loopDuration);
    float cursor = 2.0*((time < halfDuration ? time : (loopDuration-time))/loopDuration);
    float var = 0.2+easeInOutQuart(cursor)/2.0;
    
    fragColor = vec4(0.0);
    
    fragColor += lightSpot(
        fragCoord,
        /*light*/ vec4(iResolution.xy/4.0, 1.0*var, 35.0*var),
        /*radius*/85.0,
        /*color*/ vec4(1.0, 0.2, 0.1, 1.0)
    );
    
    vec2 c1 = (vec2(0.0)+iGlobalTime*30.0)-vec2(1.0, iGlobalTime*18.0)+iGlobalTime*5.0;
    vec3 c = vec3(iResolution.xy/2.0+30.0, 20.0);
    
    fragColor += shadow(fragCoord, c1, c, lightSpot(
        fragCoord,
        /*light*/ vec4(c1.xy, 1.2*var, 24.0*var),
        /*radius*/320.0,
        /*color*/ vec4(0.1, 0.4, 1.0, 1.0)
    ), 320.0);
    
    fragColor = circle(fragCoord,
    	/*center, radius*/c
    ) ? vec4(0.5) : fragColor;
}
