Function Export-TrelloRecipes {
    <#
    .SYNOPSIS
        Export-TrelloRecipes
    .DESCRIPTION
        Export-TrelloRecipes
    .PARAMETER BoardName
        The board name where the list is found.
    .PARAMETER BoardName
        Existing paths to download recipes to.
    .EXAMPLE
        PS> Export-TrelloRecipes -BoardName "Recipes" -Path "D:\trello-meal-plan\examples"
    
        Backup your recipes in the board Recipes to markdown files.
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, Position = 1)]
        [String]$BoardName,

        [Parameter(Mandatory = $True, Position = 2)]
        [String]$Path
    )

    Process {
        # Get all cards from board
        $cards = Get-TrelloBoard -Name $BoardName | Get-TrelloCard 

        ForEach ($card in $cards) {
            # Define filenames and paths
            $fileName = ($card.Name).ToLower().Replace(" ", "-")
            $filePathMarkdown = Join-Path -Path $Path -ChildPath "$($filename).md"
            $filePathImage = Join-Path -Path $Path -ChildPath "$($filename).jpg"

            # Title and image
            "# $($card.Name)`r`n" | Out-File -FilePath $filePathMarkdown
            "![$($card.Name)]($filename.jpg)`r`n" | Out-File -FilePath $filePathMarkdown -Append
            
            # Ingredients
            $ingredients = $card | Get-TrelloCardChecklist | Get-TrelloCardChecklistItem

            "## Ingredients`r`n" | Out-File -FilePath $filePathMarkdown -Append

            ForEach ($ingredient in $ingredients) {
                "- [ ] $($ingredient.Name)" | Out-File -FilePath $filePathMarkdown -Append
            }

            # Desciption
            "`r`n## Description`r`n" | Out-File -FilePath $filePathMarkdown -Append
            "$($card.Desc)" | Out-File -FilePath $filePathMarkdown -Append

            # Download image
            Invoke-WebRequest ($card | Get-TrelloCardAttachment).Url -OutFile $filePathImage
        }
    }
}
