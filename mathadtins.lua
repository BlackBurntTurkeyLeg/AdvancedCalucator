--[[
@mathadtins.lua
Pronounced: meth-ad-tins(let the TH and A fade like tha)

Author: Shrek Orge(omg I'm so trash)

Information and begging applications


Why you should use this(cuz its greatest one)
Most string calucators use patterns and easy parsing, not this.
For start off, this uses a lexer(tokenizer).
You can manually parse the tokens before it gets its evaluation.
Second, more features supported including: Coefficients, Negative Integers, Memory saving(discontinued), Math Functions, and Hexdecimal values.


This isn't obviously that compact but it is customizable using Module.Debug(more info below).

NOTES FOR FORKERS:
btw remember it's the lexer that needs the variables, not the evaluation.

Began in 2022, now to 2023. And has been worked for 9 months.

UPDATES:
  
  Oct 22
      Added the variables methods where you can make coefficients with variables: 1x, abc, xy/z
  Oct 23
    Fixed the coefficients bug.
      Added Memory logs for faster results ;)
    Plus from the memory logs, you can use a file to log the memory so extra cool ;)
  Oct 24
    Supports negative numbers too!
    Better functionality of memory
    Added New Function : GetFinishedTokens
    Added an documentary for all of the functions(most)
    Fixed a lot(I'm telling you it was a hellhole)
    Introduction to math functions: log, sqrt, floor!
  Oct 29
    Fixed Order of Operations: ("%")
    Removed Module File Feature, Fixed String Pattern Function.
    Eulers Constant bug fix(Lexer can support eulers constant)
  Oct 30
    Removed Memory completely(caused a lot of bad results);
    Added Check symbol(√);
    Fixed Brackets []
  Nov 21
    Added a new divsion function for faster divison!
  Jan 25
    Added Loop Limit
version: 1.1.4
  Jan 29
    Added Back Memoization at its fullest!
  Apr 23
    Fixed Glitch
    Added abs
]]
--[[-]
  MATH_OP: The math operations used, + * ^ / -
    OP: Like MATH_OP but the symbol is the index.
  MATH_FUNC: The math functions
    FUNC: The same thing as MATH_FUNC in a different table

  Module.Debug: The debug library, in control for testing and playing with.
    AllowCoefficients: Allows coefficients to be in a tokens, also fixes them
    AllowHexdecimal: Allows hexdecimal values to be in a token, also fixes them
    Enclosing: Enclosing characters usedin parentheses, customizable for idients too(no math ops)
    AllowLog: prints all of the logs
    AllowMemory: Allows the script to memorize estimates and tokens for faster results. removed
    MemoryFile: The file used for the script to store its memory(optional) (removed and replaced by MemoFile RIP)
    AllowSigns: Allows negative numbers to be used
    AllowMFuncs: Allows math functions to be used(if turned off, you cant use the check symbol aswell)
    FixEulersConstant: Fixes the euler constant, toggle off will ignore the constant and may cause bugs
    LoopLimt: The Loop limit to control while loops from getting out of control.
    Memoization: Controls if memoization is allowed(Doesn't need a file name).
    MemoFile: The memoization file(optional but not recommended since it deceases performance);

  Module.Lexer: The Lexer used to turn a single string into multiple tokens to parse through

  Module.OP: It's the math operation table.

  Module.Memory: The memory table (discontinued and now replaced by memo RIP)
  Module.Memo: The memo table!

  Module.GetBrackets: Returns enclosing data

  Module.CalucateFirstOp: It gets the most important operation (miop) from its greatest level function(glf) and automatically calucates it and removes x and y, its the little boss but not recommend aswell.

  Module.SetBrackets: Uses the bracket data to evaluate anything inside those brackets (1+6): 5

  Module.GetFinishedTokens: Uses all of the parsing functions to get the finished tokens

  Module.Evaluate: The higher up boss, its bigger than big boss. It gets all of the tokens and uses special parses so that way it ends up accurate.

  Module.GetEvaluation: Its the big boss of the operation(I'm so funny), however this isn't the proper way to evaluate your tokens, Module.Evaluate fixes and checks tokens for you, with this it doesn't use the features it automatically parses thru the tokens and may cause bugs, not recommended.
]] --]]
local function modulo(x, y)
    local l = x
    local q = 0
    while l >= y do
        q = q + 1
        l = l - y
    end
    return q, l
