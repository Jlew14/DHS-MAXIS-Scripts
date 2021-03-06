'Required for statistical purposes==========================================================================================
name_of_script = "NOTES - DRUG FELON.vbs"
start_time = timer
STATS_counter = 1               'sets the stats counter at one
STATS_manualtime = 90           'manual run time in seconds
STATS_denomination = "C"        'C is for each case
'END OF stats block=========================================================================================================

'LOADING FUNCTIONS LIBRARY FROM GITHUB REPOSITORY===========================================================================
IF IsEmpty(FuncLib_URL) = TRUE THEN	'Shouldn't load FuncLib if it already loaded once
	IF run_locally = FALSE or run_locally = "" THEN	   'If the scripts are set to run locally, it skips this and uses an FSO below.
		IF use_master_branch = TRUE THEN			   'If the default_directory is C:\DHS-MAXIS-Scripts\Script Files, you're probably a scriptwriter and should use the master branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/master/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		Else											'Everyone else should use the release branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/RELEASE/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		End if
		SET req = CreateObject("Msxml2.XMLHttp.6.0")				'Creates an object to get a FuncLib_URL
		req.open "GET", FuncLib_URL, FALSE							'Attempts to open the FuncLib_URL
		req.send													'Sends request
		IF req.Status = 200 THEN									'200 means great success
			Set fso = CreateObject("Scripting.FileSystemObject")	'Creates an FSO
			Execute req.responseText								'Executes the script code
		ELSE														'Error message
			critical_error_msgbox = MsgBox ("Something has gone wrong. The Functions Library code stored on GitHub was not able to be reached." & vbNewLine & vbNewLine &_
                                            "FuncLib URL: " & FuncLib_URL & vbNewLine & vbNewLine &_
                                            "The script has stopped. Please check your Internet connection. Consult a scripts administrator with any questions.", _
                                            vbOKonly + vbCritical, "BlueZone Scripts Critical Error")
            StopScript
		END IF
	ELSE
		FuncLib_URL = "C:\BZS-FuncLib\MASTER FUNCTIONS LIBRARY.vbs"
		Set run_another_script_fso = CreateObject("Scripting.FileSystemObject")
		Set fso_command = run_another_script_fso.OpenTextFile(FuncLib_URL)
		text_from_the_other_script = fso_command.ReadAll
		fso_command.Close
		Execute text_from_the_other_script
	END IF
END IF
'END FUNCTIONS LIBRARY BLOCK================================================================================================

'DIALOGS-------------------------------------------------------------------------------------------------------------------------------
BeginDialog drug_felon_dialog, 0, 0, 246, 235, "Drug Felon"
  EditBox 60, 5, 75, 15, MAXIS_case_number
  EditBox 65, 25, 60, 15, conviction_date
  EditBox 65, 45, 135, 15, probation_officer
  CheckBox 10, 65, 145, 10, "Check here if the authorization is on file:", authorization_on_file_check
  CheckBox 10, 80, 130, 10, "Check here if client complied with UA:", complied_with_UA_check
  EditBox 40, 95, 80, 15, UA_date
  DropListBox 50, 115, 65, 15, "select one..."+chr(9)+"Positive"+chr(9)+"Negative"+chr(9)+"Refused", UA_results
  EditBox 75, 135, 55, 15, date_of_1st_offense
  EditBox 75, 155, 70, 15, date_of_2nd_offense
  EditBox 60, 175, 180, 15, actions_taken
  EditBox 80, 195, 70, 15, worker_signature
  ButtonGroup ButtonPressed
    OkButton 135, 215, 50, 15
    CancelButton 190, 215, 50, 15
  Text 5, 160, 70, 10, "Date of 2nd Offense:"
  Text 5, 30, 55, 10, "Conviction Date:"
  Text 5, 180, 50, 10, "Actions Taken:"
  Text 5, 120, 40, 10, "UA Results:"
  Text 5, 200, 70, 15, "Sign your Case Note:"
  Text 5, 140, 65, 10, "Date of 1st Offense:"
  Text 5, 50, 60, 10, "Probation Officer:"
  Text 5, 100, 30, 10, "UA Date:"
  Text 5, 10, 50, 10, "Case Number:"
EndDialog

'THE SCRIPT----------------------------------------------------------------------------------------------------------------------------
'Connects to BlueZone & grabbing case number
EMConnect "" 
CALL MAXIS_case_number_finder(MAXIS_case_number)

'Show dialog
DO
	DO
		DO
			Dialog drug_felon_dialog
			IF Buttonpressed = 0 THEN StopScript
			IF worker_signature = "" THEN MsgBox "You must sign your case note"
		LOOP UNTIL worker_signature <> ""
		IF IsNumeric(MAXIS_case_number)= FALSE THEN MsgBox "You must type a valid numeric case number."
	LOOP UNTIL IsNumeric(MAXIS_case_number) = TRUE
	If UA_results = "select one..." THEN MsgBox "You must select 'UA results field'"
LOOP UNTIL UA_results <> "select one..."

'Checks MAXIS for password prompt
Call check_for_MAXIS(FALSE)

'Writes the case note
start_a_blank_CASE_NOTE
CALL write_variable_in_case_note("***Drug Felon***")
CALL write_bullet_and_variable_in_case_note("Conviction date", conviction_date)
CALL write_bullet_and_variable_in_case_note("Probation Officer", po_officer)
IF authorization_on_file_check = checked THEN CALL write_variable_in_case_note("* Authorization on file.")
IF complied_with_UA_check = checked THEN CALL write_variable_in_case_note("* Complied with UA.")
CALL write_bullet_and_variable_in_case_note("UA Date", UA_date)
CALL write_bullet_and_variable_in_case_note("Date of 1st offence", date_of_1st_offense)
CALL write_bullet_and_variable_in_case_note("Date of 2nd offence", date_of_2nd_offense)
IF UA_results <> "select one..." THEN CALL write_bullet_and_variable_in_case_note("UA results", UA_results)
CALL write_bullet_and_variable_in_case_note("Actions taken", actions_taken)
CALL write_variable_in_case_note("---")
CALL write_variable_in_case_note(worker_signature)

script_end_procedure("")
