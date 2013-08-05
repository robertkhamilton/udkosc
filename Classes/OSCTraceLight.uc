class OSCTraceLight extends PointLightMovable;

function turnOn() {
	LightComponent.SetEnabled(true);
}

function turnOff() {

	LightComponent.SetEnabled(false);
}

function setBrightness(float f) {
	LightComponent.SetLightProperties(f);
        LightComponent.UpdateColorAndBrightness();
}

function setColor(byte ir, byte ig, byte ib, byte ia) {
	local color c;
	
	c.R = ir;
	c.G = ig;
	c.B = ib;
	c.A = ia;

	LightComponent.SetLightProperties(,c); 
        LightComponent.UpdateColorAndBrightness();
}

//default 1024.0
function setRadius(float r) {
	PointLightComponent(LightComponent).Radius = r;
}

//default 2.0
function setFallOffExponent(float e) {
	PointLightComponent(LightComponent).FalloffExponent = e;
}

//default 2.0
function setShadowFalloffExponent(float e) {
	PointLightComponent(LightComponent).ShadowFalloffExponent = e;
}

//default 1.1
function setShadowRadiusMultiplier(float f) {
	PointLightComponent(LightComponent).ShadowRadiusMultiplier = f;
}

function setCastDynamicShadows(bool b) {
	LightComponent.CastDynamicShadows = b;
}

//below is showing how to move the light
//every light you spawn will gradually rise
//if you uncomment this function
//use similar code where/how you actually want
//to move the light
/*
function tick(Float DT) {
	super.tick(DT);
	move(vect(0, 0, 1));
}
*/

DefaultProperties
{
        bNoDelete = false
	
	PointLightComponent(LightComponent).Radius = 10
	
        //for use with actor.move()
        bCollideActors = false
	bCollideWorld = false
}