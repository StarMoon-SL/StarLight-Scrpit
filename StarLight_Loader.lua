local API_KEY     = "253d91ff-9ec1-4701-8056-f643b6ce8092"   -- 你的 API
local SERVER_NAME = "StarLight"                             -- 服务器名
local PROVIDER    = "StarLight"                             -- provider
local MAIN_SCRIPT = "https://raw.githubusercontent.com/Zer0neK/SB-Xi-pro/refs/heads/main/SBXiPro.lua"
-----------------------------------------------------------------

local HttpService = game and game:GetService("HttpService") or {
    JSONEncode   = function(_,t) return json.encode(t) end,
    JSONDecode   = function(_,s) return json.decode(s) end
}

local TODAY = os.date("%Y-%m-%d")
local ENV   = getfenv()

-- 简单的日级缓存
if ENV._StarLightVerified == TODAY then
    print("✅ 今日已验证，直接加载主脚本")
    return loadstring(request({Url = MAIN_SCRIPT}).Body)()
end

local FAIL_COUNT = 0
local MAX_FAIL   = 3

-- 统一 POST 请求封装
local function post(url, data)
    local body = HttpService:JSONEncode(data)
    local res  = request({
        Url     = url,
        Method  = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["User-Agent"]   = "StarLight-AutoKey/1.2"
        },
        Body    = body
    })
    if res and res.Success and res.Body then
        return HttpService:JSONDecode(res.Body)
    end
    return nil
end

-- 主循环：申请 -> 验证 -> 加载
while FAIL_COUNT < MAX_FAIL do
    print("🔄 正在向 StarLight 申请密钥 ...")

    local resp = post("https://junkie-development.de/get-key/starlight", {
        api      = API_KEY,
        server   = SERVER_NAME,
        provider = PROVIDER
    })

    if resp and resp.key then
        local key = resp.key
        print("✅ 拿到密钥："..key)

        -- 再次回传校验（部分套餐需要二次确认）
        local chk = post("https://junkie-development.de/verify-key/starlight", {
            api = API_KEY,
            key = key
        })

        if chk and chk.valid == true then
            print("✅ 校验通过！开始加载主脚本 ...")
            ENV._StarLightVerified = TODAY                -- 写缓存
            return loadstring(request({Url = MAIN_SCRIPT}).Body)()
        end
    end

    FAIL_COUNT = FAIL_COUNT + 1
    print("❌ 密钥无效或网络异常，"..(MAX_FAIL - FAIL_COUNT).." 次后退出")
    wait(2)
end

print("❌ 连续 "..MAX_FAIL.." 次失败，脚本终止")