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
var int footerDrawBar;
var float footerImgX;
var float footerImgY;
var float footerImgScale;

var int fontSize;
	
var float tempVar1, tempVar2, tempVar3, tempVar4;

var bool trumbruticusLoaded;

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
	var int drawBar;
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
var config int presentationWidth;
var config int presentationHeight;
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
	
	if(Layouts[Slides[slideNumber].layout].transitionTime > 0)
	{
	  if(slideStartX != slideNextX)
		slideStartX = Lerp(slideStartX , slideNextX, Layouts[Slides[slideNumber].layout].transitionTime);
	
	//	slideStartX = Layouts[Slides[slideNumber].layout].x * viewportWidth;
	} else {
 	  slideStartX = Layouts[Slides[slideNumber].layout].x * viewportWidth;
	}
	
	// Calc slide starting y...
	slideNextY = Layouts[Slides[slideNumber].layout].y * viewportHeight;

	if(Layouts[Slides[slideNumber].layout].transitionTime > 0)
	{
	
  	  if(slideStartY != slideNextY) 
		slideStartY = Lerp(slideStartY , slideNextY, Layouts[Slides[slideNumber].layout].transitionTime);

	//	slideStartY = Layouts[Slides[slideNumber].layout].y * viewportHeight;
	} else {
 	  slideStartY = Layouts[Slides[slideNumber].layout].y * viewportHeight;
	}
	
	// Calc slide width...
	slideNextWidth = Layouts[Slides[slideNumber].layout].width * viewportWidth;
	
	if(Layouts[Slides[slideNumber].layout].transitionTime > 0)
	{
	
	  if(slideWidth != slideNextWidth)
		slideWidth = Lerp(slideWidth , slideNextWidth, Layouts[Slides[slideNumber].layout].transitionTime);
		
	//slideWidth = Layouts[Slides[slideNumber].layout].width * viewportWidth;
	} else {
	  slideWidth = Layouts[Slides[slideNumber].layout].width * viewportWidth;
	}
	
	//Calc slide height...
	slideNextHeight = Layouts[Slides[slideNumber].layout].height * viewportHeight;
	
	if(Layouts[Slides[slideNumber].layout].transitionTime > 0)
	{
	
	  if(slideHeight != slideNextHeight)
		slideHeight = Lerp(slideHeight , slideNextHeight, Layouts[Slides[slideNumber].layout].transitionTime);	
	
	//slideHeight = Layouts[Slides[slideNumber].layout].height * viewportHeight;
	} else {
	  slideHeight = Layouts[Slides[slideNumber].layout].height * viewportHeight;
	}
	
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
	  footerDrawBar = Footers[footernumber].drawBar;
	  footerImgX = Footers[footerNumber].imgX * viewportWidth;
	  footerImgY = Footers[footerNumber].imgY * viewportHeight;
	  footerImgScale = Footers[footerNumber].imgScale;
	}
	
	if(Slides[slideNumber].ccmd != "")
		executeConsoleCommand(Slides[slideNumber].ccmd);
}

