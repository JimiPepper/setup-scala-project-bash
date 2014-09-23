Setup a scala project for SBT
=============================

This bash script allow you to create a scala project handled by SBT tool.
Currently, you have to precise the project name for the first argument
and the default package path for the second one to run correctly the script.

The generation includes a complete local scala project with :
* sbt-eclipse plugin for importing your project under Eclipse IDE
* sbt-assembly plugin for compiling your application into a jar file
* scalatest library for unit testing
* predefined build.sbt & plugins.sbt 
* Boot.scala file to start your project
* ExampleSpec.scala test file running under scalatest
* An empty local Git repository
* A mardown file README.md that you can edit

Warning : Actually, the script supposes you have the last version of Scala (2.11.2)

TODO
----
Now, the next step is implementing options for :
* Choose to generate java directories into your project
* Generate or not default scala files
* Add or not default plugins & libraries
* Choose or not the current version of Scala on computer
* Add new plugins
* Add new libraries
* Create a default project if user uses the script without arguments
* Some others features to which I haven't thought yet
