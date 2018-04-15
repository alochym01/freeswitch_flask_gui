-- https://freeswitch.org/confluence/display/FREESWITCH/Lua+with+Database#LuawithDatabase-freeswitch.dbh
-- create Postgres DB connection
-- local dbh = freeswitch.Dbh("pgsql://hostaddr=127.0.0.1 dbname=freeswitch user=freeswitch password=password options='-c client_min_messages=NOTICE' application_name='freeswitch'")
-- If connected is continue
-- assert(dbh:connected())

-- create redis connection
-- local redis = require 'redis'
-- local client = redis.connect('127.0.0.1', 6379)

-- using freeswitch dbh and lua-redis to generated sip user directory
-- get user and domain from freeswitch requests
local user = params:getHeader("user")
local domain = params:getHeader("domain")

if not user then
    XML_STRING =[[
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <document type="freeswitch/xml">
      <section name="result">
        <result status="not found" />
      </section>
    </document>
    ]]
else
    -- create redis connection
    local redis = require 'redis'
    local client = redis.connect('127.0.0.1', 6379)
    local record = client:get(user)
    if record == nil then
        -- create Postgres DB connection
        local dbh = freeswitch.Dbh("pgsql://hostaddr=127.0.0.1 dbname=freeswitch user=freeswitch password=password options='-c client_min_messages=NOTICE' application_name='freeswitch'")
        -- exits the script if we didn't connect
        assert(dbh:connected())

        -- query data from postgres
        local sql_query = "SELECT * FROM sipaccs WHERE username = " .. user
        dbh:query(sql_query, function(row) end)
        --dbh:query("SELECT displayname, company FROM names WHERE number='" .. cidnum_e164 .. "'", function(row)
        --        name = row.displayname
        --        return 1
        --end)

        -- assign row value to record variable
        record = row
        -- using redis to store record
        client:set(user, record)
        -- redis close connection
    end
    client:quit()
    XML_STRING = [[
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <document type="freeswitch/xml">
            <section name="directory">
                <domain name="]] .. domain .. [[">
                    <params>
                        <param name="dial-string" value="{presence_id=${dialed_user}@${dialed_domain}}${sofia_contact(${dialed_user}@${dialed_domain})}" />
                    </params>
                    <groups>
                        <group name="default">
                            <users>
                                <user id="]] .. user .. [[">
                                    <params>
                                        <param name="password" value="12345" />
                                        <!--<param name="a1-hash" value="{{ password }}" />-->
                                    </params>
                                    <variables>
                                        <!-- using for restricted call -->
                                        <variable name="toll_allow" value="domestic,international,local" />
                                        <!-- using for restricted call -->
                                        <variable name="calls_max" value="1" />
                                        <!-- using for accounting -->
                                        <!-- <variable name="accountcode" value="{{ user }}" /> -->
                                        <!-- using dial plan -->
                                        <variable name="user_context" value="default" />
                                        <!-- using for call name -->
                                        <!-- <variable name="effective_caller_id_name" value="Extension {{ user }}" /> -->
                                        <!-- using for caller number -->
                                        <!-- <variable name="effective_caller_id_number" value="{{ user }}" />-->
                                        <!-- using for call name who make call out PSTN -->
                                        <!-- <variable name="outbound_caller_id_name" value="$${outbound_caller_name}" />-->
                                        <!-- using for call number who make call out PSTN -->
                                        <!-- <variable name="outbound_caller_id_number" value="$${outbound_caller_id}" />-->
                                        <!-- <variable name="callgroup" value="techsupport" /> -->
                                    </variables>
                                </user>
                            </users>
                        </group>
                    </groups>
                </domain>
            </section>
        </document>
    ]]
    freeswitch.consoleLog("INFO","value is \t" .. XML_STRING .. "\n")
end