# Lexan - GPG Encryption Manager
# Copyright (C) 2017, Josh M <mcu@protonmail.com>                     

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'curses'
include Curses

Curses.init_screen
Curses.curs_set(0)  # Invisible cursor
Curses.start_color

# Change the colors of your menu here.
Curses.init_pair(1, Curses::COLOR_WHITE, Curses::COLOR_RED)  # RED, MAGENTA, GREEN, BLUE, etc
Curses.init_pair(2, Curses::COLOR_WHITE, Curses::COLOR_GREEN)
Curses.init_pair(3, Curses::COLOR_GREEN, Curses::COLOR_BLACK)  # nav words color

Curses.noecho # echo or noecho to display user input
Curses.cbreak # do not buffer commands until Enter is pressed
Curses.raw # disable interpretation of keyboard input
Curses.nonl
Curses.stdscr.nodelay = 1

# Top Header
SCREEN_WIDTH       = 72
HEADER_HEIGHT      = 1
HEADER_WIDTH       = SCREEN_WIDTH

# Left Header
SCREEN_WIDTHLEFT      = 47
HEADER_HEIGHTLEFT     = 1
HEADER_WIDTHLEFT      = SCREEN_WIDTHLEFT

# Right Header
SCREEN_WIDTHRIGHT      = 20
HEADER_HEIGHTRIGHT     = 1
HEADER_WIDTHRIGHT      = SCREEN_WIDTHRIGHT

# MAIN MENU OPTION FUNCTIONS
def fstart           # function start
  Curses.close_screen
  system "clear" or system "cls"
end

def fend             # function end
  if $?.exitstatus > 0
    puts "You do not have GPG installed." 
  end
  puts "\n\nPress Enter to continue."
  gets # waits for the user to press enter
end

def fend2            # 2nd function end
  if $?.exitstatus > 0
    puts "\nThere was an error." 
  end
  puts "Press Enter to continue."
  gets # waits for the user to press enter
end

def placezero                              # create new key pair
  fstart  # call function
  system "gpg --gen-key"
  fend
end

def placeone                               # list keys
  fstart
  puts "This option lists all public and secret/private keys."
  puts "Do you want to list public or secret key? (Type 'p' or 's')"
  keytype = gets.chomp
  
  if keytype == "p"
    system "gpg --list-keys"
  elsif keytype == "s"
	  system "gpg --list-secret-keys"
  else
    puts "You did not choose public or secret."
  end
  fend
end

def placetwo                               # import and export keys
  fstart
  puts "You can import keys from other people.  You can also export keys to give to people."
  puts "Do you want to import or export a key? (Type 'i' or 'e')"
  impex = gets.chomp
	if impex = "i"
	    puts "Type the path and name of the key you are importing."
	    impname = gets.chomp
	    system "gpg --import " + impname
	    print impname + " imported."
  elsif impex = "e"
	  puts "This option exports the key to a text file."
	  puts "Do you want to export a public or secret key? (Type 'p' or 's')"
	  keytype = gets.chomp
	  
	  if keytype == "p"
	    puts "Type the path and name of the key your are exporting."
	    publicname = gets.chomp
	    puts "Type the name you want to give the secret key file."
	    keyname = gets.chomp
	    system "gpg -a --export " + publicname + " > " + keyname + ".txt"  # -a is the same as --armor
	    puts "Done."
	  elsif keytype == "s"
	    puts "Type the path and name of the key your are exporting."
	    secretname = gets.chomp
	    puts "Type the name you want to give the secret key file."
	    keyname = gets.chomp
	    system "gpg -a --export-secret-keys " + secretname + " > " + keyname + ".txt"
	    puts "Done."
	  else
	    puts "You did not choose public or secret."
	  end
	else
	  puts "You did not choose import or export."
	end
  fend2
end

def placethree                              # delete keys
  fstart
  puts "This option allows you to delete a key."
  puts "Do you want to delete a public or secret key? (Type 'p' or 's')"
  deletetype = gets.chomp
  if deletetype == "p"
    puts "Type the name of the actual key your are deleting."
    publicdelname = gets.chomp
    system "gpg --delete-key " + publicdelname

  elsif deletetype == "s"
    puts "Type the name of the actual key your are deleting."
    secretdelname = gets.chomp
    system "gpg --delete-secret-key " + secretdelname

  else
    puts "You did not choose public or secret."
  end
  fend2
end

def placefour                               # trust a key
  fstart
  puts "When importing a key from another location, you may have to configure\nGPG to trust the key."
  puts "Otherwise, GPG may prompt you to trust the key each time you use\ndecryption."
  puts "\nDo you want to go ahead and trust a key now? (Type 'y' or 'n')"
  trustkey = gets.chomp
  if trustkey == "y"
    puts "Type the name of the key you want to trust."
    trustname = gets.chomp
    system "clear" or system "cls"
    puts "\nYou will be placed in the GPG menu.  Once there, type the word 'trust'\nand press enter."
    puts "Then select the level of trust you want to give the key."
    puts "When you are finished you can type 'quit' and press enter."
    puts "\nEnter to Continue"
    gets 
    system "(gpg --edit-key " + trustname + "; trust)"
  elsif trustkey == "n"
    # do nothing
  else
    puts "You did not choose yes or no."
  end
  fend2
