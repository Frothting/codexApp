pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- runelite pico main cart
-- minimal scaffolding

-- global helper table
T={}

-- default input wrappers so tests can override
T.btn=btn
T.stat=stat
T.events={}

function fire_event(ev)
    add(T.events,ev)
end

player={x=64,y=64,spd=1}
player.tx=nil
player.ty=nil

-- tile flag for solid collision
FLAG_SOLID=0x01

function is_walkable(tx,ty)
    return not fget(mget(tx,ty),0)
end

function update_player()
    local moved=false

    if T.btn(0) and is_walkable(flr((player.x-1)/8),flr(player.y/8)) then
        player.x-=player.spd
        moved=true
    end
    if T.btn(1) and is_walkable(flr((player.x+player.spd)/8),flr(player.y/8)) then
        player.x+=player.spd
        moved=true
    end
    if T.btn(2) and is_walkable(flr(player.x/8),flr((player.y-player.spd)/8)) then
        player.y-=player.spd
        moved=true
    end
    if T.btn(3) and is_walkable(flr(player.x/8),flr((player.y+player.spd)/8)) then
        player.y+=player.spd
        moved=true
    end

    -- click to set target tile
    if T.stat(34)==1 then
        player.tx=flr(T.stat(32)/8)*8
        player.ty=flr(T.stat(33)/8)*8
    end

    -- step toward target
    if player.tx then
        if player.x<player.tx then
            player.x+=player.spd
        elseif player.x>player.tx then
            player.x-=player.spd
        end
        if player.y<player.ty then
            player.y+=player.spd
        elseif player.y>player.ty then
            player.y-=player.spd
        end

        if player.x==player.tx and player.y==player.ty then
            player.tx=nil
            player.ty=nil
            fire_event("player_arrived")
        end
    end

    return moved
end

function _init()
end

function _update()
    if btnp(7) then
        run_tests()
    end
    update_player()
end

function _draw()
    cls()
    rectfill(player.x,player.y,player.x+7,player.y+7,7)
end

tests={}
tests_passed=0
tests_failed=0

function assert_eq(a,b,msg)
    if a~=b then
        tests_failed+=1
        printh((msg or "assert").." fail: "..tostr(a).." != "..tostr(b))
    else
        tests_passed+=1
    end
end

function add_test(fn)
    add(tests,fn)
end

function run_tests()
    tests_passed=0
    tests_failed=0
    for t in all(tests) do
        t()
    end
    printh("tests "..tests_passed.." pass, "..tests_failed.." fail")
end

add_test(function()
    assert_eq(1+1,2,"math")
end)

add_test(function()
    -- simulate holding right arrow for four frames
    player={x=64,y=64,spd=1}
    local frame=0
    T.btn=function(k)
        if k==1 and frame<4 then return true end
        return false
    end
    while frame<4 do
        update_player()
        frame+=1
    end
    T.btn=btn
    assert_eq(player.x,68,"move right 4")
end)
