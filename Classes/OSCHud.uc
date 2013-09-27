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
	
var float tempVar1, tempVar2, tempVar3;

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
	var int Footer;			// default -1 means no Footer
};

struct Slide
{
	var int layout;	
	var String title;
	var float titleScale;
	var String text;
	var float textX;
	var float textY;
	var float textScale;	
	var int imgId;			// default -1 means no img	
	var float imgX;
	var float imgY;
	var float imgScale;
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

var config array<Slide> Slides;
var config array<Layout> Layouts;
var config array<Footer> Footers;

var Texture2D d3_graph_1_TEX, img_valkordia_grey_TEX;

exec function getCurrentResolution()
{
	`log("Current Resolution: "$self.Canvas.SizeX$", "$Canvas.SizeY);
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	slideCount=Slides.Length;
}

exec function setCurrentSlide(int var)
{
	slideNumber = var;
	
//	currentTitle = Slides[var].title;
//	currentText = Slides[var].text;
//	currentX = Slides[slideNumber].x;
//	currentY = Slides[slideNumber].y;
}

exec function nextSlide()
{
	slideNumber = (slideNumber + 1) % slideCount;	
//	currentTitle = Slides[slideNumber].title;
//	currentText = Slides[slideNumber].text;
//	currentX = Slides[slideNumber].x;
//	currentY = Slides[slideNumber].y;
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
	currentText = Slides[slideNumber].text;
	currentTextX = Slides[slideNumber].textX * viewportWidth;
	currentTextY = Slides[slideNumber].textY * viewportHeight;

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
}

exec function drawSlides(bool val)
{
	bDrawSlides=val;
}

exec function toggleSlides()
{
	bDrawSlides = !bDrawSlides;
}

function DrawGameHud()
{
	if(bDrawSlides)
	{
//	`log("Current Resolution: "$Canvas.SizeX$", "$Canvas.SizeY);
	
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
	
		// draw slide's text...
		//Canvas.Font = class'Engine'.static.GetLargeFont();
		//Canvas.Font = fontArial;
		//Canvas.Font = fontArialMedium;
		Canvas.Font = fontSourceSansProMedium;
		
		
		Canvas.setDrawColor(slideTextColorR,slideTextColorG,slideTextColorB,slideTextColorA);
		Canvas.SetPos(slideStartX + currentTextX, slideStartY + currentTextY);
	  	Canvas.DrawText(currentTitle, TRUE, titleScale, titleScale);
	  	Canvas.DrawText(currentText, TRUE, textScale, textScale);
	  		  
	  	// draw image...
		if(slideImgId > -1)
		{
		  Canvas.SetPos(slideStartX + slideImgX, slideStartY + slideImgY);
	  	  Canvas.SetDrawColor(255,255,255,255);
	  	  Canvas.DrawTexture(d3_graph_1_TEX, slideImgScale);
		}
		
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
			  Canvas.DrawTexture(img_valkordia_grey_TEX, footerImgScale);
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

exec function slideDebugVar(float val1, float val2,float val3)
{
	tempVar1 = val1;
	tempVar2 = val2;
	tempVar3 = val3;	
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
	fontSourceSansProSmall = Font'udkosc.Fonts.source_sans_pro_24'
	fontSourceSansProMedium = Font'udkosc.Fonts.source_sans_pro_36'
	fontSourceSansProLarge = Font'udkosc.Fonts.source_sans_pro_48'
	
	footerNumber=-1
	
	tempVar1 = 1.0
	tempVar2 = 1.0
	tempVar3 = 1.0	
	
	d3_graph_1_TEX=Texture2D'udkosc.presentation.d3_wing_zoom_composite_small'
	img_valkordia_grey_TEX=Texture2D'udkosc.presentation.valkordia-grey'
}
