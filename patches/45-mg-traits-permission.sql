BEGIN;

SELECT _v.register_patch('45-mg-traits-permission', 
                          array['8-authdb','44-auth-user-defaults' ] );

-- defining a user for testing a 

INSERT INTO auth.users(
	   logname, 
	   first_name, 
	   initials, 
	   last_name, 
	   description, 
	   join_date, 
       pass, 
	   disabled, 
	   email, 
	   lastlogin, 
	   "external", 
	   provider, 
	   external_id)
    VALUES (
	   'mg-traits-tester',
	   'Meta',
	   DEFAULT,
 	   'Traits',
       '',
	   '2014-01-29 15:07:47.7+01',
	   '1000:c1e7d51485421d2f510c76f981ec7bca12ad2e7eb12bd68a:11b511dbef3ba27e10cfbc7cfd19fd68a947a0bd6bc5352d',
	   FALSE,
	   'rkottman@mpi-bremen.de',
       DEFAULT,
	   FALSE,
	   DEFAULT,
 	   DEFAULT);

INSERT INTO auth.roles VALUES ('mg_traits_user','for using MG-Traits Web Services for retrieving data');

INSERT INTO auth.roles VALUES ('mg_traits_submitter','for using MG-Traits Web Services to calculate new metagenomes');


INSERT INTO auth.web_resource_permissions(
            url_path, http_method, "role")
    VALUES ('ws/*/mg-traits/v*/jobs*', 'POST', 'mg_traits_submitter');


INSERT INTO auth.web_resource_permissions(
            url_path, http_method, "role")
    VALUES ('ws/*/mg-traits/v*/*', 'POST', 'mg_traits_user');





COMMIT; 
