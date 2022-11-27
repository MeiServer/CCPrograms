--name: tables
--author: niko__25
--version: 0.1

function empty(tbl)
	if tbl == nil then return true end
	return not next(tbl)
end

function elemn(tbl)
	local n = 0
	for _ in pairs(tbl) do
		n = n + 1
	end
	return n
end

function in_key(tbl, key)
	for k, v in pairs(tbl) do
		if k == key then return true end
	end
	return false
end

function in_value(tbl, val)
	for k, v in pairs(tbl) do
		if v == val then return true end
	end
	return false
end

function keys(tbl)
	local u = {}
	for i, v in pairs(tbl) do
		table.insert(u, i)
	end
	return u
end

function values(tbl)
	local u = {}
	for i, v in pairs(tbl) do
		table.insert(u, v)
	end
	return u
end

function removeKey(tbl, key)
	for k, v in pairs(tbl) do
		if k == key then
			tbl[key] = nil
		end
	end
end

function removeValue(tbl, value)
	for k, v in pairs(tbl) do
		if v == value then
			tbl[k] = nil
		end
	end
end

function map(tbl, func)
	local ret_tbl = {}
	for k, v in pairs(tbl) do
		ret_tbl[k] = func(k, v)
	end
	return ret_tbl
end

function filter(tbl, func)
    local res = {}
    for i, v in ipairs(tbl) do
        if func(i, v) then
            res[1+#res] = v
        end
    end
  
    for k, v in pairs(tbl) do
        if func(k, v) then
            if not (type(k) == "number" and k % 1 == 0) then
                res[k] = v
            end
        end
    end
  
    return res
end

function keySort(tbl)
	local tkeys = {}
	for k in pairs(tbl) do
		table.insert(tkeys, k)
	end
	table.sort(tkeys)
	local t = {}
	for _, k in ipairs(tkeys) do
		t[k] = tbl[k]
	end
	return t
end

function tableSort(tbl)  
	local sortkey = {}
	local n = 0
	for k ,v in pairs(tbl) do
		n = n + 1
		sortkey[n] = k
	end
	table.sort(sortkey,function(a,b)
		return tonumber(a) < tonumber(b)
	end)
	return sortkey
end

function argsIntoTable(...)
	local t = {...}
	local s = ""
	local isValue = false
	for i, v in ipairs(t) do
		if v == "=" then
			isValue = true
		elseif string.find(v, "[.{]") or string.find(v, "[.,]")then
			isValue = false
		end
		if isValue then
			if not string.find(v, "[.=]") then
				v = "\""..v.."\""
			end
		end
		s = s..v
	end
	return textutils.unserialize(s)
end

function overwrite(tbl, tbl2)
	if isTable(tbl) and isTable(tbl2) then
		for k, v in pairs(tbl2) do
			tbl[k] = v
		end
	end
end
	
function isTable(tbl)
	return type(tbl) == "table"
end

function printTable(table)
	if table then
		for k, v in pairs(table) do
			print(string.format("Key: %s, Value: %s", tostring(k), tostring(v)))
			if type(v) == "table" then
				printTable(v)
			end
		end
	else
		print("This table is empty")
	end
end