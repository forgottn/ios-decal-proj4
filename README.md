# FGC Network

## Authors
- Peter Duong

## Purpose
- The FGC Network allows fighting game players to connect with other players 
  and easily see matches they've played.

## Features
- OAuth using Twitter, FB, Google to make an Account
- Player Profiles 
  - Gamertag, Full Name, Birthday, Age, Nationality, Games Play, Characters 
  Used
  - Optional: Twitter, FB, About me
- Using Youtube API, we can look for matches played by this player

## Control Flow
- User opens the app to a login screen with three buttons, allowing them to 
  login with Twitter, FB, or Google
- If it is their first time logging in, they will be presented with views to 
  fill in necessary information, otherwise they'll be presented with a tab view
  - The default view is a search view where the user can search another 
  person's profile
  - The other tab is the player's own profile, which they can edit their 
  information
    - Here the user can view information and the matches the user has played
- If the user decides to search for a player, it'll show a list of matching 
  players that they can click to segue into another view that looks identical 
  to the my profile view without the editing.

## Implementation

### Model
- YoutubeRequest.swift
- TwitchRequest.swift
- Player.swift
- Setting.swift

### View
- PlaylistTableView
- HomeView
- PlayerView
- PlayerListView
- GameListTableView
- MainGameListTableViewCell
- GameView
- EditTableView
- GameSettingTableView
- GameListSettingTableView
- singleGameSettingTableView
- SettingView
- LoginView
- ProfileView


### Controller
- PlaylistTableViewController
- HomeViewController
- PlayerViewController
- PlayerListViewController
- GameListTableViewController
- GameViewController
- EditTableViewController
- GameSettingTableViewController
- GameListSettingTableViewController
- singleGameSettingTableViewController
- SettingViewController
- LoginViewController
- ProfileViewController

