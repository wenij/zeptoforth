\ Copyright (c) 2021 Travis Bemann
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

\ Set up the wordlist
forth-wordlist 1 set-order
forth-wordlist set-current

\ Make sure task-wordlist exists
defined? task-wordlist not [if]
  :noname space ." task is not installed" cr ; ?raise
[then]

\ Test to make sure this has not already been compiled
defined? task-wordlist not [if]

  \ Compile this to flash
  compile-to-flash

  \ Set up the actual wordlist
  wordlist constant task-pool-wordlist
  wordlist constant task-pool-internal-wordlist
  forth-wordlist task-wordlist task-pool-internal-wordlist task-pool-wordlist
  4 set-order
  task-pool-internal-wordlist set-current

  \ Task pool structure
  begin-structure task-pool-size
    \ Task pool count
    field: task-pool-count

    \ Task stack size
    hfield: task-pool-stack-size

    \ Task rstack size
    hfield: task-pool-rstack-size

    \ Task dictionary size
    field: task-pool-dict-size
  end-structure

  \ Get a task in a task pool
  : get-task ( index task-pool -- task )
    task-pool-size + swap cells + @
  ;

  \ Do nothing
  : nothing ( -- ) ;

  \ Switch wordlists
  task-pool-wordlist set-current
  
  \ Get the size of a task pool of a given size
  : get-task-pool-size ( count -- bytes ) cells task-pool-size + ;

  \ Spawn a task from a task pool
  : spawn-from-task-pool ( xt task-pool -- task )
    begin-critical
    dup task-pool-count @ 0 ?do
      i over get-task dup terminated? not if
	i swap get-task tuck init-task unloop exit
      then
    loop
    2drop 0 end-critical
  ;
  
  \ Initialize a task pool
  : init-task-pool ( dict-size stack-size rstack-size count addr -- )
    tuck task-pool-count !
    tuck task-pool-rstack-size h!
    tuck task-pool-stack-size h!
    tuck task-pool-dict-size !
    dup task-pool-count @ 0 ?do
      ['] nothing
      over dup task-pool-dict-size @
      swap dup task-pool-stack-size h@
      swap task-pool-rstack-size h@ spawn
      dup kill
      over task-pool-size + i cells + !
    loop
    drop
  ;

[then]