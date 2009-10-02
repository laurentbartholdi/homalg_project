#############################################################################
##
##  LocalizeRingBasic.gi     LocalizeRingBasic package       Mohamed Barakat
##                                                    Markus Lange-Hegermann
##
##  Copyright 2009, Mohamed Barakat, Universität des Saarlandes
##           Markus Lange-Hegermann, RWTH-Aachen University
##
##  Implementation stuff for LocalizeRingForHomalg.
##
#############################################################################

####################################
#
# global variables:
#
####################################

InstallValue( CommonHomalgTableForLocalizedRingsBasic,
        
        rec(
               ## Must only then be provided by the RingPackage in case the default
               ## "service" function does not match the Ring
               
##  <#GAPDoc Label="BasisOfRowModule">
##  <ManSection>
##    <Func Arg="M" Name="BasisOfRowModule" Label="for local rings"/>
##    <Returns>a "basis" of the module generated by M</Returns>
##    <Description>
##    This procedure computes a basis by using the Funcod of the underlying computation ring. If the computation ring is given by Mora's Algorithm, we will indeed compute a local basis. If we just use the global ring for computations, this will be a global basis and is just computed for some simplifications and not for the use of reducing by it. Of course we can just forget about the denominator of <A>M</A>.
##      <Listing Type="Code"><![CDATA[
BasisOfRowModule :=
  function( M )

    Info(
      InfoLocalizeRingForHomalg,
      2,
      "Start BasisOfRowModule with ",
      NrRows( M ), "x", NrColumns( M )
    );

    return HomalgLocalMatrix( BasisOfRowModule( Numerator( M ) ), HomalgRing( M ) );
    
end,
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

BasisOfColumnModule :=
  function( M )
    
    Info( InfoLocalizeRingForHomalg, 2, "Start BasisOfColumnModule with ", NrRows( M ), "x", NrColumns( M ) );
    
    return HomalgLocalMatrix( BasisOfColumnModule( Numerator( M ) ), HomalgRing( M ) );
    
  end,

BasisOfRowsCoeff :=
  function( M, T )
    local R, ComputationRing, TT, result;

    Info( InfoLocalizeRingForHomalg, 2, "Start BasisOfRowsCoeff with ", NrRows( M ), "x", NrColumns( M ) );
    
    R := HomalgRing( M );
    ComputationRing := AssociatedComputationRing( R );
    
    TT := HomalgVoidMatrix( ComputationRing );
    result := BasisOfRowsCoeff( Numerator( M ) , TT );
    if IsBound(TT!.Denominator) then
      SetEval( T, [ TT, TT!.Denominator ] );
      Unbind(TT!.Denominator);
    else
      SetEval( T, [ TT, One ( ComputationRing ) ] );
    fi;
    result := HomalgLocalRingElement( One( ComputationRing), Denominator( M ), R ) * HomalgLocalMatrix( result, R );
    
    Assert( 4, result = T * M );

    Info( InfoLocalizeRingForHomalgShowUnits, 1, "BasisOfRowsCoeff: produces denominator: ", Name( Denominator( result ) ), " and for the transformation matrix: ", Name(Denominator(T)) );

    return result;
    
  end,

BasisOfColumnsCoeff :=
  function( M, T )
    local R, ComputationRing, TT, result;

    Info( InfoLocalizeRingForHomalg, 2, "Start BasisOfColumnsCoeff with ", NrRows( M ), "x", NrColumns( M ) );
    
    R := HomalgRing( M );
    ComputationRing := AssociatedComputationRing( R );
    
    TT := HomalgVoidMatrix( ComputationRing );
    result := BasisOfColumnsCoeff( Numerator( M ), TT );
    if IsBound(TT!.Denominator) then
      SetEval( T, [ TT, TT!.Denominator ] );
      Unbind(TT!.Denominator);
    else
      SetEval( T, [ TT, One ( ComputationRing ) ] );
    fi;
    result := HomalgLocalRingElement( One( ComputationRing), Denominator( M ), R ) * HomalgLocalMatrix( result, R );
    
    Assert( 4, result = M * T );
    
    Info( InfoLocalizeRingForHomalgShowUnits, 1, "BasisOfColumnsCoeff: produces denominator: ", Name( Denominator( result ) ), " and for the transformation matrix: ", Name(Denominator(T)) );

    return result;
    
  end,

##  <#GAPDoc Label="DecideZeroRows:generic">
##  <ManSection>
##    <Func Arg="A, B" Name="DecideZeroRows" Label="for local rings with Mora's algorithm"/>
##    <Returns>a "reduced" form of <A>A</A> with respect to <A>B</A></Returns>
##    <Description>
##    This procedure just calls the DecideZeroRows of the computation ring for the numerator of <A>A</A>. <P/>If we use Mora's algorithm this procedure will just call it. The result is divided by the denominator of <A>A</A> afterwards. Again we do not need to care about the denominator of B. <P/>If we use the reduction implemented in this package, this Funcod is overwritten and will not be called.
##      <Listing Type="Code"><![CDATA[
DecideZeroRows :=
  function( A, B )
    local R, ComputationRing, hook, result;
    
    Info(
      InfoLocalizeRingForHomalg,
      2,
      "Start DecideZeroRows with ",
      NrRows( A ), "x", NrColumns( A ),
      " and ",
      NrRows( B ), "x", NrColumns( B )
    );
    
    R := HomalgRing( A );
    ComputationRing := AssociatedComputationRing( R );
    
    result := DecideZeroRows( Numerator( A ) , Numerator( B ) );
    result := HomalgLocalMatrix( result, Denominator( A ) , R );
    Info( InfoLocalizeRingForHomalgShowUnits, 1, "DecideZeroRows: produces denominator: ", Name( Denominator( result ) ) );
    return result;

  end,
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

DecideZeroColumns :=
  function( A, B )
    local R, ComputationRing, hook, result;
    
    Info( InfoLocalizeRingForHomalg, 2, "Start DecideZeroColumns with ", NrRows( A ), "x", NrColumns( A ), " and ", NrRows( B ), "x", NrColumns( B ) );
    
    R := HomalgRing( A );
    ComputationRing := AssociatedComputationRing( R );
    
    result := DecideZeroColumns( Numerator( A ) , Numerator( B ) );
    result := HomalgLocalMatrix( result, Denominator( A ) , R );
    Info( InfoLocalizeRingForHomalgShowUnits, 1, "DecideZeroColumns: produces denominator: ", Name( Denominator( result ) ) );
    return result;

  end,

DecideZeroRowsEffectively :=
  function( A, B, T )
    local R, T1, result, ComputationRing;
    
    Info( InfoLocalizeRingForHomalg, 2, "Start DecideZeroRowsEffectively with ", NrRows( A ), "x", NrColumns( A ), " and ", NrRows( B ), "x", NrColumns( B ) );
    
    R := HomalgRing( A );
    ComputationRing := AssociatedComputationRing( R );
    
    T1 := HomalgVoidMatrix( ComputationRing );
    #little remark: the return value of DecideZeroRowsEffectively also has a denominator as an attribute, which is used in HomalgLocalMatrix
    result := HomalgLocalMatrix( DecideZeroRowsEffectively( Numerator( A ), Numerator ( B ), T1 ), Denominator( A ), R );
    
    if IsBound(T1!.Denominator) then
      SetEval( T, [ T1, T1!.Denominator * Denominator( A ) ] );
      Unbind(T1!.Denominator);
    else
      SetEval( T, [ T1, Denominator( A ) ] );
    fi;
    
    Assert( 4, result = A + T * B );
    
    Info( InfoLocalizeRingForHomalgShowUnits, 1, "DecideZeroRowsEffectively: produces denominator: ", Name( Denominator( result ) ), " and for the transformation matrix: ", Name( Denominator( T ) ) );
    
    return result;
    
  end,

DecideZeroColumnsEffectively :=
  function( A, B, T )
    local R, T1, result, ComputationRing;
    
    Info( InfoLocalizeRingForHomalg, 2, "Start DecideZeroColumnsEffectively with ", NrRows( A ), "x", NrColumns( A ), " and ", NrRows( B ), "x", NrColumns( B ) );
    
    R := HomalgRing( A );
    ComputationRing := AssociatedComputationRing( R );
    
    T1 := HomalgVoidMatrix( ComputationRing );
    #little remark: the return value of DecideZeroColumnsEffectively also has a denominator as an attribute, which is used in HomalgLocalMatrix
    result := HomalgLocalMatrix( DecideZeroColumnsEffectively( Numerator( A ), Numerator ( B ), T1 ), Denominator( A ), R );
    
    if IsBound(T1!.Denominator) then
      SetEval( T, [ T1, T1!.Denominator * Denominator( A ) ] );
      Unbind(T1!.Denominator);
    else
      SetEval( T, [ T1, Denominator( A ) ] );
    fi;
    
    Assert( 4, result = A + B * T );
    
    Info( InfoLocalizeRingForHomalgShowUnits, 1, "DecideZeroColumnsEffectively: produces denominator: ", Name( Denominator( result ) ), " and for the transformation matrix: ", Name( Denominator( T ) ) );
    
    return result;
    
  end,

##  <#GAPDoc Label="SyzygiesGeneratorsOfRows">
##  <ManSection>
##    <Func Arg="M" Name="SyzygiesGeneratorsOfRows" Label="for local rings"/>
##    <Returns>a "basis" of the syzygies of the arguments (for details consult the homalg help)</Returns>
##    <Description>
##    It is easy to see, that a global syzygy is also a local syzygy and vice versa when clearing the local Syzygy of its denominators. So this procedure just calls the syzygy Funcod of the underlying computation ring.
##      <Listing Type="Code"><![CDATA[
SyzygiesGeneratorsOfRows :=
  function( M )
    
    Info(
      InfoLocalizeRingForHomalg,
      2,
      "Start SyzygiesGeneratorsOfRows with ",
      NrRows( M ), "x", NrColumns( M )
    );

    return HomalgLocalMatrix(\
             SyzygiesGeneratorsOfRows( Numerator( M ) ), HomalgRing( M )\
           );
    
  end,
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

RelativeSyzygiesGeneratorsOfRows :=
  function( M, N )
    local CommonDenomMatrix, M2, N2;
    
    Info( InfoLocalizeRingForHomalg, 2, "Start RelativeSyzygiesGeneratorsOfRows with ", NrRows( M ), "x", NrColumns( M ), " and ", NrRows( N ), "x", NrColumns( N ) );
    
    CommonDenomMatrix := UnionOfRows( M, N );
    M2 := CertainRows( CommonDenomMatrix, [ 1 .. NrRows( M ) ] );
    N2 := CertainRows( CommonDenomMatrix, [ NrRows( M ) + 1 .. NrRows( CommonDenomMatrix ) ] );
    
    return HomalgLocalMatrix( SyzygiesGeneratorsOfRows( Numerator( M2 ), Numerator( N2 ) ), HomalgRing( M ) );
    
  end,

SyzygiesGeneratorsOfColumns :=
  function( M )
    
    Info( InfoLocalizeRingForHomalg, 2, "Start SyzygiesGeneratorsOfColumns with ", NrRows( M ), "x", NrColumns( M ) );
    return HomalgLocalMatrix( SyzygiesGeneratorsOfColumns( Numerator( M ) ), HomalgRing( M ) );
    
  end,
  
RelativeSyzygiesGeneratorsOfColumns :=
  function( M, N )
    local CommonDenomMatrix, M2, N2;
    
    Info( InfoLocalizeRingForHomalg, 2, "Start RelativeSyzygiesGeneratorsOfColumns with ", NrRows( M ), "x", NrColumns( M ), " and ", NrRows( N ), "x", NrColumns( N ) );
    
    CommonDenomMatrix := UnionOfColumns( M, N );
    M2 := CertainColumns( CommonDenomMatrix, [ 1 .. NrColumns( M ) ] );
    N2 := CertainColumns( CommonDenomMatrix, [ NrColumns( M ) + 1 .. NrColumns( CommonDenomMatrix ) ] );
    
    return HomalgLocalMatrix( SyzygiesGeneratorsOfColumns( Numerator( M2 ), Numerator( N2 ) ), HomalgRing( M ) );
    
  end,

            )
);

