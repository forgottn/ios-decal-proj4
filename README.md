# FGC Network

## Authors
- Peter Duong

## Purpose
- The FGC Network allows fighting game players to view streams and videos from 
various fighting games as well as view the profiles of other players. 

## Features
- OAuth using Twitter, FB to make an Account
- Player Profiles 
  - Gamertag, Full Name, Birthday, Age, Nationality, Games Play, Characters 
  Used
- Using Youtube API, we can look for content from official channels
- Using Twitch API, we can look for streams

## Control Flow
- User opens the app to a login screen with two buttons, allowing them to 
  login with Twitter, FB
- If it is their first time logging in, they will be presented with views to 
  fill in necessary information, otherwise they'll be presented with a tab view
  - The default view is a games view, where the user can look up official
  content and streams
  - The second tab is a profile search view, where the user can go through
  various games and find players' profiles by character
  - The other tab is the player's own profile, which they can edit their 
  information
    - Here the user can view information and the games the user has played
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

