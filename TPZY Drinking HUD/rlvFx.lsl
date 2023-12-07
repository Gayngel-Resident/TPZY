/* RLV Effects script */

string main_folder = "TPZY Drinking Hud"; //main folder in the #RLV folder
list subfolders = ["swirl FX",50,"vomit",89]; // add the items in inventory you want to attach followed by the percentage of total sips of when you want the item to attach. For example, if there are 15 total sips, "cocktail umbrella",30 will attach the cocktail umbrella on the 5th sip. Item name must match name of object in inventory. Each item will be a subfolder of the main sub folder. Item names are case sensitive.
string item;
integer ttot;
list object_list;


float minBlur=1.0;
float maxBlur=1.0;
float repeatTimes;
float delay;
integer direction;

float increment = 0.1;
float wobbleTime = 1.0;
float blur;
float increase;
float max(float x, float y) {
    if( y > x ) return y;
    return x;
}
//blurMin, blurMax, blurWaitTime, blurRepeat, blurWobbleTime, camFX

integer attach_handle;
integer attach_chan;
integer inv_handle;
integer inv_chan;
key owner;


string lm;
key lm_data;
vector gPosLM;
key httpReq;

AttachItem(string itemName)
{
 

     
       llOwnerSay("@attach:~"+main_folder+"/~"+itemName+"=force");
      
}

integer Pchannel(string salt){
    string setint = (string)((integer)("0x"+llGetSubString((string)llGetOwner(),-8,-1)) * 
    llStringLength(salt) * llCeil(llLog(llStringLength(salt))));
    return (integer)llGetSubString(setint, 0, 7);
}

