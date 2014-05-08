ALTER PROCEDURE "test_parse_input"(IN @p_szEditSuggestionID varchar(10)) 

AS
BEGIN

DECLARE @String long varchar
DECLARE @Param varchar(260)
DECLARE @VarValue varchar(250)
DECLARE @VarName varchar(10)

SET @String = (SELECT top 1 fd_newform
  FROM sy_suggestion_monitor
  WHERE fd_entity = 'xxxx')

CREATE TABLE #t
(
    pk int PRIMARY KEY DEFAULT AUTOINCREMENT,
    gt_suggestion_id int,    
    var_name varchar(10),
    var_value varchar(250)
)

WHILE Locate(@String,'|') > 0
BEGIN
    SET @Param = LEFT(@String, Locate(@String,'|') - 1)

    IF RIGHT(@Param,1) <> '='
        BEGIN
            SET @VarName = LEFT(@Param, Locate(@Param,'=') - 1)
            SET @VarValue = SubString(@Param, Locate(@Param,'=') - 1)
        END
    ELSE
        BEGIN
            SET @VarName = LEFT(@Param, Locate(@Param,'=') - 1)
            SET @VarValue = ''
        END

INSERT INTO #t(gt_suggestion_id, var_name, var_value) VALUES (@p_szEditSuggestionID, Substring(@VarName, 4), Substring(@VarValue, 3))


        SET @String = RIGHT(@String, Len(@String) - Len(@Param) - 1)
END

IF Right(@String,1) <> '='
    BEGIN
        SET @VarName = LEFT(@String, Locate(@String,'|') - 1)
        SET @VarValue = SubString(@String, Locate(@String,'=') + 1)
    END
    ELSE
    BEGIN
        SET @VarName = LEFT(@String, Locate(@String,'=') - 1)
        SET @VarValue = ''
    END

    INSERT INTO gt_cart_det (gt_suggestion_id, gt_line_number, gt_variable_value)
    SELECT gt_suggestion_id,
           var_name,
           var_value
    FROM #t
  
SELECT * FROM gt_cart_det WHERE gt_suggestion_id = @p_szEditSuggestionID

END