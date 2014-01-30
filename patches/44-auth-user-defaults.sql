BEGIN;

SELECT _v.register_patch('44-auth-user-defaults', 
                          array['8-authdb'] );

-- deleting old users
DELETE FROM auth.users
 WHERE logname = 'testuser';

DELETE FROM auth.users 
 WHERE logname = 'mg-traits-tester';

-- adding sensitive defaults to auth.users

-- first name not null
UPDATE auth.users
   SET  first_name=''
 WHERE first_name is null;

ALTER TABLE auth.users
   ALTER COLUMN first_name SET NOT NULL;

-- initials not null and default
UPDATE auth.users
   SET  initials=''
 WHERE initials is null;
ALTER TABLE auth.users
   ALTER COLUMN initials SET DEFAULT '';
ALTER TABLE auth.users
   ALTER COLUMN initials SET NOT NULL;

-- last name not null
UPDATE auth.users
   SET  last_name =''
 WHERE last_name is null;
ALTER TABLE auth.users
   ALTER COLUMN last_name SET NOT NULL;

-- description not null and defualt ''
UPDATE auth.users
   SET  description = ''
 WHERE description is null;
ALTER TABLE auth.users
   ALTER COLUMN description SET DEFAULT '';
ALTER TABLE auth.users
   ALTER COLUMN description SET NOT NULL;

-- lastlogin to infinity if never logged in
UPDATE auth.users
   SET  lastlogin = 'infinity'
 WHERE lastlogin IS NULL;

ALTER TABLE auth.users
   ALTER COLUMN lastlogin SET DEFAULT 'infinity';

UPDATE auth.users
   SET  provider = ''
 WHERE provider is null;
ALTER TABLE auth.users
   ALTER COLUMN provider SET DEFAULT '';
ALTER TABLE auth.users
   ALTER COLUMN provider SET NOT NULL;
-- not null
UPDATE auth.users
   SET  external_id = ''
 WHERE external_id is null;
ALTER TABLE auth.users
   ALTER COLUMN external_id SET DEFAULT '';
ALTER TABLE auth.users
   ALTER COLUMN external_id SET NOT NULL;


commit; 
