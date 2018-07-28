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
    float opacity;
};

struct Transform {
    float2x2 matrix;
    float2 offset, origin;
    float opacity, extra;
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
    vert.opacity = t.opacity;
    
    return vert;
}

fragment float4 textureShader(VertexOut vert [[stage_in]],
                              texture2d<float, access::sample> tex [[texture(0)]],
                              sampler sam [[sampler(0)]]) {
    float4 sample = tex.sample(sam, vert.texCoord);
    sample.a *= vert.opacity;
    return sample;
}

constant VertexOut vertexTypes[] = {
    { float4(0, 0, 0, 1), float2(0, 0) },
    { float4(1, 0, 0, 1), float2(1, 0) },
    { float4(0, 1, 0, 1), float2(0, 1) },
    { float4(1, 0, 0, 1), float2(1, 0) },
    { float4(0, 1, 0, 1), float2(0, 1) },
    { float4(1, 1, 0, 1), float2(1, 1) }
};

struct MapMetadata {
    uint mapWidth, mapHeight;
    uint tilesetWidth, tilesetHeight;
    uint tileWidth, tileHeight;
    uint tilesX, tilesY;
    float unitX, unitY;
};

vertex VertexOut mapVertexShader(uint vertexId [[vertex_id]],
                                 constant MapMetadata* metadata [[buffer(0)]],
                                 constant uint* mapData [[buffer(1)]],
                                 constant Transform* transforms [[buffer(2)]],
                                 constant uint* transformId [[buffer(3)]]) {
    // Get map metadata.
    MapMetadata meta = *metadata;
    
    // Get transform.
    Transform t = transforms[*transformId];
    
    // Calculate locations and vertex locations.
    uint vertexType = vertexId % 6;
    uint tileId = vertexId / 6;
    uint tileData = mapData[tileId];
    uint tileX = tileId % meta.mapWidth, tileY = tileId / meta.mapWidth;
    uint tilesetX = tileData % meta.tilesX, tilesetY = tileData / meta.tilesX;
    
    float tileUnitX = meta.tileWidth / (float)meta.tilesetWidth;
    float tileUnitY = meta.tileHeight / (float)meta.tilesetHeight;
    
    // Get a vertex location from the `vertexTypes` array.
    VertexOut vert = vertexTypes[vertexType];
    
    // Adjust the tile location.
    vert.position.x = (vert.position.x + tileX) * meta.unitX * 2 - 1;
    vert.position.y = -((vert.position.y + tileY) * meta.unitY * 2 - 1);
    
    // Apply transform.
    float2 newPos = t.matrix * (vert.position.xy - t.origin) + t.origin + t.offset;
    
    vert.position.x = newPos.x;
    vert.position.y = newPos.y;
    
    // Calculate texture location.
    vert.texCoord.x = (vert.texCoord.x + tilesetX) * tileUnitX;
    vert.texCoord.y = (vert.texCoord.y + tilesetY) * tileUnitY;
    
    vert.opacity = t.opacity;
    
    return vert;
}
