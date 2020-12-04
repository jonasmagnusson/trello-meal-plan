# Trello Meal Plan

These scripts exists to help use Trello to store your recipes and do meal planning. It helps to automate the task to recalculate the ingredients while meal planning and generates grocery lists.

![Demo](demo.gif "Demo")

## Installation

To be able to create grocery lists you need to have [PowerTrello](https://github.com/adbertram/PowerTrello) by Adam Bertram installed. Run Powershell as Administrator and install it like this:

```powershell
# Install PowerTrello Module
Install-Module PowerTrello
```

Get your Trello API key [here](https://trello.com/app-key), and set it in PowerTrello like this and follow the instructions:

```powershell
# Define Trello API key
Set-TrelloAccessToken -ApiKey APIKEY
```

Clone this repository and load the functions:

```powershell
# Clone repository
git clone https://github.com/jonasmagnusson/trello-meal-plan.git

# Dot source functions
. .\New-TrelloRecipe.ps1
. .\New-TrelloGroceryList.ps1
. .\Export-TrelloRecipes.ps1
```

## Usage

Create two boards in Trello, one to save your recipes and one where the meal planning and grocery list generation will take place.

### Recipe Template

Create a new recipe template to get the correct formatting, and then edit it to add your recipes. Keep scaling to the default value and make sure not to change the name of the ingredient checklist:

```powershell
# Create template recipe to get the correct formatting
New-TrelloRecipe -BoardName "Recipes" -ListName "Meat"
```

### Meal Planning

Create one list for each week you want to plan in the meal planning board you created earlier. Copy recipe cards from your collection and place in desired week. Edit the copied recipes scaling decimal value to change the services of that recipe.

Then run the script against the list in the meal planning board:

```powershell
# Create grocery list
New-TrelloGroceryList -BoardName "Meal Plan" -ListName "Week 50"
```

This will do the following:

* Recalculate and update ingredients based on scaling on each recipe.
* Update number of servings on each recipe.
* Create a grocery list card which is sorted in alphabetical order.

Ingredients from different recipes is not merged, but you can see which recipe all items come from, to be able to easily skip items while shopping.

### Export Recipes

To export all your recipes and images to markdown files as backup, run the following:

```powershell
# Export recipes as markdown
Export-TrelloRecipes -BoardName "Recipes"
```

Exported recipes will look like [this](examples/het-chiligryta-på-högrev.md).
