<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/*
 * Use this file to override any settings from config.php
 *
 * For descriptions of the options please refer to config.php.
 */
$config['base_url'] = %%%BASE_URL%%%; // URL to the application
$config['encryption_key'] = %%%ENCRYPTION_KEY%%%; // set this to a 32char random string
$config['cache_backend'] = %%%CACHE_BACKEND%%%;
$config['index_page'] = %%%INDEX_PAGE%%%;
$config['upload_path'] = FCPATH.'data/uploads';

// This address will be used as the sender for emails (like password recovery mails).
$config['email_from'] = %%%EMAIL_FROM%%%;

// Make sure to adjust PHP's limits (post_max_size, upload_max_filesize) if necessary
$config['upload_max_size'] = intval(%%%UPLOAD_MAX_SIZE%%%);

// Files smaller than this will be highlit, larger ones will simply be downloaded
// even if requested to be highlit.
$config['upload_max_text_size'] = intval(%%%UPLOAD_MAX_TEXT_SIZE%%%);

// Files older than this will be deleted by the cron job or when accessed.
// 0 disables deletion.
$config['upload_max_age'] = intval(%%%UPLOAD_MAX_AGE%%%);

// Action keys (invitions, password resets) will be deleted after this time by
// the cron job.
$config['actions_max_age'] = intval(%%%ACTIONS_MAX_AGE%%%);

// Files smaller than this won't be deleted (even if they are old enough)
$config['small_upload_size'] = intval(%%%SMALL_UPLOAD_SIZE%%%);

// Maximum size for multipaste tarballs. 0 disables the feature
$config['tarball_max_size'] = intval(%%%TARBALL_MAX_SIZE%%%);

// Multipaste tarballs older than this will be deleted by the cron job
// Changing this is not recommended
$config['tarball_cache_time'] = intval(%%%TARBALL_CACHE_TIME%%%);

// The maximum number of active invitation keys per account.
$config['max_invitation_keys'] = intval(%%%MAX_INVITATION_KEYS%%%);
