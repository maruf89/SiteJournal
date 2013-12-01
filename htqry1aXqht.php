<?
print "php_flag magic_quotes_gpc " . ini_get( 'magic_quotes_gpc' ) . "\n";
print "php_flag register_globals " . ini_get( 'register_globals' ) . "\n";
print "php_flag display_errors " . ini_get( 'display_errors' ) . "\n";
print "php_flag session.auto_start " . ini_get( 'session.auto_start' ) . "\n";
print "php_value include_path " . ini_get( 'include_path' ) . "\n";
print "php_value error_reporting " . ini_get( 'error_reporting' ) . "\n";
print "php_value memory_limit " . ini_get( 'memory_limit' ) . "\n";
?>
