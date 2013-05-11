<?php
ini_set('display_errors',true);
$manager = new BlendInlineCommentManager();
//echo "<pre>"; print_r($_POST); echo "</pre>";


$contentAttributeId = isset($Params['ObjectAttributeId']) ? $Params['ObjectAttributeId'] : false;
$version = isset($Params['Version']) ? $Params['Version'] : false;
$languageId = isset($Params['Language']) ? $Params['Language'] : false;

$comments = $_POST['comments'];

header('Content-Type: application/json');

echo json_encode($manager->saveComments($contentAttributeId, $version, $languageId, $comments));

eZExecution::cleanExit();