Valyrie's Friends Enhanced - v2.5.4

VFE extends the original Friends menu by adding some much needed functionality.
It will replace the standard Friends.swf file and will therefore not work with any other (possible) add-ons that does the same.

Donations
It takes a lot of time to develop an add-on, so if you really like this mod and want to support it then please consider donating any amount. Thank you!
You can always donate through this page: http://hem.bredband.net/Valyrie/

What's new in this version
* Removed the "Meetup and remove" menu item completely as it isn't needed anymore
* Included missing info about changing notification colors manually for players logging in/out into the readme

All current features
* Add your personal notes for any Friend / Cabal member / Ignored player
* Allows you to set preferred roles (tank, DPS, healer) for any Friend or Cabal member
* A "Last seen" column that shows when Friends was last seen being logged in (only visible when showing all players)
  Note: this data is NOT taken from the servers (it's not available) but rather checking who is online while you play yourself. 
  So if anyone is online while you are not, then my mod has no way of detecting this.
* A "Last online" column that shows when a Cabalmate was last logged in on the game server.
* Two optional "Custom" columns that can represent whatever you want to keep track of (true/false only). 
  Both column titles can be custom set to max ~10 characters and are shared between all your characters
* All custom player information is stored "per account" and thus shared between all your characters on the same TSW account
* Support for notifying on screen when Friends and/or Cabals log in and/or out.
* Support sorting on all columns (makes it easy to find for example all friends with a preferred healer role)
* Support for batch Export/Import of player data between different characters
* Import another characters Friends
* Fixed the bug from the original Friends window where the right-click menu interacted with the wrong player if the list had been sorted
* Button to toggle between 'show all' or 'show only players online' for the Friends and Cabal view
  This setting is unique for each of the two views, thus you can have a different setting for each
* The last opened view is remembered and will be shown automatically next time you open the mod
* Views will remember their last used column sort
* The position of the VFE icon can be set to be anywhere on screen (function disabled if using the Viper Topbar mod)
* Support for resizing the window
* Remember last Window position on screen
* Export and Import ignored users list and an 'unignore all' button for easy handling of your ignored players
* Count the number of days a player has been ignored (people can change). Old ignores can't be counted for apparent reasons!
* Optional 'Dimension' column for Cabal and Friends view (toggle in the settings tab)
* Optional 'Rank' column for Cabal view (toggle in the settings tab)
* Optional 'Region' column for Cabal view (toggle in the settings tab)
* Optional 'Society' column for Friends view (toggle in the settings tab)
* Added "Create Raid" and "Invite to/Remove from Raid" options to the context menu
* Integrates with Viper's Topbar Information Overload mod
* Integrates with Viper's They Come And Go mod
* A "/Who" feature for friends (still need to press enter in the chat window to see player info)


Note: due to request I've added three variables for defining the color of the text announcing players loggin in/out.
These colors can NOT be set from the mod UI, you have to manually edit the Prefs_2.xml for each character you want to change it for.
The format must be a valid HTML color (starting with a hash tag followed by 6 hex characters), for example #FF0000 that is red.

Variable names and explanation:
PlayerOnlineColor; used when you have enabled the general going online monitoring for Friends/Cabalmates in the Settings tab.
PlayerOfflineColor; used when you have enabled the general going offline monitoring for Friends/Cabalmates in the Settings tab.
MonitoredPlayerOnlineColor; used when you have set a checkmark in the right-click menu for a specific player and he/she comes online.


Installation
Unpack the .zip archive into <your Secret World Directory>\Data\Gui\Customized\Flash\ folder, overwrite if files already exists

It should look like this:
\Data\Gui\Customized\Flash\Friends.swf
\Data\Gui\Customized\Flash\FriendsProxy\CharPrefs.xml
\Data\Gui\Customized\Flash\FriendsProxy\FriendsProxy.swf
\Data\Gui\Customized\Flash\FriendsProxy\Modules.xml
\Data\Gui\Customized\Flash\FriendsProxy\LoginPrefs.xml
\Data\Gui\Customized\Flash\FriendsProxy\readme.txt

If you had TSW running when copying these files, then you must quit the game completely and then restart it or the addon won't work properly!

Uninstallation
Delete \Data\Gui\Customized\Flash\Friends.swf
Delete the \Data\Gui\Customized\Flash\FriendsProxy folder

Usage
Simply press shift+f or use the "Friends" option in the game menu and you will see the new, enhanced interface.

/Valyrie
