unit main;

interface
{$ifdef gui4} {$define gui3} {$define gamecore}{$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define bmp} {$define ico} {$define gif} {$define snd} {$endif}
{$ifdef con3} {$define con2} {$define net} {$define ipsec} {$endif}
{$ifdef con2} {$define bmp} {$define ico} {$define gif} {$define jpeg} {$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses gosswin2, gossroot, {$ifdef gui}gossgui,{$endif} {$ifdef snd}gosssnd,{$endif} gosswin, gossio, gossimg, gossnet;
{$align on}{$O+}{$W-}{$I-}{$U+}{$V+}{$B-}{$X+}{$T-}{$P+}{$H+}{$J-} { set critical compiler conditionals for proper compilation - 10aug2025 }
//## ==========================================================================================================================================================================================================================
//##
//## MIT License
//##
//## Copyright 2025 Blaiz Enterprises ( http://www.blaizenterprises.com )
//##
//## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//## files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//## modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
//## is furnished to do so, subject to the following conditions:
//##
//## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//##
//## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//##
//## ==========================================================================================================================================================================================================================
//## Library.................. app code (main.pas)
//## Version.................. 2.00.158 (+23)
//## Items.................... 1
//## Last Updated ............ 07nov2025, 24oct2025, 16sep2025, 07sep2025
//## Lines of Code............ 1,800+
//##
//## main.pas ................ app code
//## gossroot.pas ............ console/gui app startup and control
//## gossio.pas .............. file io
//## gossimg.pas ............. image/graphics
//## gossnet.pas ............. network
//## gosswin.pas ............. static Win32 api calls
//## gosswin2.pas ............ dynamic Win32 api calls
//## gosssnd.pas ............. sound/audio/midi/chimes
//## gossgui.pas ............. gui management/controls
//## gossdat.pas ............. app icons (24px and 20px) and help documents (gui only) in txt, bwd or bwp format
//## gosszip.pas ............. zip support
//## gossjpg.pas ............. jpeg support
//## gossgame.pas ............ game support (optional)
//## gamefiles.pas ........... internal files for game (optional)
//##
//## ==========================================================================================================================================================================================================================
//## | Name                   | Hierarchy         | Version   | Date        | Update history / brief description of function
//## |------------------------|-------------------|-----------|-------------|--------------------------------------------------------
//## | tapp                   | tbasicapp         | 2.00.135  | 24oct2025   | Easy to use midi player - 16sep2025, 07sep2025
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
//## ==========================================================================================================================================================================================================================


const
   synth_showstyle     =false;//true;

var
   itimerbusy:boolean=false;
   iapp:tobject=nil;

type

{tapp}
   tapp=class(tbasicapp)
   private

    ibarleft,ibarright:tbasiccontrol;
    ilaststate:char;
    imiddevice:tbasicsel;
    ivol:tsimpleint;
    iplaylist:tplaylist;
    ispeed:tsimpleint;
    imode,istyle:tbasicsel;
    iformats:tbasicset;
    ijump:tbasicjump;
    ititlebar,ijumptitle,ilistcap,inavcap:tbasictoolbar;
    inav:tbasicnav;
    ilist,iinfo:tbasicmenu;
    isettingspanel,ilistroot:tbasicscroll;
    ishownav,ishowsettings,ishowinfo,ishowlistlinks,ianimateicon,ialwayson,ionacceptonce,lshow,lshowsep,ilargejumptitle,ilargejump,iautoplay,iautotrim,imuststop,imustplay,iplaying,ibuildingcontrol,iloaded:boolean;
    inavcol,iinfcol:longint;
    ilasttimeref,iflashref,itimer100,itimer350,itimer500,itimerslow,iinfotimer:comp;
    iplaylistREF,ijumpcap,ilyricref,iinforef,ilasterror,ilastsavefilename,ilastfilename,inavref,isettingsref:string;
    ilastpos,imustpos:longint;
    ilastbeatval,ilastbeatvalBass,ibeatval,ibeatvalBass,imustpertpos:double;

    //.status support
    iff,iintro,iinfoid,iselstart,iselcount,idownindex,inavindex,ifolderindex,ifileindex,inavcount,ifoldercount,ifilecount:longint;
    iisnav,iisfolder,iisfile:boolean;

    //.midi status
    ijumpstatus:longint;
    procedure xcmd0(xcode2:string);
    procedure xcmd(sender:tobject;xcode:longint;xcode2:string);
    procedure __onclick(sender:tobject);
    procedure __ontimer(sender:tobject); override;
    function __oninfo(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
    function xmasklist:string;
    function xfull_mask:string;
    procedure xnav_mask;
    procedure xloadsettings;
    procedure xsavesettings;
    procedure xsavesettings2(xforce:boolean);
    procedure xautosavesettings;
    procedure xfillinfo;
    procedure xshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
    function xshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
    function xintroms:longint;
    function xffms:longint;
    function xonaccept(sender:tobject;xfolder,xfilename:string;xindex,xcount:longint):boolean;
    function getshowplaylist:boolean;
    procedure setshowplaylist(x:boolean);
    function findlistcmd(n:string;var xcaption,xhelp,xcmd:string;var xtep:longint;var xenabled:boolean;xextendedlables:boolean):boolean;
    function canprev:boolean;
    function cannext:boolean;
    function xmustsaveplaylist:boolean;
    procedure xupdatebuttons;
    function playlist__canaddfile:boolean;

    //.saveas
    function xlistfilename:string;
    function xcansaveas:boolean;
    procedure xsaveas;

   public

    //create
    constructor create; virtual;
    destructor destroy; override;

    //information
    property showplaylist:boolean read getshowplaylist write setshowplaylist;

   end;


//custom toolbar images (in tea format) - 08feb2025
const
tep_settings20:array[0..400] of byte=(
84,69,65,49,35,19,0,0,0,20,0,0,0,128,255,255,47,0,0,0,2,128,255,255,12,0,0,0,2,128,255,255,2,0,0,0,1,128,255,255,2,0,0,0,1,128,255,255,2,0,0,0,2,128,255,255,6,0,0,0,1,128,255,255,2,0,0,0,2,128,255,255,4,0,0,0,2,128,255,255,2,0,0,0,1,128,255,255,5,0,0,0,1,128,255,255,12,0,0,0,1,128,255,255,6,0,0,0,1,128,255,255,10,0,0,0,1,128,255,255,7,0,0,0,1,128,255,255,10,0,0,0,1,128,255,255,5,0,0,0,2,128,255,255,4,0,0,0,3,128,255,255,5,0,0,0,1,128,255,255,3,0,0,0,1,128,255,255,5,0,0,0,1,128,255,255,3,0,0,0,1,128,255,255,5,0,0,0,1,128,255,255,2,0,0,0,1,128,255,255,5,0,0,0,1,128,255,255,3,0,0,0,1,128,255,255,5,0,0,0,1,128,255,255,3,0,0,0,2,128,255,255,3,0,0,0,1,128,255,255,3,0,0,0,1,128,255,255,4,0,0,0,1,128,255,255,6,0,0,0,1,128,255,255,3,0,0,0,3,128,255,255,4,0,0,0,1,128,255,255,7,0,0,0,1,128,255,255,10,0,0,0,1,128,255,255,6,0,0,0,1,128,255,255,11,0,0,0,1,128,255,255,6,0,0,0,1,128,255,255,2,0,0,0,2,128,255,255,4,0,0,0,2,128,255,255,2,0,0,0,1,128,255,255,6,0,0,0,2,128,255,255,2,0,0,0,1,128,255,255,2,0,0,0,1,128,
255,255,2,0,0,0,2,128,255,255,11,0,0,0,1,128,255,255,2,0,0,0,1,128,255,255,16,0,0,0,2,128,255,255,27);

//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024
procedure info__app_checkparameters;


//app procs --------------------------------------------------------------------
//.create / destroy
procedure app__remove;//does not fire "app__create" or "app__destroy"
procedure app__create;
procedure app__destroy;

//.event handlers
function app__onmessage(m,w,l:longint):longint;
procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
procedure app__onpaint(sw,sh:longint);
procedure app__ontimer;

//.support procs
function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
function app__findcustomtep(xindex:longint;var xdata:tlistptr):boolean;
function app__syncandsavesettings:boolean;


implementation

{$ifdef gui}
uses
    gossdat;
{$endif}



//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//get
if      (xname='slogan')              then result:=info__app('name')+' by Blaiz Enterprises'
else if (xname='width')               then result:='1420'
else if (xname='height')              then result:='920'
else if (xname='language')            then result:='english-australia'//for Clyde - 14sep2025
else if (xname='codepage')            then result:='1252'
else if (xname='ver')                 then result:='2.00.158'
else if (xname='date')                then result:='07nov2025'
else if (xname='name')                then result:='Synthesiser'
else if (xname='web.name')            then result:='synthesiser'//used for website name
else if (xname='des')                 then result:='Easy to use midi player'
else if (xname='infoline')            then result:=info__app('name')+#32+info__app('des')+' v'+app__info('ver')+' (c) 1997-'+low__yearstr(2025)+' Blaiz Enterprises'
else if (xname='size')                then result:=low__b(io__filesize64(io__exename),true)
else if (xname='diskname')            then result:=io__extractfilename(io__exename)
else if (xname='service.name')        then result:=info__app('name')
else if (xname='service.displayname') then result:=info__app('service.name')
else if (xname='service.description') then result:=info__app('des')
else if (xname='new.instance')        then result:='1'//1=allow new instance, else=only one instance of app permitted
else if (xname='screensizelimit%')    then result:='98'//95% of screen area
else if (xname='realtimehelp')        then result:='0'//1=show realtime help, 0=don't
else if (xname='hint')                then result:='1'//1=show hints, 0=don't

//.links and values
else if (xname='linkname')            then result:=info__app('name')+' by Blaiz Enterprises.lnk'
else if (xname='linkname.vintage')    then result:=info__app('name')+' (Vintage) by Blaiz Enterprises.lnk'
//.author
else if (xname='author.shortname')    then result:='Blaiz'
else if (xname='author.name')         then result:='Blaiz Enterprises'
else if (xname='portal.name')         then result:='Blaiz Enterprises - Portal'
else if (xname='portal.tep')          then result:=intstr32(tepBE20)
//.software
else if (xname='url.software')        then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.html'
else if (xname='url.software.zip')    then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.zip'
//.urls
else if (xname='url.portal')          then result:='https://www.blaizenterprises.com'
else if (xname='url.contact')         then result:='https://www.blaizenterprises.com/contact.html'
else if (xname='url.facebook')        then result:='https://web.facebook.com/blaizenterprises'
else if (xname='url.mastodon')        then result:='https://mastodon.social/@BlaizEnterprises'
else if (xname='url.twitter')         then result:='https://twitter.com/blaizenterprise'
else if (xname='url.x')               then result:=info__app('url.twitter')
else if (xname='url.instagram')       then result:='https://www.instagram.com/blaizenterprises'
else if (xname='url.sourceforge')     then result:='https://sourceforge.net/u/blaiz2023/profile/'
else if (xname='url.github')          then result:='https://github.com/blaiz2023'
//.program/splash
else if (xname='license')             then result:='MIT License'
else if (xname='copyright')           then result:='© 1997-'+low__yearstr(2025)+' Blaiz Enterprises'
else if (xname='splash.web')          then result:='Web Portal: '+app__info('url.portal')

else
   begin
   //nil
   end;

except;end;
end;

procedure info__app_checkparameters;
var
   xonce:boolean;

   procedure c(n:string);
   begin
   //show first error only
   if xonce and (app__info(n)='') then
      begin
      xonce:=false;
      showerror('App parameter "'+n+'" missing in "info__app()" procedure.');
      end;
   end;
begin
try
//init
xonce:=true;

//check these app parameters are set in "info__app()" proc
c('width');
c('height');
c('ver');
c('date');
c('name');
c('screensizelimit%');
c('focused.opacity');
c('unfocused.opacity');
c('opacity.speed');
c('head.large');
c('head.center');
c('head.sleek');
c('head.align');
c('scroll.size');
c('scroll.minimal');
c('slider.minimal');
c('bordersize');
c('sparkle');
c('brightness');
c('back.strength');
c('back.speed');
c('back.fadestep');
c('back.scrollstep');
c('back.vscrollstep');
c('back.wobble');
c('back.vwobble');
c('back.fadewobble');
c('back.colorise');
c('ecomode');
c('glow');
c('emboss');
c('sleek');
c('shade.focus');
c('shade.round');
c('color.name');
c('frame.name');
c('frame.max');
c('font.name');
c('font.size');
c('font2.use');
c('font2.name');
c('font2.size');
c('help.maxwidth');
c('check.mode');
except;end;
end;


//app procs --------------------------------------------------------------------
procedure app__create;
begin
{$ifdef gui}
iapp:=tapp.create;
{$else}

//.starting...
app__writeln('');
//app__writeln('Starting server...');

//.visible - true=live stats, false=standard console output
scn__setvisible(false);


{$endif}
end;

procedure app__remove;
begin
try

except;end;
end;

procedure app__destroy;
begin
try
//save
//.save app settings
app__syncandsavesettings;

//free the app
freeobj(@iapp);
except;end;
end;

function app__findcustomtep(xindex:longint;var xdata:tlistptr):boolean;

  procedure m(const x:array of byte);//map array to pointer record
  begin
  {$ifdef gui}
  xdata:=low__maplist(x);
  {$else}
  xdata.count:=0;
  xdata.bytes:=nil;
  {$endif}
  end;
begin//Provide the program with a set of optional custom "tep" images, supports images in the TEA format (binary text image)
//defaults
//result:=false;

//sample custom image support
{
case xindex of
tepHand20:m(_tephand20);
end;
}
//successful
result:=(xdata.count>=1);
end;

function app__syncandsavesettings:boolean;
begin
//defaults
result:=false;
try
//.settings
{
app__ivalset('powerlevel',ipowerlevel);
app__ivalset('ramlimit',iramlimit);
{}


//.save
app__savesettings;

//successful
result:=true;
except;end;
end;

function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
begin
result:=tnetbasic.create;
end;

function app__onmessage(m,w,l:longint):longint;
begin
//defaults
result:=0;
end;

procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
begin
//nil
end;

procedure app__onpaint(sw,sh:longint);
begin
//console app only
end;

procedure app__ontimer;
begin
try
//check
if itimerbusy then exit else itimerbusy:=true;//prevent sync errors

//last timer - once only
if app__lasttimer then
   begin

   end;

//check
if not app__running then exit;


//first timer - once only
if app__firsttimer then
   begin

   end;



except;end;
try
itimerbusy:=false;
except;end;
end;


constructor tapp.create;
const
   vsep=5;
var
   e:string;
   xsubmenu20:longint;

   procedure ladd(n:string);
   var
      xcaption,xhelp,xcmd:string;
      xtep:longint;
      xenabled:boolean;
   begin
   //check
   if (ilistcap=nil) then exit;
   if not findlistcmd(n,xcaption,xhelp,xcmd,xtep,xenabled,false) then
      begin
      showerror('List command not found "'+n+'"');
      exit;
      end;
   //get
   ilistcap.add(xcaption,xtep,0,xcmd,'Playlist|'+xhelp);
   end;

begin
if system_debug then dbstatus(38,'Debug 010 - 21may2021_528am');//yyyy


//win__make_gosswin2_pas;app__halt;


//prevent app from closing immediately -> we control the shutdown process
app__closepaused:=true;

//required graphic support checkers --------------------------------------------
//needers - 26sep2021
//need_jpeg;
//need_gif;
//need_ico;
need_mm;//required


//init midi device range -> disable "all midi devices" - 13sep2025
mid_setAllowAllDevices(false);


//init sample disk
idisk__init('Sample Midi Music',tep_notes20);

idisk__tofile21('Joan of Arc.mid',programfile__JoanOfArc_mid,true,e);
idisk__tofile21('Roses Are Red.mid',programfile__Roses_Are_Red_mid,true,e);
idisk__tofile21('Titanic.mid',programfile__Titanic_mid,true,e);
idisk__tofile21('We Will Rock You.mid',programfile__We_Will_Rock_You_mid,true,e);
idisk__tofile21('Marys.mid',programfile__MARYS_MID,true,e);
idisk__tofile21('Rock.mid',programfile__ROCK_MID,true,e);
idisk__tofile21('A Minor.mid',programfile__AMINOR_MID,true,e);
idisk__tofile21('Hotel California.mid',programfile__HOTCAL_MID,true,e);
idisk__tofile21('I''ll Take You Home Again Kathleen.mid',programfile__ILLTAKEUHOMEAGAINKATHLEEN_MID,true,e);
idisk__tofile21('D 2PRE.mid',programfile__D_2PRE_MID,true,e);
idisk__tofile21('D 4INV.mid',programfile__D_4INV_MID,true,e);
idisk__tofile21('Cum On Feel The Noise.mid',programfile__CUM_ON_FEEL_THE_NOISE_MID,true,e);
idisk__tofile21('Classical.mid',programfile__Classical_MID,true,e);
idisk__tofile21('Classical 2.mid',programfile__Classical2_MID,true,e);
idisk__tofile21('Maggie.mid',programfile__MAGGIE_MID,true,e);
idisk__tofile21('Rockin.mid',programfile__ROCKIN_MID,true,e);
idisk__tofile21('RRWaltz.mid',programfile__RRWALTZ_MID,true,e);
idisk__tofile21('Bach.mid',programfile__bach_mid,true,e);



//self
inherited create(strint32(app__info('width')),strint32(app__info('height')),true);
ibuildingcontrol:=true;


//init
xsubmenu20          :=tepDown;//tep__addone20c(1,tep_settings20);
ilaststate          :='n';
itimer100           :=slowms64;
itimer350           :=slowms64;
itimer500           :=slowms64;
itimerslow          :=slowms64;
iflashref           :=slowms64;
iinfotimer          :=slowms64;
ilasttimeref        :=0;

//columns
inavcol             :=1;
iinfcol             :=3;

//vars
iloaded             :=false;
ilastsavefilename   :='';
ibeatval            :=0;
ibeatvalBass        :=0;
ilastbeatval        :=0;
ilastbeatvalBass    :=0;
ishowlistlinks      :=false;
ialwayson           :=false;
ianimateicon        :=false;
ionacceptonce       :=false;
ilasterror          :='';
inavref             :='';
ilargejump          :=false;
ilargejumptitle     :=false;
iautoplay           :=false;
ijumpstatus         :=0;//off
iautotrim           :=false;
ishownav            :=false;
ishowinfo           :=false;
ishowsettings       :=false;
iintro              :=0;
iff                 :=0;
ilyricref           :='';
iplaylistREF        :='';
lshow               :=true;
lshowsep            :=true;

mm_playmanagement_init(imuststop,imustplay,iplaying,imustpertpos,imustpos,ilastpos,ilastfilename);

//.playlist handler
iplaylist:=tplaylist.create;
iplaylist.fullmask:=xfull_mask;//master mask - 20mar2022
iplaylist.partmask:='';

//.midi handler
mid_setkeepopen(false);//auto closes midi device after 5 seconds of inactivity
mid_enhance(true);//enable enhanced midi features -> e.g. realtime status

//controls
with rootwin do
begin
scroll:=false;
xhead;
xgrad;
xhead.add('Nav',tepNav20,0,'nav.toggle','Navigation Panel | Toggle navigation panel (play folder / play list)');
xhead.add('Play Folder',tepFolder20,0,'show.folder','Play midis in a folder');
xhead.add('Play List',tepNotes20,0,'show.list','Play midis in a playlist');
//xhead.addsep;
xhead.add('Prev',tepPrev20,0,'prev','Previous midi');
xhead.add('Rewind',tepRewind20,0,'rewind','Rewind # seconds');
xhead.add('Stop',tepStop20,0,'stop','Stop playback');
xhead.benabled2['stop']:=false;
xhead.add('Play',tepPlay20,0,'play','Toggle playback');
xhead.add('Fast Forward',tepFastForward20,0,'fastforward','Fast forward # seconds');
xhead.add('Next',tepNext20,0,'next','Next midi');
xhead.add('Menu',tepMenu20,0,'menu','Show menu');
xhead.xaddMixer;
xhead.xaddoptions;
xhead.xaddhelp;

//.playback status
with xhigh2 do
begin

ijumpcap:='Playback Progress';
ijumptitle:=ntitlebar(false,ijumpcap,'Midi playback progress');
with ijumptitle do
begin
osepv:=5;
oautoheight:=false;//1 line only
halign:=2;

add('Nav',tepNav20,0,'nav.toggle','Navigation Panel | Toggle navigation panel (play folder / play list)');
add('Info',tepInfo20,0,'info.toggle','Information Panel | Toggle information panel');
add('Settings',tepSettings20,0,'settings.toggle','Information Panel | Toggle settings sub-panel');
add('',xsubmenu20,0,'jump.menu','Playback Progress|Show options');
end;

ijump:=xhigh2.njump('','Click and/or drag to adjust playback position',0,0);

end;
end;


//------------------------------------------------------------------------------
//navigation column - left -----------------------------------------------------
//------------------------------------------------------------------------------
rootwin.xcols.style:=bcLefttoright;//04feb2025

with rootwin.xcols.makecol(inavcol,100,false) do

begin
ilistroot:=client as tbasicscroll;

//.play from folder
inavcap:=ntoolbar('Navigate files and folders on disk');
with inavcap do
begin
maketitle3('Play Folder',false,false);
opagename:='folder';
normal:=false;
add('Refresh',tepRefresh20,0,'refresh','Navigation|Refresh list');
add('Fav',tepFav20,0,'nav.fav','Navigation|Show favourites list');
add('Back',tepBack20,0,'nav.prev','Navigation|Previous folder');
add('Forward',tepForw20,0,'nav.next','Navigation|Next folder');
add('Add',tepEdit20,0,'list.addfile','Playlist|Add selected file to playlist');
onclick:=__onclick;
end;

inav:=nnav.makenavlist;
inav.hisname:='synthesiser';//24may2021
inav.omasklist:=xfull_mask;
inav.oautoheight:=true;
inav.sortstyle:=nlName;//nlSize;
inav.style:=bnNavlist;
inav.ofindname:=true;//21feb2022
inav.opagename:='folder';

//.play from list
ilistcap:=ntoolbar('Navigate files and folders on disk');
with ilistcap do
begin
maketitle3('Play List',false,false);
opagename:='list';
normal:=false;
ladd('edit');
ladd('new');
ladd('open');
ladd('save as');
addsep;
ladd('cut');
ladd('copy');
ladd('copy all');
ladd('paste');
ladd('replace');//19apr2022
ladd('undo');


with xhigh2 do
begin
imode:=nsel('Playback Mode','Playback mode',0);
with imode do
begin
xadd('Once','once','Playback Mode|Play selected midi once');
xadd('Repeat One','repeat1','Playback Mode|Play selected midi repeatedly');
xadd('Repeat All','repeat1','Playback Mode|Play all midis repeatedly');
xadd('All Once','once','Playback Mode|Play all midis once');
xadd('Random','repeat1','Playback Mode|Play midis randomly');
end;
end;

//.event
onclick:=__onclick;
end;

ilist:=nlist('','',nil,0);
ilist.opagename:='list';
ilist.oretainpos:=true;
ilist.onumberfrom:=0;
ilist.help:='Select file to play';
ilist.ocanshowmenu:=true;

//default playback list style
page:='folder';
end;


//------------------------------------------------------------------------------
//information column - right ---------------------------------------------------
//------------------------------------------------------------------------------

with rootwin.xcols.makecol(iinfcol,100,false) do
begin

ititlebar:=ntitlebar(false,'Midi Information','Midi information');
with ititlebar do
begin

add('',tepLess20,0,'vol.dn','Volume|Decrease volume');
add('Vol 100',tepNone,0,'vol.100','Volume|Reset volume to 100%');
add('',tepMore20,0,'vol.up','Volume|Increase volume');

addsep;

add('',tepLess20,0,'speed.dn','Speed|Decrease playback speed');
add('Speed 100',tepNone,0,'speed.100','Speed|Reset playback speed to 100%');
add('',tepMore20,0,'speed.up','Speed|Increase playback speed');

end;


iinfo:=nlistx('','Midi technnical and playback information',19,19,__oninfo);//07sep2025, 11aug2025
iinfo.otab:=tbL100_L500;
iinfo.oscaleh:=0.70;
iinfo.makepanel;//21aug2025

//settings
isettingspanel:=xhigh2;
isettingspanel.ntitle(false,'Settings','Settings');
isettingspanel.osepv:=5;

//.formats

with xhigh2.ncols do
begin
makeautoheight;

iformats:=makecol(0,30,false).nset('File Types','File Types | Select midi file types to list in the Navigation panel (left) | Selecting no file type lists all midi file types',7,7);
with iformats do
begin
osepv:=vsep;
itemsperline:=3;
xset(0,'mid', 'mid','File Types|Include ".mid" file type in play list',true);
xset(1,'midi','midi','File Types|Include ".midi" file type in play list',true);
xset(2,'rmi', 'rmi','File Types|Include ".rmi" file type in play list',true);
end;

//.device
imiddevice:=makecol(1,70,false).nmidi('','');
imiddevice.osepv:=vsep;

end;

//.style
istyle:=xhigh2.nsel('Play Style','Select play style',0);
with istyle do
begin
osepv:=vsep;
itemsperline:=4;
xadd('GM','GM','GM');
xadd('GS','GS','GS');
xadd('XG','XG','XG');
xadd('GM2','GM2','GM2');
end;
istyle.visible:=synth_showstyle;//16apr2021

//.speed
ispeed:=xhigh2.mint2b('Speed','Playback speed|Restore default playback speed','Playback speed|Set playback speed from 50% (slower) to 200% (faster)|Normal playback speed is 100%',50,200,100,100,'');
ispeed.osepv:=2*vsep;
ispeed.ounit:=' %';

//.volume
ivol:=xhigh2.mmidivol('','');
ivol.osepv:=vsep;
end;


//events
rootwin.onaccept:=xonaccept;
rootwin.xhead.onclick:=__onclick;
ijumptitle.onclick:=__onclick;
ititlebar.onclick:=__onclick;

//.nav
inav.onclick:=__onclick;
inav.xlist.showmenuFill1:=xshowmenuFill1;
inav.xlist.showmenuClick1:=xshowmenuClick1;
//.list
ilist.onclick:=__onclick;
ilist.showmenuFill1:=xshowmenuFill1;
ilist.showmenuClick1:=xshowmenuClick1;
iplaylist.list:=ilist;//connect playlist handler to user list - 20mar2022
//.jump
ijump.onclick:=__onclick;


//animated icon support - 30apr2022
rootwin.xhead.aniAdd(tepIcon24,500);
rootwin.xhead.aniAdd(tepIcon24B,500);
//rootwin.xhead.aniAdd(tepError32,500);


//defaults
ibuildingcontrol:=false;
xloadsettings;
xfillinfo;


//iautoplay
if iautoplay then imustplay:=true;


//finish
createfinish;

end;

destructor tapp.destroy;
begin
try
//settings
xsavesettings;
//controls
mid_stop;
freeobj(@iplaylist);
//self
inherited destroy;
except;end;
end;

procedure tapp.xupdatebuttons;
var
   xmustalign,xshownav,xplaylist,bol1:boolean;
   xvollevel:longint;
begin
try
//init
xmustalign :=false;
xshownav   :=ishownav or (not ishowinfo);
xvollevel  :=ivol.val;

//get
xplaylist:=showplaylist;
bol1:=ishowlistlinks;
rootwin.xhead.bmarked2['show.folder']:=not xplaylist;
rootwin.xhead.bmarked2['show.list']:=xplaylist;

ilistcap.benabled2['list.undo']:=iplaylist.canundo;
ilistcap.benabled2['list.open']:=iplaylist.canopen;
ilistcap.benabled2['list.saveas']:=iplaylist.cansave;
ilistcap.benabled2['list.new']:=iplaylist.cannew;
ilistcap.benabled2['list.cut']:=iplaylist.cancut;
ilistcap.benabled2['list.copy']:=iplaylist.cancopy;
ilistcap.benabled2['list.copyall']:=iplaylist.cancopyall;

ilistcap.bvisible2['list.undo']:=bol1;
ilistcap.bvisible2['list.open']:=bol1;
ilistcap.bvisible2['list.saveas']:=bol1;
ilistcap.bvisible2['list.new']:=bol1;
ilistcap.bvisible2['list.cut']:=bol1;
ilistcap.bvisible2['list.copy']:=bol1;
ilistcap.bvisible2['list.copyall']:=bol1;
ilistcap.bvisible2['list.replace']:=bol1;//19apr2022

inavcap.benabled2['list.addfile']:=playlist__canaddfile;//19aug2025

ititlebar.benabled2['vol.up']   :=(xvollevel<ivol.max);
ititlebar.benabled2['vol.100']  :=(xvollevel<>100);
ititlebar.benabled2['vol.dn']   :=(xvollevel>ivol.min);

ititlebar.benabled2['speed.up'] :=(ispeed.val<ispeed.max);
ititlebar.benabled2['speed.100']:=(ispeed.val<>100);
ititlebar.benabled2['speed.dn'] :=(ispeed.val>ispeed.min);

with ijumptitle do
begin
bmarked2['nav.toggle']:=xshownav;
bmarked2['info.toggle']:=ishowinfo;
bmarked2['settings.toggle']:=ishowsettings;
end;

with inavcap do
begin
benabled2['nav.prev']:=inav.canprev;
benabled2['nav.next']:=inav.cannext;
end;

//play
bol1:=iplaying;//imidi.playing;
with rootwin.xhead do
begin
benabled2['rewind']:=(mid_pos>1);
benabled2['stop']:=bol1;
bflash2['play']:=bol1;
bmarked2['play']:=bol1;
benabled2['fastforward']:=(mid_len<>0);
benabled2['prev']:=canprev;//23mar2022
benabled2['next']:=cannext;
bmarked2['nav.toggle']:=xshownav;
//bflash2['nav.toggle']:=xshownav;
end;

//.autotrim
if (mid_trimtolastnote<>iautotrim) then mid_settrimtolastnote(iautotrim);

//.show columns
rootwin.xcols.vis[inavcol]:=xshownav;
rootwin.xcols.vis[iinfcol]:=ishowinfo;

if (isettingspanel.visible<>ishowsettings) then//15aug2025
   begin
   isettingspanel.visible :=ishowsettings;
   xmustalign             :=true;
   end;

//.jump
ijump.status:=ijumpstatus;
ijump.olarge:=ilargejump;
ijumptitle.olarge:=ilargejumptitle;

//.xmustalign
if xmustalign then gui.fullalignpaint;
except;end;
end;

function tapp.findlistcmd(n:string;var xcaption,xhelp,xcmd:string;var xtep:longint;var xenabled:boolean;xextendedlables:boolean):boolean;
var
   str1:string;

   procedure xset(acap,ahelp,acmd:string;atep:longint;aenabled:boolean);
   begin
   xcaption:=acap;
   xhelp:=ahelp;
   xcmd:=acmd;
   xtep:=atep;
   xenabled:=aenabled;
   result:=true;
   end;
begin
//defaults
result:=false;

try
n:=strlow(n);
xcaption:='';
xhelp:='';
xcmd:='';
xtep:=tepNone;
xenabled:=false;
str1:=insstr('...',xextendedlables);
//get
if (n='new')           then xset('New'+str1,'Create new playlist','list.new',tepNew20,iplaylist.cannew)
else if (n='edit')     then xset('Edit','Show edit menu','list.edit',tepEdit20,true)
else if (n='open')     then xset('Open'+str1,'Open playlist from file','list.open',tepOpen20,iplaylist.canopen)
else if (n='save as')  then xset('Save As'+str1,'Save playlist to file','list.saveas',tepSave20,iplaylist.cansave)
else if (n='cut')      then xset('Cut','Cut selected playlist item to Clipboard','list.cut',tepCut20,iplaylist.cancut)
else if (n='copy')     then xset('Copy','Copy selected playlist item to Clipboard','list.copy',tepCopy20,iplaylist.cancopy)
else if (n='copy all') then xset('Copy All','Copy entire playlist to Clipboard','list.copyall',tepCopy20,iplaylist.cancopyall)
else if (n='paste')    then xset('Paste','Paste playlist from Clipboard at end of current playlist','list.paste',tepPaste20,iplaylist.canpaste)
else if (n='replace')  then xset('Replace','Replace playlist with Clipboard playlist','list.replace',tepPaste20,iplaylist.canreplace)
else if (n='undo')     then xset('Undo','Undo last playlist change','list.undo',tepUndo20,iplaylist.canundo);
except;end;
end;

function tapp.playlist__canaddfile:boolean;
begin
result:=(not showplaylist) and (inav.valuestyle=nltFile);
end;

function tapp.getshowplaylist:boolean;
begin
result:=(ilistroot<>nil) and (ilistcap<>nil) and strmatch(ilistroot.page,ilistcap.opagename);
end;

procedure tapp.setshowplaylist(x:boolean);
begin
if (ilistroot<>nil) and (ilistcap<>nil) then ilistroot.page:=low__aorbstr(inavcap.opagename,ilistcap.opagename,x);
end;

function tapp.xonaccept(sender:tobject;xfolder,xfilename:string;xindex,xcount:longint):boolean;
begin
result:=true;

try
if io__fileexists(xfilename) then
   begin
   if not ionacceptonce then
      begin
      ionacceptonce:=true;
      iplaylist.xfillundo;//fill undo
      showplaylist:=true;//switch to play list mode - 20mar2022
      end;
   iplaylist.xaddone(-1,'',xfilename);
   end;
if ionacceptonce and (xindex>=(xcount-1)) then iplaylist.xmask(true);
//reset
if (xindex>=(xcount-1)) then ionacceptonce:=false;//done
except;end;
end;

function tapp.xintroms:longint;
begin
case iintro of
1:result:=2000;
2:result:=5000;
3:result:=10000;
4:result:=30000;
else result:=0;
end;
end;

function tapp.xffms:longint;
begin
case iff of
1:result:=2000;
2:result:=5000;
3:result:=10000;
4:result:=30000;
else result:=1000;
end;
end;

procedure tapp.xshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
label
   skipend;
var
   p,xholdindex,xholdms:longint;

   procedure ladd(n:string);
   var
      xcaption,xhelp,xcmd:string;
      xtep:longint;
      xenabled:boolean;
   begin
   //check
   if (ilistcap=nil) then exit;
   if not findlistcmd(n,xcaption,xhelp,xcmd,xtep,xenabled,true) then
      begin
      showerror('List command not found "'+n+'"');
      exit;
      end;
   //get
   low__menuitem2(xmenudata,xtep,xcaption,xhelp,xcmd,100,aknone,xenabled);
   end;

   function ides(xsec:longint):string;
   begin
   case xsec of
   0:result:='Select to play entire midi (no intro mode)';
   else result:='Select to play first '+intstr32(xsec)+' seconds of midi';
   end;//case
   end;

   function fdes(xsec:longint):string;
   begin
   result:='Select to rewind and fast forward by '+intstr32(xsec)+' second'+insstr('s',xsec>=2);
   end;

begin
try
//check
if zznil(xmenudata,5000) then exit;

//menu history
xmenuname:='history.'+xstyle;


//main options
if (xstyle='') then
   begin
   low__menutitle(xmenudata,tepnone,'Play Options','Play options');
   if not showplaylist then low__menuitem2(xmenudata,tepRefresh20,'Refresh','Refresh list','refresh',100,aknone,true);
   low__menuitem2(xmenudata,tepStop20,'Stop','Stop playback','stop',100,aknone,iplaying);
   low__menuitem3(xmenudata,tepPlay20,'Play','Toggle playback','play',100,aknone,iplaying,true);
   low__menusep(xmenudata);
   low__menuitem3(xmenudata,tep__yes(iautoplay),'Play on Start','Ticked: Commence play on program start','autoplay',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__yes(iautotrim),'Trim Trailing Silence','Trim Trailing Silence | When ticked, trailing silence is removed from playback | The midi file is not modified','autotrim',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__yes(lshow),'Show Lyrics','Ticked: Show lyrics in the playback progress bar title','lshow',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__yes(lshowsep),'Hyphenate Lyrics','Ticked: Hyphenate the midi lyrics','lshowsep',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__yes(ialwayson),'Always on Midi','Ticked: Remain connected to midi device | Not Ticked: Disconnect from midi device after a short idle period','alwayson',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__yes(ianimateicon),'Animate Icon','Ticked: Animate icon whilst playing','animateicon',100,aknone,false,true);
   //.save as
   low__menuitem3(xmenudata,tepSave20,'Save Midi As...','Save selected midi to file','saveas',100,aknone,false,xcansaveas);

   //.intro
   low__menutitle(xmenudata,tepnone,'Intro Mode','Play first # seconds of midi');
   low__menuitem3(xmenudata,tep__tick(iintro=0),'Off',ides(0),'intro:0',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iintro=1),'2 secs',ides(2),'intro:1',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iintro=2),'5 secs',ides(5),'intro:2',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iintro=3),'10 secs',ides(10),'intro:3',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iintro=4),'30 secs',ides(30),'intro:4',100,aknone,false,true);
   //.ff and rr time
   low__menutitle(xmenudata,tepnone,'Rewind / Fast Forward By','Rewind / Fast Forward by # seconds');
   low__menuitem3(xmenudata,tep__tick(iff=0),'1 sec',fdes(1),'ff:0',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iff=1),'2 secs',fdes(2),'ff:1',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iff=2),'5 secs',fdes(5),'ff:2',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iff=3),'10 secs',fdes(10),'ff:3',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(iff=4),'30 secs',fdes(30),'ff:4',100,aknone,false,true);
   end
