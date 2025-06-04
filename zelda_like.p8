pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- simple zelda-like demo
-- move with arrow keys and press Z to swing sword

player = {}
enemy = {}

FLAG_SOLID = 0 -- map flag index for solid tiles

function setup_map()
    -- fill map with ground tiles
    for x=0,15 do
        for y=0,15 do
            mset(x,y,0)
        end
    end
    -- outer wall using tile 1
    for i=0,15 do
        mset(i,0,1)
        mset(i,15,1)
        mset(0,i,1)
        mset(15,i,1)
    end
    -- mark tile 1 as solid
    fset(1,FLAG_SOLID,true)
end

function is_walkable(tx,ty)
    return not fget(mget(tx,ty),FLAG_SOLID)
end

function _init()
    setup_map()
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
    enemy.vx = 0
    enemy.vy = 0
end

function _update()
    -- movement with collision
    local nx = player.x
    local ny = player.y
    if btn(0) then nx -= 1 player.dir = 0 end
    if btn(1) then nx += 1 player.dir = 1 end
    if btn(2) then ny -= 1 player.dir = 2 end
    if btn(3) then ny += 1 player.dir = 3 end
    if is_walkable(flr(nx/8), flr(ny/8)) then
        player.x = nx
        player.y = ny
    end

    -- enemy wander
    if rnd(1) < 0.05 then
        enemy.vx = flr(rnd(3)) - 1
        enemy.vy = flr(rnd(3)) - 1
    end
    local ex = enemy.x + enemy.vx
    local ey = enemy.y + enemy.vy
    if is_walkable(flr(ex/8), flr(ey/8)) then
        enemy.x = ex
        enemy.y = ey
    end

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
    map(0,0,0,0,16,16)
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
