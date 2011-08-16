<?php
########################
# PHP Flash Embed
# Created for XSPF Jukebox
# Lacy Morrow
# 2007 http://blog.geekkid.net
########################
//TO USE, EDIT THE FOLLOWING SETTINGS AND CALL FROM A PHP PAGE USING "require_once("embed.php");".

//SETTINGS

//width+height
$width = 300;
$height = 488;

//xspf_jukebox.swf location
$swfurl = "xspf_jukebox.swf";

//playlist file location
$playlisturl = "playlist.php";

//skin folder location
$skinurl = "iPodBlack";

//use external variables.txt or use variables from this file? where is the file, if in use?
$extervars = false;
$variablesurl = "variables.txt";

//place all variables between quotation marks. ex: $vars = "&autoplay=true&autoload=true&shuffle=true";
$vars = "";

######### DO NOT EDIT BELOW THIS LINE ###########

if(substr($skinurl, -1) != "/"){
	$skinurl .= "/";
}
//create url
$url = "$swfurl?playlist_url=$playlisturl&skin_url=$skinurl";
if (!$extervars){
	$url .= $vars;
} elseif ($variablesurl){
	$url .= "&loadurl=$variablesurl";
}

?>
<script type="text/javascript">
if(typeof deconcept == "undefined") var deconcept = new Object();

function swfReplace(){
var so = new SWFObject("<?php echo $url; ?>", "main", "<?php echo $width; ?>", "<?php echo $height; ?>", "7", "#ffffff");
so.addParam("wmode", "transparent");
so.write("flashcontent");
window.document.main.focus();
};
</script>
<div id="flashcontent" >
<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0" width="<?php echo $width; ?>" height="<?php echo $height; ?>" align="middle">
<param name="allowScriptAccess" value="sameDomain" />
<param name="movie" value="<?php echo $url; ?>" /><param name="loop" value="false" /><param name="quality" value="high" /><param name="wmode" value="transparent" /><param name="bgcolor" value="#ffffff" /><embed src="<?php echo $url; ?>" loop="false" quality="high" wmode="transparent" bgcolor="#ffffff" width="<?php echo $width; ?>" height="<?php echo $height; ?>" name="main" align="middle" allowScriptAccess="sameDomain" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
</object>
</div>
<script type="text/javascript">
swfReplace();
</script>