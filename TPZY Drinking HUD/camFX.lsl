integer on;
integer code =33;
integer unix = 0;
float p =0.5;
integer c=0;
float fade = 0.0;

integer blackoutLink = 2;

default_cam()
{
    llSetTimerEvent(0.0);
    llClearCameraParams(); 
    llSetCameraParams([CAMERA_ACTIVE, 0]);
}

camRandomFrame()
{
      vector camPos = llGetPos() + <llFrand(2),llFrand(2),llFrand(2)> ;
      vector camFocus = llGetPos()+ <llFrand(2),llFrand(2),llFrand(2)> ;
        llClearCameraParams(); // reset camera to default
        llSetCameraParams([
            CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
            CAMERA_FOCUS, camFocus, // region relative position
            CAMERA_FOCUS_LOCKED, TRUE, // (TRUE or FALSE)
            CAMERA_POSITION, camPos, // region relative position
            CAMERA_POSITION_LOCKED, TRUE // (TRUE or FALSE)
        ]);
}

camSpin()
{
       llSetCameraParams([
        CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
        CAMERA_BEHINDNESS_ANGLE, 180.0, // (0 to 180) degrees
        CAMERA_BEHINDNESS_LAG, 0.5, // (0 to 3) seconds
        //CAMERA_DISTANCE, 10.0, // ( 0.5 to 10) meters
        //CAMERA_FOCUS, <0.0,0.0,5.0>, // region relative position
        CAMERA_FOCUS_LAG, 0.05 , // (0 to 3) seconds
        CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
        CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
        CAMERA_PITCH, 30.0, // (-45 to 80) degrees
        //CAMERA_POSITION, <0.0,0.0,0.0>, // region relative position
        CAMERA_POSITION_LAG, 0.0, // (0 to 3) seconds
        CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
        CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
        CAMERA_FOCUS_OFFSET, <0.0,0.0,0.0> // <-10,-10,-10> to <10,10,10> meters
    ]);
 
    float i;
    vector camera_position;
    for (i=0; i< 20*TWO_PI; i+=.05)
    {
        camera_position = llGetPos() + <0.0, 4.0, 0.0> * llEuler2Rot(<0.0, 0.0, i>);
        llSetCameraParams([CAMERA_POSITION, camera_position]);
    }
    
    if (llGetPermissions() & (PERMISSION_CONTROL_CAMERA))
    {
        llClearCameraParams();
    }
}

//vape lag cam
lookAtMe( integer perms )
{
        float lag = llFrand(3.0);
        float dist = llFrand(5.0);
        float angle = llFrand(20);
        llClearCameraParams(); // reset camera to default
        llSetCameraParams([
            CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
            CAMERA_BEHINDNESS_ANGLE, angle, // (0 to 180) degrees
            CAMERA_BEHINDNESS_LAG, 1.5, // (0 to 3) seconds
           // CAMERA_DISTANCE, dist, // ( 0.5 to 10) meters
          //CAMERA_FOCUS, <0,0,5>, // region relative position
            CAMERA_FOCUS_LAG, lag , // (0 to 3) seconds
         //   CAMERA_FOCUS_LOCKED, TRUE, // (TRUE or FALSE)
         //   CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
         //   CAMERA_PITCH, 35.0, // (-45 to 80) degrees
         // CAMERA_POSITION, <0,0,1>, // region relative position
            CAMERA_POSITION_LAG, 1.5 // (0 to 3) seconds
          //  CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
         //   CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
          //  CAMERA_FOCUS_OFFSET, <1.2, 0.0, 0.0> // <-10,-10,-10> to <10,10,10> meters
        ]);
}

default
{
    state_entry()
    {
      if(llGetAttached() > 0)
      {   
        llRequestPermissions(llGetOwner(),(PERMISSION_CONTROL_CAMERA));
        c=0;
        default_cam();
      }
    }
     changed(integer mask)
    {
        if(mask & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
    
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_CONTROL_CAMERA)
        {
            if(c==1)
            {
                camSpin();
            }
            if(c==2)
            {
                lookAtMe(1);
            }
            if(c==3)
            {
                 llSetTimerEvent(2.0);
                 camRandomFrame();
            }
            else if (c==0)
            {
                default_cam();
            }
        }
    }
    
    
    timer()
    {
        //camRandomFrame();
        if(c ==0)
        {
            llSetTimerEvent(0.0);
        }
        if(c==4)
        {
            fade+=0.1;
            if(fade>=1.0){ fade=1.0; c=0; llSetTimerEvent(0.0); 
            llMessageLinked(LINK_SET,0,"send_home","");}
            llSetLinkAlpha( blackoutLink, fade, ALL_SIDES );
        }
        if(c==5)
        {
            fade-=0.1;
            if(fade<=0.05)
            { 
                fade=0.05; 
                c=0; 
                llSetTimerEvent(0.0); 
                llSetLinkPrimitiveParamsFast(blackoutLink, [PRIM_SIZE, <0.01000, 0.1, 0.1>]);
            }
            llSetLinkAlpha( blackoutLink, fade, ALL_SIDES );
        }
    }
    
    attach(key attachedAgent)
    {
        if (attachedAgent != NULL_KEY)
        {
            llResetScript();
        }
    }
    
    
    link_message(integer sender_num, integer num, string msg, key id)
    {
        if(num == code)
        {
            //llOwnerSay("LINK "+(string)num+" "+msg);
            if(msg =="spinOn")
            {
                c=1;
                llRequestPermissions(llGetOwner(),(PERMISSION_CONTROL_CAMERA));
            }
            if(msg =="lagOn")
            {
                c=2;
                llRequestPermissions(llGetOwner(),(PERMISSION_CONTROL_CAMERA));
            }
            else if(msg == "randomFrameOn")
            {
                c=3;
                llRequestPermissions(llGetOwner(),(PERMISSION_CONTROL_CAMERA));
            }
            else if(msg == "camOff")
            {
                c=0;
                llRequestPermissions(llGetOwner(),(PERMISSION_CONTROL_CAMERA));
            }
            else if(msg == "blkOut")
            {
                c=4;
                fade = 0.0;
                llSetTimerEvent(0.1);
                llSetLinkPrimitiveParamsFast(blackoutLink, [PRIM_SIZE, <0.01000, 5.0, 2.0>]);
            }
            else if(msg == "blkOff")
            {
                c=5;
                llSetTimerEvent(0.1);
            }
        }
    }
}    
