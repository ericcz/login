<?php
	$hostname = "127.0.0.1";
	$username = "root";
	$password = "mysql";
	$dbName = "webattend";
	
	define('CLIENT_MULTI_RESULTS',131072);
	
	$conn=mysql_connect($hostname,$username,$password,1,CLIENT_MULTI_RESULTS) or die("Could not connect: ".mysql_error());
	mysql_select_db($dbName,$conn) or die("Could not select database");
?>