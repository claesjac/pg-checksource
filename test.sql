select COUNT(*), x*y, SUM(CASE WHEN Foo IS NOT NULL THEN 1 ELSE 0 END)
  FROM Bar 
 WHERE Quax = $1 and Datestamp>=now() -'1 hour'::interval;