exec function whiteroom()
{
	PlayerOwner.ConsoleCommand("teleportpawn 1000 1000 -25500");	
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

exec function showOffTrumbruticus()
{
	PlayerOwner.ConsoleCommand("teleportpawn 20380 37785 -147.8");
	PlayerOwner.ConsoleCommand("swapCharacter");
	
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
			if(footerDrawBar == 1)
 			{
  			  Canvas.DrawRect(slideWidth, slideHeight * 0.02);
			}
			Canvas.SetPos(footerTextX, footerTextY);			
			Canvas.setDrawColor(footerTextColorR,footerTextColorG,footerTextColorB,footerTextColorA);
			Canvas.Font = fontSourceSansProSmall;
			Canvas.DrawText(footerText, TRUE, footerTextScale, footerTextScale);
			
			if(footerImgId > -1)
			{
			  Canvas.SetPos(footerImgX, footerImgY);
			  Canvas.SetDrawColor(255,255,255,255);
//			  Canvas.DrawTexture(img_valkordia_grey_TEX, footerImgScale * viewportWidth/1920.0);
			  Canvas.DrawTexture(Images[footerImgId], footerImgScale * viewportWidth/slideWidth);			  
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

exec function mapoverviewPosition()
{
	PlayerOwner.ConsoleCommand("ChangePlayerMesh 2");
	PlayerOwner.ConsoleCommand("posePlayer True");
	
	PlayerOwner.ConsoleCommand("teleportpawn -50233 -29004 48122");
}

exec function sidetracePosition()
{
	PlayerOwner.ConsoleCommand("teleportpawn 61386 -64840 8677");
	PlayerOwner.ConsoleCommand("showOSCTraceData TRUE");	
}

exec function verticaltracePosition()
{
	PlayerOwner.ConsoleCommand("teleportpawn -15762, -26962, 760");
	PlayerOwner.ConsoleCommand("showOSCTraceData TRUE");
}

exec function loadValkordia()
{
	PlayerOwner.ConsoleCommand("ChangePlayerMesh 2");
	
}

exec function loadTrumbruticus()
{
	if(!trumbruticusLoaded) {
		PlayerOwner.ConsoleCommand("ChangePlayerMesh 1");
		trumbruticusLoaded = True;
		
		PlayerOwner.ConsoleCommand("teleportpawn -30449.5, -20130.0, 41.4");
		PlayerOwner.ConsoleCommand("behindviewset 1200, 0, 100");
				
	}
}

exec function splashScreen()
{
	//PlayerOwner.ConsoleCommand("hideweapon");
	PlayerOwner.ConsoleCommand("teleportpawn -45800 -10650 14300");
/*	PlayerOwner.ConsoleCommand("FlyWalk"); */
	PlayerOwner.ConsoleCommand("OSCSetFly 1");
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

	footerDrawBar=-1
	
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
	Fonts[4] = Font'udkosc.Fonts.verdana_24'
	Fonts[5] = Font'udkosc.Fonts.verdana_36'	
	Fonts[6] = Font'udkosc.Fonts.verdana_48'

	footerNumber=-1
	
	tempVar1 = 0.0
	tempVar2 = 0.0
	tempVar3 = 0.0	
	tempVar4 = 0.0	
	
	d3_graph_1_TEX=Texture2D'udkosc.presentation.d3_wing_zoom_composite_small'

	// PhD Defense Slides
	Images[0] = Texture2D'phd.slide001';	
	Images[1] = Texture2D'phd.slide001';
	Images[2] = Texture2D'phd.slide002';
	Images[3] = Texture2D'phd.slide003';
	Images[4] = Texture2D'phd.slide004';
	Images[5] = Texture2D'phd.slide005';
	Images[6] = Texture2D'phd.slide006';
	Images[7] = Texture2D'phd.slide007';
	Images[8] = Texture2D'phd.slide008';
	Images[9] = Texture2D'phd.slide009';
	Images[10] = Texture2D'phd.slide010';
	Images[11] = Texture2D'phd.slide011';
	Images[12] = Texture2D'phd.slide012';	
	Images[13] = Texture2D'phd.slide013';
	Images[14] = Texture2D'phd.slide014';
	Images[15] = Texture2D'phd.slide015';
	Images[16] = Texture2D'phd.slide016';
	Images[17] = Texture2D'phd.slide017';
	Images[18] = Texture2D'phd.slide018';
	Images[19] = Texture2D'phd.slide019';
	Images[20] = Texture2D'phd.slide020';
	Images[21] = Texture2D'phd.slide021';
	Images[22] = Texture2D'phd.slide022';
	Images[23] = Texture2D'phd.Trans.slide023';
	Images[24] = Texture2D'phd.Trans.slide024';
	Images[25] = Texture2D'phd.Trans.slide025';
	Images[26] = Texture2D'phd.Trans.slide026';
	Images[27] = Texture2D'phd.slide027';
	Images[28] = Texture2D'phd.slide028';
	Images[29] = Texture2D'phd.slide029';
	Images[30] = Texture2D'phd.slide030';	
	Images[31] = Texture2D'phd.Trans.slide031';	
	Images[32] = Texture2D'phd.slide032';	
	Images[33] = Texture2D'phd.slide033';	
	Images[34] = Texture2D'phd.slide034';	
	Images[35] = Texture2D'phd.slide035';	
	Images[36] = Texture2D'phd.slide036';	
	Images[37] = Texture2D'phd.slide037';	
	Images[38] = Texture2D'phd.slide038';	
	Images[39] = Texture2D'phd.slide039';	
	Images[40] = Texture2D'phd.slide040';		
	Images[41] = Texture2D'phd.slide041';	
	Images[42] = Texture2D'phd.slide042';	
	Images[43] = Texture2D'phd.slide043';	
	Images[44] = Texture2D'phd.slide044';	
	Images[45] = Texture2D'phd.slide045';	
	Images[46] = Texture2D'phd.slide046';	
	Images[47] = Texture2D'phd.slide047';	
	Images[48] = Texture2D'phd.slide048';	
	Images[49] = Texture2D'phd.slide049';	
	Images[50] = Texture2D'phd.slide050';		
	Images[51] = Texture2D'phd.slide051';	
	Images[52] = Texture2D'phd.slide052';		
	Images[53] = Texture2D'phd.Trans.slide053';	
	Images[54] = Texture2D'phd.Trans.slide054';	
	Images[55] = Texture2D'phd.slide055';	
	Images[56] = Texture2D'phd.slide056';	
	Images[57] = Texture2D'phd.slide057';	
	Images[58] = Texture2D'phd.slide058';	
	Images[59] = Texture2D'phd.slide059';	
	Images[60] = Texture2D'phd.slide060';
	Images[61] = Texture2D'phd.Trans.slide061';	
	Images[62] = Texture2D'phd.slide062';	
	Images[63] = Texture2D'phd.slide063';	
	Images[64] = Texture2D'phd.slide064';	
	Images[65] = Texture2D'phd.slide065';	
	Images[66] = Texture2D'phd.slide066';	
	Images[67] = Texture2D'phd.slide067';	
	Images[68] = Texture2D'phd.slide068';	
	Images[69] = Texture2D'phd.slide069';	
	Images[70] = Texture2D'phd.slide070';
	Images[71] = Texture2D'phd.slide071';	
	Images[72] = Texture2D'phd.slide072';	
	Images[73] = Texture2D'phd.slide073';	
	Images[74] = Texture2D'phd.slide074';	
	Images[75] = Texture2D'phd.slide075';	
	Images[76] = Texture2D'phd.slide076';	
	Images[77] = Texture2D'phd.slide077';	
	Images[78] = Texture2D'phd.slide078';	
	Images[79] = Texture2D'phd.slide079';	
	Images[80] = Texture2D'phd.slide080';
	Images[81] = Texture2D'phd.slide081';	
	Images[82] = Texture2D'phd.slide082';	
	Images[83] = Texture2D'phd.slide083';	
	Images[84] = Texture2D'phd.slide084';	
	Images[85] = Texture2D'phd.slide085';	
	Images[86] = Texture2D'phd.slide086';	
	Images[87] = Texture2D'phd.slide087';	
	Images[88] = Texture2D'phd.slide088';	
	Images[89] = Texture2D'phd.slide089';	
	Images[90] = Texture2D'phd.slide090';
	Images[91] = Texture2D'phd.Trans.slide091';	
	Images[92] = Texture2D'phd.slide092';	
	Images[93] = Texture2D'phd.slide093';	
	Images[94] = Texture2D'phd.slide094';	
	Images[95] = Texture2D'phd.slide095';	
	Images[96] = Texture2D'phd.slide096';	
	Images[97] = Texture2D'phd.slide097';	
	Images[98] = Texture2D'phd.slide098';	
	Images[99] = Texture2D'phd.slide099';	
	Images[100] = Texture2D'phd.slide100';
	Images[101] = Texture2D'phd.slide101';	
	Images[102] = Texture2D'phd.slide102';	
	Images[103] = Texture2D'phd.slide103';	
	Images[104] = Texture2D'phd.slide104';	
	Images[105] = Texture2D'phd.slide105';	
	Images[106] = Texture2D'phd.slide106';	
	Images[107] = Texture2D'phd.slide107';	
	Images[108] = Texture2D'phd.slide108';	
	Images[109] = Texture2D'phd.slide109';	
	Images[110] = Texture2D'phd.slide110';
	Images[111] = Texture2D'phd.slide111';	
	Images[112] = Texture2D'phd.slide112';	
	Images[113] = Texture2D'phd.slide113';	
	Images[114] = Texture2D'phd.slide114';	
	Images[115] = Texture2D'phd.slide115';	
	Images[116] = Texture2D'phd.slide116';	
	Images[117] = Texture2D'phd.slide117';	
	Images[118] = Texture2D'phd.slide118';	
	Images[119] = Texture2D'phd.slide119';	
	Images[120] = Texture2D'phd.slide120';
	Images[121] = Texture2D'phd.slide121';
	Images[122] = Texture2D'phd.slide122';
	Images[123] = Texture2D'phd.slide123';
	Images[124] = Texture2D'phd.slide124';
	Images[125] = Texture2D'phd.slide125';
	Images[126] = Texture2D'phd.slide126';
	Images[127] = Texture2D'phd.slide127';
	Images[128] = Texture2D'phd.slide128';
	Images[129] = Texture2D'phd.slide129';
	Images[130] = Texture2D'phd.slide130';	
	Images[131] = Texture2D'phd.slide131';	
	Images[132] = Texture2D'phd.slide132';	
	Images[133] = Texture2D'phd.slide133';	
	Images[134] = Texture2D'phd.slide134';	
	Images[135] = Texture2D'phd.slide135';	
	Images[136] = Texture2D'phd.slide136';	
	Images[137] = Texture2D'phd.slide137';	
	Images[138] = Texture2D'phd.slide138';	
	Images[139] = Texture2D'phd.slide139';	
	Images[140] = Texture2D'phd.slide140';		
	Images[141] = Texture2D'phd.slide141';	
	Images[142] = Texture2D'phd.slide142';	
	Images[143] = Texture2D'phd.slide143';	
	Images[144] = Texture2D'phd.slide144';	
	Images[145] = Texture2D'phd.slide145';	
	Images[146] = Texture2D'phd.slide146';	
	Images[147] = Texture2D'phd.slide147';	
	Images[148] = Texture2D'phd.slide148';	
	Images[149] = Texture2D'phd.slide149';	
	Images[150] = Texture2D'phd.slide150';		
	Images[151] = Texture2D'phd.slide151';	
	Images[152] = Texture2D'phd.slide152';	
	Images[153] = Texture2D'phd.slide153';	
	Images[154] = Texture2D'phd.slide154';	
	Images[155] = Texture2D'phd.slide155';	
	Images[156] = Texture2D'phd.slide156';	
	Images[157] = Texture2D'phd.slide157';	
	Images[158] = Texture2D'phd.slide158';	
	Images[159] = Texture2D'phd.slide159';		
	Images[160] = Texture2D'phd.slide160';		
	Images[161] = Texture2D'phd.slide161';		
	Images[162] = Texture2D'phd.slide162';		
	Images[163] = Texture2D'phd.slide163';		
	Images[164] = Texture2D'phd.slide164';		
	Images[165] = Texture2D'phd.slide165';		
	Images[166] = Texture2D'phd.slide166';		
	Images[167] = Texture2D'phd.slide167';		
	Images[168] = Texture2D'phd.slide168';		
	Images[169] = Texture2D'phd.slide169';		
	Images[170] = Texture2D'phd.slide170';		
	Images[171] = Texture2D'phd.slide171';	

    Images[172] = Texture2D'phd.slide155a';
    Images[173] = Texture2D'phd.slide156a';
    Images[174] = Texture2D'phd.slide156b';
    Images[175] = Texture2D'phd.slide156c';
    Images[176] = Texture2D'phd.slide156d';
	
	Images[177] = Texture2D'phd.slide155aa';
	Images[178] = Texture2D'phd.slide155ab';
	Images[179] = Texture2D'phd.slide155ac';
	Images[180] = Texture2D'phd.slide155ad';
	Images[181] = Texture2D'phd.slide155ae';
	Images[182] = Texture2D'phd.slide155af';
	Images[183] = Texture2D'phd.slide155ag';
	Images[184] = Texture2D'phd.slide155ah';
	Images[185] = Texture2D'phd.slide155ai';

	Images[186] = Texture2D'phd.slide172';

	
	// Test see-throuch images
//	Images[160] = Texture2D'udkosc.defense.overview_37'
//	Images[161] = Texture2D'udkosc.defense.section_mvw'
//	Images[162] = Texture2D'udkosc.defense.section_blank'	

/*	
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
*/
	

	/*
	// GDC IMAGES
	Images[21] = Texture2D'udkosc.gdc2014.backgrounds.gdc2014_titlescreen_background'
	Images[22] = Texture2D'udkosc.gdc2014.backgrounds.gdc2014_titlescreen'
	Images[23] = Texture2D'udkosc.gdc2014.backgrounds.gdc2014_headerbar'
	Images[24] = Texture2D'udkosc.presentation.valkordia-grey'
	
	Images[25] = Texture2D'udkosc.gdc.gdc2014_001'
	Images[26] = Texture2D'udkosc.gdc.gdc2014_002'
	Images[27] = Texture2D'udkosc.gdc.gdc2014_003'
	Images[28] = Texture2D'udkosc.gdc.gdc2014_004'
	Images[29] = Texture2D'udkosc.gdc.gdc2014_005'
	Images[30] = Texture2D'udkosc.gdc.gdc2014_006'
	Images[31] = Texture2D'udkosc.gdc.gdc2014_007'
	Images[32] = Texture2D'udkosc.gdc.gdc2014_008'
	Images[33] = Texture2D'udkosc.gdc.gdc2014_009'
	Images[34] = Texture2D'udkosc.gdc.gdc2014_010'
	Images[35] = Texture2D'udkosc.gdc.gdc2014_011'
	Images[36] = Texture2D'udkosc.gdc.gdc2014_012'
	Images[37] = Texture2D'udkosc.gdc.gdc2014_013'
	Images[38] = Texture2D'udkosc.gdc.gdc2014_014'
	Images[39] = Texture2D'udkosc.gdc.gdc2014_015'
	Images[40] = Texture2D'udkosc.gdc.gdc2014_016'
	Images[41] = Texture2D'udkosc.gdc.gdc2014_017'
	Images[42] = Texture2D'udkosc.gdc.gdc2014_018'
	Images[43] = Texture2D'udkosc.gdc.gdc2014_019'
	Images[44] = Texture2D'udkosc.gdc.gdc2014_020'
	Images[45] = Texture2D'udkosc.gdc.gdc2014_021'
	Images[46] = Texture2D'udkosc.gdc.gdc2014_022'
	Images[47] = Texture2D'udkosc.gdc.gdc2014_023'
	Images[48] = Texture2D'udkosc.gdc.gdc2014_024'
	Images[49] = Texture2D'udkosc.gdc.gdc2014_025'
	Images[50] = Texture2D'udkosc.gdc.gdc2014_026'
	Images[51] = Texture2D'udkosc.gdc.gdc2014_027'
	Images[52] = Texture2D'udkosc.gdc.gdc2014_028'
	Images[53] = Texture2D'udkosc.gdc.gdc2014_029'	
	Images[54] = Texture2D'udkosc.gdc.gdc2014_030'
	Images[55] = Texture2D'udkosc.gdc.gdc2014_031'
	Images[56] = Texture2D'udkosc.gdc.gdc2014_032'
	Images[57] = Texture2D'udkosc.gdc.gdc2014_033'
	Images[58] = Texture2D'udkosc.gdc.gdc2014_034'
	Images[59] = Texture2D'udkosc.gdc.gdc2014_035'
	Images[60] = Texture2D'udkosc.gdc.gdc2014_036'
	Images[61] = Texture2D'udkosc.gdc.gdc2014_037'
	Images[62] = Texture2D'udkosc.gdc.gdc2014_038'
	Images[63] = Texture2D'udkosc.gdc.gdc2014_039'
	Images[64] = Texture2D'udkosc.gdc.gdc2014_040'	
	Images[65] = Texture2D'udkosc.gdc.gdc2014_041'
	Images[66] = Texture2D'udkosc.gdc.gdc2014_042'
	Images[67] = Texture2D'udkosc.gdc.gdc2014_043'
	Images[68] = Texture2D'udkosc.gdc.gdc2014_044'
	Images[69] = Texture2D'udkosc.gdc.gdc2014_045'
	Images[70] = Texture2D'udkosc.gdc.gdc2014_046'
	Images[71] = Texture2D'udkosc.gdc.gdc2014_047'
	Images[72] = Texture2D'udkosc.gdc.gdc2014_048'
	Images[73] = Texture2D'udkosc.gdc.gdc2014_049'
	Images[74] = Texture2D'udkosc.gdc.gdc2014_050'
	Images[75] = Texture2D'udkosc.gdc.gdc2014_051'
	Images[76] = Texture2D'udkosc.gdc.gdc2014_052'
	Images[77] = Texture2D'udkosc.gdc.gdc2014_053'
	Images[78] = Texture2D'udkosc.gdc.gdc2014_054'
	Images[79] = Texture2D'udkosc.gdc.gdc2014_055'
	Images[80] = Texture2D'udkosc.gdc.gdc2014_056'
	Images[81] = Texture2D'udkosc.gdc.gdc2014_057'
	Images[82] = Texture2D'udkosc.gdc.gdc2014_058'
	Images[83] = Texture2D'udkosc.gdc.gdc2014_059'
	Images[84] = Texture2D'udkosc.gdc.gdc2014_060'
	Images[85] = Texture2D'udkosc.gdc.gdc2014_061'
	Images[86] = Texture2D'udkosc.gdc.gdc2014_062'
	Images[87] = Texture2D'udkosc.gdc.gdc2014_063'
	Images[88] = Texture2D'udkosc.gdc.gdc2014_064'
	Images[89] = Texture2D'udkosc.gdc.gdc2014_065'
	Images[90] = Texture2D'udkosc.gdc.gdc2014_066'
	Images[91] = Texture2D'udkosc.gdc.gdc2014_067'
	Images[92] = Texture2D'udkosc.gdc.gdc2014_068'
	Images[93] = Texture2D'udkosc.gdc.gdc2014_069'
	Images[94] = Texture2D'udkosc.gdc.gdc2014_070'
	Images[95] = Texture2D'udkosc.gdc.gdc2014_071'
	Images[96] = Texture2D'udkosc.gdc.gdc2014_072'
	Images[97] = Texture2D'udkosc.gdc.gdc2014_073'
	Images[98] = Texture2D'udkosc.gdc.gdc2014_074'
	Images[99] = Texture2D'udkosc.gdc.gdc2014_075'
	Images[100] = Texture2D'udkosc.gdc.gdc2014_076'
	Images[101] = Texture2D'udkosc.gdc.gdc2014_077'
	Images[102] = Texture2D'udkosc.gdc.gdc2014_078'
	Images[103] = Texture2D'udkosc.gdc.gdc2014_079'
	Images[104] = Texture2D'udkosc.gdc.gdc2014_080'
	Images[105] = Texture2D'udkosc.gdc.gdc2014_081'
	Images[106] = Texture2D'udkosc.gdc.gdc2014_082'
	Images[107] = Texture2D'udkosc.gdc.gdc2014_083'
	Images[108] = Texture2D'udkosc.gdc.gdc2014_084'
	Images[109] = Texture2D'udkosc.gdc.gdc2014_085'
	Images[110] = Texture2D'udkosc.gdc.gdc2014_086'
	Images[111] = Texture2D'udkosc.gdc.gdc2014_087'
	Images[112] = Texture2D'udkosc.gdc.gdc2014_088'
	Images[113] = Texture2D'udkosc.gdc.gdc2014_089'
	Images[114] = Texture2D'udkosc.gdc.gdc2014_090'
	Images[115] = Texture2D'udkosc.gdc.gdc2014_091'
	Images[116] = Texture2D'udkosc.gdc.gdc2014_092'
	Images[117] = Texture2D'udkosc.gdc.gdc2014_093'
	Images[118] = Texture2D'udkosc.defense.door_12'
	

*/	
	/*
	Images[25] = Texture2D'udkosc.gdc2014.backgrounds.gdc2014_overview_1'
	Images[26] = Texture2D'udkosc.gdc2014.backgrounds.gdc2014_overview_2'
	Images[27] = Texture2D'udkosc.gdc2014.backgrounds.gdc2014_overview_3'
	
	Images[28] = Texture2D'udkosc.gdc2014.backgrounds.gdc2014_farnell_quote'
	Images[29] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original013'
	Images[30] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original014'
	Images[31] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original015'
	Images[32] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original016'
	Images[33] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original017'
	Images[34] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original018'
	Images[35] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original019'
	Images[36] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original020'
	Images[37] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original021'
	Images[38] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original023'
	Images[39] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original024'
	Images[40] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original025'
	Images[41] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original026'
	Images[42] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original027'
	Images[43] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original028'
	Images[44] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original029'
	Images[45] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original030'
	Images[46] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original031'
	Images[47] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original032'
	Images[48] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original033'
	Images[49] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original034'
	Images[50] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original035'
	Images[51] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original036'
	Images[52] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original037'
	Images[53] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original038'
	Images[54] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original039'
	Images[55] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original040'
	Images[56] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original041'
	Images[57] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original042'
	Images[58] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original043'
	Images[59] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original044'
	Images[60] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original046'
	Images[61] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original047'
	Images[62] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original048'
	Images[63] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original049'
	Images[64] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original053'
	Images[65] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original054'
	Images[66] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original057'
	Images[67] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original061'
	Images[68] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original062'
	Images[69] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original063'
	Images[70] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original065'
	Images[71] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original066'
	Images[72] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original067'
	Images[73] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original068'
	Images[74] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original070'
	Images[75] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original071'
	Images[76] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original072'
	Images[77] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original073'
	Images[78] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original074'
	Images[79] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original075'
	Images[80] = Texture2D'udkosc.gdc2014.backgrounds.GDC14_hamilton_original082'
*/
	img_valkordia_grey_TEX=Texture2D'udkosc.presentation.valkordia-grey'
	
	debugSlideImgX = -1.0
	debugSlideImgY = -1.0
}
