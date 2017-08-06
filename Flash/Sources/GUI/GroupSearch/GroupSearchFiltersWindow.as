//Imports
import com.Utils.LDBFormat;
import com.Utils.Signal;
import gfx.core.UIComponent;
import gfx.controls.CheckBox;
import gfx.controls.Button;

//Class
class GUI.GroupSearch.GroupSearchFiltersWindow extends UIComponent
{
    //Constants    
	private var m_Background:MovieClip;
	private var m_AllActivitiesCheckbox:CheckBox;
	private var m_AllDifficultiesCheckbox:CheckBox;
	private var m_SocialCheckbox:CheckBox;
	private var m_TradeCheckbox:CheckBox;
	private var m_CabalCheckbox:CheckBox;
	private var m_DungeonCheckbox:CheckBox;
	private var m_RaidCheckbox:CheckBox;
	private var m_ScenarioCheckbox:CheckBox;
	private var m_LairCheckbox:CheckBox;
	private var m_MissionCheckbox:CheckBox;
	private var m_PvPCheckbox:CheckBox;
	private var m_FiltersLabel:TextField;
	private var m_AllActivitiesLabel:TextField;
	private var m_AllDifficultiesLabel:TextField;
	private var m_SocialLabel:TextField;
	private var m_TradeLabel:TextField;
	private var m_CabalLabel:TextField;
	private var m_DungeonLabel:TextField;
	private var m_RaidLabel:TextField;
	private var m_ScenarioLabel:TextField;
	private var m_LairLabel:TextField;
	private var m_MissionLabel:TextField;
	private var m_PvPLabel:TextField;
	private var m_NormalCheckbox:CheckBox;
	private var m_EliteCheckbox:CheckBox;
	private var m_NightmareCheckbox:CheckBox;
	private var m_DifficultiesLabel:TextField;
	private var m_NormalLabel:TextField;
	private var m_EliteLabel:TextField;
	private var m_NightmareLabel:TextField;
	private var m_ApplyButton:Button;
    private var m_CancelButton:Button;
	
	public static var SOCIAL:Number = 0;
	public static var TRADE:Number = 1;
	public static var CABAL:Number = 2;
	public static var DUNGEON:Number = 3;
	public static var RAID:Number = 4;
	public static var SCENARIO:Number = 5;
	public static var LAIR:Number = 6;
	public static var MISSION:Number = 7;
	public static var PVP:Number = 8;
	
	public static var ANY:Number = 0;
	public static var NORMAL:Number = 1;
	public static var ELITE:Number = 2;
	public static var NIGHTMARE:Number = 3;
	
	public static var TDB_ALL:String = LDBFormat.LDBGetText("GroupSearchGUI", "AllFilters");
	
	public static var TDB_ACTIVITY:String = LDBFormat.LDBGetText("GroupSearchGUI", "ViewActivity");
	public static var TDB_SOCIAL:String = LDBFormat.LDBGetText("GroupSearchGUI", "Social");
	public static var TDB_TRADE:String = LDBFormat.LDBGetText("GroupSearchGUI", "Trade");
	public static var TDB_CABAL:String = LDBFormat.LDBGetText("GroupSearchGUI", "Cabal");
	public static var TDB_PVP:String = LDBFormat.LDBGetText("GroupSearchGUI", "PvP");
	public static var TDB_DUNGEON:String = LDBFormat.LDBGetText("GroupSearchGUI", "Dungeon");
	public static var TDB_RAID:String = LDBFormat.LDBGetText("GroupSearchGUI", "Raid");
	public static var TDB_SCENARIO:String = LDBFormat.LDBGetText("GroupSearchGUI", "Scenario");
	public static var TDB_LAIR:String = LDBFormat.LDBGetText("GroupSearchGUI", "Lair");
	public static var TDB_MISSION:String = LDBFormat.LDBGetText("GroupSearchGUI", "Mission");
	
	public static var TDB_DIFFICULTY:String = LDBFormat.LDBGetText("GroupSearchGUI", "ViewDifficultyMessage");
	public static var TDB_ANY:String = LDBFormat.LDBGetText("GroupSearchGUI", "anyDifficulty");
	public static var TDB_NORMAL:String = LDBFormat.LDBGetText("GroupSearchGUI", "normalDifficulty");
	public static var TDB_ELITE:String = LDBFormat.LDBGetText("GroupSearchGUI", "eliteDifficulty");
	public static var TDB_NIGHTMARE:String = LDBFormat.LDBGetText("GroupSearchGUI", "nightmareDifficulty");
	
