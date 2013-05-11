
tinymce.PluginManager.requireLangPack('blendinlinecomments');
tinymce.create('tinymce.plugins.BlendInlineCommentsPlugin', {
    init: (ed, url) ->
        ed.blendInlineComment = {
            makeBubble: this.makeBubble
            hasProperties: this.hasProperties
        }
        ed.addCommand 'addinlinecomment', this.addComment
        ed.addButton('inlinecomment', {
              id: 'inlinecomment'
              title: 'Add Comment'
              cmd: 'addinlinecomment'
              #image: url.replace('/ezoe/','/blendinlinecomments/') + '/img/comment.png'
        })
        ed.onLoadContent.add this.injectComments
        ed.onPreProcess.add this.handleComments
        ed.onNodeChange.add (ed, cm, n, co) ->
            #The timeout is a hack to get around the fact that eZ mangles button state in a later listener
            setTimeout( ->
                cm.setDisabled('inlinecomment', co ? 0 : 1)
            , 100 )

            true


    addComment: ->
        time = new Date()
        key = time.valueOf()
        sel = this.selection
        bubble = this.blendInlineComment.makeBubble('Author',time, '<p class="comment-insert">&nbsp;</p>', true, key)

        sel.setContent(bubble.wrap('<p>').parent().html() + "<span id=\"comment_tag_n#{key}\" type=\"custom\" class=\"ezoeItemCustomTag inlinecomment\">" + sel.getContent() + '</span>' )
        console.log('comment code here')

#    testSubmit: (ed, evt) ->
#        console.log('onSubmit')
#        console.log(evt)
    makeBubble: (author, time, comment, isNew, id) ->
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
        if (isNew)
            idTag += 'n'
        idTag += id
        bubble = $("<div class=\"comment-bubble\"></div>")
        bubble.attr('id', idTag)
        bubble.attr('comment-tag-target', idTag.replace('comment_bubble','comment_tag'))

        if (!isNew)
            bubble.append("<span class=\"author mceItemNonEditable\">#{author}</span><br />")
            bubble.append("<span class=\"time mceItemNonEditable\">#{formatDate(time)}</span><br />")

        bubble.append("<div class=\"inline-comment #{(isNew ? '' : ' mceItemNonEditable')}\">#{comment}</div>");


    injectComments: (ed, evt) ->
        plug = this
        urlTokens = window.location.pathname.split('/')
        language = urlTokens.pop()
        version = urlTokens.pop()
        attributeId = ed.id.split('_').pop()

        #Parse the document for inline comment tags and add the comment bubbles
        $.get("/inlinecomments/read/#{attributeId}/#{version}/#{language}", {})
            .done((data) ->
                console.log(data);
                $('.inlinecomment', ed.contentDocument).each ->
                    custom = $(this).attr('customattributes')
                    tagId = custom.split('|').pop()
                    $(this).attr('id',"comment_tag_#{tagId}")
                    time = new Date(data[tagId].added * 1000)

                    bubble = ed.blendInlineComment.makeBubble(
                        data[tagId].author,
                        time,
                        data[tagId].comment,
                        false,
                        tagId
                    )

                    $(this).before(bubble)

            )

    handleComments: (ed, object) ->
        urlTokens = window.location.pathname.split('/')
        language = urlTokens.pop()
        version = urlTokens.pop()
        attributeId = ed.id.split('_').pop()

        #Remove all the comment bubbles from the document
        dom = ed.dom;
        newComments = {}
        commentData = {}
        tinymce.each(dom.select('div', object.node).reverse(), (n) ->
            if (n && (dom.hasClass(n, 'comment-bubble')))
                #See if it's a new comment
                targetId = dom.getAttrib(n, 'comment-tag-target')
                if (targetId.indexOf('comment_tag_n') == 0)
                    console.log('New Comment ID' + dom.getAttrib(n, 'comment-tag-target'))
                    console.log($('.inline-comment',n).html())
                    if ($('.inline-comment',n).text().trim().length > 0)
                        newComments[targetId]={bubble: n, tag: dom.select("span##{targetId}").pop()}
                        commentData[targetId]=$('.inline-comment',n).html()
                dom.remove(n, 0);
                return true
        )
        if (ed.blendInlineComment.hasProperties(newComments))
            formToken = $("#ezxform_token_js").attr('content')
            $.post("/inlinecomments/write/#{attributeId}/#{version}/#{language}", {comments: commentData, ezxform_token: formToken})
            .done( (response) ->
                tinymce.each(newComments, (obj, id) ->
                    tag = dom.select("span##{id}")
                    dom.setAttrib(tag, 'customattributes', "comment_id|#{response[id]}")
                    dom.setAttrib(tag, 'id', "comment_tag_#{response[id]}")
                    bubbleName = id.replace('_tag_','_bubble_')
                    bubble = dom.select("div##{bubbleName}")
                    dom.setAttrib(bubble, 'comment-tag-target', "comment_tag_#{response[id]}")
                    dom.setAttrib(bubble, 'id', "comment_bubble_#{response[id]}")
                )
                console.log(response)
            )

        #$('.comment-bubble', ed.contentDocument).remove()
    #Helper function to see an an object has properties
    hasProperties: (object) ->
        hasProps = false
        $.each(object, ->
            hasProps = true
        )
        return hasProps


    getInfo: ->
        {
            longname : 'Google Drive Import plugin'
            author : 'Blend Interactive'
            authorurl : 'http://blendinteractive.com'
            infourl : 'http://blendinteractive.com'
            version : "1.0"
        }
})
tinymce.PluginManager.add('blendinlinecomments', tinymce.plugins.BlendInlineCommentsPlugin);

