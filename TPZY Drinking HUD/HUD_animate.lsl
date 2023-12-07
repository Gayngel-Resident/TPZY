/*  HUD Animator
*    For override animations in between drinks
*/

float bamt;
list bamtToOverride = [
    20.0, "drunk stand 5", "Standing",
    20.0, "TPZYwobbl", "Walking",
    40.0, "ao_drunk_stand_4", "Standing",
    80.0, "drunk stand3", "Standing",
    100.0, "drunk stand with fall", "Standing"
];
integer boStride = 3;

override_animation()
{    
    integer i = 0;
    while(i<llGetListLength(bamtToOverride)-boStride)
    {
        float tryBa = llList2Float(bamtToOverride, i);
        integer tempI = i+boStride;
        float nextBa = llList2Float(bamtToOverride, tempI);
        while(nextBa==tryBa && tempI<llGetListLength(bamtToOverride)-boStride)
        {
            tempI+=boStride;
            nextBa = llList2Float(bamtToOverride, tempI);
        }
        string tryAnim = llList2String(bamtToOverride, i+1);
        string animState = llList2String(bamtToOverride, i+2);
        if( bamt >= tryBa && bamt < nextBa )
        {
            if(llGetInventoryType(tryAnim)!=INVENTORY_NONE)
            {
                llSetAnimationOverride(animState, tryAnim);
            }
        }
        i+=boStride;
    }
}

default{
    state_entry()
    {
        if(llGetAttached() > 0)
        {
            llRequestPermissions(llGetOwner(),PERMISSION_OVERRIDE_ANIMATIONS);
        }
    }
    
    run_time_permissions(integer perm)
    {
        if(perm&PERMISSION_OVERRIDE_ANIMATIONS){
            llResetAnimationOverride("ALL");
            override_animation();
        }
    }

    changed(integer mask)
    {
        if(mask & CHANGED_OWNER)
        {
            llResetScript();
        }
    }

    link_message( integer sender_num, integer num, string str, key id )
    {
        if(num==-1)
        {
            llResetAnimationOverride("ALL");
        }else if(num==1){
            bamt = (float)str;
            if(llGetPermissions()&PERMISSION_OVERRIDE_ANIMATIONS)
            {
                override_animation();
            }else{
                llRequestPermissions(llGetOwner(),PERMISSION_OVERRIDE_ANIMATIONS);
            }
        }
    }

    attach(key attachedAgent)
    {
        if (attachedAgent != NULL_KEY)
        {
            llResetScript();
        }else if(llGetAttached() == 0){
            if(llGetPermissions()&PERMISSION_OVERRIDE_ANIMATIONS)
            {
                llResetAnimationOverride("ALL");
            }
        }
    }

}
