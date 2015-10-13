# cellHTS-wrappers
CGI web applications that wrap around cellHTS to process and manage cell base screening data sets


## General notes 

* Write the templates first. View source on existing pages to get a start point
* Break the templates up into re-usable chunks (header, footer, menu etc)
* Note what variables are needed in the templates so we can supply them later in the perl code
* cleanse the code of any literal paths (e.g. /home/user/data). Store these in the config
* review all SQL inputs and sanitise

## perl module
* save the more complex logic into a perl module and call this to create the application specific functionality
* some things can be shared between different apps (e.g. sorting screens in drug or RNAi screens)

## Add new screen
this has a lot of DB calls that could be collected together in one place rather than scattering them through the code

## save new screen
change this to refresh every 20 seconds or so until a complete state is found ($| does not work well)


## show all screens
Can use this same code/template for showing all screens, a subset or a sorted set. Include CGI params to define search and sort behaviour


## templates needed
These should be saved under ./lib
* header
* menu_rnai
* menu_drugs
* submit_screen_rnai
* submit_screen_drugs
* footer
* process_screen_working
* process_screen_done
* show_screens
* edit_screen
* show_qc_rnai
* show_qc_drugs