end

def placefive                             # quick encrypt
  fstart
  puts "Type the path and name of the file you want to encrypt."
  puts "Example:  /home/username/lexan.txt"
  quickfile = gets.chomp
  puts "Specify the name or recipient who shall be able to decrypt the file."
  quickrecipient = gets.chomp
  system "gpg --encrypt --recipient " + quickrecipient + " " + quickfile
  puts "\n " + quickfile + " encrypted."
  puts "\n\nPress Enter to continue."
  gets # waits for the user to press enter
end

def placesix                             # encrypt with name
  fstart
  puts "Type the path and name of the file you want to encrypt."
  puts "Example:  /home/username/lexan.txt"
  quickfile = gets.chomp
  puts "What do you want to name the encrypted file?  You can also specify\nthe directory you want it stored in."
  encryptname = gets.chomp
  puts "Type the key name or recipient who shall be able to decrypt the file."
  quickrecipient = gets.chomp
  system "clear" or system "cls"
  puts "Do you want to only allow the recipient to decrypt the file or\ndo you want to allow both you and the recipient to decrypt the file?"
  puts "(Type 'r' for recipient only or 'b' for both.)"
  whodecrypt = gets.chomp
  if whodecrypt == "r"
	  system "gpg -r " + quickrecipient + " --output " + encryptname + " --encrypt " + quickfile
	  puts "\n " + quickfile + " encrypted as" + encryptname + "."
	elsif whodecrypt == "b"
    system "clear" or system "cls"
	  puts "Type your own public key name here."
	  mykey = gets.chomp
	  system "gpg -r " + quickrecipient + " --encrypt-to " + mykey + " --output " + encryptname + " --encrypt " + quickfile
	  puts "\n " + quickfile + " encrypted as " + encryptname + "."
	else
	  puts "You did not choose r or b."
	end
	fend2
end

def placeseven                             # quick decrypt
  fstart
  puts "Type the path and name of the file you want to decrypt."
  puts "Example:  /home/username/lexan.pgp"
  quickfile = gets.chomp
  system "gpg " + quickfile
  puts "\n " + quickfile + " decrypted."
  puts "\n\nPress Enter to continue."
  gets # waits for the user to press enter
end

def placeeight                             # decrypt with name
  fstart
  puts "Type the path and name of the file you want to decrypt."
  puts "Example:  /home/username/lexan.gpg"
  quickfile = gets.chomp
  puts "What do you want to name the decrypted file?  You can also specify\nthe directory you want it stored in."
  decryptname = gets.chomp
  puts "Specify the key name or recipient who shall be able to decrypt the file."
  quickrecipient = gets.chomp
  system "gpg -r " + quickrecipient + " --output " + decryptname + " --decrypt " + quickfile
  puts "\n " + quickfile + " decrypted."
  puts "\n\nPress Enter to continue."
  gets # waits for the user to press enter
end

def placenine                           # terminal decrypt
  fstart
  puts "This option will decrypt and display readable documents to the terminal."
  puts "Do you want to do this? (Type 'y' or 'n')"
  terminaldisplay = gets.chomp
  if terminaldisplay == "y"  
    puts "Type the path and name of the document file you want to decrypt."
    puts "Example:  /home/username/lexandoc.pgp"
    displayfile = gets.chomp
    system "gpg --decrypt " + displayfile
    puts "\n\nPress Enter to continue."
    gets # waits for the user to press enter
  elsif terminaldisplay == "n"
    # do nothing
  else
    # do nothing
  end
end

def placeten                         # encrypt file for e-mail and web
  fstart
  puts "This option will encrypt a file to binary format so that the file\ncan be sent through e-mail or published on the web."
  puts "Do you want to do this? (Type 'y' or 'n')"
  terminaldisplay = gets.chomp
  if terminaldisplay == "y"  
    puts "Type the path and name of the file you want to export."
    binaryname = gets.chomp
    puts "Specify the key name or recipient who shall be able to decrypt the file."
    encrecipient = gets.chomp
    system "gpg -r " + encrecipient + " --armor --encrypt " + binaryname
    puts "\n\n" + binaryname + ".asc has been created."
    puts "Press Enter to continue."
    gets # waits for the user to press enter
  elsif terminaldisplay == "n"
    # do nothing
  else
    # do nothing
  end
  fend2
end

