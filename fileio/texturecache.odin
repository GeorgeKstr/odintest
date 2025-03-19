package fileio

import rl "vendor:raylib"
import "../console"

texture_cache := make(map[cstring]rl.Texture2D)

get_texture :: proc(texture_path: cstring) -> rl.Texture2D {
    if !(texture_path in texture_cache) {
        texture_cache[texture_path] = rl.LoadTexture(texture_path)
        console.console_log("Loaded texture: [", texture_path, "]")
    }
    return texture_cache[texture_path]
}

unload_textures :: proc() {
    for key, texture in texture_cache {
        rl.UnloadTexture(texture)
        delete_key(&texture_cache, key)
        console.console_log("Unloaded texture: [", key, "]")
    }
}