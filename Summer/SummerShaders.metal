//
//  SummerShaders.metal
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-20.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertexShader(uint vertexId [[vertex_id]], constant VertexIn* vertexData [[buffer(0)]]) {
    VertexOut vert;
    
    vert.position = float4(vertexData[vertexId].position, 0, 1);
    vert.texCoord = vertexData[vertexId].texCoord;
    
    return vert;
}

fragment float4 textureShader(VertexOut vert [[stage_in]],
                              texture2d<float, access::sample> tex [[texture(0)]],
                              sampler sam [[sampler(0)]]) {
    return tex.sample(sam, vert.texCoord);
}
//hello my name is azhaararraararrrararaarara and welcome to my waffle house we are currently serving spaghet.
