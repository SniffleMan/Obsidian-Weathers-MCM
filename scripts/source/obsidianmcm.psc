ScriptName ObsidianMCM Extends SKI_ConfigBase


ImagespaceModifier Property ObsidianNatural Auto
ImagespaceModifier Property ObsidianFantasy Auto
ImagespaceModifier Property ObsidianBleakPreset Auto
ImagespaceModifier Property ObsidianCold Auto
ImagespaceModifier Property ObsidianSunlightFix Auto
GlobalVariable Property ObsidianSeasonsFXGlobal Auto  ; Int
GlobalVariable Property ObsidianSunlightFixGlobal Auto  ; Int
ObsidianSeasons Property OSeasons Auto



String[] _menuEntries
Int _menuEntriesIdx = 0


; Called when the config menu is initialized.
Event OnConfigInit()
	ModName = "$Obsidian_ModName"
	pages = New String[1]
	pages[0] = "$Obsidian_pages0"

	_menuEntries = New String[5]
	_menuEntries[0] = "$Obsidian_Filter_Default"
	_menuEntries[1] = "$Obsidian_Filter_Natural"
	_menuEntries[2] = "$Obsidian_Filter_Fantasy"
	_menuEntries[3] = "$Obsidian_Filter_BleakPreset"
	_menuEntries[4] = "$Obsidian_Filter_Cold"
EndEvent


; Called when the config menu is closed.
Event OnConfigClose()
EndEvent


; Called when a version update of this script has been detected.
; a_version - The new version.
Event OnVersionUpdate(Int a_version)
EndEvent


; Called when a new page is selected, including the initial empty page.
; a_page - The name of the the current page, or "" if no page is selected.
Event OnPageReset(String a_page)
	If (a_page == "$Obsidian_pages0")
		SetCursorFillMode(LEFT_TO_RIGHT)
		
		AddMenuOptionST("Obsidian_Filters_M", "$Obsidian_MenuOption_Filters", GetActiveFilter())
		AddTextOptionST("Obsidian_Save_T", "$SAVE", "")
		AddToggleOptionST("Obsidian_SeasonsFX_B", "$Obsidian_ToggleOption_SeasonsFX", ObsidianSeasonsFXGlobal.GetValue() As Bool)
		AddTextOptionST("Obsidian_Load_T", "$LOAD", "")
		AddToggleOptionST("Obsidian_SunlightFix_B", "$Obsidian_ToggleOption_SunlightFix", ObsidianSunlightFixGlobal.GetValue() As Bool)
	EndIf
EndEvent


State Obsidian_Filters_M
	Event OnMenuOpenST()
		SetMenuDialogStartIndex(_menuEntriesIdx)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(_menuEntries)
	EndEvent

	Event OnMenuAcceptST(Int a_index)
		Clean()
		_menuEntriesIdx = a_index
		If (_menuEntriesIdx == 1)
			ObsidianNatural.Apply(1.0)
		ElseIf (_menuEntriesIdx == 2)
			ObsidianFantasy.Apply(1.0)
		ElseIf (_menuEntriesIdx == 3)
			ObsidianBleakPreset.Apply(1.0)
		ElseIf (_menuEntriesIdx == 4)
			ObsidianCold.Apply(1.0)
		EndIf
		SetMenuOptionValueST(_menuEntries[_menuEntriesIdx])
	EndEvent

	Event OnDefaultST()
		Clean()
		_menuEntriesIdx = 0
		SetMenuOptionValueST(_menuEntries[_menuEntriesIdx])
	EndEvent

	Event OnHighlightST()
		SetInfoText("$Obsidian_InfoText_Filters")
	EndEvent
EndState


State Obsidian_Save_T
	Event OnSelectST()
		BeginSavePreset()
	EndEvent

	Event OnDefaultST()
	EndEvent

	Event OnHighlightST()
		SetInfoText("$Obsidian_InfoText_Save")
	EndEvent
EndState


State Obsidian_SeasonsFX_B
	Event OnSelectST()
		ToggleBool(ObsidianSeasonsFXGlobal)
		OSeasons.SeasonsFX = ObsidianSeasonsFXGlobal.GetValue() As Bool
		OSeasons.Season(True)
		SetToggleOptionValueST(ObsidianSeasonsFXGlobal.GetValue() As Bool)
	EndEvent

	Event OnDefaultST()
		ObsidianSeasonsFXGlobal.SetValue(0)
		OSeasons.SeasonsFX = False
		OSeasons.Season(True)
		SetToggleOptionValueST(ObsidianSeasonsFXGlobal.GetValue() As Bool)
	EndEvent

	Event OnHighlightST()
		SetInfoText("$Obsidian_InfoText_SeasonsFX")
	EndEvent
