#!/bin/bash

# last update : 22 / 09 / 2014
# Setup a scala directory project for SBT

# $1 : Project name
# $2 : Package path

# SCRIPT FUNCTIONS
error(){
	# echo 'setup-sbt-project.sh: invalid option --'\''z'\''' >&2
	echo 'Try '\''setup-sbt-project.sh --help'\'' for more information.' >&2
	exit 1
}

usage(){ 
	echo 'Usage: ./setup-sbt-project.sh [PROJECT NAME] [PATH_PACKAGE]'
 	echo 'Set up a Scala project for SBT tool\n'
	echo 'Mandatory arguments to long options are mandatory for short options too.'
	# echo '-v, --sbtversion	    initialize your project with a specific version of SBT'
	echo '    --nojava	    unable automatic creation java directories'
	echo '    --noplugin	    unable automatic plugin addition'
	echo '    --nolibrary	    unable automatic library addition'
	echo '    --nocvs	    disable local repository creation'
	echo '    --svn		    create a local SVN repository instead nor Git'
	echo '-q, --quiet	    perform operations quietly'
      	echo '    --version         output version information and exit'
	echo '    --verbose         enable verbose format'
	echo '-h, --help            display this help and exit'
	exit 0;
} 

version(){
	echo 'setup-sbt-project 1.1'
	echo 'Github repository : https://github.com/JimiPepper/setup-scala-project-bash'
	echo 'Written by Romain Philippon with the help of William Gouzer'
	exit 0
}

makeScalaDir() {
	mkdir -p $1/scala/$(echo $projectPackage | tr '.' '/')
	mkdir -p $2/scala/$(echo $projectPackage | tr '.' '/')
}

makeJavaDir() {
	mkdir -p $1/java/$(echo $projectPackage | tr '.' '/')
	mkdir -p $2/java/$(echo $projectPackage | tr '.' '/')
}

# SETUP SCRIPT VARIABLES
# environment variables
projectName='defaultScalaProject'
projectPackage='com.example'

# variables to handle options
quiet=0
useCVS=1
useGit=1
usePlugin=1
useLibrary=1
useJavaDir=1
useVerbose=0

# PARAMETERS TESTS
if [ $# -gt 1 ]
then
	projectName=$1 && projectPackage=$2 

	options=$(getopt -o h,q: -l nojava noplugin nolibrary nocvs svn quiet version verbose help -- "$@") 

	# éclatement de $options en $1, $2... 
	set -- $options 

	while true 
	do 
		case "$1" in
		--nojava) useJavaDir=0
			shift;;
		--noplugin) usePlugin=0
			shift;;
		--nolibrary) useLibrary=0
			shift;;
		--nocvs) useCVS=0
			shift;;
		--svn) useGit=0	
			shift;;
		--quiet) quiet=1
			shift;;
		--version) version
			shift;;
		--verbose) useVerbose=1
		       shift;;	
		-h|--help) usage 
			shift;; 
		--) echo "Fin param" # end options 
			shift
			break;; 
		*) error 
			shift;; 
		esac 
	done
fi

# SETUP DIRECTORIES
mkdir -p $projectName/src/main $projectName/src/test $projectName/lib $projectName/project

pathMain="$projectName/src/main"
pathTest="$projectName/src/test"
pathProject="$projectName/project"

mkdir $pathMain/resources $pathTest/resources

[ $useJavaDir -eq 1 ] && makeJavaDir $pathMain $pathTest
makeScalaDir $pathMain $pathTest

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

touch $pathMain/scala/"(echo $projectPackage | tr '.' '/')/Boot.scala
cat <<EOF >> $pathPackageSMain/Boot.scala
package $(echo $projectPackage)

object Boot extends App {
	Console.println("Hello World !!")
}
EOF

touch $pathTest"/scala/"$(echo $projectPackage | tr '.' '/')/ExampleSpec.scala
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
[ $useCVS -eq 1 ] && if [ $useGit -eq 1 ] ; then git init --quiet $projectName ; else svnadmin create projectName

echo 'Init local Git repository'
