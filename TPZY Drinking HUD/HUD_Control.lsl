/* Drink HUD Script
*  Tracks increasing drunkness while the HUD is worn, resets if removed.
*  Causes camera blurring effects as the wearer gets drunk.
*
*  Requires setTxt script to change numbers on HUD.
*/
float bamt;

// The list below contains all of the data to cause increased vision blur 
// over time as the wearer gets drunk.
// bamt, blurMin, blurMax, blurWaitTime, blurRepeat, blurWobbleTime, camFX
list bamtToCamFx = [
    6.0, 1.0, 0.0, 0.0, 1.0, 1.0, "",
    8.0, 1.0, 3.0, 10.0, 1.0, 10.0, "",
    10.0, 1.0, 3.0, 5.0, 1.0, 5.0, "",
    12.0, 1.0, 3.0, 6.0, 2.0, 2.0, "",
    14.0, 1.0, 4.0, 8.0, 2.0, 6.0, "",
    16.0, 1.0, 4.0, 0.1, 1.0, 5.0, "",
    18.0, 1.0, 4.0, 5.0, 2.0, 4.0, "",
    20.0, 1.0, 2.0, 0.1, 1.5, 0.5, "",
    
    22.0, 2.0, 3.0, 0.1, 1.0, 1.0, "",
    24.0, 2.0, 4.0, 10.0, 1.0, 10.0, "",
    26.0, 2.0, 4.0, 5.0, 1.0, 5.0, "",
    28.0, 2.0, 4.0, 6.0, 2.0, 2.0, "",
    30.0, 2.0, 4.0, 8.0, 2.0, 6.0, "",
    32.0, 2.0, 6.0, 0.1, 1.0, 5.0, "",
    34.0, 2.0, 6.0, 5.0, 2.0, 4.0, "",
    36.0, 2.0, 6.0, 0.1, 1.0, 4.0, "",
    38.0, 2.0, 6.0, 0.1, 1.0, 4.0, "",
    40.0, 2.0, 3.0, 0.1, 1.5, 0.5, "",
    
    42.0, 3.0, 4.0, 0.1, 3.0, 0.5, "",
    44.0, 2.0, 3.0, 10.0, 1.0, 10.0, "",
    46.0, 2.0, 4.0, 5.0, 1.0, 5.0, "",
    48.0, 2.0, 5.0, 6.0, 2.0, 2.0, "",
    40.0, 2.0, 6.0, 8.0, 2.0, 6.0, "",
    52.0, 2.0, 6.0, 0.1, 1.0, 5.0, "",
    54.0, 2.0, 6.0, 5.0, 2.0, 4.0, "",
    56.0, 2.0, 6.0, 0.1, 1.0, 4.0, "",
    58.0, 2.0, 6.0, 0.1, 1.0, 4.0, "",
    60.0, 2.0, 3.0, 0.1, 1.5, 0.5, "",
    
    62.0, 3.0, 4.0, 0.1, 1.0, 10.0, "",
    64.0, 3.0, 5.0, 10.0, 1.0, 10.0, "",
    66.0, 3.0, 5.0, 5.0, 1.0, 5.0, "",
    68.0, 3.0, 5.0, 6.0, 2.0, 2.0, "",
    70.0, 3.0, 6.0, 8.0, 2.0, 6.0, "",
    72.0, 3.0, 6.0, 0.1, 1.0, 5.0, "",
    74.0, 3.0, 7.0, 5.0, 2.0, 4.0, "",
    76.0, 3.0, 7.0, 0.1, 1.0, 4.0, "",
    78.0, 3.0, 7.0, 0.1, 1.0, 4.0, "",
    80.0, 3.0, 4.0, 0.1, 1.5, 0.5, "",
    
    82.0, 4.0, 5.0, 0.1, 1.0, 10.0, "",
    84.0, 4.0, 5.0, 10.0, 1.0, 10.0, "",
    86.0, 4.0, 5.0, 5.0, 1.0, 5.0, "",
    88.0, 4.0, 5.0, 6.0, 2.0, 2.0, "",
    90.0, 4.0, 6.0, 8.0, 2.5, 6.0, "",
    92.0, 4.0, 6.0, 0.1, 1.0, 5.0, "",
    94.0, 4.0, 7.0, 5.0, 2.0, 4.0, "",
    96.0, 4.0, 8.0, 0.1, 1.0, 4.0, "",
    98.0, 4.0, 6.0, 0.1, 1.0, 4.0, "",
    
    100.0, 4.0, 6.0, 0.1, 1.0, 1.0, "blkOut"
];
integer camStride = 7;

