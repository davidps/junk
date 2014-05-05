ALTER PROCEDURE "ifs"."proc_uf_get_grant_suggestion_form"
	(@p_szOrgID char, @p_szEntity char, @p_szOrgName char, @p_szProjectID char, @p_szError char, @p_szFundList char, @p_szAdvisorID char, @p_dFieldCoefficient decimal (15,2), @p_szEditSuggestionID char, @p_szRecentGrant char )
AS
BEGIN

DECLARE @szHtml varchar(1000)
DECLARE @szFormCopy varchar(2000)
DECLARE @szErrorMessage varchar(200)
DECLARE @szTitle varchar(250)
DECLARE @szProjectName varchar(100)
DECLARE @szNewForm char(1) --1 character
DECLARE @szAdvisorEmail varchar(250)
DECLARE @szAddress varchar(50)
DECLARE @szAddr1 varchar(50)
DECLARE @szAddr2 varchar(50)
DECLARE @szAddr3 varchar(50)
DECLARE @szCity varchar(40)
DECLARE @szState varchar(20)
DECLARE @szZip varchar(10)
DECLARE @szVariableList varchar(1000)
DECLARE @szVariable varchar(1000)
DECLARE @szAllowCents char(1) --1 character
DECLARE @szContactPerson varchar(40)
DECLARE @szContactPhone varchar(16)
DECLARE @szSuggestionCart varchar(1000)
DECLARE @szButton varchar(10)
DECLARE @szDelimiter varchar(5)
DECLARE @szFundName varchar(100) --may need more functions imported, this might be required
DECLARE @szBoldRequired varchar(10)
DECLARE @szSuggestion varchar(1000)
DECLARE @szFoundationText varchar(200)
DECLARE @szCantMakeGrantsLanguage varchar(100)
DECLARE @szDefaultIAgree varchar(10)
DECLARE @szShowIAgreeOnly varchar(10)
DECLARE @szCheckAdvisor varchar(40)
DECLARE @szGtID varchar(16)
DECLARE @szLineNumber varchar(100)
DECLARE @szDonorAnonymousYN char(1)
DECLARE @szFundHistoryHdr varchar(100)
DECLARE @szHeading varchar(100)
DECLARE @szAnonymousYN char(1) --1 character
DECLARE @szGrantRecommendation varchar(500)
DECLARE @szPurpose long varchar
DECLARE @szApprovalYN char(1)
DECLARE @szAdminType varchar(10)
DECLARE @szEntity varchar(10)
DECLARE @szGranteeName varchar(50)
DECLARE @szEIN varchar(16)
DECLARE @szAdvisorName varchar(40)
DECLARE @szColonAfterLabel char --1 char
DECLARE @szRequiredFieldIndicator varchar(20)
DECLARE @szUseImageHeadersYN char --1 char, might not be necessary
DECLARE @szSubmitButton varchar(10)
DECLARE @szContinueButton varchar(10)
DECLARE @szClearButton varchar(10)
DECLARE @szPrintNewWindowYN char --1 char, maybe not necessary
DECLARE @szDefaultPurpose varchar(100)
DECLARE @szAdvGtID varchar(20)
DECLARE @szShowMin varchar(100)
DECLARE @szCalendarHTML varchar(1000)
DECLARE @szGrantID varchar(10)/
DECLARE @szCountry varchar(40)
DECLARE @szJavascript varchar(100) --may not be necessary
DECLARE @szContactEmail varchar(250)
DECLARE @szDAFAmount varchar(10)
DECLARE @szDAFYN char(1)
DECLARE @lCount integer
DECLARE @lPos integer
DECLARE @lOrgCt integer
DECLARE @lIndex integer
DECLARE @lCounter integer
DECLARE @lSuggestionID integer
DECLARE @lPosIndex integer
DECLARE @lRecurFields integer
DECLARE @lRowCount integer
DECLARE @lDateFields integer
/* datastore ds
datastore ds2
datastore dFB */
DECLARE @dtSubmittedDate date
DECLARE @dMinimum decimal (15, 2)
DECLARE @dAmount numeric (12, 2)
DECLARE @dSubmittedamt decimal (15, 2) --Probably should actually have this in there somewhere, though apparently this was for calculating fund stuff re: javascript
DECLARE @dspendbalance decimal (15, 2) --Probably should have this one there too
/* DECLARE @bConfirmOnly
DECLARE @bPrintableOnly */