EndState


State Obsidian_Load_T
	Event OnSelectST()
		BeginLoadPreset()
	EndEvent

	Event OnDefaultST()
	EndEvent

	Event OnHighlightST()
		SetInfoText("$Obsidian_InfoText_Load")
	EndEvent
EndState


State Obsidian_SunlightFix_B
	Event OnSelectST()
		ToggleBool(ObsidianSunlightFixGlobal)
		If (ObsidianSunlightFixGlobal.GetValue() As Bool)
			ObsidianSunlightFix.Apply()
		Else
			ObsidianSunlightFix.Remove()
		EndIf
		SetToggleOptionValueST(ObsidianSunlightFixGlobal.GetValue() As Bool)
	EndEvent

	Event OnDefaultST()
		ObsidianSunlightFixGlobal.SetValue(0)
		ObsidianSunlightFix.Remove()
		SetToggleOptionValueST(ObsidianSunlightFixGlobal.GetValue() As Bool)
	EndEvent

	Event OnHighlightST()
		SetInfoText("$Obsidian_InfoText_SunlightFix")
	EndEvent
EndState


; Returns the static version of this script.
; RETURN - The static version of this script.
; History:
; 1 - Initial Release (v1.0.0)
Int Function GetVersion()
	Return 1
EndFunction


; Returns the active global filter
; RETURN - The active global filter
String Function GetActiveFilter()
	If (_menuEntriesIdx >= 0 && _menuEntriesIdx < 5)
		Return _menuEntries[_menuEntriesIdx]
	Else
		Return "$Obsidian_Filter_Error"
	EndIf
EndFunction


; Toggles a global variable acting as a boolean
; a_globalVar - The global variable to toggle
Function ToggleBool(GlobalVariable a_globalVar)
	If (a_globalVar.GetValue() As Bool)
		a_globalVar.SetValue(0)
	Else
		a_globalVar.SetValue(1)
	EndIf
EndFunction


; Removes all applied imagespace modifiers
Function Clean()
	ObsidianNatural.Remove()
	ObsidianFantasy.Remove()
	ObsidianBleakPreset.Remove()
	ObsidianCold.Remove()
EndFunction


; Saves the current preset using FISS
Function BeginSavePreset()
	If (!ShowMessage("$Obsidian_Save_AreYouSure") || !ShowMessage("$Obsidian_PleaseWait"))
		Return
	EndIf

	FISSInterface fiss = FISSFactory.getFISS()
	If (!fiss)
		ShowMessage("$Obsidian_FISSNotFound", False, "$OK")
		Return
	EndIf

	fiss.beginSave("ObsidianWeathersMCM.xml", "Obsidian Weathers MCM")

	fiss.saveInt("Obsidian_Filters_M", _menuEntriesIdx)
	fiss.saveBool("Obsidian_SeasonsFX_B", ObsidianSeasonsFXGlobal.GetValue() As Bool)
	fiss.saveBool("Obsidian_SunlightFix_B", ObsidianSunlightFixGlobal.GetValue() As Bool)

	String saveResult = fiss.endSave()

	If (saveResult != "")
		ShowMessage("$Obsidian_Save_Failure", False, "$OK")
	Else
		ShowMessage("$Obsidian_Save_Success", False, "$OK")
	EndIf
EndFunction


; Loads the saved preset using FISS
Function BeginLoadPreset()
	If (!ShowMessage("$Obsidian_Load_AreYouSure") || !ShowMessage("$Obsidian_PleaseWait"))
		Return
	EndIf

	FISSInterface fiss = FISSFactory.getFISS()
	If (!fiss)
		ShowMessage("$Obsidian_FISSNotFound", False, "$OK")
		Return
	EndIf

	fiss.beginLoad("ObsidianWeathersMCM.xml")

	String prevState = GetState()
	Bool b

	GotoState("Obsidian_Filters_M")
	OnMenuAcceptST(fiss.loadInt("Obsidian_Filters_M"))

	GotoState("Obsidian_SeasonsFX_B")
	b = fiss.loadBool("Obsidian_SeasonsFX_B")
	b = !b
	OnSelectST()

	GotoState("Obsidian_SunlightFix_B")
	b = fiss.loadBool("Obsidian_SunlightFix_B")
	b = !b
	OnSelectST()

	GotoState(prevState)

	String loadResult = fiss.endLoad()

	If (loadResult != "")
		ShowMessage("$Obsidian_Load_Failure", False, "$OK")
	Else
		ShowMessage("$Obsidian_Load_Success", False, "$OK")
	EndIf
EndFunction