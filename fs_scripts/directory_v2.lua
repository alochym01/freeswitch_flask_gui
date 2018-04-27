-- get user and domain from freeswitch requests
local user = params:getHeader("user")
local domain = params:getHeader("domain")

return_string =[[
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <document type="freeswitch/xml">
      <section name="result">
        <result status="not found" />
      </section>
    </document>
    ]]
if not user then
    XML_STRING = return_string
else
    local key = user .. domain
    -- create redis connection
    local redis = require 'redis'
    local client = redis.connect('127.0.0.1', 6379)
    local record = client:get(key)
    if record == nil then
        -- create Postgres DB connection
        local dbh = freeswitch.Dbh("pgsql://hostaddr=127.0.0.1 dbname=freeswitch user=freeswitch password=password options='-c client_min_messages=NOTICE' application_name='freeswitch'")
        -- exits the script if we didn't connect
        assert(dbh:connected())

        -- query data from postgres
        -- dbh:query("SELECT * FROM sip_accounts WHERE username = '" .. user .. "'", function(row)
        dbh:query("SELECT * FROM sip_accounts WHERE username = '" .. user .. "' and domain = '" .. domain .."'", function(row)
            return_string = [[
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <document type="freeswitch/xml">
                <section name="directory">
                <domain name="]] .. domain .. [[">
                    <params>
                    <param name="dial-string" value="{presence_id=${dialed_user}@${dialed_domain}}${sofia_contact(${dialed_user}@${dialed_domain})}"/>
                    </params>
                    <groups>
                    <group name="default">
                        <users>
                        <user id="]] .. user .. [[">
                            <params>
                                <param name="a1-hash" value="]] .. row.password .. [["/>
                            </params>
                            <variables>
                                <variable name="toll_allow" value="]] .. row.toll_allow .. [["/>
                                <variable name="calls_max" value="]] .. row.max_calls .. [["/>
                                <variable name="accountcode" value="]] .. user .. [["/>
                                <variable name="user_context" value="]] .. row.context .. [["/>
                                <variable name="effective_caller_id_name" value="]] .. row.caller_name .. [["/>
                                <variable name="effective_caller_id_number" value="]] .. row.caller_number .. [["/>
                                <variable name="outbound_caller_id_name" value="]] .. row.outbound_caller_name .. [["/>
                                <variable name="outbound_caller_id_number" value="]] .. row.outbound_caller_number .. [["/>
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
            -- using redis to store record
            client:set(key, return_string)
        end)
    else
        return_string = record
    end
    -- redis close connection
    client:quit()
    XML_STRING = return_string
    freeswitch.consoleLog("INFO","value is \t" .. XML_STRING .. "\n")
end