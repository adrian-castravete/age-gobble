local tunpack = unpack -- table.unpack

local E = {
	sortfn = nil,
	_systems = {},
	_entities = {},
	_namedEntities = {},
	_entities2add = {},
	_messageCoroutines = {},
	_tweenCoroutines = {}
}

if not table.deepUpdate then
	function table.deepUpdate(src, upd, cache)
		if not cache then
			cache = {}
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

function E.system(name, data)
	if not data then
		return E._systems[name]
	end
	if type(data) == "function" then
		local Sys = {}
		Sys.__index = Sys
		Sys.system = data
		data = Sys
	end
	E._systems[name] = data
	return data
end

function E.entity(data)
	if type(data) == "string" then
		data = {
			name = data,
		}
	end

	if not data.name then
		error("name not specified for entity", 2)
	end

	local e = {}
	table.deepUpdate(e, data)
	if not e[data.name] then
		e[data.name] = true
	end
	local ents = E._namedEntities[data.name]
	if not ents then
		ents = {}
		E._namedEntities[data.name] = ents
		E._messageCoroutines[data.name] = coroutine.create(function(target, e, name, mdata)
			while name ~= "nuke" do
				local c = 0
				if not target then
					target = E._namedEntities[data.name]
				end
				for _, i in ipairs(target) do
					if i[name] then
						i[name](i, e, tunpack(mdata))
						c = c + 1
					end
				end
				target, e, name, mdata = coroutine.yield(c)
			end
		end)
	end

	table.insert(E._entities2add, e)

	return e
end

function E.map(name, cbfn)
	local ents = E._entities
	if name then
		ents = E._namedEntities[name]
	end

	for _, e in ipairs(ents) do
		cbfn(e)
	end
end

function E.message(e, target, name, ...)
	local targetName = target
	local goal = nil
	if type(target) ~= "string" then
		targetName = target.name
		goal = target
	end
	local co = E._messageCoroutines[targetName]
	if not co then return nil end
	local ok, c = coroutine.resume(co, goal, e, name, {...})
	if not ok then error(c) end
	return c
end

function E.tween(e, duration, progressFn, doneFn)
	if not duration then return end
	local v = 0
	local co = coroutine.create(function ()
		while v < duration do
			if progressFn then
				progressFn(e, v / duration)
			end
			coroutine.yield(v / duration)
			v = v + 1
		end
		if progressFn then
			progressFn(e, 1)
		end
		if doneFn then
			doneFn(e)
		end
		return 1
	end)
	local ok, c = coroutine.resume(co)
	if not ok then
		error(c)
	end
	table.insert(E._tweenCoroutines, co)
end

function E.update(...)
	local ents = E._entities2add
	if ents then
		for _, e in ipairs(ents) do
			local f = nil
			if E.sortfn then
				for i, o in ipairs(E._entities) do
					if E.sortfn(o, e) then
						f = i
						break
					end
				end
			end
			if f then
				table.insert(E._entities, f, e)
			else
				table.insert(E._entities, e)
			end
		end
		E._entities2add = {}
	end

	local ntco = {}
	for _, co in ipairs(E._tweenCoroutines) do
		local ok, v = coroutine.resume(co)
		if ok and v < 1 then
			table.insert(ntco, co)
		end
		if not ok then
			print(v)
		end
	end
	E._tweenCoroutines = ntco

	for comp, system in pairs(E._systems) do
		if system.system then
			for _, e in ipairs(E._entities) do
				if e[comp] then
					system:system(e, ...)
				end
			end
		end
	end

	local newe = {}
	local newne = {}
	for _, e in ipairs(E._entities) do
		if not e.destroy then
			local nne = newne[e.name]
			if not nne then
				nne = {}
				newne[e.name] = nne
			end
			table.insert(nne, e)
			table.insert(newe, e)
		end
	end
	E._entities = newe
	E._namedEntities = newne
end

E.S = E.system  -- name, data
E.E = E.entity  -- data
E.M = E.message -- entity, target, name, ...
E.T = E.tween   -- entity, duration, progressFn, doneFn
E.U = E.update  -- ...

-- E.map -- name, fn
-- E.S.system -- system, entity, ...
-- E.M.[cbName] -- entity, name, ...

return E
