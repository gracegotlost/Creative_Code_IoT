#include "exampleApp.h"


//------------------------------------------------------------------------------
void exampleApp::setup()
{
	ofSetFrameRate(24);
	
	// this load font loads the non-full character set
	// (ie ASCII 33-128), at size "32"
	
	std::string url = "http://www.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=6f33a9ea5cf089636d99a302b34bbfee&format=json&nojsoncallback=1";
    
    //------------------------------------------------------
    //Always get this error if I changed to other url
    /*std::string url = "https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=d2b1269787876896911080f38e494810&format=json&nojsoncallback=1&auth_token=72157644196005694-9464c74c2cc3ac8d&api_sig=e451e8512c9290e37368fb0b81607644";
   
    [ error ] ofxJSONElement::openRemote: Unable to parse https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=d2b1269787876896911080f38e494810&format=json&nojsoncallback=1&auth_token=72157644196005694-9464c74c2cc3ac8d&api_sig=e451e8512c9290e37368fb0b81607644: * Line 1, Column 16377
    Syntax error: value, object or array expected.
    */
    //------------------------------------------------------
    
	if (!response.open(url)) {
		cout  << "Failed to parse JSON\n" << endl;
	}
    
    font.loadFont("pixelated.ttf", 20, true, true, true);
    // Change blockImage to 1 for precise image
    blockImageX = 5;
    blockImageY = 5;
	
}

//--------------------------------------------------------------
void exampleApp::update(){
    
    if(keyPress){
        int count = 0;
        
        for (int i = 0; i < images[0].width; i += blockImageX){
            for (int j = 0; j < images[0].height; j += blockImageY){
                
                particles[count].resetForce();
                
                
                particles[count].addAttractionForce(i, j, 1000, 0.1);
                particles[count].addRepulsionForce(mouseX, mouseY, 500, 0.2);
                
                particles[count].addDampingForce();
                particles[count].update();
                
                count++;
                
            }
        }
    }
    
    
}

//------------------------------------------------------------------------------
void exampleApp::draw()
{
	ofBackground(0);
    
    // Display Image
    /*
    if(keyPress){
        // Origin Image
        ofSetColor(255);
        images[0].draw(0, (ofGetWindowHeight() - images[0].height)/2);
        
        // Pixalate Image
        ofPushMatrix();
        {
            for (int i = 0; i < images[0].width; i += blockImageX) {
                for (int j = 0; j < images[0].height; j += blockImageY) {
                    ofColor c = images[0].getPixelsRef().getColor(i, j);
                    float brightness = c.getBrightness();
                    //ofSetColor(brightness);
                    ofSetColor(c);
                    //ofRect(i + i/blockImageX*2, j + j/blockImageY*2 + (ofGetWindowHeight() - (images[0].height + images[0].height/5) )/2, blockImageX, blockImageY);
                    ofRect(i + 500, j + (ofGetWindowHeight() - images[0].height)/2, blockImageX, blockImageY);
                }
            }
        }
        ofPopMatrix();
    }
    */
    
    // Particle Image
    if (keyPress) {
        for (int i = 0; i < particles.size(); i++){
            particles[i].draw();
        }
    }
    
    else {
        string s = "PRESS ANY KEY TO START";
        font.drawString(s, 200, 2 * ofGetWindowHeight()/3);
    }
    
    
}

//--------------------------------------------------------------
void exampleApp::keyPressed(int key){
    
    keyPress = true;
    
    // Read Image
    randomImage = int(ofRandom(0, response["photos"]["photo"].size()));
	
    
    int farm = response["photos"]["photo"][randomImage]["farm"].asInt();
    std::string id = response["photos"]["photo"][randomImage]["id"].asString();
    std::string secret = response["photos"]["photo"][randomImage]["secret"].asString();
    std::string server = response["photos"]["photo"][randomImage]["server"].asString();
    std::string urlImage = "http://farm"+ofToString(farm)+".static.flickr.com/"+server+"/"+id+"_"+secret+".jpg";
    
    ofImage img;
    img.loadImage(urlImage);
    if(images.size() != 0)images.erase(images.begin());
    images.push_back( img );
    //cout << urlImage << endl;
    
    // Particle Image
    particles.clear();
    for (int i = 0; i < images[0].width; i += blockImageX){
        for (int j = 0; j < images[0].height; j += blockImageY){
            
            ofColor c = images[0].getPixelsRef().getColor(i, j);
            // Pass position, velocity, color, size, height into Particle Init
            particle myParticle;
            myParticle.setInitialCondition(i, j, 0, 0, c, blockImageX, blockImageY, images[0].height);
            // Particle with diversity
            //myParticle.damping = ofRandom(0.01, 0.05);
            particles.push_back(myParticle);
        }
    }
    
    
}
