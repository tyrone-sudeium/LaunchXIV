//
//  LaunchXIVTests.swift
//  LaunchXIVTests
//
//  Created by Tyrone Trevorrow on 13/3/17.
//  Copyright © 2017 Tyrone Trevorrow. All rights reserved.
//

import XCTest
@testable import LaunchXIV

let testStoredHTML = """
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang=en-GB>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>FINAL FANTASY XIV Launcher</title>


<link rel="stylesheet" href="/oauth/content/css/mod_reborn_login.css?date=20160129" type="text/css" />
<link rel="shortcut icon" href="/oauth/content/image/common/favicon.ico" />

a






1c7e

<script>
<!--
// -------------------------------------------------------------------
// Event
// -------------------------------------------------------------------
var g_clickCheck = false;
var g_eventElementName = '_event';
function ctrEvent ( formName )
{
if (g_clickCheck)
{
//window.external.user('login=auth,ng,err,The data has already been sent.rnIf the screen still has not displayed after waiting a few moments, please refresh the page on your browser.');
return;
}

if (formName == null || formName =='')
formName = 'mainForm';
document.forms [ formName ].submit();
g_clickCheck = true;
ctrStartClickCheckResetTimer();
}

function ctrEventAction ( formName , actionName)
{
if (g_clickCheck)
{
//window.external.user('login=auth,ng,err,The data has already been sent.rnIf the screen still has not displayed after waiting a few moments, please refresh the page on your browser.');
return;
}

if (formName == null || formName =='')
formName = 'mainForm';
document.forms [ formName ].action = actionName;
document.forms [ formName ].submit();
g_clickCheck = true;
ctrStartClickCheckResetTimer();
}

// -------------------------------------------------------------------
// Reset Timer
// -------------------------------------------------------------------
var g_ctrClickCheckTimer;
function ctrResetClickCheck() {
g_clickCheck = false;
window.clearTimeout(g_ctrClickCheckTimer);
}
function ctrStartClickCheckResetTimer() {
g_ctrClickCheckTimer = window.setTimeout('ctrResetClickCheck()', 15*1000);
}

// -------------------------------------------------------------------
// Get Key Code
// -------------------------------------------------------------------
function ctrGetKeyCode(event){
var key;
if(event.keyCode != 0) {
key = event.keyCode;
} else{
key = event.charCode;
}
return key;
}
-->
</script>




<script type="text/javascript" src="/oauth/content/swk/ffxiv/swk.js"></script>

</head>
<body >












<script>
<!--
//初期フォーカス設定
window.onload = function(){

var sqexid = document.getElementById('sqexid');
// sqexid に値がない場合
if(sqexid.value == ""){
sqexid.focus();
}else{
// sqexid に値がある場合
document.getElementById('password').focus();
}
// ソフキーを初期化
swk.init({
// 画像パス指定
imagePath: "/oauth/content/swk/image",
show: function() {
// 開き時の処理を追加
window.external.user("softkey=1");
},
hide: function() {
// 閉じ時の処理を追加
window.external.user("softkey=0");
}
});


var node = document.getElementById('recaptcha_whatsthis_btn');
if(node){
//. リキャプチャのヘルプリンクにjavascriptを追加して、target,_blankを削除する
url = "javascript:window.external.user(\'link=" + "https://support.google.com/recaptcha/?hl=en" + "\')";
node.setAttribute("href", url);
node.removeAttribute("target");
node.onclick=null;
}
var elm = document.getElementById('recaptcha_privacy');
if(elm){
var items = elm.getElementsByTagName('a');
var node;
var cnt = items.length;
for(var i=0; i<cnt; i++){
node = items[i];
var url = node.href;
url = "javascript:window.external.user(\'link=" + url + "\')";
node.setAttribute("href", url);
node.setAttribute("target", "");
node.onclick=null;
}
}
var itemstep2 = document.getElementById( 'step2' ) ;
if(itemstep2){
itemstep2.style.display = 'none' ;
}
}
//入力中のテキストボックスの背景色を設定
function editColor( item_name )
{
var item =document.getElementsByName( item_name ) ;
item[ 0 ].style.backgroundColor = '#FFF9B2' ;
item[ 0 ].style.borderColor ='#F2B600';
}
//通常のテキストボックスの背景色を設定
function defaultColor( item_name )
{
var item = document.getElementsByName( item_name ) ;
item[ 0 ].style.backgroundColor = '#FFFFFF' ;
item[ 0 ].style.borderColor ='#7D7C7C';
}
//recaptha step続き
function stepchange()
{
var itemstep1 = document.getElementById( "step1" ) ;
itemstep1.style.display = 'none' ;
var itemstep2 = document.getElementById( "step2" ) ;
itemstep2.style.display = '' ;
}
//
function onEnterPressSubmit(event) {
if( ctrGetKeyCode(event) == 13 ){
var targets = new Array(2);
targets[0] = document.getElementById('sqexid');
targets[1] = document.getElementById('password');
//sqexidに入力がない場合はsqexidにフォーカス
if(targets[0] && targets[0].value == "") {
targets[0].focus();
}
//sqexidに入力があり、passwordに入力が無い場合はpasswordにフォーカス
if(targets[0] && targets[0].value != ""
&& ((targets[1] && targets[1].value == ""))) {
document.getElementById('password').focus();
}
if(targets[0] && targets[0].value != ""
&& ((targets[1] && targets[1].value != ""))) {

ctrEvent('mainForm','Submit');

}
return false;
}
}


-->
</script>

<form action="login.send" method="post" name="mainForm">


<input type="hidden" name="_STORED_" value="a5f06e5f47798101ac62bce3c650e276ef1a9863d0266d77ea3b1f8b209a2283965a37cf4ae1e657abea6037d93d0a53908dde6c2b199dd4f27148d6dc37cb1c72cacc101db097e604776b201211af21abf5744fe8819f30e11a9b4b1ba80e1a5c83fa22842f00c9fcc43d0b31208e93909fda8298dff852ccd860bf72939f9552d08094b2c3872b4f941a1f2f73ca8776b68f87959aec89a2caabedb40b5da2574e7eec6cb2556c3b85a98f8df39460c68fccaa7d816806ea5fd4570776343e92be2ac2e9eb9e22d04a9872377aa3f7118422496faf33a2beabcfd8a465a181d431338023f27c9f16b63a0358c2811029c680c58670bb3189aaf66e5f0ef24dc1a5128ff6e564e9fe8f1fe89f9388f7175b20f785f1aeb030517e65ae4cdfa2047b3beea896ffa9122a6cbb59f9a58be92770c56353fac39c">


<div id="contents">
<div id="headerArea">
<div id="logoArea" style="background-image: url(/oauth/content/image/common/ffxivarr/logo_login_ENFRDE.png)"></div>
</div>
<div id="step1">
<table class="frame1">

<tr class="mainContent">
<td class="text"><div class="textImg" style="background-image: url(/oauth/content/image/en/ffxivarr/login/sqexid.png)"></div></td>
<td class="textBox" onKeyPress="return onEnterPressSubmit(event);">
<input type="text" name="sqexid" id ="sqexid" value="" tabindex="1" maxLength="16"
style="character-type:alphabet;" onFocus="editColor(this.name)" onBlur="defaultColor(this.name)"/>
</td>

<td class="swkContent">
<!-- Swk key bord 挿入場所 -->
<a class="swk" rel="sqexid(4,128)" href="javascript:;" tabindex="6"></a>
</td>

</tr>

<tr class="mainContent">
<td class="text"><div class="textImg" style="background-image: url(/oauth/content/image/en/ffxivarr/login/password.png)"></div></td>
<td class="textBox"  onKeyPress="return onEnterPressSubmit(event);">
<input type="password" name="password" id="password" tabindex="2" autocomplete="off" maxLength="32" onFocus="editColor(this.name)" onBlur="defaultColor(this.name)"/>
</td>

<td class="swkContent">
<!-- Swk ke
382
y bord 挿入場所 -->
<a class="swk" rel="password(4,152)" href="javascript:;" tabindex="7"></a>
</td>

</tr>

<tr class="mainContent">
<td class="text"><div class="textImg" style="background-image: url(/oauth/content/image/en/ffxivarr/login/otp.png)"></div></td>
<td class="textBox" onKeyPress="return onEnterPressSubmit(event);">
<input type="password" name="otppw" id="otppw" tabindex="3" autocomplete="off" maxLength="6" onFocus="editColor(this.name)" onBlur="defaultColor(this.name)"/>
</td>
</tr>
</table>

<div id="linkeArea">
<table id="linkAreaContent" class="topSpace1">

<tr>
<td>
<a href="javascript:window.external.user('link=http://eu.square-enix.com/en/seaccount/otp')" style="background-image: url(/oauth/content/image/en/ffxivarr/login/aboutOtp.png); width:174px;"></a>
</td>
</tr>
451


<tr>
<td>
<a href="javascript:ctrEventAction('mainForm','login.reminder');" style="background-image: url(/oauth/content/image/en/ffxivarr/login/reminder.png); width:166px;"></a>
</td>
</tr>
</table>
</div>

<div id="btArea">
<table id="btAreaContent" class="topSpace1">
<tr>
<td>

<table>
<tr>
<td>
<input name="saveid" id="saveid" type="checkbox" value="1" tabindex="4" />
</td>
<td>
<label for="saveid">
<span>
<div style="width:180px; height:16px; background-image: url(/oauth/content/image/en/ffxivarr/login/autoLogin.png);"></div>
</span>
</label>
</td>
</tr>
</table>

</td>
</tr>
<tr>
<td>

<a href="javascript:ctrEvent('mainForm');" id="btLogin" class="button" tabindex="5" style="background-image: url(/oauth/content/image/en/ffxivarr/login/login.png)"></a>

</td>
</tr>
</table>
</div>
</div>

</div>
</form>

</body>
</html>
"""