    //Properties
    public var SignalFiltersChanged:Signal;
    
    //Constructor
    public function GroupSearchFiltersWindow()
    {
        super();        
        SignalFiltersChanged = new Signal;
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        _visible = false;        
		_x = _parent._width / 2 - _width / 2;
        _y = _parent._height / 2 - _height / 2;
		
		m_ApplyButton.label = LDBFormat.LDBGetText("GenericGUI", "Apply");
        m_ApplyButton.disableFocus = true;
        m_ApplyButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        m_CancelButton.label = LDBFormat.LDBGetText("GenericGUI", "Cancel");
        m_CancelButton.disableFocus = true;
        m_CancelButton.addEventListener("click", this, "ResponseButtonEventHandler");
		
		m_FiltersLabel.text = TDB_ACTIVITY;
		m_AllActivitiesLabel.text = TDB_ALL;
		m_AllDifficultiesLabel.text = TDB_ALL;
		
		m_SocialLabel.text = TDB_SOCIAL;
		m_TradeLabel.text = TDB_TRADE;
		m_CabalLabel.text = TDB_CABAL;
		m_DungeonLabel.text = TDB_DUNGEON;
		m_RaidLabel.text = TDB_RAID;
		m_ScenarioLabel.text = TDB_SCENARIO;
		m_LairLabel.text = TDB_LAIR;
		m_MissionLabel.text = TDB_MISSION;
		m_PvPLabel.text = TDB_PVP;
		
		m_DifficultiesLabel.text = TDB_DIFFICULTY;
		m_NormalLabel.text = TDB_NORMAL;
		m_EliteLabel.text = TDB_ELITE;
		m_NightmareLabel.text = TDB_NIGHTMARE;
		
		m_AllActivitiesCheckbox.addEventListener("click",this,"ToggleAllActivities");
		m_AllDifficultiesCheckbox.addEventListener("click",this,"ToggleAllDifficulties");
		
		m_SocialCheckbox.addEventListener("click",this,"FiltersChanged");
		m_TradeCheckbox.addEventListener("click",this,"FiltersChanged");
		m_CabalCheckbox.addEventListener("click",this,"FiltersChanged");
		m_DungeonCheckbox.addEventListener("click",this,"FiltersChanged");
		m_RaidCheckbox.addEventListener("click",this,"FiltersChanged");
		m_ScenarioCheckbox.addEventListener("click",this,"FiltersChanged");
		m_LairCheckbox.addEventListener("click",this,"FiltersChanged");
		m_MissionCheckbox.addEventListener("click",this,"FiltersChanged");
		m_PvPCheckbox.addEventListener("click",this,"FiltersChanged");
		
		m_NormalCheckbox.addEventListener("click",this,"FiltersChanged");
		m_EliteCheckbox.addEventListener("click",this,"FiltersChanged");
		m_NightmareCheckbox.addEventListener("click",this,"FiltersChanged");
    }
    
    //Show Prompt
    public function ShowPrompt(selectedFilters:Array, selectedDifficulties:Array):Void
    {  
        if (_visible)
        {
            return;
        }
		SetFilters(selectedFilters, selectedDifficulties);
        swapDepths(_parent.getNextHighestDepth()); 
		_x = _parent._width / 2 - _width / 2;
        _y = _parent._height / 2 - _height / 2;
        _visible = true;
    }
	
	//Called when a filter checkbox is changed
	private function FiltersChanged():Void
	{
		var activities:Array = BuildFilterArray();
		var difficulties:Array = BuildDifficultyArray();
		m_AllActivitiesCheckbox.selected = activities.length == PVP + 1;
		m_AllDifficultiesCheckbox.selected = difficulties.length == NIGHTMARE;
	}
	
	//Called with the all activities checkbox is changed
	private function ToggleAllActivities():Void
	{
		var select:Boolean = m_AllActivitiesCheckbox.selected;
		m_SocialCheckbox.selected = select;
		m_TradeCheckbox.selected = select;
		m_CabalCheckbox.selected = select;
		m_DungeonCheckbox.selected = select;
		m_RaidCheckbox.selected = select;
		m_ScenarioCheckbox.selected = select;
		m_LairCheckbox.selected = select;
		m_MissionCheckbox.selected = select;
		m_PvPCheckbox.selected = select;
	}
	
