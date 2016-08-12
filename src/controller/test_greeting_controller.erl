-module(test_greeting_controller, [Req]).
-compile(export_all).

index('GET', []) ->
    SavedGreetings = boss_db:find(greeting, []),
    FirstGreeting = hd(SavedGreetings),
    {output, FirstGreeting:greeting_text()}.

login('GET', []) ->
    {ok, [{redirect, Req:header(referer)}]};

    login('POST', []) ->
    Name = Req:post_param("name"),
    case boss_db:find(ward_boss, [{name, Name}], [{limit,1}]) of
        [WardBoss] ->
            case WardBoss:check_password(Req:post_param("password")) of
                true ->
                    {redirect, proplists:get_value("redirect",
                        Req:post_params(), "/"), WardBoss:login_cookies()};
                false ->
                    {ok, [{error, "Bad name/password combination"}]}
            end;
        [] ->
            {ok, [{error, "No Ward Boss named " ++ Name}]}
    end.


hello('GET', []) ->
 {ok, [{greeting, "Hello, world!"}]}.

list('GET', []) ->
 Greetings = boss_db:find(greeting, []),
 {ok, [{greetings, Greetings}]}.

create('GET', []) ->
 ok;

create('POST', []) ->
 	GreetingText = Req:post_param("greeting_text"),
 	NewGreeting = greeting:new(id, GreetingText),
 	case NewGreeting:save() of
 		{ok, SavedGreeting} ->
 			{redirect, [{action, "list"}]};
 		{error, ErrorList} ->
 			{ok, [{errors, ErrorList}, {new_msg, NewGreeting}]}
 	end.

 goodbye('POST', []) ->
  boss_db:delete(Req:post_param("greeting_id")),
 {redirect, [{action, "list"}]}.

 send_test_message('GET', []) ->
 TestMessage = "Free at last!",
 boss_mq:push("test-channel", TestMessage),
 {output, TestMessage}.

 pull('GET', [LastTimestamp]) ->
 {ok, Timestamp, Greetings} = boss_mq:pull("new-greetings",
 list_to_integer(LastTimestamp)),
 {json, [{timestamp, Timestamp}, {greetings, Greetings}]}.

 live('GET', []) ->
 Greetings = boss_db:find(greeting, []),
 Timestamp = boss_mq:now("new-greetings"),
 {ok, [{greetings, Greetings}, {timestamp, Timestamp}]}.
 