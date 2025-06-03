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

player={x=64,y=64,spd=1,hp=10,max_hp=10,mana=5,max_mana=5,xp=0,max_xp=10}
player.tx=nil
player.ty=nil

-- combat globals
attack_cooldown=0
enemies={{x=96,y=64,hp=5,vx=0,vy=0}}

-- quest system
Q_NONE=0
Q_ACTIVE=1
Q_DONE=2
quests={}

-- inventory system
inventory={}
inventory_open=false

-- skills table
skills={
    sword={lvl=1,xp=0},
    magic={lvl=1,xp=0},
    heal={lvl=1,xp=0},
    fish={lvl=1,xp=0}
}

-- basic spells
spells={
    fire={id="fire",cost=3,damage=4},
    heal={id="heal",cost=2,heal=5}
}

-- npc + dialog
npcs={{x=80,y=64,id=1,dialog="hello adventurer"}}
game_state="play"
current_dialog=nil

-- tile flag for solid collision
FLAG_SOLID=0x01

function is_walkable(tx,ty)
    return not fget(mget(tx,ty),0)
end

function draw_bar(x,y,w,h,val,max_val,col_full,col_empty)
    local fill=0
    if max_val>0 then
        fill=flr(w*val/max_val)
    end
    rectfill(x,y,x+w-1,y+h-1,col_empty)
    if fill>0 then
        rectfill(x,y,x+fill-1,y+h-1,col_full)
    end
end

function sgn(x)
    if x>0 then return 1 elseif x<0 then return -1 else return 0 end
end

function xp_to_level(lvl)
    return lvl*10
end

function gain_xp(skill,amt)
    local s=skills[skill]
    if s then
        s.xp+=amt
        while s.xp>=xp_to_level(s.lvl) do
            s.xp-=xp_to_level(s.lvl)
            s.lvl+=1
        end
    end
end

function cast_spell(spell,target)
    if player.mana<spell.cost then return false end
    player.mana-=spell.cost
    if spell.damage then
        target.hp=max(0,(target.hp or 0)-spell.damage)
    end
    if spell.heal then
        if target.max_hp then
            target.hp=min(target.max_hp,target.hp+spell.heal)
        else
            target.hp=(target.hp or 0)+spell.heal
        end
    end
    return true
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

function open_dialog(n)
    current_dialog=n.dialog
    game_state="dialog"
end

function close_dialog()
    current_dialog=nil
    game_state="play"
end

function update_npcs()
    if T.stat(34)==1 then
        local mx=T.stat(32)
        local my=T.stat(33)
        if game_state=="play" then
            for n in all(npcs) do
                local dx=mx-n.x
                local dy=my-n.y
                if dx*dx+dy*dy<=64 then
                    open_dialog(n)
                    break
                end
            end
        else
            close_dialog()
        end
    end
end

function update_enemy(e)
    local dx=player.x-e.x
    local dy=player.y-e.y
    if dx*dx+dy*dy<=1024 then
        e.vx=sgn(dx)
        e.vy=sgn(dy)
    elseif rnd(1)<0.05 then
        e.vx=flr(rnd(3))-1
        e.vy=flr(rnd(3))-1
    end
    local nx=e.x+e.vx
    local ny=e.y+e.vy
    if is_walkable(flr(nx/8),flr(ny/8)) then
        e.x=nx
        e.y=ny
    end
end

function update_enemies()
    if game_state~="play" then return end
    if attack_cooldown>0 then
        attack_cooldown-=1
    end
    for e in all(enemies) do
        update_enemy(e)
    end
    if T.stat(34)==1 and attack_cooldown==0 then
        local mx=T.stat(32)
        local my=T.stat(33)
        for e in all(enemies) do
            if mx>=e.x and mx<=e.x+7 and my>=e.y and my<=e.y+7 and e.hp>0 then
                e.hp=max(0,e.hp-skills.sword.lvl)
                attack_cooldown=15
                break
            end
        end
    end
end

function handle_spells()
    if btnp(6) then
        local mx=T.stat(32)
        local my=T.stat(33)
        for e in all(enemies) do
            if mx>=e.x and mx<=e.x+7 and my>=e.y and my<=e.y+7 and e.hp>0 then
                cast_spell(spells.fire,e)
                break
            end
        end
    end
    if btnp(5) then
        cast_spell(spells.heal,player)
    end
end

function accept_quest(id)
    for q in all(quests) do
        if q.id==id then
            q.status=Q_ACTIVE
            break
        end
    end
end

