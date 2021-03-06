#define PHONG
#define M_PI 3.14

uniform vec3 diffuse;
uniform vec3 emissive;
uniform vec3 specular;
uniform float shininess;
uniform float opacity;

uniform float uTime;
uniform vec3 uStripeOrientation;
uniform float uInvert;
uniform vec3 uSquare;
uniform float uWidth;
uniform float uHeight;
uniform float uLength;
uniform float uProgress;

varying vec2 vUv;

#include <common>
#include <packing>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <uv2_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <envmap_pars_fragment>
#include <gradientmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars>
#include <lights_phong_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>

void main() {

    #include <clipping_planes_fragment>

    vec4 diffuseColor = vec4( diffuse, opacity );
    ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
    vec3 totalEmissiveRadiance = emissive;

    #include <logdepthbuf_fragment>
    #include <map_fragment>
    #include <color_fragment>
    #include <alphamap_fragment>
    #include <alphatest_fragment>
    #include <specularmap_fragment>
    #include <normal_flip>
    #include <normal_fragment>
    #include <emissivemap_fragment>

    // accumulation
    #include <lights_phong_fragment>
    #include <lights_template>

    // modulation
    #include <aomap_fragment>

    vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular + reflectedLight.indirectSpecular + totalEmissiveRadiance;

    #include <envmap_fragment>

    vec4 color = vec4(outgoingLight, diffuseColor.a );

    float absX = floor(-cos((uTime * 0.1 + M_PI * uSquare.x * ( ( vUv.x + uProgress + 0.15 ) * 2. - 1. ) * 0.5))) + 1.;
    float absY = floor(-cos((M_PI * uSquare.y * ( vUv.y * 2. - 1. ) * 0.5))) + 1.;

    if ( absX > 0. || absY > 0. ) {
       color = vec4(vec3(1.0 - uInvert), diffuseColor.a);
    } else {
        color = vec4(vec3(0.0 + uInvert), diffuseColor.a);  
    }

    // color = vUv.x > 1. - uProgress  ? vec4(vec3(1.0 - uInvert), diffuseColor.a) : vec4(vec3(0.0 + uInvert), diffuseColor.a);
    
    gl_FragColor = color;

    #include <tonemapping_fragment>
    #include <encodings_fragment>
    #include <fog_fragment>
    #include <premultiplied_alpha_fragment>
}