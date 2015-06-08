## This file is automatically generated
## Standard maketest.g for the homalg project

LoadPackage( "GaussForHomalg" );
LoadPackage( "Modules" );
Read( "ListOfDocFiles.g" );
example_tree := ExtractExamples( DirectoriesPackageLibrary( "GaussForHomalg", "doc" )[1]![1], "GaussForHomalg.xml", list, 500 );
RunExamples( example_tree, rec( compareFunction := "uptowhitespace" ) );
GAPDocManualLab( "GaussForHomalg" );
QUIT;