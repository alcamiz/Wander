# Contributions:

#### Gabby Galicinao (Release 25%, Overall 25%)

* All of tab bar controller
    * Create tab bar controller + storyboard, linked the storyboard references from the tab bar controller, added color scheme and icons to tab bar
* All of Playmode storyboard/ViewController
    * Not entirely satisfied with appearance of end tiles - might 
* All of playtesting
    * From “Game Title View Controller”, can select “Playtest” button and be redirected to Playmode screen
* Most of editor screens in Main storyboard
    * Map, Linking View Controllers: 
        * Added to title labels if a game tile is the root tile (first tile to appear in play mode), and end tile (win/lose), and what tiles each button links to, if any.
    * Editor View Controller:
        * Added ScrollView to buttons (realized that when you selected a button to change their name, the keyboard covered up the button). DOES NOT CURRENTLY WORK! When you modify a button name, you still cannot see it while you are still editing. Currently usable when only using the hardware keyboard
* Other:
    * Added theme colors to buttons and navigation bar on editor screens in main storyboard
    * Have not tested adding image from camera to UIImageViews

#### Nihar Rao (Release 25%, Overall 25%)

* Alpha
    * Created final screens for My Games, Game Title, Map View, And Linking View Controller as well as navigation and segues for the alpha Created initial design for app and editor Completed linking for tiles
* Beta
    * Creation of LoginFlow and LoginViewControllers, added in authentication and saving of variables for future use as well as setup for login persistence
    * Creation of the UI for Profile and setup for some future features
        * Changing password, log out, and pfp has not been functionally added due to database issues 
    * Creation of App Logo App Icon and application of color palette as well as design across application

#### Ben Gordon (Release 25%, Overall 25%)

Alpha

* Defined core data models and helper functions (alongside Alex) 
* Added outlets and actions to View Controller files to handle core data functionality

Beta

* Set up firebase project with Firestone database for most info and Storage for images 
* Uploading games to Firestore
    * Developed new more compact representation of data for Firebase
* Browsing games
    * Made intermediate data structure FirebaseGame to provide previews of games without having to download all information 
    * Dealt with asynchronous functions 
* Downloading Games to Core Data

Final
* Refactored Core Data models
    * Made the game structure an explicit binary tree (each tile has 2 children, rather than an array)
    * Removed the option class and unnecessary DateTime fields
    * Added fields for advanced queries, i.e. a publishedOn Date field to StoredGame, along with liking/disliking information
* Improved downloading of games, tiles, and users
    * StoredUsers attached to downloaded StoredGames
* Liking and dislking games
    * GameScreen UI
    * New data structure in the users Firestore collection 
* Firebase query: sorting games by published date and number of likes
* Firebase query: filtering games by tags
* Firebase query: searching for games by author's username
* Allowing users to see published games after signing back in, after core data has been cleared
* JPEG images instead of PNG (slightly improves download speeds)

#### Alex Cabrera (Release 25%, Overall 25%)

* Alpha:
    * Defined core-data models and helper function (alongside Ben)
    * Set-up basic view controller data handling
    * Added viewController saving/loading to core-data
    * Misc fixes
* Beta
    * Explore Page:
        * ContractionView and NavBar work for displaying popular games, newly added games, and games in your history.
    * Search Page:
        * Set up UISearchController (search bar, explore page)
        * ResultView for displaying search results:
            * Custom cells for displaying games after query is entered in search
            * Uses query/tags/sort from other screens
        * FilterView for tags and sorting:
            * Accessed from the sandwich menu to the right of search bar
            * UI Only, see deviations
            * Custom CollectionView:
                * Cell sizes calculated programmatically to fit within any frame and set up to allow custom “row by column” displays when creating the view
                * Reusable as an NIB
    * Game Screen:
        * Both the explore page and results page (from search) link here to start playing a created game retrieved from Firebase
        * Segues to Gabby’s PlayTester view
    * Misc fixes on editor screens

# Deviations:

* Set up a server with an API and a database
    * This has been setup although there are some other parts to add in for the final 
* Publish games to the web
    * You are able to upload games to the database and download them
* View a list of other players’ games 
    * Published games can be found on the explore page
    * Tags and sorting is not working
* 3 main view controllers when not making a game - games you are currently playing, games on the web, and games that you made
    * Tab controller displays this, and some changes were made for finding these things, separated between my games and explore
* Feature to “save” a game (add it to your own home screen)
*      Downloading pictures is not working and we are still working on this feature as we got caught behind with Firebase issues.
* Filtering is only implemented in the UI, but does not have the appropriate components in Firebase/Editor to currently support it. Proper filtering/sorting will be included in the final release.
