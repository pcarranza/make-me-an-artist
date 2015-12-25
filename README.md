Make me an artist
-----------------

*Maybe* in reply to [make me a rockstar](https://github.com/avinassh/rockstar)

This is a way of vandalising my github contributions stream with some 7 bits pixel art.

This is the product of trying to use [ghdecoy](https://github.com/tickelton/ghdecoy), and then realizing that if you do have some actual activity it was just not covering that.

So, one thing lead to another... I have my own vandalism\^H\^H\^H\^H\^H\^H\^H\^H\^H production tool.


##How to use

* `vi bin/make_me_an_artist`
* (change design and configuration as wished)
* `./bin/make_me_an_artist`
* push the local repo to a repo of your choice in github (I use **noise** as a repo name)

## What will happen

* The tool will fetch all your contributions from github
* It will calculate the ranges needed to represent the required design.
* It will build up a plan of commits that has to happen on each day of your contributions.
* With this plan, the tool will create a repository `/tmp/<repo>` (unless some other path is declared)
* It then will commit to match the commit plan.

## What do you need to do then?

* Create a repo for this in your github account
* Add the remote origin to your local *noise* repo
* `git push -f origin master`

## Links

* For drawing designs [gitfiti painter](http://codepen.io/cbas/pen/vOXeKV)
* For inspiration [hintjens](https://github.com/hintjens)

* Similar tools and inspirations:
    * [ghdecoy](https://github.com/tickelton/ghdecoy)
    * [github-board](https://github.com/bayandin/github-board)
    * [gitfiti](https://github.com/gelstudios/gitfiti) <= Here you can pick more designs
