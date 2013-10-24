Blend Inline Comments
=====================

An Inline Comments extension for the eZ Publish Online Editor
-------------------

This extension provides an inline comments feature to the ezoe editor.
This allows users to leave comments on specific portions of a document, similar to
Google Docs. The comment text is stored separately from the document, so there's
no risk of the comments turning up on the page or in search results.

This system has been tested against Firefox and Chrome - there may be issues when using it in IE.

Installation
------------

* Add the blendinlinecommments extension to the 'extensions' folder.
* Run sql/blend_inlinecomments.sql against your database. This will add the 'blend_inlinecomments' table.
* Add 'blendinlinecomments' to the active extensions array.
* Run 'bin/php/ezpgenerateautoloads.php'
* Clear all caches
* Edit the editor role (or whatever user role you're using) to add the 'inlinecomments/read' and 'inlinecomments/write' permissions as appropriate

![screenshot](https://raw.github.com/blendinteractive/blendinlinecomments/master/doc/Screenshot.jpg)