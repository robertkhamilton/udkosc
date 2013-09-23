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

struct Layout
{
	var float x;
	var float y;
	var float width;
	var float height;		// 0.0 - 1.0 * current resolution
	var int bgId;			
	var int colorR;
	var int colorG;
	var int colorB;
	var int colorA;	
	var int textColorR;
	var int textColorG;
	var int textColorB;
	var int textColorA;	
};

struct Slide
{
	var int layout;	
	var String title;
	var String text;
	var float textX;
	var float textY;	
	var int imgId;			// default -1 means no img	
	var float imgX;
	var float imgY;
	var float imgScale;
};

var config array<Slide> Slides;
var config array<Layout> Layouts;

var Texture2D d3_graph_1_TEX;

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
	slideStartX = Layouts[Slides[slideNumber].layout].x * viewportWidth;
	
	// Calc slide starting y...
	slideStartY = Layouts[Slides[slideNumber].layout].y * viewportHeight;
		
	// Calc slide width...
	slideWidth = Layouts[Slides[slideNumber].layout].width * viewportWidth;
	
	//Calc slide height...
	slideHeight = Layouts[Slides[slideNumber].layout].height * viewportHeight;
	
	// Set slide color...
	slideColorR = Layouts[Slides[slideNumber].layout].colorR;
	slideColorG = Layouts[Slides[slideNumber].layout].colorG;
	slideColorB = Layouts[Slides[slideNumber].layout].colorB;
	slideColorA = Layouts[Slides[slideNumber].layout].colorA;
		
	// Set slide Text Font...
    //currentFont = "UI_Fonts_Final.HUD.MF_Medium";
	//currentFont = "UI_Fonts.MultiFonts.MF_HudLarge";
	//currentFont = "UI_Fonts.MultiFonts.MF_HudMedium";
	//currentFont = "UI_Fonts.MultiFonts.MF_HudSmall";
	
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
	
	// draw slide's image	
	slideImgId = Slides[slideNumber].ImgId;
	slideImgX = Slides[slideNumber].imgX * viewportWidth;
	slideImgY = Slides[slideNumber].imgY * viewportHeight;
	slideImgScale = Slides[slideNumber].imgScale;
}

exec function drawSlides(bool val)
{
	bDrawSlides=val;
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
		Canvas.Font = class'Engine'.static.GetLargeFont();
		Canvas.setDrawColor(slideTextColorR,slideTextColorG,slideTextColorB,slideTextColorA);
		Canvas.SetPos(slideStartX + currentTextX, slideStartY + currentTextY);
	  	Canvas.DrawText(currentTitle);
		Canvas.DrawText("");
	  	Canvas.DrawText(currentText);
	  		  
	  	// draw image...
		if(slideImgId > -1)
		{
		  Canvas.SetPos(slideStartX + slideImgX, slideStartY + slideImgY);
	  	  Canvas.SetDrawColor(255,255,255,255);
	  	  Canvas.DrawTexture(d3_graph_1_TEX, slideImgScale);
		}
/*	
	  // Set Cell Background...
	  Canvas.SetDrawColor(slideColorR,slideColorG,slideColorB,slideColorA);
	  Canvas.SetPos(0,0);
	  Canvas.setPos(posx, posy);
	  Canvas.DrawRect(width, height);
	
	  // Set Text...
	  Canvas.Font = class'Engine'.static.GetMediumFont();
	  Canvas.SetPos(currentX + posx, currentY + posy);
	  Canvas.setDrawColor(255,25,25,80);
	  Canvas.DrawText(currentTitle);
	  Canvas.DrawText(currentText);
	
	  // Set Image...
	  Canvas.SetPos(posx,posy);
	  Canvas.SetDrawColor(255,255,255,255);
	  Canvas.DrawTexture(d3_graph_1_TEX, 0.3);
*/

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
	
	d3_graph_1_TEX=Texture2D'udkosc.presentation.d3_wing_zoom_composite_small'
	
}
