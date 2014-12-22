<?php

/* This is a simple php uploader via post method. Please consider the
 * potential risks if you put this page in public.
 */

//print_r($_FILES);

if (isset($_FILES["iagreewithyou"]) == false || $_FILES["iagreewithyou"]["error"] > 0) {
	//echo "Error: " . $_FILES["file"]["error"] . "<br>";
	if (isset($_FILES["iagreewithyou"]) == false)
		echo "file not found";
	echo "error";
}
else {
	//echo "Upload: " . $_FILES["file"]["name"] . "<br>";
	//echo "Type: " . $_FILES["file"]["type"] . "<br>";
	//echo "Size: " . ($_FILES["file"]["size"] / 1024) . " kB<br>";
	//echo "Stored in: " . $_FILES["file"]["tmp_name"];
	exec("mv {$_FILES["iagreewithyou"]["tmp_name"]} /Users/timestring/iosupload/{$_FILES["iagreewithyou"]["name"]}");
	echo "okdes";
}
?>


<?php

/* ------ for testing ----------------
<html>
<body>

<form action="." method="post"
enctype="multipart/form-data">
<label for="file">Filename:</label>
<input type="file" name="iagreewithyou" id="file"><br>
<input type="submit" name="submit" value="Submit">
</form>

</body>
</html>
 */
?>
