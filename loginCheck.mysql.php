<?php
//include_once "dbcon.php";
	$hostname = "127.0.0.1";
	$username = "up";
	$password = "upload";
	$dbName = "uploads";
	define('CLIENT_MULTI_RESULTS',131072);
	$conn=mysqli_connect($hostname,$username,$password,$dbName) or die("Could not connect: ".mysql_error());
	/*
	$PinID='96001';
	$pwd='eric';
	*/
	$PinID = $_REQUEST['Pid'];
	$pwd = $_REQUEST['Pwd'];
	$desc = "";
	$sc=0;
	
	$proc='cspCheckLogin';
	$result=mysqli_query($GLOBALS["conn"],"call $proc('$PinID','$pwd',@x)");
	$result=mysqli_query($GLOBALS["conn"],"select @x");
	/*
	$query ="select concat(iUid,'#',chUserNo,'#',chUserCN) from ctbUser where iStatus=1 and chUserNo='".$PinID."' and exists(select iUid from ctbPWD where iUser=ctbUser.iUid and chPwd=md5(concat(md5('".$pwd."'),encrypt)))";
	$result=mysqli_query($GLOBALS["conn"],$query);
	*/
	if ($result){ 
		while($row=mysqli_fetch_row($result)){
			$desc.= $row[0];
		}
		if ($desc=="0"){
			$sc="0";
			$desc="Error in username or password";
		}else
			$sc="1";
	}else{
		$sc="0";
		$desc="result false";
	}
	echo $sc."#".$desc;
	$var=fncheckinLogs($sc,"login",$desc);
function fncheckinLogs($sc,$step,$info){
	$proc='cspLogs_ins';
	$p = $GLOBALS["PinID"];
	$result=mysqli_query($GLOBALS["conn"],"call $proc($sc,'','$step','$info','$p',@x)");
	$result=mysqli_query($GLOBALS["conn"],"select @x");
	if( $result == false ){ 
		$dc = "Error .\n";}
	if ($result){ 
		while($row=mysqli_fetch_row($result)){
			$dc = $row[0];
		}
	}else
		$dc = "-1";
	return $dc;
}

	mysqli_close($conn);
?>