end;
local MATH_OP = {
    -- the math operations
    {
        OP = "^",
        FUNC = function(x, y)
            return x ^ y
        end
    },
    {
        OP = "%",
        FUNC = function(x, y)
            return x % y
        end
    },
    {
        OP = "/",
        FUNC = (function(x, y)
            local q, r = modulo(x, y)
            local l = r * 10
            local tries = 12
            local t = 0
            local final = q .. "."
            if tries == 0 then
                return q
            end
            while l ~= 0 do
                local q_, r_ = modulo(l, y)
                l = (r_ * 10)
                final = final .. q_
                t = t + 1
                if r_ == 0 or t >= tries then
                    break
                end
            end
            if final:sub(#final) == "." then
                final = final .. "0"
            end
            return tonumber(final)
        end)
    },
    {
        OP = "*",
        FUNC = function(x, y)
            return x * y
        end
    },
    {
        OP = "-",
        FUNC = function(x, y)
            return x - y
        end
    },
    {
        OP = "+",
        FUNC = function(x, y)
            return x + y
        end
    },
}
local MATH_FUNC = {
    floor = math.floor,
    sqrt = math.sqrt,
    sin = math.sin,
    log = math.log,
    abs = math.abs,
}
local Module = {}
Module.Debug = {
    -- debug for play.
    AllowCoefficients = true, -- 1(5) or 1x xyz or abc
    AllowHexdecimal = true, -- 0x13213
    Enclosing = {"(", ")", "[", "]"}, -- Enclosing Characters;
    AllowLog = false, -- prints all of the log of the scripts functions
    AllowSigns = true, -- allows negative integers
    AllowMFuncs = true, -- allows math functions: floor, abs, sqrt
    FixEulerConstant = true, -- fixes the "euler constant"
    LoopLimit = nil, --the loop limit,leave it nil and it automatically choses it(can cause improper answers)
    Memoization = true, -- Allows Memoization(An optimization tool!)
    MemoFile = "Memo"
 -- This is the memo file(When nil increases performance)
}

local Memos = {}
Module.Memos = Memos
local function getfile(file)
   
    local re = io.open(file, "r")
    
    local contents
    contents = re:read("*all")
    local wr = io.open(file, "w+")
    wr:write(contents)
    wr:close();
    
    local lib
    local history = {contents}
    local function correct()
        lib.contents = contents
        lib.history = history
    end
    local function rewrite(arg)
        wr = io.open(file, "w+")
        wr:write(arg)
        wr:close()
        history[#history + 1] = arg
        contents = arg
        correct()
    end
    local function update()
        contents = re:read("*all")
        correct()
        return contents
    end
    local type = file:match("%..*")
    if (type) then
        ({function()
            end})[1]()
        type = type:sub(2)
    end
    lib = {
        filename = file,
        name = file,
        filetype = type,
        type = type,
        -- Properties --
        contents = contents,
        history = history,
        -- Methods --
        update = update,
        up = update,
        change = update,
        rewrite = rewrite,
        open = function()
            return re, wr
        end,
        correct = correct
    }
    return lib
end
local lib
if Module.Debug.MemoFile and Module.Debug.Memoization then
    lib = getfile(Module.Debug.MemoFile)
    Module.FileLib = lib
end
local function LoadMemoFile()
    if lib then
        lib.contents:gsub(
            "%b[]",
            function(c)
                local key = c:match('%b""'):sub(2, -2)
                local value = c:sub(({c:find('%b""')})[2] + 3, -3)
                Memos[key] = value
            end
        )
    end
end
local function SaveMemoFile()
    if not lib then
        return
    end
    local str = ""
    for i, v in next, Memos do
        local level = '["' .. i .. '"=(' .. tostring(v) .. ")]"
        str = str .. level
    end
    lib.rewrite(str)
    return str
end
local function AddToMemos(i, v)
    if not Module.Debug.Memoization then
        return
    end
    Memos[i] = v
    SaveMemoFile()
end
local function GetAnswerFromMemo(tokens)
    if not Module.Debug.Memoization then
        return
    end
    local concat = Module.Concatenate(tokens)
    return Memos[concat], concat
end
LoadMemoFile();

local function MakeCopy(tab) -- makes a copy of a table; useful.
    local tb = {}
    for i, v in pairs(tab) do
        tb[i] = v
    end
    return tb
end
local insert = function(tab, value)
    tab[#tab + 1] = value
end
local function WhileLoop(tab, func) -- like a for loop but faster(maybe?)
    local function Indexer(tab_)
        local c = {}
        for i, v in pairs(tab_) do
            insert(c, {index = i, value = v, i = i, v = v})
        end
        return c
    end
    local indexes = Indexer(tab)
    local index = 1
    while true do
        local book = indexes[index]
        if book then
            func(book.i, book.v)
        else
            break
        end
        index = index + 1
    end
end
local OP = {} -- I'm not making a function for this.
local FUNC = {}
WhileLoop(
    MATH_OP,
    function(i, v)
        OP[v.OP] = v -- the index is the math operation symbol, the value stays the same
    end
)
WhileLoop(
    MATH_FUNC,
    function(i, v)
        FUNC[i] = v
    end
)
Module.OP = OP -- For looking into, and to debug :)
Module.FUNC = FUNC -- For looking into, and to debug :)
Module.Lexer = function(str, variables, enclosing, extraenclosing) -- lexical analysis for numbers(see how annoying this is)
    local str =
        str:gsub("–", "-"):gsub("%s", ""):gsub(
        "%b||",
        function(c)
            return "abs(" .. c:sub(1, #c - 1):sub(2) .. ")"
        end
    )
    local tokens = {}
    local op, num1, num2 = 1, "", ""
    local enclosing = enclosing or {Module.Debug.Enclosing[1], Module.Debug.Enclosing[2]} -- primary enclosing aka parentheses
    local extraenclosing = extraenclosing or {Module.Debug.Enclosing[3], Module.Debug.Enclosing[4]} -- second enclosing aka brackets
    if variables and next(variables) then
        for i in next, variables do
            if (i ~= "nan") and (i ~= "inf") then -- nan and inf are good
                assert(tonumber(i) == nil, "a variables name cannot be integer nor number value!") -- make sure!
            end
        end
    end
    for i = 1, #str do -- this is all old code, but it still works very good.
        local c = str:sub(i, i)
        if
            not (rawget(Module.OP, c) or
                ((c == enclosing[1] or c == enclosing[2]) or (c == extraenclosing[1] or c == extraenclosing[2])))
         then
            if op == 1 then
                num1 = num1 .. c
                num2 = ""
            end
            if op == 2 then
                num2 = num2 .. c
                num1 = ""
            end
        elseif
            (rawget(Module.OP, c) or
                ((c == enclosing[1] or c == enclosing[2]) or (c == extraenclosing[1] or c == extraenclosing[2])) or
                c == "-") and
                (str:sub(i - 1, i - 1) ~= "e" and Module.Debug.FixEulerConstant)
         then
            if op == 2 then
                if (#num2:gsub("%s", "")) ~= 0 then
                    insert(tokens, num2)
                end
                num2 = ""
                op = 1
            else
                if (#num1:gsub("%s", "")) ~= 0 then
                    insert(tokens, num1)
                end
                op = 2
            end
            insert(tokens, c)
            num1 = ""
        end
        if i == #str then
            if op == 2 then
                insert(tokens, num2)
                num1 = ""
            end
            if op == 1 then
                insert(tokens, num1)
                num2 = ""
            end
        end
    end
    do -- The variable section
        for i, v in next, tokens do
            if variables and variables[v] then -- if the variable matches directly then revalue the token to the variables value
                tokens[i] = variables[v]
            elseif variables then
                local var = {} -- all of the variables found inside the token
                for variable in next, variables do
                    if tostring(v):find(variable) then
                        insert(var, variable)
                    end
                end
                if var then
                    local index = 1 -- for proper revaluing
                    local finished = v -- the finished value
                    for _, variable in next, var do
                        finished = finished:gsub(variable, "") -- remove the variable from the tokens value
                        local val = variables[variable]
                        insert(tokens, i + index, tonumber(val)) -- set the variable as a new token
                        index = index + 1
                    end
                    tokens[i] = finished -- the revalued token
                    if tonumber(finished) then
                        tokens[i] = tonumber(finished)
                    end
                end
            end
        end
    end
    Module.FixTokens(tokens)
    return tokens
end
local function GetLevel(symbol) -- What level is the math operation in?
    if symbol == "+" or symbol == "-" then
        return 1
    end
    if symbol == "*" or symbol == "/" then
        return 2
    end
    if symbol == "^" or symbol == "%" then -- FIXED
        return 3
    end
    return
end
Module.Concatenate = function(tokens) -- intergates all values into a single string
    local concat = ""
    for i, v in next, tokens do
        concat = concat .. v
    end
    return concat
end
Module.GetBrackets = function(tokens, enclosing, extraenclosing) -- gets brackets and parentheses data
    local brackets = {}
    local p = 0
    local bracketcurrent = {}
    local enclosing = enclosing or {Module.Debug.Enclosing[1], Module.Debug.Enclosing[2]} -- primary enclosing aka parentheses
    local extraenclosing = extraenclosing or {Module.Debug.Enclosing[3], Module.Debug.Enclosing[4]} -- second enclosing aka brackets

    for i, v in next, tokens do
        if enclosing and v == enclosing[1] then
            p = p + 1
            if p == 1 then
                bracketcurrent = {starti = i, tokens = {}}
            else
                insert(bracketcurrent.tokens, {index = i, value = v, i = i, v = v})
            end
        elseif enclosing and v == enclosing[2] then
            p = p - 1
            if p == 0 then
                bracketcurrent.endi = i
                insert(brackets, bracketcurrent)
                bracketcurrent = {}
            else
                insert(bracketcurrent.tokens, {index = i, value = v, i = i, v = v})
            end
        elseif extraenclosing and v == extraenclosing[1] then
            p = p + 1
            if p == 1 then
                bracketcurrent = {starti = i, tokens = {}}
            else
                insert(bracketcurrent.tokens, {index = i, value = v, i = i, v = v})
            end
        elseif extraenclosing and v == extraenclosing[2] then
            p = p - 1
            if p == 0 then
                bracketcurrent.endi = i
                insert(brackets, bracketcurrent)
                bracketcurrent = {}
            else
                insert(bracketcurrent.tokens, {index = i, value = v, i = i, v = v})
            end
        else
            if #tostring(v) > 0 and bracketcurrent.tokens then
                insert(bracketcurrent.tokens, {index = i, value = v, i = i, v = v})
            end
        end
    end
    return brackets
end
Module.CalucateFirstOp = function(tokenstab) -- Finds the most important operation and evaluates it automatically
    local tokens = MakeCopy(tokenstab)
    local function GetFirstOperation(tokenstab_)
        local glf, miop = nil, nil
        WhileLoop(
            tokenstab_,
            function(i, v)
                if rawget(Module.OP, v) and tonumber(v) == nil then
                    if (miop == nil and glf == nil) then
                        glf = GetLevel(v)
                        miop = {index = i, value = v, i = i, v = v}
                        if Module.Debug.AllowLog then
                            print("First operation found:" .. v)
                        end
                        glf = GetLevel(v)
                        miop = {index = i, value = v, i = i, v = v}
                    elseif glf < GetLevel(v) then
                        glf = GetLevel(v)
                        miop = {index = i, value = v, i = i, v = v}
                        if Module.Debug.AllowLog then
                            print("New operation found:" .. v)
                        end
                    end
                end
            end
        )
        if glf and miop then
            local x = tonumber(tokenstab_[miop.i - 1])
            local y = tonumber(tokenstab_[miop.i + 1])
            if Module.Debug.AllowLog and x and y then
                print(x .. miop.value .. y)
            end
            return x, y, miop
        end
        return
    end
    local x, y, miop = GetFirstOperation(tokens)
    if x and y and miop then
        local FUNC_ = OP[miop.v].FUNC
        local result = FUNC_(x, y)
        tokens[miop.i] = result -- sets answer
        table.remove(tokens, miop.i - 1) -- removes x
        table.remove(tokens, miop.i) -- removes y
    else
        assert(x ~= nil, "x is nil, cannot do operation")
        assert(y ~= nil, "y is nil, cannot do operation")
        assert(miop ~= nil, "op is nil, cannot do operation")
    end
    return tokens
end
Module.GetEvaluation = function(tokens) -- bootleg evaluation.
    local result = tokens
    local loops = -1
    if #tokens == 0 then
        return error("No tokens cannot get estimate!", 2)
    elseif #tokens == 1 then
        return tonumber(result[1])
    end
    while (#result ~= 1) and (loops < (Module.Debug.LoopLimit or (#tokens * 2))) do -- WATCH OUT FOR THIS
        loops = loops + 1
        if Module.Debug.AllowLog then
            print("Phase")
        end
        result = Module.CalucateFirstOp(result)
    end
    return tonumber(result[1])
end
Module.SetBrackets = function(tokenstab) -- Converts the brackets and parentheses into a single number for better results
    local tokens = MakeCopy(tokenstab)
    local brackets = Module.GetBrackets(tokens)
    local bracketsadd = {}
    local tabs = {}
    for i, v in next, brackets do
        bracketsadd[v.starti] = v
    end
    local function FindFirstBracket(index) -- if the index is in brackets or parentheses, it will show want bracket(or parentheses) it is in
        local bracketindex = nil
        for i, v in next, bracketsadd do
            if v.starti <= index and v.endi >= index then
                bracketindex = i
                break
            end
        end
        return bracketindex
    end
    local function GetTokenValues(tokenstab) -- gets the absolute value for tokens
        local tabs = {}
        for i, v in next, tokenstab do
            if v.value then
                insert(tabs, v.value) -- some tokens use value and index for better anaylsis
            else
                insert(tabs, v)
            end
        end
        return tabs
    end
    for i, v in next, tokens do
        if bracketsadd[i] then
            local tokenstabbs = (GetTokenValues(bracketsadd[i].tokens))
            local res = Module.Evaluate(tokenstabbs) -- you don't need more
            insert(tabs, res)
        elseif not FindFirstBracket(i) then
            insert(tabs, v)
        end
    end
    Module.FixTokens(tabs)
    return tabs
end
Module.FixCoefficients = function(tokenstab) -- for the "multiplication thign": 1(5) 1x
    local tokens = MakeCopy(tokenstab)
    local tab = {}
    for i, v in next, tokens do
        local v2 = tokens[i + 1]
        local v3 = tokens[i - 1]
        local bool = tonumber(v) ~= nil and tonumber(v2) ~= nil
        local bool2 = tonumber(v) ~= nil and tonumber(v3) ~= nil
        insert(tab, v)
        if bool and Module.Debug.AllowCoefficients then
            if Module.Debug.AllowLog then
                print("Coefficient Found!")
            end
            if i ~= #tokens then
                insert(tab, "*")
            end
        elseif not Module.Debug.AllowCoefficients and bool then
            error("There cannot be any coefficients!")
        elseif not Module.Debug.AllowCoefficients and bool2 then
            error("There cannot be any coefficients!")
        end
    end
    Module.FixTokens(tab)
    return tab
end
Module.FixSigns = function(tokenstab) -- for the "multiplication thign": 1(5) 1x
    local tokens = MakeCopy(tokenstab)
    local tab = {}
    for i, v in next, tokens do
        local v2 = tokens[i + 1]
        local v3 = tokens[i - 1]
        local v4 = tokens[i - 2]
        local bool = v3 == "-" and tonumber(v) ~= nil and (tonumber(v4) == nil)
        local bool2 = v == "-" and tonumber(v2) ~= nil
        local bool3 = v == "-" and tonumber(v2) ~= nil and tonumber(v3) ~= nil
        if bool and Module.Debug.AllowSigns then
            if Module.Debug.AllowLog then
                print("Negative integer Found!")
            end
            insert(tab, -(v))
        elseif not Module.Debug.AllowSigns and bool and not bool3 then
            error("There cannot be any negative integers!")
        elseif (not bool2) and (not bool) then
            insert(tab, v)
        elseif (bool3) then
            insert(tab, v)
        end
    end
    Module.FixTokens(tab)
    return tab
end
Module.GetFuncs = function(tokenstab) -- for special operators
    local tokens = MakeCopy(tokenstab)
    local tab = {}
    local FUNC = Module.FUNC
    for i, v in next, tokens do
        local v2 = tokens[i + 1]
        local v3 = tokens[i - 1]
        local bool = (FUNC[v] ~= nil) and tonumber(v2) ~= nil
        local bool2 = (FUNC[v3] ~= nil) and tonumber(v) ~= nil
        if bool and Module.Debug.AllowMFuncs then
            if Module.Debug.AllowLog then
                print("Math function found!")
            end
            insert(tab, FUNC[v](v2))
        elseif not Module.Debug.AllowMFuncs and bool then
            error("There cannot be any math functions!")
        elseif (not bool2) and (not bool) then
            insert(tab, v)
        end
    end
    Module.FixTokens(tab)
    return tab
end
Module.HexTokens = function(tokens) -- for hexdecimal
    local tabs = {}
    if not Module.Debug.AllowHexdecimal then
        return tokens
    end
    for i, v in next, tokens do
        if tostring(v):sub(1, 2) == "0x" then
            if tonumber(v, 16) then
                tabs[i] = tonumber(v, 16)
                if Module.Debug.AllowLog then
                    print("Found Hexdecimal:" .. v .. "Converted: " .. tonumber(v, 16))
                end
            else
                tabs[i] = v
            end
        else
            tabs[i] = v
        end
    end
    return Module.FixTokens(tabs)
end
Module.FixTokens = function(tokens) -- fixes the tokens for no errors
    local tabs = {}
    for i, v in next, tokens do
        if #tostring(v):gsub("%s", "") == 0 then
            table.remove(tokens, i)
        else
            insert(tabs, v)
        end
    end
    return tabs
end
Module.GetCheckSymbol = function(tokens)
    local tabs = {}
    local patt = "[-]?%d+[.]?%d*" -- the pattern to find a number value, negative or postive
    for i, v in next, tokens do
        if v == "√" then
            insert(tabs, "sqrt")
        elseif type(v) == "string" and v:sub(1, 1):byte() == 226 then
            local number = tonumber(v:match(patt))
            if number then
                insert(tabs, "sqrt")
                insert(tabs, number)
            end
        else
            insert(tabs, v)
        end
    end
    return Module.FixTokens(tabs)
end
Module.GetFinishedTokens = function(tokenstab)
    local tokens = tokenstab
    local brackettok = Module.SetBrackets(tokens)
    local hex = Module.HexTokens(brackettok)
    local check = Module.GetCheckSymbol(hex)
    local mult = Module.FixCoefficients(check)
    local sign = Module.FixSigns(mult)
    local func = Module.GetFuncs(sign)
    return Module.FixTokens(func)
end

Module.Evaluate = function(tokenstab) -- the final function for the absolute result
    if #tokenstab == 1 then
        return tonumber(tokenstab[1])
    end
    local memoans, concat = GetAnswerFromMemo(tokenstab)
    if memoans then
        if Module.Debug.AllowLog then
            print("GOT MEMO ANSWER")
        end
        AddToMemos(concat, memoans)
        return memoans
    end
    local concat = Module.Concatenate(tokenstab)
    local tokens = Module.GetFinishedTokens(tokenstab)
    local result = Module.GetEvaluation(tokens)
    if Module.Debug.AllowLog then
        print(result)
    end
    AddToMemos(concat, result)
    return result
end
return Module
