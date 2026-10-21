--[[
    Système d'identification visuelle par équipe via l'objet Highlight.
    Ce script récupère automatiquement la couleur de l'équipe attribuée par le jeu.
--]]

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local LocalPlayer = Players.LocalPlayer

-- Fonction principale pour gérer l'affichage de la silhouette sur un personnage
local function appliquerEffetEquipe(joueur, personnage)
	if not personnage then return end
	
	-- Recherche ou création de l'instance Highlight officielle
	local highlight = personnage:FindFirstChildOfClass("Highlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "VisualTeamHighlight"
		highlight.Parent = personnage
	end
	
	-- Configuration des propriétés visuelles
	highlight.FillTransparency = 0.5   -- Transparence du remplissage intérieur
	highlight.OutlineTransparency = 0.1 -- Transparence de la silhouette extérieure
	
	-- Application dynamique de la couleur de l'équipe
	if joueur.Team then
		highlight.FillColor = joueur.Team.TeamColor.Color
		highlight.OutlineColor = joueur.Team.TeamColor.Color
	else
		-- Couleur neutre par défaut si aucune équipe n'est assignée
		highlight.FillColor = Color3.fromRGB(200, 200, 200)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	end
	
	-- Masquer l'effet sur son propre personnage pour ne pas gêner la vue à la première personne
	if joueur == LocalPlayer then
		highlight.Enabled = false
	else
		highlight.Enabled = true
	end
end

-- Gestionnaire individuel pour chaque joueur connecté
local function gererJoueur(joueur)
	-- Déclenchement automatique à chaque réapparition (Spawn) du personnage
	joueur.CharacterAdded:Connect(function(personnage)
		appliquerEffetEquipe(joueur, personnage)
	end)
	
	-- Application immédiate si le personnage est déjà chargé sur la carte
	if joueur.Character then
		appliquerEffetEquipe(joueur, joueur.Character)
	end
	
	-- Mise à jour automatique si le joueur change d'équipe en cours de partie
	joueur:GetPropertyChangedSignal("Team"):Connect(function()
		if joueur.Character then
			appliquerEffetEquipe(joueur, joueur.Character)
		end
	end)
end

-- Initialisation du script pour tous les joueurs présents et futurs
for _, joueur in ipairs(Players:GetPlayers()) do
	gererJoueur(joueur)
end

Players.PlayerAdded:Connect(gererJoueur)
