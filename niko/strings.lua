--- 文字列を指定した文字で区切り、テーブルに収納して返す
---@param str string
---@param ts string
function split(str, ts)

        if isString(str) then

        if ts == nil then return {} end
        local t = {} ; 
        local i = 1

        for s in string.gmatch(str, "([^"..ts.."]+)") do
            t[i] = s
            i = i + 1
        end
  
        return t
    end

    err(str .. " is not String!")
end

--- 引数が文字列の場合'true'を、それ以外は'false'を返す
---@param str string
function isString(str)
    return type(str) == "string"
end
