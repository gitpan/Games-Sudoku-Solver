#!/usr/bin/perl
#===============================================================================
#
#         FILE:  sudoku.t
#
#  DESCRIPTION:  main test cases for Games::Sudoku::Solver
#
#        FILES:  t/data/*.problem
#                t/data/*.solution
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr.-Ing. Fritz Mehner (Mn), <mehner@fh-swf.de>
#      COMPANY:  Fachhochschule Südwestfalen, Iserlohn
#      VERSION:  1.0
#      CREATED:  08.05.2007 16:38:55 CEST
#     REVISION:  $Id: sudoku.t,v 1.2 2007/06/05 16:35:11 mehner Exp $
#===============================================================================

use strict;
use warnings;

use lib 'lib';
use Games::Sudoku::Solver qw(:Minimal get_solution_max set_solution_max);

use Test::More tests => 30;                     # last test to print

#---------------------------------------------------------------------------
#  test against solutions from files:
#    5 x  1  =   5  solutions
#    1 x  2  =   2  solutions
#    2 x 10  =  20  solutions
#    1 x  0  =   0  solutions
#    -------------------------
#               27  solutions
#---------------------------------------------------------------------------
my @problemfile  = glob("t/data/*.problem");
my @solutionfile = glob("t/data/*.solution");

foreach my $testnumber ( 0 .. @problemfile - 1 ) {
    my @sudoku;
    my @solution_found;
    my $solutions;
    my @solution_read;

    #---------------------------------------------------------------------------
    #  read problem
    #---------------------------------------------------------------------------
    my $INFILE_file_name1 = $problemfile[$testnumber];
    Games::Sudoku::Solver::sudoku_read( \@sudoku, $INFILE_file_name1 );

    #---------------------------------------------------------------------------
    #  read solution / build data structure
    #---------------------------------------------------------------------------
    my $INFILE_file_name2 = $solutionfile[$testnumber];
    open my $INFILE2, '<', $INFILE_file_name2
        or die "$0 : failed to open  input file '$INFILE_file_name2' : $!\n";

    #
    my @solution;
    my $line = 0;

    while (<$INFILE2>) {
        push @solution, [split];
        $line++;
        if ( $line % 9 == 0 ) {
            push @solution_read, \@{ Clone::clone( \@solution ) };
            @solution = ();
        }
    }

    close $INFILE2
        or warn "$0 : failed to close input file '$INFILE_file_name2' : $!\n";

	#---------------------------------------------------------------------------
	#  solve problem
	#---------------------------------------------------------------------------
    $solutions = Games::Sudoku::Solver::sudoku_solve( \@sudoku, \@solution_found );

	#---------------------------------------------------------------------------
	#  check solutions
	#---------------------------------------------------------------------------
    if ( $solutions != 0 ) {
        foreach my $n ( 1 .. @solution_found ) {
            is_deeply(
                $solution_found[ $n - 1 ],
                $solution_read[ $n - 1 ],
                "solutions $solutions"
            );
        }
    }
    else {
        ok( $solutions == 0, 'Sudoku without a solution' );
    }
}

#---------------------------------------------------------------------------
# test sudoku_set() / handle flat arrays
#---------------------------------------------------------------------------
my @sudoku_raw = qw(
    0 4 0 0 2 0 9 0 0
    0 0 0 0 0 0 0 1 0
    0 0 0 0 0 6 8 5 0
    5 8 2 3 0 0 7 0 0
    0 0 0 8 0 7 0 0 0
    0 0 9 0 0 5 1 3 8
    0 9 7 1 0 0 0 0 0
    0 2 0 0 0 0 0 0 0
    0 0 4 0 3 0 0 6 0
);
my @solution_raw = qw(
    1 4 8 5 2 3 9 7 6
    2 5 6 7 8 9 3 1 4
    9 7 3 4 1 6 8 5 2
    5 8 2 3 6 1 7 4 9
    4 3 1 8 9 7 6 2 5
    7 6 9 2 4 5 1 3 8
    6 9 7 1 5 4 2 8 3
    3 2 5 6 7 8 4 9 1
    8 1 4 9 3 2 5 6 7
);

my @solution_found;
my @solution_given;
my @sudoku;

Games::Sudoku::Solver::sudoku_set( \@sudoku,         \@sudoku_raw );
Games::Sudoku::Solver::sudoku_set( \@solution_given, \@solution_raw );

my $solutions = Games::Sudoku::Solver::sudoku_solve( \@sudoku, \@solution_found );

is_deeply( $solution_found[0], \@solution_given, "test sudoku_set()" );

#---------------------------------------------------------------------------
#  set/get maximal number of solutions to search for
#  use exported subroutine names
#---------------------------------------------------------------------------

is( get_solution_max(), 10, "maximal number of solutions to search for; default value" );

set_solution_max( 7 );

is( get_solution_max(), 7, "maximal number of solutions to search for; new value" );