else if (xstyle='jump.menu') then
   begin
   low__menutitle(xmenudata,tepnone,'Playback Progress Bar','Playback progress bar options');
   low__menuitem3(xmenudata,tep__yes(ilargejumptitle),'Large Title','Ticked: Show large title/lyrics','largejumptitle',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__yes(ilargejump),'Large Bar','Ticked: Show large playback progress bar','largejump',100,aknone,false,true);

   low__menutitle(xmenudata,tepnone,'Status','Playback progress bar status');
   low__menuitem3(xmenudata,tep__tick(ijumpstatus=1),'Elapsed Time','Selected: Show elapsed time in playback progress bar','jumpstatus.1',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(ijumpstatus=2),'Remaining Time','Selected: Show remaining time in playback progress bar','jumpstatus.2',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__tick(ijumpstatus=0),'Off','Selected: Show no status in playback progress bar','jumpstatus.0',100,aknone,false,true);

   low__menutitle(xmenudata,tepnone,'Lyrics','Lyric options');
   low__menuitem3(xmenudata,tep__yes(lshow),'Show Lyrics','Ticked: Show lyrics in the playback progress bar title','lshow',100,aknone,false,true);
   low__menuitem3(xmenudata,tep__yes(lshowsep),'Hyphenate Lyrics','Ticked: Hyphenate the midi lyrics','lshowsep',100,aknone,false,true);
   goto skipend;
   end;

