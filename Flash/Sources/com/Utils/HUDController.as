//Imports
import com.GameInterface.DistributedValue;
import com.GameInterface.AccountManagement;
import GUIFramework.SFClipLoader;
import com.Utils.Archive;
import com.Utils.Signal;
import com.Utils.SignalGroup;
import flash.external.*;
import flash.geom.Rectangle;
import mx.transitions.easing.*;

//Class
class com.Utils.HUDController
{
    //Constants
    public static var s_ResolutionScaleMonitor = DistributedValue.Create("GUIResolutionScale");
    public static var s_HUDScaleMonitor = DistributedValue.Create("GUIScaleHUD");
	public static var s_AbilityBarScaleMonitor = DistributedValue.Create("AbilityBarScale");
	public static var s_PlayerInfoScaleMonitor = DistributedValue.Create("PlayerInfoScale");
	public static var s_TargetInfoScaleMonitor = DistributedValue.Create("TargetInfoScale");
	public static var s_LeftWeaponStatusScaleMonitor = DistributedValue.Create("LeftWeaponStatusScale");
	public static var s_RightWeaponStatusScaleMonitor = DistributedValue.Create("RightWeaponStatusScale");
	public static var s_LeftEnergyScaleMonitor = DistributedValue.Create("LeftEnergyScale");
	public static var s_RightEnergyScaleMonitor = DistributedValue.Create("RightEnergyScale");
	public static var s_PlayerCastbarScaleMonitor = DistributedValue.Create("PlayerCastbarScale");
	public static var s_TargetCastbarScaleMonitor = DistributedValue.Create("TargetCastbarScale");
	//public static var s_DodgebarScaleMonitor = DistributedValue.Create("DodgebarScale");
	public static var s_MissionTrackerScaleMonitor = DistributedValue.Create("MissionTrackerScale");
	public static var s_AnimaWheelLinkScaleMonitor = DistributedValue.Create("AnimaWheelLinkScale");
	public static var s_SignupNotificationsScaleMonitor = DistributedValue.Create("SignupNotificationsScale");
	public static var s_CompassScaleMonitor = DistributedValue.Create("CompassScale");
	public static var s_PvPMiniScoreboardScaleMonitor = DistributedValue.Create("PvPMiniScoreboardScale");
	public static var s_UltimateAbilityScaleMonitor = DistributedValue.Create("UltimateAbilityScale");
	public static var s_TopMenuAlignmentMonitor = DistributedValue.Create("TopMenuAlignment");
	public static var s_XPBarAlignmentMonitor = DistributedValue.Create("XPBarAlignment");
    
    //Properties
    private static var s_RegisteredModules:Object = new Object;

    //Constructor
    public function HUDController()
    {
        Stage.addListener(this);

        UpdateResolutionScale();
		SFClipLoader.SignalDisplayResolutionChanged.Connect(RestoreDefaultPositions, this);
        s_ResolutionScaleMonitor.SignalChanged.Connect(RestoreDefaultPositions, this);
		com.Utils.GlobalSignal.SignalInterfaceOptionsReset.Connect(RestoreDefaultPositions, this);
		AccountManagement.GetInstance().SignalLoginStateChanged.Connect(SlotLoginStateChanged, this);
        s_HUDScaleMonitor.SignalChanged.Connect(Layout, this);
		s_AbilityBarScaleMonitor.SignalChanged.Connect(Layout, this);
		s_PlayerInfoScaleMonitor.SignalChanged.Connect(Layout, this);
		s_TargetInfoScaleMonitor.SignalChanged.Connect(Layout, this);
		s_LeftWeaponStatusScaleMonitor.SignalChanged.Connect(Layout, this);
		s_RightWeaponStatusScaleMonitor.SignalChanged.Connect(Layout, this);
		s_LeftEnergyScaleMonitor.SignalChanged.Connect(Layout, this);
		s_RightEnergyScaleMonitor.SignalChanged.Connect(Layout, this);
		s_PlayerCastbarScaleMonitor.SignalChanged.Connect(Layout, this);
		s_TargetCastbarScaleMonitor.SignalChanged.Connect(Layout, this);
		//s_DodgebarScaleMonitor.SignalChanged.Connect(Layout, this);
		s_MissionTrackerScaleMonitor.SignalChanged.Connect(Layout, this);
		s_AnimaWheelLinkScaleMonitor.SignalChanged.Connect(Layout, this);
		s_SignupNotificationsScaleMonitor.SignalChanged.Connect(Layout, this);
		s_CompassScaleMonitor.SignalChanged.Connect(Layout, this);
		s_PvPMiniScoreboardScaleMonitor.SignalChanged.Connect(Layout, this);
		s_UltimateAbilityScaleMonitor.SignalChanged.Connect(Layout, this);
		s_TopMenuAlignmentMonitor.SignalChanged.Connect(Layout, this);
		s_XPBarAlignmentMonitor.SignalChanged.Connect(Layout, this);
    }
	
