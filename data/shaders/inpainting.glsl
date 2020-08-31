// https://www.shadertoy.com/view/4ty3Dy
// Diffusion from jamriska.
// Used techniques in Jeschke et al. 09.

uniform vec3 iResolution;
uniform float iGlobalTime;
uniform vec4 iMouse;
uniform sampler2D tex0;

// ~ ~ ~ BUFFER A ~ ~ ~ 
/** 
 * Laplacian Solver For Image Completion
 * Forked from [url=https://www.shadertoy.com/view/XdKGDW]jamriska[/url].
 * Used techniques in [url=https://pdfs.semanticscholar.org/2407/5ab482f70ffd1137abb3a533dfe551210c6f.pdf]Jeschke et al. 09[/url].
 * To be simplified, I removed the support for resizing the rendering buffer.
 */

// buffer A holds the original image
vec4 bufferA(vec4 fragColor, vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy); 
    // render the first frame
    if (iFrame < 5) {
        // set this pixel unknown
        fragColor = vec4(vec3(-1.0), 1);
        // return the image with holes
        vec3 col = texture(iChannel3, fragCoord.xy/iResolution.xy).xyz;
        if (length(col) > 0.5) fragColor = vec4(texture(iChannel2, fragCoord.xy/iResolution.xy).xyz, 1.0); 
    }
    return fragColor;
}

// ~ ~ ~ BUFFER B ~ ~ ~ 
// buffer B stores the distance map of the curves along with an intial guess of the solution
const int LEVEL_OF_PYRAMID = 4;

// short cut for texturing
vec4 bufferB(vec4 fragColor, vec2 fragCoord) {
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
    for (int i = 0; i < LEVEL_OF_PYRAMID; i++) {          
        d = min(d, B(x - r, y   ) + r);
        d = min(d, B(x + r, y   ) + r);
        d = min(d, B(x    , y - r) + r);
        d = min(d, B(x    , y + r) + r);
        r = r / 2.0;
    }     

    fragColor = vec4(vec3(d), 1.0);
    return fragColor;
}

// ~ ~ ~ BUFFER C ~ ~ ~ 
// short cut for texturing
vec4 bufferC(vec4 fragColor, vec2 fragCoord) {
    float x = fragCoord.x, y = fragCoord.y;
    
    vec3 a = A(x,y);
    if (a.x > -0.5) { 
        fragColor = vec4(a, 1); 
        return; 
    };  
        
        
    float r = min(B(x,y), mix(512.0, 1.0, clamp(max(float(iFrame) / 64.0 - 1.0,0.0), 0.0, 1.0)));

    /*
    // gamma correction
    vec3 c = pow((pow(C(x - r, y ), vec3(2.2)) +
                  pow(C(x + r, y ), vec3(2.2)) +
                  pow(C(x    , y-r), vec3(2.2)) +
                  pow(C(x    , y+r), vec3(2.2))) / 4.0, vec3(1.0 / 2.2));
    */
    vec3 c = (C(x - r, y ) +
              C(x + r, y ) +
              C(x    , y-r) +
              C(x    , y+r)) / 4.0;
    
    fragColor = vec4(c, 1);
    return fragColor;
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

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    if (iMouse.z > 0.0) {
        fragColor = texture(iChannel0, uv); 
    } else {
    	fragColor = texture(iChannel2, uv);
    }
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
}