//play list options
if showplaylist or (xstyle='playlist') then
   begin
   low__menutitle(xmenudata,tepNotes20,'Play List Options','Play List options');
   ladd('new');
   ladd('open');
   ladd('save as');
   low__menusep(xmenudata);
   ladd('cut');
   ladd('copy');
   ladd('copy all');
   ladd('paste');
   ladd('replace');
   ladd('undo');
   low__menusep(xmenudata);
   low__menuitem3(xmenudata,tep__yes(ishowlistlinks),'Show Links on Toolbar','Ticked: Show links on toolbar','list.showlinks',100,aknone,false,true);
   end;

skipend:
except;end;
end;

function tapp.xlistfilename:string;
begin
if       showplaylist             then result:=ilist.xgetval2(ilist.itemindex)
else if (inav.valuestyle=nltFile) then result:=inav.value
else                                   result:='';
end;

function tapp.xcansaveas:boolean;
begin
result:=(xlistfilename<>'');
end;

procedure tapp.xsaveas;
var
   str1,sf,df,dext,e:string;
begin
//init
sf:=xlistfilename;
df:=io__extractfilepath(strdefb(ilastsavefilename,sf))+io__extractfilename(sf);
dext:=io__readfileext_low(df);
str1:='';

//get
if gui.popsave(df,dext,'',str1) then
   begin
   ilastsavefilename:=df;
   if not io__copyfile(sf,df,e) then gui.poperror('',e);
   end;
