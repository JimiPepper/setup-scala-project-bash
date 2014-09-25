Setup a scala project for SBT
=============================

This bash script allows you to create a scala project handled by SBT tool.
Currently, you have to specify the project name for the first argument
and the default package path for the second one to run correctly the script.

The generation includes a complete local scala project with :
* sbt-eclipse plugin to import your project under Eclipse IDE
* sbt-assembly plugin to compile your application into a jar file
* scalatest library for unit testing
* predefined build.sbt & plugins.sbt
* Boot.scala file to start your project
* ExampleSpec.scala test file which runs under scalatest
* An empty local Git repository
* A mardown file README.md that you can edit

Warning : Actually, the script supposes you have the last version of Scala (2.11.2)


RECENT FIX
----------
* replace mkdir by mkdir -p. This will allow a better user experience if the directory already exists
* fix the reading of the script's parameters, we now handle the project name/package accordingly
* add fancy colors and bold text when prompting. The answer can be 'y' 'Y' or empty line, the later
will trigger the default choice (which is highlight in bold and red)
* if a project with the same name already exists, we quit instantly (avoid errors)
* plus some items on the todo list

TODO
----
Now, the next step is implementing options for :
* ~~Choose to create java directories into your project~~
* ~~Generate or not default scala files~~
* Add or not default plugins & libraries
* ~~Choose or not the current version of Scala on computer~~ <= this is not a good idea, sbt will
always try to download its "own version" into its .sbt/ directory... Ideally (i'm using this setup
right now), you don't install scala on your computer. You install a JRE/JDK, download sbt-launch.jar
and from there you pull everything you need (i.e. java -jar sbt-launch.jar console for a scala
interpreter, java -jar {...} compile, run, test and so on)
* Add new plugins
* Add new libraries
* ~~Create a default project if user uses the script without parameters~~
* Add your own plugins that you used to use in your project
* Write man page
* Add -h / --help option that indicates how to use this script
* Add alias inside .bashrc to launch 
* Some others features to which I haven't thought yet
