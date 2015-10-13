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
our @EXPORT = qw(get_script_name get_conf_file);
use Carp;

#
# Common data
#

my $shared_stuff = '';

sub get_script_name($){
  # strip path to script name and return
  my $path = shift;
  $path =~ /([^\/]+)$/;
  my $script_name = $1;
  warn unless $script_name =~ /[a-z0-9_]\.(pl|r)/i;
  return $script_name;
}

sub get_conf_file($){
  # replace the script name extention to find the conf file
  my $script_name = shift;
  my $conf_file = $script_name;
  $conf_file =~ s/pl$/conf/;
  return $conf_file;
}

sub get_config_hash{
  my $conf_file = shift;
  my %config;
  open CONFIG, "< $conf_file" or die "Can't read list of configurations from file $conf_file: $!\n";
  while(<CONFIG>){
    next if /^(#|[\n\r])/;
    if(/^([^\t]+)\t+([^\t]+)/){
      my ($key, $value) = ($1, $2);
      chomp($value);
      if(exists($config{$key})){
        die "configure: $key is duplicated in the config file $conf_file\n\nYou need to fix that to continue\n";
      }
      $config{$key} = $value;
    }
  }
  return %config;
}

# This last line is required to stay here
1;