	// This is kind of hackish. We have to wait until the character is logged in before we can get DistributedValues for the GUI
	// This should only really do anything if the player changed resolutions in the patcher, or by manually editing the settings file
	public static function SlotLoginStateChanged( state:Number )
	{
		if (state == _global.Enums.LoginState.e_LoginStateInPlay)
		{
			var Resolution:DistributedValue = DistributedValue.Create("DisplayResolution");
			var CustomGUIResolution:DistributedValue = DistributedValue.Create("CustomGUIResolution");
			
			if (!Resolution.GetValue().equals(CustomGUIResolution.GetValue()))
			{
				RestoreDefaultPositions();
			}
		}
	}

    //Register Module
    public static function RegisterModule(name:String, movie:MovieClip):Void
    {
        s_RegisteredModules[name] = movie;
        
        if (movie.hasOwnProperty("SizeChanged"))
        {
            movie.SizeChanged.Connect(Layout);
        }
        
        Layout();
    }

    //Get Hide Position 2
    public static function GetHidePosition2(realPos:Rectangle):Rectangle
    {
        var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];

        var distToCenterX = realPos.x + realPos.width * 0.5 - visibleRect.width * 0.5;
        var distToCenterY = realPos.y + realPos.height * 0.5 - visibleRect.height * 0.5;

