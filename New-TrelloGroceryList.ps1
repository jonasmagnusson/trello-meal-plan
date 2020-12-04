Function New-TrelloGroceryList {
    <#
    .SYNOPSIS
        New-TrelloGroceryList
    .DESCRIPTION
        New-TrelloGroceryList
    .PARAMETER BoardName
        The board name where the list is found.
    .PARAMETER ListName
        The list name to create an grocery list for.
    .EXAMPLE
        PS> New-TrelloGroceryList -BoardName "Meal Plan" -ListName "Week 50"
    
        Create grocery list in the board Meal Plan and the list Week 50.
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, Position = 1)]
        [String]$BoardName,

        [Parameter(Mandatory = $True, Position = 2)]
        [String]$ListName
    )

    Process {
        Write-Host "Fetching cards from board... " -NoNewline

        # Get board, list and card objects
        $board = Get-TrelloBoard -Name $BoardName
        $list = Get-TrelloList -BoardId $($board.Id) | Where-Object { $_.Name -like $ListName }
        $cards = Get-TrelloCard -Board $board -List $list

        Write-Host "√" -ForegroundColor 'Green'

        Write-Host "Recalculating ingredients for recipes... " -NoNewline

        # List of ingredients
        $ingredients = @()

        # Loop through each card
        ForEach ($card in $cards) {
            $cardIngredients = @()

            # Find scaling in recipe
            $card.Desc -match "(\* Servings: )(?<Servings>[0-9.]+)[\s\S](\* Scaling: )(?<Scaling>[0-9.]+)" | Out-Null
            
            # Store servings and scaling for later
            $servings = $Matches.Servings
            $scaling = $Matches.Scaling
            
            Write-Debug "Found servings $servings for $($card.Name)"
            Write-Debug "Found scaling $scaling for $($card.Name)"

            # Loop through each ingredient
            ForEach ($ingredient in $($card | Get-TrelloCardChecklist | Get-TrelloCardChecklistItem)) {
                $measurementFound = $ingredient.Name -match "^(?<Measurment>[0-9.]+)"

                If ($measurementFound) {
                    # Get current measurement
                    $measurment = $Matches.Measurment
                    Write-Debug "Found measurement $measurment for $($ingredient.Name)"

                    # Calculate new ingredient measurement
                    $newMeasurement = (([decimal]$measurment * [decimal]$scaling).ToString("0.##")).Replace(",", ".")
                    Write-Debug "Calculated new measurement $newMeasurement with scaling $scaling on $($ingredient.Name)"

                    # Add to ingredient list
                    $ingredients += "$(($ingredient.Name).Replace($measurment,$newMeasurement)) (*$($card.Name)*)"
                    $cardIngredients += "$(($ingredient.Name).Replace($measurment,$newMeasurement))"
                }

                Else {
                    # Add to ingredient list without modified measurement
                    $ingredients += "$($ingredient.Name) ($($card.Name))"
                    $cardIngredients += "$($ingredient.Name)"
                    Write-Debug "Measurement was not found for $($ingredient.Name)"
                }
            }

            # Remove ingredients from recipe
            $card | Get-TrelloCardChecklist | Get-TrelloCardChecklistItem | Remove-TrelloCardChecklistItem 

            # Add new ingredients with correct scaling
            ForEach ($cardIngredient in $cardIngredients) {
                $card | Get-TrelloCardChecklist | New-TrelloCardChecklistItem -Name $cardIngredient | Out-Null
            }

            # Update servings and scale on the recipe description
            $updatedDescription = ($card.Desc).Replace("Servings: $servings","Servings: $(([decimal]$servings * [decimal]$scaling).ToString("0.##"))")
            $updatedDescription = $updatedDescription.Replace("Scaling: $scaling","Scaling: 1")

            $requestBody = @{
                desc = $updatedDescription
            }

            $requestJsonBody = [System.Text.Encoding]::UTF8.GetBytes(($requestBody | ConvertTo-Json))

            # Update card description
            Invoke-RestMethod -Method Put -ContentType "application/json" -Body $requestJsonBody -Uri "https://api.trello.com/1/cards/$($card.Id)?$((Get-TrelloConfiguration).String)" | Out-Null
        }

        Write-Host "√" -ForegroundColor 'Green'

        # Sort ingredients
        Write-Host "Sorting ingredients by name... " -NoNewline

        $sortedIngredients = @()

        ForEach ($ingredient in $ingredients) {
            # Create custom object with and without measurement
            $ingredientObject = [PSCustomObject] @{
                'WithoutMeasurement' = $ingredient -replace '((\d*(\.\d)*) (st|dl|ml|msk|tsk|g|kg|cups|krm) )', ''
                'WithMeasurement'    = $ingredient
            }

            # Add to sorted list
            $sortedIngredients += $ingredientObject
        }

        Write-Host "√" -ForegroundColor 'Green'
        
        # Sort ingredients without measurement but display full ingredient text
        $sortedIngredients = $sortedIngredients | Sort-Object WithoutMeasurement | Select-Object WithMeasurement
        
        # Create grocery list card and checklist
        $groceryListCard = New-TrelloCard -ListId $list.Id -Name "Grocery List - $ListName" -Position 1 -Description "Grocery list containing all items from list $($List.Name)" -urlSource "https://i.imgur.com/K55gyig.jpg"
        $groceryListCard | New-TrelloCardChecklist -Name "Grocery List - $ListName"
        
        Write-Host "Adding ingredients to grocery list... " -NoNewline

        # Populate grocery list with items
        ForEach ($ingredient in $sortedIngredients.WithMeasurement) {
            $groceryListCard | Get-TrelloCardChecklist | New-TrelloCardChecklistItem -Name $ingredient | Out-Null
            Write-Debug "Added $ingredient to Grocery List - $ListName"
        }

        Write-Host "√" -ForegroundColor 'Green'
    }
}
