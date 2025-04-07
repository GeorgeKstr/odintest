package engine

entity :: struct {
    origin: rl.Vector3,
    angle: rl.Vector3,
    flags: [len(stackFlags)]bool,
    draw: proc(),
}