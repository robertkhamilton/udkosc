class OSCHud extends UTHUD
	config(OSCPresentation);

/*
#exec TEXTURE IMPORT NAME=pHUD FILE=Textures\traintag.pcx GROUP="HUD" MIPS=OFF FLAGS=2

var texture T;
*/

var FONT currentFont;

var bool bDrawSlides;

//http://www.shad-fr.com/udk/hudtut/english.html

var int slideStartX, slideStartY, slideWidth, slideHeight;
var int slideNextX, slideNextY, slideNextWidth, slideNextHeight;

var config String slide_1_text;
var config int slide_1_x, slide_1_y;

var String currentTitle;
var Float currentTitleX;
var Float currentTitleY;
var String currentText;
var Float currentX;
var Float currentY;
var Float currentTextX;
var Float currentTextY;

var int slideNumber;
var int slideCount;

var int slideColorR;
var int slideColorG;
var int slideColorB;
var int slideColorA;

var int slideTextColorR;
var int slideTextColorG;
var int slideTextColorB;
var int slideTextColorA;

var int slideImgId;
var float slideImgX;
var float slideImgY;
var float slideImgScale;

var float debugSlideImgX;		// DEBUG
var float debugSlideImgY;		// DEBUG

var int viewportWidth;			// current resolution pixel width
var int viewportHeight;			// current resolution pixel height
var vector viewportSize;

var FONT fontArial;
var FONT fontArialSmall;
var FONT fontArialMedium;
var FONT fontArialLarge;
var FONT fontVerdanaSmall;
var FONT fontVerdanaMedium;
var FONT fontVerdanaLarge;
var FONT fontSourceSansProTiny;
var FONT fontSourceSansProSmall;
var FONT fontSourceSansProMedium;
var FONT fontSourceSansProLarge;

var float textScale;
var float titleScale;

var float currentDeltaTime;

var int footerNumber;

var String footerText;
var float footerTextX;
var float footerTextY;
var float footerTextScale;

var int footerTextColorR;
var int footerTextColorG;
var int footerTextColorB;
var int footerTextColorA;

var int footerImgId;
var float footerImgX;
var float footerImgY;
var float footerImgScale;

var int fontSize;
	
var float tempVar1, tempVar2, tempVar3, tempVar4;

struct Layout
{
	var float x;
	var float y;
	var float width;
	var float height;		// 0.0 - 1.0 * current resolution			
	var int colorR;
	var int colorG;
	var int colorB;
	var int colorA;	
	var int textColorR;
	var int textColorG;
	var int textColorB;
	var int textColorA;
	var float transitionTime;
	var int fontSize;
	var int Footer;			// default -1 means no Footer
};

struct Slide
{
	var int layout;	
	var String title;
	var float titleX;
	var float titleY;
	var float titleScale;
	var String text;
	var float textX;
	var float textY;
	var float textScale;	
	var int imgId;			// default -1 means no img	
	var float imgX;
	var float imgY;
	var float imgScale;
	var string ccmd;		// console command string
};

struct Footer
{
	var String text;
	var float textScale;
	var float textX;
	var float textY;
	var int textColorR;
	var int textColorG;
	var int textColorB;
	var int textColorA;	
	var int imgId;			// default -1 means no img	
	var float imgX;
	var float imgY;
	var float imgScale;	
};

// Mirror struct from OSCPawn.uc

struct PlayerStateStruct
{
    var string Hostname;
    var int Port;
    var int id;
    var string PlayerName;
    var float LocX;
    var float LocY;
    var float LocZ;
    var int crouch;
    var float Pitch;
    var float Yaw;
    var float Roll;
    var float leftTrace; 
    var float rightTrace;
    var float downTrace;
    var float sendCall;    // 1/0 Call is fired
    var float bone1X;
    var float bone1Y;
    var float bone1Z;
	var float bone2X;
    var float bone2Y;
    var float bone2Z;
};

struct Image
{
	var string type;
	var string package;
	var string name;
};

var config array<Slide> Slides;
var config array<Layout> Layouts;
var config array<Footer> Footers;
var array<Texture2D> Images;
var array<FONT> Fonts;
var config array<String> Texts;

