begin;

SELECT _v.register_patch( '24-time-resolution-function', NULL, NULL );

CREATE FUNCTION core.get_time_resolution(input TIMESTAMP) RETURNS TEXT AS $$
DECLARE
  result TEXT;
  hour INT;
  minute INT;
  second FLOAT;
BEGIN
  hour := EXTRACT(hour from input)::INT;
  minute := EXTRACT(minute from input)::INT;
  second := EXTRACT(second from input)::INT;
  CASE
    WHEN input = 'infinity' THEN
      result := 'infinity';
    WHEN hour = 0 AND minute = 0 AND second = 0 THEN
      result := 'day';
    WHEN minute = 0 AND second = 0 THEN
      result := 'hour';
    WHEN second = 0 THEN
      result := 'minute';
    ELSE
      result := 'second';
  END CASE;
  RETURN RESULT;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

commit;