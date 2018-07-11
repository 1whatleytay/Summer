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

struct Transform {
    float2x2 matrix;
    float2 offset;
    float2 origin;
};

vertex VertexOut vertexShader(uint vertexId [[vertex_id]],
                              constant VertexIn* vertexData [[buffer(0)]],
                              constant Transform* transforms [[buffer(1)]],
                              constant uint* pivot [[buffer(2)]]) {
    VertexOut vert;
    
    Transform t = transforms[pivot[vertexId / 6]];
    
    vert.position = float4(t.matrix *
                           (vertexData[vertexId].position - t.origin)
                           + t.origin + t.offset
                           , 0, 1);
    vert.texCoord = vertexData[vertexId].texCoord;
    
    return vert;
}

fragment float4 textureShader(VertexOut vert [[stage_in]],
                              texture2d<float, access::sample> tex [[texture(0)]],
                              sampler sam [[sampler(0)]]) {
    return tex.sample(sam, vert.texCoord);
}
