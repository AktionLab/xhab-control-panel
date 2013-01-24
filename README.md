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

This setup guide assumes you are operating a bash terminal (or similar) in a Linux environment.

First, install RVM, the Ruby version manager. The typical RVM installation is per-user, so you'll want to install this as your own user, not as root.

    \curl -L https://get.rvm.io | bash -s stable --ruby

RVM allows you to install different versions of Ruby on your machine, and to use specific versions for any given Ruby project. For this application, we are using Ruby version 1.9.3-p327. So, assuming RVM installed correctly, you can now install the specific version of ruby we're using:

    rvm install 1.9.3-p327

That'll probably take a few minutes to configure and build.

Ruby on Rails requires a Javascript runtime. If you don't already have one on your system, install node. But first, make sure you've installed the required dependencies:

    sudo apt-get update
    sudo apt-get install build-essential git python libssl-dev

Now you can install node. You may want to check the node website and adjust the following commands so that you are installing the latest version of node:

    cd /usr/local/src
    sudo mkdir node
    cd node
    sudo wget http://nodejs.org/dist/v0.8.18/node-v0.8.18.tar.gz
    sudo tar -xzvf node-v0.8.18.tar.gz
    cd node-v0.8.18
    sudo ./configure
    sudo make
    sudo make install

Expect that to take a bit of time to build. Once you have node installed (or already had a Javascript runtime on your system), you can continue setting up the project.

Next, clone the project from github.

    git clone git@github.com:AktionLab/xhab-control-panel.git

A new directory will be created, called xhab-control-panel, and the project files will be downloaded into it. When you change into the project directory, RVM should notify you that a new .rvmrc file has been detected, and will ask you if you would like to use it. Choose yes.

The first thing you need to do when working with any Rails project is to run bundler. Bundler is an application that manages all your project's gems (packages), that are used in the application. The gems that are used in the application are defined in the Gemfile. Now, run bundler to pull in all the required gems and their dependencies:

    bundle install

After bundler fetches and installs all the gems, you'll want to make sure your database schema is up to date. For this project, we're using sqlite in development, so you don't need to create a separate MySQL database. Simply run the rake command to update your sqlite database schema to the last revision:

    rake db:migrate

Rails uses a system of database migration files to achieve version control of the database, allowing you to move back in time to previous database schemas if you want. Similar to how git keeps track of changes to the codebase over time, migrations track changes to the database schema, and are a key feature of Rails.

There may be seed data for the project, so you'll want to run a rake command to generate the seed data:

    rake db:seed

At this point you should have everything you need to run the application. To start up the rails server:

    rails s

That will run the default Rails web server, Webrick, on port 3000. To load the site, just point your browser to http://localhost:3000.
