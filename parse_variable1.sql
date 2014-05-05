ALTER PROCEDURE "IFS"."test_parse_input"( /* [IN | OUT | INOUT] parameter_name parameter_type [DEFAULT default_value], ... */ )
/* RESULT( column_name column_type, ... ) */

AS
BEGIN

DECLARE @String long varchar

DECLARE myCursor CURSOR FOR

SELECT fd_newform
  FROM sy_suggestion_monitor
 WHERE fd_entity = '0116'

OPEN myCursor

FETCH myCursor INTO @String 

CLOSE myCursor

DECLARE @StringChunk varchar(250)
DECLARE @Counter int

WHILE Len(@String) > 0
BEGIN    
    SET @Counter = 0
    IF PATINDEX('%|%', @String) > 0
        BEGIN
            SET @StringChunk = SubStr(@String, 0, PATINDEX('%|%', @String))
            SET @Counter = @Counter + 1
            INSERT INTO #tt_1 (col_1, col_2) VALUES (@StringChunk, @Counter)
            SET @String = SubStr(@String, LEN(@StringChunk + '|') + 1, LEN(@String))
        END
    END
CREATE TABLE #tt_1
(
    col_1 long varchar, 
    col_2 int 
)
/*INSERT INTO #tt_1 VALUES (@String)*/
SELECT * FROM #tt_1

END