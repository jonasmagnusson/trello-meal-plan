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
       [Parameter(Mandatory=$True, Position=1)]
       [String]$BoardName,

       [Parameter(Mandatory=$True, Position=2)]
       [String]$ListName
	)

	Process {
        # Get board, list and card objects
        $board = Get-TrelloBoard -Name $BoardName
        $list = Get-TrelloList -BoardId $($board.Id) | Where-Object { $_.Name -like $ListName }
        $cards = Get-TrelloCard -Board $board -List $list

        # List of ingredients
        $ingredients = @()

        # Loop through each card
        ForEach ($card in $cards) {
            # Find scaling in recipe
            $card.Desc -match "(Scaling: )(?<Scaling>[0-9.]+)" | Out-Null
            
            # Store scaling for later
            $scaling =  $Matches.Scaling
            Write-Debug "Found scaling $scaling for $($card.Name)"

            # Loop through each ingredient
            ForEach ($ingredient in $($card | Get-TrelloCardChecklist | Get-TrelloCardChecklistItem)) {
                $measurementFound = $ingredient.Name -match "^(?<Measurment>[0-9.]+)"

                If ($measurementFound) {
                    # Get current measurement
                    $measurment = $Matches.Measurment
                    Write-Debug "Found measurement $measurment for $($ingredient.Name)"

                    # Calculate new ingredient measurement
                    $newMeasurement = [decimal]$measurment * [decimal]$scaling
                    Write-Debug "Calculated new measurement $newMeasurement with scaling $scaling on $($ingredient.Name)"

                    # Add to ingredient list
                    $ingredients += "$(($ingredient.Name).Replace($measurment,$newMeasurement)) (*$($card.Name)*)"
                }

                Else {
                    # Add to ingredient list without modified measurement
                    $ingredients += "$($ingredient.Name) ($($card.Name))"
                    Write-Debug "Measurement was not found for $($ingredient.Name)"
                }
            }

            # Update card recipe, scaling and portions
        }

        # Sort ingredients
        $sortedIngredients = @()

        foreach($ingredient in $ingredients){
            # Create custom object with and without measurement
            $ingredientObject = [PSCustomObject] @{
                'WithoutMeasurement' = $ingredient -replace '((\d*(\.\d)*) (st|dl|ml|msk|tsk|g|kg|cups|krm) )',''
                'FullIngredient' = $ingredient
            }

            # Add to sorted list
            $sortedIngredients += $ingredientObject
        }
        
        # Sort ingredients without measurement but display full ingredient text
        $sortedIngredients = $sortedIngredients | Sort-Object WithoutMeasurement | Select-Object FullIngredient
        
        # Create grocery list card and checklist
        $groceryListCard = New-TrelloCard -ListId $list.Id -Name "Grocery List - $ListName" -Position 1 -Description "Grocery list containing all items from list $($List.Name)" -urlSource "https://inhabitat.com/wp-content/blogs.dir/1/files/2018/02/Produce-Food-889x592.jpg"
        $groceryListCard | New-TrelloCardChecklist -Name "Grocery List - $ListName"
        
        # Populate grocery list with items
        ForEach ($ingredient in $sortedIngredients.FullIngredient) {
            $groceryListCard | Get-TrelloCardChecklist | New-TrelloCardChecklistItem -Name $ingredient | Out-Null
            Write-Output "Added $ingredient to Grocery List - $ListName"
        }
	}
}

# TODO
# Number of decimals on ingredients
# Better cover art
# Update recipes in meal plan with scaling and portions
