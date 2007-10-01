package CPANPLUS::Shell::Default::Plugins::CustomSource;

use strict;
use CPANPLUS::Error                 qw[error msg];
use CPANPLUS::Internals::Constants;

use Data::Dumper;
use Locale::Maketext::Simple        Class => 'CPANPLUS', Style => 'gettext';


sub plugins {
    return ( cs => 'custom_source' )
}

### XXX Refactor
### XXX use search numbers
### XXX note saving tree to make changes permanent
sub custom_source {
    my $class   = shift;
    my $shell   = shift;
    my $cb      = shift;
    my $cmd     = shift;
    my $input   = shift || '';
    my $opts    = shift || {};

    ### show a list
    if( $opts->{'list'} ) {
        my %files = $cb->list_custom_sources;
        
        $shell->__print( loc("Your remote sources:"), $/ ) if keys %files;
        
        my $i = 0;
        while(my($local,$remote) = each %files) {
            $shell->__printf( "   [%2d] %s\n", ++$i, $remote );
        }
        
        $shell->__print( $/ );

    ### XXX make me work on search numbers        
    } elsif ( $opts->{'contents'} ) {
        
        unless( $input ) {
            error(loc("--contents needs URI parameter"));
            return;
        }        

        my %files = reverse $cb->list_custom_sources;
        
        my $local = $files{ $input } or (
            error(loc("'%1' is not a known remote source", $input)),
            return
        );
        
        my $fh = OPEN_FILE->( $local ) or return;

        $shell->__printf( "   %s", $_ ) for sort <$fh>;
        $shell->__print( $/ );

    
    } elsif ( $opts->{'add'} ) {        
        unless( $input ) {
            error(loc("--add needs URI parameter"));
            return;
        }
        
        $cb->add_custom_source( uri => $input ) 
            and $shell->__print(loc("Added remote source '%1'", $input));
        
        ### XXX list the contents
        
        
    } elsif ( $opts->{'remove'} ) {
        unless( $input ) {
            error(loc("--remove needs URI parameter"));
            return;
        }
    
        my %files = reverse $cb->list_custom_sources;
        
        my $local = $files{ $input } or (
            error(loc("'%1' is not a known remote source", $input)),
            return
        );
    
        1 while unlink $local;
    
    
        $shell->__print( loc("Removed remote source '%1'", $input) );

    ### XXX support single uri too
    } elsif ( $opts->{'update'} ) {
        $cb->update_custom_source 
            and $shell->__print(loc("Updated remote sources"));      

    } elsif ( $opts->{'write'} ) {
        $cb->write_custom_source_index( path => $input )
            and $shell->__print(loc("Wrote remote source index for '%1'", $input));              
            
    } else {
        error(loc("Unrecognized command, see '%1' for help", '/? cs'));
    }
    
    return;
}

sub custom_source_help {
    return loc(
                                                                          $/ .
        '    # Plugin to manage custom sources from the default shell'  . $/ .
        "    # See the 'CUSTOM MODULE SOURCES' section in the "         . $/ .
        '    # CPANPLUS::Backend documentation for details.'            . $/ .
        '    /cs --list             # list available sources'           . $/ .
        '    /cs --add       URI    # add source'                       . $/ .
        '    /cs --remove    URI    # remove source'                    . $/ .
        '    /cs --contents  URI    # show packages from source'        . $/ .
        '    /cs --update   [URI]   # update source index'              . $/ .
        '    /cs --write     PATH   # write source index'               . $/ 
    );        

}

1;
    