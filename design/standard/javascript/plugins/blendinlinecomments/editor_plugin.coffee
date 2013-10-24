
tinymce.PluginManager.requireLangPack('blendinlinecomments');
tinymce.create('tinymce.plugins.BlendInlineCommentsPlugin', {
    init: (ed, url) ->
        plugin = this
        ed.blendInlineComment = {
            makeBubble: this.makeBubble
            hasProperties: this.hasProperties
            getUuid: this.getUuid
            deleteComment: this.deleteComment
        }
        ed.addCommand 'addinlinecomment', this.addComment

        ed.addButton('inlinecomment', {
              id: 'inlinecomment'
              title: 'Add Comment'
              cmd: 'addinlinecomment'
              #image: url.replace('/ezoe/','/blendinlinecomments/') + '/img/comment.png'
        })
        #ed.serializer.addRules('div[id|class|title|customattributes|data-id|data-target|data-new]');

        ed.onPostRender.add (ed, evt) ->
            setTimeout( () ->
                plugin.injectComments(ed, evt)
                ed.execCommand('initializeinlinecomments');
            , 200)
        #ed.onPostProcess.add this.handleComments
        $('#' + ed.settings.id).closest('form').submit( () ->
            tinyMCE.triggerSave()
        )

        ed.onNodeChange.add this.updateComments

        ed.onSaveContent.add this.handleSave


        ed.addCommand('initializeinlinecomments', (editor) ->
            ed = editor || ed;
            #Configure events for reply handling

            #Shim to use 'on' on new jQuery versions, or 'delegate' on older ones
            $.fn.onOrDelegate = (event, selector, fn) ->
                if typeof $.fn.on != 'undefined'
                    this.on(event, selector, fn)
                else
                    this.delegate(selector, event, fn)


            $(ed.contentDocument.body).onOrDelegate('click','.delete-button', (ev) ->
                console.log('delete button')
                body = $(this).closest('body')
                bubble = $(this).closest('.comment-bubble')
                target = bubble.attr('data-target')
                span = $("##{target}", body)

                span.replaceWith(span.html())
                bubble.remove()

                return false
            )

            #Highlight comment bubble when user rolls over highlighted text
            $(ed.contentDocument.body).onOrDelegate('mouseover','.inlinecomment', (ev) ->
                $('.inlinecomment,.comment-bubble', ed.contentDocument.body).removeClass('selected')
                $(this).addClass('selected')
                bubble = $(this).attr('id').replace('comment_tag','comment_bubble')
                $('#' + bubble, ed.contentDocument.body).addClass('selected')
            )
            $(ed.contentDocument.body).onOrDelegate('mouseout','.inlinecomment', (ev) ->
                $('.inlinecomment,.comment-bubble', ed.contentDocument.body).removeClass('selected')
            )

            #Highlight related text when user rolls over comment bubble
            $(ed.contentDocument.body).onOrDelegate('mouseover','.comment-bubble', (ev) ->
                $(this).addClass('selected')
                target = $(this).attr('data-target')
                $('.inlinecomment', ed.contentDocument.body).removeClass('selected')
                $('#' + target, ed.contentDocument.body).addClass('selected')
            )
            $(ed.contentDocument.body).onOrDelegate('mouseout','.comment-bubble', (ev) ->
                $(this).removeClass('selected')
                target = $(this).attr('data-target')
                $('#' + target, ed.contentDocument.body).removeClass('selected')
            )

            #Prevent user from deleting the comment container when user is writing a reply
            #$(ed.contentDocument.body).onOrDelegate('keydown', '.comment-insert', (ev) ->
            $(ed.contentDocument.body).keydown((ev) ->

                if (ev.keyCode == 8) #8 = delete key
                    range = ed.selection.getRng()

                    #Ignore everything outside comments
                    if ($(range.startContainer).closest('.comment-insert').length == 0)
                        return true

                    #Only prevent backspace at the start of the range
                    if (range.startOffset > 0)
                        return true
                    else
                        return false

                return true;
            )

            $(ed.contentDocument.body).onOrDelegate('click','.reply-button', (ev) ->
                time = new Date()
                key = ed.blendInlineComment.getUuid()
                bubble = $(this).closest('.comment-bubble')
                reply = $(this).closest('.comment-reply')
                target = bubble.attr('data-target')
                id = ed.blendInlineComment.getUuid()
                idTag = "comment_replyx_"
                idTag += id

                commentDiv = $('<div class="inline-comment editing"><p class="comment-insert"><span class="start"><br /></span></p></div>')
                commentDiv.attr('id', "reply_" + bubble.attr('data-id'))

                replyDiv = $('<div class="reply-text" contenteditable="true"><button class="reply-cancel-button">Cancel</button></div>')
                replyDiv.attr('data-new', 1)
                replyDiv.attr('id', idTag)
                replyDiv.attr('data-reply', bubble.attr('data-id'))
                replyDiv.addClass('new-comment')
                replyDiv.prepend(commentDiv)


                comment = $('<div><strong class="reply-header">Reply:</strong></div>')
                comment.append(replyDiv)

                $(this).replaceWith(comment)

                ed.selection.select($('.start', commentDiv).get(0))
                ed.selection.collapse(true)

                #ed.selection.select($('p', comment).get(0))
                #ed.selection.collapse()
            )

            $(ed.contentDocument.body).onOrDelegate('click','.reply-cancel-button', (ev) ->
                reply = $(this).closest('.comment-reply')
                reply.html("<button class=\"reply-button\">Reply</button>")
            )

        )



    updateComments: (ed, cm, n, co, ob) ->
        #The timeout is a hack to get around the fact that eZ mangles button state in a later listener
        setTimeout( ->
            cm.setDisabled('inlinecomment', co ? 0 : 1)
        , 100 )

        #Position comments
        tops = {} #Hash to make sure comments don't appear in identical positions
        $('.comment-bubble', ed.contentDocument).each(() ->
            #Locate the matching comment and position near it
            target = $(this).attr('data-target')
            comment=$("##{target}", ed.contentDocument)
            coords=comment.offset()
            top = coords.top
            right = 8
            while (typeof tops[top] != 'undefined')
                top = top + 10
                right = right + 10

            tops[top] = true

            $(this).removeClass('selected')
            $(this).css({'position':'absolute','top':top + 'px', 'right': right + 'px'})
        )
        $('.inlinecomment', ed.contentDocument).removeClass('selected')

        blockEdit = false
        blockEditElem = false
        dontComment = false
        $.each(ob.parents, () ->
            if (this.className.indexOf('blNonEditable') > -1)
                blockEdit = true
                blockEditElem = this
                dontComment = true
            if (this.className.indexOf('comment-bubble') > -1)
                dontComment = true
            if (this.className.indexOf('inlinecomment') > -1)
                $(this).addClass('selected')
                targetId=$(this).attr('id').replace('tag','bubble')
                $("##{targetId}", ed.contentDocument).addClass('selected')
                true
        )
        ###

        if (dontComment)
            setTimeout( ->
                cm.setDisabled('inlinecomment', 1)

            , 150)
        if (blockEdit)
            ed.selection.select(blockEditElem)
        ###
    addComment: () ->
        ed = this
        time = new Date()
        key = this.blendInlineComment.getUuid()
        sel = this.selection
        bubble = this.blendInlineComment.makeBubble('Author',time, '<p class="comment-insert"><span class="start"><br /></span></p>', true, key, [], ed)

        sel.setContent("<span id=\"comment_tag_#{key}\" type=\"custom\" class=\"ezoeItemCustomTag inlinecomment\" data-id=\"#{key}\" customattributes=\"comment_id|#{key}\">" + sel.getContent() + '</span>' )

        this.dom.add(this.contentDocument.body, bubble.get(0))

        this.selection.select($('.start', bubble).get(0))
        this.selection.collapse(true)

    deleteComment: (bubble) ->
        console.log('delete')
        return true

    getUuid: ->
        s = []
        hexDigits = "0123456789abcdef";
        for i in [0..36]
            s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1)
        s[14] = "4"; # bits 12-15 of the time_hi_and_version field to 0010
        s[19] = hexDigits.substr((s[19] & 0x3) | 0x8, 1);  # bits 6-7 of the clock_seq_hi_and_reserved to 01
        s[8] = s[13] = s[18] = s[23] = "-"

        return s.join("")

    makeBubble: (author, time, comment, isNew, id, replies, ed) ->

        formatDate = (date) ->
            minutes = date.getMinutes().toString()
            if minutes.length < 2
                minutes = "0" + minutes
            formatted="#{date.getMonth() + 1}/#{date.getDate()}/#{date.getFullYear()} at "
            if (date.getHours() > 12)
                formatted +="#{date.getHours() - 12}:#{minutes} pm"
            else
                formatted +="#{date.getHours()}:#{minutes} am"

            formatted
        idTag = "comment_bubble_"
        #if (isNew)
        #    idTag += 'n'
        idTag += id
        bubble = $("<div class=\"comment-bubble no-diff\"></div>")
        bubble.attr('id', idTag)
        bubble.attr('data-id', id)
        canEditComment = ''

        if (isNew)
            bubble.attr('data-new', 1)
            bubble.addClass('new-comment')
            canEditComment = 'editing'
        else
            bubble.attr('contenteditable', 'false')
        bubble.attr('data-target', idTag.replace('comment_bubble','comment_tag'))

        bubble.append("<button class=\"delete-button \">Delete</button>")

        if (!isNew)
            bubble.append("<span class=\"author \">#{author}</span> ")
            bubble.append("<span class=\"time \">#{formatDate(time)}</span><br />")
            #canEditComment = 'blNonEditable'

        bubble.append("<div class=\"inline-comment #{canEditComment}\">#{comment}</div>");

        if (!isNew)
            $.each(replies, () ->
                time = new Date(this.added * 1000)
                reply = $('<div class=\"comment-reply\"></div>')
                reply.append("<span class=\"author \">#{this.author}</span> ")
                reply.append("<span class=\"time \">#{formatDate(time)}</span><br />")
                reply.append("<div class=\"inline-comment #{canEditComment}\">#{this.comment}</div>");
                bubble.append(reply)

            )

            bubble.append("<div class=\"comment-reply\"><button class=\"reply-button\">Reply</button></div>")

        return bubble;

    injectComments: (ed, evt) ->
        plug = this

        language = eZOeAttributeSettings.language.substr(1)
        version = eZOeAttributeSettings.ez_contentobject_version
        editorId = ed.id
        if (ed['parentEditorId'])
            editorId = ed.parentEditorId
        attributeId = editorId.split('_').pop()
        console.log('INJECTCOMMENTS:' + "/inlinecomments/read/#{attributeId}/#{version}/#{language}")

        #Parse the document for inline comment tags and add the comment bubbles
        $.get("/inlinecomments/read/#{attributeId}/#{version}/#{language}", {})
            .done((data) ->
                #console.log('INJECTCOMMENTSREPONSE')
                #console.log(data);
                tops = {} #Hash to prevent comment bubbles from appearing exactly overlapped

                $('.inlinecomment', ed.contentDocument).each ->
                    custom = $(this).attr('customattributes')
                    tagId = custom.split('|').pop()
                    if (!data[tagId])
                        return
                    $(this).attr('id',"comment_tag_#{tagId}")
                    time = new Date(data[tagId].added * 1000)

                    #find Replies
                    replies = []
                    $.each(data, () ->
                        if (this.replyTo == tagId)
                            replies.push(this)
                    )

                    bubble = ed.blendInlineComment.makeBubble(
                        data[tagId].author,
                        time,
                        data[tagId].comment,
                        false,
                        tagId,
                        replies,
                        ed
                    )

                    coords = $(this).offset()

                    top = coords.top
                    right = 8

                    while (typeof tops[top] != 'undefined')
                        top = top + 10
                        right = right + 10

                    tops[top] = true

                    bubble.css({position:'absolute',top: top + 'px', right: right + 'px'})

                    ed.dom.add(ed.contentDocument.body, bubble.get(0))

                    return true

                #Clear undo levels to remove automated editing from undo list.
                ed.undoManager.clear()
                ed.nodeChanged()

            )


    handleSave: (ed, object) ->

        content = jQuery('<div>' + object.content + '</div>', null)

        commentData = {}
        $('.new-comment', content).each(() ->
            id = $(this).attr('id').substr(15)
            reply = null
            if (typeof $('.inline-comment', this).attr('id') != 'undefined')
                reply = $('.inline-comment', this).attr('id').substr(6)
            comment = $('.inline-comment', this).html().trim()
            commentData[id]={comment: comment, replyTo: reply}
        )

        if (!$.isEmptyObject(commentData))
            language = eZOeAttributeSettings.language.substr(1)
            version = eZOeAttributeSettings.ez_contentobject_version
            editorId = ed.id
            if (ed['parentEditorId'])
                editorId = ed.parentEditorId
            attributeId = editorId.split('_').pop()
            formToken = $("#ezxform_token_js").attr('content')
            $.post("/inlinecomments/write/#{attributeId}/#{version}/#{language}", {comments: commentData, ezxform_token: formToken})
            .done( (response) ->
                    console.log(response)
                )

        $('.comment-bubble', content).remove()
        object.content = content.html()

        return true

    handleComments: (ed, object) ->
        language = eZOeAttributeSettings.language.substr(1)
        version = eZOeAttributeSettings.ez_contentobject_version
        editorId = ed.id
        if (ed['parentEditorId'])
            editorId = ed.parentEditorId
        attributeId = editorId.split('_').pop()

        dom = ed.dom;
        newComments = {}
        commentData = {}


        tinymce.each(dom.select('div', object.node).reverse(), (n) ->
            if (n && (dom.hasClass(n, 'comment-bubble')))
                #See if it's a new comment
                targetId = dom.getAttrib(n, 'data-target')
                id = dom.getAttrib(n, 'data-id')
                if (dom.getAttrib(n, 'data-new') == '1')
                    console.log('New Comment ID' + dom.getAttrib(n, 'data-target'))
                    console.log($('.inline-comment',n).html())
                    if ($('.inline-comment',n).text().trim().length > 0)
                        newComments[id]={bubble: n, id: id, tag: dom.select("span##{targetId}").pop()}
                        commentData[id]=$('.inline-comment',n).html()
                dom.remove(n, 0);
                return true
        )
        if (ed.blendInlineComment.hasProperties(newComments))
            formToken = $("#ezxform_token_js").attr('content')
            $.post("/inlinecomments/write/#{attributeId}/#{version}/#{language}", {comments: commentData, ezxform_token: formToken})
            .done( (response) ->
                tinymce.each(newComments, (obj, id) ->
                    tag = dom.select("span##{id}")
                )
                console.log(response)
            )

    #Helper function to see an an object has properties
    hasProperties: (object) ->
        hasProps = false
        $.each(object, ->
            hasProps = true
        )
        return hasProps


    getInfo: ->
        return {
            longname : 'Google Drive Import plugin'
            author : 'Blend Interactive'
            authorurl : 'http://blendinteractive.com'
            infourl : 'http://blendinteractive.com'
            version : "1.0"
        }
})
tinymce.PluginManager.add('blendinlinecomments', tinymce.plugins.BlendInlineCommentsPlugin);

