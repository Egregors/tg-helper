-- Snippet to control linux-computer over Telegram
-- @egregros (2015)

started = 0
our_id = 0

-- CONFIG
-- **************************
-- Path to dir with this file

-- For Raspberry Pi
--PATH = '/home/pi/tg/_custom'
-- For Docker
PATH = '/home/tg/_custom'

PREFIX = 'Node_Name ' -- Name of instance
-- **************************

function check_vpn ()
    os.execute("rm " .. PATH .. "/ip.txt")
    os.execute("sudo ifconfig > " .. PATH .. "/ip.txt")

    local ip_is_found = false
    local res = nil
    local ip = nil

    for line in io.lines(PATH .. "/ip.txt") do
        if ip_is_found then
            res = line
            ip_is_found = false
            _, ip_idx_begin = string.find(res, 'addr:')
            ip_idx_end = string.find(res, 'P')
            ip = 'ssh pi@' .. string.sub(res, ip_idx_begin+1, ip_idx_end-1)
        end
        if string.find(line, 'tun') then
            ip_is_found = true
        end 
    end

    return ip
end

function read_file (file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

function on_msg_receive (msg)
    if msg.out then
        return
    end

-- HELP
    if (msg.text==PREFIX .. 'help' or msg.text==PREFIX .. '!') then
        -- List of supported commands. Put description in ./help.txt
        local help = read_file(PATH .. "/help.txt")
        send_msg (msg.from.print_name, help, ok_cb, false)
        
    end
-- VPN
    if (msg.text==PREFIX .. 'vpn') then
        -- Start VPN connection (~30-50 sec)
        res = check_vpn()
        if res then
            send_msg (msg.from.print_name, 'VPN is ON ...', ok_cb, false)
            send_msg (msg.from.print_name, res, ok_cb, false)
        else
            os.execute("sudo -s screen openvpn --daemon --config " .. PATH .. "/conf.ovpn")
            send_msg (msg.from.print_name, 'VPN -> ON ...', ok_cb, false)
        end
    end
-- STOP
    if (msg.text==PREFIX .. 'stop') then
        -- Stop VPN
        if os.execute("sudo killall openvpn") then
            send_msg (msg.from.print_name, "VPN -> OFF ...", ok_cb, false)
        else
            send_msg (msg.from.print_name, "VPN is OFF", ok_cb, false)
        end
    end  
-- IP
    if (msg.text==PREFIX .. 'ip') then
        -- Send current internal IP in VPN network
        res = check_vpn()
        if res then
            send_msg (msg.from.print_name, res, ok_cb, false)
        else
            send_msg (msg.from.print_name, 'Looks like VPN is down', ok_cb, false)
        end
        return
    end
end

function ok_cb (extra, success, result)
end

function on_our_id (id)
    our_id = id
end

function on_user_update (user, what)
  --vardump (user)
end

function on_chat_update (chat, what)
  --vardump (chat)
end

function on_secret_chat_update (schat, what)
  --vardump (schat)
end

function on_get_difference_end ()
end

function cron ()
    -- do something
    postpone (cron, false, 1.0)
end

function on_binlog_replay_end ()
    started = 1
    postpone (cron, false, 1.0)
end
