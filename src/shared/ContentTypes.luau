local ContentTypes = {}

function ContentTypes.validateContent(data)
	if type(data) ~= "table" then 
		return false, "Invalid data type" 
	end
	if not data.appType then 
		return false, "Missing app type" 
	end
	if not data.title or #data.title < 1 then 
		return false, "Title required" 
	end
	if #data.title > 100 then 
		return false, "Title too long" 
	end
	return true, nil
end

return ContentTypes