
-- never execute this script :)

Begin;

-- the next line is to let this file fail to be executed
never execute this file

-- deleting all sample before date

DELETE FROM esa.samples WHERE taken < now() - '2 days'::interval ;




-- just to avoid any troubles in case of executing it
rollback;
