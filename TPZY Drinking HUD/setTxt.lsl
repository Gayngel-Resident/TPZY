// llMessageLinked( integer link, -5555, string text_to_set, key "list,of,faces" );
string font = "c60443fc-8e71-1b99-3632-5db978c97fed";
integer text_command = -5555;
set_digits(string amount, list faces)
{
    integer i = llGetListLength(faces)-1;
    
    list params = [];
    while(i>=0)
    {
        float alpha = 0.0;
        if(llGetListLength(faces)-i<=llStringLength(amount)  &&  (integer)amount>=0)
        {
            alpha = 1.0;
        }
        llSetAlpha( alpha, llList2Integer(faces,i) );
        --i;
    }
    if( (integer)amount<0 ) return;
    i = llGetListLength(faces)-1;
    while(llStringLength(amount)>0 && i>=0)
    {
        integer sl = llStringLength(amount);
        integer r;
        integer c;
        
        string chr = llGetSubString(amount, sl-1, sl-1);
        if(chr=="$")
        {
            r=2;
            c=2;
        }else if(chr=="L"){
            r=2;
            c=3;
        }else{        
            integer digit = (integer)chr;
            r = (integer)(digit / 4);
            c = (integer)( digit-(r*4) );
        }
        amount = llDeleteSubString( amount, sl-1, sl-1 );
        integer faceToSet = llList2Integer(faces, i);
        
        //llOwnerSay("FaceToSet:"+(string)faceToSet+" r "+(string)r+" c "+(string)c);
        if(font=="")
        {
            llScaleTexture( 0.25000, 0.33333, faceToSet );
            llOffsetTexture( (c/4.0)*1.0-0.5+0.125 , (1.0-(r+1.0)/3.0)-(1.0/3.0), faceToSet );
        }else{
            params+=[PRIM_TEXTURE, faceToSet, font, <0.25, 0.33333,0.0>, <(c/4.0)*1.0-0.5+0.125 , (1.0-(r+1.0)/3.0)-(1.0/3.0),0>, 0.0];
        }
        i = i-1;
    }
    if(font!="")
    {
        llSetLinkPrimitiveParamsFast(LINK_THIS, params);
    }
}


default
{
    state_entry()
    {
        list faces = [2,1];
        set_digits("00", faces);
    }
    
    link_message( integer sender_num, integer num, string str, key id )
    {
        //llOwnerSay("heard from "+(string)sender_num+": "+(string)num+" "+str+" "+(string)id);
        if(num == text_command)
        {
            set_digits(str, llParseString2List((string)id, [","], []) );
        }
        
    }
    
      changed(integer mask)
    {
        if(mask & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}