default{
   on_rez(integer start_param)
   {
       
    // llResetScript();  
       
    } 
    
    state_entry(){
       // llOwnerSay("@clear"); 
       llMessageLinked(LINK_THIS,0,"Get_Sip_Total","");
        owner = llGetOwner();
       inv_chan = ((integer)llFabs((integer)("0x"+
llGetSubString((string)owner,-8,-1)) - 483))/200; 



        
        attach_chan = ((integer)llFabs((integer)("0x"+llGetSubString((string)owner,-8,-1)) - 324))/200;
       
      //  llOwnerSay((string)attach_chan);
        
        }
    link_message( integer sender_num, integer num, string str, key id )
    {
        //llOwnerSay("LINK "+(string)num+" "+str);
        if(num==-2 && str == "stop")
        {
            llSetTimerEvent(0.0);
            llOwnerSay("@setdebug_renderresolutiondivisor:"+"1.0"+"=force");
             llOwnerSay("@clear");
        }else if(num==32)
        {
            direction = 1;
            
            list m = llParseString2List(str, [","], []);
            minBlur = llList2Float(m,0);
            maxBlur = llList2Float(m,1);
            delay = llList2Float(m,2);
            repeatTimes = llList2Float(m,3);
            wobbleTime = max(llList2Float(m,4), 0.01);
            blur = minBlur;
            increase = (maxBlur-minBlur)/(wobbleTime/increment);
            //if(repeatTimes == 0.0) repeatTimes = 0.5;
            /*
            llOwnerSay("Stats\nincrease "+(string)increase+"\nblur "+(string)blur +
            "\ndelay "+(string)delay+"\nrepeatTimes "+(string)repeatTimes+
            "\nwobbleTime "+(string)wobbleTime+"\nBlur range: "+(string)minBlur+" - "+(string)maxBlur);
            */
            llSetTimerEvent( delay );
        }
        
         if(str == "send_home")
        {
        // llOwnerSay("message linked: send home");
        
        
       lm = llGetInventoryName(INVENTORY_LANDMARK,0);
       
       if(lm != "")
       lm_data = llRequestInventoryData(lm);  
        
                   
        }
        
        else if(str == "sip_total")
        {
        object_list = subfolders;
         ttot = num;
         
        
         
         integer i;
         integer tot = llGetListLength(object_list);
         
         for(i = 1; i < tot; i = i + 2)
         {
           
           integer s = llList2Integer(object_list,i);
          // llOwnerSay("s is " + (string)s);
           s =  llRound(((float)s/100.0)*(float)ttot); 
         //   llOwnerSay("rounded s is " + (string)s); 
           
           
           s = ttot-s;
           
           object_list = llListReplaceList(object_list,[s],i,i);

        //  llOwnerSay("subfolders: " + llList2CSV(subfolders));
             
         }   
            
            
        }
        
        else if(str == "sip_number")
        {
           // llOwnerSay("sip_number: " + (string)num);
            integer idx = llListFindList(object_list,[num]);
            
           if(idx != -1)
           { 
            
           llListenRemove(inv_handle);
           item = llList2String(object_list,idx-1);
          // llOwnerSay("checking inventory for " + item);
           inv_chan = (integer)llFabs(Pchannel(item));
             inv_handle = llListen(inv_chan,"",owner,"");
            llOwnerSay("@getinv:~"+main_folder+"="+(string)inv_chan);
            
          }
            
        }
        
        else if(str == "reset")
        
        {
          
          llResetScript();  
        }
    }
    
    
    dataserver(key reqID, string data)
    {
     gPosLM = llGetRegionCorner() + (vector)data;
     vector grid = gPosLM / 256.0;
   //  llOwnerSay((string)grid);    
      httpReq = llHTTPRequest(
                "https://cap.secondlife.com/cap/0/b713fe80-283b-4585-af4d-a3b7d9a32492?"
                + "var=name&grid_x=" + (string)llFloor(grid.x)
                + "&grid_y=" + (string)llFloor(grid.y), [], "");  
    }
    
    http_response(key id, integer status, list metadata, string body)
    {
      if (id == httpReq)
        {
            if (status != 200)
            {
               // llOwnerSay("Failure!");
                return;
            }
            
           
            integer i = llSubStringIndex(body, "'");
            body = llGetSubString(body, i + 1, -3);
           
            integer X = (integer)gPosLM.x & 255;
            integer Y = (integer)gPosLM.y & 255;
            integer Z = (integer)gPosLM.z;
            //Absolute.z = (integer)Absolute.z & 255;
          
            llOwnerSay("@tpto:" + llEscapeURL(body)+ "/"+(string)X+"/"+(string)Y+"/"+(string)Z + "=force");
          
          
           // string place = "[secondlife:///app/teleport/"+llEscapeURL(body)+
             //  "/"+(string)X+"/"+(string)Y+"/"+(string)Z+" "+lm+"]";
             
            llOwnerSay("@shownames=n");
            llOwnerSay("@tplocal=n");
            llOwnerSay("@tplm=n");
            llOwnerSay("@tploc=n");
            llOwnerSay("@tplure=n");
            llOwnerSay("@showworldmap=n");
             llOwnerSay("@showminimap=n");
              llOwnerSay("@showloc=n");
               llOwnerSay("@sittp=n");  
               
           
        }
    } 
    
     listen(integer chan, string name, key id, string msg)
    {
        
         if(chan == inv_chan)   
     {
       // llOwnerSay("inv_chan:*" + msg); 
       
       list tmp = llParseString2List(msg,[","],[]);
       
     // llOwnerSay("~"+item); 
       
       integer idx = llListFindList(tmp, ["~"+item]);
         
       //  llOwnerSay((string)idx);
          if(idx == -1)
         {
             
           
         
          llListenRemove(attach_handle);   
          attach_handle = llListen(attach_chan,"","","");
          
      //    llOwnerSay("@acceptpermission=rem"); // no dialog to accept inventory
           llOwnerSay("@notify:" + (string)attach_chan+";inv_offer=add");
            llGiveInventoryList(owner, "#RLV/~"+main_folder+"/~"+item, [item]);
         }
         
          else
         {
           //  llOwnerSay("attaching");
              AttachItem(item);
          }  
         
     }
     
     
      else if(chan == attach_chan)
         {
             
         
       // llOwnerSay("attach_chan: " + msg);
        list response = llParseString2List(msg, [ " " ], []);
            
            string behaviour = llList2String(response, 0);
            if ("/accepted_in_rlv" == behaviour)
            {
               
               AttachItem(item);
            }
            else if ("/accepted_in_inv" == behaviour)
            {
                 
               AttachItem(item);
            }
           
          
        }
     
        
    }
    
    
    timer()
    {    // Repeat effects
        llOwnerSay("@setdebug_renderresolutiondivisor:"+(string)blur+"=force");
        if(repeatTimes>0.0)
        {
            if(direction)
            {
                if(blur<maxBlur)
                {
                    blur+= increase;
                    if(blur>maxBlur) blur = maxBlur;
                    llSetTimerEvent(increment);
                }else{
                    blur = maxBlur;
                    direction = 0;
                    repeatTimes-=0.5;
                    llSetTimerEvent(increment);
                }
            }else{
                if(blur>minBlur)
                {
                    blur-= increase;
                    if(blur<minBlur) blur = minBlur;
                    llSetTimerEvent(increment);
                }else{
                    blur = minBlur;
                    direction = 1;
                    repeatTimes-=0.5;
                    llSetTimerEvent(delay);
                }
            }
        }else{ llSetTimerEvent(0.0); }
        
        
        
    }
    
      changed(integer mask)
    {
        if(mask & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
    
   
}
