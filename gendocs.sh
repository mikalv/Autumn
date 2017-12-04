#!/bin/bash
typedoc --entryPoint 'Autumn' --ignoreCompilerErrors --name 'AutumnJS.app' --readme none --theme minimal --includeDeclarations --out docs --mode file Autumn/API/*.d.ts
