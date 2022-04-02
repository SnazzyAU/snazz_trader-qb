local discordWebhook = 'https://discord.com/api/webhooks/869146285112963092/2hH9TcEpaOvNccdfmTiohVwQe0Xqqq8CvAHbYtqvSshkM9IbSQaDCIUbuQqTJZw1cPXQ'

function sendToDiscord(color, name, message, footer)
	local embed = {
		{
			["color"] = color,
			["title"] = "**".. name .."**",
			["description"] = message,
			["footer"] = {
				["text"] = footer,
			},
		}
	}
  
	PerformHttpRequest(discordWebhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end