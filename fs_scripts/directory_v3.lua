-- get user and domain from freeswitch requests
local user = params:getHeader("user")
local domain = params:getHeader("domain")

xml_result =[[
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <document type="freeswitch/xml">
      <section name="result">
        <result status="not found" />
      </section>
    </document>
    ]]

function sip_account(domain, user, password, toll_allow, max_calls, context, caller_name, caller_number, ob_caller_name, ob_caller_number)
    account = [[
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <document type="freeswitch/xml">
    <section name="directory">
    <domain name="]] .. domain .. [[">
        <params>
        <param name="dial-string" value="{^^:sip_invite_domain=${dialed_domain}:presence_id=${dialed_user}@${dialed_domain}}${sofia_contact(*/${dialed_user}@${dialed_domain})},${verto_contact(${dialed_user}@${dialed_domain})}"/>
        <param name="jsonrpc-allowed-methods" value="verto"/>
        <param name="jsonrpc-allowed-event-channels" value="demo,conference,presence"/>
        </params>
        <groups>
        <group name="default">
        <users>
            <user id="]] .. user .. [[">
            <params>
            <param name="a1-hash" value="]] .. password .. [["/>
            </params>
            <variables>
            <variable name="toll_allow" value="]] .. toll_allow .. [["/>
            <variable name="calls_max" value="]] .. max_calls .. [["/>
            <variable name="accountcode" value="]] .. user .. [["/>
            <variable name="user_context" value="]] .. context .. [["/>
            <variable name="effective_caller_id_name" value="]] .. caller_name .. [["/>
            <variable name="effective_caller_id_number" value="]] .. caller_number .. [["/>
            <variable name="outbound_caller_id_name" value="]] .. ob_caller_name .. [["/>
            <variable name="outbound_caller_id_number" value="]] .. ob_caller_number .. [["/>
            <variable name="callgroup" value="techsupport"/>
            </variables>
            </user>
        </users>
        </group>
        </groups>
    </domain>
    </section>
    </document>
    ]]
    return account
end

if not user then
    XML_STRING = xml_result
else
    local key = user .. "_" .. domain
    -- create redis connection
    local redis = require 'redis'
    local client = redis.connect('127.0.0.1', 6379)
    local record = client:get(key)

    if record == nil then
        -- query command 
        local my_query = "SELECT * FROM sip_accounts WHERE username = '" .. user .. "' and domain = '" .. domain .."'"
        freeswitch.consoleLog("INFO","value is \t" .. my_query .. "\n") 

        -- create Postgres DB connection
        --local dbh = freeswitch.Dbh("pgsql://hostaddr=127.0.0.1 dbname=freeswitch user=freeswitch password=password options='-c client_min_messages=NOTICE' application_name='freeswitch'")

        -- create SQL lite DB connection
        local dbh = freeswitch.Dbh("sqlite:///home/hadn/freeswitch_flask_gui/app.db")

        -- exits the script if we didn't connect
        assert(dbh:connected())

        dbh:query(my_query, function(row)
            xml_result = sip_account(domain, user, row.password, row.toll_allow, row.max_calls, row.context, row.caller_name, row.caller_number, row.outbound_caller_name, row.outbound_caller_number)

            -- set expire time for key "foo" about 3 minute
            client:setex(key, 3*60, xml_result)
        end)

        --optional
        dbh:release()
    else
        xml_result = record
    end
    -- redis close connection
    client:quit()

    XML_STRING = xml_result
    freeswitch.consoleLog("INFO","value is \t" .. XML_STRING .. "\n")
end

