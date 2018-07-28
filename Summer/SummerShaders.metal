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

// Replace with struct
enum MetadataFields {
    mapWidth, mapHeight,
    tilesetWidth, tilesetHeight,
    tileWidth, tileHeight,
    tilesX, tilesY,
    bigUnitX, bigUnitY
};

vertex VertexOut mapVertexShader(uint vertexId [[vertex_id]],
                                 constant uint* metadata [[buffer(0)]],
                                 constant uint* mapData [[buffer(1)]],
                                 constant Transform* transform [[buffer(2)]]) {
    // Get map metadata.
    uint mapWidth = metadata[MetadataFields::mapWidth];
    uint tilesetWidth = metadata[MetadataFields::tilesetWidth], tilesetHeight = metadata[MetadataFields::tilesetHeight];
    uint tileWidth = metadata[MetadataFields::tileWidth], tileHeight = metadata[MetadataFields::tileHeight];
    uint tilesX = metadata[MetadataFields::tilesX];
    uint bigUnitX = metadata[MetadataFields::bigUnitX], bigUnitY = metadata[MetadataFields::bigUnitY];
    
    // Get transform.
    Transform t = *transform;
    
    // Calculate locations and vertex locations.
    uint vertexType = vertexId % 6;
    uint tileId = vertexId / 6;
    uint tileData = mapData[tileId];
    uint tileX = tileId % mapWidth, tileY = tileId / mapWidth;
    uint tilesetX = tileData % tilesX, tilesetY = tileData / tilesX;
    
    float tileUnitX = tileWidth / (float)tilesetWidth;
    float tileUnitY = tileHeight / (float)tilesetHeight;
    
    // Get a vertex location from the `vertexTypes` array.
    VertexOut vert = vertexTypes[vertexType];
    
    // Adjust the tile location.
    vert.position.x += tileX;
    vert.position.y += tileY;
    
//    vert.position.x *= tileWidth;
//    vert.position.y *= tileHeight;
    
    vert.position.x = vert.position.x / bigUnitX * 2 - 1;
    vert.position.y = -(vert.position.y / bigUnitY * 2 - 1);
    
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
