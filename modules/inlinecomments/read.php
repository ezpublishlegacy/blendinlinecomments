<?php
ini_set('display_errors',true);
$manager = new BlendInlineCommentManager();

$contentAttributeId = isset($Params['ObjectAttributeId']) ? $Params['ObjectAttributeId'] : false;
$version = isset($Params['Version']) ? $Params['Version'] : false;
$languageId = isset($Params['Language']) ? $Params['Language'] : false;


header('Content-Type: application/json');

echo json_encode($manager->fetchComments($contentAttributeId, $version, $languageId));

eZExecution::cleanExit();