local AssetUtils={}

function AssetUtils:PreloadAsync(Asset,Type)
	local ContentProvider=game:GetService("ContentProvider")

	if Type=="Texture" then
		ContentProvider:PreloadAsync({"rbxassetid://"..Asset})
	elseif Type=="Sound" or Type=="Audio" then
		local Audio=Instance.new('Sound')
		Audio.SoundId="rbxassetid://"..Asset
		ContentProvider:PreloadAsync({Audio})
		Audio:Destroy()
	elseif Type=="Mesh" then
		local Mesh=Instance.new('SpecialMesh')
		Mesh.MeshId=Asset
		ContentProvider:PreloadAsync({Mesh})
		Mesh:Destroy()
	end
end

return AssetUtils