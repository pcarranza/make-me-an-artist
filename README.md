Contributions noise generator
-----------------------------

I am not my contributions.


Heavily influenced by [hintjens](https://github.com/hintjens) (and his work on psychopats).

This is a way of vandalising my contributions stream with some 7 bits pixel art.

This is a way of putting some noise into my github contributions so my contributions do not define me by the frequency, but by the image I want a bot to draw for me.


## How to use

* Provide some art form, probably in a file that can be eval with ruby, something that returns an array of arrays, in a 54x7 shape.
* Provide your username also so the tool can get your contributions.
* Provide a minimum to flatten things, the tool will default to a minimum of 1 commit for any day without any activity.
* Provide a repository name to use, it has to exist
* Optionally, provide an array with the max value for each segment of values to use in an hashmap: 0 => 0, 1 => 50, 2 => 100, 3 => 150
* Optionally, the commit message to use
* Optionally, a folder where the `noise` project exists

## What will happen

* The tool will fetch all your contributions
* If you did not provided the segments map, it will look for the max number of contributions, this will map to the max number of commits for the 1 segment. So if you have a maximum number of contributions of 9 in your best day the tool will map the general value of 1 to a maximum of 9+1, and the next segment (2) will start in 11. The subsequent segments will then map to 2 and 3 times the max +1 each (3 => (x + 1) * 2, 4 => (x + 1) * 3).
* It will build up a plan of commits that has to happen on each day of your contributions to map with the desired design.
* With this plan, the tool will pull the existing repository to a temporary folder.
* It will generate all the required commits to match the commit plan.
* It will run the changes, creating empty commits.
* It will push the changes into the repo.


## Other tools

http://codepen.io/cbas/pen/vOXeKV

## Inspirations

https://github.com/bayandin/github-board
https://github.com/gelstudios/gitfiti
