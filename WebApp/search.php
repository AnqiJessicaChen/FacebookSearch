<?php
	$accessToken = "EAACaU8eC2fUBAJ1EdIlut3GbZA6mQ2iubzE93RpxOf31bZB4CIRayMe2kSpd3xFsiqZCl9EJKMuEXd2gVXEXBvlVZBExCNOZBs3xtZAno6ZBrI8lHjV2W0QgWPDHTpaZArUB3cW07IWz72SUtaT9WOSB3uP3ybQQtnoZD";

	if (isset($_GET["keyword"])) {
		$url = "https://graph.facebook.com/v2.8/search?q=" . urlencode($_GET["keyword"]) . "&type=" . $_GET["type"] . "&fields=id,name,picture.width(700).height(700)&access_token=" . $accessToken;
		if(isset($_GET["latitude"]) && isset($_GET["longitude"])) {
			$url = $url . "&center=" . $_GET["latitude"] . "," . $_GET["longitude"];
		}
		$response = file_get_contents($url);
		echo $response;
	} elseif (isset($_GET["id"])) {
		if(isset($_GET["type"]) && $_GET["type"] == "event") {
			$url = "https://graph.facebook.com/v2.8/" . $_GET["id"] . "?fields=id,name,picture.width(700).height(700),posts.limit(5){message,story,created_time}&access_token=" . $accessToken;
		} else {
			$url = "https://graph.facebook.com/v2.8/" . $_GET["id"] . "?fields=id,name,picture.width(700).height(700),albums.limit(5){name,photos.limit(2){name,picture}},posts.limit(5){message,story,created_time}&access_token=" . $accessToken;
		}
		$response = file_get_contents($url);
		echo $response;
	} elseif (isset($_GET["photoid"])) {
		$url = "https://graph.facebook.com/v2.8/" . $_GET["photoid"] . "/picture?access_token=" . $accessToken;
		echo file_get_contents($url);
	}
?>