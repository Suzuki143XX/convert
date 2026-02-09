   print("Hello from Kimi! Server is running!")
   
   game.Players.PlayerAdded:Connect(function(player)
       print(player.Name .. " joined the game!")
   end)