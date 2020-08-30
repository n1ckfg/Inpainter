// https://www.shadertoy.com/view/4ty3Dy
// Diffusion from jamriska.
// Used techniques in Jeschke et al. 09.

// ~ ~ ~ BUFFER A ~ ~ ~ 
/** 
 * Laplacian Solver For Image Completion
 * Forked from [url=https://www.shadertoy.com/view/XdKGDW]jamriska[/url].
 * Used techniques in [url=https://pdfs.semanticscholar.org/2407/5ab482f70ffd1137abb3a533dfe551210c6f.pdf]Jeschke et al. 09[/url].
 * To be simplified, I removed the support for resizing the rendering buffer.
 */

// buffer A holds the original image
//#define TEST_GRID

void drawGrid(vec2 coord, inout vec3 col) {
    const vec3 COLOR_AXES = vec3(0.698, 0.8745, 0.541);
    const vec3 COLOR_GRID = vec3(1.0, 1.0, 0.702);
    const float tickWidth = 0.1;
    
    for (float i = -2.0; i < 2.0; i += tickWidth) {
		if (abs(coord.x - i) < 0.004) col = COLOR_GRID + coord.y / 4.0+ coord.x / 4.0;
		if (abs(coord.y - i) < 0.004) col = COLOR_GRID + coord.y / 4.0+ coord.x / 4.0;
	}
	if( abs(coord.x) < 0.006 ) col = COLOR_AXES;
	if( abs(coord.y) < 0.007 ) col = COLOR_AXES;	
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy); 
    // render the first frame
    if (iFrame < 5)
    {
        // set this pixel unknown
        fragColor = vec4(vec3(-1.0), 1);
        // return the image with holes
        vec3 col = texture(iChannel3, fragCoord.xy/iResolution.xy).xyz;
        if (length(col) > 0.5) fragColor = vec4(texture(iChannel2, fragCoord.xy/iResolution.xy).xyz, 1.0); 
#ifdef TEST_GRID
        col = vec3(0.0); 
        vec2 coord = 2.0 * (fragCoord.xy - 0.5 * iResolution.xy) / iResolution.y;
        drawGrid(coord, col); 
        if (length(col) > 0.0) fragColor = vec4(col, 1.0); else fragColor = vec4(-1.0); 
#endif
    }
}

// ~ ~ ~ BUFFER B ~ ~ ~ 
// buffer B stores the distance map of the curves along with an intial guess of the solution
const int LEVEL_OF_PYRAMID = 4;

// short cut for texturing
#define A(X,Y) (tap(iChannel0,vec2(X,Y)))
#define B(X,Y) (tap(iChannel1,vec2(X,Y)))
float tap(sampler2D tex,vec2 coord) { return texture(tex, coord / iResolution.xy).x; }


#define LAST_RESOLUTION texture(iChannel1, vec2(0.5,0.5) / iResolution.xy).yz
#define FRAME_RESET texture(iChannel1, vec2(1.5,0.5) / iResolution.xy).y

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float x = fragCoord.x;
    float y = fragCoord.y;  
    
    if (A(x,y) > -0.5 || iFrame < 3) { 
    	fragColor = vec4(vec3(0.0), 1.0);	// d = 0.0; 
        return; 
    };  
        
    float d = 100000.0;
    float r = pow(2.0, float(LEVEL_OF_PYRAMID - 1));
    // get the minimum value from buffer B
    // init d = 0.0;
    for (int i = 0; i < LEVEL_OF_PYRAMID; i++)
    {          
        d = min(d, B(x - r, y    ) + r);
        d = min(d, B(x + r, y    ) + r);
        d = min(d, B(x    , y - r) + r);
        d = min(d, B(x    , y + r) + r);
        r = r / 2.0;
    }
    
        

    fragColor = vec4(vec3(d), 1.0);
}

// ~ ~ ~ BUFFER C ~ ~ ~ 
// short cut for texturing
#define GAMMA_CORRECTION
#define A(X,Y) (tap(iChannel0,vec2(X,Y)))
#define B(X,Y) (tap(iChannel1,vec2(X,Y)).x)
#define C(X,Y) (tap(iChannel2,vec2(X,Y)))

vec3 tap(sampler2D tex,vec2 xy) { return texture(tex,xy/iResolution.xy).xyz; }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float x = fragCoord.x, y = fragCoord.y;
    
    vec3 a = A(x,y);
    if (a.x > -0.5) { 
        fragColor = vec4(a, 1); 
        return; 
    };  
        
        
    float r = min(B(x,y), mix(512.0, 1.0, clamp(max(float(iFrame) / 64.0 - 1.0,0.0), 0.0, 1.0)));

#ifdef GAMMA_CORRECTION
    vec3 c = pow((pow(C(x - r, y  ), vec3(2.2)) +
                  pow(C(x + r, y  ), vec3(2.2)) +
                  pow(C(x    , y-r), vec3(2.2)) +
                  pow(C(x    , y+r), vec3(2.2))) / 4.0, vec3(1.0 / 2.2));
#else  
    vec3 c = (C(x - r, y  ) +
              C(x + r, y  ) +
              C(x    , y-r) +
              C(x    , y+r)) / 4.0;
#endif
    
    fragColor = vec4(c, 1);
}

// ~ ~ ~ IMAGE ~ ~ ~ 
/** 
 * Image Inpainting
 * Ruofei Du
 *
 * Click on the image to see the input.
 * 
 * Used the Laplacian Solver from [url=https://www.shadertoy.com/view/XdKGDW]jamriska[/url].
 * Used techniques in [url=https://pdfs.semanticscholar.org/2407/5ab482f70ffd1137abb3a533dfe551210c6f.pdf]Jeschke et al. 09[/url].
 * To be simplified, there is no support for resizing the rendering buffer.
 */

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    if (iMouse.z > 0.0) {
        fragColor = texture(iChannel0, uv); 
    } else {
    	fragColor = texture(iChannel2, uv);
    }
}