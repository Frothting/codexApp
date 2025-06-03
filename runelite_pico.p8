pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- runelite pico main cart
-- minimal scaffolding

-- global helper table
T={}

function _init()
end

function _update()
    if btnp(7) then
        run_tests()
    end
end

function _draw()
    cls()
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
