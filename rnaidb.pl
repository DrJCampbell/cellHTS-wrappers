#!/usr/bin/perl
#
# rnaidb.pl
# A CGI wrapper for cellHTS2 and RNAiDB
#

use strict;
use warnings;
use CGI qw( :standard );
use CGI::Carp qw ( fatalsToBrowser );
use Template;
use DBI;
use Digest::MD5 qw ( md5 md5_hex md5_base64 );
use FileHandle;
use File::Copy qw(copy move);
use File::Path qw(rmtree);

no strict 'refs';	# CHECK IF NEEDED
					# for new file upload
					# - fixes the error:
					# use string ("test_plateconf.txt") as a symbol ref
					# while "strict refs" in use at...


# Don't buffer output
$| = 1;

# print an http header
print "Content-type: text/html\n\n";

my $q = new CGI;


# CHECK IF NEEDED - globals???
my $ISOGENIC_SET;
my $ADD_NEW_FILES_LINK = $config_hash{'hostname'} . "cgi-bin/$script_name?add_new_files=1";



# get script and config filenames, then read config into hash
my $script_name = &get_script_name($0);
my $conf_file = &get_conf_file($script_name);
my $config_hash = &get_config_hash($conf_file)

# Allow file uploads but limit size of a file
# to 1 MB. XLS files from the plate reader are
# approx 500 KB
$CGI::DISABLE_UPLOADS = 0;
$CGI::POST_MAX = 1024 * 1000;

# get the SQL DB info and connect
my $sqldb_name = $config_hash{'sqldb_name'};
my $sqldb_host = $config_hash{'sqldb_host'};
my $sqldb_port = $config_hash{'sqldb_port'};
my $sqldb_user = $config_hash{'sqldb_user'};
my $sqldb_pass = $config_hash{'sqldb_pass'};

my $dsn = "DBI:mysql:database=$sqldb_name;host=$sqldb_host;port=$sqldb_port";
my $dbh = DBI -> connect ($dsn, $sqldb_user, $sqldb_pass, { RaiseError => 0, AutoCommit => 1 } )
  or die "Cannot connect to database: " . $DBI::errstr;


# Decide what to do based on the params passed to the script
if ( $q -> param( "show_all_screens" )) {
  &show_all_screens ( $q );
}
elsif ( $q -> param( "add_new_screen" )) {
  &add_new_screen ( $q );
}
elsif ( $q -> param( "save_new_screen" )) {
  &save_new_screen ( $q );
}
elsif ( $q -> param( "add_new_files" )) {
  &add_new_files ( $q );
}
elsif ( $q -> param( "save_new_uploaded_plateconf_file" )) {
  &save_new_uploaded_plateconf_file ( $q );
}
elsif ( $q -> param ( "save_new_uploaded_platelist_file" )) {
  &save_new_uploaded_platelist_file ( $q );
}
elsif ( $q -> param ( "save_new_uploaded_templib_file" )) {
  &save_new_uploaded_templib_file ( $q );
}
elsif ( $q -> param ( "configure_export" )) {
  &configure_export ( $q );
}
elsif ( $q -> param ( "show_qc" )) {
  &show_qc ( $q );
}
elsif ( $q -> param ( "run_export" )) {
  &run_export ( $q );
}
else {
 &home ( $q );
}


sub add_new_screen{
  
  # file_upload_message can be passed to the script from the upload new file section(s)
  my $file_upload_message = $q -> param ( "file_upload_message" );
  
  # links to existing cellHTS input files
  my $plate_list_download_link = $config_hash{'hostname'} . $config_hash{'platelist_folder'};
  
  # link to add new cellHTS input files
  my $link_to_add_new_files = $config_hash{'hostname'} . "cgi-bin/$script_name?add_new_files=1";
  
  #
  # Multiple database queries here.
  #
  
  # get the existing tissue type from the database
  my $tissueType;
  my @tissueType;
  my $query = "SELECT Tissue_of_origin FROM Tissue_type order by Tissue_of_origin";
  my $query_handle = $dbh -> prepare ( $query )
    or die "Cannot prepare: " . $dbh -> errstr();
  $query_handle->execute();
  while ( $tissueType = $query_handle -> fetchrow_array ){
    push ( @tissueType, $tissueType );  
  }
  
  # get the existing cell line names from the database
  my $cellLineName;
  my @cellLineName;
  $query = "SELECT Cell_line_name FROM Cell_line order by Cell_line_name";
  $query_handle = $dbh -> prepare ( $query )
    or die "Cannot prepare: " . $dbh -> errstr();
  $query_handle->execute();
  while ( $cellLineName = $query_handle -> fetchrow_array ){  
    push ( @cellLineName, $cellLineName );
  }
  
  # get plate list file paths from the database
  $query = "SELECT Platelist_file_location FROM Platelist_file_path";
  $query_handle = $dbh -> prepare ( $query )
    or die "Cannot prepare: " . $dbh -> errstr();
  $query_handle->execute()
    or die "SQL Error: " . $query_handle -> errstr();
  my $platelist_name;
  my @platelist_path;
  while ( $platelist_name = $query_handle -> fetchrow_array ) {
    $platelist_name =~ s/.*\///;
    $platelist_name =~ s/\.[^.]+$//;
    push ( @platelist_path, $platelist_name );
  }
  unshift ( @platelist_path, "Please select" );
  
  # get template file paths from the database
  $query = "SELECT Template_library_file_location FROM Template_library_file_path";
  $query_handle = $dbh -> prepare ( $query )
    or die "Cannot prepare: " . $dbh -> errstr();
  $query_handle->execute()
    or die "SQL Error: " . $query_handle -> errstr();
  my $templib_name;
  my @templib_path;
  while ( $templib_name = $query_handle -> fetchrow_array ) {
    $templib_name =~ s/.*\///;
    $templib_name =~ s/\.[^.]+$//;
    push ( @templib_path, $templib_name );
  }
  unshift( @templib_path, "Please select" );

  # If we are finished fetching DB stuff we can close the qh
  $query_handle -> finish();
  
  
  my $vars = {
    'file_upload_message' => $file_upload_message,
    'plate_list_download_link' => $plate_list_download_link,
    'link_to_add_new_files' => $link_to_add_new_files,
    'tissueType' => @tissueType,
    'cellLineName' => @cellLineName,
    'platelist_path' => @platelist_path,
    'templib_path' => @templib_path,
  };
  
  my $template = Template->new({
  	INCLUDE_PATH => ${} . './lib',
  	PRE_PROCESS => 'config',
  });
  
  $template->process($vars) || die $template->error();
  
  
  
  
}
