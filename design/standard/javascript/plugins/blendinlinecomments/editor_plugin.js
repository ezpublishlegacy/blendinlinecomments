(function() {

  tinymce.PluginManager.requireLangPack('blendinlinecomments');

  tinymce.create('tinymce.plugins.BlendInlineCommentsPlugin', {
    init: function(ed, url) {
      ed.blendInlineComment = {
        makeBubble: this.makeBubble,
        hasProperties: this.hasProperties
      };
      ed.addCommand('addinlinecomment', this.addComment);
      ed.addButton('inlinecomment', {
        id: 'inlinecomment',
        title: 'Add Comment',
        cmd: 'addinlinecomment'
      });
      ed.onLoadContent.add(this.injectComments);
      ed.onPreProcess.add(this.handleComments);
      return ed.onNodeChange.add(function(ed, cm, n, co) {
        setTimeout(function() {
          return cm.setDisabled('inlinecomment', co != null ? co : {
            0: 1
          });
        }, 100);
        return true;
      });
    },
    addComment: function() {
      var bubble, key, sel, time;
      time = new Date();
      key = time.valueOf();
      sel = this.selection;
      bubble = this.blendInlineComment.makeBubble('Author', time, '<p class="comment-insert">&nbsp;</p>', true, key);
      sel.setContent(bubble.wrap('<p>').parent().html() + ("<span id=\"comment_tag_n" + key + "\" type=\"custom\" class=\"ezoeItemCustomTag inlinecomment\">") + sel.getContent() + '</span>');
      return console.log('comment code here');
    },
    makeBubble: function(author, time, comment, isNew, id) {
      var bubble, formatDate, idTag;
      formatDate = function(date) {
        var formatted, minutes;
        minutes = date.getMinutes().toString();
        if (minutes.length < 2) {
          minutes = "0" + minutes;
        }
        formatted = "" + (date.getMonth() + 1) + "/" + (date.getDate()) + "/" + (date.getFullYear()) + " at ";
        if (date.getHours() > 12) {
          formatted += "" + (date.getHours() - 12) + ":" + minutes + " pm";
        } else {
          formatted += "" + (date.getHours()) + ":" + minutes + " am";
        }
        return formatted;
      };
      idTag = "comment_bubble_";
      if (isNew) {
        idTag += 'n';
      }
      idTag += id;
      bubble = $("<div class=\"comment-bubble\"></div>");
      bubble.attr('id', idTag);
      bubble.attr('comment-tag-target', idTag.replace('comment_bubble', 'comment_tag'));
      if (!isNew) {
        bubble.append("<span class=\"author mceItemNonEditable\">" + author + "</span><br />");
        bubble.append("<span class=\"time mceItemNonEditable\">" + (formatDate(time)) + "</span><br />");
      }
      return bubble.append("<div class=\"inline-comment " + (isNew != null ? isNew : {
        '': ' mceItemNonEditable'
      }) + "\">" + comment + "</div>");
    },
    injectComments: function(ed, evt) {
      var attributeId, language, plug, urlTokens, version;
      plug = this;
      urlTokens = window.location.pathname.split('/');
      language = urlTokens.pop();
      version = urlTokens.pop();
      attributeId = ed.id.split('_').pop();
      return $.get("/inlinecomments/read/" + attributeId + "/" + version + "/" + language, {}).done(function(data) {
        console.log(data);
        return $('.inlinecomment', ed.contentDocument).each(function() {
          var bubble, custom, tagId, time;
          custom = $(this).attr('customattributes');
          tagId = custom.split('|').pop();
          $(this).attr('id', "comment_tag_" + tagId);
          time = new Date(data[tagId].added * 1000);
          bubble = ed.blendInlineComment.makeBubble(data[tagId].author, time, data[tagId].comment, false, tagId);
          return $(this).before(bubble);
        });
      });
    },
    handleComments: function(ed, object) {
      var attributeId, commentData, dom, formToken, language, newComments, urlTokens, version;
      urlTokens = window.location.pathname.split('/');
      language = urlTokens.pop();
      version = urlTokens.pop();
      attributeId = ed.id.split('_').pop();
      dom = ed.dom;
      newComments = {};
      commentData = {};
      tinymce.each(dom.select('div', object.node).reverse(), function(n) {
        var targetId;
        if (n && (dom.hasClass(n, 'comment-bubble'))) {
          targetId = dom.getAttrib(n, 'comment-tag-target');
          if (targetId.indexOf('comment_tag_n') === 0) {
            console.log('New Comment ID' + dom.getAttrib(n, 'comment-tag-target'));
            console.log($('.inline-comment', n).html());
            if ($('.inline-comment', n).text().trim().length > 0) {
              newComments[targetId] = {
                bubble: n,
                tag: dom.select("span#" + targetId).pop()
              };
              commentData[targetId] = $('.inline-comment', n).html();
            }
          }
          dom.remove(n, 0);
          return true;
        }
      });
      if (ed.blendInlineComment.hasProperties(newComments)) {
        formToken = $("#ezxform_token_js").attr('content');
        return $.post("/inlinecomments/write/" + attributeId + "/" + version + "/" + language, {
          comments: commentData,
          ezxform_token: formToken
        }).done(function(response) {
          tinymce.each(newComments, function(obj, id) {
            var bubble, bubbleName, tag;
            tag = dom.select("span#" + id);
            dom.setAttrib(tag, 'customattributes', "comment_id|" + response[id]);
            dom.setAttrib(tag, 'id', "comment_tag_" + response[id]);
            bubbleName = id.replace('_tag_', '_bubble_');
            bubble = dom.select("div#" + bubbleName);
            dom.setAttrib(bubble, 'comment-tag-target', "comment_tag_" + response[id]);
            return dom.setAttrib(bubble, 'id', "comment_bubble_" + response[id]);
          });
          return console.log(response);
        });
      }
    },
    hasProperties: function(object) {
      var hasProps;
      hasProps = false;
      $.each(object, function() {
        return hasProps = true;
      });
      return hasProps;
    },
    getInfo: function() {
      return {
        longname: 'Google Drive Import plugin',
        author: 'Blend Interactive',
        authorurl: 'http://blendinteractive.com',
        infourl: 'http://blendinteractive.com',
        version: "1.0"
      };
    }
  });

  tinymce.PluginManager.add('blendinlinecomments', tinymce.plugins.BlendInlineCommentsPlugin);

}).call(this);

// Generated by CoffeeScript 1.5.0-pre