end;

function tapp.xshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
begin
if strmatch(strcopy1(xcode2,1,4),'nav.') then result:=false
else
   begin
   result:=true;//handled
   xcmd(nil,0,xcode2);
   end;
end;

procedure tapp.xfillinfo;
begin

case showplaylist of
false:if zzok(inav,7320) then inav.findinfo(iselstart,iselcount,idownindex,inavindex,ifolderindex,ifileindex,inavcount,ifoldercount,ifilecount,iisnav,iisfolder,iisfile);
true:iisfile:=(ilastfilename<>'')
end;//case

low__iroll(iinfoid,1);

end;

function tapp.xmasklist:string;
label
   redo;
var
   xonce,xforce:boolean;
begin
//init
result:='';

try
xonce:=true;
xforce:=false;
//get
redo:
if xforce or iformats.vals[0] then result:=result+'*.mid;';
if xforce or iformats.vals[1] then result:=result+'*.midi;';
if xforce or iformats.vals[2] then result:=result+'*.rmi;';
//check
if xonce and (result='') then
   begin
   xonce:=false;
   xforce:=true;
   goto redo;
   end;
except;end;
end;

function tapp.xfull_mask:string;
begin
result:='*.mid;*.rmi;*.midi';
end;

procedure tapp.xnav_mask;
var
   v:string;
