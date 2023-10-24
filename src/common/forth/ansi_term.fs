\ Copyright (c) 2021-2023 Travis Bemann
\ 
\ Permission is hereby granted, free of charge, to any person obtaining a copy
\ of this software and associated documentation files (the "Software"), to deal
\ in the Software without restriction, including without limitation the rights
\ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
\ copies of the Software, and to permit persons to whom the Software is
\ furnished to do so, subject to the following conditions:
\ 
\ The above copyright notice and this permission notice shall be included in
\ all copies or substantial portions of the Software.
\ 
\ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
\ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
\ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
\ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
\ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
\ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
\ SOFTWARE.

\ Compile this to flash
compile-to-flash

begin-module ansi-term

  systick import

  begin-module ansi-term-internal

    \ Saved entered byte
    user saved-key

    \ Show cursor count
    user show-cursor-count

    \ Preserve cursor count
    user preserve-cursor-count
    
  end-module> import
  
  compress-flash

  \ Character constants
  $1B constant escape
    
  \ Type a decimal integer
  : (dec.) ( n -- ) base @ 10 base ! swap (.) base ! ;

  \ Type the CSI sequence
  : csi ( -- )
    [: $1B emit [char] [ emit ;] critical
  ;

  commit-flash

  \ Show the cursor
  : show-cursor ( -- )
    [: csi [char] ? emit 25 (dec.) [char] h emit ;] critical
  ;

  \ Hide the cursor
  : hide-cursor ( -- )
    [: csi [char] ? emit 25 (dec.) [char] l emit ;] critical
  ;

  \ Save the cursor position
  : save-cursor ( -- ) [: csi [char] s emit ;] critical ;

  \ Restore the cursor position
  : restore-cursor ( -- ) [: csi [char] u emit ;] critical ;

  \ Scroll up screen by a number of lines
  : scroll-up ( lines -- )
    [: csi (dec.) [char] S emit ;] critical
  ;

  \ Move the cursor to specified row and column coordinates
  : go-to-coord ( row column -- )
    [: swap csi 1+ (dec.) [char] ; emit 1+ (dec.) [char] f emit ;] critical
  ;

  \ Erase from the cursor to the end of the line
  : erase-end-of-line ( -- ) [: csi [char] K emit ;] critical ;

  \ Erase the lines below the current line
  : erase-down ( -- ) [: csi [char] J emit ;] critical ;

  \ Query for the cursor position
  : query-cursor-position ( -- )
    [: csi [char] 6 emit [char] n emit ;] critical
  ;

  commit-flash
  
  \ Show the cursor with a show/hide counter
  : show-cursor ( -- )
    1 show-cursor-count +! show-cursor-count @ 0 = if show-cursor then
  ;

  \ Hide the cursor with a show/hide counter
  : hide-cursor ( -- )
    -1 show-cursor-count +! show-cursor-count @ -1 = if hide-cursor then
  ;

  commit-flash

  \ Execute code with a hidden cursor
  : execute-hide-cursor ( xt -- ) hide-cursor try show-cursor ?raise ;

  \ Clear a saved key
  : clear-key ( -- ) 0 saved-key ! ;

  \ Get a key
  : get-key ( -- b )
    saved-key @ ?dup if 0 saved-key ! else key then
  ;

  \ Get whether a key is available
  : get-key? ( -- flag ) saved-key @ if true else key? then ;

  \ Save a key
  : set-key ( b -- ) saved-key ! ;

  commit-flash
  
  \ Wait for a number
  : wait-number ( -- n matches )
    ram-here >r get-key dup [char] - = if
      ram-here c! 1 ram-allot
    else
      set-key
    then
    0 begin
      dup 10 < if
	get-key dup [char] 0 >= over [char] 9 <= and if
	  ram-here c! 1 ram-allot 1+ false
	else
	  set-key true
	then
      else
	true
      then
    until
    drop base @ 10 base ! r@ ram-here r@ - parse-unsigned
    rot base ! r> ram-here!
  ;
  
  \ Wait for a character
  : wait-char ( b -- ) begin dup get-key = until drop ;

  \ Confirm that a character is what is expected
  : expect-char ( b -- flag )
    get-key dup rot = if drop true else set-key false then
  ;

  commit-flash
  
  \ Get the cursor position
  : get-cursor-position ( -- row column )
    [:
      begin
	clear-key query-cursor-position escape wait-char
	[char] [ expect-char if
	  wait-number if
	    1 - [char] ; expect-char if
	      wait-number if
		[char] R expect-char if
		  1 - true
		else
		  2drop false
		then
	      else
		drop false
	      then
	    else
	      drop false
	    then
	  else
	    drop false
	  then
	else
	  false
	then
      until
    ;] execute-hide-cursor
  ;

  commit-flash

  \ Execute code while preserving cursor position
  : execute-preserve-cursor ( xt -- )
    1 preserve-cursor-count +!
    preserve-cursor-count @ 1 = if
      save-cursor try restore-cursor
    else
      get-cursor-position >r >r try r> r> go-to-coord
    then
    -1 preserve-cursor-count +! ?raise
  ;

  \ Actually get the terminal size
  : get-terminal-size ( -- rows columns )
    [:
      get-cursor-position
      1000 1000 go-to-coord
      get-cursor-position swap 1+ swap 1+
      2swap go-to-coord
    ;] execute-hide-cursor
  ;

  \ Reset terminal state
  : reset-ansi-term ( -- ) 0 show-cursor-count ! 0 saved-key ! ;

  \ Clear window in ticks
  100 constant clear-ticks

  commit-flash
  
  \ Clear input of multiple escaped characters
  : clear-keys ( -- )
    systick-counter clear-ticks +
    begin
      get-key? if
	get-key dup escape = if
	  set-key true
	else
	  drop dup systick-counter <
	then
      then
    until
    drop
  ;
  
end-module

commit-flash

\ Clear the console
: page ( -- )
  [:
    ansi-term::csi [char] 2 emit [char] J emit
    ansi-term::csi [char] H emit
  ;] critical
;

end-compress-flash

\ Reboot
reboot
