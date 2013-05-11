Blend Inline Comments for eZ Online Editor
==========================================

This extension provides an inline comments feature to the ezoe editor.
This allows users to leave comments on specific portions of a document, similar to
Google Docs. The comment text is stored separately from the document, so there's
no risk of the comments turning up on the page or in search results.

This is an early proof of concept, but feel free to try it out and submit ideas or pull requests!

* Note: * This extension is in a pre-alpha state. There are likely very many bugs.

* INSTALLATION *

#. Add the blendinlinecommments extension to the 'extensions' folder.
#. Run sql/blend_inlinecomments.sql against your database. This will add the 'blend_inlinecomments' table.
#. Add 'blendinlinecomments' to the active extensions array.
#. Clear all caches
#. Edit the editor role (or whatever user role you're using) to add the 'inlinecomments/read' and 'inlinecomments/write' permissions as appropriate