package input

import rl "vendor:raylib"

user_action::enum{
    ACTION_FORWARD,
    ACTION_BACKWARD,
    ACTION_LEFT,
    ACTION_RIGHT,
    ACTION_UP,
    ACTION_DOWN,
    ACTION_JUMP,
    ACTION_CROUCH,
    ACTION_ATTACK,
    ACTION_BLOCK,
    ACTION_USE,
    ACTION_INVENTORY,
    ACTION_PAUSE,
    ACTION_CONSOLE,
    ACTION_QUIT,
}

action_names := map[string]user_action{
    "FORWARD" = user_action.ACTION_FORWARD,
    "BACKWARD" = user_action.ACTION_BACKWARD,
    "LEFT" = user_action.ACTION_LEFT,
    "RIGHT" = user_action.ACTION_RIGHT,
    "UP" = user_action.ACTION_UP,
    "DOWN" = user_action.ACTION_DOWN,
    "JUMP" = user_action.ACTION_JUMP,
    "CROUCH" = user_action.ACTION_CROUCH,
    "ATTACK" = user_action.ACTION_ATTACK,
    "BLOCK" = user_action.ACTION_BLOCK,
    "USE" = user_action.ACTION_USE,
    "INVENTORY" = user_action.ACTION_INVENTORY,
    "PAUSE" = user_action.ACTION_PAUSE,
    "CONSOLE" = user_action.ACTION_CONSOLE,
    "QUIT" = user_action.ACTION_QUIT,
}

key_pending: bool = false
button_keybinds := make(map[rl.KeyboardKey]user_action)
actions_pressed := make(map[user_action]bool)
actions_released := make(map[user_action]bool)
setKeyboardStatus := proc() {
    for key, action in button_keybinds {
        if rl.IsKeyPressed(key) {
            actions_released[action] = false
            actions_pressed[action] = true
        } else if rl.IsKeyReleased(key) {
            actions_pressed[action] = false
            actions_released[action] = true
        }
    }
}