begin
try
v:=xmasklist;
if (v<>inav.omasklist) then inav.omasklist:=v;
except;end;
end;

procedure tapp.xloadsettings;
var
   a:tvars8;
   e,xname:string;
begin
try
//defaults
a:=nil;
//check
if zznil(prgsettings,5001) then exit;
//init
a:=vnew2(950);
//filter
a.b['show.list']             :=prgsettings.bdef('show.list',false);//20mar2022
a.i['intro']                 :=prgsettings.idef('intro',0);
a.i['ff']                    :=prgsettings.idef('ff',0);//19apr2022
a.i['midvol']                :=prgsettings.idef('midvol',100);
a.b['autoplay']              :=prgsettings.bdef('autoplay',true);
a.b['autotrim']              :=prgsettings.bdef('autotrim',false);
a.b['largejump']             :=prgsettings.bdef('largejump',(not vicompact));
a.b['largejumptitle']        :=prgsettings.bdef('largejumptitle',(not vicompact));
a.b['lshow']                 :=prgsettings.bdef('lshow',true);
a.b['alwayson']              :=prgsettings.bdef('alwayson',false);
a.b['animateicon']           :=prgsettings.bdef('animateicon',true);//30apr2022
a.b['list.showlinks']        :=prgsettings.bdef('list.showlinks',false);//27mar2022
a.b['lshowsep']              :=prgsettings.bdef('lshowsep',false);
a.i['speed']                 :=prgsettings.idef('speed',100);
a.i['mode']                  :=prgsettings.idef('mode',2);
a.i['style']                 :=prgsettings.idef('style',0);
a.i['deviceindex']           :=prgsettings.idef('deviceindex',0);
a.i['formats']               :=prgsettings.idef('formats',7);
a.s['folder']                :=prgsettings.sdef('folder','!:\');//sample drive
a.s['name']                  :=io__extractfilename(prgsettings.sdef('name',''));
a.s['playlist.filename']     :=prgsettings.sdef('playlist.filename','');
a.i['playlist.index']        :=prgsettings.idef('playlist.index',0);
a.b['shownav']               :=prgsettings.bdef('shownav',true);
a.b['showinfo']              :=prgsettings.bdef('showinfo',true);
a.b['showsettings']          :=prgsettings.bdef('showsettings',true);//15aug2025
a.i['jumpstatus']            :=prgsettings.idef('jumpstatus',1);

//nav
inav.xfromprg2('nav',a);//prg -> nav -> a

//get
lshow                        :=a.b['lshow'];
lshowsep                     :=a.b['lshowsep'];
ialwayson                    :=a.b['alwayson'];//23mar2022
ianimateicon                 :=a.b['animateicon'];//30apr2022
ishowlistlinks               :=a.b['list.showlinks'];
iintro                       :=frcrange32(a.i['intro'],0,4);
iff                          :=frcrange32(a.i['ff'],0,4);//19apr2022
mmsys_mid_basevol            :=frcrange32(a.i['midvol'],0,200);
ispeed.val                   :=frcrange32(a.i['speed'],10,1000);
imode.val                    :=frcrange32(a.i['mode'],0,mmMax);
istyle.val                   :=frcrange32(a.i['style'],0,3);
iformats.val                 :=a.i['formats'];
ishownav                     :=a.b['shownav'];
ishowinfo                    :=a.b['showinfo'];
ishowsettings                :=a.b['showsettings'];
ijumpstatus                  :=frcrange32(a.i['jumpstatus'],0,2);
xnav_mask;
xname:=a.s['name'];
case (xname<>'') of
true:inav.value              :=io__readportablefilename(io__asfolderNIL(a.s['folder']))+xname;//focus the previously playing track - 20feb2022
false:inav.folder            :=io__readportablefilename(io__asfolderNIL(a.s['folder']));
end;

//.playlist
iplaylist.partmask           :=xmasklist;
iplaylist.xopen2(low__platprgext('m3u'),a.i['playlist.index'],false,false,e);
xmustsaveplaylist;//don't save now we've loaded it - 25mar2022

//.other
ilargejump                   :=a.b['largejump'];
ilargejumptitle              :=a.b['largejumptitle'];
iautoplay                    :=a.b['autoplay'];//do after
iautotrim                    :=a.b['autotrim'];//11jan2025
showplaylist                 :=a.b['show.list'];

//sync
prgsettings.data             :=a.data;
xupdatebuttons;

except;end;

//free
freeobj(@a);

//mark as loaded
iloaded:=true;

end;

procedure tapp.xsavesettings;
begin
xsavesettings2(true);
end;

procedure tapp.xsavesettings2(xforce:boolean);
var
   a:tvars8;
   e:string;
begin
try
//check
if not iloaded then exit;
//defaults
a:=nil;
a:=vnew2(951);
//get
a.b['show.list']             :=showplaylist;//20mar2022
a.i['intro']                 :=frcrange32(iintro,0,4);
a.i['ff']                    :=frcrange32(iff,0,4);//19apr2022
a.i['midvol']                :=frcrange32(mmsys_mid_basevol,0,200);
a.b['largejump']             :=ilargejump;
a.b['largejumptitle']        :=ilargejumptitle;
a.b['autoplay']              :=iautoplay;
a.b['autotrim']              :=iautotrim;
a.b['lshow']                 :=lshow;
a.b['lshowsep']              :=lshowsep;
a.b['alwayson']              :=ialwayson;
a.b['animateicon']           :=ianimateicon;
a.b['list.showlinks']        :=ishowlistlinks;
a.i['speed']                 :=ispeed.val;
a.i['mode']                  :=imode.val;
a.i['style']                 :=istyle.val;
a.i['formats']               :=iformats.val;
a.s['folder']                :=io__makeportablefilename(inav.folder);
a.s['name']                  :=io__extractfilename(inav.value);
a.b['shownav']               :=ishownav;
a.b['showinfo']              :=ishowinfo;
a.b['showsettings']          :=ishowsettings;
a.i['jumpstatus']            :=ijumpstatus;

a.i['playlist.index']        :=ilist.itemindex;
if xmustsaveplaylist or xforce then iplaylist.xsave2(low__platprgext('m3u'),false,e);//25mar2022
inav.xto(inav,a,'nav');

//set
prgsettings.data             :=a.data;
siSaveprgsettings;
except;end;

//free
freeobj(@a);

end;

function tapp.xmustsaveplaylist:boolean;
begin
result:=low__setstr(iplaylistREF,intstr32(iplaylist.id));
end;

procedure tapp.xautosavesettings;
var
   str1:string;
begin
try
//check
if not iloaded then exit;
//get
str1:=
 intstr32(mmsys_mid_basevol)+'|'+intstr32(iplaylist.id)+'|'+intstr32(iintro)+'|'+intstr32(iff)+'|'+bolstr(ishowlistlinks)+bolstr(showplaylist)+bolstr(lshow)+bolstr(ianimateicon)+bolstr(ialwayson)+bolstr(lshowsep)+bolstr(ishownav)+bolstr(ishowinfo)+bolstr(ilargejumptitle)+bolstr(ilargejump)+bolstr(iautoplay)+bolstr(iautotrim)+'|'+intstr32(ijumpstatus)+'|'+
 intstr32(ispeed.val)+'|'+intstr32(vimididevice)+'|'+intstr32(istyle.val)+'|'+
 intstr32(imode.val)+'|'+intstr32(inav.sortstyle)+'|'+intstr32(iformats.val)+'|'+inav.folder;

if low__setstr(isettingsref,str1) then xsavesettings2(false);
except;end;
end;

function tapp.canprev:boolean;
begin
if showplaylist then result:=(ilist.itemindex>=1) else result:=(inav.itemindex>=1);
end;

function tapp.cannext:boolean;
begin
if showplaylist then result:=(ilist.itemindex<(ilist.count-1)) else result:=(inav.itemindex<(inav.totalcount-1));
end;

procedure tapp.__onclick(sender:tobject);
begin
xcmd(sender,0,'');
end;

procedure tapp.xcmd0(xcode2:string);
begin
xcmd(nil,0,xcode2);
end;

procedure tapp.xcmd(sender:tobject;xcode:longint;xcode2:string);
label
   skipend;
var
   a:tstr8;
   xresult,zok:boolean;
   v,e:string;
   v32:longint;

   function mv(const x:string):boolean;
   begin
   result:=strm(xcode2,x,v,v32);
   end;

   function m(const x:string):boolean;
   begin
   result:=strmatch(x,xcode2);
   end;

begin//use for testing purposes only - 15mar2020
//defaults
xresult :=true;
e       :=gecTaskfailed;
v       :='';
v32     :=0;

try
a:=nil;
//init
zok:=zzok(sender,7455);
if zok and (sender is tbasictoolbar) then
   begin
   //ours next
   xcode:=(sender as tbasictoolbar).ocode;
   xcode2:=strlow((sender as tbasictoolbar).ocode2);
   //nav toolbar handler 1st
   if (xcode2<>'nav.refresh') then
      begin
      if inav.xoff_toolbarevent(sender as tbasictoolbar) then goto skipend;
      end;
   end
else if zok and ((sender is tbasicnav) or (sender=ilist)) then
   begin
   if gui.mousedbclick and vidoubleclicks and (not iplaying) and (inav.valuestyle=nltFile) then imustplay:=true;
   goto skipend;
   end
else if zok and (sender=ijump) then
   begin
   imustpertpos:=ijump.hoverpert;
   goto skipend;
   end;

//get
if m('max') then
   begin
   if (gui.state='+') then gui.state:='n' else gui.state:='+';
   end
else if m('refresh') or m('nav.refresh') then//override "inav" refresh without our own
   begin
   inav.reload;
   ilastfilename:='';
   end
else if m('home') then
   begin
   inav.folder:='';
   ilastfilename:='';
   end
else if m('lshow')          then lshow:=not lshow
else if m('lshowsep')       then lshowsep:=not lshowsep
else if m('alwayson')       then ialwayson:=not ialwayson//23mar2022
else if m('animateicon')    then ianimateicon:=not ianimateicon//30apr2022
else if mv('intro:')        then iintro:=frcrange32(v32,0,4)
else if mv('ff:')           then iff:=frcrange32(v32,0,4)
else if m('list.showlinks') then ishowlistlinks:=not ishowlistlinks
else if m('list.edit')      then ilist.showmenu2('playlist')
else if m('list.undo')      then xresult:=iplaylist.undo(e)
else if m('list.new')       then xresult:=iplaylist.new(e)
else if m('list.cut')       then xresult:=iplaylist.cut(e)//20mar2022
else if m('list.copy')      then xresult:=iplaylist.copy(e)
else if m('list.copyall')   then xresult:=iplaylist.copyall(e)
else if m('list.paste')     then xresult:=iplaylist.paste(e)
else if m('list.replace')   then xresult:=iplaylist.replace(e)
else if m('list.open')      then xresult:=iplaylist.open(e)
else if m('list.saveas')    then xresult:=iplaylist.save(e)
else if m('list.addfile')   then xresult:=iplaylist.addfile(inav.value,e)
else if m('show.list')      then showplaylist:=true
else if m('show.folder')    then showplaylist:=false
else if m('nav.toggle')     then ishownav:=not ishownav
else if m('info.toggle')    then ishowinfo:=not ishowinfo
else if m('settings.toggle') then ishowsettings:=not ishowsettings//15aug2025

else if m('vol.up')         then ivol.val:=ivol.val+5
else if m('vol.100')        then ivol.val:=100
else if m('vol.dn')         then ivol.val:=ivol.val-5

else if m('speed.up')       then ispeed.val:=ispeed.val+2
else if m('speed.100')      then ispeed.val:=100
else if m('speed.dn')       then ispeed.val:=ispeed.val-2

else if m('menu') then
   begin
   if showplaylist          then ilist.showmenu else inav.showmenu;
   end

else if m('jump.menu')      then ilist.showmenu2(xcode2)

else if m('prev') then
   begin
   if showplaylist then
      begin
      ilist.notidle;
      ilist.itemindex:=frcmin32(ilist.itemindex-1,0);
      end
   else
      begin
      inav.notidle;
      inav.itemindex:=frcmin32(inav.itemindex-1,0);
      end;
   end

else if m('next') then
   begin
   if showplaylist then
      begin
      ilist.notidle;
      ilist.itemindex:=frcmax32(ilist.itemindex+1,frcmin32(ilist.count-1,0));
      end
   else
      begin
      inav.notidle;
      inav.itemindex:=inav.itemindex+1;
      end;
   end

else if m('rewind')         then mid_setpos(mid_pos-xffms)//10mar2021
else if m('fastforward')    then mid_setpos(mid_pos+xffms)//10mar2021
else if m('stop')           then imuststop:=true

else if m('play') then
   begin
   case iplaying of
   true:imuststop:=true;
   false:imustplay:=true;
   end;//case
   end

else if m('largejumptitle') then ilargejumptitle:=not ilargejumptitle
else if m('largejump')      then ilargejump:=not ilargejump

else if m('autoplay')       then iautoplay:=not iautoplay//16apr2021
else if m('autotrim')       then iautotrim:=not iautotrim//11jan2025
else if m('saveas')         then xsaveas

else if m('folder') then
   begin
   if (inav.folder<>'')     then runLOW(inav.folder,'');
   end

else if mv('jumpstatus.')   then ijumpstatus:=frcrange32(v32,0,2)

else
   begin
   if system_debug then showtext('Unknown Command>'+xcode2+'<<');
   end;

skipend:
except;end;
try
str__free(@a);
xupdatebuttons;
if not xresult then gui.poperror('',e);
except;end;
end;

procedure tapp.__ontimer(sender:tobject);//._ontimer
label
   skipend;
var
   bol1:boolean;
begin
try

//timer100
if (slowms64>=itimer100) and iloaded then
   begin

   //play management
   case showplaylist of
   false:if mm_playmanagement('mid',imode.val,xintroms,imuststop,imustplay,iplaying,bol1,imustpertpos,imustpos,ilastpos,ilastfilename,inav,nil,'',ijump) and bol1 then xfillinfo;
   true:if mm_playmanagement('mid',imode.val,xintroms,imuststop,imustplay,iplaying,bol1,imustpertpos,imustpos,ilastpos,ilastfilename,nil,ilist,'',ijump) and bol1 then xfillinfo;
   end;

   //speed
   if (not gui.mousedown) and (mid_speed<>ispeed.val) then mid_setspeed(ispeed.val);

   //style
   if (not gui.mousedown) and synth_showstyle and (mid_style<>istyle.val) then mid_setstyle(istyle.val);

   //lyric
   if low__setstr(ilyricref,bolstr(lshow)+bolstr(lshowsep)+bolstr(mid_lyriccount>=1)+bolstr(iplaying)+'|'+intstr32(mid_pos)+'|'+intstr32(mid_len)+'|'+ilastfilename) then
      begin
      case lshow and (mid_lyriccount>=1) of
      true:ijumptitle.caption:=ijumpcap+'  -  Lyrics:  '+mid_lyric(mid_pos,lshowsep);
      false:ijumptitle.caption:=ijumpcap;
      end;
      end;

   //animated icon
   if ianimateicon and mid_playing then rootwin.xhead.aniPlay;//30apr2022

   //reset
   itimer100:=slowms64+100;
   end;

//infotimer
if (slowms64>=iinfotimer) then
   begin

   //info
   if low__setstr(iinforef,intstr32(mid_datarate)+'|'+intstr32(vimididevice)+'|'+bolstr(mid_deviceactive)+bolstr(mid_keepopen)+bolstr(mid_loop)+bolstr(mid_playing)+'|'+k64(mid_midbytes)+'|'+intstr32(mid_speed)+'|'+intstr32(mid_tracks)+'|'+intstr32(mid_format)+'|'+k64(iinfoid)+'|'+k64(mid_pos)+'|'+intstr32(iintro)+'|'+k64(mid_len)+'|'+k64(xintroms)+'|'+ilasterror+'|'+ilastfilename) then iinfo.paintnow;

   //reset
   iinfotimer:=slowms64+350;

   end;

//timer350
if (slowms64>=itimer350) then
   begin
   //page
   xupdatebuttons;
   //nav
   inav.xoff_toolbarsync(rootwin.xhead);
   //reset
   itimer350:=slowms64+350;
   end;

//timer500
if (slowms64>=itimer500) then
   begin

   //links
   bol1:=clip__canpastetext;
   ilistcap.benabled2['list.paste']:=bol1;
   ilistcap.benabled2['list.replace']:=bol1;
   mid_setkeepopen(ialwayson);

   //savesettings
   xautosavesettings;

   //update list mask
   xnav_mask;
   iplaylist.partmask:=xmasklist;

   //reset
   itimer500:=slowms64+500;

   end;


//debug support
if system_debug then
   begin
   if system_debugFAST then rootwin.paintallnow;
   end;
if system_debug and system_debugRESIZE then
   begin
   if (system_debugwidth<=0) then system_debugwidth:=gui.width;
   if (system_debugheight<=0) then system_debugheight:=gui.height;
   //change the width and height to stress
   //was: if (random(10)=0) then gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   end;


skipend:

//can close audio system and app safely -> tell system it's safe to shutdown now - 10aug2025
if app__closeinited and mm_safetohalt then
   begin

   app__closepaused:=false;

   end;

except;end;
end;


function tapp.__oninfo(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
var
   int1,p,xfileindex,xfilecount,xintro,xfilesize,xpos,xlen,xspeed,spos,slen,strim:longint;
   xerrmsg,str1:string;
   bol1,xhavefile:boolean;

   function xfilter(x,xdef:string):string;
   begin
   if xhavefile then result:=x else result:=xdef;
   end;

   function s(xcount:longint):string;
   begin
   result:=insstr('s',xcount<>1);
   end;

begin
result:=true;

try
//init
xtep           :=tepFNew20;
xtepcolor      :=clnone;
xcaption       :='';
xcaplabel      :='';
xhelp          :='';
xcode2         :='';
xcode          :=0;
xshortcut      :=aknone;
xindent        :=0;//xindex*5;
xflash         :=false;//25mar2021
xenabled       :=true;
xtitle         :=false;//(xindex=3);
xsep           :=false;
xhavefile      :=iisfile;
xlen           :=1;//safe default
xpos           :=0;
xspeed         :=100;
slen           :=1;//safe default
spos           :=0;
strim          :=0;
xintro         :=xintroms;
xfilesize      :=mid_midbytes;

if xhavefile then
   begin

   xlen      :=frcmin32(mid_len,1);
   xpos      :=mid_pos;
   xspeed    :=frcmin32(mid_speed,1);

   //speed adjusted values
   slen      := frcmin32(trunc( xlen*(100/xspeed) ),1);
   spos      := trunc( (xpos/xlen)*slen );
   strim     := trunc( (mid_lenfull-mid_len)*(100/xspeed) );
   end;

case showplaylist of
true:begin
   xfileindex:=ilist.itemindex;
   xfilecount:=ilist.count;
   end;
else
   begin
   xfileindex:=ifileindex;
   xfilecount:=ifilecount;
   end;
end;//case

//.info
case xindex of
//technical
0:begin
   xtep:=tepnone;
   xcaption:='Technical';
   xtitle:=true;
   end;

1:begin

   int1:=mid_handlecount;

   case mid_deviceactive of
   true:str1:='Online' +insstr('  ( '+k64(int1)+' device'+insstr('s',int1<>1)+' in use ) ',int1>=1);
   else str1:='Offline'+insstr(' - failed to open midi device', mid_playing and (mid_outdevicecount>=1) );
   end;//case

   xcaption:='Device Status'+#9+str1;

   end;

2:begin

   int1:=mid_outdevicecount;

   case (int1>=1) of
   true:str1:=k64(int1)+' midi playback device'+s(int1)+' present';
   else str1:='ERROR: No midi playback devices present - no sound';
   end;//case

   xcaption:='Device Count'+#9+str1;

   end;

3:begin

   xerrmsg  :=insstr(' ( '+mid_timermsg+' )',mid_timercode<>0);
   xcaption :='Resolution'+#9+curdec(mid_msrate,2,false)+' ms / '+curdec(mid_mspert100,1,false)+'%'+xerrmsg;//15aug2025, 05mar2022

   end;

4:xcaption:='Name'+#9+xfilter(io__extractfilename(ilastfilename),'-');
5:xcaption:='Folder'+#9+xfilter(io__extractfilepath(ilastfilename),'-');
6:xcaption:='Size'+#9+xfilter(low__b(xfilesize,true)+'  ( '+low__mb(xfilesize,true)+' )','-');
7:xcaption:='File'+#9+xfilter(k64(1+xfileindex)+' / '+k64(xfilecount),'-');

8:begin
   int1:=mid_format;
   case int1 of
   0:str1:='Single Track';
   1:str1:='Multi-Track';
   else str1:='Not Supported';
   end;
   xcaption:='Format'+#9+xfilter(intstr32(int1)+' / '+str1,'-');
   end;

9:xcaption:='Tracks'+#9+xfilter(k64(mid_tracks),'-');
10:xcaption:='Messages'+#9+xfilter(k64(mid_msgssent)+' / '+k64(mid_msgs),'-');

//playback
11:begin
   xtep:=tepnone;
   xcaption:='Playback';
   xtitle:=true;
   end;
12:xcaption:='Elapsed'+#9+low__uptime(spos,(slen>=3600000),(slen>=60000),true,true,ijump.oms,#32);
13:xcaption:='Remaining'+#9+low__uptime(slen-spos,(slen>=3600000),(slen>=60000),true,true,ijump.oms,#32);
14:xcaption:='Total'+#9+low__uptime(slen,(slen>=3600000),(slen>=60000),true,true,ijump.oms,#32)+insstr(' ( '+curdec( (100/xspeed)*100 ,1,true)+'% )',slen<>xlen);
15:xcaption:='Trim'+#9+low__aorbstr('Off', low__uptime(strim,false,false,false,true,ijump.oms,#32)+' of silence', mid_trimtolastnote );
16:xcaption:='Intro Mode'+#9+low__aorbstr('Off','First '+k64(xintro div 1000)+' seconds',xintro>0);
17:xcaption:='Speed'+#9+k64(mid_speed)+'%';
18:xcaption:='State'+#9+low__aorbstr('Stopped','Playing',mid_playing);
else
   begin
   xtep:=tepnone;
   end;
end;//case
except;end;
end;

end.