InstallValue( HomalgTableReductionMethodsForLocalizedRingsBasic,
        
        rec(
        
##  <#GAPDoc Label="DecideZeroRows">
##  <ManSection>
##    <Func Arg="A, B" Name="DecideZeroRows" Label="for local rings"/>
##    <Returns>a "reduced" form of <A>A</A> with respect to <A>B</A></Returns>
##    <Description>
##    This procedure is the mathematical core procedure of this package. We use a trick to decide locally, whether <A>A</A> can be reduced to zero by <A>B</A> with a global computation. First a heuristic is used by just checking, whether the element lies inside the global module, generated by the generators of the local module. This of course implies this for the local module having the advantage of a short computation time and leaving a normal form free of denominators. If this check fails, we use our trick to check for each row of <A>A</A> independently, whether it lies in the module generated by <A>B</A>.
##      <Listing Type="Code"><![CDATA[
DecideZeroRows :=
  function( A, B )
    local R, T, m, gens, n, GlobalR, one, N, a, numA, denA, i, A1, B1, A2, B2, A3;
    
    Info( 
       InfoLocalizeRingForHomalg,
       2,
       "Start DecideZeroRows with ",
       NrRows( A ), "x", NrColumns( A ),
       " and ",
       NrRows( B ), "x", NrColumns( B ) 
    );
    
    R := HomalgRing( A );
    GlobalR := AssociatedComputationRing( R );
    T := HomalgVoidMatrix( R );
    gens := GeneratorsOfMaximalLeftIdeal( R );
    n := NrRows( gens );
    one := One( GlobalR );
    
    m := NrRows( B );
    B1 := Numerator( B );
    
    N := HomalgZeroMatrix( 0, NrColumns( A ), R );
    a := Eval( A );
    numA := a[1];
    denA := a[2];
    
    for i in [ 1 .. NrRows( A ) ] do
    
        #use global reduction as heuristic
        A1 := CertainRows( numA, [ i ] );
        A2 := HomalgLocalMatrix( DecideZeroRows( A1, B1 ), R );
        
        #if it is nonzero, check whether local reduction makes it zero
        if not IsZero( A2 ) then
          B2 := UnionOfRows( B1, gens * A1 );
          B2 := BasisOfRows( B2 );
          A3 := HomalgLocalMatrix( DecideZeroRows( A1, B2 ), R );
          if IsZero( A3 ) then
            A2 := A3;
          fi;
        fi;
        
        N := UnionOfRows( N, A2 );
        
    od;
    
    N := HomalgRingElement( One( GlobalR ), denA, R ) * N;
    
    Info( InfoLocalizeRingForHomalgShowUnits, 1, "DecideZeroRows: produces denominator: ", Name( Denominator( N ) ) );
    
    return N;
    
  end,
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

DecideZeroColumns :=
  function( A, B )
    local R, T, m, gens, n, GlobalR, one, N, a, numA, denA, i, A1, B1, A2, B2, A3;
    
    Info( InfoLocalizeRingForHomalg, 2, "Start DecideZeroColumns with ", NrRows( A ), "x", NrColumns( A ), " and ", NrRows( B ), "x", NrColumns( B ) );
    
    R := HomalgRing( A );
    GlobalR := AssociatedComputationRing( R );
    T := HomalgVoidMatrix( R );
    gens := GeneratorsOfMaximalRightIdeal( R );
    n := NrColumns( gens );
    one := One( GlobalR );

    m := NrColumns( B );
    B1 := Numerator( B );
    
    N := HomalgZeroMatrix( NrRows( A ), 0, R );
    a := Eval( A );
    numA := a[1];
    denA := a[2];
    
    for i in [ 1 .. NrColumns( A ) ] do
    
        A1 := CertainColumns( numA, [ i ] );
        A2 := HomalgLocalMatrix( DecideZeroColumns( A1, B1 ), R );
        
        if not IsZero( A2 ) then
          B2 := UnionOfColumns( B1, A1 * gens );
          B2 := BasisOfColumns( B2 );
          A3 := HomalgLocalMatrix( DecideZeroColumns( A1, B2 ), R );
          if IsZero( A3 ) then
            A2 := A3;
          fi;
        fi;
        
        N := UnionOfColumns( N, A2 );
        
    od;
    
    N := HomalgRingElement( One( GlobalR ), denA, R ) * N;
    
    Info( InfoLocalizeRingForHomalgShowUnits, 1, "DecideZeroColumns: produces denominator: ", Name(Denominator(N)) );
    
    return N;
    
  end,

DecideZeroRowsEffectively :=
  function( A, B, T )
    local R, m, gens, n, GlobalR, one, N, TT, a, numA, denA, b, numB, denB, i, A1, B1, A2, B2, S, S1, u, SS, A3;
    
    Info( InfoLocalizeRingForHomalg, 2, "Start DecideZeroRowsEffectively with ", NrRows( A ), "x", NrColumns( A ), " and ", NrRows( B ), "x", NrColumns( B ) );
    
    R := HomalgRing( A );
    GlobalR := AssociatedComputationRing( R );
    gens := GeneratorsOfMaximalLeftIdeal( R );
    one := One( GlobalR );
    
    m := NrRows( B );
    n := NrRows( gens );
    N := HomalgZeroMatrix( 0, NrColumns( A ), R );
    TT := HomalgZeroMatrix( 0, m, R );
    
    a := Eval( A );
    numA := a[1];
    denA := a[2];
    b := Eval( B );
    numB := b[1];
    denB := b[2];
    
    for i in [ 1 .. NrRows( A ) ] do
    
        A1 := CertainRows( numA, [ i ] );
        B1 := numB;
        S1 := HomalgVoidMatrix( GlobalR );
        A2 := HomalgLocalMatrix( DecideZeroRowsEffectively( A1, B1, S1 ), R );
        
        if not IsZero( A2 ) then
          B2 := UnionOfRows( B1, gens * A1 );
          SS := HomalgVoidMatrix( GlobalR );
          B2 := BasisOfRowsCoeff( B2, SS );
          S := HomalgVoidMatrix( GlobalR );
          A3 := HomalgLocalMatrix( DecideZeroRowsEffectively( A1, B2, S ), R );
          if IsZero( A3 ) then
            S := S * SS;
            u := CertainColumns( S, [ m + 1 .. n + m ] ) * gens;
            u := GetEntryOfHomalgMatrix( u, 1, 1, GlobalR );
            IsZero( u );
            u := one + u;
            S := HomalgLocalMatrix( CertainColumns( S, [ 1 .. m ] ), u, R );
            A2 := HomalgRingElement( one , u , R ) * A3;
          else
            S := HomalgVoidMatrix( GlobalR );
            A2 := HomalgLocalMatrix( DecideZeroRowsEffectively( A1 , B1 , S ) , one , R );
            S := HomalgLocalMatrix( S , one , R );
          fi;
        else
          S := HomalgLocalMatrix( S1 , one , R );
        fi;
        
        TT := UnionOfRows( TT, S );
        N := UnionOfRows( N, A2 );
        
        Assert( 5, S * HomalgLocalMatrix( B1, R ) + HomalgLocalMatrix( A1, R ) = A2 );
        
    od;
    
    TT := HomalgRingElement( denB, denA, R ) * TT;
    
    if HasEvalUnionOfRows( TT ) then
        SetEvalUnionOfRows( T, EvalUnionOfRows( TT ) );
    elif HasEvalMulMat( TT ) then
        SetEvalMulMat( T, EvalMulMat( TT ) );
    else
        SetEval( T, Eval( TT ) );
    fi;
    
    N := HomalgRingElement( one , denA , R ) * N;
    
    Info( InfoLocalizeRingForHomalgShowUnits, 1, "DecideZeroRowsEffectively: produces denominator: ", Name( Denominator( N ) ), " and for the transformation matrix: ", Name( Denominator( T ) ) );
    
    return N;
    
  end,

DecideZeroColumnsEffectively :=
  function( A, B, T )
    local R, m, gens, n, GlobalR, one, N, TT, a, numA, denA, b, numB, denB, i, A1, B1, A2, B2, S, S1, u, SS, A3;
    
    Info( InfoLocalizeRingForHomalg, 2, "Start DecideZeroColumnsEffectively with ", NrRows( A ), "x", NrColumns( A ), " and ", NrRows( B ), "x", NrColumns( B ) );
    
    R := HomalgRing( A );
    GlobalR := AssociatedComputationRing( R );
    gens := GeneratorsOfMaximalRightIdeal( R );
    one := One( GlobalR );
    
    m := NrColumns( B );
    n := NrColumns( gens );
    N := HomalgZeroMatrix( NrRows( A ), 0, R );
    TT := HomalgZeroMatrix( m, 0, R );
  
    a := Eval( A );
    numA := a[1];
    denA := a[2];
    b := Eval( B );
    numB := b[1];
    denB := b[2];
    
    for i in [ 1 .. NrColumns( A ) ] do
    
        A1 := CertainColumns( numA, [ i ] );
        B1 := numB;
        S1 := HomalgVoidMatrix( GlobalR );
        A2 := HomalgLocalMatrix( DecideZeroColumnsEffectively( A1, B1, S1 ), R );
        
        if not IsZero( A2 ) then
          B2 := UnionOfColumns( B1, A1 * gens );
          SS := HomalgVoidMatrix( GlobalR );
          B2 := BasisOfColumnsCoeff( B2, SS );
          S := HomalgVoidMatrix( GlobalR );
          A3 := HomalgLocalMatrix( DecideZeroColumnsEffectively( A1, B2, S ), R );
          if IsZero( A3 ) then
            S := SS * S;
            u := gens * CertainRows( S, [ m + 1 .. n + m ] );
            u := GetEntryOfHomalgMatrix( u, 1, 1, GlobalR );
            IsZero( u );
            u := one + u;
            S := HomalgLocalMatrix( CertainRows( S, [ 1 .. m ] ), u, R );
            A2 := HomalgRingElement( one, u, R ) * A3;
          else
            S := HomalgVoidMatrix( GlobalR );
            A2 := HomalgLocalMatrix( DecideZeroColumnsEffectively( A1 , B1 , S ) , one , R );
            S := HomalgLocalMatrix( S , one , R );
          fi;
          
        else
          
          S := HomalgLocalMatrix( S1 , one , R );
        
        fi;
        
        TT := UnionOfColumns( TT, S );
        N := UnionOfColumns( N, A2 );
        
        Assert( 5, HomalgLocalMatrix( B1, R ) * S + HomalgLocalMatrix( A1, R ) = A2 );
        
    od;
    
    TT := HomalgRingElement( denB, denA, R ) * TT;
    
    if HasEvalUnionOfColumns( TT ) then
        SetEvalUnionOfColumns( T, EvalUnionOfColumns( TT ) );
    elif HasEvalMulMat( TT ) then
        SetEvalMulMat( T, EvalMulMat( TT ) );
    else
        SetEval( T, Eval( TT ) );
    fi;
  
    N := HomalgRingElement( one , denA , R ) * N;
    
    Info( InfoLocalizeRingForHomalgShowUnits, 1, "DecideZeroColumnsEffectively: produces denominator: ", Name( Denominator( N ) ), " and for the transformation matrix: ", Name( Denominator( T ) ) );
    
    return N;
    
  end,

        )
 );