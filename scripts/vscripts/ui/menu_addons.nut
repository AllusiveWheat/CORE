const MAP_LIST_VISIBLE_ROWS = 17
const MAP_LIST_SCROLL_SPEED = 0
function main()
{
	Globalize( InitAddonsMenu )
	Globalize( UpdateAddonPaths )
	Globalize( ResetUIScript )
}



function InitAddonsMenu( menu )
{
	file.menu <- menu
	file.mapListScrollState <- 0
	file.numMapButtonsOffScreen <- null
	uiGlobal.menu <- menu	
	file.menu.GetChild("MapButtonsPanel").SetVisible( true )
	AddEventHandlerToButtonClass( menu, "MapListScrollUpClass", UIE_CLICK, Bind( OnMapListScrollUp_Activate ) )
	AddEventHandlerToButtonClass( menu, "MapListScrollDownClass", UIE_CLICK, Bind( OnMapListScrollDown_Activate ) )
	file.buttons <- GetElementsByClassname( menu, "MapButtonClass" )
	local var = GetModPath()
	uiGlobal.addons <- {}
	uiGlobal.addons = var
	foreach(i,button in file.buttons) {
		button.SetVisible( false )
	}
	foreach(i,table in var) {
		file.buttons[i].SetText( table["name"] )
		file.buttons[i].SetVisible( true )
		// file.buttons[i].SetScriptID( i )
		file.buttons[i].SetSelected(table["enabled"])
		file.buttons[i].AddEventHandler( UIE_CLICK, OnAddonsMenu )
		file.buttons[i].AddEventHandler( UIE_GET_FOCUS, ChangePreviewUI )
		file.menu.GetChild("NextMapImage").SetImage( table["image"] )
	}
	
	// file.menu.GetChild("NextMapImage").SetImage( "../ui/menu/lobby/lobby_image_mp_wargames" )
	file.menu.GetChild("NextMapImage").SetVisible( true )
	file.numMapButtonsOffScreen = 32 - MAP_LIST_VISIBLE_ROWS
	RegisterButtonPressedCallback( MOUSE_WHEEL_UP, OnMapListScrollUp_Activate )
	RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, OnMapListScrollDown_Activate )
}	

function ScrollDown( button )
{
	local scrollPanel = button.GetParent().GetChild("MapButtonsPanel")
	scrollPanel.ScrollDown( 1 )
}

function ChangePreviewUI( button )
{

	local script_id = button.GetScriptID().tointeger()
	local table = uiGlobal.addons[script_id]
	local name = table["name"]
	local desc = table["description"]
	local author = table["author"]
	uiGlobal.menu.GetChild("NextMapImage").SetImage( table["image"] )
	uiGlobal.menu.GetChild("NextMapName").SetVisible( true)
	uiGlobal.menu.GetChild("NextMapName").SetText( name)

	uiGlobal.menu.GetChild("NextMapDesc").SetVisible( true )
	uiGlobal.menu.GetChild("NextMapDesc").SetText( desc )

	uiGlobal.menu.GetChild("StarsLabel").SetText(author)
}

function OnAddonsMenu( button )
{
	local script_id = button.GetScriptID().tointeger()
	print("script_id: " + script_id)
	if ( button.IsSelected() )
	{
		button.SetSelected( false )
		UpdateAddons(script_id,false)
	}
	else
	{
		button.SetSelected( true )
		UpdateAddons(script_id ,true)
	}
	ClientCommand( "update_addon_paths" )
}

function UpdateAddonPaths( button )
{
    ClientCommand( "update_addon_paths" )
}

function ResetUIScript( button )
{
	ClientCommand( "uiscript_reset" )
}


function OnMapListScrollUp_Activate(...)
{
	file.mapListScrollState--
	if ( file.mapListScrollState < 0 )
		file.mapListScrollState = 0

	UpdateMapListScroll()
}

function OnMapListScrollDown_Activate(...)
{
	file.mapListScrollState++
	if ( file.mapListScrollState > file.numMapButtonsOffScreen )
		file.mapListScrollState = file.numMapButtonsOffScreen

	UpdateMapListScroll()
}

function UpdateMapListScroll()
{
	local buttons = file.buttons
	local basePos = buttons[0].GetBasePos()
	local offset = buttons[0].GetHeight() * file.mapListScrollState

	buttons[0].SetPos( basePos[0], basePos[1] - offset )
}