// Dear hackers: before you get too excited about the SID in the data below, you should know
// it's just 56 characters worth of RANDOM data I generated. Have fun with it anyway!
let testSIDHTML = """

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang=en-US>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>FINAL FANTASY XIV Launcher</title>


<link rel="stylesheet" href="/oauth/content/css/mod_reborn_login.css?date=20160129" type="text/css" />
<link rel="shortcut icon" href="/oauth/content/image/common/favicon.ico" />






<script>
<!--
// -------------------------------------------------------------------
// Event
// -------------------------------------------------------------------
var g_clickCheck = false;
var g_eventElementName = '_event';
function ctrEvent ( formName )
{
if (g_clickCheck)
{
//window.external.user('login=auth,ng,err,The data has already been sent.rnIf the screen still has not displayed after waiting a few moments, please refresh the page on your browser.');
return;
}

if (formName == null || formName =='')
formName = 'mainForm';
document.forms [ formName ].submit();
g_clickCheck = true;
ctrStartClickCheckResetTimer();
}

function ctrEventAction ( formName , actionName)
{
if (g_clickCheck)
{
//window.external.user('login=auth,ng,err,The data has already been sent.rnIf the screen still has not displayed after waiting a few moments, please refresh the page on your browser.');
return;
}

if (formName == null || formName =='')
formName = 'mainForm';
document.forms [ formName ].action = actionName;
document.forms [ formName ].submit();
g_clickCheck = true;
ctrStartClickCheckResetTimer();
}

// -------------------------------------------------------------------
// Reset Timer
// -------------------------------------------------------------------
var g_ctrClickCheckTimer;
function ctrResetClickCheck() {
g_clickCheck = false;
window.clearTimeout(g_ctrClickCheckTimer);
}
function ctrStartClickCheckResetTimer() {
g_ctrClickCheckTimer = window.setTimeout('ctrResetClickCheck()', 15*1000);
}

// -------------------------------------------------------------------
// Get Key Code
// -------------------------------------------------------------------
function ctrGetKeyCode(event){
var key;
if(event.keyCode != 0) {
key = event.keyCode;
} else{
key = event.charCode;
}
return key;
}
-->
</script>




<script type="text/javascript" src="/oauth/content/swk/ffxiv/swk.js"></script>

</head>
<body >

















<form action="login.send" method="post" name="mainForm">




<script type="text/javascript">
//<!--
window.external.user("login=auth,ok,sid,fc39611bcdbb9d08b53b12783ca5c95e0e0b0b4ba76a8788cd46d2b8,terms,1,region,3,etmadd,0,playable,1,ps3pkg,0,maxex,2,product,1");
//-->
</script>


</form>

</body>
</html>


"""