/* These puppies are part of the main problem - in the function we can use arrays, in the SP we can't. hence cursors and processing. */
/* DECLARE @szGotVariable[106] char */
CREATE TABLE #tt_got_variable (col_1 varchar(5000))
/* DECLARE @szVariableValue[106] char --1000 characters */
CREATE TABLE #tt_variable_value (col_1 varchar(5000), col_2 varchar(5000), col_3 varchar(5000), col_4 varchar(5000))
/* DECLARE @szVariableIndexed[106] char */
CREATE TABLE #tt_variable_indexed (col_1 varchar(5000), col_2 varchar(5000), col_3 varchar(5000), col_4 varchar(5000))
/* DECLARE @szHiddenValue[106] char */
CREATE TABLE #tt_hidden_value (col_1 varchar(5000))
/* DECLARE @szHiddenValueIndexed[106] char */
CREATE TABLE #tt_hidden_value_indexed (col_1 varchar(5000))
/* DECLARE @lVariableIndex[106] integer */
CREATE TABLE #tt_long_variable_index (col_1 integer)
/* DECLARE @szAdded[] char */
CREATE TABLE #tt_added (col_1 varchar(5000))

SET @szHtml = ''
SET @szAddress = ''
SET @szVariableList = ''
SET @szFoundationText = 'the foundation'
SET @szApprovalYN = 'N'
SET @szShowMin = 'Y'
SET @szCalendarHTML = ''
SET @szCalendarHTML = ''
SET @szJavascript = ''
SET @szDAFYN = 'N'
/* SET @bConfirmOnly = 'FALSE' --again, likely not necessary
SET @bPrintableOnly = 'FALSE' --again, likely not necessary */

//redacted

IF left(@p_szprojectid,4) = 'DAF|'
BEGIN
	SET @szDAFAmount = Right(@p_szprojectid, Len(@p_szprojectid) - SubStr(@p_szprojectid,'|'))
	SET @p_szprojectid = ''
	SET #tt_variable_indexed.col_4 = @szDAFAmount
	SEt @szDAFYN = 'Y'
END

SELECT sy_grant_form_bold_required_yn, sy_grant_form_suggestion_term, sy_cant_make_suggestions_language,
		 sy_default_iagree_on_signoffs_yn, sy_show_iagree_only_yn, COALESCE(sy_suppress_title_bar_yn,'N'),
		 sy_use_image_headers_yn, COALESCE(sy_print_new_window_yn,'N'), gt_dynamic_grant_form --MAY NOT BE NECESSARY TO SELECT gt_dynamic_grant_form INTO @szHtml
  INTO @szBoldRequired, @szSuggestion, @szCantMakeGrantsLanguage, @szDefaultIAgree, @szShowIAgreeOnly, 
       @szSuppressTitleBar, @szUseImageHeadersYN , @szPrintNewWindowYN , @szHtml
  FROM fd_entity
 WHERE fd_entity = @p_szEntity 
 
 SELECT fd_advisor.fd_administrator_type, fd_advisor_email, fd_advisor_name
  INTO @szAdminType, @szAdvisorEmail, @szAdvisorName
  FROM fd_advisor
 WHERE fd_advisor_userid = @p_szAdvisorID
 
