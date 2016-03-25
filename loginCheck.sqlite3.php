<?php
	$db="user.db" or die('Unable to open database');
	$conn  = new SQLite3($db);
	$desc = "";
	$sc = 0;

	$Pid = sanitize($_POST['Pid']);
	$Pwd = sanitize($_POST['Pwd']);
/*
	$Pid ='101';
	$Pwd = 'echo';
*/
	$sql="insert into usr values(110,'eric')";
	$conn->exec($sql);

	$sql="select id,vc from usr where id=".$Pid." and vc='".$Pwd."' limit 1";
	$result=$conn -> query($sql);
	if ($result){ 
		while($row=$result->fetchArray()){
			$desc= $row['id']."#".$row['vc'];
			$sc=1;
	}}
	if ($desc==""){
		echo "0#Error user and password";
	}else
		echo "1#".$desc;
?>