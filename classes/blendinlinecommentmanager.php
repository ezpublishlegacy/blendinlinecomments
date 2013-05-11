<?php

class BlendInlineCommentManager
{
    public function fetchComments($contentAttributeId, $version, $language)
    {
        $comments = array();
        $results = BlendInlineComment::fetchByContentAttribute($contentAttributeId, $version, $language);
        foreach ( $results as $result ) {
            $comments[$result->id] = $result;
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
                    'author' => $userName,
                    'added_at' => $time,
                    'comment' => $commentData,
                    'contentobjectattribute_id' => $contentAttributeId,
                    'version' => $version,
                    'language' => $language,
                    'user_id' => $user->attribute('contentobject_id')
                )
            );

            $comment->store();
            $results[$id] = $comment->attribute('id');
        }
        return $results;
    }
}