Function New-TrelloRecipe {
    <#
    .SYNOPSIS
        New-TrelloRecipe
    .DESCRIPTION
        New-TrelloRecipe
    .PARAMETER BoardName
        The board name to create the recipe template in.
    .PARAMETER ListName
        The list name to create the recipe template in.
    .EXAMPLE
        PS> New-TrelloRecipe -BoardName "Recipes" -ListName "Meat"

        Create recipe template in board Recipe and list Meat.
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, Position = 1)]
        [String]$BoardName,

        [Parameter(Mandatory = $True, Position = 2)]
        [String]$ListName
    )

    Process {
        # Get board and list objects
        $board = Get-TrelloBoard -Name $BoardName
        $list = Get-TrelloList -BoardId $($board.Id) | Where-Object { $_.Name -like $ListName }

        Write-Host "Creating template card for recipe... " -NoNewline

        # Create description
        $desciption += "* Servings: 6`n"
        $desciption += "* Scaling: 1`n"
        $desciption += "* Time: 60 minutes`n`n"
        $desciption += "Short recipe description`n`n"
        $desciption += "## Directions`n`n"
        $desciption += "1. Do this first.`n"
        $desciption += "2. Then do this.`n`n"
        $desciption += "[Source](https://example.com/)"

        # Create new card
        $card = New-TrelloCard -ListId $list.Id -Name "Recipe Name" -Description $desciption

        # Add checklist to card
        $card | New-TrelloCardChecklist -Name "Ingredients"

        Write-Host "√" -ForegroundColor 'Green'
    }
}
