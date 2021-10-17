function fread(fname)
	local file = io.open(fname, "r");
	local ret  = "";
	local line;
	io.input(file);
	repeat
		line = io.read();
		ret  = ret .. line;
	until line ~= nil;
	io.close();
	return ret;
end

function fexists(fname)
	local f = io.open(fname,"r");
	if f ~= nil then io.close(f) return true else return false end;
end

function rfind(buf, find)
	if buf:find("/") ~= nul then
		return (#buf - buf:reverse():find(find))+2;
	else
		return 1;
	end
end

function scandir(directory)
    local i, t, popen = 0, {}, io.popen;
    local pfile = popen('ls -a "'..directory..'"');
    for filename in pfile:lines() do
        i = i + 1;
        t[i] = filename;
    end
    pfile:close();
    return t;
end

-- my discord bot --
-- Combot --
local discordia = require("discordia");
local md5       = require("md5");
local http      = require("http");
local info      = require("./info.lua");
local client    = discordia.Client();


function command(message, cmd)
	if (message.content:sub(1, #cmd) == cmd) then return true end;
	return false;
end;

client:on("ready", function()
	print("Logged in as ".. client.user.username);
	client:getChannel(info.syschan):send("Bot ready\nRunning on " .. client.user.tag);
	client:setGame("on " .. #client.guilds .. " servers");
end)

client:on("messageCreate", function(message)
	if message.author.bot then return end;

	if message.content:sub(1, #info.prefix) == info.prefix then
		print("[COMMAND] " .. message.author.name .. " executed " .. message.content);
		client:setGame("on " .. #client.guilds .. " servers");
	end

	if command(message, "com help") then
		message.channel:send { embed = {
			title = "**ComBot help**",
			fields = {
				{name="Info", value="**Prefix**: " .. info.prefix},
				{name="Commands", value="help, id, pfp, md5, sinfo, bot, 8ball, img, search"}
			},
			timestamp = discordia.Date():toISO('T', 'Z'),
			color = discordia.Color.fromRGB(0,255,0).value
		}};
		message:addReaction("👍");
	end

	if command(message, "com id") then
		if message.mentionedUsers.first == nil then
			message.channel:send("your id is " .. message.author.id);
		else
			if #message.mentionedUsers > 15 then
				message.channel.send("don't spam!");
				return 0;
			end
			send = "";
			for user in message.mentionedUsers:iter() do
				send = send .. user.name .. "'s id is " .. user.id .. "\n";
			end
			message.channel:send(send);
		end
	end
	if command(message, "com pfp") then
		if message.mentionedUsers.first == nil then
			message.channel:send(message.author.avatarURL);
		else
			if #message.mentionedUsers > 3 then
				message.channel:send("don't spam!");
				return 0;
			end
			send = "";
			for user in message.mentionedUsers:iter() do
				send = send .. user.name .. ": " .. user.avatarURL .. "\n";
			end
			message.channel:send(send);
		end
	end
	if command(message, "com md5") then
		hash = md5.sumhexa(message.content:sub(#"com md5 "));
		message.channel:send("Output: " .. hash)
	end
	if command(message, "com sinfo") then
		send = "**" .. message.guild.name .. "** info";
		send = send .. "\n**Members**: " .. message.guild.totalMemberCount;
		if message.guild.owner ~= nil then
			send = send .. "\n**Owner**: " .. message.guild.owner.tag; 
		end
		if message.guild.iconURL ~= nil then
			send = send .. "\n**Icon**: " .. message.guild.iconURL;
		end
		if message.guild.bannerURL ~= nil then
			send = send .. "\n**Banner**: " .. message.guild.bannerURL;
		end
		if message.guild.splashURL ~= nil then
			send = send .. "\n**Splash*: " .. message.guild.slashURL;
		end
		send = send .. "\n**Region**: " .. message.guild.region;
		if message.guild.vanityCode ~= nil then
			send = send .. "\n**Vanity code**: " .. message.guild.vanityCode;
		end
		send = send .. "\n**Text channels**: " .. #message.guild.textChannels;
		send = send .. "\n**Voice channels**: " .. #message.guild.voiceChannels;
		send = send .. "\n**Roles**: " .. #message.guild.roles;
		if message.guild:getBans() ~= nil then send = send .. "\n**Bans**: " .. #message.guild:getBans(); end
		message.channel:send(send);
	end;
	if command(message, "com bot") then
		message.channel:send{
			embed = {
				title = client.user.name,
				fields = {
					{name="Servers", value=#client.guilds}
				},
				timestamp = discordia.Date():toISO('T', 'Z'),
				color = discordia.Color.fromRGB(0,255,0).value
			}
		};
	end
	if command(message, "com 8ball") then
		local responses = {};
		responses[0] = "it is certain";
		responses[1] = "it is decidedly so";
		responses[2] = "without a doubt";
		responses[3] = "yes definitely";
		responses[4] = "you may rely on it";
		responses[5] = "as i see it, yes";
		responses[6] = "most likely"
		responses[7] = "outlook good";
		responses[8] = "yes"
		responses[9] = "signs point to yes";
		responses[10] = "reply hazy, try again";
		responses[11] = "ask again later";
		responses[12] = "better not tell you now";
		responses[13] = "cannot predict now";
		responses[14] = "concentrate and ask again";
		responses[15] = "don't count on it";
		responses[16] = "my reply is no";
		responses[17] = "my sources say no";
		responses[18] = "outlook not so good";
		responses[19] = "very doubtful";
		math.randomseed(os.time())
		math.random(); math.random(); math.random()
		message.channel:send{
			embed = {
				title = "The magic 8-ball",
				fields = {
					{name="Question", value=message.content:sub(#(info.prefix .. " 8ball")+1)},
					{name="Response", value=responses[math.random(0,19)]}
				},
				timestamp = discordia.Date():toISO('T', 'Z'),
				color = discordia.Color.fromRGB(0,255,0).value
			}
		};
	end
	if command(message, "com img ") then
		file = message.content:sub(#(info.prefix .. " 8ball"))
		file = string.sub(file, rfind(file,"/"));
		if fexists("./pictures/" .. file) then
			message.channel:send{
				file = "./pictures/" .. file,
			}
		else
			message.channel:send("No such image");
		end
	end
	if command(message, "com search ") then
		files = scandir("./pictures");
		local searchTerm = message.content:sub(#("com search ")+1);
		result = "";
		for i=3,#files do
			if files[i]:find(searchTerm) ~= nil then
				if i % 2 == 0 then result = result .. "**" end
				result = result .. files[i] .. ", ";
				if i % 2 == 0 then result = result .. "**" end
			end
			if i % 3 == 0 then
				result = result .. "\n";
			end
		end
		if result == "" then
			message.channel:send("No results :(");
		else
			message.channel:send{embed = {
				title = "ComImage",
				fields = {
					{name="Search results", value=result}
				},
				timestamp = discordia.Date():toISO('T', 'Z'),
				color = discordia.Color.fromRGB(0,255,0).value
			}};
		end
	end
end)

client:run("Bot " .. info.token);