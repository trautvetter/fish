============
Project fish
============

Description
-----------

Fish is an options organization tool for bash scripts.
It allows you to add functionality to your script and quickly hook up switches to use it, and maintain the help/usage so that you don't forget how to use it.

With one or two lines of configuration text you define how your new functions will be called, and simultaneously maintain the usage text.


If your function is called with longopts style switches and you want to provide short-cuts simply add a line to the config table. You can use longopts, shortopts, or bare opts styles (-o, --option, o, option).
When you run fish it will parse the options you pass in and map them to the correct options that the function is equipped to handle.

Here's an example - four ways to use the "fish" functionality available in the fish project
- ``$ ./fish --fish 3``
- ``$ ./fish fish 3``
- ``$ ./fish -f 3``
- ``$ ./fish f 3``

and two ways to use the "fish" functionality with one of its sub commands
- ``$ ./fish -f 3 more``
- ``$ ./fish -f 3 m``