	//Called with the all difficulties checkbox is changed
	private function ToggleAllDifficulties():Void
	{
		var select:Boolean = m_AllDifficultiesCheckbox.selected;
		m_NormalCheckbox.selected = select;
		m_EliteCheckbox.selected = select;
		m_NightmareCheckbox.selected = select;
	}
    
    //Response Button Event Handler
    private function ResponseButtonEventHandler(event:Object):Void
    {
		if (event.target == m_ApplyButton)
        {
			var filter:Array = BuildFilterArray();
			var difficulty:Array = BuildDifficultyArray();
			SignalFiltersChanged.Emit(true, filter, difficulty);
		}
		else
		{
			SignalFiltersChanged.Emit(false);
		}
		_visible = false;
        Selection.setFocus(null);
	}
	
	private function BuildFilterArray():Array
	{
		var filter = new Array();
		if (m_SocialCheckbox.selected){ filter.push(SOCIAL); }
		if (m_TradeCheckbox.selected){ filter.push(TRADE); }
		if (m_CabalCheckbox.selected){ filter.push(CABAL); }
		if (m_DungeonCheckbox.selected){ filter.push(DUNGEON); }
		if (m_RaidCheckbox.selected){ filter.push(RAID); }
		if (m_ScenarioCheckbox.selected){ filter.push(SCENARIO); }
		if (m_LairCheckbox.selected){ filter.push(LAIR); }
		if (m_MissionCheckbox.selected){ filter.push(MISSION); }
		if (m_PvPCheckbox.selected){ filter.push(PVP); }
		return filter;
	}
	
	private function BuildDifficultyArray():Array
	{
		var difficulty = new Array();
		if (m_NormalCheckbox.selected){ difficulty.push(NORMAL); }
		if (m_EliteCheckbox.selected){ difficulty.push(ELITE); }
		if (m_NightmareCheckbox.selected){ difficulty.push(NIGHTMARE); }
		return difficulty;
	}
    
    //Set Role Persistence
    private function SetFilters(selectedFilters:Array, selectedDifficulties):Void
    {
        if (selectedFilters == undefined)
        {
            return;
        }
		m_SocialCheckbox.selected = false;
		m_TradeCheckbox.selected = false;
		m_CabalCheckbox.selected = false;
		m_DungeonCheckbox.selected = false;
		m_RaidCheckbox.selected = false;
		m_ScenarioCheckbox.selected = false;
		m_LairCheckbox.selected = false;
		m_MissionCheckbox.selected = false;
		m_PvPCheckbox.selected = false;
		for (var i:Number = 0; i<selectedFilters.length; i++)
		{
			if (selectedFilters[i] == SOCIAL){ m_SocialCheckbox.selected = true; }
			if (selectedFilters[i] == TRADE){ m_TradeCheckbox.selected = true; }
			if (selectedFilters[i] == CABAL){ m_CabalCheckbox.selected = true; }
			if (selectedFilters[i] == DUNGEON){ m_DungeonCheckbox.selected = true; }
			if (selectedFilters[i] == RAID){ m_RaidCheckbox.selected = true; }
			if (selectedFilters[i] == SCENARIO){ m_ScenarioCheckbox.selected = true; }
			if (selectedFilters[i] == LAIR){ m_LairCheckbox.selected = true; }
			if (selectedFilters[i] == MISSION){ m_MissionCheckbox.selected = true; }
			if (selectedFilters[i] == PVP){ m_PvPCheckbox.selected = true; }
		}
		m_AllActivitiesCheckbox.selected = selectedFilters.length == PVP + 1;
		
		m_NormalCheckbox.selected = false;
		m_EliteCheckbox.selected = false;
		m_NightmareCheckbox.selected = false;
		for (var i:Number = 0; i<selectedDifficulties.length; i++)
		{
			if (selectedDifficulties[i] == NORMAL){ m_NormalCheckbox.selected = true; }
			if (selectedDifficulties[i] == ELITE){ m_EliteCheckbox.selected = true; }
			if (selectedDifficulties[i] == NIGHTMARE){ m_NightmareCheckbox.selected = true; }
		}
		m_AllDifficultiesCheckbox.selected = selectedDifficulties.length == NIGHTMARE;
    }
}