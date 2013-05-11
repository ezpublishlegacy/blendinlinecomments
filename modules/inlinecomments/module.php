<?php
$module = array( 'name' => 'inlinecomments', 'variable_params' => true);

$ViewList = array(); //add as many views as you want here:

$ViewList['read'] = array(
    'functions' => array('read'),
    'ui_context' => 'edit',
    'script' => 'read.php',
    'params' => array(
        'ObjectAttributeId',
        'Version',
        'Language'
    )
);

$ViewList['write'] = array(
    'functions' => array( 'write' ),
    'ui_context' => 'edit',
    'script' => 'write.php',
    'params' => array(
        'ObjectAttributeId',
        'Version',
        'Language'
    )
);

$FunctionList = array();
$FunctionList['read'] = array();
$FunctionList['write'] = array();
