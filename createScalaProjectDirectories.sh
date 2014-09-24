#!/bin/bash

# last update : 22 / 09 / 2014
# Setup a scala directory project for SBT

# $1 : Project name
# $2 : Package path

# COLORS / FANCY OUTPUT
RED="\033[0;31m"
GRN="\033[0;32m"
BLU="\033[0;34m"
WHT="\033[0;37m"
BOLD="\E[1m" # output of "bold=`tput bold`; $bold"
NRML="\E(B\E[m" # output of "normal=`tput sgr0`; $normal"

# SETUP VARIABLES
projectName='defaultScalaProject'
projectPackage='com.example'

# PARAMETERS TESTS
[ "$#" -eq 2 ] && projectName=$1 && projectPackage=$2

# CHECK IF THE PROJECT ALREADY EXISTS
if [ -d $projectName ]; then
    echo -e $RED$BOLD"Failed !!!"$WHT$NRML "This name is already used for another project, delete it first."
    exit 1
fi

echo -e "Project name : "$GRN$projectName$WHT
echo -e "Package name : "$GRN$projectPackage$WHT

# SETUP DIRECTORIES
mkdir -p $projectName/src/main $projectName/src/test $projectName/lib $projectName/project

pathMain="$projectName/src/main"
pathTest="$projectName/src/test"
pathProject="$projectName/project"

mkdir -p $pathMain/scala
mkdir -p $pathTest/scala

# SETUP / CREATE PACKAGE DIRECTORIES
pathPackageSMain=$pathMain/scala
for dir in $(echo $projectPackage | tr '.' ' '); do
    pathPackageSMain="$pathPackageSMain/$dir"; mkdir -p $pathPackageSMain
done

pathPackageSTest=$pathTest/scala
for dir in $(echo $projectPackage | tr '.' ' '); do
    pathPackageSTest="$pathPackageSTest/$dir"; mkdir -p $pathPackageSTest
done

echo -ne "Do you need a "$GRN$BOLD"resources"$WHT$NRML" directory ? ["$RED$BOLD"Y"$WHT$NRML"|n] "
read resources_choice
if [ "$resources_choice" = "y" ] || [ "$resources_choice" = "Y" ] || [ "$resources_choice" = "" ]; then
    mkdir -p $pathMain/resources
    mkdir -p $pathTest/resources
fi

echo -ne "Do you need a "$GRN$BOLD"java"$WHT$NRML "directory ? ["$RED$BOLD"Y"$WHT$NRML"|n] "
read java_choice
if [ "$java_choice" = "y" ] || [ "$java_choice" = "Y" ] || [ "$java_choice" = "" ]; then
    mkdir -p $pathMain/java
    pathPackageJMain=$pathMain/java
    for dir in $(echo $projectPackage | tr '.' ' '); do
        pathPackageJMain="$pathPackageJMain/$dir"; mkdir -p $pathPackageJMain
    done

    mkdir -p $pathTest/java
    pathPackageJTest=$pathTest/java
    for dir in $(echo $projectPackage | tr '.' ' '); do
        pathPackageJTest="$pathPackageJTest/$dir"; mkdir -p $pathPackageJTest
    done
fi


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