var config array<Image> iniImages;

var Texture2D d3_graph_1_TEX, img_valkordia_grey_TEX;

var bool editSlide;
var bool bShowOSCData;
var bool bShowOSCTraceData;
var bool bShowOSCBoneData;

var PlayerStateStruct psStruct;


exec function editSlides()
{
	editSlide=!editSlide;
}

exec function getCurrentResolution()
{
	`log("Current Resolution: "$self.Canvas.SizeX$", "$Canvas.SizeY);
}

simulated function PostBeginPlay()
{	
	super.PostBeginPlay();

	slideCount=Slides.Length;		
}

/*
// Load images from .ini as Texture2Ds
function loadImages()
{
	local int i;
	local Texture2D currentTexture;
	
	for(i=0; i<iniImages.Length; i++)
	{

// Creates and initializes a new Texture2DDynamic with the requested settings
// static native noexport final function Texture2DDynamic Create(int InSizeX, int InSizeY, optional EPixelFormat InFormat = PF_A8R8G8B8, optional bool InIsResolveTarget = FALSE);

		Images[i] = Texture2D'iniImages[i].package $ 
	}

// 	Images[0] = Texture2D'udkosc.presentation.d3_wing_zoom_composite_small';
}
*/

exec function setCurrentSlide(int var)
{
	slideNumber = var;
}

exec function nextSlide()
{
	slideNumber = (slideNumber + 1) % slideCount;	
}

exec function prevSlide()
{
	slideNumber = (slideNumber - 1) % slideCount;

	if(slideNumber < 0)
		slideNumber = slideCount-1;
}

function buildSlide()
{
	// Set slide's Canvas position, text and img properties
	// ----------------------------------------------------
	
	// Calc slide starting x...
	slideNextX = Layouts[Slides[slideNumber].layout].x * viewportWidth;
	
	if(slideStartX != slideNextX)
		slideStartX = Lerp(slideStartX , slideNextX, Layouts[Slides[slideNumber].layout].transitionTime);
	
	//	slideStartX = Layouts[Slides[slideNumber].layout].x * viewportWidth;
	
	// Calc slide starting y...
	slideNextY = Layouts[Slides[slideNumber].layout].y * viewportHeight;
	
	if(slideStartY != slideNextY) 
		slideStartY = Lerp(slideStartY , slideNextY, Layouts[Slides[slideNumber].layout].transitionTime);

	//	slideStartY = Layouts[Slides[slideNumber].layout].y * viewportHeight;
		
	// Calc slide width...
	slideNextWidth = Layouts[Slides[slideNumber].layout].width * viewportWidth;
	
	if(slideWidth != slideNextWidth)
		slideWidth = Lerp(slideWidth , slideNextWidth, Layouts[Slides[slideNumber].layout].transitionTime);
		
	//slideWidth = Layouts[Slides[slideNumber].layout].width * viewportWidth;
	
	//Calc slide height...
	slideNextHeight = Layouts[Slides[slideNumber].layout].height * viewportHeight;
	
	if(slideHeight != slideNextHeight)
		slideHeight = Lerp(slideHeight , slideNextHeight, Layouts[Slides[slideNumber].layout].transitionTime);	
	
	//slideHeight = Layouts[Slides[slideNumber].layout].height * viewportHeight;
	
	// Set slide color...
	slideColorR = Layouts[Slides[slideNumber].layout].colorR;
	slideColorG = Layouts[Slides[slideNumber].layout].colorG;
	slideColorB = Layouts[Slides[slideNumber].layout].colorB;
	slideColorA = Layouts[Slides[slideNumber].layout].colorA;
	
	// Set slide Text Font...
    // currentFont = "UI_Fonts_Final.HUD.MF_Medium";
	// currentFont = "UI_Fonts.MultiFonts.MF_HudLarge";
	// currentFont = "UI_Fonts.MultiFonts.MF_HudMedium";
	// currentFont = "UI_Fonts.MultiFonts.MF_HudSmall";
	
	// Set slide Text data and position...	
	currentTitle = Slides[slideNumber].title;
	currentTitleX = Slides[slideNumber].titleX * viewportWidth;
	currentTitleY = Slides[slideNumber].titleY * viewportHeight;	
	
	if(editSlide)
	{
	  currentTitleX = tempVar1 * viewportWidth;
	  currentTitleY = tempVar2 * viewportHeight;
	}
	
	currentText = Slides[slideNumber].text;

	if(bShowOSCData)
	{
		currentText = getOSCData();
	} else if(bShowOSCTraceData) {	
		currentText = getOSCTraceData();
	} else if(bShowOSCBoneData) {
		currentText = getOSCBoneData();
	} else {
		currentText = Slides[slideNumber].text;
	}
	
	currentTextX = Slides[slideNumber].textX * viewportWidth;
	currentTextY = Slides[slideNumber].textY * viewportHeight;
	
	if(editSlide)
	{
	  currentTextX = tempVar3 * viewportWidth;
	  currentTextY = tempVar4 * viewportHeight;
	}
	
	// Set slide Text color...
	slideTextColorR = Layouts[Slides[slideNumber].layout].textColorR;
	slideTextColorG = Layouts[Slides[slideNumber].layout].textColorG;
	slideTextColorB = Layouts[Slides[slideNumber].layout].textColorB;
	slideTextColorA = Layouts[Slides[slideNumber].layout].textColorA;	
	
	// Set slide text and title scaling
	titleScale = Slides[slideNumber].titleScale;
	textScale = Slides[slideNumber].textScale;
	
	// draw slide's image	
	slideImgId = Slides[slideNumber].ImgId;
	slideImgX = Slides[slideNumber].imgX * viewportWidth;
	slideImgY = Slides[slideNumber].imgY * viewportHeight;
	slideImgScale = Slides[slideNumber].imgScale;
	
	// DEBUG	
	// Over-ride slide position with debug if debug values have been set...
	if(editSlide)
	{
	  `log("debugSlideImgX: "$debugSlideImgX);
	  if(debugSlideImgX > -1)
		slideImgX = debugSlideImgX * viewportWidth;

	  `log("debugSlideImgY: "$debugSlideImgY);
	  if(debugSlideImgY > -1)
		slideImgY = debugSlideImgY * viewportHeight;
	}
	
	// Set slide footer data
	footerNumber = Layouts[Slides[slideNumber].layout].footer;
	
	if(footerNumber > -1) {
	  footerText = Footers[footerNumber].text; 
	  footerTextX = Footers[footerNumber].textX * viewportWidth;
	  footerTextY = Footers[footerNumber].textY * viewportHeight;
	  footerTextScale = Footers[footerNumber].textScale;
	  footerTextColorR = Footers[footerNumber].textColorR;
	  footerTextColorG = Footers[footerNumber].textColorG;
	  footerTextColorB = Footers[footerNumber].textColorB;
	  footerTextColorA = Footers[footerNumber].textColorA;	
	  footerImgId = Footers[footerNumber].ImgId;
	  footerImgX = Footers[footerNumber].imgX * viewportWidth;
	  footerImgY = Footers[footerNumber].imgY * viewportHeight;
	  footerImgScale = Footers[footerNumber].imgScale;
	}
	
	if(Slides[slideNumber].ccmd != "")
		executeConsoleCommand(Slides[slideNumber].ccmd);
}

exec function drawSlides(bool val)
{
	bDrawSlides=val;
}

exec function toggleSlides()
{
	bDrawSlides = !bDrawSlides;
}

exec function hudConsoleCommand()
{
	PlayerOwner.ConsoleCommand("ToggleSlides");
}

exec function showOSCBoneData(bool val)
{
	bShowOSCBoneData=val;
	if(val) {
		PlayerOwner.ConsoleCommand("showOSCData FALSE");
		PlayerOwner.ConsoleCommand("showOSCTraceData FALSE");
	}
}

exec function showText()
{
	PlayerOwner.ConsoleCommand("showOSCData FALSE");
	PlayerOwner.ConsoleCommand("showOSCTraceData FALSE");
	PlayerOwner.ConsoleCommand("showOSCBoneData FALSE");
	PlayerOwner.ConsoleCommand("debugPose FALSE");	
}

exec function showOSCData(bool val)
{
	bShowOSCData=val;	
	if(val) {
		PlayerOwner.ConsoleCommand("behindviewset 60 0 0");
		PlayerOwner.ConsoleCommand("showOSCTraceData FALSE");
		PlayerOwner.ConsoleCommand("showOSCBoneData FALSE");

		//PlayerOwner.ConsoleCommand("debugPose FALSE");
		//PlayerOwner.ConsoleCommand("togglePose FALSE");		
	}
}

exec function showOSCTraceData(bool val)
{
	bShowOSCTraceData=val;
	if(val) {
		PlayerOwner.ConsoleCommand("showOSCData TRUE");
		PlayerOwner.ConsoleCommand("showOSCBoneData FALSE");
		PlayerOwner.ConsoleCommand("slideTrace TRUE");
	} else {
		PlayerOwner.ConsoleCommand("slideTrace FALSE");
	}
}

exec function slideShowIK(bool val)
{
	if(val) {
		PlayerOwner.ConsoleCommand("behindviewset 20 -30 -65");		
		PlayerOwner.ConsoleCommand("debugPose TRUE");
		bShowOSCData=TRUE;	
		PlayerOwner.ConsoleCommand("showOSCTraceData FALSE");
		PlayerOwner.ConsoleCommand("showOSCBoneData FALSE");		
	} else
	{
		PlayerOwner.ConsoleCommand("behindviewset 60 0 0");
		PlayerOwner.ConsoleCommand("debugPose FALSE");	
	}
	
}

function String getOSCData()
{
	local String result;
	
	result = "Location:" $ "\n";
	result $= "      X: " $ psStruct.LocX $ "\n";
	result $= "      Y: " $ psStruct.LocY $ "\n";
	result $= "      Z: " $ psStruct.LocZ $ "\n";

	result $= "\n" $ "Rotation:" $ "\n";
	result $= "      Pitch: " $ psStruct.Pitch $ "\n";
	result $= "      Yaw: " $ psStruct.Yaw $ "\n";
	result $= "      Roll: " $ psStruct.Roll $ "\n";

	result $= "\n" $ "Ray Trace Distances:" $ "\n";
	result $= "       Left Trace: " $ psStruct.leftTrace $ "\n";
	result $= "       Right Trace: " $ psStruct.rightTrace $ "\n";
	result $= "       Down Trace: " $ psStruct.downTrace $ "\n";
	
	result $= "\n" $ "Bone Location (Local):" $ "\n";
	result $= "      Right X: " $ psStruct.bone1X $ "\n";
	result $= "      Right Y: " $ psStruct.bone1Y $ "\n";
	result $= "      Right Z: " $ psStruct.bone1Z $ "\n";
	result $= "      Left X: " $ psStruct.bone2X $ "\n";
	result $= "      Left Y: " $ psStruct.bone2Y $ "\n";
	result $= "      Left Z: " $ psStruct.bone2Z;
	
	return result;
}

function String getOSCTraceData()
{
	local String result;
	
	result = "Ray Trace Distances:" $ "\n";
	result $= "       Left Trace: " $ psStruct.leftTrace $ "\n";
	result $= "       Right Trace: " $ psStruct.rightTrace $ "\n";
	result $= "       Down Trace: " $ psStruct.downTrace $ "\n";

	return result;
}

function String getOSCBoneData()
{
	local String result;
	
	result = "Bone Location (Local):" $ "\n";
	result $= "      Right X: " $ psStruct.bone1X $ "\n";
	result $= "      Right Y: " $ psStruct.bone1Y $ "\n";
	result $= "      Right Z: " $ psStruct.bone1Z $ "\n";
	result $= "      Left X: " $ psStruct.bone2X $ "\n";
	result $= "      Left Y: " $ psStruct.bone2Y $ "\n";
	result $= "      Left Z: " $ psStruct.bone2Z;

	return result;
}

function executeConsoleCommand(string val)
{
	PlayerOwner.ConsoleCommand(val);
}

function DrawGameHud()
{
	if(bDrawSlides)
	{
	`log("Current Resolution: "$Canvas.SizeX$", "$Canvas.SizeY);
	
	  viewportWidth = Canvas.SizeX;
	  viewportHeight = Canvas.SizeY;	
	
      if ( !PlayerOwner.IsDead() && !UTPlayerOwner.IsInState('Spectating'))
      {

	    buildSlide();
	
		// Set Canvas position...
		Canvas.setPos(slideStartX, slideStartY);
	
		// draw slide's background rectangle...
		Canvas.SetDrawColor(slideColorR,slideColorG,slideColorB,slideColorA);
		Canvas.DrawRect(slideWidth, slideHeight);

	  	// draw image...
		if(slideImgId > -1)
		{
		  Canvas.SetPos(slideStartX + slideImgX, slideStartY + slideImgY);
	  	  Canvas.SetDrawColor(255,255,255,255);
	  	  Canvas.DrawTexture(Images[slideImgId], slideImgScale);
		}
				
		// draw slide's text...

//		if(Layouts[Slides[slideNumber].layout].fontSize == -1)
//		{
		/*
		  if(viewportWidth==1920)
		  {
			Canvas.Font = fontSourceSansProMedium;		
			`log("Canvas.Font is fontSourceSansProMedium");	
		  } else if(viewportWidth < 1280) {
			Canvas.Font = fontSourceSansProTiny;		
			`log("Canvas.Font is fontSourceSansProTiny");
		  } else {
			Canvas.Font = fontSourceSansProSmall;		
			`log("Canvas.Font is fontSourceSansProSmall");
		  } */
/*		} else { */
			Canvas.Font = Fonts[Layouts[Slides[slideNumber].layout].fontSize];
//		}		
		
		Canvas.setDrawColor(slideTextColorR,slideTextColorG,slideTextColorB,slideTextColorA);
		Canvas.SetPos(slideStartX + currentTextX, slideStartY + currentTextY);	  	
	  	Canvas.DrawText(currentText, TRUE, textScale, textScale);		
		Canvas.SetPos(slideStartX + currentTitleX, slideStartY + currentTitleY);	  		  	
		Canvas.DrawText(currentTitle, TRUE, titleScale, titleScale);		
		

		// draw footer...
		if(footerNumber > -1)
		{
			Canvas.SetPos(0, viewportHeight * 0.9);
			Canvas.SetDrawColor(100,100,100,100);
			Canvas.DrawRect(slideWidth, slideHeight * 0.02);
			Canvas.SetPos(footerTextX, footerTextY);			
			Canvas.setDrawColor(footerTextColorR,footerTextColorG,footerTextColorB,footerTextColorA);
			Canvas.Font = fontSourceSansProSmall;
			Canvas.DrawText(footerText, TRUE, footerTextScale, footerTextScale);
			
			if(footerImgId > -1)
			{
			  Canvas.SetPos(footerImgX, footerImgY);
			  Canvas.SetDrawColor(255,255,255,255);
			  Canvas.DrawTexture(img_valkordia_grey_TEX, footerImgScale * viewportWidth/1920.0);
			}
		}	
      }
	}
}