        if (Math.abs(distToCenterX) > Math.abs(distToCenterY))
        {
            if (distToCenterX > 0)
            {
                return new Rectangle(visibleRect.x + visibleRect.width + 20, realPos.y, realPos.width, realPos.height);
            }
            else
            {
                return new Rectangle(-(realPos.width + 20), realPos.y, realPos.width, realPos.height);
            }
        }
        else
        {
            if (distToCenterY > 0)
            {
                return new Rectangle(realPos.x, visibleRect.y + visibleRect.height + 20, realPos.width, realPos.height);
            }
            else
            {
                return new Rectangle(realPos.x, -(realPos.height + 20), realPos.width, realPos.height);
            }
        }
    }
    
    //Get Hide Position
    public static function GetHidePosition(realPos:Rectangle):Rectangle
    {
        var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];

        var distToCenterX = realPos.x + realPos.width * 0.5 - visibleRect.width * 0.5;
        var distToCenterY = realPos.y + realPos.height * 0.5 - visibleRect.height * 0.5;

        if (Math.abs(distToCenterX) > Math.abs(distToCenterY))
        {
            if (distToCenterX > 0)
            {
                return new Rectangle(realPos.x + 100, realPos.y, realPos.width, realPos.height);
            }
            else
            {
                return new Rectangle(realPos.x - 100, realPos.y, realPos.width, realPos.height);
            }
        }
        else
        {
            if (distToCenterY > 0)
            {
                return new Rectangle(realPos.x, realPos.y + 100, realPos.width, realPos.height);
            }
            else
            {
                return new Rectangle(realPos.x, realPos.y - 100, realPos.width, realPos.height);
            }
        }
    }
    
    //Deregister Module
    public static function DeregisterModule(name:String):Void
    {
        var movie:MovieClip = s_RegisteredModules[name];
        
        if (movie.hasOwnProperty("SizeChanged"))
        {
            movie.SizeChanged.Disconnect(null, Layout);
        }

        delete s_RegisteredModules[ name ];
        Layout();
    }

    //Get Module
    public static function GetModule(name:String):MovieClip
    {
        if (s_RegisteredModules.hasOwnProperty(name))
        {
            return s_RegisteredModules[name];
        }
        else
        {
            return null;
        }
    }

    //Update Resolution Scale
    private static function UpdateResolutionScale():Void
    {
        /*
         *  ResolutionScaleMonitor set values are based on what matches the
         *  concept the most in 1600x900 displays with a reference picture
         *  overlay.
         *
         */
        
        var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
        s_ResolutionScaleMonitor.SetValue(Math.max(Math.min(1600, visibleRect.width) / 1702, 0.80));
    }
    
    //On Resize
    private function onResize():Void
    {
        UpdateResolutionScale();
        Layout();
    }

    //Set Module Pos
    private static function SetModulePos(movie:MovieClip, x:Number, y:Number, hideOffsetX:Number, hideOffsetY:Number):Void
    {
        var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];

        movie._x = visibleRect.x + x;
        movie._y = visibleRect.y + y;
    }
    
    //Layout
    private static function Layout():Void
    {
        var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
        var dv:DistributedValue = DistributedValue.Create("GUIResolutionScale");
        var movie:MovieClip;
        var abilityBarTop:Number = 0;
		var abilityBarLeft:Number = 0;
		var abilityBarMainRight:Number = 0;
		var abilityBarRight:Number = 0;
		var playerInfoLeft:Number = 0;
        var xpBarHeight:Number = 0;
        var scale:Number = dv.GetValue();
		scale *= s_HUDScaleMonitor.GetValue() / 100;

        movie = GetModule("HUDBackground");
        if (movie != null)
        {
            var oldwidth:Number = movie._width;
            movie._width = visibleRect["width"]
			movie._yscale = scale * 100;

            SetModulePos    (
                            movie,
                            0,
                            visibleRect.height - movie._height,
                            0,
                            visibleRect.height - movie._height
                            );
        }

        movie = GetModule("AbilityBar");
        if (movie != null)
        {
			var abilityBarScale:Number = dv.GetValue();
			abilityBarScale *= s_AbilityBarScaleMonitor.GetValue() / 100;
            movie._xscale = abilityBarScale * 100;
            movie._yscale = abilityBarScale * 100;

            /*
             *  m_BaseWidth is a member of GUI.HUD.AbilityBar.as to serve as a 
             *  constant.  Without this constant, unintentional repositioning of
             *  the AbilityBar will occur:
             * 
             *  http://jira.funcom.com/browse/TSW-101595
             *
             */
            
            var baseWidth:Number = movie.m_BaseWidth * abilityBarScale;
			
			/*
             *  m_InitialY is a member of GUI.HUD.AbilityBar.as to serve as a 
             *  constant.  Without this constant, unintentional repositioning of
             *  the AbilityBar will occur:
             * 
             *  http://jira.funcom.com/browse/TSW-117931
             *
             */
			 			 
			var moduleX:DistributedValue = DistributedValue.Create( "AbilityBarX" );
			var moduleY:DistributedValue = DistributedValue.Create( "AbilityBarY" );	

			if (moduleX.GetValue() == "undefined") { moduleX.SetValue((visibleRect.width - baseWidth) * 0.5); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(visibleRect.height - 115 * abilityBarScale); }
						 
			movie.m_InitialY = moduleY.GetValue();
                
            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            movie._height + 2 * abilityBarScale
                            );

            abilityBarTop = moduleY.GetValue();
			abilityBarLeft = moduleX.GetValue();
			abilityBarMainRight = abilityBarLeft + movie.m_BaseWidth * abilityBarScale;
			abilityBarRight = abilityBarLeft + movie.m_BigWidth * abilityBarScale;
        }
		
		/*
        movie = GetModule("AAPassivesBar");
        if (movie != null)
        {
			var abilityBarScale:Number = dv.GetValue();
			abilityBarScale *= s_AbilityBarScaleMonitor.GetValue() / 100;
            movie._xscale = abilityBarScale * 100;
            movie._yscale = abilityBarScale * 100;
			
			/*
             *  m_InitialY is a member of GUI.HUD.PassivesBar.as to serve as a 
             *  constant.  Without this constant, unintentional repositioning of
             *  the AbilityBar will occur:
             * 
             *  http://jira.funcom.com/browse/TSW-117931
             *
            */
			/*
			var baseWidth:Number = GetModule("AbilityBar").m_BaseWidth * abilityBarScale;
			var moduleX:DistributedValue = DistributedValue.Create( "AbilityBarX" );
			var moduleY:DistributedValue = DistributedValue.Create( "AbilityBarY" );	
			
			//We just defined these, they shouldn't be undefined
			/*
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue((visibleRect.width - baseWidth) * 0.5); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(visibleRect.height - 79 * abilityBarScale); }
			*/
			 /*
			movie.m_InitialY = moduleY.GetValue();
            
            SetModulePos    (movie,
                            moduleX.GetValue() + 25 * abilityBarScale,
                            moduleY.GetValue(),
                            0,
                            movie._height - 41 * abilityBarScale
                            );
            
            abilityBarTop = movie.m_Bar.getBounds(_root).yMin;
        }
		
		*/
        
		//This thing doesn't actually exist AFAIK -Alanc
        movie = GetModule("SprintBar");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;

            SetModulePos    (
                            movie,
                            abilityBarLeft, 
							(abilityBarTop - visibleRect.y) - 75 * scale,
                            abilityBarLeft, 
							(abilityBarTop - visibleRect.y) - 75 * scale
                            );
        }

        movie = GetModule("AbilityList");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;
            
            SetModulePos    (
                            movie,
                            visibleRect.width - 20 * scale, 0,
                            20 * scale,
                            0
                            );
        }

        movie = GetModule("PassivesList");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;

            SetModulePos    (
                            movie,
                            visibleRect.width - 20 * scale,
                            0,
                            20 * scale,
                            0
                            );
        }

        movie = GetModule("PlayerInfo");
        if (movie != null)
        {
			var playerInfoScale:Number = dv.GetValue();
			playerInfoScale *= s_PlayerInfoScaleMonitor.GetValue() / 100;
            movie._xscale = playerInfoScale * 100;
            movie._yscale = playerInfoScale * 100;
			
			var moduleX:DistributedValue = DistributedValue.Create( "PlayerInfoX" );
			var moduleY:DistributedValue = DistributedValue.Create( "PlayerInfoY" );	
			
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue((visibleRect.width - movie._width) * 0.5 - 400 * playerInfoScale); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(visibleRect.height - 85 * playerInfoScale); }
            
            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            movie._height - 73 * playerInfoScale
                            );
							
			playerInfoLeft = movie.getBounds(_root).xMin;
        }
		
        movie = GetModule("TargetInfo");
        if (movie != null)
        {
			var targetInfoScale:Number = dv.GetValue();
			targetInfoScale *= s_TargetInfoScaleMonitor.GetValue() / 100;
            movie._xscale = targetInfoScale * 100;
            movie._yscale = targetInfoScale * 100;
			
			var moduleX:DistributedValue = DistributedValue.Create( "TargetInfoX" );
			var moduleY:DistributedValue = DistributedValue.Create( "TargetInfoY" );	
			
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue((visibleRect.width - movie._width) * 0.5 + 500 * targetInfoScale); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(visibleRect.height - 118 * targetInfoScale); }
            
            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            movie._height - 30 * targetInfoScale
                            );
        }
		
		movie = GetModule("LeftWeaponStatus");
        if (movie != null)
        {
			var leftWeaponStatusScale:Number = dv.GetValue();
			leftWeaponStatusScale *= s_LeftWeaponStatusScaleMonitor.GetValue() / 100;
            movie._xscale = leftWeaponStatusScale * 100;
            movie._yscale = leftWeaponStatusScale * 100;
						
			var moduleX:DistributedValue = DistributedValue.Create( "LeftWeaponStatusX" );
			var moduleY:DistributedValue = DistributedValue.Create( "LeftWeaponStatusY" );	
			
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue((visibleRect.width * 0.5) - (220 * leftWeaponStatusScale) - (100 * dv.GetValue())); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(visibleRect.height - 225 * leftWeaponStatusScale); }
			
            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            movie._height - 30 * leftWeaponStatusScale
                            );
        }
		
		movie = GetModule("RightWeaponStatus");
        if (movie != null)
        {
			var rightWeaponStatusScale:Number = dv.GetValue();
			rightWeaponStatusScale *= s_RightWeaponStatusScaleMonitor.GetValue() / 100;
            movie._xscale = rightWeaponStatusScale * 100;
            movie._yscale = rightWeaponStatusScale * 100;
						
			var moduleX:DistributedValue = DistributedValue.Create( "RightWeaponStatusX" );
			var moduleY:DistributedValue = DistributedValue.Create( "RightWeaponStatusY" );	
			
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue((visibleRect.width * 0.5) + (115 * dv.GetValue())); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(visibleRect.height - 225 * rightWeaponStatusScale); }
			
            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            movie._height - 30 * rightWeaponStatusScale
                            );
        }
		
		movie = GetModule("LeftEnergy");
        if (movie != null)
        {
			var leftEnergyScale:Number = dv.GetValue();
			leftEnergyScale *= s_LeftEnergyScaleMonitor.GetValue() / 100;
            movie._xscale = leftEnergyScale * 100;
            movie._yscale = leftEnergyScale * 100;
						
			var moduleX:DistributedValue = DistributedValue.Create( "LeftEnergyX" );
			var moduleY:DistributedValue = DistributedValue.Create( "LeftEnergyY" );	
			
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue((visibleRect.width * 0.5) - (251 * dv.GetValue())); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(visibleRect.height - 112 * dv.GetValue()); }
			
            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            movie._height - 30 * leftEnergyScale
                            );
        }
		
		movie = GetModule("RightEnergy");
        if (movie != null)
        {
			var rightEnergyScale:Number = dv.GetValue();
			rightEnergyScale *= s_RightEnergyScaleMonitor.GetValue() / 100;
            movie._xscale = rightEnergyScale * 100;
            movie._yscale = rightEnergyScale * 100;
						
			var moduleX:DistributedValue = DistributedValue.Create( "RightEnergyX" );
			var moduleY:DistributedValue = DistributedValue.Create( "RightEnergyY" );	
			
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue((visibleRect.width * 0.5) + (99 * dv.GetValue())); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(visibleRect.height - 112 * dv.GetValue()); }
			
            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            movie._height - 30 * rightEnergyScale
                            );
        }
        
        movie = GetModule("PlayerCastBar");
        if (movie != null)
        {
			var castbarScale:Number = dv.GetValue();
			castbarScale *= s_PlayerCastbarScaleMonitor.GetValue() / 100;
            movie._xscale = castbarScale * 100;
            movie._yscale = castbarScale * 100;
			
			var moduleX:DistributedValue = DistributedValue.Create( "PlayerCastbarX" );
			var moduleY:DistributedValue = DistributedValue.Create( "PlayerCastbarY" );	
			
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue(playerInfoLeft + 35 * castbarScale); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(visibleRect.height - 30 * castbarScale); }

            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            abilityBarTop - 47 * castbarScale
                            );
        }
        
        movie = GetModule("TargetCastBar");
        if (movie != null)
        {
			var castbarScale:Number = dv.GetValue();
			castbarScale *= s_TargetCastbarScaleMonitor.GetValue() / 100;
            movie._xscale = castbarScale * 100;
            movie._yscale = castbarScale * 100;
			
			var moduleX:DistributedValue = DistributedValue.Create( "TargetCastbarX" );
			var moduleY:DistributedValue = DistributedValue.Create( "TargetCastbarY" );	
			
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue(abilityBarRight + 10 * castbarScale); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(visibleRect.height - 30 * castbarScale); }

            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            90 * castbarScale
                            );
        }
        
		/*
        movie = GetModule("DodgeBar");
        if (movie != null)
        {
			var dodgebarScale:Number = dv.GetValue();
			dodgebarScale *= s_DodgebarScaleMonitor.GetValue() / 100;
            movie._xscale = dodgebarScale * 100;
            movie._yscale = dodgebarScale * 100;
			
			var moduleX:DistributedValue = DistributedValue.Create( "DodgebarX" );
			var moduleY:DistributedValue = DistributedValue.Create( "DodgebarY" );	
			
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue(abilityBarLeft); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue((abilityBarTop -visibleRect.y)  - (55 * dodgebarScale)); }

            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            abilityBarTop - 47 * dodgebarScale);
        }
		*/

        movie = GetModule("FIFO");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;

            SetModulePos    (
                            movie,
                            (visibleRect.width / 2),
                            50,
                            0,
                            0
                            );
        }

        movie = GetModule("DamageInfo");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;

            SetModulePos    (
                            movie,
                            0,
                            0,
                            0,
                            0
                            );
        }

        movie = GetModule("FriendlyMenu");
        if (movie != null)
        {
            movie._yscale = movie._xscale = scale * 100;
            movie._x = visibleRect.x;
            movie._y = visibleRect.y;
        }
		
		movie = GetModule("HUDXPBar");
        if (movie != null)
        {
			var XPBarAlignment:DistributedValue = DistributedValue.Create( "XPBarAlignment" );
			var yPos:Number = visibleRect.height - 8;
			if (XPBarAlignment.GetValue() == 0) { yPos = 0; }
            SetModulePos    (
                            movie,
                            0,
                            yPos,
                            0,
                            0
                            );
        }
		
		movie = GetModule("MainMenu");
        if (movie != null)
        {
			var TopMenuAlignment:DistributedValue = DistributedValue.Create( "TopMenuAlignment" )
			var XPBarAlignment:DistributedValue = DistributedValue.Create( "XPBarAlignment" );
			var yPos:Number = 0;
			if (TopMenuAlignment.GetValue() == 1) 
			{ 
				yPos = visibleRect.height - 20; 
				if (XPBarAlignment.GetValue() == 1 && DistributedValue.GetDValue("hud_xp_bar", true)) 
				{ 
					yPos -= 8; 
				}
			}
			else if (XPBarAlignment.GetValue() == 0 && DistributedValue.GetDValue("hud_xp_bar", true))
			{
				yPos = 8;
			}
			
            SetModulePos    (
                            movie,
                            0,
                            yPos,
                            0,
                            0
                            );
			movie.LayoutEditModeMask(); //In case edit mode is open when the bar is moved
        }
        
        movie = GetModule("MissionTracker");
        if (movie != null)
        {
			var missionTrackerScale:Number = dv.GetValue();
			missionTrackerScale *= s_MissionTrackerScaleMonitor.GetValue() / 100;
            movie._xscale = missionTrackerScale * 100;
            movie._yscale = missionTrackerScale * 100;
			
			var moduleX:DistributedValue = DistributedValue.Create( "MissionTrackerX" );
			var moduleY:DistributedValue = DistributedValue.Create( "MissionTrackerY" );	
			
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue(visibleRect.width - (60 * missionTrackerScale)); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(375 * missionTrackerScale); }
            
            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            0
                            );
			movie.AlignText();
        }
        
        movie = GetModule("Compass");
        if (movie != null)
        {
			var compassScale:Number = dv.GetValue();
			compassScale *= s_CompassScaleMonitor.GetValue() / 100;
            movie._xscale = compassScale * 90;
            movie._yscale = compassScale * 90;
			
			var moduleX:DistributedValue = DistributedValue.Create( "CompassX" );
			var moduleY:DistributedValue = DistributedValue.Create( "CompassY" );	
			
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue((visibleRect.width - movie._width) * 0.5); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(2.5); }
            
            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            0
                            );
        }

        movie = GetModule("PvPMiniScoreView");
        if (movie != null)
        {
			var scoreboardScale:Number = dv.GetValue();
			scoreboardScale *= s_PvPMiniScoreboardScaleMonitor.GetValue() / 100;
            movie._xscale = scoreboardScale * 100;
            movie._yscale = scoreboardScale * 100;
			
			var moduleX:DistributedValue = DistributedValue.Create( "PvPMiniScoreboardX" );
			var moduleY:DistributedValue = DistributedValue.Create( "PvPMiniScoreboardY" );	
			
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue((visibleRect.width - movie._width) * 0.5); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(30); }
            
            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            0
                            );
        }

        movie = GetModule("LatencyWindow");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;
            
            SetModulePos    (
                            movie,
                            0,
                            60,
                            0,
                            0
                            );
        }
        
        movie = GetModule("AnimaWheelLink");
        if (movie != null)
        {
			var notificationScale:Number = dv.GetValue();
			notificationScale *= s_AnimaWheelLinkScaleMonitor.GetValue() / 100;
            movie._xscale = notificationScale * 100;
            movie._yscale = notificationScale * 100;
			
			var moduleX:DistributedValue = DistributedValue.Create( "AnimaWheelLinkX" );
			var moduleY:DistributedValue = DistributedValue.Create( "AnimaWheelLinkY" );	
			
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue(visibleRect.width - 48 * notificationScale); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(visibleRect.height - 68 * notificationScale); }
            
            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            movie._height + 2 * notificationScale
                            );
        }

        movie = GetModule("SignUpNotifications");
        if (movie != null)
        {
			var notificationScale:Number = dv.GetValue();
			notificationScale *= s_SignupNotificationsScaleMonitor.GetValue() / 100;
            movie._xscale = notificationScale * 100;
            movie._yscale = notificationScale * 100;
			
			var moduleX:DistributedValue = DistributedValue.Create( "SignupNotificationsX" );
			var moduleY:DistributedValue = DistributedValue.Create( "SignupNotificationsY" );	
			
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue(11 * notificationScale); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(38 * notificationScale); }
            
            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            0
                            );
        }
        
        movie = GetModule("AchievementLoreWindow");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;
            
            SetModulePos    (
                            movie,
                            0,
                            0,
                            0,
                            0
                            );
        }
        
        movie = GetModule("WalletController");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;
            
            SetModulePos    (
                            movie,
                            0,
                            0,
                            0,
                            0
                            );
        }
		
		movie = GetModule("UltimateAbility");
        if (movie != null)
        {
			var ultimateAbilityScale:Number = dv.GetValue();
			ultimateAbilityScale *= s_UltimateAbilityScaleMonitor.GetValue() / 100;
            movie._xscale = ultimateAbilityScale * 100
			movie._yscale = ultimateAbilityScale * 100;
			
			var moduleX:DistributedValue = DistributedValue.Create( "UltimateAbilityX" );
			var moduleY:DistributedValue = DistributedValue.Create( "UltimateAbilityY" );
			
			if (moduleX.GetValue() == "undefined") { moduleX.SetValue((visibleRect.width - movie._width) * 0.5); }
			if (moduleY.GetValue() == "undefined") { moduleY.SetValue(visibleRect.height - (280 * dv.GetValue())); }

            SetModulePos    (
                            movie,
                            moduleX.GetValue(),
                            moduleY.GetValue(),
                            0,
                            0
                            );
        }
		
		//Set Minimap position
		com.GameInterface.WaypointInterface.MoveMinimap(DistributedValue.GetDValue("MinimapTopOffset"), DistributedValue.GetDValue("MinimapRightOffset"));
	}
	
	public static function RestoreDefaultPositions():Void
	{
		DistributedValue.SetDValue("AbilityBarX", "undefined");
		DistributedValue.SetDValue("AbilityBarY", "undefined");
		DistributedValue.SetDValue("AbilityBarScale", 100);
		DistributedValue.SetDValue("PlayerInfoX", "undefined");
		DistributedValue.SetDValue("PlayerInfoY", "undefined");
		DistributedValue.SetDValue("PlayerInfoScale", 100);
		DistributedValue.SetDValue("TargetInfoX", "undefined");
		DistributedValue.SetDValue("TargetInfoY", "undefined");
		DistributedValue.SetDValue("TargetInfoScale", 100);
		DistributedValue.SetDValue("LeftWeaponStatusX", "undefined");
		DistributedValue.SetDValue("LeftWeaponStatusY", "undefined");
		DistributedValue.SetDValue("LeftWeaponStatusScale", 100);
		DistributedValue.SetDValue("RightWeaponStatusX", "undefined");
		DistributedValue.SetDValue("RightWeaponStatusY", "undefined");
		DistributedValue.SetDValue("RightWeaponStatusScale", 100);
		DistributedValue.SetDValue("LeftEnergyX", "undefined");
		DistributedValue.SetDValue("LeftEnergyY", "undefined");
		DistributedValue.SetDValue("LeftEnergyScale", 100);
		DistributedValue.SetDValue("RightEnergyX", "undefined");
		DistributedValue.SetDValue("RightEnergyY", "undefined");
		DistributedValue.SetDValue("RightEnergyScale", 100);
		DistributedValue.SetDValue("PlayerCastbarX", "undefined");
		DistributedValue.SetDValue("PlayerCastbarY", "undefined");
		DistributedValue.SetDValue("PlayerCastbarScale", 100);
		DistributedValue.SetDValue("TargetCastbarX", "undefined");
		DistributedValue.SetDValue("TargetCastbarY", "undefined");
		DistributedValue.SetDValue("TargetCastbarScale", 100);
		/*
		DistributedValue.SetDValue("DodgebarX", "undefined");
		DistributedValue.SetDValue("DodgebarY", "undefined");
		DistributedValue.SetDValue("DodgebarScale", 100);
		*/
		DistributedValue.SetDValue("MissionTrackerX", "undefined");
		DistributedValue.SetDValue("MissionTrackerY", "undefined");
		DistributedValue.SetDValue("MissionTrackerScale", 100);
		DistributedValue.SetDValue("AnimaWheelLinkX", "undefined");
		DistributedValue.SetDValue("AnimaWheelLinkY", "undefined");
		DistributedValue.SetDValue("AnimaWheelLinkScale", 100);
		DistributedValue.SetDValue("SignupNotificationsX", "undefined");
		DistributedValue.SetDValue("SignupNotificationsY", "undefined");
		DistributedValue.SetDValue("SignupNotificationsScale", 100);
		DistributedValue.SetDValue("CompassX", "undefined");
		DistributedValue.SetDValue("CompassY", "undefined");
		DistributedValue.SetDValue("CompassScale", 100);
		DistributedValue.SetDValue("MinimapTopOffset", 25);
		DistributedValue.SetDValue("MinimapRightOffset", 0);
		DistributedValue.SetDValue("MinimapScale", 100);
		DistributedValue.SetDValue("ScryCounterX", "undefined");
		DistributedValue.SetDValue("ScryCounterY", "undefined");
		DistributedValue.SetDValue("ScryCounterScale", 100);
		DistributedValue.SetDValue("ScryTimerX", "undefined");
		DistributedValue.SetDValue("ScryTimerY", "undefined");
		DistributedValue.SetDValue("ScryTimerScale", 100);
		DistributedValue.SetDValue("ScryTimerCounterComboX", "undefined");
		DistributedValue.SetDValue("ScryTimerCounterComboY", "undefined");
		DistributedValue.SetDValue("ScryTimerCounterComboScale", 100);
		DistributedValue.SetDValue("PvPMiniScoreboardX", "undefined");
		DistributedValue.SetDValue("PvPMiniScoreboardY", "undefined");
		DistributedValue.SetDValue("PvPMiniScoreboardScale", 100);
		DistributedValue.SetDValue("UltimateAbilityX", "undefined");
		DistributedValue.SetDValue("UltimateAbilityY", "undefined");
		DistributedValue.SetDValue("UltimateAbilityScale", 100);
		
		//Set the CustomGUIResolution equal to the resolution that these values were set for
		var Resolution:DistributedValue = DistributedValue.Create("DisplayResolution");
		var CustomGUIRes:DistributedValue = DistributedValue.Create("CustomGUIResolution");
		
		CustomGUIRes.SetValue(Resolution.GetValue());
		
		Layout();
	}
}