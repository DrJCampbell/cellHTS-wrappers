# Cellhtswrappers - library of code for
# creating applications wrapping cellHTS2

# POD documentation - main docs before the code

=head1 NAME

Cellhtswrappers

=head1 SYNOPSIS

  use Cellhtswrappers;
  
  # Do something
  do_something();
  
=head1 DESCRIPTION

Code that can be used to create specific applications that use cellHTS2 to process screen data and manage the resulting outputs

=head1 FEEDBACK

=head2 Pleas use github

https://github.com/GeneFunctionTeam/cellHTS-wrappers

=head1 AUTHORS

Aditi Gulati
James Campbell
Rahul Kumar

=cut

#'
# begin code
package Cellhtswrappers;
use  base qw(Exporter);
our @EXPORT = qw(my_func_1 my_func_2);
use Carp;

#
# Common data
#

my $shared_stuff = '';

#
sub my_func_1{
  # do something...
  my $something = "something";
  return $something;
}

sub my_func_2 {
  # do something else...
  my $something_else = "something";
  return $something_else;

}


1;