exec function drawHudRect(int lposx, int lposy, int lendx, int lendy)
{
	slideStartX=lposx;
	slideStartY=lposy;
	slideWidth=lendx;
	slideHeight=lendy;
}

exec function debugSlideImgPosition(float x, float y)
{
	debugSlideImgX = x;
	debugSlideImgY = y;
}

exec function slideDebugVar(float val1, float val2,float val3, float val4)
{
	tempVar1 = val1;
	tempVar2 = val2;
	tempVar3 = val3;	
	tempVar4 = val4;		
}

exec function slideTrace(bool val)
{
	if(val) {
	  PlayerOwner.ConsoleCommand("testtrace 1");
	} else {
  	  PlayerOwner.ConsoleCommand("testtrace 0");	
	}
}

exec function splashScreen()
{
	PlayerOwner.ConsoleCommand("hideweapon");
	PlayerOwner.ConsoleCommand("teleportpawn -45800 -10650 14300");
	PlayerOwner.ConsoleCommand("FlyWalk");
	PlayerOwner.ConsoleCommand("Setut3osccameramode 1");
}

function setCanvasLocation(int x, int y)
{
	slideStartX = x;
	slideStartY = y;
}

defaultproperties
{
	slideNumber=0
	slideWidth=400
	slideHeight=400
	slideStartX=0
	slideStartY=0
	slideColorR=255
	slideColorG=255
	slideColorB=25
	slideColorA=80
	
	titleScale=24.0
	textScale=24.0
	
//	fontArial = Font'EngineFonts.custom.arial'
	fontArial = Font'udkosc.Fonts.arial'
	fontArialSmall = Font'udkosc.Fonts.arial_24'
	fontArialMedium = Font'udkosc.Fonts.arial_36'	
	fontArialLarge = Font'udkosc.Fonts.arial_48'
	fontVerdanaSmall = Font'udkosc.Fonts.verdana_24'
	fontVerdanaMedium = Font'udkosc.Fonts.verdana_36'	
	fontVerdanaLarge = Font'udkosc.Fonts.verdana_48'
	fontSourceSansProTiny = Font'udkosc.Fonts.source_sans_pro_12'
	fontSourceSansProSmall = Font'udkosc.Fonts.source_sans_pro_24'
	fontSourceSansProMedium = Font'udkosc.Fonts.source_sans_pro_36'
	fontSourceSansProLarge = Font'udkosc.Fonts.source_sans_pro_48'
	
	Fonts[0] = Font'udkosc.Fonts.source_sans_pro_12';
	Fonts[1] = Font'udkosc.Fonts.source_sans_pro_24'
	Fonts[2] = Font'udkosc.Fonts.source_sans_pro_36'
	Fonts[3] = Font'udkosc.Fonts.source_sans_pro_48'
	
	footerNumber=-1
	
	tempVar1 = 0.0
	tempVar2 = 0.0
	tempVar3 = 0.0	
	tempVar4 = 0.0	
	
	d3_graph_1_TEX=Texture2D'udkosc.presentation.d3_wing_zoom_composite_small'
	
	Images[0] = Texture2D'udkosc.presentation.d3_wing_zoom_composite_small';
	Images[1] = Texture2D'udkosc.presentation.d3_wing_xyz_bw_large_font_legend';
	Images[2] = Texture2D'udkosc.presentation.gnuplot_xyz_2048';
	Images[3] = Texture2D'udkosc.presentation.sc_lighthouse_1024';
	Images[4] = Texture2D'udkosc.presentation.sc_screetch_512';
	Images[5] = Texture2D'udkosc.presentation.sc_sidetrace_512';
	Images[6] = Texture2D'udkosc.presentation.sc_wing_sines_512';
	Images[7] = Texture2D'udkosc.presentation.System_2048';
	Images[8] = Texture2D'udkosc.presentation.3birds_2048';
	Images[9] = Texture2D'udkosc.presentation.mvw_2048';
	Images[10] = Texture2D'udkosc.presentation.skel_mesh_trum_val_2048';
	Images[11] = Texture2D'udkosc.presentation.overview1';
	Images[12] = Texture2D'udkosc.presentation.overview2';
	Images[13] = Texture2D'udkosc.presentation.overview3';
	Images[14] = Texture2D'udkosc.presentation.overview4';
	Images[15] = Texture2D'udkosc.presentation.overview5';
	Images[16] = Texture2D'udkosc.presentation.overview6';
	Images[17] = Texture2D'udkosc.presentation.overview7';
	Images[18] = Texture2D'udkosc.presentation.overview8';
	Images[19] = Texture2D'udkosc.presentation.rift_2048';
	Images[20] = Texture2D'udkosc.presentation.space_1024';
	
	img_valkordia_grey_TEX=Texture2D'udkosc.presentation.valkordia-grey'
	
	debugSlideImgX = -1.0
	debugSlideImgY = -1.0
}
