// This number should be the same in any dispenser and dispensed objects that need to work together

integer attach_point = ATTACH_HUD_CENTER_1; // Attach to HUD
//integer attach_point = ATTACH_RHAND; // Attach to hand

// This script is meant to go into an object that is temporary attached.
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

integer handle;
key user;
integer comms = -987345;


destroy()
{
    if(llGetStartParameter()!=0)
    {
        llDie();
    }else{
        llOwnerSay("Would have destroyed this object, but it was rezzed by a user");
        llSetTimerEvent(0.0);
    }
}

default{
    state_entry()
    {
        handle = llListen( comms, "", "", "" );
        string obj = llGetObjectName();
        handle = llListen( comms, "", "", "" );
        llWhisper(comms, obj+"|rez|0"); // Announce rez
        
        llSetTimerEvent(30.0);
    }
    on_rez(integer n)
    {
        llSetTimerEvent(3.0);
        string obj = llGetObjectName();
        handle = llListen( comms, "", "", "" );
        llWhisper(comms, obj+"|rez|"+(string)n); // Announce rez
    }
    
    listen( integer channel, string name, key id, string message )
    {
        //llOwnerSay("Heard :"+message+" on channel "+(string)channel);
        if(channel==comms)
        {   // Expects the name of the object + "|give" + "|" + user.
            list m = llParseString2List( message, ["|"], [] );
            if(llList2String(m,0)==llGetObjectName())
            {
                if( llList2String(m, 1)=="give" )
                {
                    user = (key)llList2String(m,2);
                    if(llGetAgentSize( user )!=ZERO_VECTOR)
                    {
                        if( llGetPermissionsKey()!=user )
                        {
                            llSetTimerEvent(30.0);
                            llRequestPermissions( user, PERMISSION_ATTACH|PERMISSION_TRIGGER_ANIMATION );
                        }else{
                            state Ready;
                        }
                    }
                }
            }
        }
    } // End Listen
    
    run_time_permissions( integer perm )
    {
        if(PERMISSION_ATTACH & perm)
        {
            llSetTimerEvent(0.0);
            state Ready;
        }else{
            destroy();
        }
    }
    
    timer()
    {
        destroy();
    }
    
      changed(integer mask)
    {
        if(mask & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}

state Ready{
    state_entry()
    {
        llAttachToAvatarTemp( attach_point );
    }
    
      changed(integer mask)
    {
        if(mask & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}
