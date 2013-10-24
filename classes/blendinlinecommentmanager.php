<?php

class BlendInlineCommentManager
{
    public function fetchComments($contentAttributeId, $version, $language)
    {
        $comments = array();
        $results = BlendInlineComment::fetchByContentAttribute($contentAttributeId, $version, $language);
        foreach ( $results as $result ) {
            $comments[$result->guid] = $result;
        }
        return $comments;

    }

    public function saveComments($contentAttributeId, $version, $language, $comments)
    {
        $user = eZUser::currentUser();
        $userObject = $user->attribute('contentobject');
        $userName = $userObject->attribute('name');
        $time = time();
        $results = array();
        //$user->
        foreach ($comments as $id => $commentData) {
            $comment = new BlendInlineComment(
                array(
                    'guid' => $id,
                    'author' => $userName,
                    'added_at' => $time,
                    'comment' => $commentData['comment'],
                    'contentobjectattribute_id' => $contentAttributeId,
                    'version' => $version,
                    'language' => $language,
                    'reply_to'=> $commentData['replyTo'],
                    'user_id' => $user->attribute('contentobject_id')
                )
            );

            $comment->store();
            $results[$id] = $comment->attribute('guid');
        }
        return $results;
    }
}