local tunpack = table.unpack or unpack

if not table.deepUpdate then
	function table.deepUpdate(src, upd, cache)
		if not cache then
			cache = {}
		end
		if not upd then
			error("Unavailable update table", 2)
		end
		for k, v in pairs(upd) do
			if type(v) == "table" then
				if not src[k] then src[k] = {} end
				local h = tostring(v)
				local c = cache[h]
				if c then
					src[k] = c
				else
					cache[h] = v
					table.deepUpdate(src[k], v, cache)
				end
			else
				src[k] = v
			end
		end
	end
end

local Age = {
	layers = {"default"},
	_templates = {},
	_entities = {},
	_ents2add = {},
	_lastId = 0,
	_walkFlip = false,
	_coroutines = {},
}
Age.__index = Age

function Age.template(name, template)
	if not template.__index then
		template.__index = template
	end
	template.templateName = name
	local co = coroutine.create(function (src, target, message, args)
		while true do
			Age.map(name, function (e)
				if not target or e.id == target.id then
					e[message](e, src, tunpack(args))
				end
			end)
			src, target, message, args = coroutine.yield()
		end
	end)
	Age._coroutines[name] = co
	Age._templates[name] = template
end

function Age.entity(name, start, ...)
	local e = start or {}

	local template = Age._templates[name]
	if type(name) ~= "string" then
		error("Template name is not a string", 2)
	end
	if not template then
		error("Unavailable template '" .. name .. "'", 2)
	end
	table.deepUpdate(e, template)
	e.id = Age._lastId + 1
	e.template = name
	Age._lastId = e.id
	if e.init then
		e:init(...)
	end
	if not e.layer then
		e.layer = "default"
	end

	table.insert(Age._ents2add, e)

	return e
end

function Age.update(...)
	for _, e in ipairs(Age._ents2add) do
		local ents = Age._entities[e.layer]
		if not ents then
			ents = {}
			Age._entities[e.layer] = ents
		end
		table.insert(ents, e)
	end
	Age._ents2add = {}

	for _, layer in ipairs(Age.layers) do
		local ents = Age._entities[layer]
		if not ents then
			ents = {}
			Age._entities[layer] = ents
		end
		if Age._walkFlip then
			for i=#ents, 1, -1 do
				ents[i]:update(...)
			end
		else
			for i=1, #ents do
				ents[i]:update(...)
			end
		end
	end

	for name, ents in pairs(Age._entities) do
		for i=#ents, 1, -1 do
			if ents[i].destroy then
				table.remove(ents, i)
			end
		end
	end

	Age._walkFlip = not Age._walkFlip
end

function Age.clone(inTable)
	local o = {}
	o.__index = o
	table.deepUpdate(o, inTable)
	return o
end

function Age.map(templateName, callback, targetLayer)
	for _, layerName in ipairs(Age.layers) do
		if not targetLayer or layerName == targetLayer then
			for _, e in ipairs(Age._entities[layerName]) do
				if not templateName or e.template == templateName then
					if callback(e) == false then
						break
					end
				end
			end
		end
	end
end

local function _resumeTarget(targetName, src, target, message, args)
	local co = Age._coroutines[targetName]
	if not co then
		error("Unknown target '" .. targetName .. "'", 3)
	end
	local ok, err = coroutine.resume(co, src, target, message, args)
	if not ok then
		if err ~= "cannot resume running coroutine" then
			error(err, 3)
		end
		if not _errRunningCos then
			_errRunningCos = 0
		end
		_errRunningCos = _errRunningCos + 1
		print("Running coroutine calls rejected: " .. _errRunningCos)
	end
end

function Age.message(src, target, message, ...)
	local args = {...}
	if type(target) == "string" then
		return _resumeTarget(target, src, nil, message, args)
	end
	local targetName = target.template
	if targetName then
		return _resumeTarget(targetName, src, target, message, args)
	end
	local res = {}
	for _, e in ipairs(target) do
		table.insert(res, _resumeTarget(e.template, src, e, message, args))
	end
	return res
end

return Age
