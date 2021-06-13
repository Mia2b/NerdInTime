import json

def getSpritesAndFlags(data, field):
    sprites = -1
    flags = -1
    name0 = data[field][0]["name"]
    if name0 == "sprites":
        sprites = data[field][0]
        flags = data[field][1]
    else:
        sprites = data[field][1]
        flags = data[field][0]
    return sprites, flags

def cleanSpritesAndFlags(data):
    spriteMap, flagMap = getSpritesAndFlags(data, "layers")
    spriteTiles, flagTiles = getSpritesAndFlags(data, "tilesets")
    if flagTiles["firstgid"] == 1:
        spriteOffFactor = flagTiles["tilecount"]
        flagOffFactor = spriteTiles["tilecount"]
        for i in range(len(spriteMap["data"])):
            if spriteMap["data"][i] != 0:
                spriteMap["data"][i] -= spriteOffFactor
        for i in range(len(flagMap["data"])):
            if flagMap["data"][i] != 0:
                flagMap["data"][i] += flagOffFactor
        spriteTiles["firstgid"] -= spriteOffFactor
        flagTiles["firstgid"] += flagOffFactor
    data["layers"][0] = spriteMap
    data["layers"][1] = flagMap
    data["tilesets"][0] = spriteTiles
    data["tilesets"][1] = flagTiles
    return data


def tileProperties(sprite, flag):
    properties = [{},{}]
    properties[0]["name"]  = "flagID"
    properties[0]["type"]  = "int"
    properties[0]["value"] = flag if flag >= 0 else 255
    properties[1]["name"]  = "colorOffset"
    properties[1]["type"]  = "int"
    properties[1]["value"] = 128 if sprite >= 1 else 0
    return properties

def makeTileObj(x, y, sprite, flag, width = 8, height = 8):
    tile = {}
    tile["name"] = "Tile:{0},{1}".format(x, y)
    tile["gid"] = sprite
    tile["width"] = width
    tile["height"] = height
    tile["x"] = x * width
    tile["y"] = (y + 1) * height
    tile["properties"] = tileProperties(sprite, flag)
    return tile


def makePV8Layers(data):
    spriteMap, flagMap = getSpritesAndFlags(data, "layers")
    spriteTiles, flagTiles = getSpritesAndFlags(data, "tilesets")
    spriteMap = spriteMap["data"]
    flagMap = flagMap["data"]
    for i in range(len(flagMap)):
        flagMap[i] = -1 if flagMap[i] == 0 else (flagMap[i] - flagTiles["firstgid"])
    width = data["width"]
    height = data["height"]
    layers = {}
    layers["draworder"] = "topdown"
    layers["name"] = "Tilemap"
    layers["id"] = 1
    layers["type"] = "objectgroup"
    layers["opacity"] = 1
    layers["visible"] = True
    layers["x"] = 0
    layers["y"] = 0
    layers["objects"] = []
    for y in range(height):
        for x in range(width):
            sprite = spriteMap[x + width * y]
            flag = flagMap[x + width * y]
            if sprite > 0 or flag >= 0:
                layers["objects"].append(makeTileObj(x, y, sprite, flag))
    return layers

def makePV8Tileset(data):
    spriteTileset, flagTileset = getSpritesAndFlags(data, "tilesets")
    tileset = {}
    tileset["columns"]          = spriteTileset["columns"]
    tileset["firstgid"]         = spriteTileset["firstgid"]
    tileset["image"]            = "sprites.png"
    tileset["imagewidth"]       = spriteTileset["imagewidth"]
    tileset["imageheight"]      = spriteTileset["imageheight"]
    tileset["margin"]           = spriteTileset["margin"]
    tileset["name"]             = spriteTileset["name"]
    tileset["spacing"]          = spriteTileset["spacing"]
    tileset["tilewidth"]        = spriteTileset["tilewidth"]
    tileset["tileheight"]       = spriteTileset["tileheight"]
    tileset["tilecount"]        = spriteTileset["tilecount"]
    tileset["transparentcolor"] = "#FF00FF"
    return tileset

def makePV8(tiled):
    tiled = cleanSpritesAndFlags(tiled)
    pv8 = {}
    pv8["width"]           = 256
    pv8["height"]          = 256
    pv8["nextobjectid"]    = tiled["nextobjectid"]
    pv8["orientation"]     = tiled["orientation"]
    pv8["renderorder"]     = tiled["renderorder"]
    pv8["tiledversion"]    = tiled["tiledversion"]
    pv8["tilewidth"]       = tiled["tilewidth"]
    pv8["tileheight"]      = tiled["tileheight"]
    pv8["type"]            = tiled["type"]
    pv8["version"]         = 1
    pv8["backgroundcolor"] = "#FF00FF"
    pv8["tilesets"] = [makePV8Tileset(tiled)]
    pv8["layers"] = [makePV8Layers(tiled)]
    return pv8

tiled = {}

with open("tiledSourceMap.json") as tileMap:
    tiled = json.load(tileMap)

pv8 = makePV8(tiled)

with open("../tilemap.json", "w") as output:
    output.write(json.dumps(pv8))