function complete_quest(id)
    for q in all(quests) do
        if q.id==id and q.status==Q_ACTIVE then
            q.status=Q_DONE
            player.xp=mid(0,player.xp+q.reward_xp,player.max_xp)
            break
        end
    end
end

function add_item(id,qty)
    for it in all(inventory) do
        if it.id==id then
            it.qty+=qty
            return
        end
    end
    add(inventory,{id=id,qty=qty})
end

function remove_item(id,qty)
    for it in all(inventory) do
        if it.id==id then
            it.qty-=qty
            if it.qty<=0 then
                del(inventory,it)
            end
            break
        end
    end
end

function toggle_inventory()
    inventory_open=not inventory_open
end

function _init()
end

function _update()
    if btnp(7) then
        run_tests()
    end
    if btnp(4) then
        toggle_inventory()
    end
    handle_spells()
    update_player()
    update_npcs()
    update_enemies()
end

function _draw()
    cls()
    local mx=T.stat(32)
    local my=T.stat(33)
    local tx=flr(mx/8)
    local ty=flr(my/8)
    if is_walkable(tx,ty) then
        rect(tx*8,ty*8,tx*8+7,ty*8+7,10)
    end
    rectfill(player.x,player.y,player.x+7,player.y+7,7)
    for n in all(npcs) do
        rectfill(n.x,n.y,n.x+7,n.y+7,11)
    end
    for e in all(enemies) do
        if e.hp>0 then
            rectfill(e.x,e.y,e.x+7,e.y+7,8)
        end
    end
    draw_bar(2,2,20,2,player.hp,player.max_hp,8,1)
    draw_bar(2,6,20,2,player.mana,player.max_mana,12,1)
    draw_bar(2,10,20,2,player.xp,player.max_xp,9,1)
    if inventory_open then
        rectfill(96,0,127,63,0)
        rect(96,0,127,63,7)
        local y=2
        for it in all(inventory) do
            print(it.id..":"..it.qty,98,y,7)
            y+=6
        end
    end
    if game_state=="dialog" and current_dialog then
        rectfill(16,96,111,120,0)
        rect(16,96,111,120,7)
        print(current_dialog,18,100,7)
    end
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
    player={x=0,y=0}
    enemies={{x=16,y=0,hp=5,vx=0,vy=0}}
    update_enemy(enemies[1])
    assert_eq(enemies[1].vx,-1,"enemy chase vx")
    assert_eq(enemies[1].vy,0,"enemy chase vy")
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

add_test(function()
    local calls=0
    local old_rectfill=rectfill
    rectfill=function()
        calls+=1
    end
    draw_bar(0,0,8,1,4,8,8,1)
    rectfill=old_rectfill
    assert_eq(calls,2,"draw_bar rects")
end)

add_test(function()
    game_state="play"
    open_dialog({dialog="test"})
    assert_eq(game_state,"dialog","open_dialog state")
end)

add_test(function()
    player={x=0,y=0,spd=1,hp=10,max_hp=10,mana=5,max_mana=5,xp=0,max_xp=10}
    quests={{id=1,qtype="test",arg=0,status=Q_NONE,reward_xp=3}}
    accept_quest(1)
    assert_eq(quests[1].status,Q_ACTIVE,"quest accepted")
    complete_quest(1)
    assert_eq(quests[1].status,Q_DONE,"quest done")
    assert_eq(player.xp,3,"quest xp")
end)

add_test(function()
    inventory={}
    add_item(1,3)
    remove_item(1,2)
    assert_eq(#inventory,1,"inv count")
    assert_eq(inventory[1].qty,1,"inv qty")
end)

add_test(function()
    skills={sword={lvl=2,xp=0}}
    enemies={{x=0,y=0,hp=5}}
    attack_cooldown=0
    T.stat=function(n)
        if n==32 then return 0 end
        if n==33 then return 0 end
        if n==34 then return 1 end
        return 0
    end
    update_enemies()
    T.stat=stat
    assert_eq(enemies[1].hp,3,"enemy dmg")
    assert_eq(attack_cooldown,15,"cooldown set")
end)

add_test(function()
    player={mana=5}
    local e={hp=5}
    cast_spell(spells.fire,e)
    assert_eq(player.mana,2,"fire mana")
    assert_eq(e.hp,1,"fire dmg")
end)

add_test(function()
    player={hp=3,max_hp=10,mana=5}
    cast_spell(spells.heal,player)
    assert_eq(player.hp,8,"heal hp")
    assert_eq(player.mana,3,"heal mana")
    cast_spell(spells.heal,player)
    assert_eq(player.hp,10,"heal clamp")
end)
