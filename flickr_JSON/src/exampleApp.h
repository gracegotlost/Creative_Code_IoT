#pragma once


#include "ofMain.h"
#include "ofxJSONElement.h"
#include "particle.h"


class exampleApp : public ofBaseApp {
public:
    void setup();
    void draw();
    void update();
    void keyPressed(int key);
    
    ofxJSONElement  response;
    std::vector<ofImage> images;
    
    ofTrueTypeFont font;
    bool keyPress = false;
    int randomImage;
    int blockImageX;
    int blockImageY;
    
    vector<particle> particles;
};
