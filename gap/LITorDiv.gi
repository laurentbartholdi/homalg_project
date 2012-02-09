#############################################################################
##
##  LITorDiv.gi     ToricVarieties       Sebastian Gutsche
##
##  Copyright 2011 Lehrstuhl B für Mathematik, RWTH Aachen
##
##  Logical implications for toric divisors
##
#############################################################################

#############################
##
## True methods
##
#############################

##
## <=
##

##
InstallTrueMethod( IsCartier, IsPrincipal );

##
InstallTrueMethod( IsBasepointFree, IsAmple );

##
InstallTrueMethod( IsNumericallyEffective, IsBasepointFree );

#############################
##
## Immediate Methods
##
#############################

##
InstallImmediateMethod( IsPrincipal,
                        IsToricDivisor and IsCartier,
                        0,
  function( divisor )
    local ambient_variety;
    
    ambient_variety := AmbientToricVariety( divisor );
    
    if HasIsAffine( ambient_variety ) then
        
        if IsAffine( ambient_variety ) then
            
            return true;
            
        fi;
        
    fi;
    
    TryNextMethod( );
    
end );

