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
            if not (type(k)=="number" and k%1==0) then
                res[k] = v
            end
        end
    end
  
    return res
end

function isTable(tbl)
	return type(tbl) == "table"
end
