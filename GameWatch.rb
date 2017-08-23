#!/usr/bin/env ruby

# This application will check the major sports for any close games and rank games in order of importance to the user. 
# The user will get a notification if a game is of particular interest.

# Pseudocode:
# 
# Download website information from ESPN
# Parse website and put data into a hash
# Develop a ranking system for determing which game is most important
#   Rank the order of the sports
#   Rank close game
#   Rank end of game
#   Rank ranking of the team
# For now, output the upcoming game that is of most interest

# Need functions for:
#   Accessing website
#   Parsing data

require_relative 'espn'

module GameWatch
    MAJOR_SPORTS = ['mens-college-basketball',
                    'womens-college-basketball',
                    'college-football',
                    'nfl',
                    'nba',
                    'mlb',
                    'nhl']
    
end

# Launch the app
GameWatch::ESPN.new