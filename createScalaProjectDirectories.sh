#!/bin/bash

# last update : 22 / 09 / 2014
# Setup a scala directory project for SBT

# $1 : Project name
# $2 : Package path

# SETUP DIRECTORIES
mkdir $1
mkdir $1/src $1/lib $1/project
mkdir $1/src/main $1/src/test

pathMain="$1/src/main"
pathTest="$1/src/test"
pathProject="$1/project"

mkdir $pathMain/resources $pathMain/scala $pathMain/java
mkdir $pathTest/resources $pathTest/scala $pathTest/java

# SETUP PACKAGE DIRECTORIES
pathPackageSMain=$pathMain/scala
for dir in $(echo $2 | tr '.' ' ') ; do pathPackageSMain="$pathPackageSMain/$dir" ; mkdir $pathPackageSMain ; done

pathPackageJMain=$pathMain/java
for dir in $(echo $2 | tr '.' ' ') ; do pathPackageJMain="$pathPackageJMain/$dir" ; mkdir $pathPackageJMain ; done

pathPackageSTest=$pathTest/scala
for dir in $(echo $2 | tr '.' ' ') ; do pathPackageSTest="$pathPackageSTest/$dir" ; mkdir $pathPackageSTest ; done
pathPackageJTest=$pathTest/java
for dir in $(echo $2 | tr '.' ' ') ; do pathPackageJTest="$pathPackageJTest/$dir" ; mkdir $pathPackageJTest ; done

# SETUP FILES
touch $1/build.sbt
touch $1/README.md
# wc -c command counts the last caracter \0
cat <<EOF >> $1/README.md
$(echo $1)
$(for numero in $(seq 2 $(echo $1 | wc -c)) ; do echo '=' ; done) 

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
package $(echo $2)

object Boot extends App {
	Console.println("Hello World !!")
}
EOF

touch $pathPackageSTest/ExampleSpec.scala
cat <<EOF >> $pathPackageSTest/ExampleSpec.scala
package $(echo $2).test

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
for element in $(echo $2 | tr '.' ' ' | rev) ; do organization=$organization.$(echo $element | rev) ; done
organization=${organization:1}

cat <<EOF >> $1/build.sbt
import AssemblyKeys._

// Project settings
name := "$(echo $1)"

organization := "$(echo $organization)"

version := "0.1"

scalaVersion := "2.11.2"

assemblySettings

// Assembly plugin settings
jarName in assembly := "$(echo $1 | tr ' ' '_' | tr '[:upper:]' '[:lower:]').jar"

mainClass in assembly := Some("$(echo $2).Boot")

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
git init --quiet $1

echo 'Init local Git repository'