IF @p_szEditSuggestionID <> '' AND @p_szEditSuggestionID != NULL
BEGIN 
	IF SubStr(UPPER(@p_szEditSuggestionID),'APPROVAL') > 0
	BEGIN
		SET @szApprovalYN = 'Y'
		SET @p_szEditSuggestionID = LEFT(@p_szEditSuggestionID,SubStr(@p_szEditSuggestionID,'APPROVAL') - 1) 
		IF @szAdminType <> 'S' 
			RETURN 'You must be a system administrator for this.'
		
		SELECT "gt_cart_hdr"."fd_entity"
		  INTO @szEntity
		  FROM "gt_cart_hdr"
		  WHERE "gt_suggestion_id" = CAST(@p_szEditSuggestionID as integer) 
		IF @szEntity <> @p_szEntity 
			RETURN 'Suggestion ID is not one of your foundation! Request denied'
	END
	ELSE
	BEGIN
		SELECT "gt_cart_hdr"."fd_advisor_id", "gt_submitted_date"
		  INTO @szCheckAdvisor, @dtSubmittedDate
		  FROM "gt_cart_hdr"
		  WHERE "gt_suggestion_id" = CAST(@p_szEditSuggestionID as integer)
		IF @szCheckAdvisor <> @p_szAdvisorID 
			RETURN 'You request could not be processed. Please try again later. GSF'
	END
END

SELECT fd_label_fd_fund_history_hdr
  INTO @szFundHistoryHdr
  FROM fd_labels_fundhistory
 WHERE fd_entity = @p_szEntity
 
IF @szFundHistoryHdr = Null OR TRIM(@szFundHistoryHdr) = ''
	SET @szFundHistoryHdr = 'Fund Summary'

IF @p_dFieldCoefficient = Null
	SET @p_dFieldCoefficient = 1

SELECT fd_suggestioncart_label, fd_html_before_form, fd_html_after_form, gt_grant_recommendation,
		fd_colon_after_label_yn, fd_required_field_indicator, fd_minimum_suggestion, fd_allow_cents_yn,
		sy_continue_button, sy_submit_button, sy_clear_button  --MAY BE ABLE TO DELETE fd_html_before/after_form AND VARIABLES
  INTO @szSuggestionCart, @szHTMLBeforeForm, @szHTMLAfterForm, @szGrantRecommendation, @szColonAfterLabel,
  		@szRequiredFieldIndicator, @dMinimum, @szAllowCents, @szContinueButton, @szSubmitButton, @szClearButton 
  FROM fd_entity_grant_settings
 WHERE fd_entity = @p_szEntity
IF @szSuggestionCart = Null OR TRIM(@szSuggestionCart) = '' 
	SET @szSuggestionCart = 'Suggestion Cart' 
IF @szColonAfterLabel = Null OR @szColonAfterLabel = 'Y' 
	SET @szColonAfterLabel = "@"
ELSE
	SET @szColonAfterLabel = ''
 
IF @szRequiredFieldIndicator = Null
	SET @szRequiredFieldIndicator = '*'

IF @szBoldrequired = Null OR @szBoldRequired = '' 
	SET @szBoldRequired = 'N'
IF @szSuggestion = Null OR @szSuggestion = '' 
	SET @szSuggestion = 'suggestion' 
IF @szCantMakeGrantsLanguage = Null OR @szCantMakeGrantsLanguage = '' 
	SET @szCantMakeGrantsLanguage = 'You are not set up to make grant suggestions to any funds at this time.  Please contact the foundation if you feel this is in error.'
IF @szDefaultIAgree = Null
	SET @szDefaultIAgree = 'N'
IF @szShowIAgreeOnly = Null
	SET @szShowIAgreeOnly = 'N'

/**********************CONFIRM AND PRINTABLE ARE BOOLEAN AND ALSO DON'T MATTER WITHOUT HTMLSTRING, I SUSPECT
IF UPPER(LEFT(@p_szError,7)) = 'CONFIRM' THEN
	SET @bConfirmOnly = TRUE

IF UPPER(LEFT(@p_szError,9)) = 'PRINTABLE' THEN
	SET @bPrintableOnly = TRUE */


IF @p_szEditSuggestionID <> '' AND @p_szEditSuggestionID != Null
BEGIN
	SELECT gt_cart_det.gt_variable_value 
	  INTO @p_szOrgID
	  FROM gt_cart_det
	 WHERE gt_cart_det.gt_line_number = 1
	   AND gt_cart_det.gt_suggestion_id = @p_szEditSuggestionID
	IF @p_szOrgID = '' OR @p_szOrgID = '0' 
		SET @p_szOrgName = 'MANUAL'
