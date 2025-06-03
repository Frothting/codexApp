pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- simple zelda-like demo
-- move with arrow keys and press Z to swing sword

player = {}
enemy = {}

function _init()
    player.x = 64
    player.y = 64
    player.w = 8
    player.h = 8
    player.dir = 1
    player.health = 3
    player.attack_timer = 0
    enemy.x = 96
    enemy.y = 64
    enemy.w = 8
    enemy.h = 8
    enemy.health = 3
end

function _update()
    -- movement
    if btn(0) then player.x -= 1 player.dir = 0 end
    if btn(1) then player.x += 1 player.dir = 1 end
    if btn(2) then player.y -= 1 player.dir = 2 end
    if btn(3) then player.y += 1 player.dir = 3 end

    -- attack
    if btnp(4) and player.attack_timer == 0 then
        player.attack_timer = 8
    end
    if player.attack_timer > 0 then
        player.attack_timer -= 1
        local ax = player.x
        local ay = player.y
        if player.dir == 0 then ax -= 8
        elseif player.dir == 1 then ax += 8
        elseif player.dir == 2 then ay -= 8
        elseif player.dir == 3 then ay += 8 end
        if enemy.health > 0 and collides(ax, ay, 8, 8, enemy.x, enemy.y, enemy.w, enemy.h) then
            enemy.health -= 1
        end
    end
end

function _draw()
    cls()
    -- player
    rectfill(player.x, player.y, player.x + player.w - 1, player.y + player.h - 1, 11)

    -- sword
    if player.attack_timer > 0 then
        local sx = player.x
        local sy = player.y
        if player.dir == 0 then sx -= 8
        elseif player.dir == 1 then sx += 8
        elseif player.dir == 2 then sy -= 8
        elseif player.dir == 3 then sy += 8 end
        rectfill(sx, sy, sx + 7, sy + 7, 7)
    end

    -- enemy
    if enemy.health > 0 then
        rectfill(enemy.x, enemy.y, enemy.x + enemy.w - 1, enemy.y + enemy.h - 1, 8)
    end

    -- health display
    for i = 1, player.health do
        circfill(4 + (i - 1) * 8, 4, 3, 10)
    end
end

function collides(ax, ay, aw, ah, bx, by, bw, bh)
    return not (ax + aw < bx or ax > bx + bw or ay + ah < by or ay > by + bh)
end
