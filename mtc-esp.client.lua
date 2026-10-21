--[[
    Système d'identification visuelle globale et affichage de la distance.
    Configuration : Analyse globale du Workspace pour cibler tous les modèles de personnages (y compris entités MTC).
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Fonction pour appliquer l'effet et l'interface sur n'importe quel modèle valide
local function configurerEntite(personnage)
	if not personnage or not personnage:IsA("Model") then return end
	
	-- Éviter d'appliquer l'effet sur son propre personnage
	if LocalPlayer.Character and personnage == LocalPlayer.Character then return end
	
	-- Vérifier s'il s'agit bien d'une entité vivante/personnage (présence d'un Humanoid)
	if not personnage:FindFirstChildOfClass("Humanoid") then return end
	
	-- 1. APPLICATION DU HIGHLIGHT
	local highlight = personnage:FindFirstChild("VisualRedHighlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "VisualRedHighlight"
		highlight.Parent = personnage
	end
	
	highlight.FillColor = Color3.fromRGB(255, 0, 0)      -- Rouge pur
	highlight.OutlineColor = Color3.fromRGB(255, 50, 50) -- Contour clair
	highlight.FillTransparency = 0.3                    -- Remplissage visible
	highlight.OutlineTransparency = 0                   -- Totalement opaque
	highlight.Enabled = true
	
	-- 2. APPLICATION DU BILLBOARDGUI (Distance)
	local tete = personnage:FindFirstChild("Head") or personnage:FindFirstChildOfClass("Part")
	if not tete then return end
	
	local billboard = tete:FindFirstChild("DistanceUI")
	local label
	
	if not billboard then
		billboard = Instance.new("BillboardGui")
		billboard.Name = "DistanceUI"
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		
		label = Instance.new("TextLabel")
		label.Name = "DistanceLabel"
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(255, 50, 50)
		label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		label.TextStrokeTransparency = 0
		label.TextSize = 14
		label.Font = Enum.Font.GothamBold
		label.Parent = billboard
		
		billboard.Parent = tete
	end
end

-- Fonction pour scanner récursivement le Workspace à la recherche de modèles
local function scannerWorkspace()
	for _, objet in ipairs(Workspace:GetDescendants()) do
		if objet:IsA("Model") then
			configurerEntite(objet)
		end
	end
end

-- Surveillance des nouvelles entités apparaissant dans le jeu
Workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("Model") then
		task.defer(function()
			configurerEntite(descendant)
		end)
	end
end)

-- Lancement du scan initial
scannerWorkspace()

-- 3. MISE À JOUR DYNAMIQUE EN TEMPS RÉEL DE LA DISTANCE
RunService.RenderStepped:Connect(function()
	local persoLocal = LocalPlayer.Character
	if not persoLocal or not persoLocal:FindFirstChild("HumanoidRootPart") then return end
	
	local posLocale = persoLocal.HumanoidRootPart.Position
	
	for _, objet in ipairs(Workspace:GetDescendants()) do
		if objet:IsA("Model") and objet ~= persoLocal and objet:FindFirstChild("HumanoidRootPart") then
			local tete = objet:FindFirstChild("Head") or objet:FindFirstChildOfClass("Part")
			if tete then
				local billboard = tete:FindFirstChild("DistanceUI")
				if billboard then
					local label = billboard:FindFirstChild("DistanceLabel")
					if label then
						local posCible = objet.HumanoidRootPart.Position
						local distance = math.floor((posLocale - posCible).Magnitude)
						
						-- Affiche le nom de l'entité/modèle et sa distance
						label.Text = objet.Name .. " [" .. tostring(distance) .. "m]"
					end
				end
			end
		end
	end
end)