END

IF @p_szEditSuggestionID <> '' AND @p_szEditSuggestionID != Null AND (LEFT(@p_szError,SubStr(@p_szError,'|') - 1) = '' OR @p_szError = Null)
	SET @lSuggestionID = Cast(@p_szEditSuggestionID AS int)
	
	/********************DATASTORE PROBABLY MEANS WE NEED TO TEAR THIS PART OUT TOO (OR REPLACE WITH SIMILAR FUNCTIONALITY)********************
	ds2 = CREATE DATASTORE
	ds2.dataobject = 'd_gt_suggestion_info'
	ds2.SetTrans(itr)
	ds2.Retrieve(lSuggestionID) 
	FOR lIndex = 1 to ds2.RowCount()
		lVariableIndex[lIndex] = ds2.GetItemNumber(lIndex,"gt_line_number") 
		szVariableValue[lIndex] = ds2.GetItemString(lIndex,"gt_variable_value") 
		szVariableIndexed[lVariableIndex[lIndex]] = szVariableValue[lIndex]
	NEXT
	lCounter = ds2.RowCount()
	DESTROY ds2 */

ELSE	
	IF @p_szError <> '' AND @p_szError != Null -- Error in the form 
	BEGIN
		SET @szErrorMessage = LEFT(@p_szError,SubStr(@p_szError,'|') - 1)
			
		SET @szFormCopy = RIGHT(@p_szError,LEN(@p_szError) - SubStr(@p_szError,'|'))
		IF SubStr(@szFormCopy,'|') > 0  
			SET @szDelimiter = '|'
		ELSE
			SET @szDelimiter = '&' 
		
		/* Parse out variables */ 
		
		SET @lCounter = 0
		IF RIGHT(@szFormCopy,1) <> '|' 
			SET @szFormCopy = @szFormCopy + '|' 
		WHILE SubStr(@szFormCopy,@szDelimiter) > 0
			SET @szVariable = LEFT(@szFormCopy,SubStr(@szFormCopy,@szDelimiter) - 1)
			SET @szFormCopy = RIGHT(@szFormCopy,LEN(@szFormCopy) - SubStr(@szFormCopy,@szDelimiter))
			IF LEFT(@szVariable,3) = 'VAR' 
			BEGIN
				SET @lCounter ++ 
				SET @szGotVariable[@lCounter] = @szVariable 
				SET @lVariableIndex[@lCounter] = Cast(MID(@szVariable,4,  SubStr(@szVariable,"=") - 4 ) AS int)
				SET @szVariableValue[@lCounter] = RIGHT(@szVariable,LEN(@szVariable) - SubStr(@szVariable,"="))
				SET @lPosIndex = 1 
				-- Get Rid of Possible Tags 
				WHILE SubStr(@szVariableValue[@lCounter],'<',@lPosIndex) > 0
					IF SubStr(@szVariableValue[@lCounter],'>',@lPosIndex + 1) > 0 
						SET @szVariableValue[@lCounter] = LEFT(@szVariableValue[@lCounter],&
																		SubStr(@szVariableValue[@lCounter],'<',@lPosIndex) - 1) + &
															 RIGHT(@szVariableValue[@lCounter],LEN(@szVariableValue[@lCounter]) - &
																		SubStr(@szVariableValue[@lCounter],'>',@lPosIndex + 1))
					ELSE
						EXIT
				LOOP 
			END
				
				/* End Removal of Tags */ 
				SET @szHiddenValue[@lcounter] = @szVariableValue[@lcounter]
				WHILE SubStr(@szHiddenValue[@lcounter],'"') > 0
					SET @szHiddenValue[@lcounter] = LEFT(@szHiddenValue[@lcounter],SubStr(@szHiddenValue[@lcounter],'"') - 1) + '&quot;' + &
										RIGHT(@szHiddenValue[@lcounter],LEN(@szHiddenValue[@lcounter]) - SubStr(@szHiddenValue[@lcounter],'"'))
				LOOP
				SET @szVariableIndexed[@lVariableIndex[@lcounter]] = @szVariableValue[@lcounter]
				SET @szHiddenValueIndexed[@lVariableIndex[@lcounter]] = @szHiddenValue[@lcounter]
				IF @lVariableIndex[@lcounter] = 1 
					SET @p_szOrgID = @szVariableValue[@lcounter] -- Set Org ID
				SET @szVariableList = @szVariableList + @szGotVariable[@lcounter] + '@' + String(@lVariableIndex[@lcounter]) + &
								'@' + @szVariableValue[@lcounter] + '<br>'
		LOOP
	END

