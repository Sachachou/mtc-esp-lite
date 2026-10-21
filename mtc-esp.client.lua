--[[
    Système d'identification visuelle par équipe et affichage de la distance.
    Configuration : Rouge très clair visible à travers le verre + Distance dynamique en temps réel.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Fonction principale pour appliquer la silhouette et l'affichage de la distance
local function appliquerInterfaceEtEffet(joueur, personnage)
	if not personnage or joueur == LocalPlayer then return end
	
	-- 1. CONFIGURATION DU HIGHLIGHT (Silhouette Rouge)
	local highlight = personnage:FindFirstChildOfClass("Highlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "VisualRedHighlight"
		highlight.Parent = personnage
	end
	
	highlight.FillColor = Color3.fromRGB(255, 0, 0)      -- Rouge pur vif
	highlight.OutlineColor = Color3.fromRGB(255, 50, 50) -- Contour clair visible
	highlight.FillTransparency = 0.3                    -- Remplissage à 70% d'opacité
	highlight.OutlineTransparency = 0                   -- Contour totalement opaque pour le verre
	highlight.Enabled = true
	
	-- 2. CONFIGURATION DE L'ÉTIQUETTE DE DISTANCE (BillboardGui)
	local tete = personnage:WaitForChild("Head", 5)
	if not tete then return end
	
	local billboard = tete:FindFirstChild("DistanceUI")
	local label
	
	if not billboard then
		billboard = Instance.new("BillboardGui")
		billboard.Name = "DistanceUI"
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 2.5, 0) -- Positionné au-dessus de la tête
		billboard.AlwaysOnTop = true                 -- Reste visible derrière les murs et le verre
		
		label = Instance.new("TextLabel")
		label.Name = "DistanceLabel"
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(255, 50, 50) -- Texte rouge très clair
		label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		label.TextStrokeTransparency = 0              -- Contour noir pour une lisibilité parfaite
		label.TextSize = 14
		label.Font = Enum.Font.GothamBold
		label.Parent = billboard
		
		billboard.Parent = tete
	else
		label = billboard:FindFirstChild("DistanceLabel")
	end
end

-- Gestion des connexions pour chaque joueur
local function gererJoueur(joueur)
	joueur.CharacterAdded:Connect(function(personnage)
		appliquerInterfaceEtEffet(joueur, personnage)
	end)
	
	if joueur.Character then
		appliquerInterfaceEtEffet(joueur, joueur.Character)
	end
end

-- Lancement initial pour tous les joueurs
for _, joueur in ipairs(Players:GetPlayers()) do
	gererJoueur(joueur)
end
Players.PlayerAdded:Connect(gererJoueur)

-- 3. BOUCLE DE MISE À JOUR DYNAMIQUE DE LA DISTANCE (Optimisée par frame)
RunService.RenderStepped:Connect(function()
	local personnageLocal = LocalPlayer.Character
	if not personnageLocal or not personnageLocal:FindFirstChild("HumanoidRootPart") then return end
	
	local positionLocale = personnageLocal.HumanoidRootPart.Position
	
	for _, joueur in ipairs(Players:GetPlayers()) do
		if joueur ~= LocalPlayer and joueur.Character and joueur.Character:FindFirstChild("HumanoidRootPart") then
			local tete = joueur.Character:FindFirstChild("Head")
			if tete then
				local billboard = tete:FindFirstChild("DistanceUI")
				if billboard then
					local label = billboard:FindFirstChild("DistanceLabel")
					if label then
						-- Calcul mathématique de l'écart entre votre avatar et l'autre joueur
						local positionCible = joueur.Character.HumanoidRootPart.Position
						local distance = math.floor((positionLocale - positionCible).Magnitude) -- Distance arrondie
						
						-- Met à jour le texte à l'écran (Exemple : "Player123 [145m]")
						label.Text = joueur.Name .. " [" .. tostring(distance) .. "m]"
					end
				end
			end
		end
	end
end)
