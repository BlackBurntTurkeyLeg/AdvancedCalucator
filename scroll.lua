local scrollup = "\27\91\66"
local scrolldown = "\27\91\65"

local function circle(x,y,diag)
    if x == 0 then
        x = y;
    elseif math.abs(x) ~= x then
        return circle(y+x,y)
    end
    local f = math.max((x%(y+1)),1)
    if diag then
        print(x,y,f)
    end
    return f
end
local function promptselectmenu(title, ...)
    local args = {...}
    if next(args) then
        if type(args[1]) == "table" then
            menu = args[1]
        else
            menu = args
        end
        local indextable = {}
        local selectable = {}
        for i, v in next, menu do
            table.insert(indextable, i)
        end
        local index = 1
        while true do
            os.execute("clear")
            print(title .. "\n")
            for i, v in next, indextable do
                if i == index then
                    print("	" .. menu[v] .. " <--")
                else
                    print("	" .. menu[v])
                end
            end
            local scroll = io.read()
            if scroll == scrolldown then
                index = circle(index - 1, #indextable)
            elseif scroll == "w" then
                index = circle(index - 1, #indextable)
            elseif scroll == scrollup then
                index = circle(index + 1, #indextable)
            elseif scroll == "s" then
                index = circle(index + 1, #indextable)
            elseif scroll == "" then
                return indextable[index]
            end
        end
    end
end
local function promptstrictmenu(title, ...)
    local args = {...}
    if next(args) then
        if type(args[1]) == "table" then
            menu = args[1]
        else
            menu = args
        end
        local indextable = {}
        local selectable = {}
        for i, v in next, menu do
            table.insert(indextable, i)
        end
        local index = 1
        while true do
            os.execute("clear")
            print(title .. "\n")
            for i, v in next, indextable do
                if i == index then
                    print("	" .. menu[v] .. " <--")
                else
                    print("	" .. menu[v])
                end
            end
            local scroll = io.read()
            if scroll == scrolldown then
                index = circle(index - 1, #indextable)
            elseif scroll == "w" then
                index = circle(index - 1, #indextable)
            elseif scroll == scrollup then
                index = circle(index + 1, #indextable)
            elseif scroll == "s" then
                index = circle(index + 1, #indextable)
            elseif scroll == "" then
                os.execute("clear")
                print("Are you sure you want to select the following ["..tostring(menu[indextable[index]]).."]?")
                io.write("Yes or No: ")
                local y = io.read():sub(1,1):lower()=="y"
                if y then
                    os.execute("clear")
                    return indextable[index]
                end
            end
        end
    end
end
return {pm = promptselectmenu,PromptMenu = promptselectmenu, PromptSelectMenu = promptselectmenu, PromptStrictMenu = promptstrictmenu,psm = promptstrictmenu}