/*******************Not certain "upperbound()" is a function in SQL Anywhere*******************
IF IsNull(@p_szProjectID) OR @p_szProjectID = '' -- For confirm, edit screens
	IF Upperbound(@szVariableIndexed) >= 99
		IF @szVariableIndexed[99] <> '' AND NOT IsNull(@szVariableIndexed[99]) 
			SET @p_szProjectID = @szVariableIndexed[99]
		END IF
	END IF
	If IsNull(@p_szProjectID) 
		SET @p_szProjectID = '' 
END IF */

IF (@szVariableIndexed[13] = '' OR @szVariableIndexed[13] = Null)) -- Fund Anonymous has no value yet. Default?
BEGIN	
	SELECT COUNT(*) 
		INTO @lCount 
		FROM "fd_advisor_fund" 
		WHERE "fd_advisor_userid" = @p_szAdvisorID
	IF @lCount = 1 
	BEGIN	
		SELECT fd_master.fd_anonymous_yn 
		  INTO @szAnonymousYN 
		  FROM fd_master, fd_advisor_fund 
		  WHERE fd_master.fd_id = fd_advisor_fund.fd_id 
		  ANd fd_master.fd_entity = fd_advisor_fund.fd_entity 
		  AND fd_advisor_fund.fd_advisor_userid = @p_szAdvisorID 
		 IF Upper(@szAnonymousYN) = 'N' OR @szAnonymousYN = Null OR Trim(@szAnonymousYN) = '' 
			SET @szVariableIndexed[13] = 'NO'
		ELSE
			SET @szVariableIndexed[13] = 'YES'
	END 
END

IF (@szVariableIndexed[14] = '' OR @szVariableIndexed[14] = Null)) -- Donor Anonymous has no value yet. Default?
BEGIN	
	SELECT COUNT(*) 
	INTO @lCount 
	FROM "fd_advisor_fund" 
	WHERE "fd_advisor_userid" = @p_szAdvisorID 
	IF @lCount = 1 
	BEGIN	
		SELECT fd_master.fd_donor_anon_yn
		  INTO @szDonorAnonymousYN
		  FROM fd_master, fd_advisor_fund
		  WHERE fd_master.fd_id = fd_advisor_fund.fd_id
		  AND fd_master.fd_entity = fd_advisor_fund.fd_entity
		  AND fd_advisor_fund.fd_advisor_userid = @p_szAdvisorID 
		IF Upper(@szDonorAnonymousYN) = 'N' OR @szDonorAnonymousYN = Null OR Trim(@szDonorAnonymousYN) = '' 
			SET @szVariableIndexed[14] = 'NO'
		ELSE
			SET @szVariableIndexed[14] = 'YES'
	END 
END

IF (@szVariableIndexed[21] = '' OR @szVariableIndexed[21] = Null)) AND &
	((@p_szOrgID = 'MANUAL' AND @p_szOrgName = 'MANUAL') OR @p_szEntity = '0176') -- Email Field Blank - Fill in with default.
BEGIN
	/* Parse out any multiple e-mails */
	DO WHILE SubStr(@szAdvisorEmail,';') > 0 
		SET @szAdvisorEmail = TRIM(LEFT(@szAdvisorEmail, SubStr(@szAdvisorEmail,';') - 1))
	LOOP
	WHILE SubStr(@szAdvisorEmail,',') > 0 
		SET @szAdvisorEmail = TRIM(LEFT(@szAdvisorEmail, SubStr(@szAdvisorEmail,',') - 1))
	LOOP
	SET @szVariableIndexed[21] = @szAdvisorEmail
