Contributions:

Alex Cabrera (25%)
Defined core-data models and helper function (alongside Ben)
Set-up basic view controller data handling
Added viewController saving/loading to core-data
Misc fixes

Nihar Rao (25%)
Created final screens for My Games, Game Title, Map View, And Linking View Controller as well as navigation and segues for the alpha
Created initial design for app and editor
Completed linking for tiles

Ben Gordon (25%)
Defined core data models and helper functions (alongside Alex) 
Added outlets and actions to View Controller files to handle core data functionality

Gabby Galicinao (25%)
Majority of editor screen (import an image into UIImageView, customized UITextView, edit titles of the two choice buttons and tile’s title in the navigation bar)
Part of Game Title screen (can edit game title, can add image to ImageView for game)
Used CropViewController to crop an image selected from photo library

Deviations:

Here are the things we planned for in the alpha release:
Basic UI for making a game
There is a basic UI for creating the game as well as finding the game to edit, finding the tile to edit, editing the game information, and editing a tile
The simulators do not have the camera, so Gabby did not yet test if the user can import an image from the camera; just the photo library.
We planned for a description in the Game screen but we ran into some problems with that screen and might move some stuff around
Tile/game deletion is implemented with a swiping action on each TableView controller. Game deletion will be moved to the game screen, where the button currently does not do anything. We plan on adding a confirmation action as well.
View Controller to see a list of your own games, list of games you are currently playing, and list of games you have played in the past 
We only have a list of your own games and decided against a list of games you are currently playing and games you have played in the past. We thought it was a little redundant and would be easier to make the search system more robust to find the games you have played in the past.
Keep track of progress for the user in each game (persistent storage)
The app saves your progress on editing each tile as well as editing the game object itself (game title, image, description). This is done through core data objects with convenience functions manually defined.
A user system is implemented, but since there are no login/signup screens in our alpha release, a user object is created by default on login. We plan to implement the network side of this (sync and auth) on our beta release.





