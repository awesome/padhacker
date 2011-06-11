#!/bin/sh

# Launches development environment stuff
  
  osascript <<-eof
    set app_directory to "~/projects/padhacker"
    
	tell application "iTerm"

		set staticterm to (make new terminal)
		tell staticterm

			launch session "Default session"
			tell the last session
				set name to "Haml"
				write text "watchhaml " & app_directory & "/ui_source " & app_directory & "/ui"
			end tell

			launch session "Default session"
			tell the last session
				set name to "Compass"
				write text "cd " & app_directory
				write text "compass watch --sass-dir ui_source/ --css-dir ui/ -s compact"
			end tell

			launch session "Default session"
			tell the last session
				set name to "CoffeeScript"
				write text "cd " & app_directory
				write text "coffee -o ui/ -w -c ui_source/*.coffee"
			end tell

			launch session "Default session"
			tell the last session
				set name to "Livereload"
				write text "cd " & app_directory
				write text "livereload"
			end tell

			launch session "Default session"
			tell the last session
				set name to "Server"
				write text "cd " & app_directory & "/ui/"
				write text "staplesx runserver --cwd"
			end tell

		end tell
	end tell

eof