string overrideAnimation = "F-Drunk-Dance (+Drink)";

key portrait = TEXTURE_TRANSPARENT;
integer portraitFace = 3;
string textFaces = "2,1";

integer blackoutLink = 2;

integer comChannel = -1;
integer canRLV;
string currentAnimation="";
integer textScramble;

integer Pchannel(string salt){
    string setint = (string)((integer)("0x"+llGetSubString((string)llGetOwner(),-8,-1)) * 
    llStringLength(salt) * llCeil(llLog(llStringLength(salt))));
    return (integer)llGetSubString(setint, 0, 7);
}

update_rlvFx()
{
    
    // bamt, blurMin, blurMax, blurWaitTime, blurRepeat, blurWobbleTime, camFX
    integer i = 0;
    float lastAmt = llList2Float(bamtToCamFx, llGetListLength(bamtToCamFx)-camStride);
    
    while(i<(llGetListLength(bamtToCamFx)+1)-camStride)
    {
        float thisAmt = llList2Float(bamtToCamFx, i);
        float nextAmt = thisAmt+1.0;
        
        if(i+camStride<llGetListLength(bamtToCamFx) )nextAmt = llList2Float(bamtToCamFx, i+camStride);
        if( (bamt>=thisAmt&&bamt<nextAmt) || bamt>lastAmt )
        {
            //llOwnerSay("thisAmt "+(string)thisAmt+"  nextAmt "+(string)nextAmt);
            string rlvFx = (string)llList2Float(bamtToCamFx, i+1) + "," + 
                (string)llList2Float(bamtToCamFx, i+2) + "," +
                (string)llList2Float(bamtToCamFx, i+3) + "," +
                (string)llList2Float(bamtToCamFx, i+4) + "," +
                (string)llList2Float(bamtToCamFx, i+5);
            string camFx = llList2String(bamtToCamFx, i+6);
           // llOwnerSay("bamt is "+(string)bamt+" cam is "+camFx+".");
            if(canRLV) 
            {
                llMessageLinked(LINK_THIS,32, rlvFx, "");
                if(camFx!="") llMessageLinked(LINK_THIS,33,camFx,"");
            }
        }
        i+=camStride;
    }
}

list string2CharList(string str)
{
    integer i;
    integer len = llStringLength(str);
    list ret;
    
    for(i = 0; i < len; i++)
    {
        ret += llGetSubString(str,i,i);
    }
    return ret;
}

string charList2String(list chars)
{
    return (string)chars;
}

string scrambleWordsIn(string str)
{
    list words = llParseString2List(str,[" "],[]);
    
    integer i;
    integer len = llGetListLength(words);
    
    str = "";
    
    for(i = 0; i < len; i++)
    {
        //llSetText((string)i,<0,1,0>,1.0);
        string word = llList2String(words,i);
        integer len = llStringLength(word);
        if(len > 3)
        {
            string toScramble = llGetSubString(word,1,len - 2);
            word = llDeleteSubString(word,1,len - 2);
            
            toScramble = charList2String(llListRandomize(string2CharList(toScramble),1));
            
            word = llInsertString(word,1,toScramble);
            
        }
        str += word + " ";
    } 
    return str;
}

integer isValidFloat(string s) { return (float)(s + "1") != 0.0; }

