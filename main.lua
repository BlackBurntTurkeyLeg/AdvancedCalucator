local mathadtins = require("mathadtins")

local alphabet = (function(x,y)
      local a = {};
      for i = x,y do
          a[#a+1] = string.char(i);
      end;
      return a;
    end)(string.byte("a"),string.byte("z"));
local function numberup(num,t)
    
    local r, v = num%#alphabet, (num/#alphabet - (num%#alphabet)/#alphabet);
    local t = "";
    if v > 0 and r ~= 0 then
        t = t .. (numberup(v)):upper();
    end;
    if v > 0 and r == 0 then
        if v ~= 1 then
            t = t .. (numberup((v-1))):upper()
        end
    end
    if r > 0 then
        t = t .. ((alphabet[tonumber(tostring(r))]));
    end
    if r == 0 then
        t = t .. alphabet[#alphabet]
    end;
    return t
end;
--[[

percent(12,12) -- percentage of how y goes into x (100)
percent(12,%12) -- what number is y of x (1.44)
percent(12,%12,1) -- what number of y is x (100)
]]

local function eval(vars)
     local variables = {}
    local expression =
        vars:gsub(
        "(%a+)%s*=%s*(%b())",
        function(v,c)
            c = c:sub(2,#c-1);
            return v .. "="..eval(c);
        end
    ):gsub(
        "%a+%s*=%s*[%-]?%d+[.]?%d*",
        function(c)
            local var = c:match("%a+")
            local num = c:match("[%-]?%d+[.]?%d*")
            variables[var] = num
            return ""
        end
    ):gsub(
        "surface(%b())",
        function(v)
            local o = v:sub(2,#v-1)..",";
            o = ","..o:gsub(",",function()return",,"end);
            local l,h,w;
            local _ = o:gsub("%b,,",function(c)
                c = c:sub(2,#c-1)
                if l == nil then
                    l = tonumber(c)
                elseif h == nil then
                    h = tonumber(c);
                elseif w == nil then
                    w = tonumber(c);
                end
            end)
            if l and h and w then
                return "(".."("..l.."*"..h.."*2) + ("..w.."*"..l.."*2) + ("..w.."*"..h.."*2)" .. ")";
            end
        end
    ):gsub(
        "area(%b())",
        function(v)
            local o = v:sub(2,#v-1)..",";
            o = ","..o:gsub(",",function()return",,"end);
            local l,h,w;
            local _ = o:gsub("%b,,",function(c)
                c = c:sub(2,#c-1)
                if l == nil then
                    l = (c)
                elseif h == nil then
                    h = (c);
                elseif w == nil then
                    w = (c);
                end
            end)
            if l and h and w then
                return "("..l .."*" .. h .."*".. w..")";
            elseif l and h then
                return "("..l .."*" .. h..")"
            end
        end
    ):gsub(
        "percent(%b())",
        function(v)
            local o = v:sub(2,#v-1)..",";
            o = ","..o:gsub(",",function()return",,"end);
            local args = {}
            local _ = o:gsub("%b,,",function(c)
                c = c:sub(2,#c-1)
                args[#args+1] = c;
            end)
            local percentage,num;
            for i,v in next, args do
                if v:find("%%") then
                    percentage = v:gsub("%%","");
                elseif num == nil then
                    num = v
                end
            end;
            
            if percentage and args[3] == nil  then -- get number from fraction
                local x,y = num, percentage;
                
                return "("..x.." * ("..y.."/100))"
            elseif args[3] and percentage  then  -- get percentage of number
                local x,y = num, percentage
                return '((1/'..y..' * '..x..'/1) * 100)';
              else -- get percentage
                  local x,y = args[1], args[2]
                  return "(("..x.." * 100) / "..y..")"

            end
        end
    ):gsub(
        "fraction(%b())",
        function(v)
            local o = v:sub(2,#v-1)..",";
            o = ","..o:gsub(",",function()return",,"end);
            local args = {}
            local _ = o:gsub("%b,,",function(c)
                c = c:sub(2,#c-1)
                args[#args+1] = c;
            end)

            
        end
    )

    local lex = mathadtins.Lexer(expression, variables)
        local sus, result = pcall(mathadtins.Evaluate, lex)
        if sus then
            return tostring(result)
        else
            if #expression:gsub("%s","") > 0 then
                return ("Error")
            else
                return ("No Input")
            end
        end
    
end;

print('Advanced Calculator\n\tTo add variables, put in variable = value\n\tTo do multiple operations use `~` to seperate\n\tTo set values to expressions do `x = (expression)`\n\tThere are also functions like log, floor, sqrt, sin, and abs.\n\tYou can use `||` to get absolute value aswell.\n\tThere are forumlas you can use, like `percent`, `area`, and `surface`.\n\tTo see how forumlas work, put in `forumlas` in the box.\n\n[PRESS ENTER]');
(function(input)
  if input == "forumlas" then
os.execute("clear");
print([[
Forumlas are like functions, but instead of functions that generate the answer, forumlas create forumlas.

        surface(3 ARGS FOR 3D): Generates a forumla that generates the surface area of a rectanglar prism

        area(3-2 ARGS FOR 2D AND 3D): Generates the forumla for area
        percent(3-2 ARGS): 
            | (num, percentage): Generates the forumla: [percentage] of [x].
            | (x, y): Generates the formula: the percentage of [y] into [x].
            | (x, percentage, 1): Generates the forumla: the number of [percentage] is x.


[PRESS ENTER]
]]);

io.read();
end
  end)(io.read("*l"));
while true do
    os.execute("clear")
    print("advanced calculator easy and complicated\nInput: Type down below\n")
    local vars = io.read("*l")
    local variables = {}
    if vars:find("~") then
        local expressions = {};
        
        local e = "";
        for i = 1 , #vars do
            local c = vars:sub(i,i);
            if c == "~" then
                expressions[#expressions+1] = e;
                e = "";
            elseif i == #vars then
                expressions[#expressions+1] = e..c;
            else
                e = e .. c;
            end
        end
    
        print("Answers");
        for i,v in next, expressions do
            print("\t",numberup(i).."\t:\t".. eval(v),"\t::EXP:\t",v);
        end
    else
        print("Answer: ".. eval(vars))
    end
    print("\n[PRESS ENTER]")
    io.read()
end
