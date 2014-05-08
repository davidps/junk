ALTER PROCEDURE "test_parse_input"(IN @p_szEditSuggestionID varchar(10), @p_szEntity varchar(4)/* [IN | OUT | INOUT] parameter_name parameter_type [DEFAULT default_value], ... */ )
/* RESULT( column_name column_type, ... ) */

/* parse out variables */
AS
BEGIN

DECLARE @String long varchar
DECLARE @Param varchar(260)
DECLARE @VarValue varchar(250)
DECLARE @VarNumber varchar(10)


SET @String = (SELECT top 1 fd_newform
  FROM sy_suggestion_monitor
  WHERE fd_entity = 'xxxx')


CREATE TABLE #t
(
    gt_suggestion_id int,    
    var_number varchar(10),
    var_value varchar(250)
)

WHILE Locate(@String,'|') > 0
BEGIN
    SET @Param = LEFT(@String, Locate(@String,'|') - 1)

    IF RIGHT(@Param,1) <> '='
        BEGIN
            SET @VarNumber = LEFT(@Param, Locate(@Param,'=') - 1)
            SET @VarValue = SubString(@Param, Locate(@Param,'=') - 1)
        END
    ELSE
        BEGIN
            SET @VarNumber = LEFT(@Param, Locate(@Param,'=') - 1)
            SET @VarValue = ''
        END

INSERT INTO #t(gt_suggestion_id, var_number, var_value) VALUES (@p_szEditSuggestionID, Substring(@VarNumber, 4), Substring(@VarValue, 3))


        SET @String = RIGHT(@String, Len(@String) - Len(@Param) - 1)
END

IF Right(@String,1) <> '='
    BEGIN
        SET @VarNumber = LEFT(@String, Locate(@String,'|') - 1)
        SET @VarValue = SubString(@String, Locate(@String,'=') + 1)
    END
    ELSE
    BEGIN
        SET @VarNumber = LEFT(@String, Locate(@String,'=') - 1)
        SET @VarValue = ''
    END
/*
INSERT INTO gt_cart_det (gt_suggestion_id, 
                             gt_line_number, 
                             gt_variable_name, 
                             gt_variable_value)
    SELECT gt_suggestion_id,
           var_number,
           g.gt_description,
           var_value
    FROM #t
    INNER JOIN gt_form_lines_setup g
    ON g.gt_line_number = #t.var_number
 */
INSERT INTO gt_cart_det (gt_suggestion_id, 
gt_line_number, 
gt_variable_name, 
gt_variable_value)
SELECT gt_suggestion_id,
var_number,
g.gt_description,
var_value
FROM #t
INNER JOIN gt_form_lines_setup g
ON g.gt_line_number = #t.var_number AND g.fd_entity = @p_szEntity AND g.gt_new_grantee_yn = 'N'


SELECT * FROM gt_cart_det WHERE gt_suggestion_id = @p_szEditSuggestionID

END