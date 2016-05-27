# InsightEdge
##### _InsightEdge GigaSpaces convergence platform_
-----------------------------------------

[_Introduction_](#introduction)

[1. Building project](#building-project)

[2. Features](#features)

[3. Documentation](#documentation)

## Introduction

Hybrid transactional/analytical processing platform built on top of Spark and GigaSpaces Data Grid.

## Building project

This project is based on Maven, so to build it you run the next command:

```bash
# without unit tests
mvn clean install -DskipTests=true

# with unit tests
mvn clean install -Dcom.gs.home={path to xap directory}

# package the distribution (depends on insightedge-zeppelin, insightedge-examples)
mvn clean package -DskipTests=true -P package-deployment -Ddist.spark=<path to spark.tgz> -Ddist.xap=<path to xap.zip> -Ddist.zeppelin=<path to zeppelin.tar.gz> -Ddist.examples=<path to examples.jar>

# run integration tests with Docker (depends on running Docker daemon tcp://127.0.0.1:2375 and built zip distribution file)
mvn -pl insightedge-integration-tests -P run-integration-tests clean verify
```


## Features
* Exposes Data Grid as Spark RDDs
* Saves Spark RDDs to Data Grid
* Full DataFrames API support with persistence
* Transparent integration with SparkContext using Scala implicits
* Ability to select and filter data from Data Grid with arbitrary SQL and leverage Data Grid indexes
* Running SQL queries in Spark over Data Grid
* Data locality between Spark and Data Grid nodes
* Storing MLlib models in Data Grid
* Saving Spark Streaming computation results in Data Grid
* Off-Heap persistence
* Interactive Web Notebook

## Documentation

Please refer to the [insightedge.io](http://insightedge.io/docs) site.