class LaunchXIVTests: XCTestCase {
    func testStoredParser() {
        let queue = OperationQueue()
        let op = StoredParseOperation(html: testStoredHTML)
        let expect = XCTestExpectation()
        expect.expectedFulfillmentCount = 1
        op.completionBlock = {
            XCTAssertNotNil(op.result)
            XCTAssertNotEqual(op.result!, HTMLParseResult.error)
            guard case let HTMLParseResult.result(res) = op.result! else {
                XCTFail()
                return
            }
            XCTAssertEqual(res, "a5f06e5f47798101ac62bce3c650e276ef1a9863d0266d77ea3b1f8b209a2283965a37cf4ae1e657abea6037d93d0a53908dde6c2b199dd4f27148d6dc37cb1c72cacc101db097e604776b201211af21abf5744fe8819f30e11a9b4b1ba80e1a5c83fa22842f00c9fcc43d0b31208e93909fda8298dff852ccd860bf72939f9552d08094b2c3872b4f941a1f2f73ca8776b68f87959aec89a2caabedb40b5da2574e7eec6cb2556c3b85a98f8df39460c68fccaa7d816806ea5fd4570776343e92be2ac2e9eb9e22d04a9872377aa3f7118422496faf33a2beabcfd8a465a181d431338023f27c9f16b63a0358c2811029c680c58670bb3189aaf66e5f0ef24dc1a5128ff6e564e9fe8f1fe89f9388f7175b20f785f1aeb030517e65ae4cdfa2047b3beea896ffa9122a6cbb59f9a58be92770c56353fac39c")
            expect.fulfill()
        }
        queue.addOperation(op)
        wait(for: [expect], timeout: 5.0)
    }
    
    func testSidParser() {
        let queue = OperationQueue()
        let op = SidParseOperation(html: testSIDHTML)
        let expect = XCTestExpectation()
        expect.expectedFulfillmentCount = 1
        op.completionBlock = {
            XCTAssertNotNil(op.result)
            XCTAssertNotEqual(op.result!, HTMLParseResult.error)
            guard case let HTMLParseResult.result(res) = op.result! else {
                XCTFail()
                return
            }
            XCTAssertEqual(res, "login=auth,ok,sid,fc39611bcdbb9d08b53b12783ca5c95e0e0b0b4ba76a8788cd46d2b8,terms,1,region,3,etmadd,0,playable,1,ps3pkg,0,maxex,2,product,1")
            expect.fulfill()
        }
        queue.addOperation(op)
        wait(for: [expect], timeout: 5.0)
    }
    
}
