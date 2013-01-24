X-Hab Control Panel
===================

This application provides the Control Panel user interface for the 2012-2013 X-Hab Remote Plant Food Production project at CU Boulder.

The application is based on the Ruby on Rails framework and is written in Ruby, however the user interface itself consists of Javascript, HTML, and CSS.

Prerequisites
-------------

To develop and run this application, you should have at least a basic understanding of these technologies:

- Ubuntu Linux
- Ruby
- HTML/CSS/SASS
- Javascript/Coffeescript
- git
- RVM (Ruby version manager)

Environment Setup
-----------------

This setup guide assumes you are opertaing a bash terminal (or similar) in a Linux environment.

First, install RVM, the Ruby version manager. Do this as your own user, not as root.

    $ \curl -L https://get.rvm.io | bash -s stable --ruby

RVM allows you to install different versions of Ruby on your machine, and to use specific versions for any given Ruby project. For this application, we are using Ruby version 1.9.3-p327. So, assuming RVM installed correctly, you can now install the specific version of ruby we're using:

    rvm install 1.9.3-p327

That'll probably take a few minutes to configure and build.

Once you have Ruby installed, clone the project from github.

    git clone 