END 

IF (@szVariableIndexed[4] = '' OR @szVariableIndexed[4] = Null)) AND @p_szRecentGrant <> '' AND @p_szRecentGrant != Null)
BEGIN 
	SET @szGtID = LEFT(@p_szRecentGrant,SubStr(@p_szRecentGrant,'|') - 1)
	SET @szLineNumber = RIGHT(@p_szRecentGrant,LEN(@p_szRecentGrant) - SubStr(@p_szRecentGrant,'|'))
	SELECT gt_pay_amt, gt_purpose, gt_grantee_name 
	  INTO @dAmount, @szPurpose, @szGranteeName 
	  FROM gt_payments
	  WHERE gt_payments.gt_id = @szGtId
	    AND gt_payments.gt_payline = @szLineNumber
		AND gt_payments.fd_entity = @p_szEntity 
	IF @dAmount > 0 AND @dAmount != Null) 
	BEGIN
		IF @p_szEntity <> '1435' AND @p_szEntity <> '1255' AND @p_szEntity <> '0071' 
			SET @szVariableIndexed[4] = String(@dAmount,'$#,###')
		ELSE
			SET @szVariableIndexed[4] = ''
	END		
	IF @szPurpose <> '' AND NOT IsNull(@szPurpose) 
	BEGIN	
		IF @p_szEntity <> '1435' 
			SET @szVariableIndexed[15] = @szPurpose
		ELSE
			SET @szVariableIndexed[15] = ''
	END 
END

IF (@szVariableIndexed[24] = '' OR IsNull(@szVariableIndexed[24])) -- Advisor name field Blank - Fill in with default. AND &
	SET @szVariableIndexed[24] = @szAdvisorName

//redacted

IF @p_szOrgID = '0' OR TRIM(@p_szOrgID) = '' OR IsNull(@p_szOrgId) OR @p_szOrgID = 'MANUAL' 
BEGIN	
	IF @p_szOrgID <> 'MANUAL' OR IsNull(@p_szOrgID)
		SET @p_szOrgID = '0'
		SET @szNewForm = 'Y'
	ELSE
		SET @szNewForm = 'N'
END
 
IF @p_szEntity = '0071' 
	SET @szButton = 'Continue'
ELSE
	IF @p_szEntity = 'B097'  
	SET @szButton = 'Add to Recommendation List' 
	ELSE
		IF UPPER(RIGHT(@szSuggestionCart,4)) = 'LIST'  
			SET @szButton = 'Add to ' + UPPER(LEFT(@szSuggestion,1)) + RIGHT(@szSuggestion, LEN(@szSuggestion) - 1) + ' List'
		ELSE
			SET @szButton = 'Add to ' + UPPER(LEFT(@szSuggestion,1)) + RIGHT(@szSuggestion, LEN(@szSuggestion) - 1) + ' Cart'

//redacted

/*******************MORE DATASTORE STUFF, REMOVE AS IT PROBABLY WON'T WORK IN A STORED PROCEDURE******************
ds = CREATE datastore
ds.dataobject = 'd_gt_grant_form_lines'
ds.SetTrans(itr)
lRowCount = ds.Retrieve(p_szEntity, szNewForm, p_dFieldCoefficient) 

IF szApprovalYN = 'Y' THEN 
	FOR lIndex = 1 to ds.RowCount() 
		ds.object.gt_required_yn[lIndex] = ds.object.gt_approval_required_yn[lIndex]
	NEXT
END IF */

/* Make sure we have the org name */
IF TRIM(@p_szOrgName) = '' OR IsNull(@p_szOrgName) 
	SELECT ct_org_name
	  INTO @p_szOrgName
	  FROM ct_org_master
	 WHERE fd_entity = @p_szEntity
	 AND ct_id = @p_szOrgID
