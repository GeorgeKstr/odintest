package ui

import rl "vendor:raylib"
import "../defs"
import "core:hash"
import "core:strings"
import "core:fmt"

texture_cache := make(map[cstring]rl.Texture2D)


get_texture :: proc(texture_path: cstring) -> rl.Texture2D {
    if !(texture_path in texture_cache) {
        texture_cache[texture_path] = rl.LoadTexture(texture_path)
    }
    return texture_cache[texture_path]
}

// Function to draw a rectangle with alpha
draw_rectangle :: proc(pos: rl.Vector2, size: rl.Vector2, color: rl.Color, alpha: f32 = 1.0) {
    rl.DrawRectangleV(pos, size, rl.Color{color.r, color.g, color.b, u8(alpha * 255)})
}

// Function to draw a circle with alpha
draw_circle :: proc(center: rl.Vector2, radius: f32, color: rl.Color, alpha: f32 = 1.0) {
    rl.DrawCircleV(center, radius, rl.Color{color.r, color.g, color.b, u8(alpha * 255)})
}

// Function to draw a line with alpha
draw_line :: proc(start: rl.Vector2, end: rl.Vector2, color: rl.Color, alpha: f32 = 1.0) {
    rl.DrawLineV(start, end, rl.Color{color.r, color.g, color.b, u8(alpha * 255)})
}

// Function to draw a triangle with alpha
draw_triangle :: proc(v1: rl.Vector2, v2: rl.Vector2, v3: rl.Vector2, color: rl.Color, alpha: f32 = 1.0) {
    rl.DrawTriangle(v1, v2, v3, rl.Color{color.r, color.g, color.b, u8(alpha * 255)})
}

// Function to draw a rectangle outline with thickness and alpha
draw_rectangle_outline :: proc(pos: rl.Vector2, size: rl.Vector2, color: rl.Color, thickness: f32, alpha: f32 = 1.0) {
    rl.DrawRectangleLinesEx(rl.Rectangle{pos.x, pos.y, size.x, size.y}, thickness, rl.Color{color.r, color.g, color.b, u8(alpha * 255)})
}

// Function to draw a texture with alpha
draw_texture :: proc(texture_path: cstring, pos: rl.Vector2, size: rl.Vector2, alpha: f32 = 1.0) {
    texture := get_texture(texture_path)
    rl.DrawTexturePro(texture, rl.Rectangle{0, 0, f32(texture.width), f32(texture.height)}, rl.Rectangle{pos.x, pos.y, size.x, size.y}, rl.Vector2{0, 0}, 0, rl.Color{255, 255, 255, u8(alpha * 255)})
}

// Function to draw a centered texture with alpha
draw_texture_centered :: proc(texture_path: cstring, pos: rl.Vector2, size: rl.Vector2, alpha: f32 = 1.0) {
    texture := get_texture(texture_path)
    draw_texture(texture_path, rl.Vector2{pos.x - (size.x / 2), pos.y - (size.y / 2)}, size, alpha)
}

draw_text_centered :: proc(text: cstring, font: rl.Font, pos: rl.Vector2, size: rl.Vector2, color: rl.Color, alpha: f32 = 1.0) {
    _bounds := rl.MeasureTextEx(font, text, f32(font.baseSize), 0)
    rl.DrawTextEx(font, text, rl.Vector2{pos.x + (size.x / 2) - (_bounds.x / 2), pos.y + (size.y / 2) - (_bounds.y / 2)}, f32(font.baseSize), 0, rl.Color{color.r, color.g, color.b, u8(alpha * 255)})
}

draw_text :: proc(text: cstring, font: rl.Font, pos: rl.Vector2, color: rl.Color, alpha: f32 = 1.0) {
    rl.DrawTextEx(font, text, pos, f32(font.baseSize), 0, rl.Color{color.r, color.g, color.b, u8(alpha * 255)})
}

unload_textures :: proc() {
    for key, texture in texture_cache {
        rl.UnloadTexture(texture)
        delete_key(&texture_cache, key)
    }
}

