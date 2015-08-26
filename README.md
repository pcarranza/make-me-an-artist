Make me an artist
-----------------

Maybe in reply to [make me a rockstar](https://github.com/avinassh/rockstar)

This is a way of vandalising my contributions stream with some 7 bits pixel art.

This is probably the product of trying to use [ghdecoy](https://github.com/tickelton/ghdecoy), but finding out that if you do have some activity it was just not covering that. So, one thing lead to another, I have my own vandalism^H^H^H^H^H^H^H^H^H production tool.


##How to use

* `vi bin/make_me_an_artist`
* (change design and configuration as wished)
* `./bin/make_me_an_artist`
* push the local repo to a repo of your choice

## What will happen

* The tool will fetch all your contributions
* It will calculate the ranges needed to represent the required design.
* It will build up a plan of commits that has to happen on each day of your contributions.
* With this plan, the tool will create a repository /tmp/noise (unless some other path is declared)
* It then will commit to match the commit plan.

## What do you need to do then?

* Create a repo for this
* Add the remote origin
* `git push -f origin master`

## Links

* For drawing designs [gitfiti painter](http://codepen.io/cbas/pen/vOXeKV)
* For inspiration [hintjens](https://github.com/hintjens)

* Similar tools:
** [ghdecoy](https://github.com/tickelton/ghdecoy)
** [github-board](https://github.com/bayandin/github-board)
** [gitfiti](https://github.com/gelstudios/gitfiti) <= Here you can pick more designs