ELSE
	WHILE SubStr(@p_szOrgName,'+') > 0
		SET @p_szOrgName = LEFT(@p_szOrgName,SubStr(@p_szOrgName,'+') - 1) + ' ' + RIGHT(@p_szOrgName,LEN(@p_szOrgName) - SubStr(@p_szOrgName,'+'))
	LOOP


/* Default Contact Person and Phone if available */
IF @p_szOrgID <> '' AND NOT IsNull(@p_szOrgId)  
BEGIN
	SELECT ct_contact_person, ct_contact_phone, ct_org_addr1, ct_org_addr2,ct_org_addr3, ct_org_city, 
			 ct_org_state, ct_org_zip, ct_org_title, ct_ein, ct_country, ct_contact_email
	  INTO @szContactPerson, @szContactPhone, @szAddr1, @szAddr2, @szAddr3, @szCity, @szState, @szZip , @szTitle, @szEIN, @szCountry, @szContactEmail
	  FROM ct_org_master
	  WHERE fd_entity = @p_szEntity
	  AND ct_id = @p_szOrgID
	/* check for grant address data */
	SELECT COUNT(@ct_id)
	 	INTO @lOrgCt
	 	FROM ct_org_address
	    WHERE fd_entity = @p_szEntity
	    AND ct_id = @p_szOrgID
		AND gt_id = @szGtId
	IF @lOrgCt > 0 
		SELECT ct_org_contact_name, ct_contact_phone, ct_org_addr1, ct_org_addr2,ct_org_addr3, ct_org_city, ct_org_state, ct_org_zip, ct_contact_email 
			INTO @szContactPerson, @szContactPhone, @szAddr1, @szAddr2, @szAddr3, @szCity, @szState, @szZip, @szContactEmail
			FROM ct_org_address
			WHERE fd_entity = @p_szEntity
			AND gt_id = @szGtId
			AND ct_id = @p_szOrgID
END
	
IF (@szVariableIndexed[10] = '' OR IsNull(@szVariableIndexed[10])) AND &
		@szContactPerson <> '' AND NOT IsNull(@szContactPerson)
			SET @szVariableIndexed[10] = @szContactPerson
IF (@szVariableIndexed[12] = '' OR IsNull(@szVariableIndexed[12])) AND &
		@szContactPhone <> '' AND NOT IsNull(@szContactPhone) 
			SET @szVariableIndexed[12] = @szContactPhone  
IF @p_szEntity = '1435'
BEGIN		
	IF (@szVariableIndexed[28] = '' OR IsNull(@szVariableIndexed[28])) AND &
		@szContactEmail <> '' AND NOT IsNull(@szContactEmail) 
			SET @szVariableIndexed[28] = @szContactEmail
END 
	IF (@szVariableIndexed[5] = '' OR IsNull(@szVariableIndexed[5])) AND &
		@szAddr1 <> '' AND NOT IsNull(@szAddr1) 
			SET @szVariableIndexed[5] = @szAddr1
	IF (@szVariableIndexed[6] = '' OR IsNull(@szVariableIndexed[6])) AND &
		@szAddr2 <> '' AND NOT IsNull(@szAddr2) 
			SET @szVariableIndexed[6] = @szAddr2
	IF (@szVariableIndexed[105] = '' OR IsNull(@szVariableIndexed[105])) AND &
		@szAddr3 <> '' AND NOT IsNull(@szAddr3) 
			SET @szVariableIndexed[105] = @szAddr3
	IF (@szVariableIndexed[7] = '' OR IsNull(@szVariableIndexed[7])) AND &
		@szCity <> '' AND NOT IsNull(@szCity) 
			SET @szVariableIndexed[7] = @szCity
	IF (@szVariableIndexed[8] = '' OR IsNull(@szVariableIndexed[8])) AND &
		@szState <> '' AND NOT IsNull(@szState)
			SET @szVariableIndexed[8] = @szState
	IF (@szVariableIndexed[54] = '' OR IsNull(@szVariableIndexed[54])) AND &
		@szState <> '' AND NOT IsNull(@szState) 
			SET @szVariableIndexed[54] = @szState
	IF (@szVariableIndexed[9] = '' OR IsNull(@szVariableIndexed[9])) AND &
		@szZip <> '' AND NOT IsNull(@szZip) 
			SET @szVariableIndexed[9] = @szZip
	IF (@szVariableIndexed[11] = '' OR IsNull(@szVariableIndexed[11])) AND &
		@szTitle <> '' AND NOT IsNull(@SzTitle) 
			SET @szVariableIndexed[11] = @szTitle 
	IF (@szVariableIndexed[62] = '' OR IsNull(@szVariableIndexed[62])) AND @szCountry <> '' AND NOT IsNull(@szCountry) AND @p_szEntity = '1435'
		SET @szVariableIndexed[62] = @szCountry
	IF @szCountry = 'UNITED STATES OF AMERICA' 
		SET @szVariableIndexed[23] = 'Check'
		ELSE
			SET @szVariableIndexed[23] = 'Wire - International'
		END IF
	END IF
