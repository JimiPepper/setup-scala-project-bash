#!/bin/bash

# last update : 22 / 09 / 2014
# Setup a scala directory project for SBT

# $1 : Project name
# $2 : Package path

error(){
	# echo 'setup-sbt-project.sh: invalid option --'\''z'\''' >&2
	echo 'Try '\''setup-sbt-project.sh --help'\'' for more information.' >&2
}

usage(){ 
	echo 'Usage: ./setup-sbt-project.sh [PROJECT NAME] [PATH_PACKAGE]'
 	echo 'Set up a Scala project for SBT tool\n'
	echo 'Mandatory arguments to long options are mandatory for short options too.'
	echo '-v, --sbtversion	    initialize your project with a specific version of SBT'
	echo '    --noplugin	    unable automatic plugin addition'
	echo '    --nolibrary	    unable automatic library addition'
	echo '    --nocvs,	    disable local repository creation'
	echo '    --svn		    create a local SVN repository instead nor Git'
      	echo '    --version         output version information and exit'
	echo '    --verbose         enable verbose format'
	echo '-h, --help            display this help and exit'
} 

version(){
	echo 'setup-sbt-project 1.1'
	echo 'Github repository : https://github.com/JimiPepper/setup-scala-project-bash'
	echo 'Written by Romain Philippon'
}

# SETUP VARIABLES
projectName='defaultScalaProject'
projectPackage='com.example'

# PARAMETERS TESTS
[ $# -gt 1 ] && projectName=$1 && projectPackage=$2 

# SETUP DIRECTORIES
mkdir -p $projectName/src/main $projectName/src/test $projectName/lib $projectName/project

pathMain="$projectName/src/main"
pathTest="$projectName/src/test"
pathProject="$projectName/project"

mkdir $pathMain/resources $pathMain/scala $pathMain/java
mkdir $pathTest/resources $pathTest/scala $pathTest/java

# SETUP / CREATE PACKAGE DIRECTORIES
pathPackageSMain=$pathMain/scala
for dir in $(echo $projectPackage | tr '.' ' ') ; do pathPackageSMain="$pathPackageSMain/$dir" ; mkdir $pathPackageSMain ; done

pathPackageJMain=$pathMain/java
for dir in $(echo $projectPackage | tr '.' ' ') ; do pathPackageJMain="$pathPackageJMain/$dir" ; mkdir $pathPackageJMain ; done

pathPackageSTest=$pathTest/scala
for dir in $(echo $projectPackage | tr '.' ' ') ; do pathPackageSTest="$pathPackageSTest/$dir" ; mkdir $pathPackageSTest ; done
pathPackageJTest=$pathTest/java
for dir in $(echo $projectPackage | tr '.' ' ') ; do pathPackageJTest="$pathPackageJTest/$dir" ; mkdir $pathPackageJTest ; done

# SETUP FILES
touch $projectName/build.sbt $projectName/README.md

# wc -c command counts the last caracter \0
cat <<EOF >> $projectName/README.md
$(echo $projectName)
$(for numero in $(seq 2 $(echo $projectName | wc -c)) ; do echo -n '=' ; done) 

Generated Scala Project for SBT

_Contains plugin :_
* sbt-eclipse
* sbt-assembly

_Contains library :_
* scalatest

EOF

touch $pathProject/build.properties $pathProject/plugins.sbt

touch $pathPackageSMain/Boot.scala
cat <<EOF >> $pathPackageSMain/Boot.scala
package $(echo $projectPackage)

object Boot extends App {
	Console.println("Hello World !!")
}
EOF

touch $pathPackageSTest/ExampleSpec.scala
cat <<EOF >> $pathPackageSTest/ExampleSpec.scala
package $(echo $projectPackage).test

import org.scalatest._

class ExampleSpec extends FunSuite {
	test("Return a welcome message") {
		val msg : String = "Hello and welcome"
		assert(msg == "Hello and welcome")
	}
}
EOF

echo 'Init directories...'

# WRITE BUILD.SBT

organization=''
for element in $(echo $projectPackage | tr '.' ' ' | rev) ; do organization=$organization.$(echo $element | rev) ; done
organization=${organization:1}

cat <<EOF >> $projectName/build.sbt
import AssemblyKeys._

// Project settings
name := "$(echo $projectName)"

organization := "$(echo $organization)"

version := "0.1"

scalaVersion := "2.11.2"

assemblySettings

// Assembly plugin settings
jarName in assembly := "$(echo $projectName | tr ' ' '_' | tr '[:upper:]' '[:lower:]').jar"

mainClass in assembly := Some("$(echo $projectPackage).Boot")

// Compiler settings
scalacOptions := Seq("-unchecked", "-deprecation", "-encoding", "utf8")

// Library settings
libraryDependencies += "org.scalatest" % "scalatest_2.11" % "2.2.1" % "test"

EOF

# ADD PLUGINS
# sbt-eclipse
cat <<EOF >> $pathProject/plugins.sbt
// Make SBT projects compatible with Eclipse IDE
// SBT command : eclipse
// https://github.com/typesafehub/sbteclipse'
addSbtPlugin("com.typesafe.sbteclipse" % "sbteclipse-plugin" % "2.5.0")

EOF

# sbt-assembly
cat <<EOF >> $pathProject/plugins.sbt
// Compile SBT projects files into jar
// SBT command : assembly
//https://github.com/sbt/sbt-assembly
addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.11.2")

EOF

echo 'Init sbt plugins (sbt-eclipse, sbt-assembly)'

# INITIALIZE LOCAL REPOSITORY
git init --quiet $projectName

echo 'Init local Git repository'
