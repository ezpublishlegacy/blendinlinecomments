<?php

class BlendInlineComment extends eZPersistentObject
{

    public static function definition()
    {
        return array(
            'fields' => array(
                'id' => array('name' => 'id',
                    'datatype' => 'integer',
                    'default' => 0,
                    'required' => true),
                'language' => array('name' => 'language',
                    'datatype' => 'string',
                    'default' => '',
                    'required' => true),
                'added_at' => array('name' => 'added',
                    'datatype' => 'integer',
                    'default' => 0,
                    'required' => true),
                'user_id' => array('name' => 'userId',
                    'datatype' => 'integer',
                    'default' => 0,
                    'required' => false),
                'author' => array('name' => 'author',
                    'datatype' => 'string',
                    'default' => '',
                    'required' => false),
                'contentobjectattribute_id' => array('name' => 'contentObjectAttributeId',
                    'datatype' => 'integer',
                    'default' => 0,
                    'required' => true),
                'reply_to' => array('name' => 'replyTo',
                    'datatype' => 'integer',
                    'default' => 0,
                    'required' => true),
                'version' => array('name' => 'version',
                    'datatype' => 'integer',
                    'default' => 0,
                    'required' => true),
                'comment' => array('name' => 'comment',
                    'datatype' => 'string',
                    'default' => '',
                    'required' => true),
            ),
            'keys' => array('id'),
            'function_attributes' => array(),
            'increment_key' => 'id',
            'class_name' => 'BlendInlineComment',
            'name' => 'blend_inlinecomment');
    }

    /**
     * Fetch comment by given id.
     *
     * @param int $id
     * @return BlendInlineComment
     */
    static function fetch( $id )
    {
        $cond = array( 'id' => $id );
        return eZPersistentObject::fetchObject( self::definition(), null, $cond );
    }

    static function fetchByContentAttribute( $contentObjectAttributeId, $version, $language )
    {
        $cond = array(
            'contentobjectattribute_id' => $contentObjectAttributeId,
//            'version' => $version,
            'language' => $language
        );

        return eZPersistentObject::fetchObjectList( self::definition(), null, $cond);
    }

}