def placeeleven                         # create or verify signature file
  fstart
  puts "GPG can create and verify detached signatures or .asc files."
  puts "A detatched signature allows your to verify if a file you've\ndownloaded is the one it's creator wants you to have."
  puts "This option allows you to create a signature for a file or\nverify a signature for a file."
  puts "Do you want to create or verify? (Type 'c' or 'v')"
  detsig = gets.chomp
  if detsig == "c"
    system "clear" or system "cls"
    puts "Type the path and name of the file you want to create a\nsignature for."
    puts "Example:  /home/username/lexan.tar.gz"
    create = gets.chomp
    system "gpg --armor --detach-sign " + create
    puts create + ".asc created."
  elsif detsig == "v"
    system "clear" or system "cls"
    puts "Type the path and name of the signature you want to verify.\nIt will end with .asc"
    puts "Example:  /home/username/lexan.asc"
    asc = gets.chomp
    puts "Type the path and name of the the file you want to match the signature to."
    puts "Example:  /home/username/lexan.tar.gz"
    sigfile = gets.chomp
    system "gpg --verify " + asc + " " + sigfile
  else
    puts "You did not choose create or verify."
  end
  fend2
end

begin
  
	# Title Bar
	header_window = Curses::Window.new(HEADER_HEIGHT, HEADER_WIDTH, 0, 0)   # (height, width, top, left)
	header_window.color_set(1)
	header_window << "Lexan   ::   Encryption Manager".center(HEADER_WIDTH)
	header_window.refresh
	
	header2_window = Curses::Window.new(HEADER_HEIGHTLEFT, HEADER_WIDTHLEFT, 2, 2)
	header2_window.color_set(2)
	header2_window << "Main Menu".center(HEADER_WIDTHLEFT)
	header2_window.refresh
	
	header3_window = Curses::Window.new(HEADER_HEIGHTRIGHT, HEADER_WIDTHRIGHT, 2, 50)
	header3_window.color_set(2)
	header3_window << "Navigation".center(HEADER_WIDTHRIGHT)
	header3_window.refresh
	
	
	# right side navigation menu
	nav = Window.new(20, 20, 3, 50)  # (height, width, top, left)
	nav.attrset(Curses.color_pair(3) | Curses::A_BOLD)
	# nav.box('|', '-')
	nav.setpos(1, 2)
	nav.addstr "Select (Enter)"
	nav.setpos(2, 2)
	nav.addstr "Up     (W)"
	nav.setpos(3, 2)
	nav.addstr "Down   (S)"
	nav.setpos(4, 2)
	nav.addstr "Exit   (X)"
	nav.refresh
	
	
	# static text for main window
	def draw_menu(menu, active_index=nil)
	  ["Get started with new key.", "List keys.", "Import and export keys.", "Delete keys.", "Trust a key.", "Quick encrypt.", "Encrypt with name.",\
     "Quick decrypt.", "Decrypt with name.", "Terminal decrypt.", "Encrypt file for e-mail and web.", "Create or verify signature file."].each_with_index do |element, index|
	  # "w" for word array
	  # It's a shortcut for arrays
	    menu.setpos(index + 1, 1)
	    menu.attrset(index == active_index ? A_STANDOUT : A_NORMAL)
    j = "#{index}."            
		menu.addstr(j.ljust(4) + element)   # left justify
	  end
	  menu.setpos(5, 1)
	end
	
	# refresh text for main menu
	def draw_info(menu, text)
	  menu.setpos(14, 30)  # sets the position of move up and down
	                     # for example, menu.setpos(1, 10) moves to another
	                     # location
	  menu.attrset(A_NORMAL)
	  menu.addstr text
	end
	
	
	# user navigation for main window
	position = 0

	menu = Window.new(20, 47, 3, 2)  # (height, width, top, left)
	menu.keypad = true  # enable keypad which allows arrow keys
	# menu.box('|', '-')
	draw_menu(menu, position)
	while ch = menu.getch
	  stdscr.keypad = true
	  case ch
	  when KEY_UP, 'w'
	    #draw_info menu, 'move up'
	    position -= 1
	  when KEY_DOWN, 's'
	    #draw_info menu, 'move down'
	    position += 1
	  when 13
	    if position.zero?
		    placezero # function goes here
	    elsif position == 1
		    placeone
		  elsif position == 2
		    placetwo
      elsif position == 3
        placethree
      elsif position == 4
        placefour
      elsif position == 5
        placefive
      elsif position == 6
        placesix
      elsif position == 7
        placeseven
      elsif position == 8
        placeeight
      elsif position == 9
        placenine
      elsif position == 10
        placeten
      elsif position == 11
        placeeleven
	    else
		  Curses.close_screen
		  system "clear" or system "cls"
		  puts "Test 2."
		  puts "\n\nPress Enter to continue."
		  gets # waits for the user to press enter
	    end
	  when 'x'
	    exit
	  end
	  position = 11 if position < 0
	  position = 0 if position > 11
	  draw_menu(menu, position)
	  draw_info menu, "Select Option #{position}."   
	end

rescue => ex
  Curses.close_screen
end
