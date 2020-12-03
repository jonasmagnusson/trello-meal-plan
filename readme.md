# Trello Meal Plan

Trello is a perfect tool to save your recipes and meal planning. These scripts helps to automate the task to recalculate the ingredients while meal planning and generate grocery lists.

IMAGE

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
# Dingus
```

Create two boards in Trello, one to save your recipes and one where the meal planning and grocery list generation will take place.

## Usage

When you have your desired recipes in one board, create a new recipe template to get the correct formatting, and then edit it to add your recipe.

```powershell
# Create template recipe to get the correct formatting
New-TrelloRecipe -BoardName "Recipes" -ListName "Meat"
```

After adding your recipes, copy recipe cards to the meal planning board and for example one list per week of planning. Edit the recipe scaling in decimal form to change the portions of each recipe. Then run the script to update the meal planning recipes ingredients, and generate a grocery list:

```powershell
# Create grocery list
New-TrelloGroceryList -BoardName "Meal Plan" -ListName "Week 50"
```

This creates a card named `Grocery List - Week 50` in the same board and list, containing all the checkbox items from the recipes the same list. The scale value is used to recalculate the ingredients needed.

The grocery list items of the same type is not merged, as i prefer them seperated. The grocery list is sorted in alphabetical order and you can see which recipe each ingredient is coming from and are able to skip some if you want to while shopping.

To export all your recipes and images to markdown files as backup, run the following:

```powershell
# Export recipes as markdown
Export-TrelloRecipes -BoardName "Recipes"
```