END IF

/* Get the Project name if applicable */
IF @p_szProjectID <> '' 
BEGIN
	IF Left(@p_szProjectID,5) = 'GTADV' 
	BEGIN
		IF Len(@p_szProjectID) > 5 
			SET @szGrantID = Right(@p_szProjectID, Len(@p_szProjectID) - 5)
			SELECT IsNull(@gt_project_desc,'Grant Advice'), gt_id 
			INTO @szDefaultPurpose, @szAdvGtID
			FROM gt_advice
			WHERE gt_id = @szGrantID
		ELSE
			SELECT IsNull(@gt_project_desc,'Grant Advice'), gt_id 
			INTO @szDefaultPurpose, @szAdvGtID
			FROM gt_advice
			WHERE ct_id = @p_szOrgID
	END
		SET @szVariableIndexed[15] = @szDefaultPurpose
		SET @szVariableIndexed[99] = 'Grant Advice ' --+ @p_szOrgName
		SET @szVariableIndexed[106] = @szAdvGtID
	ELSE
		SELECT ax_synergy_title, ax_synergy_default_purpose 
		  INTO @szProjectName, @szDefaultPurpose 
		  FROM ax_synergy
		  WHERE fd_entity = @p_szEntity
		  AND ax_synergy_code = @p_szProjectID
		IF itr.sqlcode < 0 
			RETURN itr.sqlerrtext 
		IF @szVariableIndexed[15] = '' OR IsNull(@szVariableIndexed[15]) 
			SET @szVariableIndexed[15] = @szDefaultPurpose
		END IF 
	END IF
END IF

IF NOT IsNull(@p_szeditsuggestionid) AND @p_szeditsuggestionid <> '' 
BEGIN
	SELECT gt_variable_value
	  INTO @szAdvGtID
	  FROM gt_cart_det 
	 WHERE gt_suggestion_id = @p_szeditsuggestionid 
	   AND gt_line_number = 106
	SET @szVariableIndexed[106] = @szAdvGtID
END

IF (@szVariableIndexed[27] = '' OR IsNull(@szVariableIndexed[27])) 
BEGIN
	IF @p_szEntity = '2333'  
		SET @szVariableIndexed[27] = String(Date(today()),'mm/dd/yyyy')
END

IF (@szVariableIndexed[29] = '' OR IsNull(@szVariableIndexed[29])) 
		SET @szVariableIndexed[29] = szEIN

/* get count of recurring grant fields */
SELECT count(*)
  INTO @lRecurFields
  FROM gt_form_lines_setup
 WHERE fd_entity = @p_szEntity
   AND gt_new_grantee_yn = @szNewForm
   AND gt_show_yn = 'Y'
   AND gt_line_number IN (85,86,87)

/* determine if grant form has payment date field (27) */
SELECT count(*) INTO @lDateFields
  FROM gt_form_lines_setup
 WHERE fd_entity = @p_szEntity
   AND gt_show_yn = 'Y'
   AND gt_new_grantee_yn = @szNewForm
   AND gt_line_number IN (27)

END