default{
    state_entry()
    {
        // llMessageLinked(LINK_THIS,0,"reset","");
        llSetLinkPrimitiveParamsFast(blackoutLink, [PRIM_SIZE, <0.01, 0.1, 0.1>]);
        llSetLinkAlpha( blackoutLink, 0.0, ALL_SIDES );
        comChannel = Pchannel("TPZY_Drink");
        if(llGetAttached() > 0)
        {
            llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
            llSetTexture( portrait, portraitFace );
            llMessageLinked( LINK_THIS, -5555, "-1", (key)textFaces );
            llMessageLinked(LINK_THIS, -1, (string)bamt, "");
            llListen( comChannel, "", "", "");
            llListen( comChannel+1, "", llGetOwner(), "");
            llOwnerSay("@versionnew="+(string)comChannel); // Request rlv
            llSetTimerEvent(1.0);
            
            
            
            //llOwnerSay("Operating on Channel "+(string)comChannel);
        }
        else
        {
            //llOwnerSay("Pchannel "+(string)comChannel);
            llOwnerSay("Attach to begin!");
        }
    }
    on_rez(integer n)
    { 
        llResetScript(); 
    }
    
    touch_end(integer n)
    {
        string buttonName = llGetLinkName( llDetectedLinkNumber(0) );
        llWhisper(comChannel, buttonName);
        if(buttonName=="StopButton")
        {
            llMessageLinked(LINK_THIS, -1, (string)bamt, "");
            if(canRLV) llMessageLinked(LINK_THIS, -2, "stop", "");
            llSay(comChannel,"detach_objects");
            llSetLinkPrimitiveParamsFast(blackoutLink, [PRIM_SIZE, <0.01000, 0.1, 0.1>]);
            llSetLinkAlpha( blackoutLink, 0.0, ALL_SIDES );
            if(llGetPermissions()&PERMISSION_TRIGGER_ANIMATION)
            {
                if(llGetInventoryType(currentAnimation)!=INVENTORY_NONE )
                {
                    llStopAnimation(currentAnimation);
                }
                if(llGetInventoryType(overrideAnimation)!=INVENTORY_NONE )
                {
                    llStopAnimation(overrideAnimation);
                }
            }
        }
        if(buttonName=="SipButton")
        {
            if(llGetPermissions()&PERMISSION_TRIGGER_ANIMATION &&
            llGetInventoryType(currentAnimation)!=INVENTORY_NONE )
            {
                llStopAnimation(currentAnimation);
            }
        }
    }
    
    listen( integer channel, string name, key id, string mess )
    {
      
      
       


 if(mess == "bottle_reset")
 {
     
    // llMessageLinked(LINK_THIS,0,"reset",""); 
 }
    


else if(~llSubStringIndex(mess, "sip_total"))
                {
                 string sip_tot =  llStringTrim(llGetSubString( mess, llSubStringIndex(mess, "sip_total")+9, llStringLength(mess)), STRING_TRIM); 
               llMessageLinked(LINK_THIS,(integer)sip_tot,"sip_total","");   
                
            }
            
            else if(~llSubStringIndex(mess, "drink_total"))
                {
                 string drink_tot =  llStringTrim(llGetSubString( mess, llSubStringIndex(mess, "drink_total")+11, llStringLength(mess)), STRING_TRIM); 
               llMessageLinked(LINK_THIS,(integer)drink_tot,"drink_total","");   
                
            }
        
        if(channel==comChannel+1)
        {
          //  llOwnerSay("scrambling");
            llSay(0, scrambleWordsIn(mess));
        }else{
            if(~llSubStringIndex(mess, "detach"))
            {
                llMessageLinked( LINK_THIS, -5555, "-1", (key)textFaces );
                llMessageLinked(LINK_THIS, 1, (string)bamt, "");
                llSetTexture( portrait, portraitFace );
                if(llGetPermissions()&PERMISSION_TRIGGER_ANIMATION)
                {
                    if(llGetInventoryType(currentAnimation)!=INVENTORY_NONE)
                    {
                        llStartAnimation(currentAnimation);
                    }else{
                        llStartAnimation(overrideAnimation);
                    }
                }else{
                    currentAnimation = overrideAnimation;
                    llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
                }
            }
            key o = llList2Key(llGetObjectDetails( id, [OBJECT_OWNER]), 0);
            if( o==llGetOwner() )
            {
                if(mess == "hudPing")
                {    // If I'm attached and hear someone attaching...
                    llSay(comChannel, "duplicateHud");
                   
                }
                if(mess == "duplicateHud")
                {    // If I've attached and hear that I'm a duplicate...
                    llRequestPermissions( llGetOwner(), PERMISSION_ATTACH );
                }
                
                
                
                if(~llSubStringIndex(mess, "RestrainedLove")){
                    canRLV = 1;
                    //llOwnerSay("HUD got RLV");
                    llSetLinkPrimitiveParamsFast( LINK_THIS, [PRIM_NAME, llGetDisplayName(llGetOwner())] );
                    llOwnerSay("@setdebug_renderresolutiondivisor:"+"1.0"+"=force");
                }
                
                if(~llSubStringIndex(mess, "portrait"))
                {    // Get portrait, sent bamt
                    string tex = llStringTrim(llGetSubString( mess, llSubStringIndex(mess, "portrait")+8, llStringLength(mess)), STRING_TRIM);
                    llSetTexture( tex, portraitFace );
                    llWhisper(comChannel, "activate");
                    llWhisper(comChannel, "setBamt"+(string)bamt);
                    if(canRLV) llWhisper(comChannel, "RestrainedLove");
                }else if(~llSubStringIndex(mess, "total"))
                {
                    string tot = llStringTrim(llGetSubString( mess, llSubStringIndex(mess, "total")+5, llStringLength(mess)), STRING_TRIM);
                    llMessageLinked( LINK_THIS, -5555, tot, (key)textFaces );
                    llMessageLinked(LINK_THIS,(integer)tot,"sip_number","");
                }else if(~llSubStringIndex(mess, "bamtIncrease"))
                {
                    string inc = llStringTrim(llGetSubString( mess, llSubStringIndex(mess, "bamtIncrease")+12, llStringLength(mess)), STRING_TRIM);
                    if(isValidFloat(inc))
                    {
                        bamt+=(float)inc;
                    }
                    llSay(comChannel, "setBamt"+(string)bamt);
                    llMessageLinked(LINK_THIS, 1, (string)bamt, ""); // Set overrides
                    if(canRLV) update_rlvFx(); // Do cam effects
                }
                else if(~llSubStringIndex(mess, "OverAnim,")){
                    string ani = llStringTrim(llGetSubString( mess, llSubStringIndex(mess, "OverAnim,")+8, llStringLength(mess)), STRING_TRIM);
                    if(llGetInventoryType(ani)!=INVENTORY_NONE)
                    {
                        overrideAnimation = ani;
                    }
                }
                
                
                else if(~llSubStringIndex(mess, "DrinkAnim,")){
                    string ani = llStringTrim(llGetSubString( mess, llSubStringIndex(mess, "DrinkAnim,")+10, llStringLength(mess)), STRING_TRIM);
                    if(llGetInventoryType(ani)!=INVENTORY_NONE)
                    {
                        currentAnimation = ani;
                        overrideAnimation = ani;
                        if(llGetPermissions()&PERMISSION_TRIGGER_ANIMATION)
                        {
                            llStartAnimation(ani);
                        }else{
                            llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
                        }
                    }
                }
                
            }
        }
    }
    timer()
    {
        llSetTimerEvent(0.0);
        llSay( comChannel, "hudPing"); // In case HUD is put on after dring is partly drunk
        llOwnerSay("TPZY Drinking HUD is ready to party!!! Detaching the HUD removes all drinking effects.");
    }
    run_time_permissions( integer perm )
    {
        if(perm&PERMISSION_ATTACH) llDetachFromAvatar();
        if(perm&PERMISSION_TRIGGER_ANIMATION)
        {
            if(llGetInventoryType(currentAnimation)!=INVENTORY_NONE) llStartAnimation(currentAnimation);
        }
    }
    
    attach(key attachedAgent)
    {
        if (attachedAgent != NULL_KEY)
        {
            llResetScript();
        }else if(llGetAttached() == 0){
            //llMessageLinked(LINK_THIS,0,"stop","");
            llWhisper(comChannel, "detach");
            
            llMessageLinked(LINK_THIS, -1, (string)bamt, "");
            if(canRLV) llMessageLinked(LINK_THIS, -2, "stop", "");
            llSetLinkPrimitiveParamsFast(blackoutLink, [PRIM_SIZE, <0.01000, 0.1, 0.1>]);
            llSetLinkAlpha( blackoutLink, 0.0, ALL_SIDES );
        }
    }
    
    link_message(integer sender, integer num, string msg, key id)
    {
      if(msg == "Get_Sip_Total")
      {
         llSay(comChannel,"Get_Sip_Total");  
          
     } 
     
     else if(msg == "Get_Drink_Total") 
     {
         
        llSay(comChannel,"Get_Drink_Total"); 
     }
        
    }
}
