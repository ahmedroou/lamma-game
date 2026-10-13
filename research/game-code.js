ao(){return new A.ZB(null,null)}}
A.ZB.prototype={
aD(){var s,r=this,q=null
r.aP()
s=r.d=A.bX(q,q,q,q,r)
s.bJ()
s=s.cQ$
s.b=!0
s.a.push(new A.aze(r))},
l(){var s=this.d
s===$&&A.a()
s.l()
this.af5()},
O(a){var s=null,r=this.d
r===$&&A.a()
return new A.Ft(new A.PK("assets/logoanimation/logoanimation.json",s,s,s,s,!1),new A.azd(this),r,s,s,s,s,s,s,s,s,s,B.bs,s,s,s,s,s,s,s)}}
A.aze.prototype={
$1(a){if(a===B.a7)this.a.a.c.$0()},
$S:8}
A.azd.prototype={
$1(a){var s,r=this.a.d
r===$&&A.a()
s=a.c
r.e=A.cT(0,B.d.T((s.c-s.b)/s.d*1000),0)
r.bL()},
$S:596}
A.NY.prototype={
l(){var s=this,r=s.ba$
if(r!=null)r.M(s.gfl())
s.ba$=null
s.aJ()},
bA(){this.ce()
this.c5()
this.fm()}}
A.Us.prototype={
O(a){return new A.HL(new A.anx(),!0,!0,B.a0H,null)}}
A.anx.prototype={
$2(a,b){var s=null
return new A.ut(new A.qf(s),"3 Krooot",A.Ah(s,s,B.Vv,!0),!1,s)},
$S:597}
A.tZ.prototype={
ao(){var s="openrelayproject",r=t.N,q=t.z
return new A.L5($.P6(),A.v(r,t.Lr),A.b([],t.iO),A.v(r,t.H1),A.V(["iceServers",A.b([A.V(["url","stun:stun.l.google.com:19302"],r,r),A.V(["url","stun:stun1.l.google.com:19302"],r,r),A.V(["url","turn:openrelay.metered.ca:80","username",s,"credential",s],r,r)],t.m0),"sdpSemantics","unified-plan"],r,q),A.v(r,q),A.v(r,q),A.b([],t.s),[],A.b9G(),B.f.j(Date.now()),A.b2(r),null,null)}}
A.L5.prototype={
D1(){var s=0,r=A.t(t.H),q=this
var $async$D1=A.o(function(a,b){if(a===1)return A.p(b,r)
for(;;)switch(s){case 0:s=2
return A.n(q.R8.vP(new A.PL("tick.mp3",null),B.YA),$async$D1)
case 2:return A.q(null,r)}})
return A.r($async$D1,r)},
xq(a,b){return this.auE(a,b)},
auE(a,b){var s=0,r=A.t(t.H),q=1,p=[],o=this,n,m,l,k,j,i,h
var $async$xq=A.o(function(c,d){if(c===1){p.push(d)
s=q}for(;;)switch(s){case 0:s=o.y.ad(a)?2:3
break
case 2:A.en("🚀 تفريغ صندوق الانتظار للاعب: "+a)
l=o.y.h(0,a)
l.toString
l=J.bh(l)
case 4:if(!l.B()){s=5
break}n=l.gN()
q=7
s=10
return A.n(b.qV(n),$async$xq)
case 10:q=1
s=9
break
case 7:q=6
h=p.pop()
m=A.a7(h)
j="⚠️ خطأ أثناء إضافة الـ ICE المتأخر: "+A.j(m)
i=$.a8L
if(i==null)A.a8K(j)
else i.$1(j)
s=9
break
case 6:s=1
break
case 9:s=4
break
case 5:o.y.G(0,a)
case 3:return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$xq,r)},
Xa(a){var s,r,q,p,o="imageUrl"
if(a.h(0,o)!=null){s=J.b7(a.h(0,o))
r=B.c.b7(s,"http")?s:"https://api.3krooot.com"+s}else{q=a.h(0,"category")
if(q==null)p=null
else{q=B.c.d1(J.b7(q))
q=A.h8(q," ","_")
p=q}r="https://api.3krooot.com/assets/category/"+(p==null?"General":p)+".png"}return r+"?v="+this.rx},
auA(a){var s,r=null
if(B.c.D(a.toLowerCase(),".svg"))return
s=this.c
s.toString
A.boz(new A.m2(r,a,r,1,r,r,r,r,B.rA),s)},
Xf(a,b,c){var s,r,q,p,o=this.ax
if(o==null)s=null
else{o=o.h(0,"text")
o=o==null?null:J.b7(o)
s=o}if(s==null)s=""
o=this.as.h(0,"text")
r=o==null?null:J.b7(o)
if(r==null)r="لا يوجد تعليمات"
o=new A.aEK(this,b-24*$.c().gq()-30*$.c().gq())
q=o.$1(s)
o=o.$1(r)
p=c*0.75
return B.d.c6(Math.max(A.j_(q),A.j_(o))+40*$.c().gp(),Math.min(150*$.c().gp(),p),p)},
ahP(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=this,e=null,d=f.ax
if(d==null)return f.UV()
s=J.b7(d.h(0,"text"))
d=f.ax.h(0,"category")
r=d==null?e:J.b7(d)
d=f.ax.h(0,"level")
q=d==null?e:J.b7(d).toLowerCase()
if(q==null)q=""
if(B.c.D(q,"صعب")||q==="3"||q==="hard")p=B.ak
else p=B.c.D(q,"سهل")||q==="1"||q==="easy"?B.bk:B.bS
d=f.ax
d.toString
o=f.Xa(d)
d=$.c()
d=A.ay(20*Math.min(d.gq(),d.gp()))
n=$.c()
n=Math.min(n.gq(),n.gp())
n=A.b([new A.be(0,B.H,B.ic,new A.h(0,4*$.c().gp()),8*n)],t.V)
m=$.c().gp()
l=A.nR("assets/logo.png",e,e,50*$.c().gp(),e)
k=r==null?"":r
k=A.a6(k.toUpperCase(),e,e,e,e,e,e,e,A.Z(e,e,B.pS,e,e,e,e,e,"FFHekaya",e,e,f.hu(35),e,e,B.o,e,e,!0,e,1.2,e,e,e,e,e,e),B.N,e,e)
j=A.aa(e,5*$.c().gp(),e)
i=$.c()
i=20*Math.min(i.gq(),i.gp())
h=$.c()
h=20*Math.min(h.gq(),h.gp())
g=t.p
return A.ag(e,A.bf(A.b([new A.bi(new A.S(0,12*m,0,0),l,e),k,j,A.bP(A.no(new A.d3(B.G,B.G,new A.aF(i,i),new A.aF(h,h)),A.cU(B.aQ,A.b([A.qz(0,A.ag(e,e,B.j,e,e,new A.ar(e,e,e,e,e,new A.fc(B.bg,B.c8,B.at,A.b([A.U(B.d.T(229.5),p.m()>>>16&255,p.m()>>>8&255,p.m()&255),A.U(0,p.m()>>>16&255,p.m()>>>8&255,p.m()&255)],t.W),e,e),e,B.u),e,e,e,e,e,e,e)),A.qz(0,f.ahF(o)),A.qz(0,A.Fe(new A.aEz(f,s)))],g),B.D,B.ag)),1)],g),B.ce,B.r,B.t),B.j,e,e,new A.ar(B.ie,e,e,d,n,e,e,B.u),e,e,e,e,e,e,e)},
Ve(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=this,d=null,c="assets/logo.png",b="FFHekaya"
if(!a){s=$.c()
s=A.ay(20*Math.min(s.gq(),s.gp()))
r=A.bo(B.B,2*$.c().gq())
return A.ag(d,A.cc(A.nR(c,d,B.bs,d,100*$.c().gq()),d,d),B.j,d,d,new A.ar(d,d,r,s,d,B.rT,d,B.u),d,d,d,d,d,d,d)}q=e.as.h(0,"text")
if(q==null)q="لا يوجد تعليمات"
p=e.as.h(0,"effect")
if(p==null)p="none"
s=p!=="double_or_nothing"
o=(!s||p==="all_in_bet")&&e.y1==="none"
n=p==="coin_multiplier"||p==="coin_decides_fate"
r=$.c()
r=A.ay(20*Math.min(r.gq(),r.gp()))
m=$.c().gp()
l=A.nR(c,d,d,50*$.c().gp(),d)
k=A.a6("TWIST",d,d,d,d,d,d,d,A.Z(d,d,B.B,d,d,d,d,d,b,d,d,e.hu(50),d,d,B.o,d,d,!0,d,1.2,d,d,d,d,d,d),B.N,d,d)
j=A.aa(d,5*$.c().gp(),d)
i=$.c()
i=20*Math.min(i.gq(),i.gp())
h=$.c()
h=20*Math.min(h.gq(),h.gp())
g=t.p
g=A.b([A.bf(A.b([new A.bi(new A.S(0,12*m,0,0),l,d),k,j,A.bP(A.no(new A.d3(B.G,B.G,new A.aF(i,i),new A.aF(h,h)),A.cU(B.aQ,A.b([A.qz(0,A.mt(A.b0h("assets/twist.svg",B.bs,d,new A.aED(),d),0.9)),A.qz(0,A.Fe(new A.aEE(e,q)))],g),B.D,B.ag)),1)],g),B.ce,B.r,B.t)],g)
if(o){s=$.c().gp()
g.push(A.eu(d,e.aht(),d,d,0,0,70*s,d))}else if((!s||p==="all_in_bet")&&e.y1!=="none"){s=$.c().gp()
m=20*$.c().gq()
l=6*$.c().gp()
k=e.y1==="accepted"?B.kM:B.ig
j=$.c()
j=A.ay(12*Math.min(j.gq(),j.gp()))
i=e.y1==="accepted"
h=A.bo(i?B.fx:B.bE,1)
i=i?"تم قبول الرهان":"لم يتم الرهان"
f=e.hu(35)
g.push(A.eu(d,A.cc(A.ag(d,A.a6(i,d,d,d,d,d,d,d,A.Z(d,d,e.y1==="accepted"?B.pH:B.I,d,d,d,d,d,b,d,d,f,d,d,B.o,d,d,!0,d,d,d,d,d,d,d,d),d,d,d),B.j,d,d,new A.ar(k,d,h,j,d,d,d,B.u),d,d,d,new A.S(m,l,m,l),d,d,d),d,d),d,d,0,0,80*s,d))}else if(n){s=$.c().gp()
g.push(A.eu(d,e.ahG(),d,d,0,0,60*s,d))}return A.ag(d,A.cU(B.aQ,g,B.D,B.jN),B.j,d,d,new A.ar(d,d,d,r,d,B.rT,d,B.u),d,d,d,d,d,d,d)},
hu(a){var s,r=this.c
r.toString
s=A.bS(r,null,t.w).w.a.a
if(s>=1200)return $.c().L(a)
else return $.c().L(a*(1+(1200-s)/1200*2))},
aD(){var s,r,q=this,p=null
q.aP()
s=q.a
r=s.x
if(r!=null){q.e=r
r=s.y
q.f=r==null?A.v(t.N,t.Lr):r
s=s.z
q.x=s==null?A.b([],t.iO):s
s=q.a
r=s.Q
q.y=r==null?A.v(t.N,t.H1):r
q.r=s.as
q.w=!0
s=q.f
q.xr.I(0,new A.aR(s,A.m(s).i("aR<1>")))
q.X8()
q.f.ac(0,new A.aFE(q))}q.ok=A.bX(p,B.c_,p,p,q)
q.p1=A.bX(p,B.c_,p,p,q)
q.p2=A.bX(p,B.c_,p,p,q)
q.p3=A.bX(p,B.cf,p,p,q)
q.p4=A.bX(p,B.bv,p,p,q)
q.aly()
s=q.a
s=A.V(["roomCode",s.w,"isSupervisor",s.c],t.N,t.K)
r=q.d.a
r===$&&A.a()
r.c7("rejoin_game",s)
if(!q.a.d&&q.e==null)q.oB()},
aqU(){var s=this,r=s.a,q=r.c,p=t.N,o=s.d
r=r.w
if(q){r=A.V(["roomCode",r],p,p)
o=o.a
o===$&&A.a()
o.c7("end_game",r)}else{r=A.V(["roomCode",r],p,p)
o=o.a
o===$&&A.a()
o.c7("leave_game",r)}s.J7()
r=s.c
r.toString
A.cK(r,!1).kO(A.hg(new A.aET(s),null,t.z),new A.aEU())},
aly(){var s=this,r="update_game_state",q="timer_tick",p="twist_action_result",o="force_disconnect",n="phone_disconnected",m=s.d,l=m.a
l===$&&A.a()
l.d0(r)
m.a.d0(q)
m.a.d0(p)
m.a.d0("connect")
m.a.d0(o)
m.a.d0(n)
m.a.bD("connect",new A.aF8(s))
m.a.bD("error_game_not_found",new A.aF9(s))
m.a.bD(o,new A.aFa(s))
m.a.bD(n,new A.aFh(s))
m.a.bD("player_joined",new A.aFi(s))
m.a.bD("player_left",new A.aFj(s))
m.a.bD(r,new A.aFk(s))
m.a.bD(q,new A.aFl(s))
m.a.bD(p,new A.aFm(s))
m.a.bD("show_answer_dialog",new A.aFn(s))
m.a.bD("webrtc_new_peer",new A.aFo(s))
m.a.bD("webrtc_existing_peers",new A.aFb(s))
m.a.bD("webrtc_offer",new A.aFc(s))
m.a.bD("webrtc_answer",new A.aFd(s))
m.a.bD("webrtc_ice_candidate",new A.aFe(s))
m.a.bD("coin_flip_started",new A.aFf(s))
m.a.bD("blink_category",new A.aFg(s))},
X8(){var s=this.x2
if(s!=null)s.aG()
this.x2=A.Jq(B.qE,new A.aFw(this))},
l(){var s=this,r=s.d,q=r.a
q===$&&A.a()
q.d0("update_game_state")
r.a.d0("timer_tick")
r.a.d0("twist_action_result")
r.a.d0("connect")
r.a.d0("error_game_not_found")
r.a.d0("force_disconnect")
r.a.d0("phone_disconnected")
r=s.ok
r===$&&A.a()
r.l()
r=s.p1
r===$&&A.a()
r.l()
r=s.p2
r===$&&A.a()
r.l()
r=s.p3
r===$&&A.a()
r.l()
r=s.p4
r===$&&A.a()
r.l()
s.J7()
if(s.w){r=s.e
if(r!=null)B.b.ac(r.wu(),new A.aFA())
r=s.e
if(r!=null)r.l()
s.f.ac(0,new A.aFB())
s.f.R(0)}B.b.R(s.x)
r=s.x1
if(r!=null)r.aG()
r=s.x2
if(r!=null)r.aG()
s.afk()},
alw(a){var s,r,q=this
if(q.c==null)return
s=J.aw(a)
if(J.d(s.h(a,"isTwistRevealed"),!0)&&!q.fy){q.fy=!0
r=q.ok
r===$&&A.a()
r.bL()}if(J.d(s.h(a,"isTimerRevealed"),!0)&&!q.go){q.go=!0
r=q.p2
r===$&&A.a()
r.bL()}if(J.d(s.h(a,"isQuestionRevealed"),!0)&&!q.id){q.id=!0
s=q.p1
s===$&&A.a()
s.bL()}q.P(new A.aEP(q,a))},
amR(a){var s,r=this,q="categoryStats",p=J.aw(a)
if(p.h(a,q)!=null){r.ay=A.ed(p.h(a,q),t.N,t.z)
p=r.ch
B.b.R(p)
for(s=r.ay,s=new A.cN(s,s.r,s.e,A.m(s).i("cN<1>"));s.B();)p.push(s.d)}r.LJ()},
LJ(){var s,r,q=this
q.ax=null
q.dx=q.db=q.cy=0
q.k1=q.id=q.go=q.fy=q.fx=!1
q.k2=null
q.k4=q.k3=!1
s=q.p4
s===$&&A.a()
s.st(s.a)
s=q.ok
s===$&&A.a()
r=s.r
if(r!=null&&r.a!=null||s.gaV()===B.a7)s.st(0)
s=q.p1
s===$&&A.a()
r=s.r
if(r!=null&&r.a!=null||s.gaV()===B.a7)s.st(0)
s=q.p2
s===$&&A.a()
r=s.r
if(r!=null&&r.a!=null||s.gaV()===B.a7)s.st(0)},
axV(){var s,r,q=this
if(q.k3||q.k4)return
q.P(new A.aFz(q))
s=q.p4
s===$&&A.a()
s.vY()
s=t.z
r=q.d.a
r===$&&A.a()
r.c7("request_twist_action",A.v(s,s))},
u3(a){return this.ajp(a)},
ajp(a){var s=0,r=A.t(t.Lr),q,p=this,o,n
var $async$u3=A.o(function(b,c){if(b===1)return A.p(c,r)
for(;;)switch(s){case 0:s=p.f.ad(a)?3:4
break
case 3:s=5
return A.n(p.f.h(0,a).ar(),$async$u3)
case 5:p.f.G(0,a)
case 4:s=6
return A.n($.a8Z().EO(p.z,null),$async$u3)
case 6:o=c
p.f.n(0,a,o)
n=p.e
if(n!=null)B.b.ac(n.wu(),new A.aEH(p,o))
o.e=new A.aEI(p,a)
o.Q=new A.aEJ(p,a)
q=o
s=1
break
case 1:return A.q(q,r)}})
return A.r($async$u3,r)},
J7(){var s,r=this
if(r.w){s=r.e
if(s!=null)B.b.ac(s.wu(),new A.aEF())
s=r.e
if(s!=null)s.l()
r.e=null
r.f.ac(0,new A.aEG())
r.f.R(0)
B.b.R(r.x)
r.w=!1}},
oz(a){return this.aoe(a)},
aoe(a){var s=0,r=A.t(t.H),q=this,p,o,n,m,l
var $async$oz=A.o(function(b,c){if(b===1)return A.p(c,r)
for(;;)switch(s){case 0:m=q.d
l=m.a
l===$&&A.a()
p=l.e
s=B.c.b9(p==null?"":p,a)>0?2:4
break
case 2:A.en("📞 أنا من سيتصل باللاعب: "+a)
s=5
return A.n(q.u3(a),$async$oz)
case 5:o=c
s=6
return A.n(o.z7(),$async$oz)
case 6:n=c
s=7
return A.n(o.q8(n),$async$oz)
case 7:l=t.N
l=A.V(["to",a,"offer",A.V(["sdp",n.a,"type",n.b],l,t.v)],l,t.z)
m.a.c7("webrtc_offer",l)
s=3
break
case 4:A.en("⏳ سأنتظر اتصالاً من اللاعب: "+a+" لتجنب الزحمة...")
case 3:return A.q(null,r)}})
return A.r($async$oz,r)},
oA(a,b){return this.aoK(a,b)},
aoK(a,b){var s=0,r=A.t(t.H),q=this,p,o,n,m
var $async$oA=A.o(function(c,d){if(c===1)return A.p(d,r)
for(;;)switch(s){case 0:A.en("📥 استقبال عرض اتصال من: "+a)
s=q.f.ad(a)?2:3
break
case 2:A.en("♻️ إعادة بناء الاتصال مع "+a+" لتجنب التعليق...")
s=4
return A.n(q.f.h(0,a).ar(),$async$oA)
case 4:q.f.G(0,a)
case 3:s=5
return A.n(q.u3(a),$async$oA)
case 5:p=d
o=J.aw(b)
s=6
return A.n(p.q9(new A.ll(o.h(b,"sdp"),o.h(b,"type"))),$async$oA)
case 6:q.xq(a,p)
s=7
return A.n(p.z5(),$async$oA)
case 7:n=d
s=8
return A.n(p.q8(n),$async$oA)
case 8:o=t.N
o=A.V(["to",a,"answer",A.V(["sdp",n.a,"type",n.b],o,t.v)],o,t.z)
m=q.d.a
m===$&&A.a()
m.c7("webrtc_answer",o)
return A.q(null,r)}})
return A.r($async$oA,r)},
Ck(a,b){return this.aoG(a,b)},
aoG(a,b){var s=0,r=A.t(t.H),q=this,p,o
var $async$Ck=A.o(function(c,d){if(c===1)return A.p(d,r)
for(;;)switch(s){case 0:o=q.f.h(0,a)
s=o!=null?2:3
break
case 2:p=J.aw(b)
s=4
return A.n(o.q9(new A.ll(p.h(b,"sdp"),p.h(b,"type"))),$async$Ck)
case 4:A.en("✅ تم الربط الصوتي بنجاح مع: "+a)
q.xq(a,o)
case 3:return A.q(null,r)}})
return A.r($async$Ck,r)},
xp(a,b){return this.aoI(a,b)},
aoI(a,b){var s=0,r=A.t(t.H),q=1,p=[],o=this,n,m,l,k,j,i
var $async$xp=A.o(function(c,d){if(c===1){p.push(d)
s=q}for(;;)switch(s){case 0:l=J.aw(b)
k=new A.lj(l.h(b,"candidate"),l.h(b,"sdpMid"),l.h(b,"sdpMLineIndex"))
j=o.f.h(0,a)
s=j!=null?2:4
break
case 2:s=8
return A.n(j.B4(),$async$xp)
case 8:s=d!=null?5:7
break
case 5:q=10
s=13
return A.n(j.qV(k),$async$xp)
case 13:q=1
s=12
break
case 10:q=9
i=p.pop()
n=A.a7(i)
A.en("⚠️ خطأ في إضافة الـ ICE: "+A.j(n))
s=12
break
case 9:s=1
break
case 12:s=6
break
case 7:A.en(u.m+a)
J.ep(o.y.bi(a,new A.aEN()),k)
case 6:s=3
break
case 4:A.en(u.m+a)
J.ep(o.y.bi(a,new A.aEO()),k)
case 3:return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$xp,r)},
oB(){var s=0,r=A.t(t.H),q=1,p=[],o=this,n,m,l,k,j,i
var $async$oB=A.o(function(a,b){if(a===1){p.push(b)
s=q}for(;;)switch(s){case 0:o.P(new A.aEQ(o))
l=A.b([B.jf],t.o_)
s=2
return A.n($.aWt().jX(l),$async$oB)
case 2:q=4
s=7
return A.n(A.PR(),$async$oB)
case 7:n=b
s=8
return A.n(n.r5(new A.px(B.ki,new A.wT(12),B.kj,null,null,B.ov,B.hL,null)),$async$oB)
case 8:$.a8Z()
l=t.N
k=t.z
s=9
return A.n(new A.Uh().tq(A.V(["audio",!0,"video",!1],l,k)),$async$oB)
case 9:o.e=b
o.P(new A.aER(o))
o.alz()
s=10
return A.n(A.k3(B.bv,null,k),$async$oB)
case 10:o.X8()
l=A.V(["roomCode",o.a.w],l,l)
k=o.d.a
k===$&&A.a()
k.c7("webrtc_join_voice",l)
q=1
s=6
break
case 4:q=3
i=p.pop()
m=A.a7(i)
o.P(new A.aES(o))
A.hW().$1("❌ خطأ في فتح المايك: "+A.j(m))
s=6
break
case 3:s=1
break
case 6:return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$oB,r)},
alz(){var s=this.x1
if(s!=null)s.aG()
this.x1=A.Jq(B.ln,new A.aFv(this))},
xy(a){return this.amS(a)},
amS(a){var s=0,r=A.t(t.H),q,p=2,o=[],n=[],m=this,l,k,j,i,h
var $async$xy=A.o(function(b,c){if(b===1){o.push(c)
s=p}for(;;)switch(s){case 0:if(!m.a.c){s=1
break}if(m.RG!=null){s=1
break}m.LJ()
k=m.d
j=t.N
i=A.V(["category",a],j,j)
h=k.a
h===$&&A.a()
h.c7("broadcast_blink_category",i)
m.P(new A.aEL(m,a))
p=3
l=0
case 6:if(!(l<3)){s=8
break}i=m.p3
i===$&&A.a()
i.z=B.aW
s=9
return A.n(i.tQ(i.b),$async$xy)
case 9:i=m.p3
i.z=B.fd
s=10
return A.n(i.tQ(i.a),$async$xy)
case 10:case 7:++l
s=6
break
case 8:n.push(5)
s=4
break
case 3:n=[2]
case 4:p=2
if(m.Q==="CATEGORY_SELECT"){j=A.V(["category",a],j,j)
k.a.c7("select_category",j)}if(m.c!=null)m.P(new A.aEM(m))
s=n.pop()
break
case 5:case 1:return A.q(q,r)
case 2:return A.p(o.at(-1),r)}})
return A.r($async$xy,r)},
alB(){var s,r,q=this,p=null
if(q.e!=null){q.P(new A.aFx(q))
B.b.ac(q.e.Hy(),new A.aFy(q))
s=q.c.av(t.J).f
r=q.r?"تم كتم المايك 🔇":"تم تشغيل المايك 🎙️"
r=A.a6(r,p,p,p,p,p,p,p,A.Z(p,p,p,p,p,p,p,p,"FFHekaya",p,p,$.c().L(22),p,p,p,p,p,!0,p,p,p,p,p,p,p,p),p,p,p)
s.io(A.iP(p,p,p,q.r?B.ak:B.bk,p,B.D,p,r,p,B.bv,p,p,p,p,p,p,p,p,p,p))}},
alv(a){if(this.r)return B.ak
if(a>0.7)return B.cD
if(a>0.4)return B.mx
return B.j9},
V5(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=this,d=null,c=e.c
c.toString
s=A.bS(c,d,t.w).w.a.a<900
if(s){c=$.c()
r=60*Math.min(c.gq(),c.gp())}else{c=$.c()
r=70*Math.min(c.gq(),c.gp())}if(s){c=$.c()
q=80*Math.min(c.gq(),c.gp())}else{c=$.c()
q=120*Math.min(c.gq(),c.gp())}p=r+q
c=e.to
o=r+c*q
n=e.alv(c)
if(e.ry){c=5*$.c().gq()
m=r*0.5
return A.ag(B.x,A.bf(A.b([A.aa(B.pt,m,m),A.aa(d,8*$.c().gp(),d),A.a6("جاري الاتصال...",d,d,d,d,d,d,d,A.Z(d,d,B.h,d,d,d,d,d,"FFHekaya",d,d,$.c().L(14),d,d,B.o,d,d,!0,d,d,d,d,d,d,d,d),B.N,d,d)],t.p),B.p,B.r,B.Z),B.j,d,d,d,d,p,new A.S(c,0,c,0),d,d,d,p)}if(!e.a.d){c=5*$.c().gq()
m=A.b([],t.p)
if(!e.r&&e.w){l=A.U(B.d.T(255*(0.2+e.to*0.3)),n.m()>>>16&255,n.m()>>>8&255,n.m()&255)
k=A.U(B.d.T(255*(e.to*0.6)),n.m()>>>16&255,n.m()>>>8&255,n.m()&255)
j=$.c()
j=Math.min(j.gq(),j.gp())
i=e.to
h=$.c()
h=Math.min(h.gq(),h.gp())
g=e.to
f=$.c()
m.push(A.kN(d,d,B.O,new A.ar(l,d,d,d,A.b([new A.be(g*(10*Math.min(f.gq(),f.gp())),B.H,k,B.i,20*j+i*(40*h))],t.V),d,d,B.ae),B.qA,d,o,d,d,o))}l=e.r
k=l?B.i9:B.h
l=l?B.ak:A.U(204,n.m()>>>16&255,n.m()>>>8&255,n.m()&255)
l=A.bo(l,3*$.c().gq())
j=$.c()
j=Math.min(j.gq(),j.gp())
j=A.b([new A.be(0,B.H,B.bu,new A.h(0,3*$.c().gp()),5*j)],t.V)
i=e.r
h=i?B.rr:B.rs
i=i?B.dF:A.U(B.d.T(229.5),n.m()>>>16&255,n.m()>>>8&255,n.m()&255)
m.push(A.ag(d,A.bL(h,i,d,r*0.55),B.j,d,d,new A.ar(k,d,l,d,j,d,d,B.ae),d,r,d,d,d,d,r))
return A.fA(d,A.ag(B.x,A.cU(B.x,m,B.j,B.ag),B.j,d,d,d,d,p,new A.S(c,0,c,0),d,d,d,p),B.a8,!1,d,d,d,d,d,d,d,d,d,d,d,d,d,d,e.galA(),d,d,d,d,d,d)}return B.ax},
a0a(a){var s,r,q=this,p=null
if(q.a.c){s=t.z
r=q.d.a
r===$&&A.a()
r.c7("supervisor_reveal_answer",A.v(s,s))}s=q.c
s.toString
A.cK(s,!0).o_(A.bfe(p,B.I,!0,"Dismiss",!1,new A.aFr(q,a),p,p,new A.aFs(),B.c_,p,t.X))},
O(a){var s,r=this,q=null,p=t.p,o=A.b([A.ag(q,q,B.j,q,q,B.p5,q,q,q,q,q,q,q)],p),n=r.Q
if(n==="CATEGORY_SELECT")o.push(r.V2(r.ahw()))
else if(n==="GAME_OVER")o.push(r.V2(r.ahD()))
else{n=r.Vd(r.V5(),!0,!0)
s=$.c()
s=10*Math.min(s.gq(),s.gp())
o.push(A.qP(!0,A.bf(A.b([n,A.bP(new A.bi(new A.S(s,s,s,s),r.ahC(),q),1),A.aa(q,10*$.c().gp(),q)],p),B.p,B.r,B.t),!0))}return A.zt(q,A.cU(B.aQ,o,B.D,B.ag),q)},
V2(a){var s=$.c().gp()
return A.zt(B.B,A.qP(!1,new A.bi(new A.S(20*$.c().gq(),s,20*$.c().gq(),0),a,null),!0),null)},
alX(){var s,r=this.ax
if(r==null)return B.bS
r=r.h(0,"level")
s=r==null?null:J.b7(r).toLowerCase()
if(s==null)s=""
if(B.c.D(s,"سهل")||s==="1"||s==="easy")return B.aq
if(B.c.D(s,"صعب")||s==="3"||s==="hard")return B.kT
return B.q1},
ahH(){var s,r,q,p=this,o=null,n=A.fd(p.dy,!0,t.z),m=p.c
m.toString
s=t.w
m=A.bS(m,o,s).w
r=p.c
r.toString
s=A.bS(r,o,s).w
m=m.a.a<900?0.6:0.45
r=p.a.c
q=A.a2(n).i("a4<1,pt>")
q=A.a0(new A.a4(n,new A.aEy(p),q),q.i("ao.E"))
return A.ag(o,A.zL(A.hz(A.bZ(q,B.an,B.r,B.Z,0,o),!r,o),B.j,o,B.dA,!0,B.aI),B.j,o,new A.al(0,s.a.a*m,0,1/0),o,o,o,o,o,o,o,o)},
qx(){var s=0,r=A.t(t.H),q=1,p=[],o=this,n,m,l,k,j,i
var $async$qx=A.o(function(a,b){if(a===1){p.push(b)
s=q}for(;;)switch(s){case 0:j=t.N
j=A.V(["roomCode",o.a.w],j,j)
l=o.d.a
l===$&&A.a()
l.c7("leave_game",j)
q=3
s=6
return A.n(A.vE(),$async$qx)
case 6:n=b
s=7
return A.n(J.hX(n,"saved_userId"),$async$qx)
case 7:s=8
return A.n(J.hX(n,"saved_username"),$async$qx)
case 8:s=9
return A.n($.C1().n7(),$async$qx)
case 9:q=1
s=5
break
case 3:q=2
i=p.pop()
m=A.a7(i)
A.en("Error signing out: "+A.j(m))
s=5
break
case 2:s=1
break
case 5:j=o.c
if(j!=null)A.cK(j,!1).kO(A.hg(new A.aEV(),null,t.z),new A.aEW())
return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$qx,r)},
Vd(a7,a8,a9){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3=this,a4=null,a5="FFHekaya",a6=a3.c
a6.toString
s=A.bS(a6,a4,t.w).w.a.a<900
a6=s?140*$.c().gp():230*$.c().gp()
r=16*$.c().gq()
q=8*$.c().gp()
if(s){p=$.c()
p=6*Math.min(p.gq(),p.gp())}else{p=$.c()
p=10*Math.min(p.gq(),p.gp())}o=s?12*$.c().gq():18*$.c().gq()
n=s?4*$.c().gp():6*$.c().gp()
m=$.c()
m=A.ay(15*Math.min(m.gq(),m.gp()))
l=A.bo(B.k,1.5*$.c().gq())
k=a3.a.c?"انهاء اللعبة":"مغادرة"
p=A.fA(a4,A.ag(a4,A.ag(a4,A.a6(k,a4,a4,a4,a4,a4,a4,a4,A.Z(a4,a4,B.ak,a4,a4,a4,a4,a4,a5,a4,a4,s?$.c().L(24):$.c().L(30),a4,a4,B.o,a4,a4,!0,a4,a4,a4,a4,a4,a4,a4,a4),a4,B.T,a4),B.j,a4,a4,new A.ar(B.kV,a4,l,m,a4,a4,a4,B.u),a4,a4,a4,new A.S(o,n,o,n),a4,a4,a4),B.j,a4,a4,new A.ar(B.eq,a4,a4,a4,a4,a4,a4,B.ae),a4,a4,a4,new A.S(p,p,p,p),a4,a4,a4),B.a8,!1,a4,a4,a4,a4,a4,a4,a4,a4,a4,a4,a4,a4,a4,a4,a3.gaqT(),a4,a4,a4,a4,a4,a4)
o=A.aa(a4,a4,10*$.c().gq())
if(s){n=$.c()
n=6*Math.min(n.gq(),n.gp())}else{n=$.c()
n=10*Math.min(n.gq(),n.gp())}m=s?12*$.c().gq():18*$.c().gq()
l=s?4*$.c().gp():6*$.c().gp()
k=$.c()
k=A.ay(15*Math.min(k.gq(),k.gp()))
j=A.bo(B.l,1.5*$.c().gq())
n=A.fA(a4,A.ag(a4,A.ag(a4,A.a6("تسجيل الخروج",a4,a4,a4,a4,a4,a4,a4,A.Z(a4,a4,B.I,a4,a4,a4,a4,a4,a5,a4,a4,s?$.c().L(24):$.c().L(30),a4,a4,B.o,a4,a4,!0,a4,a4,a4,a4,a4,a4,a4,a4),a4,B.T,a4),B.j,a4,a4,new A.ar(B.h,a4,j,k,a4,a4,a4,B.u),a4,a4,a4,new A.S(m,l,m,l),a4,a4,a4),B.j,a4,a4,new A.ar(B.ct,a4,a4,a4,a4,a4,a4,B.ae),a4,a4,a4,new A.S(n,n,n,n),a4,a4,a4),B.a8,!1,a4,a4,a4,a4,a4,a4,a4,a4,a4,a4,a4,a4,a4,a4,a3.galx(),a4,a4,a4,a4,a4,a4)
m=t.p
n=A.b([p,o,n,A.a9C(a7,B.c_,A.aQt(),B.O,A.aQu())],m)
if(a3.a.c){p=A.aa(a4,a4,10*$.c().gq())
o=12*$.c().gq()
l=6*$.c().gp()
k=$.c()
k=A.ay(20*Math.min(k.gq(),k.gp()))
j=A.U(B.d.T(127.5),B.bS.m()>>>16&255,B.bS.m()>>>8&255,B.bS.m()&255)
i=$.c()
i=Math.min(i.gq(),i.gp())
h=$.c()
i=A.b([new A.be(Math.min(h.gq(),h.gp()),B.H,j,B.i,10*i)],t.V)
j=A.bo(B.h,1.5*$.c().gq())
h=A.bL(B.rv,B.h,a4,s?$.c().L(18):$.c().L(24))
g=A.aa(a4,a4,5*$.c().gq())
B.b.I(n,A.b([p,A.ag(a4,A.bZ(A.b([h,g,A.a6("المضيف",a4,a4,a4,a4,a4,a4,a4,A.Z(a4,a4,B.h,a4,a4,a4,a4,a4,a5,a4,a4,s?$.c().L(20):$.c().L(26),a4,a4,B.o,a4,a4,!0,a4,a4,a4,a4,a4,B.RT,a4,a4),a4,a4,a4)],m),B.p,B.r,B.Z,0,a4),B.j,a4,a4,new A.ar(a4,a4,j,k,i,B.Qk,a4,B.u),a4,a4,a4,new A.S(o,l,o,l),a4,a4,a4)],m))}p=A.b([new A.e_(B.ee,a4,a4,A.bZ(n,B.p,B.r,B.Z,0,a4),a4)],m)
if(a8&&a3.id){o=A.b([],m)
if(!a3.fx){n=s?32*$.c().gp():42*$.c().gp()
l=$.c().gq()
k=$.c().gp()
j=$.c().gq()
i=$.c().gp()
h=a3.alX()
g=$.c()
g=20*Math.min(g.gq(),g.gp())
f=$.c()
f=20*Math.min(f.gq(),f.gp())
e=A.bo(B.h,2*$.c().gq())
d=$.c()
d=Math.min(d.gq(),d.gp())
d=A.b([new A.be(0,B.H,B.bu,new A.h(0,3*$.c().gp()),4*d)],t.V)
c=A.aa(a4,a4,4*$.c().gq())
b=A.a6("نقطة",a4,a4,a4,a4,a4,a4,a4,A.Z(a4,a4,B.h,a4,a4,a4,a4,a4,a5,a4,a4,s?$.c().L(30):$.c().L(40),a4,a4,a4,a4,a4,!0,a4,a4,a4,a4,a4,a4,a4,a4),a4,a4,a4)
a=A.aa(a4,a4,4*$.c().gq())
a0=a3.db
a1=s?$.c().L(30):$.c().L(40)
a2=$.c()
o.push(new A.bi(new A.S(0,n,0,0),A.ag(a4,A.bZ(A.b([c,b,a,A.a6(""+a0,a4,a4,a4,a4,a4,a4,a4,A.Z(a4,a4,B.h,a4,a4,a4,a4,a4,a5,a4,a4,a1,a4,a4,B.o,a4,a4,!0,a4,a4,a4,a4,a4,A.b([new A.fh(B.ic,B.mL,2*Math.min(a2.gq(),a2.gp()))],t.kO),a4,a4),a4,a4,a4)],m),B.p,B.r,B.Z,0,a4),B.j,a4,a4,new A.ar(h,a4,e,new A.d3(B.G,B.G,new A.aF(g,g),new A.aF(f,f)),d,a4,a4,B.u),a4,a4,a4,new A.S(16*l,12*k,16*j,6*i),a4,a4,a4),a4))}if(a3.a.c){n=a3.fx
l=s?16*$.c().gq():24*$.c().gq()
k=s?8*$.c().gp():10*$.c().gp()
j=a3.fx?B.eo:B.Mh
i=$.c()
i=A.ay(25*Math.min(i.gq(),i.gp()))
h=A.bo(B.h,3*$.c().gq())
g=$.c()
g=Math.min(g.gq(),g.gp())
g=A.b([new A.be(0,B.H,B.bu,new A.h(0,4*$.c().gp()),8*g)],t.V)
f=a3.fx?B.OQ:B.P8
f=A.b([A.bL(f,B.h,a4,s?$.c().L(18):$.c().L(22))],m)
if(!a3.fx){e=A.aa(a4,a4,8*$.c().gq())
B.b.I(f,A.b([e,A.a6("كشف الإجابة",a4,a4,a4,a4,a4,a4,a4,A.Z(a4,a4,B.h,a4,a4,a4,a4,a4,a5,a4,a4,s?$.c().L(30):$.c().L(40),a4,a4,B.o,a4,1.2,!0,a4,a4,a4,a4,a4,a4,a4,a4),a4,B.T,a4)],m))}o.push(A.hz(A.fA(a4,A.kN(A.bZ(f,B.p,B.r,B.Z,0,a4),a4,B.O,new A.ar(j,a4,h,i,g,a4,a4,B.u),B.bh,a4,a4,a4,new A.S(l,k,l,k),a4),B.a8,!1,a4,a4,a4,a4,a4,a4,a4,a4,a4,a4,a4,a4,a4,a4,new A.aEC(a3),a4,a4,a4,a4,a4,a4),n,a4))}p.push(new A.e_(B.x,a4,a4,A.cU(B.c8,o,B.j,B.ag),a4))}o=A.b([],m)
if(J.kL(a3.dy))o.push(a3.ahH())
o.push(A.aa(a4,a4,16*$.c().gq()))
if(a9&&a3.cx>0){n=15*$.c().gq()
l=5*$.c().gp()
k=A.U(B.d.T(127.5),B.h.m()>>>16&255,B.h.m()>>>8&255,B.h.m()&255)
j=$.c()
j=A.ay(12*Math.min(j.gq(),j.gp()))
i=A.bo(B.M6,1)
o.push(A.ag(a4,A.bf(A.b([A.a6("السؤال",a4,a4,a4,a4,a4,a4,a4,A.Z(a4,a4,B.a1,a4,a4,a4,a4,a4,a5,a4,a4,$.c().L(50),a4,a4,B.o,a4,a4,!0,a4,1,a4,a4,a4,a4,a4,a4),a4,a4,a4),A.a6(""+a3.CW+"/"+a3.cx,a4,a4,a4,a4,a4,a4,a4,A.Z(a4,a4,B.I,a4,a4,a4,a4,a4,a5,a4,a4,$.c().L(40),a4,a4,B.cy,a4,a4,!0,a4,a4,a4,a4,a4,a4,a4,a4),a4,a4,a4)],m),B.p,B.r,B.Z),B.j,a4,a4,new A.ar(k,a4,i,j,a4,a4,a4,B.u),a4,a4,a4,new A.S(n,l,n,l),a4,a4,a4))}p.push(new A.e_(B.fl,a4,a4,A.bZ(o,B.an,B.r,B.Z,0,a4),a4))
return A.ag(a4,A.cU(B.x,p,B.D,B.ag),B.j,a4,a4,a4,a4,a6,a4,new A.S(r,q,r,q),a4,a4,a4)},
ahw(){var s,r,q,p,o,n,m,l,k,j,i=this,h=null,g="FFHekaya",f=i.ch
if(!(f.length!==0)){s=i.ay
r=A.m(s).i("aR<1>")
f=A.a0(new A.aR(s,r),r.i("E.E"))}B.b.jw(f)
s=i.c
s.toString
q=A.bS(s,h,t.w).w.a.a<900
p=f.length
if(p===0)p=1
s=i.Vd(i.V5(),!1,!1)
r=A.t9("اختر فئة السؤال",1,10,h,A.Z(h,h,B.k,h,h,h,h,h,g,h,h,q?$.c().L(45):$.c().L(60),h,h,B.o,h,h,!0,h,h,h,h,h,h,h,h),h,h)
o=t.p
r=A.b([new A.jk(1,B.cX,r,h),A.aa(h,q?5*$.c().gp():15*$.c().gp(),h)],o)
if(i.at.length!==0){n=q?16*$.c().gq():24*$.c().gq()
m=q?6*$.c().gp():8*$.c().gp()
l=$.c()
l=A.ay(15*Math.min(l.gq(),l.gp()))
k=A.bo(B.k,1.5*$.c().gq())
j=i.at
r.push(A.ag(h,A.t9("الدور: "+j,1,16,h,A.Z(h,h,B.I,h,h,h,h,h,g,h,h,q?$.c().L(35):$.c().L(45),h,h,B.o,h,h,!0,h,h,h,h,h,h,h,h),h,B.T),B.j,h,h,new A.ar(B.kV,h,k,l,h,h,h,B.u),h,h,h,new A.S(n,m,n,m),h,h,h))}r=A.bf(r,B.p,B.hd,B.Z)
return A.bf(A.b([s,new A.jk(2,B.cX,r,h),A.bP(f.length===0?B.HQ:A.Fe(new A.aDZ(i,q,p,f)),5)],o),B.p,B.r,B.t)},
ahv(a1){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b=this,a=null,a0=b.ay.h(0,a1)
a0=a0==null?a:J.b7(a0)
s=A.h1(a0==null?"0":a0,a)
if(s==null)s=0
r=s<=0
a0=b.RG
q=B.c.d1(a1)
p="https://api.3krooot.com/assets/category/"+A.h8(q," ","_")+".png?v="+b.rx
q=r||b.RG!=null
o=r?0.4:1
n=$.c()
n=A.ay(17*Math.min(n.gq(),n.gp()))
m=A.U(51,B.l.m()>>>16&255,B.l.m()>>>8&255,B.l.m()&255)
l=$.c()
l=Math.min(l.gq(),l.gp())
l=A.b([new A.be(0,B.H,m,new A.h(0,3*$.c().gp()),5*l)],t.V)
m=$.c()
m=16*Math.min(m.gq(),m.gp())
m=A.bP(A.no(A.m_(B.G,new A.aF(m,m)),A.ag(a,A.aaY(B.bg,p,new A.aDU(),B.bs,p,310,new A.aDV(),a),B.j,B.cs,a,a,a,a,a,a,a,a,1/0)),3)
k=6*$.c().gp()
j=2*$.c().gq()
i=$.c()
i=14*Math.min(i.gq(),i.gp())
i=A.m_(new A.aF(i,i),B.G)
h=t.p
k=A.bf(A.b([m,A.ag(a,A.t9(a1,1,8,B.aG,A.Z(a,a,B.h,a,a,a,a,a,"FFHekaya",a,a,$.c().L(35),a,a,B.o,a,a,!0,a,a,a,a,a,a,a,a),B.N,a),B.j,a,a,new A.ar(B.k,a,a,i,a,a,a,B.u),a,a,a,new A.S(j,k,j,k),a,a,1/0)],h),B.p,B.r,B.t)
j=$.c().gp()
i=$.c().gq()
m=8*$.c().gq()
g=4*$.c().gp()
f=r?B.dk:A.U(B.d.T(229.5),B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
e=$.c()
e=A.ay(10*Math.min(e.gq(),e.gp()))
d=A.bo(B.h,1.5*$.c().gq())
c=r?"نفذت":"الاسئلة: "+s
h=A.b([k,A.eu(a,A.cc(A.ag(a,A.a6(c,a,a,a,a,a,a,a,A.Z(a,a,B.h,a,a,a,a,a,a,a,a,$.c().L(20),a,a,B.o,a,a,!0,a,a,a,a,a,a,a,a),a,a,a),B.j,a,a,new A.ar(f,a,d,e,a,a,a,B.u),a,a,a,new A.S(m,g,m,g),a,a,a),a,a),a,a,a,5*i,5*j,a)],h)
if(a0===a1){a0=b.p3
a0===$&&A.a()
h.push(A.qz(0,A.fS(a0,new A.aDW(b),a)))}return A.hz(A.fA(a,A.Pu(A.ag(a,A.cU(B.aQ,h,B.D,B.ag),B.j,a,a,new A.ar(B.h,a,a,n,l,a,a,B.u),a,a,a,a,a,a,a),B.O,B.bh,o),B.a8,!1,a,a,a,a,a,a,a,a,a,a,a,a,a,a,new A.aDX(b,a1),a,a,a,a,a,a),q,a)},
ahC(){return A.Fe(new A.aEc(this))},
IU(a,b,c,d,e){var s,r=null,q=A.b([this.ahB(a,c,b,d,e)],t.p)
if(b){s=$.c().gp()
q.push(A.eu(r,A.cc(new A.J_(r),r,r),r,r,0,0,30*s,r))}return A.cc(new A.t6(0.6857142857142857,A.cU(B.x,q,B.j,B.jN),r),r,r)},
ahG(){var s,r,q,p,o,n,m,l,k,j,i,h,g=this,f=null,e="FFHekaya",d=g.as.h(0,"effect")
if(d==null)d="none"
if(g.k4&&g.k2!=null){s=g.k2==="صورة"
r=d==="coin_decides_fate"
if(r){q=s?"تعتبر إجابة صحيحة ✅":"تعتبر إجابة خاطئة ❌"
p=s?B.fx:B.dF}else{q=s?"تدبيل النقاط (x2)":"نصف النقاط (x0.5)"
p=s?B.bk:B.q4}o=$.c()
o=Math.min(o.gq(),o.gp())
n=$.c()
n=Math.min(n.gq(),n.gp())
m=A.bo(B.h,3*$.c().gq())
l=$.c()
k=t.V
l=A.b([new A.be(0,B.H,B.bu,B.i,10*Math.min(l.gq(),l.gp()))],k)
j=s?"👸":"📝"
o=A.ag(f,A.cc(A.a6(j,f,f,f,f,f,f,f,A.Z(f,f,f,f,f,f,f,f,f,f,f,g.hu(45),f,f,f,f,f,!0,f,f,f,f,f,f,f,f),f,f,f),f,f),B.j,f,f,new A.ar(B.bS,f,m,f,l,f,f,B.ae),f,100*n,f,f,f,f,100*o)
n=A.aa(f,12*$.c().gp(),f)
l=20*$.c().gq()
m=8*$.c().gp()
j=$.c()
j=A.ay(15*Math.min(j.gq(),j.gp()))
k=A.b([new A.be(0,B.H,B.bu,new A.h(0,2),4)],k)
i=t.p
h=A.b([A.a6(q,f,f,f,f,f,f,f,A.Z(f,f,B.h,f,f,f,f,f,e,f,f,g.hu(26),f,f,B.o,f,f,!0,f,f,f,f,f,f,f,f),B.N,f,f)],i)
if(r)h.push(A.a6("(لصاحب الدور فقط)",f,f,f,f,f,f,f,A.Z(f,f,B.a5,f,f,f,f,f,e,f,f,g.hu(18),f,f,f,f,f,!0,f,f,f,f,f,f,f,f),f,f,f))
return A.bf(A.b([o,n,A.ag(f,A.bf(h,B.p,B.r,B.t),B.j,f,f,new A.ar(p,f,f,j,k,f,f,B.u),f,f,f,new A.S(l,m,l,m),f,f,f)],i),B.p,B.r,B.Z)}if(g.k3){r=g.p4
r===$&&A.a()
return A.fS(r,new A.aEv(g),f)}r=g.a.c?g.gaxU():f
o=A.bL(B.OR,f,f,g.hu(28))
n=A.a6("ارمي العملة",f,f,f,f,f,f,f,A.Z(f,f,f,f,f,f,f,f,e,f,f,g.hu(35),f,f,B.o,f,f,!0,f,f,f,f,f,f,f,f),f,f,f)
m=30*$.c().gq()
l=15*$.c().gp()
k=$.c()
return A.cc(A.aYq(o,n,r,A.hZ(f,f,B.bS,f,f,f,8,f,f,f,B.my,f,f,new A.S(m,l,m,l),f,new A.c2(A.ay(30*Math.min(k.gq(),k.gp())),new A.aW(B.h,2*$.c().gq(),B.z,-1)),f,f,f,f,f)),f,f)},
aht(){var s,r,q,p,o,n,m,l=this,k=null,j="FFHekaya"
if(!l.a.c)return A.bf(A.b([A.aa(k,12*$.c().gp(),k),A.a6("في انتظار قرار المضيف للرهان...",k,k,k,k,k,k,k,A.Z(k,k,B.I,k,k,k,k,k,j,k,k,l.hu(30),k,k,B.o,k,k,!0,k,k,k,k,k,k,k,k),k,k,k)],t.p),B.p,B.r,B.Z)
s=A.aa(k,12*$.c().gp(),k)
r=A.U(191,B.fC.m()>>>16&255,B.fC.m()>>>8&255,B.fC.m()&255)
q=20*$.c().gq()
p=10*$.c().gp()
o=$.c()
o=A.hZ(k,k,r,k,k,k,4,k,k,k,B.I,k,k,new A.S(q,p,q,p),k,new A.c2(A.ay(15*Math.min(o.gq(),o.gp())),B.y),k,k,k,k,k)
o=A.jg(A.a6("لا تراهن",k,k,k,k,k,k,k,A.Z(k,k,k,k,k,k,k,k,j,k,k,l.hu(35),k,k,B.o,k,k,!0,k,k,k,k,k,k,k,k),k,k,k),new A.aDS(l),o)
p=A.aa(k,k,20*$.c().gq())
q=A.U(191,B.eo.m()>>>16&255,B.eo.m()>>>8&255,B.eo.m()&255)
r=30*$.c().gq()
n=10*$.c().gp()
m=$.c()
m=A.hZ(k,k,q,k,k,k,6,k,k,k,B.h,k,k,new A.S(r,n,r,n),k,new A.c2(A.ay(15*Math.min(m.gq(),m.gp())),B.y),k,k,k,k,k)
n=t.p
return A.bf(A.b([s,A.bZ(A.b([o,p,A.jg(A.a6("راهن (x2)",k,k,k,k,k,k,k,A.Z(k,k,k,k,k,k,k,k,j,k,k,l.hu(35),k,k,B.cy,k,k,!0,k,k,k,k,k,k,k,k),k,k,k),new A.aDT(l),m)],n),B.p,B.ad,B.t,0,k)],n),B.p,B.r,B.Z)},
Vc(a){var s,r,q,p,o,n,m,l,k,j=null,i="assets/logo.png",h=this.cy,g=h<=5&&h>0,f=g?B.KG:B.l
h=$.c()
h=20*Math.min(h.gq(),h.gp())
h=A.CC(new A.aF(h,h))
s=$.c()
s=Math.min(s.gq(),s.gp())
r=new A.ar(B.ap,j,j,h,A.b([new A.be(0,B.H,B.a1,new A.h(0,5*$.c().gp()),10*s)],t.V),j,j,B.u)
if(!a){h=r.a3s(A.bo(B.ep,2*$.c().gq()))
return A.ag(j,A.cc(A.nR(i,j,B.bs,j,120*$.c().gq()),j,j),B.j,j,j,h,j,j,j,j,j,j,j)}q=B.c.nX(B.f.j(this.cy),2,"0")
h=g?B.B:B.ep
h=r.a3s(A.bo(h,g?4*$.c().gq():2*$.c().gq()))
s=$.c().gp()
p=A.nR(i,j,B.bs,50*$.c().gp(),j)
o=20*$.c().gq()
o=A.bP(new A.bi(new A.S(o,0,o,0),A.Fe(new A.aEB(f,g,q)),j),1)
n=$.c().gq()
m=$.c().gq()
l=$.c().gp()
k=this.hu(20)
return A.ag(j,A.bf(A.b([new A.bi(new A.S(0,15*s,0,0),p,j),o,new A.bi(new A.S(10*n,0,10*m,20*l),A.aSr(B.a6C,B.O,B.bh,A.Z(j,j,g?B.eq:B.l,j,j,j,j,j,"FFHekaya",j,j,k,j,j,B.o,j,j,!0,j,j,j,j,j,j,j,j)),j)],t.p),B.p,B.r,B.t),B.j,j,j,h,j,j,j,j,j,j,j)},
UV(){var s,r,q=null,p=$.c()
p=A.ay(20*Math.min(p.gq(),p.gp()))
s=A.bo(B.ep,2*$.c().gq())
r=$.c()
r=Math.min(r.gq(),r.gp())
r=A.b([new A.be(0,B.H,B.a1,new A.h(0,5*$.c().gp()),10*r)],t.V)
return A.ag(q,A.cc(A.nR("assets/logo.png",q,B.bs,q,120*$.c().gq()),q,q),B.j,q,q,new A.ar(B.ie,q,s,p,r,q,q,B.u),q,q,q,q,q,q,q)},
ahF(a){var s=null
if(B.c.D(a.toLowerCase(),".svg"))return new A.IN(s,s,B.bs,B.bg,new A.IM(a,s,s,s,s),new A.aEs(),s,s)
else return A.aaY(B.bg,a,new A.aEt(),B.bs,a,s,s,new A.aEu())},
ahB(a,b,c,d,e){var s=null
return A.fA(s,A.fS(b,new A.aE1(b,d,a),s),B.a8,!1,s,s,s,s,new A.aE2(c,b,e),s,new A.aE3(c,b),s,s,s,s,s,s,s,new A.aE4(c,b,e),s,s,s,s,s,s)},
ahD(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=this,b=null,a="FFHekaya"
if(J.kL(c.dy))J.Pf(c.dy,new A.aEj())
s=J.kL(c.dy)?J.av(c.dy,0):b
r=30*$.c().gq()
q=20*$.c().gp()
p=t.Y
o=t.p
n=t.i
m=A.b([A.ra(new A.aEk(),A.bZ(A.b([A.bL(B.P_,B.aZ,b,$.c().L(45)),A.aa(b,b,10*$.c().gq()),A.a6("نتائج التحدي",b,b,b,b,b,b,b,A.Z(b,b,B.aZ,b,b,b,b,b,a,b,b,$.c().L(65),b,b,B.o,b,b,!0,b,b,b,b,b,B.R7,b,b),b,b,b)],o),B.p,B.ad,B.t,0,b),B.hX,B.bv,new A.aG(-100,0,p),n),new A.mM(b)],o)
if(s!=null){l=A.ra(new A.aEl(),b,B.O,B.lk,new A.aG(0,628.3185307179587,p),n)
k=$.c()
k=20*Math.min(k.gq(),k.gp())
j=A.bo(B.S,5*$.c().gq())
i=A.U(204,B.aZ.m()>>>16&255,B.aZ.m()>>>8&255,B.aZ.m()&255)
h=$.c()
h=Math.min(h.gq(),h.gp())
g=$.c()
h=A.b([new A.be(10*Math.min(g.gq(),g.gp()),B.H,i,B.i,30*h)],t.V)
i=$.c()
B.b.I(m,A.b([A.ra(new A.aEm(),A.cU(B.x,A.b([l,A.ag(b,A.bL(B.m8,B.k,b,100*Math.min(i.gq(),i.gp())),B.j,b,b,new A.ar(B.ap,b,j,b,h,b,b,B.ae),b,b,b,new A.S(k,k,k,k),b,b,b)],o),B.D,B.ag),B.O,B.lk,new A.aG(0,1000,p),n),A.aa(b,15*$.c().gp(),b),A.ra(new A.aEn(),A.bf(A.b([A.a6("البطل",b,b,b,b,b,b,b,A.Z(b,b,B.aZ,b,b,b,b,b,a,b,b,$.c().L(35),b,b,B.o,b,b,!0,b,b,b,b,b,b,b,b),b,b,b),A.a6(J.b7(J.av(s,"name")),b,b,1,B.aG,b,b,b,A.Z(b,b,B.h,b,b,b,b,b,a,b,b,$.c().L(85),b,b,B.cy,b,b,!0,b,b,b,b,b,B.Rw,b,b),B.N,b,b)],o),B.p,B.r,B.t),B.er,B.iA,new A.aG(0,1,p),n)],o))}m.push(new A.mM(b))
m=A.bP(A.bf(m,B.p,B.ad,B.t),5)
l=A.aa(b,b,30*$.c().gq())
k=$.c()
k=15*Math.min(k.gq(),k.gp())
j=A.U(B.d.T(25.5),B.ap.m()>>>16&255,B.ap.m()>>>8&255,B.ap.m()&255)
i=$.c()
i=A.ay(25*Math.min(i.gq(),i.gp()))
h=B.d.T(127.5)
g=A.bo(A.U(h,B.S.m()>>>16&255,B.S.m()>>>8&255,B.S.m()&255),2*$.c().gq())
k=A.bP(A.ag(b,A.bf(A.b([A.a6("ترتيب الفرق",b,b,b,b,b,b,b,A.Z(b,b,B.ap,b,b,b,b,b,a,b,b,$.c().L(40),b,b,B.o,b,b,!0,b,b,b,b,b,b,b,b),b,b,b),A.aa(b,10*$.c().gp(),b),A.bP(A.ra(new A.aEo(c),b,B.O,B.Nz,new A.aG(0,1,p),n),1)],o),B.p,B.r,B.t),B.j,b,b,new A.ar(j,b,g,i,b,b,b,B.u),b,b,b,new A.S(k,k,k,k),b,b,b),1)
i=A.aa(b,15*$.c().gp(),b)
g=$.c().gp()
j=$.c()
j=A.hZ(b,b,B.eq,b,b,b,6,b,b,b,B.h,b,b,b,b,new A.c2(A.ay(15*Math.min(j.gq(),j.gp())),new A.aW(B.h,2*$.c().gq(),B.z,-1)),b,b,b,b,b)
g=A.bP(A.aa(A.jg(A.bZ(A.b([A.bL(B.P0,b,b,$.c().L(28)),A.aa(b,b,8*$.c().gq()),A.t9("الرئيسية",1,12,b,A.Z(b,b,b,b,b,b,b,b,a,b,b,$.c().L(30),b,b,B.o,b,b,!0,b,b,b,b,b,b,b,b),b,b)],o),B.p,B.ad,B.t,0,b),new A.aEp(c),j),70*g,b),3)
j=A.aa(b,b,15*$.c().gq())
f=$.c().gp()
e=$.c()
e=A.ay(20*Math.min(e.gq(),e.gp()))
d=$.c().gq()
d=A.hZ(b,b,B.ap,b,b,b,10,b,b,b,B.k,b,b,b,A.U(h,B.aZ.m()>>>16&255,B.aZ.m()>>>8&255,B.aZ.m()&255),new A.c2(e,new A.aW(B.S,3*d,B.z,-1)),b,b,b,b,b)
return A.zt(B.B,A.ag(b,A.qP(!0,new A.bi(new A.S(r,q,r,q),A.bZ(A.b([m,l,A.bP(A.bf(A.b([k,i,A.bZ(A.b([g,j,A.bP(A.ra(new A.aEq(),A.aa(A.jg(A.bZ(A.b([A.bL(B.P7,b,b,$.c().L(32)),A.aa(b,b,8*$.c().gq()),A.t9("العب من جديد",1,12,b,A.Z(b,b,b,b,b,b,b,b,a,b,b,$.c().L(35),b,b,B.o,b,b,!0,b,b,b,b,b,b,b,b),b,b)],o),B.p,B.ad,B.t,0,b),new A.aEr(c),d),70*f,b),B.O,B.lk,new A.aG(0,1000,p),n),4)],o),B.p,B.r,B.t,0,b)],o),B.p,B.r,B.t),4)],o),B.ce,B.r,B.t,0,b),b),!0),B.j,b,b,B.Gj,b,1/0,b,b,b,b,1/0),b)}}
A.aEK.prototype={
$1(a){var s,r=null
if(a.length===0)return 0
s=A.oM(r,r,30,r,A.dv(r,r,r,r,r,r,r,r,r,A.Z(r,r,r,r,r,r,r,r,"FFHekaya",r,r,this.a.hu(15),r,r,B.iO,r,1.3,!0,r,r,r,r,r,r,r,r),a),B.aV,B.T,r,1,B.df,B.aH)
s.a6t(this.b)
return s.b.a.c.gbx()},
$S:598}
A.aEz.prototype={
$2(a,b){var s,r=null,q=this.a,p=b.b,o=q.Xf(a,p,b.d),n=$.c().gq(),m=$.c().gq(),l=$.c().gp(),k=$.c().gq(),j=15*$.c().gq(),i=15*$.c().gp(),h=A.U(242,B.h.m()>>>16&255,B.h.m()>>>8&255,B.h.m()&255),g=$.c()
g=A.ay(20*Math.min(g.gq(),g.gp()))
s=$.c()
s=Math.min(s.gq(),s.gp())
s=A.b([new A.be(0,B.H,B.bu,new A.h(0,3*$.c().gp()),6*s)],t.V)
return A.cU(B.aQ,A.b([A.eu(50*l,A.ag(r,A.cc(A.t9(this.b,r,10,r,A.Z(r,r,B.I,r,r,r,r,r,"FFHekaya",r,r,q.hu(65),r,r,B.iO,r,1.3,!0,r,r,r,r,r,r,r,r),B.N,B.T),r,r),B.j,r,r,new A.ar(h,r,r,g,s,r,r,B.u),r,o,r,new A.S(j,i,j,i),r,r,p-24*k),r,r,12*n,12*m,r,r)],t.p),B.D,B.ag)},
$S:126}
A.aED.prototype={
$1(a){return A.cc(A.bL(B.OO,B.ap,null,$.c().L(140)),null,null)},
$S:253}
A.aEE.prototype={
$2(a,b){var s,r=null,q="FFHekaya",p=this.a,o=b.b,n=p.Xf(a,o,b.d),m=$.c().gq(),l=$.c().gq(),k=$.c().gp(),j=$.c().gq(),i=15*$.c().gq(),h=15*$.c().gp(),g=A.U(242,B.h.m()>>>16&255,B.h.m()>>>8&255,B.h.m()&255),f=$.c()
f=A.ay(20*Math.min(f.gq(),f.gp()))
s=$.c()
s=Math.min(s.gq(),s.gp())
s=A.b([new A.be(0,B.H,B.bu,new A.h(0,3*$.c().gp()),6*s)],t.V)
l=A.eu(50*k,A.ag(r,A.cc(A.t9(this.b,r,10,r,A.Z(r,r,B.I,r,r,r,r,r,q,r,r,p.hu(65),r,r,B.iO,r,1.3,!0,r,r,r,r,r,r,r,r),B.N,B.T),r,r),B.j,r,r,new A.ar(g,r,r,f,s,r,r,B.u),r,n,r,new A.S(i,h,i,h),r,r,o-24*j),r,r,12*m,12*l,r,r)
m=$.c().gq()
j=$.c().gq()
o=$.c().gp()
h=$.c().gp()
return A.cU(B.aQ,A.b([l,A.eu(5*o,A.cc(A.t9("يجب على كل لاعب التقيد بتعليمات التويست",1,8,r,A.Z(r,r,B.l,r,r,r,r,r,q,r,r,p.hu(20),r,r,B.o,r,r,!0,r,r,r,r,r,r,r,r),B.N,r),r,r),45*h,r,12*m,12*j,r,r)],t.p),B.D,B.ag)},
$S:126}
A.aFE.prototype={
$2(a,b){var s=this.a
b.e=new A.aFC(s,a)
b.Q=new A.aFD(s)},
$S:93}
A.aFC.prototype={
$1(a){var s=A.V(["to",this.b,"candidate",a.AH()],t.N,t.z),r=this.a.d.a
r===$&&A.a()
r.c7("webrtc_ice_candidate",s)},
$S:128}
A.aFD.prototype={
$1(a){var s
if(a.c.d.kind==="audio"){s=a.b
if(s.length!==0&&!B.b.D(this.a.x,s[0]))this.a.x.push(s[0])}},
$S:129}
A.aET.prototype={
$1(a){var s=this.a,r=s.a,q=r.d,p=r.f,o=r.r
if(q)s=new A.ke(p,o,s.dy,null)
else s=new A.lg(p,o,r.c?s.dy:null,null)
return s},
$S:105}
A.aEU.prototype={
$1(a){return!1},
$S:30}
A.aF8.prototype={
$1(a){var s,r,q,p,o
A.en("🔌 Connected/Reconnected to server")
s=this.a
r=s.d
q=s.a
p=t.N
q=A.V(["roomCode",q.w,"isSupervisor",q.c],p,t.K)
o=r.a
o===$&&A.a()
o.c7("rejoin_game",q)
q=s.a
if(!q.d&&s.w){s=A.V(["roomCode",q.w],p,p)
r.a.c7("webrtc_join_voice",s)}},
$S:3}
A.aF9.prototype={
$1(a){var s=this.a,r=s.c
if(r!=null){r.av(t.J).f.io(B.a0X)
s=s.c
s.toString
A.cK(s,!1).kO(A.hg(new A.aF6(),null,t.z),new A.aF7())}},
$S:3}
A.aF6.prototype={
$1(a){return B.dY},
$S:53}
A.aF7.prototype={
$1(a){return!1},
$S:30}
A.aFa.prototype={
$1(a){var s,r=null,q=this.a,p=q.c
if(p!=null){p=p.av(t.J).f
s=J.av(a,"message")
p.io(A.iP(r,r,r,B.ak,r,B.D,r,A.a6(s==null?"تم إنهاء الجلسة من قبل المضيف":s,r,r,r,r,r,r,r,r,r,r,r),r,B.bZ,r,r,r,r,r,r,r,r,r,r))
p=q.c
p.toString
A.cK(p,!1).kO(A.hg(new A.aF4(q),r,t.z),new A.aF5())}},
$S:3}
A.aF4.prototype={
$1(a){var s=null,r=this.a.a,q=r.d,p=r.f
r=r.r
return q?new A.ke(p,r,s,s):new A.lg(p,r,s,s)},
$S:105}
A.aF5.prototype={
$1(a){return!1},
$S:30}
A.aFh.prototype={
$1(a){var s,r=null,q=this.a,p=q.c
if(p!=null){p=p.av(t.J).f
s=J.av(a,"message")
p.io(A.iP(r,r,r,B.ak,r,B.D,r,A.a6(s==null?"انقطع الاتصال بالهاتف المضيف":s,r,r,r,r,r,r,r,r,r,r,r),r,B.bZ,r,r,r,r,r,r,r,r,r,r))
p=q.c
p.toString
A.cK(p,!1).kO(A.hg(new A.aF2(q),r,t.z),new A.aF3())}},
$S:3}
A.aF2.prototype={
$1(a){var s=null,r=this.a.a,q=r.d,p=r.f
r=r.r
return q?new A.ke(p,r,s,s):new A.lg(p,r,s,s)},
$S:105}
A.aF3.prototype={
$1(a){return!1},
$S:30}
A.aFi.prototype={
$1(a){var s,r=null,q=this.a.c
if(q!=null){q=q.av(t.J).f
s=J.av(a,"message")
if(s==null)s=""
q.io(A.iP(r,r,r,B.bk,r,B.D,r,A.a6(s,r,r,r,r,r,r,r,A.Z(r,r,r,r,r,r,r,r,"FFHekaya",r,r,$.c().L(20),r,r,r,r,r,!0,r,r,r,r,r,r,r,r),r,r,r),r,B.fO,r,r,r,r,r,r,r,r,r,r))}},
$S:3}
A.aFj.prototype={
$1(a){var s,r,q,p=null,o=this.a,n=o.c
if(n!=null){n=n.av(t.J).f
s=J.aw(a)
r=s.h(a,"message")
if(r==null)r=""
n.io(A.iP(p,p,p,B.mz,p,B.D,p,A.a6(r,p,p,p,p,p,p,p,A.Z(p,p,p,p,p,p,p,p,"FFHekaya",p,p,$.c().L(20),p,p,p,p,p,!0,p,p,p,p,p,p,p,p),p,p,p),p,B.fO,p,p,p,p,p,p,p,p,p,p))
q=s.h(a,"peerId")
if(q!=null){o.xr.G(0,q)
n=o.f.h(0,q)
if(n!=null)n.ar()
o.f.G(0,q)}}},
$S:3}
A.aFk.prototype={
$1(a){var s=this.a
if(s.c!=null)s.alw(a)},
$S:3}
A.aFl.prototype={
$1(a){var s,r=this.a
if(r.c!=null&&r.id){r.P(new A.aF1(r,a))
s=J.BS(a)
if(s.kX(a,5)&&s.jr(a,0))r.D1()}},
$S:3}
A.aF1.prototype={
$0(){return this.a.cy=this.b},
$S:0}
A.aFm.prototype={
$1(a){var s=this.a
if(s.c!=null&&J.av(a,"result")!=null)A.k3(B.lo,new A.aF0(s,a),t.P)},
$S:3}
A.aF0.prototype={
$0(){var s=this.a
if(s.c!=null){s.P(new A.aEX(s,this.b))
s=s.p4
s===$&&A.a()
s.dG()}},
$S:7}
A.aEX.prototype={
$0(){var s=this.a
s.k3=!1
s.k2=J.av(this.b,"result")
s.k4=!0},
$S:0}
A.aFn.prototype={
$1(a){var s,r=this.a
if(r.c!=null&&!r.a.c&&!r.fx){s=r.ax
if(s==null)s=null
else{s=s.h(0,"correctAnswer")
s=s==null?null:J.b7(s)}r.a0a(s==null?"???":s)}},
$S:3}
A.aFo.prototype={
$1(a){var s,r=this.a
if(r.c!=null){s=J.aw(a)
r.xr.E(0,J.b7(s.h(a,"peerId")))
r.oz(s.h(a,"peerId"))}},
$S:3}
A.aFb.prototype={
$1(a){var s,r,q,p,o,n=this.a
if(n.c!=null){s=J.av(a,"peers")
for(r=J.bh(s==null?[]:s),q=n.xr;r.B();){p=r.gN()
o=J.jQ(p)
q.E(0,o.j(p))
n.oz(o.j(p))}}},
$S:3}
A.aFc.prototype={
$1(a){var s,r=this.a
if(r.c!=null){s=J.aw(a)
r.oA(s.h(a,"from"),s.h(a,"offer"))}},
$S:3}
A.aFd.prototype={
$1(a){var s,r=this.a
if(r.c!=null){s=J.aw(a)
r.Ck(s.h(a,"from"),s.h(a,"answer"))}},
$S:3}
A.aFe.prototype={
$1(a){var s,r=this.a
if(r.c!=null){s=J.aw(a)
r.xp(s.h(a,"from"),s.h(a,"candidate"))}},
$S:3}
A.aFf.prototype={
$1(a){var s=this.a
if(s.c!=null&&!s.k3&&!s.k4){s.P(new A.aF_(s))
s=s.p4
s===$&&A.a()
s.vY()}},
$S:3}
A.aF_.prototype={
$0(){return this.a.k3=!0},
$S:0}
A.aFg.prototype={
$1(a){var s=0,r=A.t(t.P),q,p=2,o=[],n=[],m=this,l,k,j,i
var $async$$1=A.o(function(b,c){if(b===1){o.push(c)
s=p}for(;;)switch(s){case 0:i=m.a
s=i.c!=null&&!i.a.c?3:4
break
case 3:k=J.av(a,"category")
if(i.RG!=null){s=1
break}i.P(new A.aEY(i,k))
p=5
l=0
case 8:if(!(l<3)){s=10
break}j=i.p3
j===$&&A.a()
j.z=B.aW
s=11
return A.n(j.tQ(j.b),$async$$1)
case 11:j=i.p3
j.z=B.fd
s=12
return A.n(j.tQ(j.a),$async$$1)
case 12:case 9:++l
s=8
break
case 10:n.push(7)
s=6
break
case 5:n=[2]
case 6:p=2
if(i.c!=null)i.P(new A.aEZ(i))
s=n.pop()
break
case 7:case 4:case 1:return A.q(q,r)
case 2:return A.p(o.at(-1),r)}})
return A.r($async$$1,r)},
$S:235}
A.aEY.prototype={
$0(){return this.a.RG=this.b},
$S:0}
A.aEZ.prototype={
$0(){return this.a.RG=null},
$S:0}
A.aFw.prototype={
$1(a){return this.a9l(a)},
a9l(a){var s=0,r=A.t(t.H),q,p=this,o,n,m,l,k,j,i,h,g,f
var $async$$1=A.o(function(b,c){if(b===1)return A.p(c,r)
for(;;)switch(s){case 0:f=p.a
if(!f.w||f.e==null){s=1
break}o=f.xr
o=A.a0(o,A.m(o).c)
n=o.length
m=0
case 3:if(!(m<o.length)){s=5
break}l=o[m]
k=f.f.h(0,l)
s=k==null?6:8
break
case 6:j=!0
s=7
break
case 8:s=9
return A.n(k.wg(),$async$$1)
case 9:i=c
j=i===B.hl||i===B.hm||i===B.eZ
case 7:if(j){h="🔄 Watchdog: اكتشاف انقطاع مع "+l+"، جاري محاولة الإصلاح..."
g=$.a8L
if(g==null)A.a8K(h)
else g.$1(h)
f.oz(l)}case 4:o.length===n||(0,A.A)(o),++m
s=3
break
case 5:case 1:return A.q(q,r)}})
return A.r($async$$1,r)},
$S:109}
A.aFA.prototype={
$1(a){return a.dG()},
$S:51}
A.aFB.prototype={
$2(a,b){b.ar()},
$S:93}
A.aEP.prototype={
$0(){var s,r,q,p,o=this,n="twist",m="betStatus",l="pointsValue",k="penaltyValue",j="activePlayer",i="currentRound",h="totalRounds",g="question",f=o.b,e=J.aw(f)
if(e.h(f,"version")!=null)o.a.rx=J.b7(e.h(f,"version"))
if(e.h(f,"phase")!=null){s=e.h(f,"phase")
if(s==="CATEGORY_SELECT"&&o.a.Q!=="CATEGORY_SELECT")o.a.LJ()
o.a.Q=s}r=o.a
if(r.Q.length===0)r.Q="LOADING"
if(e.h(f,n)!=null){q=t.N
p=t.z
if(t.f.b(e.h(f,n)))r.as=A.ed(e.h(f,n),q,p)
else r.as=A.V(["text",J.b7(e.h(f,n)),"type","text","effect","none","value",0],q,p)}if(e.h(f,m)!=null)r.y1=J.b7(e.h(f,m))
else r.y1="none"
if(e.h(f,"timer")!=null&&!r.id)r.cy=e.h(f,"timer")
if(e.h(f,l)!=null)r.db=e.h(f,l)
if(e.h(f,k)!=null)r.dx=e.h(f,k)
if(e.h(f,j)!=null)r.at=J.b7(e.h(f,j))
if(e.h(f,i)!=null)r.CW=e.h(f,i)
if(e.h(f,h)!=null)r.cx=e.h(f,h)
if(e.h(f,"teams")!=null)r.dy=e.h(f,"teams")
q=r.Q
if(q==="CATEGORY_SELECT")r.amR(f)
else if(q==="QUESTION_PHASE"||q==="TWIST_PHASE")if(e.h(f,g)!=null){f=r.ax=e.h(f,g)
if(f!=null)r.auA(r.Xa(f))}},
$S:0}
A.aFz.prototype={
$0(){this.a.k3=!0},
$S:0}
A.aEH.prototype={
$1(a){var s=this.a.e
s.toString
this.b.E8(a,s)},
$S:51}
A.aEI.prototype={
$1(a){var s=A.V(["to",this.b,"candidate",a.AH()],t.N,t.z),r=this.a.d.a
r===$&&A.a()
r.c7("webrtc_ice_candidate",s)},
$S:128}
A.aEJ.prototype={
$1(a){var s
if(a.c.d.kind==="audio"){A.en("🔊 تم استلام صوت مباشر من اللاعب: "+this.b)
s=a.b
if(s.length!==0)this.a.x.push(s[0])}},
$S:129}
A.aEF.prototype={
$1(a){return a.dG()},
$S:51}
A.aEG.prototype={
$2(a,b){b.ar()},
$S:93}
A.aEN.prototype={
$0(){return A.b([],t.Wy)},
$S:100}
A.aEO.prototype={
$0(){return A.b([],t.Wy)},
$S:100}
A.aEQ.prototype={
$0(){this.a.ry=!0},
$S:0}
A.aER.prototype={
$0(){var s=this.a
s.w=!0
s.ry=!1},
$S:0}
A.aES.prototype={
$0(){this.a.ry=!1},
$S:0}
A.aFv.prototype={
$1(a){return this.a9k(a)},
a9k(a){var s=0,r=A.t(t.H),q,p=2,o=[],n=this,m,l,k,j,i,h,g,f
var $async$$1=A.o(function(b,c){if(b===1){o.push(c)
s=p}for(;;)switch(s){case 0:g=n.a
if(g.r||g.e==null||g.f.a===0){if(g.c!=null&&g.to>0.01)g.P(new A.aFt(g))
s=1
break}p=4
j={}
i=g.f
m=new A.bp(i,A.m(i).i("bp<2>")).gY(0)
s=7
return A.n(m.wr(),$async$$1)
case 7:l=c
j.a=0
for(i=J.bh(l);i.B();){k=i.gN()
if(k.b==="media-source"&&k.d.ad("audioLevel")){j.a=A.kH(J.b7(k.d.h(0,"audioLevel")))
break}}if(g.c!=null)g.P(new A.aFu(j,g))
p=2
s=6
break
case 4:p=3
f=o.pop()
s=6
break
case 3:s=2
break
case 6:case 1:return A.q(q,r)
case 2:return A.p(o.at(-1),r)}})
return A.r($async$$1,r)},
$S:109}
A.aFt.prototype={
$0(){var s=this.a
return s.to=Math.max(0,s.to-0.1)},
$S:0}
A.aFu.prototype={
$0(){var s=B.d.c6(Math.sqrt(this.a.a)*1.8,0,1),r=this.b
r.to=r.to*0.2+s*0.8},
$S:0}
A.aEL.prototype={
$0(){return this.a.RG=this.b},
$S:0}
A.aEM.prototype={
$0(){return this.a.RG=null},
$S:0}
A.aFx.prototype={
$0(){var s=this.a
s.r=!s.r},
$S:0}
A.aFy.prototype={
$1(a){a.sll(!this.a.r)},
$S:51}
A.aFr.prototype={
$3(a,b,c){var s=this.a
return A.cc(new A.Cr(this.b,s.dy,s.a.c,new A.aFq(s),null),null,null)},
$C:"$3",
$R:3,
$S:610}
A.aFq.prototype={
$2(a,b){var s,r,q
if(a!=null){s=this.a
r=t.N
r=A.V(["teamId",a],r,r)
q=s.d.a
q===$&&A.a()
q.c7("supervisor_assign_correct",r)}else{s=this.a
r=t.z
q=s.d.a
q===$&&A.a()
q.c7("supervisor_no_answer",A.v(r,r))}s.P(new A.aFp(s))},
$S:611}
A.aFp.prototype={
$0(){return this.a.fx=!0},
$S:0}
A.aFs.prototype={
$4(a,b,c,d){var s=B.qk.aa(b.gt())
return A.Am(A.mt(d,b.gt()),s)},
$S:612}
A.aEy.prototype={
$1(a){var s=this.a
return new A.pt(a,J.b7(J.av(a,"name"))===s.at,new A.aEw(s,a),new A.aEx(s,a),"FFHekaya",null)},
$S:613}
A.aEw.prototype={
$0(){var s,r=t.N
r=A.V(["teamId",J.av(this.b,"id")],r,r)
s=this.a.d.a
s===$&&A.a()
s.c7("set_active_player",r)
return null},
$S:0}
A.aEx.prototype={
$1(a){var s=A.V(["teamId",J.av(this.b,"id"),"delta",a],t.N,t.K),r=this.a.d.a
r===$&&A.a()
r.c7("adjust_local_score",s)
return null},
$S:23}
A.aEV.prototype={
$1(a){return B.dY},
$S:53}
A.aEW.prototype={
$1(a){return!1},
$S:30}
A.aEC.prototype={
$0(){var s=this.a,r=s.ax
if(r==null)r=null
else{r=r.h(0,"correctAnswer")
r=r==null?null:J.b7(r)}return s.a0a(r==null?"???":r)},
$S:0}
A.aDZ.prototype={
$2(a,b){var s,r,q,p,o,n,m,l,k=this,j=null,i=$.c()
i=Math.min(i.gq(),i.gp())
s=k.b
r=s?2*$.c().gp():8*$.c().gp()
q=s?20*$.c().gp():40*$.c().gp()
p=s?8*$.c().gq():15*$.c().gq()
o=b.d-r-q
s=k.c
n=(b.b-32*i-p*(s-1))/s
if(n<=0||o<=0)return B.ax
i=$.c()
i=Math.min(i.gq(),i.gp())
m=$.c()
l=k.d
return new A.bi(new A.S(16*i,q,16*Math.min(m.gq(),m.gp()),r),new A.e_(B.bg,j,j,A.aTj(new A.zM(s,0,p,n/o),new A.aDY(k.a,l),l.length,B.jc,!0),j),j)},
$S:614}
A.aDY.prototype={
$2(a,b){return this.a.ahv(this.b[b])},
$S:88}
A.aDX.prototype={
$0(){return this.a.xy(this.b)},
$S:0}
A.aDV.prototype={
$2(a,b){var s=null,r=A.U(153,B.h.m()>>>16&255,B.h.m()>>>8&255,B.h.m()&255)
return A.aUe(B.cs,A.ag(s,s,B.j,B.cs,s,s,s,s,s,s,s,s,s),r)},
$S:137}
A.aDU.prototype={
$3(a,b,c){return A.cc(A.bL(B.OP,B.k,null,$.c().L(40)),null,null)},
$S:259}
A.aDW.prototype={
$2(a,b){var s,r,q=null,p=this.a.p3
p===$&&A.a()
p=p.x
p===$&&A.a()
s=A.U(B.d.T(178.5),B.bF.m()>>>16&255,B.bF.m()>>>8&255,B.bF.m()&255)
r=$.c()
return A.mt(A.ag(q,q,B.j,q,q,new A.ar(s,q,q,A.ay(17*Math.min(r.gq(),r.gp())),q,q,q,B.u),q,q,q,q,q,q,q),p*0.8)},
$S:260}
A.aEc.prototype={
$2(a,b){var s,r,q,p,o,n=null,m=this.a,l=m.fy,k=!l&&m.a.c,j=l&&!m.go&&m.a.c,i=m.go&&!m.id&&m.a.c
l=m.p2
l===$&&A.a()
s=m.Vc(!0)
s=A.bP(m.IU(m.Vc(!1),j,l,s,new A.aE9(m)),1)
l=A.aa(n,n,10*$.c().gq())
r=m.p1
r===$&&A.a()
q=m.ahP()
q=A.bP(m.IU(m.UV(),i,r,q,new A.aEa(m)),1)
r=A.aa(n,n,10*$.c().gq())
p=m.ok
p===$&&A.a()
o=m.Ve(!0)
return A.bZ(A.b([s,l,q,r,A.bP(m.IU(m.Ve(!1),k,p,o,new A.aEb(m)),1)],t.p),B.p,B.ad,B.t,0,n)},
$S:619}
A.aE9.prototype={
$0(){var s,r=this.a
r.P(new A.aE8(r))
if(r.a.c){s=t.N
s=A.V(["cardType","timer"],s,s)
r=r.d.a
r===$&&A.a()
r.c7("supervisor_flip_card",s)}},
$S:0}
A.aE8.prototype={
$0(){return this.a.go=!0},
$S:0}
A.aEa.prototype={
$0(){var s,r,q,p,o,n=this.a
n.P(new A.aE6(n))
if(n.a.c){s=n.d
r=t.N
q=A.V(["cardType","question"],r,r)
p=s.a
p===$&&A.a()
p.c7("supervisor_flip_card",q)
if(n.ax!=null&&!n.k1){n.P(new A.aE7(n))
q=n.ax.h(0,"id")
p=n.ax.h(0,"category")
if(p==null)p="General"
n=n.ax.h(0,"collection")
if(n==null)n="General"
o=t.z
r=A.V(["questionId",q,"category",p,"collectionName",n],r,o)
s.a.c7("mark_question_seen",r)
s.a.c7("start_timer_signal",A.v(o,o))}}},
$S:0}
A.aE6.prototype={
$0(){return this.a.id=!0},
$S:0}
A.aE7.prototype={
$0(){return this.a.k1=!0},
$S:0}
A.aEb.prototype={
$0(){var s,r=this.a
r.P(new A.aE5(r))
if(r.a.c){s=t.N
s=A.V(["cardType","twist"],s,s)
r=r.d.a
r===$&&A.a()
r.c7("supervisor_flip_card",s)}},
$S:0}
A.aE5.prototype={
$0(){return this.a.fy=!0},
$S:0}
A.aEv.prototype={
$2(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=null,e=this.a,d=e.p4
d===$&&A.a()
d=d.x
d===$&&A.a()
s=d*2*3.141592653589793
d=new Float64Array(16)
r=new A.aM(d)
r.bq()
d[11]=0.001
q=Math.cos(s)
p=Math.sin(s)
o=d[4]
n=d[8]
m=d[5]
l=d[9]
k=d[6]
j=d[10]
i=d[7]
h=d[11]
g=-p
d[4]=o*q+n*p
d[5]=m*q+l*p
d[6]=k*q+j*p
d[7]=i*q+h*p
d[8]=o*g+n*q
d[9]=m*g+l*q
d[10]=k*g+j*q
d[11]=i*g+h*q
h=$.c()
h=Math.min(h.gq(),h.gp())
g=$.c()
g=Math.min(g.gq(),g.gp())
i=A.bo(B.aZ,5*$.c().gq())
d=$.c()
d=A.b([new A.be(0,B.H,B.bu,B.i,15*Math.min(d.gq(),d.gp()))],t.V)
return A.oP(B.x,A.ag(f,A.cc(A.bL(B.ON,B.pM,f,e.hu(50)),f,f),B.j,f,f,new A.ar(B.bS,f,i,f,d,f,f,B.ae),f,100*g,f,f,f,f,100*h),f,r,!0)},
$S:91}
A.aDS.prototype={
$0(){var s=A.V(["decision",!1],t.N,t.y),r=this.a.d.a
r===$&&A.a()
r.c7("submit_bet_decision",s)
return null},
$S:0}
A.aDT.prototype={
$0(){var s=A.V(["decision",!0],t.N,t.y),r=this.a.d.a
r===$&&A.a()
r.c7("submit_bet_decision",s)
return null},
$S:0}
A.aEB.prototype={
$2(a,b){var s,r,q,p,o,n=null,m=b.b,l=b.d,k=Math.min(m,l)
m=A.b0h("assets/time.svg",B.bs,l,new A.aEA(k),m)
l=this.a
s=this.b
r=t.kO
q=s?A.b([new A.fh(A.U(153,B.ak.m()>>>16&255,B.ak.m()>>>8&255,B.ak.m()&255),B.i,10)],r):A.b([],r)
q=A.a6("00:",n,n,n,n,n,n,n,A.Z(n,n,l,n,n,n,n,n,"Digital",n,n,k*0.15,n,n,n,n,n,!0,n,n,n,n,n,q,n,n),n,n,n)
p=s?15:2
o=t.p
return A.cU(B.x,A.b([m,A.bZ(A.b([q,A.a6(this.c,n,n,n,n,n,n,n,A.Z(n,n,l,n,n,n,n,n,"Digital",n,n,k*0.4,n,n,n,n,n,!0,n,n,n,n,n,A.b([new A.fh(s?A.U(204,B.ak.m()>>>16&255,B.ak.m()>>>8&255,B.ak.m()&255):B.h,B.mL,p)],r),n,n),n,n,n)],o),B.dG,B.ad,B.t,0,B.A)],o),B.D,B.ag)},
$S:126}
A.aEA.prototype={
$1(a){return A.bL(B.OK,B.a1,null,this.a*0.5)},
$S:620}
A.aEs.prototype={
$1(a){var s=$.c().gq()
return A.cc(A.aa(B.HV,20*$.c().gp(),20*s),null,null)},
$S:253}
A.aEu.prototype={
$3(a,b,c){var s=$.c().gq(),r=$.c().gp()
return A.cc(A.aa(A.Qw(null,2,c.gaKc()),20*r,20*s),null,null)},
$S:621}
A.aEt.prototype={
$3(a,b,c){return B.HO},
$S:259}
A.aE4.prototype={
$0(){var s,r
if(!this.a)return
s=this.b
r=s.x
r===$&&A.a()
if(r<0.5)s.bL().a.a.h1(new A.aE_(this.c))
else s.dX()},
$S:0}
A.aE_.prototype={
$0(){this.a.$0()},
$S:7}
A.aE3.prototype={
$1(a){var s,r,q
if(!this.a)return
s=this.b
r=s.x
r===$&&A.a()
q=a.e
q.toString
s.st(r-q/250)},
$S:21}
A.aE2.prototype={
$1(a){var s,r
if(!this.a)return
s=this.b
r=s.x
r===$&&A.a()
if(!(r>0.3)){r=a.d
r.toString
r=r<-200}else r=!0
if(r)s.bL().a.a.h1(new A.aE0(this.c))
else s.dX()},
$S:38}
A.aE0.prototype={
$0(){this.a.$0()},
$S:7}
A.aE1.prototype={
$2(a,b){var s,r,q=this.a.x
q===$&&A.a()
s=q*3.141592653589793
q=new Float64Array(16)
r=new A.aM(q)
r.bq()
q[11]=0.001
r.H7(s)
if(s>=1.5707963267948966){q=new A.aM(new Float64Array(16))
q.bq()
q.H7(3.141592653589793)
q=A.oP(B.x,this.b,null,q,!0)}else q=this.c
return A.oP(B.x,q,null,r,!0)},
$S:91}
A.aEj.prototype={
$2(a,b){var s,r=A.h1(J.b7(J.av(b,"score")),null)
if(r==null)r=0
s=A.h1(J.b7(J.av(a,"score")),null)
return B.f.b9(r,s==null?0:s)},
$S:90}
A.aEk.prototype={
$3(a,b,c){return A.axb(c,new A.h(0,b))},
$S:61}
A.aEm.prototype={
$3(a,b,c){return A.Am(c,1+0.05*Math.sin(b*3.141592653589793*2))},
$S:61}
A.aEl.prototype={
$3(a,b,c){var s,r=null,q=$.c()
q=Math.min(q.gq(),q.gp())
s=$.c()
s=Math.min(s.gq(),s.gp())
return A.YC(b,A.ag(r,r,B.j,r,r,new A.ar(r,r,r,r,r,new A.vM(B.x,0,6.283185307179586,B.at,A.b([B.B,A.U(153,B.aZ.m()>>>16&255,B.aZ.m()>>>8&255,B.aZ.m()&255),B.B,A.U(153,B.S.m()>>>16&255,B.S.m()>>>8&255,B.S.m()&255),B.B],t.W),r,r),r,B.ae),r,250*s,r,r,r,r,250*q))},
$S:61}
A.aEn.prototype={
$3(a,b,c){return A.mt(c,b)},
$S:624}
A.aEo.prototype={
$3(a,b,c){var s=this.a
return A.TY(new A.aEi(s,b),J.cw(s.dy),B.dA,!1,B.ai,!0)},
$S:625}
A.aEi.prototype={
$2(a1,a2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=null,b=J.av(this.a.dy,a2),a=J.aw(b),a0=A.h1(J.b7(a.h(b,"score")),c)
if(a0==null)a0=0
s=a2*0.15
r=B.d.c6((this.b-s)/(s+0.4-s),0,1)
q=B.hX.aa(r)
p=a2===0
o=p?B.aZ:B.dh
if(a2===1)o=B.KQ
if(a2===2)o=B.Mv
n=B.d.c6(r,0,1)
m=$.c().gp()
l=15*$.c().gq()
k=10*$.c().gp()
j=p?A.U(51,B.aZ.m()>>>16&255,B.aZ.m()>>>8&255,B.aZ.m()&255):A.U(B.d.T(76.5),B.l.m()>>>16&255,B.l.m()>>>8&255,B.l.m()&255)
i=$.c()
i=A.ay(15*Math.min(i.gq(),i.gp()))
h=p?B.aZ:B.fF
h=A.bo(h,$.c().gq())
g=p?B.rv:B.P5
g=A.bL(g,o,c,$.c().L(35))
f=A.aa(c,c,10*$.c().gq())
a=a.h(b,"name")
p=p?B.ap:B.h
e=t.p
p=A.bP(A.bZ(A.b([g,f,A.bP(A.a6(a,c,c,1,B.aG,c,c,c,A.Z(c,c,p,c,c,c,c,c,"FFHekaya",c,c,$.c().L(35),c,c,B.o,c,c,!0,c,c,c,c,c,c,c,c),c,c,c),1)],e),B.p,B.r,B.t,0,c),1)
a=15*$.c().gq()
f=4*$.c().gp()
g=$.c()
g=A.ay(10*Math.min(g.gq(),g.gp()))
d=A.bo(o,1)
return A.axb(A.mt(A.ag(c,A.bZ(A.b([p,A.ag(c,A.ra(new A.aEd(),c,B.MH,A.cT(0,1000+a2*200,0),new A.nU(0,a0),t.S),B.j,c,c,new A.ar(B.k,c,d,g,c,c,c,B.u),c,c,c,new A.S(a,f,a,f),c,c,c)],e),B.p,B.eI,B.t,0,c),B.j,c,c,new A.ar(j,c,h,i,c,c,c,B.u),c,c,new A.S(0,0,0,10*m),new A.S(l,k,l,k),c,c,c),n),new A.h(400*(1-q),0))},
$S:626}
A.aEd.prototype={
$3(a,b,c){var s=null
return A.a6(""+b,s,s,s,s,s,s,s,A.Z(s,s,B.ap,s,s,s,s,s,"FFHekaya",s,s,$.c().L(35),s,s,B.cy,s,s,!0,s,s,s,s,s,s,s,s),s,s,s)},
$S:627}
A.aEp.prototype={
$0(){var s=this.a,r=s.a,q=r.c,p=t.N,o=s.d
r=r.w
if(q){r=A.V(["roomCode",r],p,p)
o=o.a
o===$&&A.a()
o.c7("end_game",r)}else{r=A.V(["roomCode",r],p,p)
o=o.a
o===$&&A.a()
o.c7("leave_game",r)}s.J7()
r=s.c
r.toString
A.cK(r,!1).kO(A.hg(new A.aEg(s),null,t.z),new A.aEh())},
$S:0}
A.aEg.prototype={
$1(a){var s=this.a.a
return new A.tY(s.f,s.r,null)},
$S:628}
A.aEh.prototype={
$1(a){return!1},
$S:30}
A.aEq.prototype={
$3(a,b,c){return A.Am(c,1+0.02*Math.sin(b*3.141592653589793*4))},
$S:61}
A.aEr.prototype={
$0(){var s=this.a,r=s.c
r.toString
A.cK(r,!1).kO(A.hg(new A.aEe(s),null,t.z),new A.aEf())},
$S:0}
A.aEe.prototype={
$1(a){var s=this.a,r=s.a,q=r.d,p=r.f
r=r.r
s=s.dy
return q?new A.ke(p,r,s,null):new A.lg(p,r,s,null)},
$S:105}
A.aEf.prototype={
$1(a){return!1},
$S:30}
A.J_.prototype={
ao(){return new A.a5N(null,null)}}
A.a5N.prototype={
aD(){var s,r,q,p=this,o=null
p.aP()
s=A.bX(o,B.iA,o,o,p)
s.vY()
p.d=s
r=t.Y
q=r.i("aH<aI.T>")
p.e=new A.aH(A.cF(B.cv,s,o),new A.aG(0.8,1.4,r),q)
p.f=new A.aH(A.cF(B.cv,p.d,o),new A.aG(1,0,r),q)},
l(){var s=this.d
s===$&&A.a()
s.l()
this.afK()},
O(a){var s=this.d
s===$&&A.a()
return A.hz(A.fS(s,new A.aND(this),null),!0,null)}}
A.aND.prototype={
$2(a,b){var s,r,q,p,o,n,m=null,l=this.a,k=l.f
k===$&&A.a()
k=k.b.aa(k.a.gt())
l=l.e
l===$&&A.a()
l=l.b.aa(l.a.gt())
s=$.c()
s=Math.min(s.gq(),s.gp())
r=$.c()
r=Math.min(r.gq(),r.gp())
q=A.bo(A.U(204,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255),4*$.c().gq())
p=A.U(B.d.T(127.5),B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
o=$.c()
o=Math.min(o.gq(),o.gp())
n=$.c()
return A.mt(A.Am(A.ag(m,m,B.j,m,m,new A.ar(m,m,q,m,A.b([new A.be(2*Math.min(n.gq(),n.gp()),B.H,p,B.i,10*o)],t.V),m,m,B.ae),m,80*r,m,m,m,m,80*s),l),k)},
$S:260}
A.Cr.prototype={
ao(){return new A.K5($.P6(),null,null)},
aJc(a,b){return this.r.$2(a,b)}}
A.K5.prototype={
aD(){var s,r=this
r.aP()
r.d=A.bX(null,B.eu,null,null,r)
A.k3(B.bh,new A.azK(r),t.P)
s=r.e.a
s===$&&A.a()
s.bD("blink_team_and_close",r.gZg())},
l(){var s=this,r=s.e.a
r===$&&A.a()
r.lB("blink_team_and_close",s.gZg())
r=s.d
r===$&&A.a()
r.l()
s.af7()},
asN(a){if(this.c!=null&&!this.a.f)this.uz(J.av(a,"teamId"))},
xD(a){return this.apv(a)},
apv(a){var s=0,r=A.t(t.H),q,p=this,o,n
var $async$xD=A.o(function(b,c){if(b===1)return A.p(c,r)
for(;;)switch(s){case 0:if(!p.a.f||p.r){s=1
break}p.r=!0
o=A.V(["teamId",a,"isWrong",!1],t.N,t.X)
n=p.e.a
n===$&&A.a()
n.c7("broadcast_blink_team",o)
s=3
return A.n(p.uz(a),$async$xD)
case 3:p.a.aJc(a,!1)
case 1:return A.q(q,r)}})
return A.r($async$xD,r)},
uz(a){return this.axT(a)},
axT(a){var s=0,r=A.t(t.H),q,p=this,o,n
var $async$uz=A.o(function(b,c){if(b===1)return A.p(c,r)
for(;;)switch(s){case 0:if(p.c==null){s=1
break}p.P(new A.azI(p,a))
s=3
return A.n(A.k3(B.ll,null,t.z),$async$uz)
case 3:s=p.c!=null?4:5
break
case 4:o=p.d
o===$&&A.a()
s=6
return A.n(o.dX(),$async$uz)
case 6:o=p.c
if(o!=null){n=A.aTO(o)
o=n!=null&&n.Nj()}else o=!1
if(o){o=p.c
o.toString
A.cK(o,!1).ff()}case 5:case 1:return A.q(q,r)}})
return A.r($async$uz,r)},
O(a){var s=this.d
s===$&&A.a()
return A.fS(s,new A.azJ(this),null)},
ahr(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=this,e=null,d="FFHekaya",c=$.c().gq(),b=$.c().gp(),a=16*$.c().gq(),a0=20*$.c().gp(),a1=$.c()
a1=A.ay(30*Math.min(a1.gq(),a1.gp()))
s=A.bo(B.l,5*$.c().gq())
r=$.c()
r=Math.min(r.gq(),r.gp())
r=A.b([new A.be(0,B.H,B.ic,new A.h(0,10*$.c().gp()),20*r)],t.V)
q=A.a6("الإجابة الصحيحة هي",e,e,e,e,e,e,e,A.Z(e,e,B.l,e,e,e,e,e,d,e,e,$.c().L(40),e,e,e,e,e,!0,e,e,e,e,e,e,e,e),e,B.T,e)
p=A.aa(e,10*$.c().gp(),e)
o=f.a.c
n=$.c().L(60)
$.a_()
m=A.as()
m.b=B.aU
m.c=6
m.r=B.h.gt()
m=A.a6(o,e,e,4,B.aG,e,!0,e,A.Z(e,e,e,e,e,e,e,e,d,e,e,n,e,e,B.cy,m,e,!0,e,e,e,e,e,e,e,e),B.N,B.T,e)
n=f.a.c
o=$.c().L(60)
l=$.c().gp()
k=$.c()
j=t.p
k=A.bP(A.bf(A.b([q,p,A.cc(A.aa(A.cU(B.x,A.b([m,A.a6(n,e,e,4,B.aG,e,!0,e,A.Z(e,e,B.l,e,e,e,e,e,d,e,e,o,e,e,B.cy,e,e,!0,e,e,e,e,e,A.b([new A.fh(B.bu,new A.h(0,4*l),4*Math.min(k.gq(),k.gp()))],t.kO),e,e),B.N,B.T,e)],j),B.D,B.ag),e,1/0),e,e)],j),B.p,B.ad,B.t),1)
l=15*$.c().gp()
l=A.ag(e,e,B.j,B.cd,e,e,e,2*$.c().gp(),new A.S(0,l,0,l),e,e,e,1/0)
o=A.a6("مين جاوب؟",e,e,e,e,e,e,e,A.Z(e,e,B.l,e,e,e,e,e,d,e,e,$.c().L(40),e,e,B.o,e,e,!0,e,e,e,e,e,e,e,e),e,e,e)
n=A.aa(e,15*$.c().gp(),e)
q=!f.a.f||f.r
p=$.c().gp()
m=$.c().gq()
i=$.c().gp()
h=t.l7
g=J.j5(f.a.d,new A.azG(f),h)
g=A.a0(g,g.$ti.i("ao.E"))
h=A.a0(g,h)
h.push(f.Vb("لا أحد",e,new A.azH(f),!0))
return A.jt(B.aa,!0,e,A.ag(e,A.bf(A.b([k,l,o,n,A.hz(A.ag(e,A.zL(A.JU(B.k0,h,15*i,15*m),B.D,e,B.dA,!1,B.ai),B.j,e,new A.al(0,1/0,0,250*p),e,e,e,e,e,e,e,e),q,e)],j),B.p,B.r,B.t),B.j,e,e,new A.ar(B.Mc,e,s,a1,r,e,e,B.u),e,500*b,e,new A.S(a,a0,a,a0),e,e,500*c),B.j,e,0,e,e,e,e,e,B.he)},
Vb(a,b,c,d){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=null
if(!(d&&this.f==="none"))s=!d&&this.f==b
else s=!0
r=this.f!=null&&!s
if(s)q=d?B.dF:B.fx
else q=d?B.qc:B.h
if(s)p=B.h
else p=d?B.h:B.q7
o=r?0.4:1
n=$.c()
n=A.ay(50*Math.min(n.gq(),n.gp()))
m=24*$.c().gq()
l=12*$.c().gp()
k=$.c()
k=A.ay(50*Math.min(k.gq(),k.gp()))
if(s)j=B.h
else j=d?B.h:B.cd
j=A.bo(j,d||s?2*$.c().gq():$.c().gq())
i=t.V
if(s){h=A.U(204,q.m()>>>16&255,q.m()>>>8&255,q.m()&255)
g=$.c()
g=Math.min(g.gq(),g.gp())
f=$.c()
i=A.b([new A.be(2*Math.min(f.gq(),f.gp()),B.H,h,B.i,15*g)],i)}else i=A.b([new A.be(0,B.H,B.bu,new A.h(0,4*$.c().gp()),0)],i)
return A.Pu(A.l7(!1,n,!0,A.kN(A.a6(a,e,e,e,e,e,e,e,A.Z(e,e,p,e,e,e,e,e,"FFHekaya",e,e,$.c().L(30),e,e,B.o,e,1.1,!0,e,e,e,e,e,e,e,e),e,e,e),e,B.O,new A.ar(q,e,j,k,i,e,e,B.u),B.bh,e,e,e,new A.S(m,l,m,l),e),e,!0,e,e,e,e,e,e,e,c,e,e,e,e,e,e,e),B.O,B.bh,o)}}
A.azK.prototype={
$0(){var s=this.a
if(s.c!=null){s=s.d
s===$&&A.a()
s.bL()}},
$S:7}
A.azI.prototype={
$0(){var s=this.b
if(s==null)s="none"
this.a.f=s},
$S:0}
A.azJ.prototype={
$2(a,b){var s,r,q,p,o,n,m=null,l=this.a,k=l.d
k===$&&A.a()
k=k.x
k===$&&A.a()
s=k*3.14159
k=new Float64Array(16)
r=new A.aM(k)
r.bq()
k[11]=0.001
r.H7(s)
if(s>=1.570795){k=new A.aM(new Float64Array(16))
k.bq()
k.H7(3.14159)
k=A.oP(B.x,l.ahr(),m,k,!0)
l=k}else{l=$.c().gq()
k=$.c().gp()
q=$.c()
q=A.ay(20*Math.min(q.gq(),q.gp()))
p=A.bo(B.h,4*$.c().gq())
o=$.c()
o=Math.min(o.gq(),o.gp())
n=$.c()
o=A.b([new A.be(5*Math.min(n.gq(),n.gp()),B.H,B.a1,B.i,20*o)],t.V)
l=A.ag(m,A.cc(A.nR("assets/logo.png",m,m,m,150*$.c().gq()),m,m),B.j,m,m,new A.ar(B.ie,m,p,q,o,m,m,B.u),m,500*k,m,m,m,m,500*l)}return A.oP(B.x,l,m,r,!0)},
$S:91}
A.azG.prototype={
$1(a){var s=this.a,r=J.aw(a)
return s.Vb(r.h(a,"name"),r.h(a,"id"),new A.azF(s,a),!1)},
$S:261}
A.azF.prototype={
$0(){return this.a.xD(J.av(this.b,"id"))},
$S:0}
A.azH.prototype={
$0(){return this.a.xD(null)},
$S:0}
A.pt.prototype={
ao(){return new A.ZJ(A.b([],t.p),null,null)},
a6R(a){return this.f.$1(a)}}
A.ZJ.prototype={
aD(){this.aP()
var s=A.h1(J.b7(J.av(this.a.c,"score")),null)
this.d=s==null?0:s},
aU(a){var s,r,q=this
q.bc(a)
s=A.h1(J.b7(J.av(q.a.c,"score")),null)
if(s==null)s=0
r=q.d
if(s!==r){q.agQ(s-r)
q.d=s}},
agQ(a){var s,r,q=this,p=null,o=new A.lB(),n=a>0,m=q.c
m.toString
m=A.bS(m,p,t.w).w
s=n?B.j9:B.cD
r=""+a
if(n)r="+"+r
m=m.a.a<900?40*$.c().gp():70*$.c().gp()
q.P(new A.azz(q,A.eu(m,new A.Ek(r,s,q.a.r,new A.azA(q,o),p),p,o,0,0,p,p)))},
O(a){var s,r,q,p,o,n,m,l,k,j,i=this,h=null,g=A.bS(a,h,t.w).w.a.a<900,f=i.a.e,e=g?4*$.c().gq():8*$.c().gq(),d=g?12*$.c().gq():25*$.c().gq(),c=g?8*$.c().gp():15*$.c().gp(),b=i.a.d?B.k:A.U(B.d.T(127.5),B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
if(g){s=$.c()
s=12*Math.min(s.gq(),s.gp())}else{s=$.c()
s=20*Math.min(s.gq(),s.gp())}s=A.ay(s)
if(i.a.d)r=A.bo(B.l,g?1.5*$.c().gq():3*$.c().gq())
else r=A.bo(B.B,2*$.c().gq())
q=t.V
if(i.a.d){p=A.U(102,B.bS.m()>>>16&255,B.bS.m()>>>8&255,B.bS.m()&255)
o=$.c()
o=Math.min(o.gq(),o.gp())
n=$.c()
q=A.b([new A.be(2*Math.min(n.gq(),n.gp()),B.H,p,B.i,12*o)],q)}else q=A.b([],q)
p=J.av(i.a.c,"name")
o=i.a.r
p=A.a6(p,h,h,1,B.aG,h,h,h,A.Z(h,h,B.bF,h,h,h,h,h,o,h,h,g?$.c().L(32):$.c().L(45),h,h,B.o,h,h,!0,h,h,h,h,h,h,h,h),h,h,h)
o=A.aa(h,g?4*$.c().gp():10*$.c().gp(),h)
n=A.l7(!1,h,!0,A.bL(B.P1,B.ap,h,g?$.c().L(35):$.c().L(50)),h,!0,h,h,h,h,h,h,h,new A.azB(i),h,h,h,h,h,h,h)
m=g?8*$.c().gq():15*$.c().gq()
l=A.j(J.av(i.a.c,"score"))
k=i.a
j=k.r
k=k.d?B.h:B.I
l=A.a6(l,h,h,h,h,h,h,h,A.Z(h,h,k,h,h,h,h,h,j,h,h,g?$.c().L(35):$.c().L(50),h,h,B.cy,h,h,!0,h,h,h,h,h,h,h,h),h,h,h)
k=t.p
k=A.b([A.fA(h,A.kN(A.bf(A.b([p,o,A.bZ(A.b([n,new A.bi(new A.S(m,0,m,0),l,h),A.l7(!1,h,!0,A.bL(B.OV,B.bF,h,g?$.c().L(35):$.c().L(50)),h,!0,h,h,h,h,h,h,h,new A.azC(i),h,h,h,h,h,h,h)],k),B.p,B.r,B.Z,0,h)],k),B.p,B.ad,B.Z),h,B.O,new A.ar(b,h,r,s,q,h,h,B.u),B.bh,h,h,new A.S(e,0,e,0),new A.S(d,c,d,c),h),B.a8,!1,h,h,h,h,h,h,h,h,h,h,h,h,h,h,f,h,h,h,h,h,h)],k)
B.b.I(k,i.e)
return A.cU(B.bg,k,B.j,B.ag)}}
A.azA.prototype={
$0(){var s=this.a
if(s.c!=null)s.P(new A.azy(s,this.b))},
$S:0}
A.azy.prototype={
$0(){B.b.fg(this.a.e,new A.azx(this.b))},
$S:0}
A.azx.prototype={
$1(a){return J.d(a.a,this.a)},
$S:212}
A.azz.prototype={
$0(){this.a.e.push(this.b)},
$S:0}
A.azB.prototype={
$0(){return this.a.a.a6R(-50)},
$S:0}
A.azC.prototype={
$0(){return this.a.a.a6R(50)},
$S:0}
A.Ek.prototype={
ao(){return new A.a11(null,null)},
aIl(){return this.f.$0()}}
A.a11.prototype={
aD(){var s,r,q=this,p=null
q.aP()
s=A.bX(p,B.qz,p,p,q)
q.d=s
r=t.Y
q.e=new A.aH(A.cF(B.PQ,s,p),new A.aG(1,0,r),r.i("aH<aI.T>"))
r=t.Ni
q.f=new A.aH(A.cF(B.lb,q.d,p),new A.aG(B.i,B.WR,r),r.i("aH<aI.T>"))
q.d.bL().b6(new A.aCP(q),t.P)},
l(){var s=this.d
s===$&&A.a()
s.l()
this.afi()},
O(a){var s,r,q,p,o,n=this,m=null,l=n.f
l===$&&A.a()
s=n.e
s===$&&A.a()
r=n.a
q=r.c
r=r.e
p=$.c().L(65)
o=n.a.d
return A.qX(new A.e1(s,!1,A.a6(q,m,m,m,m,m,m,m,A.Z(m,m,o,m,m,m,m,m,r,m,m,p,m,m,B.cy,m,m,!0,m,m,m,m,m,A.b([B.a_I,new A.fh(A.U(B.d.T(127.5),o.m()>>>16&255,o.m()>>>8&255,o.m()&255),B.i,15)],t.kO),m,m),B.N,m,m),m),l,m,!0)}}
A.aCP.prototype={
$1(a){this.a.a.aIl()},
$S:29}
A.a7h.prototype={
bA(){this.ce()
this.c5()
this.eU()},
l(){var s=this,r=s.b2$
if(r!=null)r.M(s.geE())
s.b2$=null
s.aJ()}}
A.O_.prototype={
l(){var s=this,r=s.ba$
if(r!=null)r.M(s.gfl())
s.ba$=null
s.aJ()},
bA(){this.ce()
this.c5()
this.fm()}}
A.Ob.prototype={
l(){var s=this,r=s.ba$
if(r!=null)r.M(s.gfl())
s.ba$=null
s.aJ()},
bA(){this.ce()
this.c5()
this.fm()}}
A.Od.prototype={
bA(){this.ce()
this.c5()
this.eU()},
l(){var s=this,r=s.b2$
if(r!=null)r.M(s.geE())
s.b2$=null
s.aJ()}}
A.Ox.prototype={
l(){var s=this,r=s.ba$
if(r!=null)r.M(s.gfl())
s.ba$=null
s.aJ()},
bA(){this.ce()
this.c5()
this.fm()}}
A.tY.prototype={
ao(){return new A.L4(null,null)}}
A.L4.prototype={
aD(){var s,r=this,q=null
r.aP()
r.aqg()
s=A.bX(q,B.lo,q,q,r)
r.r=s
r.w=A.cF(B.qk,s,q)
r.r.bL()},
aqg(){var s=A.aVl("https://api.3krooot.com",A.V(["transports",A.b(["websocket"],t.s),"autoConnect",!1],t.N,t.z))
this.x=s
s.z_()
this.x.bD("connect",new A.aDA())},
l(){var s=this.r
s===$&&A.a()
s.l()
this.afj()},
oy(){var s=0,r=A.t(t.H),q,p=2,o=[],n=this,m,l,k,j,i,h,g
var $async$oy=A.o(function(a,b){if(a===1){o.push(b)
s=p}for(;;)switch(s){case 0:h=n.c
h.toString
s=3
return A.n(A.BY(!0,new A.aDx(),h,t.y),$async$oy)
case 3:j=b
if(!(j==null?!1:j)){s=1
break}p=5
s=8
return A.n(A.b4I(A.di("https://api.3krooot.com/api/users/"+n.a.c,0,null)),$async$oy)
case 8:m=b
s=m.b===200||m.b===204?9:11
break
case 9:s=12
return A.n(A.vE(),$async$oy)
case 12:l=b
s=13
return A.n(J.b9d(l),$async$oy)
case 13:s=14
return A.n($.C1().n7(),$async$oy)
case 14:if(n.c!=null){h=n.x
h===$&&A.a()
h.Fa()
h=n.c
h.toString
A.cK(h,!1).kO(A.hg(new A.aDy(),null,t.z),new A.aDz())}s=10
break
case 11:A.hW().$1("فشل الحذف من السيرفر")
case 10:p=2
s=7
break
case 5:p=4
g=o.pop()
k=A.a7(g)
A.hW().$1("خطأ في الاتصال: "+A.j(k))
s=7
break
case 4:s=2
break
case 7:case 1:return A.q(q,r)
case 2:return A.p(o.at(-1),r)}})
return A.r($async$oy,r)},
qB(){var s=0,r=A.t(t.H),q=1,p=[],o=this,n,m,l,k,j
var $async$qB=A.o(function(a,b){if(a===1){p.push(b)
s=q}for(;;)switch(s){case 0:q=3
s=6
return A.n(A.vE(),$async$qB)
case 6:n=b
s=7
return A.n(J.hX(n,"saved_userId"),$async$qB)
case 7:s=8
return A.n(J.hX(n,"saved_username"),$async$qB)
case 8:s=9
return A.n($.C1().n7(),$async$qB)
case 9:q=1
s=5
break
case 3:q=2
j=p.pop()
m=A.a7(j)
A.hW().$1("Logout error: "+A.j(m))
s=5
break
case 2:s=1
break
case 5:if(o.c!=null){k=o.x
k===$&&A.a()
k.Fa()
k=o.c
k.toString
A.cK(k,!1).kO(A.hg(new A.aDB(),null,t.z),new A.aDC())}return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$qB,r)},
awS(a){A.BY(!0,new A.aDO(this,A.bS(a,null,t.w).w.a),a,t.z)},
awQ(a){var s={}
s.a="جاري التحميل..."
s.b=s.c=!1
A.BY(!1,new A.aDJ(s,this,A.bS(a,null,t.w).w.a),a,t.z).b6(new A.aDK(this),t.P)},
ahO(a,a0){var s,r,q,p,o,n,m,l,k,j="FFHekaya",i=null,h=A.i_(B.x,A.a6("الربط مع شاشة خارجية",i,i,i,i,i,i,i,A.Z(i,i,B.k,i,i,i,i,i,j,i,i,$.c().L(50),i,i,B.o,i,i,!0,i,i,i,i,i,i,i,i),i,i,i),B.j,B.b3),g=A.aa(i,10*$.c().gp(),i),f=A.i_(B.x,A.a6("1. افتح هذا الرابط على المتصفح:",i,i,i,i,i,i,i,A.Z(i,i,B.k,i,i,i,i,i,j,i,i,$.c().L(30),i,i,i,i,i,!0,i,i,i,i,i,i,i,i),i,i,i),B.j,B.b3),e=A.aa(i,5*$.c().gp(),i),d=8*$.c().gp(),c=A.U(B.d.T(127.5),B.h.m()>>>16&255,B.h.m()>>>8&255,B.h.m()&255),b=$.c()
b=A.ay(10*Math.min(b.gq(),b.gp()))
s=A.bo(B.dh,1)
d=A.ag(i,A.cc(A.i_(B.x,A.a6("www.3krooot.com",i,i,i,i,i,i,i,A.Z(i,i,B.l2,i,i,i,i,i,i,i,i,$.c().L(32),i,i,B.o,i,i,!0,i,i,i,i,i,i,i,i),i,i,i),B.j,B.b3),i,i),B.j,i,i,new A.ar(c,i,s,b,i,i,i,B.u),i,i,i,new A.S(0,d,0,d),i,i,1/0)
b=A.aa(i,10*$.c().gp(),i)
s=A.i_(B.x,A.a6("2. أدخل كود الربط التالي:",i,i,i,i,i,i,i,A.Z(i,i,B.k,i,i,i,i,i,j,i,i,$.c().L(30),i,i,i,i,i,!0,i,i,i,i,i,i,i,i),i,i,i),B.j,B.b3)
c=A.aa(i,5*$.c().gp(),i)
r=5*$.c().gp()
q=$.c()
q=A.ay(15*Math.min(q.gq(),q.gp()))
p=A.bo(B.k,2*$.c().gq())
o=$.c()
o=Math.min(o.gq(),o.gp())
n=t.V
o=A.b([new A.be(0,B.H,B.cd,new A.h(0,2*$.c().gp()),4*o)],n)
r=A.ag(i,A.cc(A.i_(B.x,A.a6(a0,i,i,i,i,i,i,i,A.Z(i,i,B.I,i,i,i,i,i,i,i,i,$.c().L(45),i,i,B.o,i,i,!0,i,8*$.c().gq(),i,i,i,i,i,i),i,i,i),B.j,B.b3),i,i),B.j,i,i,new A.ar(B.h,i,p,q,o,i,i,B.u),i,i,i,new A.S(0,r,0,r),i,i,1/0)
o=$.c().gq()
q=t.p
o=A.bZ(A.b([A.aa(B.HU,25*$.c().gq(),25*o),A.aa(i,i,15*$.c().gq()),A.i_(B.x,A.a6("في انتظار الشاشة...",i,i,i,i,i,i,i,A.Z(i,i,B.k,i,i,i,i,i,j,i,i,$.c().L(32),i,i,B.o,i,i,!0,i,i,i,i,i,i,i,i),i,i,i),B.j,B.b3)],q),B.p,B.ad,B.t,0,i)
p=A.aa(i,15*$.c().gp(),i)
m=50*$.c().gq()
l=8*$.c().gp()
k=$.c()
k=A.awm(i,i,B.kX,i,i,i,i,i,i,i,i,i,new A.S(m,l,m,l),i,new A.c2(A.ay(12*Math.min(k.gq(),k.gp())),new A.aW(B.pG,$.c().gq(),B.z,-1)),i,i,i,i,i)
k=A.bP(A.bf(A.b([f,e,new A.jk(1,B.cX,d,i),b,s,c,new A.jk(2,B.cX,r,i),B.a1_,o,p,A.cc(A.i_(B.x,A.vQ(A.a6("إلغاء",i,i,i,i,i,i,i,A.Z(i,i,B.dF,i,i,i,i,i,j,i,i,$.c().L(30),i,i,B.o,i,i,!0,i,i,i,i,i,i,i,i),i,i,i),new A.aDt(this,a),k),B.j,B.b3),i,i),A.aa(i,5*$.c().gp(),i)],q),B.an,B.r,B.t),5)
p=$.c().gq()
o=15*$.c().gq()
p=A.ag(i,i,B.j,B.cd,i,i,i,i,new A.S(o,0,o,0),i,i,i,2*p)
o=A.i_(B.x,A.a6("شرح توضيحي:",i,i,i,i,i,i,i,A.Z(i,i,B.k,i,i,i,i,i,j,i,i,$.c().L(35),i,i,B.o,i,i,!0,i,i,i,i,i,i,i,i),i,i,i),B.j,B.b3)
r=A.aa(i,10*$.c().gp(),i)
c=A.bo(B.I,3*$.c().gq())
s=$.c()
s=A.ay(15*Math.min(s.gq(),s.gp()))
b=$.c()
b=Math.min(b.gq(),b.gp())
n=A.b([new A.be(0,B.H,B.bu,new A.h(4*$.c().gq(),4*$.c().gp()),8*b)],n)
b=$.c()
return A.bf(A.b([h,g,A.bP(A.bZ(A.b([k,p,A.bP(A.bf(A.b([o,r,A.bP(A.ag(i,A.no(A.ay(12*Math.min(b.gq(),b.gp())),A.nR("assets/local.gif",new A.aDu(),B.kB,i,i)),B.j,i,i,new A.ar(i,i,c,s,n,i,i,B.u),i,i,i,i,i,i,1/0),1)],q),B.p,B.ad,B.t),4)],q),B.an,B.r,B.t,0,i),1)],q),B.p,B.r,B.t)},
ahx(a){var s,r,q,p,o,n,m,l,k=null,j="FFHekaya",i=$.c()
i=20*Math.min(i.gq(),i.gp())
i=A.ag(k,A.bL(B.OY,B.fx,k,$.c().L(60)),B.j,k,k,new A.ar(B.kM,k,k,k,k,k,k,B.ae),k,k,k,new A.S(i,i,i,i),k,k,k)
s=A.aa(k,15*$.c().gp(),k)
r=A.i_(B.x,A.a6("تم الربط بنجاح!",k,k,k,k,k,k,k,A.Z(k,k,B.eo,k,k,k,k,k,j,k,k,$.c().L(50),k,k,B.o,k,k,!0,k,k,k,k,k,k,k,k),B.N,k,k),B.j,B.b3)
q=A.aa(k,10*$.c().gp(),k)
p=A.i_(B.x,A.a6("شاشتك متصلة الآن، قم باختيار الفئات من الشاشة للبدء.",k,k,k,k,k,k,k,A.Z(k,k,B.k,k,k,k,k,k,j,k,k,$.c().L(30),k,k,k,k,k,!0,k,k,k,k,k,k,k,k),B.N,k,k),B.j,B.b3)
o=A.aa(k,30*$.c().gp(),k)
n=30*$.c().gq()
m=12*$.c().gp()
l=$.c()
l=A.hZ(k,k,B.kT,k,k,k,5,k,k,k,k,k,k,new A.S(n,m,n,m),k,new A.c2(A.ay(15*Math.min(l.gq(),l.gp())),B.y),k,k,k,k,k)
return A.bf(A.b([new A.jk(1,B.cX,i,k),s,r,q,p,o,A.i_(B.x,A.aYq(A.bL(B.OS,B.h,k,$.c().L(30)),A.a6("قطع الاتصال بالشاشة",k,k,k,k,k,k,k,A.Z(k,k,B.h,k,k,k,k,k,j,k,k,$.c().L(30),k,k,k,k,k,!0,k,k,k,k,k,k,k,k),k,k,k),new A.aDs(this,a),l),B.j,B.b3)],t.p),B.p,B.ad,B.t)},
O(a){var s,r,q,p,o,n,m,l,k,j,i=this,h=null,g="FFHekaya",f=A.b([B.bF,B.ap],t.W),e=i.w
e===$&&A.a()
s=20*$.c().gq()
r=15*$.c().gp()
q=$.c()
q=10*Math.min(q.gq(),q.gp())
p=A.bo(B.ak,2*$.c().gq())
q=A.fA(h,A.ag(h,A.bL(B.m7,B.eq,h,$.c().L(30)),B.j,h,h,new A.ar(B.i9,h,p,h,h,h,h,B.ae),h,h,h,new A.S(q,q,q,q),h,h,h),B.a8,!1,h,h,h,h,h,h,h,h,h,h,h,h,h,h,i.gard(),h,h,h,h,h,h)
p=A.aa(h,h,15*$.c().gq())
o=$.c()
o=10*Math.min(o.gq(),o.gp())
n=A.bo(B.l,2*$.c().gq())
m=t.p
o=A.bZ(A.b([q,p,A.fA(h,A.ag(h,A.bL(B.P6,B.h,h,$.c().L(30)),B.j,h,h,new A.ar(B.eq,h,n,h,h,h,h,B.ae),h,h,h,new A.S(o,o,o,o),h,h,h),B.a8,!1,h,h,h,h,h,h,h,h,h,h,h,h,h,h,i.gajR(),h,h,h,h,h,h)],m),B.p,B.r,B.t,0,h)
n=i.a.d
p=$.c().L(45)
p=A.i_(B.x,A.a6("أهلاً بك يا "+n+"!",h,h,h,h,h,h,h,A.Z(h,h,A.U(204,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255),h,h,h,h,h,g,h,h,p,h,h,h,h,h,!0,h,h,h,h,h,h,h,h),h,B.T,h),B.j,B.b3)
n=A.aa(h,5*$.c().gp(),h)
q=$.c().L(50)
l=$.c().gq()
k=$.c().gp()
j=$.c()
j=A.bP(A.bf(A.b([p,n,A.i_(B.x,A.a6("اختر وضع اللعب",h,h,h,h,h,h,h,A.Z(h,h,B.k,h,h,h,h,h,g,h,h,q,h,h,B.o,h,h,!0,h,h,h,h,h,A.b([new A.fh(B.cd,new A.h(2*l,2*k),4*Math.min(j.gq(),j.gp()))],t.kO),h,h),h,h,h),B.j,B.b3)],m),B.p,B.ad,B.t),2)
k=40*$.c().gq()
l=10*$.c().gp()
return A.zt(h,A.ag(h,A.qP(!0,A.as5(B.x,A.bf(A.b([new A.bi(new A.S(s,r,s,r),o,h),j,A.bP(new A.bi(new A.S(k,l,k,l),A.bZ(A.b([A.bP(new A.pX("لعب محلي","العب مع أصدقائك على نفس الجهاز","assets/local.png",B.k,new A.aDQ(i,a),h),1),A.aa(h,h,30*$.c().gq()),A.bP(new A.pX("لعب أونلاين","نافس أصدقائك عبر الإنترنت","assets/online.png",B.k,new A.aDR(i,a),h),1)],m),B.p,B.r,B.t,0,h),h),5),A.aa(h,20*$.c().gp(),h)],m),B.p,B.r,B.t),h,e),!0),B.j,h,h,new A.ar(h,h,h,h,h,new A.fc(B.c8,B.bg,B.at,f,h,h),h,B.u),h,1/0,h,h,h,h,1/0),h)}}
A.aDA.prototype={
$1(a){A.en("✅ متصل بالسيرفر من شاشة اختيار الوضع")},
$S:3}
A.aDx.prototype={
$1(a){var s="FFHekaya",r=null,q=A.a6("حذف الحساب نهائياً",r,r,r,r,r,r,r,A.Z(r,r,B.ak,r,r,r,r,r,s,r,r,r,r,r,r,r,r,!0,r,r,r,r,r,r,r,r),r,r,r),p=A.a6("هل أنت متأكد؟ سيتم مسح جميع بياناتك وتقدمك بشكل نهائي ولا يمكن التراجع عن هذا الإجراء.",r,r,r,r,r,r,r,A.Z(r,r,r,r,r,r,r,r,s,r,r,$.c().L(20),r,r,r,r,r,!0,r,r,r,r,r,r,r,r),r,r,r),o=A.vQ(A.a6("إلغاء",r,r,r,r,r,r,r,A.Z(r,r,B.l,r,r,r,r,r,s,r,r,r,r,r,r,r,r,!0,r,r,r,r,r,r,r,r),r,r,r),new A.aDv(a),r),n=A.hZ(r,r,B.ak,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r,r)
return A.aX7(A.b([o,A.jg(A.a6("حذف",r,r,r,r,r,r,r,A.Z(r,r,B.h,r,r,r,r,r,s,r,r,r,r,r,r,r,r,!0,r,r,r,r,r,r,r,r),r,r,r),new A.aDw(a),n)],t.p),r,p,r,r,q)},
$S:262}
A.aDv.prototype={
$0(){A.cK(this.a,!1).hK(!1)
return null},
$S:0}
A.aDw.prototype={
$0(){A.cK(this.a,!1).hK(!0)
return null},
$S:0}
A.aDy.prototype={
$1(a){return B.dY},
$S:53}
A.aDz.prototype={
$1(a){return!1},
$S:30}
A.aDB.prototype={
$1(a){return B.dY},
$S:53}
A.aDC.prototype={
$1(a){return!1},
$S:30}
A.aDO.prototype={
$1(a){var s,r,q,p,o=null,n=$.c()
n=A.ay(20*Math.min(n.gq(),n.gp()))
s=$.c()
s=20*Math.min(s.gq(),s.gp())
r=A.i_(B.x,A.a6("أين تريد عرض اللعبة؟",o,o,o,o,o,o,o,A.Z(o,o,B.k,o,o,o,o,o,"FFHekaya",o,o,$.c().L(60),o,o,B.o,o,o,!0,o,o,o,o,o,o,o,o),B.N,o,o),B.j,B.b3)
q=this.b
p=this.a
return A.aX7(o,B.qd,A.aa(A.bZ(A.b([A.bP(new A.pX("على الهاتف مباشرة","إدارة ولعب من نفس الجهاز","assets/onphone.png",B.k,new A.aDM(p,a),o),1),A.aa(o,o,20*$.c().gq()),A.bP(new A.pX("اللعب عبر المتصفح","اعرض اللعبة على شاشة التلفاز أو اللابتوب","assets/onlaptop.png",B.k,new A.aDN(p,a),o),1)],t.p),B.p,B.ad,B.t,0,o),q.b*0.5,q.a*0.8),new A.S(s,s,s,s),new A.c2(n,B.y),r)},
$S:262}
A.aDM.prototype={
$0(){var s,r=this.b
A.cK(r,!1).hK(null)
s=A.hg(new A.aDL(this.a),null,t.z)
A.cK(r,!1).o_(s)},
$S:0}
A.aDL.prototype={
$1(a){var s=this.a.a
return new A.ke(s.c,s.d,null,null)},
$S:263}
A.aDN.prototype={
$0(){var s=this.b
A.cK(s,!1).hK(null)
this.a.awQ(s)},
$S:0}
A.aDJ.prototype={
$1(a){return new A.oI(new A.aDI(this.a,this.b,this.c,a),null)},
$S:140}
A.aDI.prototype={
$2(a,b){var s,r,q,p,o,n,m,l=this,k=null,j="pairing_code_generated",i="browser_connected",h=l.a
if(!h.b){h.b=!0
s=l.b
r=s.x
r===$&&A.a()
r.d0(j)
s.x.d0(i)
s.x.bD(j,new A.aDF(h,s,b))
s.x.bD(i,new A.aDG(h,s,b))
r=s.x
if(r.w){q=t.N
r.c7("request_browser_pairing",A.V(["userId",s.a.c],q,q))}else{r.z_()
A.k3(B.c_,new A.aDH(s),t.P)}}s=l.c
r=$.c()
r=A.ay(25*Math.min(r.gq(),r.gp()))
q=A.bo(B.I,3*$.c().gq())
p=$.c()
p=Math.min(p.gq(),p.gp())
p=A.b([new A.be(0,B.H,B.bu,new A.h(0,8*$.c().gp()),15*p)],t.V)
o=$.c()
o=20*Math.min(o.gq(),o.gp())
n=l.b
m=l.d
h=h.c?n.ahx(m):n.ahO(m,h.a)
return A.DA(k,B.B,A.DE(A.ag(k,h,B.j,k,k,new A.ar(B.Km,k,q,r,p,k,k,B.u),k,s.b*0.85,k,new A.S(o,o,o,o),k,k,s.a*0.9),B.T),k,k,k,k,B.hr,k,k,k)},
$S:633}
A.aDF.prototype={
$1(a){if(this.b.c!=null)this.c.$1(new A.aDE(this.a,a))},
$S:3}
A.aDE.prototype={
$0(){return this.a.a=J.b7(J.av(this.b,"code"))},
$S:0}
A.aDG.prototype={
$1(a){if(this.b.c!=null)this.c.$1(new A.aDD(this.a))},
$S:3}
A.aDD.prototype={
$0(){return this.a.c=!0},
$S:0}
A.aDH.prototype={
$0(){var s,r=this.a,q=r.x
q===$&&A.a()
s=t.N
q.c7("request_browser_pairing",A.V(["userId",r.a.c],s,s))},
$S:7}
A.aDK.prototype={
$1(a){var s=this.a,r=s.x
r===$&&A.a()
r.d0("pairing_code_generated")
s.x.d0("browser_connected")},
$S:3}
A.aDt.prototype={
$0(){var s,r=this.a,q=r.x
q===$&&A.a()
s=t.N
q.c7("kill_browser_session",A.V(["userId",r.a.c],s,s))
A.cK(this.b,!1).hK(null)},
$S:0}
A.aDu.prototype={
$3(a,b,c){var s=null
return A.ag(B.x,A.bL(B.fU,B.dk,s,$.c().L(50)),B.j,B.ig,s,s,s,s,s,s,s,s,s)},
$S:264}
A.aDs.prototype={
$0(){var s,r=this.a,q=r.x
q===$&&A.a()
s=t.N
q.c7("kill_browser_session",A.V(["userId",r.a.c],s,s))
A.cK(this.b,!1).hK(null)},
$S:0}
A.aDQ.prototype={
$0(){return this.a.awS(this.b)},
$S:0}
A.aDR.prototype={
$0(){var s=A.hg(new A.aDP(this.a),null,t.z)
A.cK(this.b,!1).o_(s)},
$S:0}
A.aDP.prototype={
$1(a){var s=this.a.a
return new A.lg(s.c,s.d,null,null)},
$S:635}
A.pX.prototype={
ao(){return new A.a1r()},
aJ5(){return this.r.$0()}}
A.a1r.prototype={
O(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=this,d=null,c="FFHekaya"
if(e.e)s=0.95
else s=e.d?1.05:1
r=$.c()
r=A.ay(30*Math.min(r.gq(),r.gp()))
q=A.bo(B.I,2*$.c().gq())
p=A.U(B.d.T(255*(e.d?0.3:0.15)),B.l.m()>>>16&255,B.l.m()>>>8&255,B.l.m()&255)
if(e.d){o=$.c()
o=20*Math.min(o.gq(),o.gp())}else{o=$.c()
o=10*Math.min(o.gq(),o.gp())}p=A.b([new A.be(0,B.H,p,new A.h(0,e.d?12*$.c().gp():6*$.c().gp()),o)],t.V)
o=$.c()
o=28*Math.min(o.gq(),o.gp())
o=A.m_(B.G,new A.aF(o,o))
n=$.c().gq()
n=A.bP(A.no(o,A.ag(d,A.nR(e.a.e,new A.aG8(e),B.bs,d,d),B.j,d,d,new A.ar(d,d,new A.eD(B.y,B.y,new A.aW(B.I,2*n,B.z,-1),B.y),d,d,d,d,B.u),d,d,d,d,d,d,1/0)),55)
o=10*$.c().gq()
m=8*$.c().gp()
l=$.c()
l=28*Math.min(l.gq(),l.gp())
l=A.m_(new A.aF(l,l),B.G)
k=e.a.c
j=$.c().L(70)
j=A.i_(B.x,A.a6(k,d,d,d,d,d,d,d,A.Z(d,d,e.a.f,d,d,d,d,d,c,d,d,j,d,d,B.o,d,d,!0,d,d,d,d,d,d,d,d),d,d,d),B.j,B.b3)
k=A.aa(d,4*$.c().gp(),d)
i=e.a.d
h=$.c().L(40)
g=e.a.f
f=t.p
return A.ld(A.fA(d,new A.Ci(A.ag(d,A.bf(A.b([n,A.bP(A.ag(d,A.bf(A.b([j,k,new A.jk(1,B.cX,A.a6(i,d,d,d,d,d,d,d,A.Z(d,d,A.U(204,g.m()>>>16&255,g.m()>>>8&255,g.m()&255),d,d,d,d,d,c,d,d,h,d,d,d,d,1.2,!0,d,d,d,d,d,d,d,d),B.N,d,d),d)],f),B.p,B.ad,B.t),B.j,d,d,new A.ar(B.h,d,d,l,d,d,d,B.u),d,d,d,new A.S(o,m,o,m),d,d,1/0),45)],f),B.p,B.r,B.t),B.j,d,d,new A.ar(B.qd,d,q,r,p,d,d,B.u),d,d,d,d,d,d,d),s,B.lb,B.aa,d,d),B.a8,!1,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,new A.aG9(e),new A.aGa(e),new A.aGb(e),d,d,d),B.ao,d,new A.aGc(e),new A.aGd(e),d)}}
A.aGc.prototype={
$1(a){var s=this.a
return s.P(new A.aG4(s))},
$S:66}
A.aG4.prototype={
$0(){return this.a.d=!0},
$S:0}
A.aGd.prototype={
$1(a){var s=this.a
return s.P(new A.aG3(s))},
$S:54}
A.aG3.prototype={
$0(){return this.a.d=!1},
$S:0}
A.aGa.prototype={
$1(a){var s=this.a
return s.P(new A.aG6(s))},
$S:36}
A.aG6.prototype={
$0(){return this.a.e=!0},
$S:0}
A.aGb.prototype={
$1(a){var s=this.a
s.P(new A.aG5(s))
s.a.aJ5()},
$S:77}
A.aG5.prototype={
$0(){return this.a.e=!1},
$S:0}
A.aG9.prototype={
$0(){var s=this.a
return s.P(new A.aG7(s))},
$S:0}
A.aG7.prototype={
$0(){return this.a.e=!1},
$S:0}
A.aG8.prototype={
$3(a,b,c){var s=null,r=$.c().L(60),q=this.a.a.f
return A.ag(s,A.bL(B.OU,A.U(B.d.T(127.5),q.m()>>>16&255,q.m()>>>8&255,q.m()&255),s,r),B.j,B.h,s,s,s,s,s,s,s,s,s)},
$S:264}
A.Oc.prototype={
l(){var s=this,r=s.ba$
if(r!=null)r.M(s.gfl())
s.ba$=null
s.aJ()},
bA(){this.ce()
this.c5()
this.fm()}}
A.nO.prototype={
gaQ(){return this.a}}
A.ke.prototype={
ao(){var s=t.s
return new A.Lt(new A.r4(B.f4,$.aT()),A.b([],t.ET),$.P6(),A.b(["assets/players/blue.png","assets/players/green.png","assets/players/pink.png","assets/players/purple.png","assets/players/red.png","assets/players/yellow.png"],s),A.b([B.ak,B.eK,B.bk,B.mz,B.yn,B.yo,B.yq,B.ym,B.my,B.yp],t.W),A.v(t.N,t.b5),A.b([],s))}}
A.Lt.prototype={
aD(){var s,r,q,p,o,n,m=this
m.aP()
s=m.r
m.w=s[0]
r=m.a.e
if(r!=null&&J.kL(r)){r=m.a.e
r.toString
r=J.bh(r)
q=m.x
p=m.e
o=0
while(r.B()){n=J.av(r.gN(),"name")
n=n==null?null:J.b7(n)
if(n==null)n="فريق"
p.push(new A.nO(n,q[B.f.bb(o,q.length)],s[B.f.bb(o,6)]));++o}}m.xR()
s=m.f
r=s.a
r===$&&A.a()
r.bD("local_game_started",new A.aHV(m))
s.a.bD("force_disconnect",new A.aHW(m))
s.a.bD("phone_disconnected",new A.aHX(m))},
xR(){var s=0,r=A.t(t.H),q=this
var $async$xR=A.o(function(a,b){if(a===1)return A.p(b,r)
for(;;)switch(s){case 0:s=2
return A.n(q.u1(),$async$xR)
case 2:s=3
return A.n(q.CG(),$async$xR)
case 3:if(q.c!=null&&!q.as)q.a0b()
return A.q(null,r)}})
return A.r($async$xR,r)},
CG(){var s=0,r=A.t(t.H),q=1,p=[],o=this,n,m,l,k,j,i
var $async$CG=A.o(function(a,b){if(a===1){p.push(b)
s=q}for(;;)switch(s){case 0:q=3
n=A.di(u.v,0,null)
s=6
return A.n(A.OL(n),$async$CG)
case 6:m=b
if(m.b===200){k=m
l=B.aS.v1(A.a8A(A.a8n(k.e)).e9(k.w),null)
if(o.c!=null)o.P(new A.aHp(o,l))}else if(o.c!=null)o.P(new A.aHq(o))
q=1
s=5
break
case 3:q=2
i=p.pop()
if(o.c!=null)o.P(new A.aHr(o))
s=5
break
case 2:s=1
break
case 5:return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$CG,r)},
l(){var s=this.f,r=s.a
r===$&&A.a()
r.d0("local_game_started")
s.a.d0("force_disconnect")
s.a.d0("phone_disconnected")
s=this.d
s.aj$=$.aT()
s.ag$=0
this.aJ()},
qC(){var s=0,r=A.t(t.H),q=1,p=[],o=this,n,m,l,k,j
var $async$qC=A.o(function(a,b){if(a===1){p.push(b)
s=q}for(;;)switch(s){case 0:q=3
s=6
return A.n(A.vE(),$async$qC)
case 6:n=b
s=7
return A.n(J.hX(n,"saved_userId"),$async$qC)
case 7:s=8
return A.n(J.hX(n,"saved_username"),$async$qC)
case 8:s=9
return A.n($.C1().n7(),$async$qC)
case 9:q=1
s=5
break
case 3:q=2
j=p.pop()
m=A.a7(j)
A.hW().$1("Logout error: "+A.j(m))
s=5
break
case 2:s=1
break
case 5:if(o.c!=null){k=o.f.a
k===$&&A.a()
k.Fa()
k=o.c
k.toString
A.cK(k,!1).kO(A.hg(new A.aHs(),null,t.z),new A.aHt())}return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$qC,r)},
u1(){var s=0,r=A.t(t.H),q=1,p=[],o=this,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3
var $async$u1=A.o(function(b4,b5){if(b4===1){p.push(b5)
s=q}for(;;)switch(s){case 0:q=3
n=A.di(u.I+o.a.c,0,null)
s=6
return A.n(A.OL(n),$async$u1)
case 6:m=b5
if(m.b===200){b=m
l=B.aS.v1(A.a8A(A.a8n(b.e)).e9(b.w),null)
a=J.av(l,"categories")
k=a==null?[]:a
a0=J.av(l,"isPremium")
j=a0==null?!1:a0
b=t.N
i=A.v(b,t.b5)
if(!j&&!o.as)J.j3(i,"الفئات المجانية",A.b([],t.H7))
for(a1=J.bh(k),a2=t.z,a3=t.H7;a1.B();){h=a1.gN()
a4=J.av(h,"collection")
a5=a4==null?null:J.b7(a4)
g=a5==null?"فئات عامة":a5
a4=J.av(h,"title")
a4=a4==null?null:J.b7(a4)
if(a4==null){a4=J.av(h,"category")
a4=a4==null?null:J.b7(a4)
a6=a4}else a6=a4
f=a6==null?"بدون عنوان":a6
a4=J.av(h,"status")
a7=a4==null?null:J.b7(a4).toLowerCase()
e=a7==null?"paid":a7
a4=J.av(h,"url")
a8=J.av(h,"version")
a9=J.av(h,"percent")
a9=J.C8(a9==null?0:a9)
b0=J.av(h,"remainingPercent")
b0=J.C8(b0==null?1:b0)
b1=J.av(h,"isCompleted")
if(b1==null)b1=!1
d=A.V(["title",f,"url",a4,"version",a8,"percent",a9,"remainingPercent",b0,"isCompleted",b1,"status",e],b,a2)
if(!i.ad(g))J.j3(i,g,A.b([],a3))
J.av(i,g).push(d)
if(!j&&!o.as&&!J.d(e,"paid"))J.av(i,"الفئات المجانية").push(d)}if(!j&&!o.as&&J.av(i,"الفئات المجانية")!=null&&J.av(i,"الفئات المجانية").length===0)J.hX(i,"الفئات المجانية")
o.P(new A.aHm(o,i,j))}else{A.en("Failed to load: "+m.b)
o.P(new A.aHn(o))}q=1
s=5
break
case 3:q=2
b3=p.pop()
c=A.a7(b3)
A.en("Error fetching categories: "+A.j(c))
o.P(new A.aHo(o))
s=5
break
case 2:s=1
break
case 5:return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$u1,r)},
a0b(){var s=this.c
s.toString
A.BY(!0,new A.aHH(this),s,t.z)},
awT(){var s=this.c
s.toString
A.BY(!1,new A.aHK(),s,t.z)},
KW(a,b){var s=null,r=this.c.av(t.J).f,q=A.a6(a,s,s,s,s,s,s,s,A.Z(s,s,s,s,s,s,s,s,"FFHekaya",s,s,$.c().L(20),s,s,s,s,s,!0,s,s,s,s,s,s,s,s),B.c4,s,s)
r.io(A.iP(s,s,s,b?B.bk:B.cD,B.hy,B.D,s,q,s,B.bZ,s,s,s,s,s,s,s,s,s,s))},
are(a){return this.KW(a,!0)},
BX(a){var s,r=null,q=$.c().gp(),p=$.c()
p=4*Math.min(p.gq(),p.gp())
s=A.U(51,B.aq.m()>>>16&255,B.aq.m()>>>8&255,B.aq.m()&255)
return new A.bi(new A.S(0,0,0,12*q),A.bZ(A.b([A.ag(r,A.bL(B.rq,B.aq,r,$.c().L(20)),B.j,r,r,new A.ar(s,r,r,r,r,r,r,B.ae),r,r,r,new A.S(p,p,p,p),r,r,r),A.aa(r,r,10*$.c().gq()),A.bP(new A.bi(new A.S(0,2*$.c().gp(),0,0),A.a6(a,r,r,r,r,r,r,r,A.Z(r,r,B.k,r,r,r,r,r,"FFHekaya",r,r,$.c().L(35),r,r,B.o,r,r,!0,r,r,r,r,r,r,r,r),r,r,r),r),1)],t.p),B.an,B.r,B.t,0,r),r)},
axJ(a){this.P(new A.aHM(this,a))},
Uw(){var s,r,q,p,o=this,n=o.e
if(n.length>=2){o.Dp("الحد الأقصى المسموح به هو فريقين فقط")
return}s=o.d
if(B.c.d1(s.a.a).length===0){o.Dp("اكتب اسم الفريق")
return}r=o.x
q=A.a2(r).i("b4<1>")
p=A.a0(new A.b4(r,new A.aHf(new A.a4(n,new A.aHg(),A.a2(n).i("a4<1,w>")).hN(0)),q),q.i("E.E"))
r=p.length===0?r:p
B.b.T1(r)
o.P(new A.aHh(o,new A.nO(B.c.d1(s.a.a),B.b.gY(r),o.w)))},
avi(a){this.P(new A.aHu(this,a))},
axf(){var s,r,q,p=this,o=p.e
if(o.length<2){p.Dp("يرجى إضافة فريقين على الأقل")
return}s=p.z
if(s.length!==6){p.Dp("يرجى اختيار 6 فئات بالضبط لبدء اللعبة")
return}r=A.a2(o).i("a4<1,i>")
q=A.a0(new A.a4(o,new A.aHL(),r),r.i("ao.E"))
o=A.V(["teams",q,"categories",s,"userId",p.a.c],t.N,t.K)
s=p.f.a
s===$&&A.a()
s.c7("create_local_game",o)},
Dp(a){var s=null
this.c.av(t.J).f.io(A.iP(s,s,s,B.cD,B.hy,B.D,s,A.a6(a,s,s,s,s,s,s,s,A.Z(s,s,s,s,s,s,s,s,"FFHekaya",s,s,$.c().L(20),s,s,s,s,s,!0,s,s,s,s,s,s,s,s),B.c4,s,s),s,B.bZ,s,s,s,s,s,s,s,s,s,s))},
ahu(a9){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3=null,a4="FFHekaya",a5=a9.h(0,"title"),a6=a9.h(0,"url"),a7=a9.h(0,"version"),a8=a7==null?a3:J.b7(a7)
if(a8==null)a8="1"
a7=a9.h(0,"status")
s=a7==null?a3:J.b7(a7).toLowerCase()
r=(s==null?"paid":s)==="paid"&&!this.as
q=(B.c.b7(a6,"http")?a6:"https://api.3krooot.com"+a6)+"?v="+a8
a7=a9.h(0,"percent")
p=J.C8(a7==null?0:a7)
o=a9.h(0,"isCompleted")
if(o==null)o=!1
n=B.b.D(this.z,a5)
a7=$.c()
a7=A.ay(15*Math.min(a7.gq(),a7.gp()))
if(n)m=B.bk
else m=r?B.bE:B.B
m=A.bo(m,n||r?3*$.c().gq():0)
l=A.U(B.d.T(25.5),B.l.m()>>>16&255,B.l.m()>>>8&255,B.l.m()&255)
k=$.c()
k=Math.min(k.gq(),k.gp())
k=A.b([new A.be(0,B.H,l,new A.h(0,3*$.c().gp()),5*k)],t.V)
l=$.c()
l=14*Math.min(l.gq(),l.gp())
l=A.m_(B.G,new A.aF(l,l))
j=t.p
i=A.b([A.aaY(B.x,q,new A.aHi(),B.bs,q,a3,new A.aHj(),a3)],j)
if(r){h=B.d.T(127.5)
g=A.U(h,B.em.m()>>>16&255,B.em.m()>>>8&255,B.em.m()&255)
f=$.c().gp()
e=$.c().gq()
d=A.bL(B.rn,B.a5,a3,$.c().L(20))
c=$.c().L(32)
b=$.c()
b=Math.min(b.gq(),b.gp())
b=A.a6("متاحة للنسخة الكاملة فقط",a3,a3,a3,a3,a3,a3,a3,A.Z(a3,a3,B.h,a3,a3,a3,a3,a3,a4,a3,a3,c,a3,a3,B.o,a3,1.2,!0,a3,a3,a3,a3,a3,A.b([new A.fh(B.l,new A.h(0,2*$.c().gp()),5*b)],t.kO),a3,a3),B.N,a3,a3)
c=A.aa(a3,10*$.c().gp(),a3)
a=10*$.c().gq()
a0=6*$.c().gp()
a1=A.U(217,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
a2=$.c()
a2=A.ay(8*Math.min(a2.gq(),a2.gp()))
h=A.bo(A.U(h,B.S.m()>>>16&255,B.S.m()>>>8&255,B.S.m()&255),$.c().gq())
i.push(A.ag(a3,A.cc(A.bf(A.b([new A.e_(B.kp,a3,a3,new A.bi(new A.S(0,5*f,5*e,0),d,a3),a3),new A.mM(a3),b,c,A.ag(a3,A.bZ(A.b([A.bL(B.ru,B.S,a3,$.c().L(18)),A.aa(a3,a3,5*$.c().gq()),A.a6("اضغط للشراء",a3,a3,a3,a3,a3,a3,a3,A.Z(a3,a3,B.h,a3,a3,a3,a3,a3,a4,a3,a3,$.c().L(20),a3,a3,a3,a3,a3,!0,a3,a3,a3,a3,a3,a3,a3,a3),a3,a3,a3)],j),B.p,B.r,B.Z,0,a3),B.j,a3,a3,new A.ar(a1,a3,h,a2,a3,a3,a3,B.u),a3,a3,a3,new A.S(a,a0,a,a0),a3,a3,a3),new A.mM(a3)],j),B.p,B.ad,B.t),a3,a3),B.j,g,a3,a3,a3,a3,a3,a3,a3,a3,a3))}if(p>0&&!o&&!r){h=$.c().gp()
i.push(A.eu(0,A.aZG(B.cd,p,B.ou),12*h,a3,0,0,a3,a3))}l=A.bP(A.no(l,A.ag(a3,A.cU(B.aQ,i,B.D,B.jN),B.j,B.cs,a3,a3,a3,a3,a3,a3,a3,a3,1/0)),3)
i=6*$.c().gp()
h=n?B.bk:B.k
g=$.c()
g=12*Math.min(g.gq(),g.gp())
g=A.m_(new A.aF(g,g),B.G)
j=A.b([A.bf(A.b([l,A.ag(a3,A.a6(a5,a3,a3,1,a3,a3,a3,a3,A.Z(a3,a3,B.h,a3,a3,a3,a3,a3,a4,a3,a3,$.c().L(35),a3,a3,B.o,a3,a3,!0,a3,a3,a3,a3,a3,a3,a3,a3),B.N,a3,a3),B.j,a3,a3,new A.ar(h,a3,a3,g,a3,a3,a3,B.u),a3,a3,a3,new A.S(0,i,0,i),a3,a3,1/0)],j),B.p,B.r,B.t)],j)
if(n&&!r){l=$.c().gp()
i=$.c().gq()
h=$.c()
h=Math.min(h.gq(),h.gp())
j.push(A.eu(a3,A.xg(B.bk,a3,A.bL(B.rl,B.h,a3,$.c().L(16)),12*h),a3,a3,a3,5*i,5*l,a3))}return A.l7(!1,a3,!0,A.kN(A.cU(B.aQ,j,B.D,B.ag),a3,B.O,new A.ar(B.h,a3,m,a7,k,a3,a3,B.u),B.aa,a3,a3,a3,a3,a3),a3,!0,a3,a3,a3,a3,a3,a3,a3,new A.aHk(this,r,a5),a3,a3,a3,a3,a3,a3,a3)},
ahQ(a,b){var s,r,q,p,o,n,m,l,k=null,j=$.c().gq(),i=5*$.c().gq(),h=5*$.c().gp(),g=$.c()
g=A.ay(15*Math.min(g.gq(),g.gp()))
s=a.b
r=A.bo(s.by(0.5),3*$.c().gq())
s=s.by(0.1)
q=$.c()
q=Math.min(q.gq(),q.gp())
q=A.b([new A.be(0,B.H,s,new A.h(0,3*$.c().gp()),4*q)],t.V)
s=$.c()
s=10*Math.min(s.gq(),s.gp())
p=$.c()
p=Math.min(p.gq(),p.gp())
o=$.c()
o=Math.min(o.gq(),o.gp())
n=A.bo(B.fC,1)
m=t.p
p=A.bf(A.b([A.ag(k,k,B.j,k,k,new A.ar(k,A.aY4(B.kB,new A.kP(a.c,k,k),k),n,k,k,k,k,B.ae),k,90*o,k,k,k,k,90*p),A.aa(k,$.c().gp(),k),A.a6(a.a,k,k,1,B.aG,k,k,k,A.Z(k,k,B.k,k,k,k,k,k,"FFHekaya",k,k,$.c().L(38),k,k,B.o,k,k,!0,k,k,k,k,k,k,k,k),B.N,k,k)],m),B.p,B.r,B.Z)
o=$.c().gp()
n=$.c().gq()
l=$.c()
l=4*Math.min(l.gq(),l.gp())
return A.ag(k,A.cU(B.x,A.b([new A.bi(new A.S(s,s,s,s),p,k),A.eu(k,A.l7(!1,k,!0,A.ag(k,A.bL(B.rm,B.ak,k,$.c().L(14)),B.j,k,k,new A.ar(B.kX,k,k,k,k,k,k,B.ae),k,k,k,new A.S(l,l,l,l),k,k,k),k,!0,k,k,k,k,k,k,k,new A.aHl(this,b),k,k,k,k,k,k,k),k,k,k,2*n,2*o,k)],m),B.D,B.ag),B.j,k,k,new A.ar(B.h,k,r,g,q,k,k,B.u),k,k,new A.S(i,h,i,h),k,k,k,200*j)},
O(c4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4=this,b5=null,b6="FFHekaya",b7=4294963659,b8=b4.e,b9=b8.length>=2,c0=b4.z,c1=c0.length,c2=c1===6,c3=6-c1
if(!b9){s="أضف فريقين على الأقل للبدء"
r=B.mx}else if(!c2){s=c3===6?"اختر المواضيع (6 فئات)":"متبقي "+c3+" فئات"
r=B.h}else{s="كل شيء جاهز! ابدأ التحدي"
r=B.j9}q=b9&&c2
c1=A.b([B.bF,B.ap],t.W)
p=$.c().gq()
o=$.c().gp()
n=$.c().gq()
m=$.c().gp()
l=$.c().gq()
k=t.p
j=A.cU(B.x,A.b([new A.e_(B.x,b5,b5,A.a6("إعداد الجلسة",b5,b5,b5,b5,b5,b5,b5,A.Z(b5,b5,B.k,b5,b5,b5,b5,b5,b6,b5,b5,$.c().L(40),b5,b5,B.o,b5,b5,!0,b5,b5,b5,b5,b5,b5,b5,b5),b5,b5,b5),b5),new A.e_(B.ee,b5,b5,A.ahP(b5,b5,A.bL(B.m7,B.ak,b5,$.c().L(40)),b5,b5,b4.garj(),b5,b5,b5),b5)],k),B.D,B.ag)
i=A.aa(b5,30*$.c().gp(),b5)
h=A.U(51,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
g=$.c()
g=A.ay(20*Math.min(g.gq(),g.gp()))
f=B.d.T(25.5)
e=A.U(f,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
d=A.aJ(b7)
c=$.c()
c=20*Math.min(c.gq(),c.gp())
b=A.a6("الفرق المتنافسة",b5,b5,b5,b5,b5,b5,b5,A.Z(b5,b5,B.k,b5,b5,b5,b5,b5,b6,b5,b5,$.c().L(60),b5,b5,B.o,b5,b5,!0,b5,b5,b5,b5,b5,b5,b5,b5),B.N,b5,b5)
a=A.aa(b5,10*$.c().gp(),b5)
a0=$.c().gp()
a1=$.c().gp()
a1=A.ag(b5,A.TY(new A.aHQ(b4),6,b5,!0,B.aI,!1),B.j,b5,b5,b5,b5,70*a0,new A.S(0,0,0,10*a1),b5,b5,b5,b5)
a0=A.Z(b5,b5,B.k,b5,b5,b5,b5,b5,b6,b5,b5,$.c().L(35),b5,b5,b5,b5,b5,!0,b5,b5,b5,b5,b5,b5,b5,b5)
a2=A.Z(b5,b5,B.dk,b5,b5,b5,b5,b5,b6,b5,b5,$.c().L(35),b5,b5,b5,b5,b5,!0,b5,b5,b5,b5,b5,b5,b5,b5)
a3=20*$.c().gq()
a4=15*$.c().gp()
a5=$.c()
a5=A.ay(15*Math.min(a5.gq(),a5.gp()))
a6=$.c()
a6=A.ay(15*Math.min(a6.gq(),a6.gp()))
a7=$.c().gq()
a8=$.c()
a8=A.ay(15*Math.min(a8.gq(),a8.gp()))
a9=B.d.T(127.5)
a2=A.ua(b5,new A.e2(4,a5,new A.aW(B.k,1,B.z,-1)),b5,new A.S(a3,a4,a3,a4),b5,b5,b5,b5,!0,new A.e2(4,a8,new A.aW(A.U(a9,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255),1,B.z,-1)),b5,b5,b5,b5,b5,A.U(B.d.T(229.5),B.h.m()>>>16&255,B.h.m()>>>8&255,B.h.m()&255),!0,b5,b5,b5,b5,new A.e2(4,a6,new A.aW(B.k,2*a7,B.z,-1)),b5,b5,b5,b5,b5,b5,b5,b5,a2,"اسم الفريق...",b5,b5,b5,b5,b5,b5,b5,b5,b5,!0,!0,!1,b5,b5,b5,b5,b5,b5,b5,b5,b5,b5,b5,b5,b5,b5)
a7=$.c()
a7=8*Math.min(a7.gq(),a7.gp())
a0=A.bP(A.Ym(b4.d,a2.aC6(new A.bi(new A.S(a7,a7,a7,a7),A.xg(b5,new A.kP(b4.w,b5,b5),b5,b5),b5)),b5,b5,new A.aHR(b4),a0,B.c4),1)
a7=A.aa(b5,b5,10*$.c().gq())
a2=$.c().gq()
a6=$.c().gp()
a8=$.c()
a8=A.hZ(b5,b5,B.k,b5,b5,b5,5,b5,b5,new A.J(55*a2,55*a6),b5,b5,b5,b5,b5,new A.c2(A.ay(15*Math.min(a8.gq(),a8.gp())),B.y),b5,b5,b5,b5,b5)
a8=A.bZ(A.b([a0,a7,A.jg(A.bL(B.rj,B.h,b5,$.c().L(24)),b4.gagY(),a8)],k),B.p,B.r,B.t,0,b5)
a7=A.aa(b5,15*$.c().gp(),b5)
a0=$.c().gp()
a6=$.c()
a6=10*Math.min(a6.gq(),a6.gp())
a2=A.U(a9,B.h.m()>>>16&255,B.h.m()>>>8&255,B.h.m()&255)
a4=$.c()
a4=A.ay(15*Math.min(a4.gq(),a4.gp()))
a3=A.bo(A.U(f,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255),1)
if(b8.length===0){b8=$.c().L(35)
b8=A.cc(A.a6("القائمة فارغة.. أضف الفرق!",b5,b5,b5,b5,b5,b5,b5,A.Z(b5,b5,A.U(a9,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255),b5,b5,b5,b5,b5,b6,b5,b5,b8,b5,b5,b5,b5,b5,!0,b5,b5,b5,b5,b5,b5,b5,b5),b5,b5,b5),b5,b5)}else{a5=$.c().gq()
b0=$.c().gp()
b1=b8.length
b2=J.aiE(b1,t.l7)
for(b3=0;b3<b1;++b3)b2[b3]=b4.ahQ(b8[b3],b3)
b8=A.JU(B.k0,b2,10*b0,10*a5)}e=A.CQ(new A.bi(new A.S(c,c,c,c),A.bf(A.b([b,a,a1,a8,a7,A.ag(b5,b8,B.j,b5,new A.al(0,1/0,100*a0,1/0),new A.ar(a2,b5,a3,a4,b5,b5,b5,B.u),b5,b5,b5,new A.S(a6,a6,a6,a6),b5,b5,1/0)],k),B.ce,B.r,B.t),b5),d,8,h,new A.c2(g,new A.aW(e,1,B.z,-1)))
g=A.aa(b5,25*$.c().gp(),b5)
h=A.U(51,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
d=$.c()
d=A.ay(20*Math.min(d.gq(),d.gp()))
f=A.U(f,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
a6=A.aJ(b7)
a4=$.c()
a4=20*Math.min(a4.gq(),a4.gp())
a3=A.b([new A.e_(B.c8,b5,b5,A.a6("فئات اللعبة",b5,b5,b5,b5,b5,b5,b5,A.Z(b5,b5,B.k,b5,b5,b5,b5,b5,b6,b5,b5,$.c().L(60),b5,b5,B.o,b5,b5,!0,b5,b5,b5,b5,b5,b5,b5,b5),b5,b5,b5),b5),A.aa(b5,20*$.c().gp(),b5)],k)
if(b4.Q){b8=$.c()
b8=30*Math.min(b8.gq(),b8.gp())
a3.push(new A.bi(new A.S(b8,b8,b8,b8),A.Qw(B.k,b5,b5),b5))}else{b8=b4.y.a
if(b8===0){b8=$.c()
b8=30*Math.min(b8.gq(),b8.gp())
a3.push(new A.bi(new A.S(b8,b8,b8,b8),A.a6("لا توجد فئات متاحة!",b5,b5,b5,b5,b5,b5,b5,A.Z(b5,b5,B.ak,b5,b5,b5,b5,b5,b6,b5,b5,$.c().L(24),b5,b5,b5,b5,b5,!0,b5,b5,b5,b5,b5,b5,b5,b5),b5,b5,b5),b5))}else a3.push(A.TY(new A.aHS(b4),b8,new A.yS(b5),!1,B.ai,!0))}b8=A.qz(0,A.zL(new A.fU(new A.al(0,1200*l,0,1/0),A.cc(A.bf(A.b([j,i,e,g,A.CQ(new A.bi(new A.S(a4,a4,a4,a4),A.bf(a3,B.p,B.r,B.t),b5),a6,8,h,new A.c2(d,new A.aW(f,1,B.z,-1)))],k),B.p,B.r,B.Z),b5,b5),b5),B.D,new A.S(20*p,20*o,20*n,160*m),b5,!1,B.ai))
p=$.c().gq()
o=$.c().gq()
n=$.c()
m=n.d
m===$&&A.a()
n=n.gp()
l=20*$.c().gq()
j=15*$.c().gp()
i=A.aJ(4284295430)
h=$.c()
h=A.ay(25*Math.min(h.gq(),h.gp()))
g=A.bo(A.aJ(4292519200),2*$.c().gq())
a9=A.U(a9,B.l.m()>>>16&255,B.l.m()>>>8&255,B.l.m()&255)
f=$.c()
f=Math.min(f.gq(),f.gp())
f=A.b([new A.be(0,B.H,a9,new A.h(0,5*$.c().gp()),20*f)],t.V)
a9=A.cT(0,300,0)
a9=A.a9C(A.a6(s,new A.e7(s,t.kK),b5,b5,b5,b5,b5,b5,A.Z(b5,b5,r,b5,b5,b5,b5,b5,b6,b5,b5,$.c().L(50),b5,b5,B.o,b5,b5,!0,b5,b5,b5,b5,b5,b5,b5,b5),B.N,b5,b5),a9,A.aQt(),B.O,A.aQu())
e=A.aa(b5,12*$.c().gp(),b5)
d=A.awm(b5,b5,b5,b5,b5,b5,b5,b5,b5,B.fG,b5,b5,b5,b5,b5,b5,b5,b5,b5,b5)
d=A.vQ(A.a6("عودة",b5,b5,b5,b5,b5,b5,b5,A.Z(b5,b5,b5,b5,b5,b5,b5,b5,b6,b5,b5,$.c().L(40),b5,b5,b5,b5,b5,!0,b5,b5,b5,b5,b5,b5,b5,b5),b5,b5,b5),new A.aHT(c4),d)
c=15*$.c().gq()
b=5*$.c().gp()
a=A.U(B.d.T(76.5),B.l.m()>>>16&255,B.l.m()>>>8&255,B.l.m()&255)
a0=$.c()
a0=A.ay(20*Math.min(a0.gq(),a0.gp()))
b=A.ag(b5,A.a6(""+c0.length+" / 6",b5,b5,b5,b5,b5,b5,b5,A.Z(b5,b5,B.h,b5,b5,b5,b5,b5,b6,b5,b5,$.c().L(28),b5,b5,B.o,b5,b5,!0,b5,b5,b5,b5,b5,b5,b5,b5),b5,b5,b5),B.j,b5,b5,new A.ar(a,b5,b5,a0,b5,b5,b5,B.u),b5,b5,b5,new A.S(c,b,c,b),b5,b5,b5)
c0=q?b4.gaxe():b5
c=q?A.aJ(4283215696):B.bD
a=25*$.c().gq()
a0=10*$.c().gp()
a1=$.c()
a1=A.ay(15*Math.min(a1.gq(),a1.gp()))
a2=q?5:0
a1=A.hZ(b5,b5,c,B.ct,b5,b5,a2,b5,b5,b5,b5,b5,b5,new A.S(a,a0,a,a0),b5,new A.c2(a1,B.y),b5,b5,b5,b5,b5)
c=q?B.h:B.q3
return A.zt(b5,A.ag(b5,A.qP(!0,A.cU(B.aQ,A.b([b8,new A.e_(B.bg,b5,b5,new A.fU(new A.al(320*o,600*p,0,1/0),A.ag(b5,A.bf(A.b([a9,e,A.bZ(A.b([d,b,A.jg(A.a6("ابدأ التحدي",b5,b5,b5,b5,b5,b5,b5,A.Z(b5,b5,c,b5,b5,b5,b5,b5,b6,b5,b5,$.c().L(40),b5,b5,B.o,b5,b5,!0,b5,b5,b5,b5,b5,b5,b5,b5),b5,b5,b5),c0,a1)],k),B.p,B.eI,B.t,0,b5)],k),B.p,B.r,B.Z),B.j,b5,b5,new A.ar(i,b5,g,h,f,b5,b5,B.u),b5,b5,new A.S(0,0,0,25*n),new A.S(l,j,l,j),b5,b5,m.a.a*0.85),b5),b5)],k),B.D,B.ag),!0),B.j,b5,b5,new A.ar(b5,b5,b5,b5,b5,new A.fc(B.c8,B.bg,B.at,c1,b5,b5),b5,B.u),b5,b5,b5,b5,b5,b5,b5),!0)}}
A.aHV.prototype={
$1(a){var s,r,q=this.a
if(q.c!=null){s=J.av(a,"roomCode")
r=q.c
r.toString
A.aTP(r,A.hg(new A.aHU(q,s),null,t.z))}},
$S:3}
A.aHU.prototype={
$1(a){var s=null,r=this.a.a
return A.aYR(s,s,s,s,s,!0,!1,!0,this.b,r.c,r.d)},
$S:265}
A.aHW.prototype={
$1(a){var s,r=null,q=this.a.c
if(q!=null){q=q.av(t.J).f
s=J.av(a,"message")
q.io(A.iP(r,r,r,B.ak,r,B.D,r,A.a6(s==null?"تم إنهاء الجلسة من قبل المضيف":s,r,r,r,r,r,r,r,r,r,r,r),r,B.bZ,r,r,r,r,r,r,r,r,r,r))}},
$S:3}
A.aHX.prototype={
$1(a){var s,r=null,q=this.a.c
if(q!=null){q=q.av(t.J).f
s=J.av(a,"message")
q.io(A.iP(r,r,r,B.ak,r,B.D,r,A.a6(s==null?"انقطع الاتصال بالهاتف المضيف":s,r,r,r,r,r,r,r,r,r,r,r),r,B.bZ,r,r,r,r,r,r,r,r,r,r))}},
$S:3}
A.aHp.prototype={
$0(){var s=this.a,r=this.b,q=J.aw(r),p=q.h(r,"hasDiscount")
s.at=p==null?!1:p
p=q.h(r,"originalPrice")
p=p==null?null:J.b7(p)
s.ax=p==null?"":p
p=q.h(r,"currentPrice")
p=p==null?null:J.b7(p)
s.ay=p==null?"4.99":p
r=q.h(r,"currency")
r=r==null?null:J.b7(r)
s.ch=r==null?"$":r
s.CW=!1},
$S:0}
A.aHq.prototype={
$0(){var s=this.a
s.ay="4.99"
s.ch="$"
s.CW=s.at=!1},
$S:0}
A.aHr.prototype={
$0(){var s=this.a
s.ay="4.99"
s.ch="$"
s.CW=s.at=!1},
$S:0}
A.aHs.prototype={
$1(a){return B.dY},
$S:53}
A.aHt.prototype={
$1(a){return!1},
$S:30}
A.aHm.prototype={
$0(){var s=this.a
s.y=this.b
s.as=s.as||this.c
s.Q=!1},
$S:0}
A.aHn.prototype={
$0(){return this.a.Q=!1},
$S:0}
A.aHo.prototype={
$0(){return this.a.Q=!1},
$S:0}
A.aHH.prototype={
$1(a){return new A.oI(new A.aHG(this.a),null)},
$S:140}
A.aHG.prototype={
$2(a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=null,c="FFHekaya",b=150*$.c().gq(),a=20*$.c().gp(),a0=$.c().gp(),a1=$.c().gq(),a2=$.c().gp(),a3=$.c().gq(),a4=$.c().gp(),a5=$.c()
a5=A.ay(30*Math.min(a5.gq(),a5.gp()))
s=A.bo(A.U(204,B.S.m()>>>16&255,B.S.m()>>>8&255,B.S.m()&255),3*$.c().gq())
r=A.U(102,B.l.m()>>>16&255,B.l.m()>>>8&255,B.l.m()&255)
q=$.c()
q=Math.min(q.gq(),q.gp())
p=t.V
q=A.b([new A.be(0,B.H,r,new A.h(0,10*$.c().gp()),20*q)],p)
r=A.a6("النسخة الكاملة",d,d,d,d,d,d,d,A.Z(d,d,B.k,d,d,d,d,d,c,d,d,$.c().L(85),d,d,B.o,d,d,!0,d,d,d,d,d,d,d,d),d,d,d)
o=A.aa(d,5*$.c().gp(),d)
n=A.a6(u.y,d,d,d,d,d,d,d,A.Z(d,d,B.bD,d,d,d,d,d,c,d,d,$.c().L(38),d,d,d,d,1.3,!0,d,d,d,d,d,d,d,d),d,d,d)
m=A.aa(d,20*$.c().gp(),d)
l=$.c()
l=15*Math.min(l.gq(),l.gp())
k=A.U(13,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
j=$.c()
j=A.ay(20*Math.min(j.gq(),j.gp()))
i=A.bo(A.U(B.d.T(25.5),B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255),1)
h=this.a
g=t.p
l=A.bP(A.bf(A.b([r,o,n,m,A.ag(d,A.bf(A.b([h.BX(u.W),h.BX("تويستات بلا حدود لزيادة الحماس والمقالب."),h.BX("تجربة لعب صافية بدون إعلانات مزعجة."),h.BX("دفع لمرة واحدة وامتلاك مدى الحياة.")],g),B.an,B.r,B.t),B.j,d,d,new A.ar(k,d,i,j,d,d,d,B.u),d,d,d,new A.S(l,l,l,l),d,d,d)],g),B.an,B.r,B.Z),3)
j=A.aa(d,d,40*$.c().gq())
i=$.c()
i=25*Math.min(i.gq(),i.gp())
k=$.c()
k=A.ay(25*Math.min(k.gq(),k.gp()))
m=A.bo(A.U(B.d.T(127.5),B.S.m()>>>16&255,B.S.m()>>>8&255,B.S.m()&255),2*$.c().gq())
n=$.c()
n=Math.min(n.gq(),n.gp())
n=A.b([new A.be(0,B.H,B.cd,new A.h(0,5*$.c().gp()),10*n)],p)
o=A.b([],g)
if(h.at)o.push(A.a6(h.ax+" "+h.ch,d,d,d,d,d,d,d,A.Z(d,d,B.fG,d,B.jQ,B.l3,d,2,c,d,d,$.c().L(55),d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d))
r=h.ay
f=h.ch
e=h.at?$.c().L(80):$.c().L(85)
o.push(A.a6(r+" "+f,d,d,d,d,d,d,d,A.Z(d,d,h.at?B.S:B.k,d,d,d,d,d,c,d,d,e,d,d,B.o,d,1.1,!0,d,d,d,d,d,d,d,d),d,d,d))
o.push(A.aa(d,25*$.c().gp(),d))
r=$.c().gp()
f=h.CW?d:new A.aHD(h,a7,a6)
e=$.c()
e=A.hZ(d,d,B.aq,B.dh,d,d,8,d,d,d,d,d,d,d,d,new A.c2(A.ay(20*Math.min(e.gq(),e.gp())),B.y),d,d,d,d,d)
o.push(A.aa(A.jg(h.CW?B.pu:A.bZ(A.b([A.a6("اشتري الآن",d,d,d,d,d,d,d,A.Z(d,d,B.h,d,d,d,d,d,c,d,d,$.c().L(75),d,d,B.o,d,d,!0,d,d,d,d,d,d,d,d),d,d,d)],g),B.p,B.ad,B.t,0,d),f,e),95*r,1/0))
o.push(A.aa(d,15*$.c().gp(),d))
o.push(A.vQ(A.a6("لاحقاً",d,d,d,d,d,d,d,A.Z(d,d,B.ij,d,B.dt,d,d,d,c,d,d,$.c().L(26),d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d),new A.aHE(a6),d))
r=A.b([A.ag(d,A.bf(o,B.p,B.r,B.Z),B.j,d,d,new A.ar(B.h,d,m,k,n,d,d,B.u),d,d,d,new A.S(i,i,i,i),d,d,d)],g)
if(h.at&&!h.CW){o=$.c().gp()
n=$.c().gq()
m=15*$.c().gq()
k=8*$.c().gp()
i=$.c()
i=A.ay(10*Math.min(i.gq(),i.gp()))
f=$.c()
f=Math.min(f.gq(),f.gp())
f=A.b([new A.be(0,B.H,B.bu,new A.h(2*$.c().gq(),2*$.c().gp()),4*f)],p)
r.push(A.eu(d,A.YC(0.2,A.ag(d,A.a6("عرض خاص!",d,d,d,d,d,d,d,A.Z(d,d,B.h,d,d,d,d,d,c,d,d,$.c().L(22),d,d,B.o,d,d,!0,d,d,d,d,d,d,d,d),d,d,d),B.j,d,d,new A.ar(d,d,d,i,f,B.rU,d,B.u),d,d,d,new A.S(m,k,m,k),d,d,d)),d,d,d,-(15*n),-(15*o),d))}a0=A.ag(d,A.bZ(A.b([l,j,A.bP(A.cU(B.aQ,r,B.j,B.ag),2)],g),B.p,B.r,B.t,0,d),B.j,d,d,new A.ar(d,d,s,a5,q,B.rW,d,B.u),d,d,new A.S(0,30*a0,0,0),new A.S(30*a1,30*a2,30*a3,30*a4),d,d,d)
a1=$.c()
a1=18*Math.min(a1.gq(),a1.gp())
a2=A.bo(B.h,4*$.c().gq())
a3=A.U(153,B.S.m()>>>16&255,B.S.m()>>>8&255,B.S.m()&255)
a4=$.c()
a4=Math.min(a4.gq(),a4.gp())
p=A.b([new A.be(0,B.H,a3,new A.h(0,5*$.c().gp()),15*a4)],p)
a1=A.eu(d,A.ag(d,A.bL(B.m8,B.h,d,$.c().L(60)),B.j,d,d,new A.ar(d,d,a2,d,p,B.rV,d,B.ae),d,d,d,new A.S(a1,a1,a1,a1),d,d,d),d,d,d,d,0,d)
p=$.c().gp()
a2=$.c().gq()
return A.DE(A.DA(d,B.B,A.cU(B.c8,A.b([a0,a1,A.eu(15*p,A.b0o(A.bL(B.rt,B.bE,d,$.c().L(24)),A.a6("",d,d,d,d,d,d,d,A.Z(d,d,B.bE,d,B.dt,B.bE,d,d,c,d,d,$.c().L(22),d,d,B.o,d,d,!0,d,d,d,d,d,d,d,d),d,d,d),new A.aHF(h,a7,a6)),d,d,20*a2,d,d,d)],g),B.j,B.ag),d,d,0,new A.S(b,a,b,a),B.hr,d,d,d),B.T)},
$S:266}
A.aHD.prototype={
$0(){var s=0,r=A.t(t.H),q=1,p=[],o=[],n=this,m,l,k,j,i,h,g,f,e
var $async$$0=A.o(function(a,b){if(a===1){p.push(b)
s=q}for(;;)switch(s){case 0:q=3
j=n.a
n.b.$1(new A.aHz(j))
s=6
return A.n(A.Vv("full_version_id",B.CB),$async$$0)
case 6:m=b
l=A.hT(A.z(m).a,null)==="PurchaseResult"?m.a:m
i=l.gFk().a.h(0,"premium_access")
s=(i==null?null:i.glt())===!0?7:8
break
case 7:j.P(new A.aHA(j))
A.cK(n.c,!1).hK(null)
j.awT()
i=A.di(u.k,0,null)
h=t.N
g=A.V(["Content-Type","application/json"],h,h)
s=9
return A.n(A.aRt(i,B.aS.va(A.V(["userId",j.a.c],h,h),null),g).iy(new A.aHB()),$async$$0)
case 9:j.u1()
case 8:o.push(5)
s=4
break
case 3:q=2
e=p.pop()
k=A.a7(e)
A.hW().$1("خطأ في الدفع: "+A.j(k))
o.push(5)
s=4
break
case 2:o=[1]
case 4:q=1
n.b.$1(new A.aHC(n.a))
s=o.pop()
break
case 5:return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$$0,r)},
$S:11}
A.aHz.prototype={
$0(){return this.a.CW=!0},
$S:0}
A.aHA.prototype={
$0(){return this.a.as=!0},
$S:0}
A.aHB.prototype={
$1(a){return A.hW().$1("DB Update Error: "+A.j(a))},
$S:9}
A.aHC.prototype={
$0(){return this.a.CW=!1},
$S:0}
A.aHE.prototype={
$0(){A.cK(this.a,!1).hK(null)
return null},
$S:0}
A.aHF.prototype={
$0(){var s=0,r=A.t(t.H),q=1,p=[],o=[],n=this,m,l,k,j,i,h,g
var $async$$0=A.o(function(a,b){if(a===1){p.push(b)
s=q}for(;;)switch(s){case 0:q=3
l=n.a
n.b.$1(new A.aHv(l))
s=6
return A.n(A.Vw(),$async$$0)
case 6:m=b
k=m.a.a.h(0,"premium_access")
s=(k==null?null:k.b)===!0?7:9
break
case 7:l.P(new A.aHw(l))
A.cK(n.c,!1).hK(null)
l.are("تم استعادة مشترياتك بنجاح! ✅")
k=A.di(u.k,0,null)
j=t.N
i=A.V(["Content-Type","application/json"],j,j)
s=10
return A.n(A.aRt(k,B.aS.va(A.V(["userId",l.a.c],j,j),null),i).iy(new A.aHx()),$async$$0)
case 10:l.u1()
s=8
break
case 9:l.KW("لم يتم العثور على مشتريات سابقة.",!1)
case 8:o.push(5)
s=4
break
case 3:q=2
g=p.pop()
n.a.KW("حدث خطأ أثناء الاستعادة.",!1)
o.push(5)
s=4
break
case 2:o=[1]
case 4:q=1
n.b.$1(new A.aHy(n.a))
s=o.pop()
break
case 5:return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$$0,r)},
$S:11}
A.aHv.prototype={
$0(){return this.a.CW=!0},
$S:0}
A.aHw.prototype={
$0(){return this.a.as=!0},
$S:0}
A.aHx.prototype={
$1(a){return A.hW().$1("DB Update Error: "+A.j(a))},
$S:9}
A.aHy.prototype={
$0(){return this.a.CW=!1},
$S:0}
A.aHK.prototype={
$1(a){var s=null
return A.DA(s,B.B,A.ra(new A.aHJ(),s,B.hX,B.qD,new A.aG(0.1,1,t.Y),t.i),s,s,0,s,B.hr,s,s,s)},
$S:638}
A.aHJ.prototype={
$3(a,b,c){var s,r,q,p,o,n,m,l,k,j,i,h,g=null,f="FFHekaya",e=$.c().gq(),d=$.c()
d=30*Math.min(d.gq(),d.gp())
s=$.c()
s=A.ay(30*Math.min(s.gq(),s.gp()))
r=A.bo(B.aq,4*$.c().gq())
q=$.c()
q=Math.min(q.gq(),q.gp())
q=A.b([new A.be(0,B.H,B.kY,new A.h(0,10*$.c().gp()),20*q)],t.V)
p=$.c()
p=20*Math.min(p.gq(),p.gp())
o=A.U(38,B.aq.m()>>>16&255,B.aq.m()>>>8&255,B.aq.m()&255)
p=A.ag(g,A.bL(B.rp,B.aq,g,$.c().L(100)),B.j,g,g,new A.ar(o,g,g,g,g,g,g,B.ae),g,g,g,new A.S(p,p,p,p),g,g,g)
o=A.aa(g,20*$.c().gp(),g)
n=A.a6("تم التفعيل بنجاح!",g,g,g,g,g,g,g,A.Z(g,g,B.aq,g,g,g,g,g,f,g,g,$.c().L(60),g,g,B.o,g,g,!0,g,g,g,g,g,g,g,g),g,B.T,g)
m=A.aa(g,10*$.c().gp(),g)
l=A.a6("جميع الفئات والتويستات أصبحت متاحة لك الآن 🔓",g,g,g,g,g,g,g,A.Z(g,g,B.bD,g,g,g,g,g,f,g,g,$.c().L(35),g,g,g,g,1.3,!0,g,g,g,g,g,g,g,g),B.N,g,g)
k=A.aa(g,35*$.c().gp(),g)
j=$.c()
j=A.ay(15*Math.min(j.gq(),j.gp()))
i=50*$.c().gq()
h=15*$.c().gp()
j=A.hZ(g,g,B.k,g,g,g,5,g,g,g,g,g,g,new A.S(i,h,i,h),g,new A.c2(j,B.y),g,g,g,g,g)
return A.Am(A.ag(g,A.bf(A.b([p,o,n,m,l,k,A.jg(A.a6("هيا نلعب",g,g,g,g,g,g,g,A.Z(g,g,B.h,g,g,g,g,g,f,g,g,$.c().L(40),g,g,B.o,g,g,!0,g,g,g,g,g,g,g,g),g,g,g),new A.aHI(a),j)],t.p),B.p,B.r,B.Z),B.j,g,g,new A.ar(B.h,g,r,s,q,g,g,B.u),g,g,g,new A.S(d,d,d,d),g,g,500*e),b)},
$S:61}
A.aHI.prototype={
$0(){A.cK(this.a,!1).hK(null)
return null},
$S:0}
A.aHM.prototype={
$0(){var s=null,r=this.a,q=r.z,p=this.b
if(B.b.D(q,p))B.b.G(q,p)
else if(q.length<6)q.push(p)
else r.c.av(t.J).f.io(A.iP(s,s,s,B.k,s,B.D,s,A.a6("يمكنك اختيار 6 فئات فقط",s,s,s,s,s,s,s,A.Z(s,s,s,s,s,s,s,s,"FFHekaya",s,s,$.c().L(18),s,s,s,s,s,!0,s,s,s,s,s,s,s,s),B.c4,s,s),s,B.bZ,s,s,s,s,s,s,s,s,s,s))},
$S:0}
A.aHg.prototype={
$1(a){return a.b},
$S:639}
A.aHf.prototype={
$1(a){return!this.a.D(0,a)},
$S:267}
A.aHh.prototype={
$0(){var s=this.a
s.e.push(this.b)
s.d.qn(B.E2)},
$S:0}
A.aHu.prototype={
$0(){B.b.ed(this.a.e,this.b)},
$S:0}
A.aHL.prototype={
$1(a){return a.a},
$S:641}
A.aHk.prototype={
$0(){var s=this.a
if(this.b)s.a0b()
else s.axJ(this.c)},
$S:0}
A.aHj.prototype={
$2(a,b){var s=null,r=A.U(153,B.h.m()>>>16&255,B.h.m()>>>8&255,B.h.m()&255)
return A.aUe(B.cs,A.ag(s,s,B.j,B.cs,s,s,s,s,s,s,s,s,s),r)},
$S:137}
A.aHi.prototype={
$3(a,b,c){return A.bL(B.fU,B.dk,null,$.c().L(24))},
$S:268}
A.aHl.prototype={
$0(){return this.a.avi(this.b)},
$S:0}
A.aHQ.prototype={
$2(a,b){var s,r=null,q=this.a,p=q.r[b],o=q.w,n=A.cT(0,200,0),m=5*$.c().gq(),l=$.c()
l=3*Math.min(l.gq(),l.gp())
o=p===o?B.bk:B.B
o=A.bo(o,3*$.c().gq())
s=$.c()
return A.fA(r,A.kN(A.xg(B.h,new A.kP(p,r,r),r,50*Math.min(s.gq(),s.gp())),r,B.O,new A.ar(r,r,o,r,r,r,r,B.ae),n,r,r,new A.S(m,0,m,0),new A.S(l,l,l,l),r),B.a8,!1,r,r,r,r,r,r,r,r,r,r,r,r,r,r,new A.aHP(q,p),r,r,r,r,r,r)},
$S:269}
A.aHP.prototype={
$0(){var s=this.a
return s.P(new A.aHN(s,this.b))},
$S:0}
A.aHN.prototype={
$0(){return this.a.w=this.b},
$S:0}
A.aHR.prototype={
$1(a){return this.a.Uw()},
$S:52}
A.aHS.prototype={
$2(a0,a1){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=null,d=4292519200,c=this.a,b=c.y,a=new A.aR(b,A.m(b).i("aR<1>")).de(0,a1)
b=c.y.h(0,a)
b.toString
s=$.c().gp()
r=$.c().gq()
q=$.c().gq()
p=$.c().gp()
o=$.c().gp()
n=$.c().gq()
m=$.c().gq()
l=$.c()
l=A.ay(20*Math.min(l.gq(),l.gp()))
k=A.aJ(d)
k=A.U(B.d.T(127.5),k.m()>>>16&255,k.m()>>>8&255,k.m()&255)
j=$.c().gq()
i=$.c()
i=A.ay(20*Math.min(i.gq(),i.gp()))
h=A.aJ(4294963659)
g=10*$.c().gq()
f=$.c().L(50)
g=A.ua(e,new A.e2(4,i,B.hR),e,new A.S(10*n,50*p,10*m,20*o),e,e,e,e,!0,new A.e2(4,l,new A.aW(k,2*j,B.z,-1)),e,e,e,e,e,e,e,B.r5,B.eD,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,A.ag(e,A.bZ(A.b([A.a6(a,e,e,e,e,e,e,e,A.Z(e,e,A.aJ(d),e,e,e,e,e,"FFHekaya",e,e,f,e,e,B.o,e,e,!0,e,e,e,e,e,e,e,e),e,e,e)],t.p),B.p,B.r,B.Z,0,e),B.j,h,e,e,e,e,e,new A.S(g,0,g,0),e,e,e),e,e,!0,!0,!1,e,e,e,e,e,e,e,e,e,e,e,e,e,e)
h=$.c().gq()
return new A.bi(new A.S(5*r,0,5*q,30*s),A.aTs(e,A.aTj(new A.zM(6,10*$.c().gp(),10*h,0.8),new A.aHO(c,b),b.length,new A.yS(e),!0),g,!1,!1,!1,!1,B.N,e),e)},
$S:270}
A.aHO.prototype={
$2(a,b){return this.a.ahu(this.b[b])},
$S:88}
A.aHT.prototype={
$0(){A.cK(this.a,!1).hK(null)
return null},
$S:0}
A.qf.prototype={
ao(){var s=A.WZ()
return new A.Lv(s,new A.c1(null,t.B),new A.r4(B.f4,$.aT()))}}
A.Lv.prototype={
aD(){var s=this
s.aP()
s.d.a_(s.gasO())
s.ch=A.aVl("https://api.3krooot.com",A.V(["transports",A.b(["websocket"],t.s),"autoConnect",!0],t.N,t.z))
$.C1().G3("309635509788-1ocqg3a738g3rranar4tusid6bbsmdgb.apps.googleusercontent.com")
s.ch.bD("force_disconnect",new A.aIo(s))},
l(){var s=this.ay
s.aj$=$.aT()
s.ag$=0
this.d.l()
this.aJ()},
asP(){var s,r=this
if(!r.x)r.P(new A.aIi(r))
if(!r.z&&r.d.f.length!==0&&!r.y){s=B.b.gc9(r.d.f).at
s.toString
if(s>400*$.c().gp())r.P(new A.aIj(r))}},
xW(){var s=0,r=A.t(t.H),q,p=this
var $async$xW=A.o(function(a,b){if(a===1)return A.p(b,r)
for(;;)switch(s){case 0:p.P(new A.aIf(p))
s=3
return A.n(A.k3(B.bv,null,t.z),$async$xW)
case 3:if(p.c==null){s=1
break}s=4
return A.n(p.J2(),$async$xW)
case 4:if(b){s=1
break}p.P(new A.aIg(p))
A.k3(B.bh,new A.aIh(p),t.P)
case 1:return A.q(q,r)}})
return A.r($async$xW,r)},
Cg(){var s=0,r=A.t(t.b5),q,p=2,o=[],n,m,l,k,j,i,h,g
var $async$Cg=A.o(function(a,b){if(a===1){o.push(b)
s=p}for(;;)switch(s){case 0:p=4
s=7
return A.n(A.OL(A.di("https://api.3krooot.com/api/images",0,null)),$async$Cg)
case 7:n=b
if(n.b===200){j=n
m=B.aS.v1(A.a8A(A.a8n(j.e)).e9(j.w),null)
i=J.av(m,"categories")
l=i==null?[]:i
j=J.j5(l,new A.aI5(),t.a)
j=A.a0(j,j.$ti.i("ao.E"))
q=new A.d4(j,A.a2(j).i("d4<1,aL<i,@>>"))
s=1
break}else{j=A.b([],t.H7)
q=j
s=1
break}p=2
s=6
break
case 4:p=3
g=o.pop()
k=A.a7(g)
A.hW().$1("Error fetching images: "+A.j(k))
j=A.b([],t.H7)
q=j
s=1
break
s=6
break
case 3:s=2
break
case 6:case 1:return A.q(q,r)
case 2:return A.p(o.at(-1),r)}})
return A.r($async$Cg,r)},
J2(){var s=0,r=A.t(t.y),q
var $async$J2=A.o(function(a,b){if(a===1)return A.p(b,r)
for(;;)switch(s){case 0:q=!1
s=1
break
case 1:return A.q(q,r)}})
return A.r($async$J2,r)},
KZ(){var s=0,r=A.t(t.H),q,p=this,o,n
var $async$KZ=A.o(function(a,b){if(a===1)return A.p(b,r)
for(;;)switch(s){case 0:n=B.c.d1(p.ay.a.a)
if(n.length===0){p.yf("الرجاء إدخال الكود من تطبيق الهاتف")
s=1
break}p.P(new A.aIa(p))
o=p.ch
o===$&&A.a()
o.d0("browser_connected")
p.ch.d0("pairing_error")
p.ch.bD("browser_connected",new A.aIb(p,n))
p.ch.bD("pairing_error",new A.aIc(p))
o=t.N
p.ch.c7("browser_join_session",A.V(["code",n],o,o))
A.k3(B.qz,new A.aId(p),t.P)
case 1:return A.q(q,r)}})
return A.r($async$KZ,r)},
yf(a){var s=null
this.c.av(t.J).f.io(A.iP(s,s,s,B.k,s,B.D,s,A.a6(a,s,s,s,s,s,s,s,A.Z(s,s,s,s,s,s,s,s,"FFHekaya",s,s,$.c().L(24),s,s,s,s,s,!0,s,s,s,s,s,s,s,s),s,s,s),s,B.bZ,s,s,s,s,s,s,s,s,s,s))},
j4(a,b){if(!b)return $.c().L(a*0.6)
else return $.c().L(a*0.85)
return $.c().L(a)},
O(a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b=this,a=null,a0="FFHekaya",a1=A.bS(a4,a,t.w).w.a,a2=$.c(),a3=a2.d
a3===$&&A.a()
s=a3.a.b
r=(a1.b-s)/2
q=60*a2.gp()
a2=a1.a
p=a2<=900
a3=A.b([B.bF,B.ap],t.W)
o=b.w
n=o?B.jc:B.dA
m=A.kN(a,a,B.ld,a,B.bv,a,o?r:q,a,a,a)
if(o)o=s
else o=p?250*$.c().gp():450*$.c().gp()
if(b.w)l=a2*0.9
else l=p?a2*0.6:450*$.c().gq()
l=A.kN(new A.Cd(b.gasG(),a),a,B.ld,a,B.bv,a,o,a,a,l)
o=A.aa(a,25*$.c().gp(),a)
k=b.r
j=k?1:0
if(k){k=20*$.c().gq()
i=A.a6("ثلاث كروت.. والذكاء هو الحكم",a,a,a,a,a,a,a,A.Z(a,a,B.k,a,a,a,a,a,a0,a,a,p?$.c().L(65):$.c().L(48),a,a,a,a,1.2,!0,a,a,a,a,a,a,a,a),B.N,a,a)
h=A.aa(a,p?40*$.c().gp():60*$.c().gp(),a)
g=!p
a2=g?1300*$.c().gq():a2*0.92
g=g?20*$.c().gq():0
f=t.p
if(p){e=A.b([],f)
e.push(b.UW(!0))
e.push(A.aa(a,20*$.c().gp(),a))
e.push(b.V9(!0))
e=A.bf(e,B.ce,B.r,B.Z)}else e=A.bZ(A.b([A.bP(b.V9(!1),1),A.aa(a,a,15*$.c().gq()),A.bP(b.ahs(!1),1),A.aa(a,a,15*$.c().gq()),A.bP(b.UW(!1),1)],f),B.an,B.r,B.t,0,a)
e=A.cc(new A.fU(new A.al(0,a2,0,1/0),new A.bi(new A.S(g,0,g,0),e,b.e),a),a,a)
a2=A.aa(a,p?50*$.c().gp():80*$.c().gp(),a)
g=p?$.c().L(75):$.c().L(36)
f=A.bf(A.b([new A.bi(new A.S(k,0,k,0),i,a),h,e,a2,A.a6("الفئات المتاحة",a,a,a,a,a,a,a,A.Z(a,a,A.U(204,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255),a,a,a,a,a,a0,a,a,g,a,a,a,a,a,!0,a,a,a,a,a,a,a,a),a,a,a),A.aa(a,25*$.c().gp(),a)],f),B.p,B.r,B.t)
a2=f}else a2=B.ax
k=t.p
j=A.b([new A.qZ(A.bf(A.b([m,l,o,A.Pu(a2,B.cv,B.lo,j)],k),B.p,B.r,B.t),a)],k)
if(b.r)j.push(A.aYP(new A.aIl(b,p),b.Q,t.b5))
if(b.r){a2=$.c().gp()
o=$.c().gp()
m=$.c().gp()
l=p?20*$.c().gq():40*$.c().gq()
i=p?20*$.c().gq():40*$.c().gq()
h=$.c()
h=40*Math.min(h.gq(),h.gp())
h=A.m_(B.G,new A.aF(h,h))
g=A.U(B.d.T(76.5),B.l.m()>>>16&255,B.l.m()>>>8&255,B.l.m()&255)
f=$.c()
f=A.b([new A.be(0,B.H,g,B.Wr,15*Math.min(f.gq(),f.gp()))],t.V)
if(p)g=A.bf(A.b([b.UZ(!0),A.aa(a,35*$.c().gp(),a),A.ad9(B.fF,1,1),A.aa(a,35*$.c().gp(),a),b.V1(!0),A.aa(a,35*$.c().gp(),a),A.ad9(B.fF,1,1),A.aa(a,35*$.c().gp(),a),b.V_(!0)],k),B.p,B.r,B.t)
else{g=A.bP(b.UZ(!1),3)
e=$.c().gq()
e=A.ag(a,a,B.j,B.ep,a,a,a,180*$.c().gp(),a,a,a,a,2*e)
d=A.bP(b.V1(!1),2)
c=$.c().gq()
c=A.bZ(A.b([g,e,d,A.ag(a,a,B.j,B.ep,a,a,a,180*$.c().gp(),a,a,a,a,2*c),A.bP(b.V_(!1),2)],k),B.an,B.mv,B.t,0,a)
g=c}e=A.aa(a,35*$.c().gp(),a)
d=A.ad9(B.fF,1,1)
c=A.aa(a,15*$.c().gp(),a)
j.push(new A.qZ(new A.bi(new A.S(0,50*a2,0,0),A.ag(a,A.bf(A.b([g,e,d,c,A.a6("جميع الحقوق محفوظة \xa9 2026 شركة كروت",a,a,a,a,a,a,a,A.Z(a,a,B.Lg,a,a,a,a,a,a0,a,a,p?$.c().L(35):$.c().L(22),a,a,a,a,a,!0,a,a,a,a,a,a,a,a),B.N,a,a)],k),B.p,B.r,B.t),B.j,a,a,new A.ar(B.k,a,a,h,f,a,a,B.u),a,a,a,new A.S(l,40*o,i,20*m),a,a,1/0),a),a))}return A.zt(a,A.ag(a,new A.Rr(j,B.ai,!1,b.d,a,n,a,!1,a,0,a,a,B.nw,B.a8,a,a,B.D,B.b0,a),B.j,a,a,new A.ar(a,a,a,a,a,new A.fc(B.c8,B.bg,B.at,a3,a,a),a,B.u),a,1/0,a,a,a,a,1/0),a)},
qA(a){return this.aqO(a)},
aqO(a){var s=0,r=A.t(t.H),q=this,p
var $async$qA=A.o(function(b,c){if(b===1)return A.p(c,r)
for(;;)switch(s){case 0:p=A.di(a,0,null)
s=5
return A.n(A.aVt(p),$async$qA)
case 5:s=c?2:4
break
case 2:s=6
return A.n(A.aVP(p,B.Qa),$async$qA)
case 6:s=3
break
case 4:if(q.c!=null)q.yf("لا يمكن فتح الرابط حالياً")
case 3:return A.q(null,r)}})
return A.r($async$qA,r)},
V9(a){var s,r,q,p,o,n,m,l,k=this,j=null,i="FFHekaya"
if(a){s=$.c()
s=15*Math.min(s.gq(),s.gp())}else s=0
if(a){r=A.U(20,B.l.m()>>>16&255,B.l.m()>>>8&255,B.l.m()&255)
q=$.c()
q=Math.min(q.gq(),q.gp())
q=new A.ar(B.h,j,j,j,A.b([new A.be(0,B.H,r,new A.h(0,5*$.c().gp()),10*q)],t.V),j,j,B.ae)
r=q}else r=j
s=A.ag(j,A.bL(B.OX,B.k,j,k.j4(a?100:45,a)),B.j,j,j,r,j,j,j,new A.S(s,s,s,s),j,j,j)
r=A.aa(j,a?10*$.c().gp():10*$.c().gp(),j)
q=A.a6("حمل اللعبة",j,j,j,j,j,j,j,A.Z(j,j,B.k,j,j,j,j,j,i,j,j,k.j4(a?260:90,a),j,j,B.o,j,j,!0,j,j,j,j,j,j,j,j),j,j,j)
p=A.aa(j,10*$.c().gp(),j)
o=A.a6("لشراء النسخة الكاملة من اللعبة او تجربة اللعبة مجانا لفترة محدودة",j,j,j,j,j,j,j,A.Z(j,j,B.k,j,j,j,j,j,i,j,j,k.j4(a?85:40,a),j,j,j,j,1.4,!0,j,j,j,j,j,j,j,j),B.N,j,j)
n=A.aa(j,a?15*$.c().gp():25*$.c().gp(),j)
m=k.Va(B.P9,"حملها من","App Store",u.x,a)
l=A.bf(A.b([s,r,q,p,o,n,m,A.aa(j,a?8*$.c().gp():15*$.c().gp(),j),k.Va(B.OL,"متوفر على","Google Play",u.B,a)],t.p),B.p,B.ad,B.Z)
s=$.c()
s=A.ay(25*Math.min(s.gq(),s.gp()))
r=A.bo(A.U(B.d.T(229.5),B.h.m()>>>16&255,B.h.m()>>>8&255,B.h.m()&255),2*$.c().gq())
q=A.U(B.d.T(127.5),B.ik.m()>>>16&255,B.ik.m()>>>8&255,B.ik.m()&255)
p=$.c()
p=Math.min(p.gq(),p.gp())
p=A.b([new A.be(0,B.H,q,new A.h(0,8*$.c().gp()),15*p)],t.V)
q=$.c()
q=A.ay(20*Math.min(q.gq(),q.gp()))
o=A.bo(A.U(B.d.T(76.5),B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255),1.5*$.c().gq())
if(a){q=20*$.c().gq()
o=20*$.c().gp()
return A.ag(j,l,B.j,j,j,new A.ar(j,j,r,s,p,B.Qi,j,B.u),j,j,j,new A.S(q,o,q,o),j,j,1/0)}else{s=20*$.c().gq()
r=20*$.c().gp()
return new A.t6(0.6896551724137931,A.ag(j,A.cc(A.zL(l,B.D,new A.S(s,r,s,r),B.dA,!1,B.ai),j,j),B.j,j,j,new A.ar(B.ie,j,o,q,j,j,j,B.u),j,j,j,j,j,j,j),j)}},
ahs(a){var s,r,q,p=this,o=null,n="FFHekaya",m=A.bL(B.OZ,B.k,o,p.j4(a?120:50,a)),l=A.aa(o,a?10*$.c().gp():15*$.c().gp(),o),k=A.a6("العب من المتصفح",o,o,o,o,o,o,o,A.Z(o,o,B.k,o,o,o,o,o,n,o,o,p.j4(a?260:80,a),o,o,B.o,o,o,!0,o,o,o,o,o,o,o,o),B.N,o,o),j=A.aa(o,5*$.c().gp(),o),i=p.j4(a?85:40,a)
i=A.a6("افتح اللعبة من هاتفك وأدخل الكود هنا",o,o,o,o,o,o,o,A.Z(o,o,A.U(204,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255),o,o,o,o,o,n,o,o,i,o,o,o,o,o,!0,o,o,o,o,o,o,o,o),B.N,o,o)
s=t.p
i=A.b([m,l,k,j,i,A.aa(o,a?15*$.c().gp():30*$.c().gp(),o)],s)
if(p.f)i.push(A.cc(A.Qw(B.k,o,o),o,o))
else{m=A.Z(o,o,o,o,o,o,o,o,o,o,o,p.j4(a?80:45,a),o,o,B.o,o,o,!0,o,o,o,o,o,o,o,o)
l=A.U(204,B.h.m()>>>16&255,B.h.m()>>>8&255,B.h.m()&255)
k=$.c()
k=A.ay(15*Math.min(k.gq(),k.gp()))
j=$.c()
m=A.Ym(p.ay,A.ua(o,new A.e2(4,k,new A.aW(B.k,1,B.z,-1)),o,o,o,o,"",o,!0,o,o,o,o,o,o,l,!0,o,o,o,o,new A.e2(4,A.ay(15*Math.min(j.gq(),j.gp())),new A.aW(B.k,2*$.c().gq(),B.z,-1)),o,o,o,o,o,o,o,o,o,"ادخل الكود ...",B.T,o,o,o,o,o,o,o,o,!0,!0,!1,o,o,o,o,o,o,o,o,o,o,o,o,o,o),o,6,o,m,B.N)
j=A.aa(o,10*$.c().gp(),o)
l=15*$.c().gp()
k=$.c()
k=A.hZ(o,o,B.k,o,o,o,5,o,o,o,B.h,o,o,new A.S(0,l,0,l),o,new A.c2(A.ay(15*Math.min(k.gq(),k.gp())),B.y),o,o,o,o,o)
B.b.I(i,A.b([m,j,A.jg(A.a6("دخول",o,o,o,o,o,o,o,A.Z(o,o,o,o,o,o,o,o,n,o,o,p.j4(a?70:45,a),o,o,o,o,o,!0,o,o,o,o,o,o,o,o),o,o,o),p.gari(),k)],s))}r=A.bf(i,B.ce,B.ad,B.Z)
m=$.c()
m=A.ay(30*Math.min(m.gq(),m.gp()))
q=new A.ar(B.ap,o,A.bo(A.U(51,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255),2*$.c().gq()),m,A.b([new A.be(0,B.H,A.U(B.d.T(76.5),B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255),B.Wo,10)],t.V),o,o,B.u)
if(a){m=20*$.c().gq()
l=20*$.c().gp()
return A.ag(o,r,B.j,o,o,q,o,o,o,new A.S(m,l,m,l),o,o,1/0)}else{m=$.c()
m=20*Math.min(m.gq(),m.gp())
return new A.t6(0.6896551724137931,A.ag(o,A.cc(A.zL(r,B.D,new A.S(m,m,m,m),B.dA,!1,B.ai),o,o),B.j,o,o,q,o,o,o,o,o,o,o),o)}},
UW(a){var s,r,q,p,o,n,m=null,l="FFHekaya"
if(a){s=$.c()
s=15*Math.min(s.gq(),s.gp())}else s=0
if(a){r=A.U(20,B.l.m()>>>16&255,B.l.m()>>>8&255,B.l.m()&255)
q=$.c()
q=Math.min(q.gq(),q.gp())
q=new A.ar(B.h,m,m,m,A.b([new A.be(0,B.H,r,new A.h(0,5*$.c().gp()),10*q)],t.V),m,m,B.ae)
r=q}else r=m
s=A.ag(m,A.bL(B.P4,B.k,m,this.j4(a?100:50,a)),B.j,m,m,r,m,m,m,new A.S(s,s,s,s),m,m,m)
r=A.aa(m,a?10*$.c().gp():5*$.c().gp(),m)
q=A.a6("قصة اللعبة",m,m,m,m,m,m,m,A.Z(m,m,B.k,m,m,m,m,m,l,m,m,this.j4(a?260:80,a),m,m,B.o,m,m,!0,m,m,m,m,m,m,m,m),m,m,m)
p=A.aa(m,a?10*$.c().gp():15*$.c().gp(),m)
o=A.Z(m,m,B.k,m,m,m,m,m,l,m,m,this.j4(a?85:36,a),m,m,m,m,1.4,!0,m,m,m,m,m,m,m,m)
n=A.bf(A.b([s,r,q,p,A.arK(m,m,m,B.cI,m,m,!0,m,A.dv(A.b([B.a2o,A.dv(m,m,m,m,m,m,m,m,m,A.Z(m,m,B.q0,m,m,m,m,m,m,m,m,m,m,m,B.o,m,m,!0,m,m,m,m,m,m,m,m),'"سؤال" '),B.a2p,A.dv(m,m,m,m,m,m,m,m,m,A.Z(m,m,B.l2,m,m,m,m,m,m,m,m,m,m,m,B.o,m,m,!0,m,m,m,m,m,m,m,m),'"وقت" '),B.a2q,A.dv(m,m,m,m,m,m,m,m,m,A.Z(m,m,B.qb,m,m,m,m,m,m,m,m,m,m,m,B.o,m,m,!0,m,m,m,m,m,m,m,m),'"تويست" '),B.a2r],t.VO),m,m,m,m,m,m,m,m,o,m),B.N,B.T,m,B.aP,B.aH)],t.p),B.p,B.ad,B.Z)
o=$.c()
o=A.ay(25*Math.min(o.gq(),o.gp()))
p=A.bo(A.U(B.d.T(229.5),B.h.m()>>>16&255,B.h.m()>>>8&255,B.h.m()&255),2*$.c().gq())
q=A.U(B.d.T(127.5),B.ip.m()>>>16&255,B.ip.m()>>>8&255,B.ip.m()&255)
r=$.c()
r=Math.min(r.gq(),r.gp())
r=A.b([new A.be(0,B.H,q,new A.h(0,8*$.c().gp()),15*r)],t.V)
q=$.c()
q=A.ay(20*Math.min(q.gq(),q.gp()))
s=A.bo(A.U(B.d.T(76.5),B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255),1.5*$.c().gq())
if(a){s=20*$.c().gq()
q=20*$.c().gp()
return A.ag(m,n,B.j,m,m,new A.ar(m,m,p,o,r,B.Qh,m,B.u),m,m,m,new A.S(s,q,s,q),m,m,1/0)}else{r=$.c()
r=20*Math.min(r.gq(),r.gp())
return new A.t6(0.6896551724137931,A.ag(m,A.cc(A.zL(n,B.D,new A.S(r,r,r,r),B.dA,!1,B.ai),m,m),B.j,m,m,new A.ar(B.q6,m,s,q,m,m,m,B.u),m,m,m,m,m,m,m),m)}},
Va(a,b,c,d,a0){var s,r,q,p,o,n,m,l,k,j,i,h=this,g=null,f=0*$.c().gp(),e=$.c()
e=A.ay(20*Math.min(e.gq(),e.gp()))
s=A.U(51,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
r=20*$.c().gq()
q=a0?15*$.c().gp():14*$.c().gp()
p=a0?A.U(153,B.h.m()>>>16&255,B.h.m()>>>8&255,B.h.m()&255):A.U(20,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
o=$.c()
o=A.ay(20*Math.min(o.gq(),o.gp()))
n=a0?B.h:A.U(51,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
n=A.bo(n,1.5*$.c().gq())
if(a0){m=A.U(13,B.l.m()>>>16&255,B.l.m()>>>8&255,B.l.m()&255)
l=$.c()
l=Math.min(l.gq(),l.gp())
l=A.b([new A.be(0,B.H,m,new A.h(0,3*$.c().gp()),5*l)],t.V)
m=l}else m=g
l=A.bL(a,B.k,g,h.j4(a0?100:70,a0))
k=A.aa(g,g,20*$.c().gq())
j=A.U(204,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
j=A.a6(b,g,g,g,g,g,g,g,A.Z(g,g,j,g,g,g,g,g,"FFHekaya",g,g,h.j4(a0?50:38,a0),g,g,g,g,g,!0,g,g,g,g,g,g,g,g),g,g,g)
i=t.p
return new A.bi(new A.S(0,f,0,f),A.jt(B.aa,!0,g,A.l7(!1,e,!0,A.ag(g,A.bZ(A.b([l,k,A.bf(A.b([j,A.a6(c,g,g,g,g,g,g,g,A.Z(g,g,B.k,g,g,g,g,g,"Arial",g,g,h.j4(a0?65:45,a0),g,g,B.o,g,1.1,!0,g,g,g,g,g,g,g,g),g,g,g)],i),B.an,B.r,B.Z)],i),B.p,B.ad,B.t,0,g),B.j,g,g,new A.ar(p,g,n,o,m,g,g,B.u),g,g,g,new A.S(r,q,r,q),g,g,1/0),g,!0,g,g,g,g,g,g,g,new A.aI4(h,d),g,g,g,g,s,g,g),B.j,B.B,0,g,g,g,g,g,B.cE),g)},
UZ(a){var s,r,q,p,o,n=null,m="FFHekaya",l=a?250*$.c().gq():140*$.c().gq()
l=A.nR("assets/logosmall.png",n,B.bs,a?250*$.c().gq():140*$.c().gq(),l)
s=A.aa(n,10*$.c().gp(),n)
r=A.a6("3 كروت",n,n,n,n,n,n,n,A.Z(n,n,B.bF,n,n,n,n,n,m,n,n,a?$.c().L(80):$.c().L(45),n,n,B.o,n,n,!0,n,n,n,n,n,n,n,n),n,B.T,n)
q=a?$.c().L(45):$.c().L(24)
q=A.a6("والذكاء هو الحكم",n,n,n,n,n,n,n,A.Z(n,n,A.U(204,B.ap.m()>>>16&255,B.ap.m()>>>8&255,B.ap.m()&255),n,n,n,n,n,m,n,n,q,n,n,n,n,n,!0,n,n,n,n,n,n,n,n),n,n,n)
p=A.aa(n,15*$.c().gp(),n)
o=a?10*$.c().gq():20*$.c().gq()
return A.bf(A.b([l,s,r,q,p,new A.bi(new A.S(o,0,o,0),A.a6("لعبة التحدي والسرعة الأولى التي تجمع بين المعلومة والذكاء في قالب مرح وتنافسي.",n,n,n,n,n,n,n,A.Z(n,n,B.a5,n,n,n,n,n,m,n,n,a?$.c().L(45):$.c().L(22),n,n,n,n,1.4,!0,n,n,n,n,n,n,n,n),B.N,B.T,n),n)],t.p),B.p,B.r,B.t)},
V1(a){var s=null
return A.bf(A.b([A.a6("حمل التطبيق",s,s,s,s,s,s,s,A.Z(s,s,B.h,s,s,s,s,s,"FFHekaya",s,s,a?$.c().L(65):$.c().L(35),s,s,s,s,s,!0,s,s,s,s,s,s,s,s),s,s,s),A.aa(s,25*$.c().gp(),s),this.V0(B.l,B.OH,B.h,a,"Download on the","App Store",u.x),A.aa(s,15*$.c().gp(),s),this.V0(B.l,B.OJ,B.h,a,"GET IT ON","Google Play",u.B)],t.p),B.p,B.ad,B.t)},
V_(a){var s=null,r=t.p
return A.bf(A.b([A.a6("تابعنا",s,s,s,s,s,s,s,A.Z(s,s,B.h,s,s,s,s,s,"FFHekaya",s,s,a?$.c().L(65):$.c().L(35),s,s,s,s,s,!0,s,s,s,s,s,s,s,s),s,s,s),A.aa(s,30*$.c().gp(),s),A.bZ(A.b([this.IV(B.OI,"يوتيوب","https://youtube.com/@3_krooot?si=zPHO-AFfZiqie20s",a),this.IV(B.OG,"إنستغرام","https://www.instagram.com/3_krooot?igsh=cjhvaGxxNDNxdmxi&utm_source=qr",a),this.IV(B.OF,"تيك توك","https://www.tiktok.com/@3_krooot?_r=1&_t=ZS-94FFeIv8yIb",a)],r),B.p,B.ad,B.t,0,s)],r),B.p,B.ad,B.t)},
IV(a,b,c,d){var s,r,q,p=null,o=d?20*$.c().gq():12*$.c().gq(),n=$.c()
n=A.ay(50*Math.min(n.gq(),n.gp()))
if(d){s=$.c()
s=18*Math.min(s.gq(),s.gp())}else{s=$.c()
s=12*Math.min(s.gq(),s.gp())}r=A.U(13,B.h.m()>>>16&255,B.h.m()>>>8&255,B.h.m()&255)
q=A.bo(A.U(B.d.T(127.5),B.bF.m()>>>16&255,B.bF.m()>>>8&255,B.bF.m()&255),$.c().gq())
return new A.bi(new A.S(o,0,o,0),A.jt(B.aa,!0,p,A.l7(!1,n,!0,A.ag(p,A.bL(a,B.bF,p,d?$.c().L(55):$.c().L(38)),B.j,p,p,new A.ar(r,p,q,p,p,p,p,B.ae),p,p,p,new A.S(s,s,s,s),p,p,p),p,!0,p,p,p,p,p,p,p,new A.aI3(this,c),p,p,p,p,p,p,p),B.j,B.B,0,p,p,p,p,p,B.cE),p)},
V0(a,b,c,d,e,f,g){var s,r,q,p,o,n,m,l,k=null,j=$.c()
j=A.ay(10*Math.min(j.gq(),j.gp()))
s=d?18*$.c().gp():8*$.c().gp()
r=d?30*$.c().gq():12*$.c().gq()
q=$.c()
q=A.ay(10*Math.min(q.gq(),q.gp()))
p=A.bo(B.fF,$.c().gq())
o=A.bL(b,c,k,d?$.c().L(65):$.c().L(34))
n=A.aa(k,k,15*$.c().gq())
m=A.a6(e,k,k,k,k,k,k,k,A.Z(k,k,B.h,k,k,k,k,k,"Arial",k,k,d?$.c().L(26):$.c().L(12),k,k,k,k,k,!0,k,k,k,k,k,k,k,k),k,k,k)
l=t.p
return A.jt(B.aa,!0,k,A.l7(!1,j,!0,A.ag(k,A.bZ(A.b([o,n,A.bf(A.b([m,A.a6(f,k,k,k,k,k,k,k,A.Z(k,k,B.h,k,k,k,k,k,"Arial",k,k,d?$.c().L(38):$.c().L(20),k,k,B.o,k,1.1,!0,k,k,k,k,k,k,k,k),k,k,k)],l),B.an,B.ad,B.t)],l),B.p,B.ad,B.Z,0,k),B.j,k,k,new A.ar(a,k,p,q,k,k,k,B.u),k,k,k,new A.S(r,s,r,s),k,k,k),k,!0,k,k,k,k,k,k,k,new A.aI0(this,g),k,k,k,k,k,k,k),B.j,B.B,0,k,k,k,k,k,B.cE)},
ahE(a,b,c){var s,r,q,p,o,n,m,l=null,k=J.b9n(a.h(0,"url"),"http")?a.h(0,"url"):"https://api.3krooot.com"+A.j(a.h(0,"url")),j=a.h(0,"version"),i=j==null?l:J.b7(j)
if(i==null)i="1"
j=$.c()
j=A.ay(20*Math.min(j.gq(),j.gp()))
s=A.U(38,B.l.m()>>>16&255,B.l.m()>>>8&255,B.l.m()&255)
r=$.c()
r=Math.min(r.gq(),r.gp())
r=A.b([new A.be(0,B.H,s,new A.h(0,2*$.c().gp()),4*r)],t.V)
s=$.c()
s=20*Math.min(s.gq(),s.gp())
s=A.bP(A.no(A.m_(B.G,new A.aF(s,s)),A.ag(l,new A.pZ(A.aU6(l,l,new A.yQ(k+"?v="+i,1,l,B.a8h)),l,new A.aI1(this),new A.aI2(this),l,l,l,B.cg,l,B.bs,B.bg,B.ci,!1,l),B.j,B.cs,l,l,l,l,l,l,l,l,1/0)),3)
q=c?12*$.c().gp():14*$.c().gp()
p=c?2*$.c().gq():4*$.c().gq()
o=$.c()
o=20*Math.min(o.gq(),o.gp())
o=A.m_(new A.aF(o,o),B.G)
n=a.h(0,"title")
m=c?75:35
return A.ag(l,A.bf(A.b([s,A.ag(l,A.a6(n,l,l,1,B.aG,l,l,l,A.Z(l,l,B.h,l,l,l,l,l,"FFHekaya",l,l,$.c().L(m),l,l,B.o,l,l,!0,l,l,l,l,l,l,l,l),B.N,l,l),B.j,l,l,new A.ar(B.k,l,l,o,l,l,l,B.u),l,l,l,new A.S(p,q,p,q),l,l,1/0)],t.p),B.p,B.r,B.t),B.j,l,l,new A.ar(B.h,l,l,j,r,l,l,B.u),l,l,l,l,l,l,l)}}
A.aIo.prototype={
$1(a){var s,r=null,q=this.a,p=q.c
if(p!=null){p=p.av(t.J).f
s=J.av(a,"message")
if(s==null)s="تم إنهاء الجلسة من قبل المضيف"
p.io(A.iP(r,r,r,B.ak,r,B.D,r,A.a6(s,r,r,r,r,r,r,r,A.Z(r,r,r,r,r,r,r,r,"FFHekaya",r,r,$.c().L(24),r,r,r,r,r,!0,r,r,r,r,r,r,r,r),r,r,r),r,B.bZ,r,r,r,r,r,r,r,r,r,r))
q=q.c
q.toString
A.cK(q,!1).kO(A.hg(new A.aIm(),r,t.z),new A.aIn())}},
$S:3}
A.aIm.prototype={
$1(a){return B.dY},
$S:53}
A.aIn.prototype={
$1(a){return!1},
$S:30}
A.aIi.prototype={
$0(){this.a.x=!0},
$S:0}
A.aIj.prototype={
$0(){this.a.z=!0},
$S:0}
A.aIf.prototype={
$0(){this.a.w=!1},
$S:0}
A.aIg.prototype={
$0(){var s=this.a
s.Q=s.Cg()
s.r=!0},
$S:0}
A.aIh.prototype={
$0(){var s=0,r=A.t(t.P),q=this,p,o
var $async$$0=A.o(function(a,b){if(a===1)return A.p(b,r)
for(;;)switch(s){case 0:p=q.a
o=p.e
s=$.ad.a5$.x.h(0,o)!=null&&p.c!=null?2:3
break
case 2:p.y=!0
o=$.ad.a5$.x.h(0,o)
o.toString
s=4
return A.n(A.b_W(o,0.4,B.ZP,B.ld,B.ll),$async$$0)
case 4:o=p.y=!1
if(!p.z?p.c!=null:o)p.P(new A.aIe(p))
case 3:return A.q(null,r)}})
return A.r($async$$0,r)},
$S:182}
A.aIe.prototype={
$0(){this.a.z=!0},
$S:0}
A.aI5.prototype={
$1(a){var s,r,q=typeof a=="string",p=q?a:J.av(a,"url")
if(q)r="فئة جديدة"
else{q=J.av(a,"title")
r=q==null?"بدون اسم":q}s=r
return A.V(["url",p,"title",s,"version",J.av(a,"version")],t.N,t.z)},
$S:645}
A.aIa.prototype={
$0(){return this.a.f=!0},
$S:0}
A.aIb.prototype={
$1(a){var s,r=this.a
if(r.c!=null){r.P(new A.aI8(r))
r.yf("✅ تم الربط بنجاح!")
s=J.av(a,"userId")
if(s==null)s="browser_"+this.b
r=r.c
r.toString
A.aTP(r,A.hg(new A.aI9(s),null,t.z))}},
$S:3}
A.aI8.prototype={
$0(){return this.a.f=!1},
$S:0}
A.aI9.prototype={
$1(a){return new A.ke(this.a,"شاشة العرض",null,null)},
$S:263}
A.aIc.prototype={
$1(a){var s,r=this.a
if(r.c!=null){r.P(new A.aI7(r))
s=J.av(a,"message")
r.yf("❌ "+A.j(s==null?"الكود غير صحيح":s))}},
$S:3}
A.aI7.prototype={
$0(){return this.a.f=!1},
$S:0}
A.aId.prototype={
$0(){var s=this.a
if(s.c!=null&&s.f){s.P(new A.aI6(s))
s.yf("⏳ انتهى وقت الاتصال، تأكد من تشغيل السيرفر")}},
$S:7}
A.aI6.prototype={
$0(){return this.a.f=!1},
$S:0}
A.aIl.prototype={
$2(a,b){var s,r,q,p,o,n=null
if(b.a===B.qi||this.a.Q==null)return new A.qZ(A.cc(A.Qw(B.k,n,n),n,n),n)
else{if(b.c==null){s=b.b
s=s==null||J.pn(s)}else s=!0
if(s)return B.a0P}s=this.a
if(!s.z)return new A.qZ(A.ag(n,n,B.j,B.B,n,n,n,400*$.c().gp(),n,n,n,n,n),n)
r=this.b
q=!r?150*$.c().gq():20*$.c().gq()
if(r){p=$.c().gq()
p=new A.zM(3,15*$.c().gp(),12*p,0.65)}else{p=$.c().gq()
o=$.c().gq()
o=new A.auu(240*p,30*$.c().gp(),30*o,0.8)
p=o}o=b.b
o.toString
return new A.Iq(new A.S(q,0,q,0),A.b0a(new A.Ip(new A.aIk(s,b,r),J.cw(o),!0,!0,!0,n),p),n)},
$S:646}
A.aIk.prototype={
$2(a,b){var s=this.b.b
s.toString
return this.a.ahE(J.av(s,b),b,this.c)},
$S:88}
A.aI4.prototype={
$0(){return this.a.qA(this.b)},
$S:0}
A.aI3.prototype={
$0(){return this.a.qA(this.b)},
$S:0}
A.aI0.prototype={
$0(){return this.a.qA(this.b)},
$S:0}
A.aI1.prototype={
$3(a,b,c){var s=null
if(c==null)return b
return A.cc(A.Qw(A.U(B.d.T(127.5),B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255),s,s),s,s)},
$C:"$3",
$R:3,
$S:271}
A.aI2.prototype={
$3(a,b,c){return A.bL(B.fU,B.dh,null,$.c().L(50))},
$S:648}
A.fW.prototype={
fh(){var s=this
return A.V(["id",s.a,"name",s.b,"color",s.c.gt(),"avatarPath",s.d,"members",s.e],t.N,t.z)},
gaQ(){return this.b}}
A.lg.prototype={
ao(){var s="openrelayproject",r=$.aT(),q=t.s,p=t.N
return new A.LP(new A.r4(B.f4,r),new A.r4(B.f4,r),new A.r4(B.f4,r),$.P6(),[],A.b([],t.N8),A.b(["assets/players/blue.png","assets/players/green.png","assets/players/pink.png","assets/players/purple.png","assets/players/red.png","assets/players/yellow.png"],q),A.b([B.ak,B.eK,B.bk,B.mz,B.yn,B.yo,B.yq,B.ym,B.my,B.yp],t.W),A.v(p,t.b5),A.b([],q),A.b2(p),A.v(p,t.Lr),A.b([],t.iO),A.v(p,t.H1),A.V(["iceServers",A.b([A.V(["url","stun:stun.l.google.com:19302"],p,p),A.V(["url","stun:stun1.l.google.com:19302"],p,p),A.V(["url","turn:openrelay.metered.ca:80","username",s,"credential",s],p,p)],t.m0),"sdpSemantics","unified-plan"],p,t.z))}}
A.LP.prototype={
aD(){var s,r,q,p,o,n,m,l,k=this,j=null
k.aP()
s=k.d
r=k.a.d
s.qn(s.a.z0(B.by,B.nL,r))
s=k.cy
k.db=s[0]
r=k.a.e
if(r!=null&&J.kL(r)){r=k.a.e
r.toString
r=J.bh(r)
while(r.B()){q=r.gN()
p=k.cx
o=J.aw(q)
n=o.h(q,"id")
n=n==null?j:J.b7(n)
if(n==null)n="team_"+Date.now()
m=o.h(q,"name")
m=m==null?j:J.b7(m)
if(m==null)m="فريق"
l=o.h(q,"color")!=null?A.aJ(A.fm(J.b7(o.h(q,"color")),j)):B.eK
o=o.h(q,"avatarPath")
o=o==null?j:J.b7(o)
if(o==null)o=s[0]
B.b.E(p,new A.fW(n,m,l,o,[]))}k.w=!0}k.awD()
k.xY()},
xY(){var s=0,r=A.t(t.H),q=this
var $async$xY=A.o(function(a,b){if(a===1)return A.p(b,r)
for(;;)switch(s){case 0:s=2
return A.n(q.uj(),$async$xY)
case 2:s=3
return A.n(q.Ch(),$async$xY)
case 3:if(q.c!=null&&!q.fy)q.Zi()
return A.q(null,r)}})
return A.r($async$xY,r)},
Ch(){var s=0,r=A.t(t.H),q=1,p=[],o=this,n,m,l,k,j,i
var $async$Ch=A.o(function(a,b){if(a===1){p.push(b)
s=q}for(;;)switch(s){case 0:q=3
n=A.di(u.v,0,null)
s=6
return A.n(A.OL(n),$async$Ch)
case 6:m=b
if(m.b===200){k=m
l=B.aS.v1(A.a8A(A.a8n(k.e)).e9(k.w),null)
if(o.c!=null)o.P(new A.aJe(o,l))}else if(o.c!=null)o.P(new A.aJf(o))
q=1
s=5
break
case 3:q=2
i=p.pop()
if(o.c!=null)o.P(new A.aJg(o))
s=5
break
case 2:s=1
break
case 5:return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$Ch,r)},
VE(){var s=this.r,r=s.a
r===$&&A.a()
r.d0("webrtc_new_peer")
s.a.d0("webrtc_offer")
s.a.d0("webrtc_answer")
s.a.d0("webrtc_ice_candidate")
s.a.d0("webrtc_existing_peers")},
Zi(){var s=this.c
s.toString
A.BY(!0,new A.aJY(this),s,t.z)},
Zk(){var s=this.c
s.toString
A.BY(!1,new A.aK0(),s,t.z)},
Zj(a,b){var s=null,r=this.c.av(t.J).f,q=A.a6(a,s,s,s,s,s,s,s,A.Z(s,s,s,s,s,s,s,s,"FFHekaya",s,s,$.c().L(20),s,s,s,s,s,!0,s,s,s,s,s,s,s,s),B.c4,s,s)
r.io(A.iP(s,s,s,B.cD,B.hy,B.D,s,q,s,B.bZ,s,s,s,s,s,s,s,s,s,s))},
CZ(a){var s,r=null,q=$.c().gp(),p=$.c()
p=4*Math.min(p.gq(),p.gp())
s=A.U(51,B.aq.m()>>>16&255,B.aq.m()>>>8&255,B.aq.m()&255)
return new A.bi(new A.S(0,0,0,12*q),A.bZ(A.b([A.ag(r,A.bL(B.rq,B.aq,r,$.c().L(20)),B.j,r,r,new A.ar(s,r,r,r,r,r,r,B.ae),r,r,r,new A.S(p,p,p,p),r,r,r),A.aa(r,r,10*$.c().gq()),A.bP(new A.bi(new A.S(0,2*$.c().gp(),0,0),A.a6(a,r,r,r,r,r,r,r,A.Z(r,r,B.k,r,r,r,r,r,"FFHekaya",r,r,$.c().L(35),r,r,B.o,r,r,!0,r,r,r,r,r,r,r,r),r,r,r),r),1)],t.p),B.an,B.r,B.t,0,r),r)},
awD(){var s=this,r=s.r,q=r.a
q===$&&A.a()
q.bD("online_room_created",new A.aJy(s))
r.a.bD("online_room_joined",new A.aJz(s))
r.a.bD("lobby_updated",new A.aJA(s))
r.a.bD("join_error",new A.aJE(s))
r.a.bD("online_game_started",new A.aJF(s))
r.a.bD("force_disconnect",new A.aJG(s))
r.a.bD("phone_disconnected",new A.aJH(s))
r.a.bD("webrtc_new_peer",new A.aJI(s))
r.a.bD("webrtc_existing_peers",new A.aJJ(s))
r.a.bD("player_left",new A.aJK(s))
r.a.bD("webrtc_offer",new A.aJL(s))
r.a.bD("webrtc_answer",new A.aJB(s))
r.a.bD("webrtc_ice_candidate",new A.aJC(s))
r.a.bD("lobby_categories_updated",new A.aJD(s))},
l(){var s=this,r=s.r,q=r.a
q===$&&A.a()
q.d0("online_room_created")
r.a.d0("online_room_joined")
r.a.d0("lobby_updated")
r.a.d0("join_error")
r.a.d0("online_game_started")
r.a.d0("force_disconnect")
r.a.d0("lobby_categories_updated")
if(!s.Q){s.VE()
if(s.p2){r=s.k4
if(r!=null)B.b.ac(r.wu(),new A.aKx())
r=s.k4
if(r!=null)r.l()
r=s.ok
r.ac(0,new A.aKy())
r.R(0)
B.b.R(s.p3)}}r=s.d
q=r.aj$=$.aT()
r.ag$=0
r=s.e
r.aj$=q
r.ag$=0
r=s.f
r.aj$=q
r.ag$=0
r=s.k1
if(r!=null)r.aG()
r=s.k2
if(r!=null)r.aG()
s.aJ()},
m1(){var s=0,r=A.t(t.H),q=1,p=[],o=this,n,m,l,k,j,i
var $async$m1=A.o(function(a,b){if(a===1){p.push(b)
s=q}for(;;)switch(s){case 0:o.P(new A.aJj(o))
l=A.b([B.jf,B.yR,B.yV],t.o_)
s=2
return A.n($.aWt().jX(l),$async$m1)
case 2:q=4
s=7
return A.n(A.PR(),$async$m1)
case 7:n=b
s=8
return A.n(n.r5(new A.px(B.ki,new A.wT(12),B.kj,null,null,B.ov,B.hL,null)),$async$m1)
case 8:s=9
return A.n(n.Bh(!0),$async$m1)
case 9:$.a8Z()
l=t.N
k=t.z
s=10
return A.n(new A.Uh().tq(A.V(["audio",!0,"video",!1],l,k)),$async$m1)
case 10:o.k4=b
A.any(!1)
o.P(new A.aJk(o))
o.ax4()
s=11
return A.n(A.k3(B.bv,null,k),$async$m1)
case 11:o.ax5()
l=A.V(["roomCode",o.z],l,t.v)
k=o.r.a
k===$&&A.a()
k.c7("webrtc_join_voice",l)
q=1
s=6
break
case 4:q=3
i=p.pop()
m=A.a7(i)
o.P(new A.aJl(o))
A.hW().$1("❌ خطأ في إعداد الصوت أو فتح المايك: "+A.j(m))
s=6
break
case 3:s=1
break
case 6:return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$m1,r)},
ax5(){var s=this.k2
if(s!=null)s.aG()
this.k2=A.Jq(B.qE,new A.aK4(this))},
ax4(){var s=this.k1
if(s!=null)s.aG()
this.k1=A.Jq(B.ln,new A.aK3(this))},
tX(a){return this.ajq(a)},
ajq(a){var s=0,r=A.t(t.Lr),q,p=this,o,n
var $async$tX=A.o(function(b,c){if(b===1)return A.p(c,r)
for(;;)switch(s){case 0:n=p.ok
s=n.ad(a)?3:4
break
case 3:s=5
return A.n(n.h(0,a).ar(),$async$tX)
case 5:n.G(0,a)
case 4:s=6
return A.n($.a8Z().EO(p.R8,null),$async$tX)
case 6:o=c
n.n(0,a,o)
n=p.k4
if(n!=null)B.b.ac(n.wu(),new A.aJ8(p,o))
o.e=new A.aJ9(p,a)
o.Q=new A.aJa(p)
q=o
s=1
break
case 1:return A.q(q,r)}})
return A.r($async$tX,r)},
y0(a,b){return this.auF(a,b)},
auF(a,b){var s=0,r=A.t(t.H),q=1,p=[],o=this,n,m,l,k,j
var $async$y0=A.o(function(c,d){if(c===1){p.push(d)
s=q}for(;;)switch(s){case 0:k=o.p4
s=k.ad(a)?2:3
break
case 2:m=k.h(0,a)
m.toString
m=J.bh(m)
case 4:if(!m.B()){s=5
break}n=m.gN()
q=7
s=10
return A.n(b.qV(n),$async$y0)
case 10:q=1
s=9
break
case 7:q=6
j=p.pop()
s=9
break
case 6:s=1
break
case 9:s=4
break
case 5:k.G(0,a)
case 3:return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$y0,r)},
oG(a){return this.aof(a)},
aof(a){var s=0,r=A.t(t.H),q=this,p,o,n,m,l
var $async$oG=A.o(function(b,c){if(b===1)return A.p(c,r)
for(;;)switch(s){case 0:m=q.r
l=m.a
l===$&&A.a()
p=l.e
s=B.c.b9(p==null?"":p,a)>0?2:3
break
case 2:s=4
return A.n(q.tX(a),$async$oG)
case 4:o=c
s=5
return A.n(o.z7(),$async$oG)
case 5:n=c
s=6
return A.n(o.q8(n),$async$oG)
case 6:l=t.N
l=A.V(["to",a,"offer",A.V(["sdp",n.a,"type",n.b],l,t.v)],l,t.z)
m.a.c7("webrtc_offer",l)
case 3:return A.q(null,r)}})
return A.r($async$oG,r)},
oH(a,b){return this.aoL(a,b)},
aoL(a,b){var s=0,r=A.t(t.H),q=this,p,o,n,m
var $async$oH=A.o(function(c,d){if(c===1)return A.p(d,r)
for(;;)switch(s){case 0:m=q.ok
s=m.ad(a)?2:3
break
case 2:s=4
return A.n(m.h(0,a).ar(),$async$oH)
case 4:m.G(0,a)
case 3:s=5
return A.n(q.tX(a),$async$oH)
case 5:p=d
m=J.aw(b)
s=6
return A.n(p.q9(new A.ll(m.h(b,"sdp"),m.h(b,"type"))),$async$oH)
case 6:q.y0(a,p)
s=7
return A.n(p.z5(),$async$oH)
case 7:o=d
s=8
return A.n(p.q8(o),$async$oH)
case 8:m=t.N
m=A.V(["to",a,"answer",A.V(["sdp",o.a,"type",o.b],m,t.v)],m,t.z)
n=q.r.a
n===$&&A.a()
n.c7("webrtc_answer",m)
return A.q(null,r)}})
return A.r($async$oH,r)},
Cy(a,b){return this.aoH(a,b)},
aoH(a,b){var s=0,r=A.t(t.H),q=this,p,o
var $async$Cy=A.o(function(c,d){if(c===1)return A.p(d,r)
for(;;)switch(s){case 0:o=q.ok.h(0,a)
s=o!=null?2:3
break
case 2:p=J.aw(b)
s=4
return A.n(o.q9(new A.ll(p.h(b,"sdp"),p.h(b,"type"))),$async$Cy)
case 4:q.y0(a,o)
case 3:return A.q(null,r)}})
return A.r($async$Cy,r)},
xC(a,b){return this.aoJ(a,b)},
aoJ(a,b){var s=0,r=A.t(t.H),q=1,p=[],o=this,n,m,l,k,j
var $async$xC=A.o(function(c,d){if(c===1){p.push(d)
s=q}for(;;)switch(s){case 0:m=J.aw(b)
l=new A.lj(m.h(b,"candidate"),m.h(b,"sdpMid"),m.h(b,"sdpMLineIndex"))
k=o.ok.h(0,a)
s=k!=null?2:4
break
case 2:s=8
return A.n(k.B4(),$async$xC)
case 8:s=d!=null?5:7
break
case 5:q=10
s=13
return A.n(k.qV(l),$async$xC)
case 13:q=1
s=12
break
case 10:q=9
j=p.pop()
s=12
break
case 9:s=1
break
case 12:s=6
break
case 7:J.ep(o.p4.bi(a,new A.aJh()),l)
case 6:s=3
break
case 4:J.ep(o.p4.bi(a,new A.aJi()),l)
case 3:return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$xC,r)},
axL(){var s=this
if(s.k4!=null){s.P(new A.aK7(s))
B.b.ac(s.k4.Hy(),new A.aK8(s))}},
am_(a){if(this.p1)return B.ak
if(a>0.7)return B.cD
if(a>0.4)return B.mx
return B.j9},
atj(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=this,d=null,c=e.c
c.toString
s=A.bS(c,d,t.w).w.a.a<900
if(s){c=$.c()
r=60*Math.min(c.gq(),c.gp())}else{c=$.c()
r=70*Math.min(c.gq(),c.gp())}if(s){c=$.c()
q=80*Math.min(c.gq(),c.gp())}else{c=$.c()
q=120*Math.min(c.gq(),c.gp())}p=r+q
c=e.id
o=r+c*q
n=e.am_(c)
if(e.go){c=5*$.c().gq()
m=r*0.5
return A.ag(B.x,A.bf(A.b([A.aa(B.pt,m,m),A.aa(d,8*$.c().gp(),d),A.a6("جاري الاتصال...",d,d,d,d,d,d,d,A.Z(d,d,B.h,d,d,d,d,d,"FFHekaya",d,d,$.c().L(14),d,d,B.o,d,d,!0,d,d,d,d,d,d,d,d),B.N,d,d)],t.p),B.p,B.r,B.Z),B.j,d,d,d,d,p,new A.S(c,0,c,0),d,d,d,p)}c=5*$.c().gq()
m=A.b([],t.p)
if(!e.p1&&e.p2){l=A.U(B.d.T(255*(0.2+e.id*0.3)),n.m()>>>16&255,n.m()>>>8&255,n.m()&255)
k=A.U(B.d.T(255*(e.id*0.6)),n.m()>>>16&255,n.m()>>>8&255,n.m()&255)
j=$.c()
j=Math.min(j.gq(),j.gp())
i=e.id
h=$.c()
h=Math.min(h.gq(),h.gp())
g=e.id
f=$.c()
m.push(A.kN(d,d,B.O,new A.ar(l,d,d,d,A.b([new A.be(g*(10*Math.min(f.gq(),f.gp())),B.H,k,B.i,20*j+i*(40*h))],t.V),d,d,B.ae),B.qA,d,o,d,d,o))}l=e.p1
k=l?B.i9:B.h
l=l?B.ak:A.U(204,n.m()>>>16&255,n.m()>>>8&255,n.m()&255)
l=A.bo(l,3*$.c().gq())
j=$.c()
j=Math.min(j.gq(),j.gp())
j=A.b([new A.be(0,B.H,B.bu,new A.h(0,3*$.c().gp()),5*j)],t.V)
i=e.p1
h=i?B.rr:B.rs
i=i?B.dF:A.U(B.d.T(229.5),n.m()>>>16&255,n.m()>>>8&255,n.m()&255)
m.push(A.ag(d,A.bL(h,i,d,r*0.55),B.j,d,d,new A.ar(k,d,l,d,j,d,d,B.ae),d,r,d,d,d,d,r))
return A.fA(d,A.ag(B.x,A.cU(B.x,m,B.j,B.ag),B.j,d,d,d,d,p,new A.S(c,0,c,0),d,d,d,p),B.a8,!1,d,d,d,d,d,d,d,d,d,d,d,d,d,d,e.gaxK(),d,d,d,d,d,d)},
qH(){var s=0,r=A.t(t.H),q=1,p=[],o=this,n,m,l,k
var $async$qH=A.o(function(a,b){if(a===1){p.push(b)
s=q}for(;;)switch(s){case 0:q=3
s=6
return A.n(A.vE(),$async$qH)
case 6:n=b
s=7
return A.n(J.hX(n,"saved_userId"),$async$qH)
case 7:s=8
return A.n(J.hX(n,"saved_username"),$async$qH)
case 8:s=9
return A.n($.C1().n7(),$async$qH)
case 9:q=1
s=5
break
case 3:q=2
k=p.pop()
s=5
break
case 2:s=1
break
case 5:if(o.c!=null){l=o.r.a
l===$&&A.a()
l.Fa()
l=o.c
l.toString
A.cK(l,!1).kO(A.hg(new A.aJm(),null,t.z),new A.aJn())}return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$qH,r)},
uj(){var s=0,r=A.t(t.H),q=1,p=[],o=this,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3
var $async$uj=A.o(function(b4,b5){if(b4===1){p.push(b5)
s=q}for(;;)switch(s){case 0:q=3
n=A.di(u.I+o.a.c,0,null)
s=6
return A.n(A.OL(n),$async$uj)
case 6:m=b5
if(m.b===200){b=m
l=B.aS.v1(A.a8A(A.a8n(b.e)).e9(b.w),null)
a=J.av(l,"categories")
k=a==null?[]:a
a0=J.av(l,"isPremium")
j=a0==null?!1:a0
b=t.N
i=A.v(b,t.b5)
if(!j&&!o.fy)J.j3(i,"الفئات المجانية",A.b([],t.H7))
for(a1=J.bh(k),a2=t.z,a3=t.H7;a1.B();){h=a1.gN()
a4=J.av(h,"collection")
a5=a4==null?null:J.b7(a4)
g=a5==null?"فئات عامة":a5
a4=J.av(h,"title")
a4=a4==null?null:J.b7(a4)
if(a4==null){a4=J.av(h,"category")
a4=a4==null?null:J.b7(a4)
a6=a4}else a6=a4
f=a6==null?"بدون عنوان":a6
a4=J.av(h,"status")
a7=a4==null?null:J.b7(a4).toLowerCase()
e=a7==null?"paid":a7
a4=J.av(h,"url")
a8=J.av(h,"version")
a9=J.av(h,"percent")
a9=J.C8(a9==null?0:a9)
b0=J.av(h,"remainingPercent")
b0=J.C8(b0==null?1:b0)
b1=J.av(h,"isCompleted")
if(b1==null)b1=!1
d=A.V(["title",f,"url",a4,"version",a8,"percent",a9,"remainingPercent",b0,"isCompleted",b1,"status",e],b,a2)
if(!i.ad(g))J.j3(i,g,A.b([],a3))
J.av(i,g).push(d)
if(!j&&!o.fy&&!J.d(e,"paid"))J.av(i,"الفئات المجانية").push(d)}if(!j&&!o.fy&&J.av(i,"الفئات المجانية")!=null&&J.av(i,"الفئات المجانية").length===0)J.hX(i,"الفئات المجانية")
o.P(new A.aJb(o,i,j))}else{A.en("Failed to load: "+m.b)
o.P(new A.aJc(o))}q=1
s=5
break
case 3:q=2
b3=p.pop()
c=A.a7(b3)
A.en("Error fetching categories: "+A.j(c))
o.P(new A.aJd(o))
s=5
break
case 2:s=1
break
case 5:return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$uj,r)},
atm(a){var s,r,q=this
if(!q.y)return
q.P(new A.aK6(q,a))
s=A.V(["categories",q.fr],t.N,t.yp)
r=q.r.a
r===$&&A.a()
r.c7("sync_lobby_categories",s)},
aju(){var s,r=this,q=B.c.d1(r.d.a.a)
if(q.length===0){r.qI("أدخل اسمك أولاً")
return}s=t.N
s=A.V(["userId",r.a.c,"teamName",q],s,s)
q=r.r.a
q===$&&A.a()
q.c7("create_online_game",s)},
aqK(){var s,r=t.N
r=A.V(["roomCode",B.c.d1(this.e.a.a),"teamName",B.c.d1(this.d.a.a)],r,r)
s=this.r.a
s===$&&A.a()
s.c7("join_online_game",r)},
axa(){var s=this.fr,r=this.cx,q=A.a2(r).i("a4<1,aL<i,@>>")
r=A.a0(new A.a4(r,new A.aK5(),q),q.i("ao.E"))
s=A.V(["categories",s,"teams",r],t.N,t.UX)
r=this.r.a
r===$&&A.a()
r.c7("start_online_game",s)},
DM(){var s,r
if(!this.y)return
s=this.cx
r=A.a2(s).i("a4<1,aL<i,@>>")
s=A.a0(new A.a4(s,new A.aKb(),r),r.i("ao.E"))
s=A.V(["teams",s],t.N,t.b5)
r=this.r.a
r===$&&A.a()
r.c7("update_lobby_teams",s)},
ath(){var s,r,q,p=this,o={},n=p.cx
if(n.length>=2){p.qI("الحد الأقصى المسموح به هو فريقين فقط")
return}if(B.c.d1(p.f.a.a).length===0){p.qI("اكتب اسم الفريق")
return}s=p.dx
r=A.a2(s).i("b4<1>")
q=A.a0(new A.b4(s,new A.aJ_(new A.a4(n,new A.aJ0(),A.a2(n).i("a4<1,w>")).hN(0)),r),r.i("E.E"))
o.a=q
if(q.length===0){o.a=s
n=s}else n=q
B.b.T1(n)
p.P(new A.aJ1(o,p))
p.DM()},
atl(a){this.P(new A.aJp(this,a))
this.DM()},
ahk(a,b){this.P(new A.aJ4(this,a,b))
this.DM()},
a1_(a){this.P(new A.aKa(this,a))
this.DM()},
qI(a){var s=null
this.c.av(t.J).f.io(A.iP(s,s,s,B.cD,s,B.D,s,A.a6(a,s,s,s,s,s,s,s,A.Z(s,s,s,s,s,s,s,s,"FFHekaya",s,s,$.c().L(20),s,s,s,s,s,!0,s,s,s,s,s,s,s,s),s,s,s),s,B.bZ,s,s,s,s,s,s,s,s,s,s))},
ati(b3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6=this,a7=null,a8="FFHekaya",a9=b3.h(0,"title"),b0=b3.h(0,"url"),b1=b3.h(0,"version"),b2=b1==null?a7:J.b7(b1)
if(b2==null)b2="1"
b1=b3.h(0,"status")
r=b1==null?a7:J.b7(b1).toLowerCase()
q=(r==null?"paid":r)==="paid"&&!a6.fy
p=(B.c.b7(b0,"http")?b0:"https://api.3krooot.com"+b0)+"?v="+b2
b1=b3.h(0,"percent")
o=J.C8(b1==null?0:b1)
n=b3.h(0,"isCompleted")
if(n==null)n=!1
m=B.b.D(a6.fr,a9)
s=!1
try{s=!a6.y}catch(l){}b1=s
k=$.c()
k=A.ay(15*Math.min(k.gq(),k.gp()))
if(m)j=B.bk
else j=q?B.bE:B.B
j=A.bo(j,m||q?3*$.c().gq():0)
i=A.U(B.d.T(25.5),B.l.m()>>>16&255,B.l.m()>>>8&255,B.l.m()&255)
h=$.c()
h=Math.min(h.gq(),h.gp())
h=A.b([new A.be(0,B.H,i,new A.h(0,3*$.c().gp()),5*h)],t.V)
i=$.c()
i=14*Math.min(i.gq(),i.gp())
i=A.m_(B.G,new A.aF(i,i))
g=t.p
f=A.b([A.aaY(B.x,p,new A.aJ5(),B.bs,p,a7,new A.aJ6(),a7)],g)
if(q){e=A.U(B.d.T(178.5),B.em.m()>>>16&255,B.em.m()>>>8&255,B.em.m()&255)
d=$.c().gp()
c=$.c().gq()
b=A.bL(B.rn,B.a5,a7,$.c().L(20))
a=$.c().L(32)
a0=$.c()
a0=Math.min(a0.gq(),a0.gp())
a0=A.a6("متاحة للنسخة الكاملة فقط",a7,a7,a7,a7,a7,a7,a7,A.Z(a7,a7,B.h,a7,a7,a7,a7,a7,a8,a7,a7,a,a7,a7,B.o,a7,1.2,!0,a7,a7,a7,a7,a7,A.b([new A.fh(B.l,new A.h(0,2*$.c().gp()),5*a0)],t.kO),a7,a7),B.N,a7,a7)
a=A.aa(a7,10*$.c().gp(),a7)
a1=10*$.c().gq()
a2=6*$.c().gp()
a3=A.U(217,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
a4=$.c()
a4=A.ay(8*Math.min(a4.gq(),a4.gp()))
a5=A.bo(A.U(B.d.T(127.5),B.S.m()>>>16&255,B.S.m()>>>8&255,B.S.m()&255),$.c().gq())
f.push(A.ag(a7,A.cc(A.bf(A.b([new A.e_(B.kp,a7,a7,new A.bi(new A.S(0,5*d,5*c,0),b,a7),a7),new A.mM(a7),a0,a,A.ag(a7,A.bZ(A.b([A.bL(B.ru,B.S,a7,$.c().L(18)),A.aa(a7,a7,5*$.c().gq()),A.a6("اضغط للشراء",a7,a7,a7,a7,a7,a7,a7,A.Z(a7,a7,B.h,a7,a7,a7,a7,a7,a8,a7,a7,$.c().L(20),a7,a7,a7,a7,a7,!0,a7,a7,a7,a7,a7,a7,a7,a7),a7,a7,a7)],g),B.p,B.r,B.Z,0,a7),B.j,a7,a7,new A.ar(a3,a7,a5,a4,a7,a7,a7,B.u),a7,a7,a7,new A.S(a1,a2,a1,a2),a7,a7,a7),new A.mM(a7)],g),B.p,B.ad,B.t),a7,a7),B.j,e,a7,a7,a7,a7,a7,a7,a7,a7,a7))}if(o>0&&!n&&!q){e=$.c().gp()
f.push(A.eu(0,A.aZG(B.cd,o,B.ou),12*e,a7,0,0,a7,a7))}i=A.bP(A.no(i,A.ag(a7,A.cU(B.aQ,f,B.D,B.jN),B.j,B.cs,a7,a7,a7,a7,a7,a7,a7,a7,1/0)),3)
f=6*$.c().gp()
e=m?B.bk:B.k
d=$.c()
d=12*Math.min(d.gq(),d.gp())
d=A.m_(new A.aF(d,d),B.G)
g=A.b([A.bf(A.b([i,A.ag(a7,A.a6(a9,a7,a7,1,a7,a7,a7,a7,A.Z(a7,a7,B.h,a7,a7,a7,a7,a7,a8,a7,a7,$.c().L(35),a7,a7,B.o,a7,a7,!0,a7,a7,a7,a7,a7,a7,a7,a7),B.N,a7,a7),B.j,a7,a7,new A.ar(e,a7,a7,d,a7,a7,a7,B.u),a7,a7,a7,new A.S(0,f,0,f),a7,a7,1/0)],g),B.p,B.r,B.t)],g)
if(m&&!q){i=$.c().gp()
f=$.c().gq()
e=$.c()
e=Math.min(e.gq(),e.gp())
g.push(A.eu(a7,A.xg(B.bk,a7,A.bL(B.rl,B.h,a7,$.c().L(16)),12*e),a7,a7,a7,5*f,5*i,a7))}return A.hz(A.l7(!1,a7,!0,A.kN(A.cU(B.aQ,g,B.D,B.ag),a7,B.O,new A.ar(B.h,a7,j,k,h,a7,a7,B.u),B.aa,a7,a7,a7,a7,a7),a7,!0,a7,a7,a7,a7,a7,a7,a7,new A.aJ7(a6,q,a9),a7,a7,a7,a7,a7,a7,a7),b1,a7)},
ahz(a){var s,r,q,p=null,o=A.xg(A.U(51,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255),p,A.bL(B.ro,B.k,p,$.c().L(18)),p),n=a.h(0,"name")
if(n==null)n="لاعب"
n=A.a6(n,p,p,p,p,p,p,p,A.Z(p,p,p,p,p,p,p,p,"FFHekaya",p,p,$.c().L(30),p,p,B.o,p,p,!0,p,p,p,p,p,p,p,p),p,p,p)
s=10*$.c().gq()
r=5*$.c().gp()
q=A.aXA(o,B.h,p,3,n,p,new A.S(s,r,s,r))
if(!this.y)return q
o=A.jt(B.aa,!0,p,A.mt(q,0.8),B.j,B.B,0,p,p,p,p,p,B.cE)
return new A.pJ(a,q,A.mt(q,0.3),o,p,t.aI)},
O(b5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9=this,b0=null,b1="FFHekaya",b2=J.aSj(a9.CW,new A.aKo(a9)),b3=A.a0(b2,b2.$ti.i("E.E")),b4=a9.y&&a9.cx.length>=2&&a9.fr.length===6
b2=$.c().gq()
s=$.c().gp()
r=$.c().gq()
q=$.c().gp()
p=$.c().gq()
o=t.p
n=A.b([A.bZ(A.b([A.ahP(b0,b0,A.bL(B.m7,B.ak,b0,$.c().L(40)),b0,b0,a9.gatk(),b0,b0,b0),a9.atj()],o),B.p,B.r,B.t,0,b0)],o)
if(a9.x){m=25*$.c().gq()
l=10*$.c().gp()
k=$.c()
k=A.ay(15*Math.min(k.gq(),k.gp()))
j=A.bo(B.k,2*$.c().gq())
n.push(A.ag(b0,A.a6("كود الغرفة: "+A.j(a9.z),b0,b0,b0,b0,b0,b0,b0,A.Z(b0,b0,B.I,b0,b0,b0,b0,b0,b1,b0,b0,$.c().L(70),b0,b0,B.o,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0),b0,b0,b0),B.j,b0,b0,new A.ar(B.h,b0,j,k,b0,b0,b0,B.u),b0,b0,b0,new A.S(m,l,m,l),b0,b0,b0))}n=A.b([A.bZ(n,B.p,B.eI,B.t,0,b0),A.aa(b0,20*$.c().gp(),b0)],o)
if(a9.x){m=$.c()
m=A.ay(20*Math.min(m.gq(),m.gp()))
l=B.d.T(25.5)
k=A.U(l,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
j=$.c()
j=20*Math.min(j.gq(),j.gp())
i=A.b([A.a6("الفِرَق المتنافسة",b0,b0,b0,b0,b0,b0,b0,A.Z(b0,b0,B.k,b0,b0,b0,b0,b0,b1,b0,b0,$.c().L(50),b0,b0,B.o,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0),b0,b0,b0)],o)
if(a9.y){h=A.aa(b0,15*$.c().gp(),b0)
g=$.c().gp()
g=A.ag(b0,A.TY(new A.aKp(a9),6,b0,!1,B.aI,!1),B.j,b0,b0,b0,b0,60*g,b0,b0,b0,b0,b0)
f=A.aa(b0,10*$.c().gp(),b0)
e=A.Z(b0,b0,b0,b0,b0,b0,b0,b0,b1,b0,b0,$.c().L(30),b0,b0,b0,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0)
d=$.c()
e=A.bP(A.Ym(a9.f,A.ua(b0,new A.e2(4,A.ay(15*Math.min(d.gq(),d.gp())),B.hR),b0,b0,b0,b0,b0,b0,!0,b0,b0,b0,b0,b0,b0,B.h,!0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,"اسم الفريق...",b0,b0,b0,b0,b0,b0,b0,b0,b0,!0,!0,!1,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0),b0,b0,b0,e,B.c4),1)
d=A.aa(b0,b0,10*$.c().gq())
c=$.c()
c=15*Math.min(c.gq(),c.gp())
b=$.c()
b=A.hZ(b0,b0,B.k,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,new A.S(c,c,c,c),b0,new A.c2(A.ay(15*Math.min(b.gq(),b.gp())),B.y),b0,b0,b0,b0,b0)
B.b.I(i,A.b([h,g,f,A.bZ(A.b([e,d,A.jg(A.bL(B.rj,B.h,b0,$.c().L(30)),a9.gatg(),b)],o),B.p,B.r,B.t,0,b0)],o))}i.push(A.aa(b0,20*$.c().gp(),b0))
h=$.c().gq()
g=$.c().gp()
f=a9.cx
e=A.a2(f).i("a4<1,nA<aL<i,@>>>")
f=A.a0(new A.a4(f,new A.aKq(a9),e),e.i("ao.E"))
i.push(A.JU(B.k0,f,15*g,15*h))
m=A.bP(A.CQ(new A.bi(new A.S(j,j,j,j),A.bf(i,B.p,B.r,B.t),b0),B.ap,b0,b0,new A.c2(m,new A.aW(k,1,B.z,-1))),2)
k=A.aa(b0,b0,20*$.c().gq())
j=$.c()
j=A.ay(20*Math.min(j.gq(),j.gp()))
i=A.U(l,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
h=$.c()
h=20*Math.min(h.gq(),h.gp())
g=A.b([A.a6("غرفة الانتظار",b0,b0,b0,b0,b0,b0,b0,A.Z(b0,b0,B.k,b0,b0,b0,b0,b0,b1,b0,b0,$.c().L(45),b0,b0,B.o,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0),b0,b0,b0)],o)
if(a9.y)g.push(A.a6("اسحب اللاعب إلى فريقه",b0,b0,b0,b0,b0,b0,b0,A.Z(b0,b0,B.bD,b0,b0,b0,b0,b0,b1,b0,b0,$.c().L(24),b0,b0,b0,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0),b0,b0,b0))
g.push(A.aa(b0,15*$.c().gp(),b0))
g.push(A.aYn(new A.aKr(a9,b3),new A.aKs(a9),t.a))
m=A.bZ(A.b([m,k,A.bP(A.CQ(new A.bi(new A.S(h,h,h,h),A.bf(g,B.p,B.r,B.t),b0),B.ap,b0,b0,new A.c2(j,new A.aW(i,1,B.z,-1))),1)],o),B.an,B.r,B.t,0,b0)
k=A.aa(b0,20*$.c().gp(),b0)
j=$.c()
j=A.ay(20*Math.min(j.gq(),j.gp()))
l=A.U(l,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
i=$.c()
i=20*Math.min(i.gq(),i.gp())
h=a9.y
g=a9.fr.length
h=h?"اختر فئات اللعبة ("+g+"/6)":"فئات اللعبة ("+g+"/6)"
h=A.b([A.a6(h,b0,b0,b0,b0,b0,b0,b0,A.Z(b0,b0,B.k,b0,b0,b0,b0,b0,b1,b0,b0,$.c().L(50),b0,b0,B.o,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0),b0,b0,b0)],o)
if(!a9.y)h.push(A.a6("المضيف يقوم باختيار الفئات حالياً...",b0,b0,b0,b0,b0,b0,b0,A.Z(b0,b0,B.bD,b0,b0,b0,b0,b0,b1,b0,b0,$.c().L(24),b0,b0,b0,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0),b0,b0,b0))
h.push(A.aa(b0,15*$.c().gp(),b0))
h.push(a9.fx?B.HW:A.TY(new A.aKt(a9),a9.dy.a,B.jc,!1,B.ai,!0))
B.b.I(n,A.b([m,k,A.CQ(new A.bi(new A.S(i,i,i,i),A.bf(h,B.p,B.r,B.t),b0),B.ap,b0,b0,new A.c2(j,new A.aW(l,1,B.z,-1)))],o))}else{m=15*$.c().gp()
l=a9.w?B.k:B.h
k=$.c()
k=A.ay(20*Math.min(k.gq(),k.gp()))
j=A.bo(B.k,2*$.c().gq())
i=$.c().L(40)
m=A.bP(A.fA(b0,A.ag(b0,A.a6("إنشاء غرفة",b0,b0,b0,b0,b0,b0,b0,A.Z(b0,b0,a9.w?B.h:B.k,b0,b0,b0,b0,b0,b1,b0,b0,i,b0,b0,B.o,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0),B.N,b0,b0),B.j,b0,b0,new A.ar(l,b0,j,k,b0,b0,b0,B.u),b0,b0,b0,new A.S(0,m,0,m),b0,b0,b0),B.a8,!1,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,new A.aKu(a9),b0,b0,b0,b0,b0,b0),1)
l=A.aa(b0,b0,20*$.c().gq())
k=15*$.c().gp()
j=!a9.w?B.k:B.h
i=$.c()
i=A.ay(20*Math.min(i.gq(),i.gp()))
h=A.bo(B.k,2*$.c().gq())
g=$.c().L(40)
m=A.bZ(A.b([m,l,A.bP(A.fA(b0,A.ag(b0,A.a6("انضمام لغرفة",b0,b0,b0,b0,b0,b0,b0,A.Z(b0,b0,!a9.w?B.h:B.k,b0,b0,b0,b0,b0,b1,b0,b0,g,b0,b0,B.o,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0),B.N,b0,b0),B.j,b0,b0,new A.ar(j,b0,h,i,b0,b0,b0,B.u),b0,b0,b0,new A.S(0,k,0,k),b0,b0,b0),B.a8,!1,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,new A.aKv(a9),b0,b0,b0,b0,b0,b0),1)],o),B.p,B.r,B.t,0,b0)
l=A.aa(b0,30*$.c().gp(),b0)
k=B.d.T(76.5)
j=A.U(k,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
i=$.c()
i=A.ay(20*Math.min(i.gq(),i.gp()))
h=A.U(51,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
g=$.c().gq()
f=$.c()
f=35*Math.min(f.gq(),f.gp())
e=a9.w?B.OW:B.P2
e=A.bL(e,B.k,b0,$.c().L(45))
d=A.aa(b0,b0,15*$.c().gq())
c=a9.w?"بيانات غرفتك الجديدة":"بيانات الانضمام للغرفة"
c=A.bZ(A.b([e,d,A.a6(c,b0,b0,b0,b0,b0,b0,b0,A.Z(b0,b0,B.k,b0,b0,b0,b0,b0,b1,b0,b0,$.c().L(45),b0,b0,B.o,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0),b0,b0,b0)],o),B.p,B.ad,B.t,0,b0)
d=A.aa(b0,35*$.c().gp(),b0)
e=$.c().gq()
b=$.c().gp()
a=A.a6("اسمك في اللعبة",b0,b0,b0,b0,b0,b0,b0,A.Z(b0,b0,B.k,b0,b0,b0,b0,b0,b1,b0,b0,$.c().L(35),b0,b0,B.o,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0),b0,b0,b0)
a0=A.Z(b0,b0,B.I,b0,b0,b0,b0,b0,b1,b0,b0,$.c().L(35),b0,b0,B.o,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0)
a1=A.Z(b0,b0,B.dh,b0,b0,b0,b0,b0,b0,b0,b0,$.c().L(30),b0,b0,b0,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0)
a2=A.bL(B.ro,B.k,b0,$.c().L(30))
a3=25*$.c().gp()
a4=$.c()
a4=A.ay(15*Math.min(a4.gq(),a4.gp()))
a5=A.U(k,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
a6=$.c().gq()
a7=$.c()
a0=A.b([A.bP(A.bf(A.b([new A.bi(new A.S(0,0,15*e,10*b),a,b0),A.Ym(a9.d,A.ua(b0,b0,b0,new A.S(0,a3,0,a3),b0,b0,b0,b0,!0,new A.e2(4,a4,new A.aW(a5,2*a6,B.z,-1)),b0,b0,b0,b0,b0,B.h,!0,b0,b0,b0,b0,new A.e2(4,A.ay(15*Math.min(a7.gq(),a7.gp())),new A.aW(B.k,3*$.c().gq(),B.z,-1)),b0,b0,b0,b0,b0,b0,b0,b0,a1,"أدخل اسمك هنا...",b0,b0,b0,b0,b0,b0,b0,b0,b0,!0,!0,!1,b0,a2,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0),b0,b0,b0,a0,B.N)],o),B.an,B.r,B.t),1)],o)
if(!a9.w){e=A.aa(b0,b0,30*$.c().gq())
b=$.c().gq()
a=$.c().gp()
a1=A.a6("كود الغرفة",b0,b0,b0,b0,b0,b0,b0,A.Z(b0,b0,B.k,b0,b0,b0,b0,b0,b1,b0,b0,$.c().L(35),b0,b0,B.o,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0),b0,b0,b0)
a2=A.Z(b0,b0,B.I,b0,b0,b0,b0,b0,b1,b0,b0,$.c().L(45),b0,b0,B.o,b0,b0,!0,b0,8*$.c().gq(),b0,b0,b0,b0,b0,b0)
a3=$.c().gq()
a3=A.Z(b0,b0,B.dh,b0,b0,b0,b0,b0,b0,b0,b0,$.c().L(35),b0,b0,b0,b0,b0,!0,b0,2*a3,b0,b0,b0,b0,b0,b0)
a4=A.bL(B.P3,B.k,b0,$.c().L(30))
a5=25*$.c().gp()
a6=$.c()
a6=A.ay(15*Math.min(a6.gq(),a6.gp()))
k=A.U(k,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
a7=$.c().gq()
a8=$.c()
B.b.I(a0,A.b([e,A.bP(A.bf(A.b([new A.bi(new A.S(0,0,15*b,10*a),a1,b0),A.Ym(a9.e,A.ua(b0,b0,b0,new A.S(0,a5,0,a5),b0,b0,b0,b0,!0,new A.e2(4,a6,new A.aW(k,2*a7,B.z,-1)),b0,b0,b0,b0,b0,B.h,!0,b0,b0,b0,b0,new A.e2(4,A.ay(15*Math.min(a8.gq(),a8.gp())),new A.aW(B.k,3*$.c().gq(),B.z,-1)),b0,b0,b0,b0,b0,b0,b0,b0,a3,"1234",b0,b0,b0,b0,b0,b0,b0,b0,b0,!0,!0,!1,b0,a4,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0),B.a2f,b0,b0,a2,B.N)],o),B.an,B.r,B.t),1)],o))}B.b.I(n,A.b([m,l,A.CQ(new A.bi(new A.S(f,f,f,f),A.bf(A.b([c,d,A.bZ(a0,B.an,B.r,B.t,0,b0)],o),B.p,B.r,B.t),b0),B.ap,8,j,new A.c2(i,new A.aW(h,2*g,B.z,-1)))],o))}b2=A.qz(0,A.zL(A.cc(new A.fU(new A.al(0,1600*p,0,1/0),A.bf(n,B.p,B.r,B.t),b0),b0,b0),B.D,new A.S(20*b2,20*s,20*r,160*q),b0,!1,B.ai))
s=$.c()
r=s.d
r===$&&A.a()
s=s.gp()
q=20*$.c().gq()
p=15*$.c().gp()
n=$.c()
n=A.ay(25*Math.min(n.gq(),n.gp()))
m=A.bo(B.S,2*$.c().gq())
l=A.U(B.d.T(127.5),B.l.m()>>>16&255,B.l.m()>>>8&255,B.l.m()&255)
k=$.c()
k=Math.min(k.gq(),k.gp())
k=A.b([new A.be(0,B.H,l,new A.h(0,5*$.c().gp()),20*k)],t.V)
l=A.b([A.vQ(A.a6("عودة",b0,b0,b0,b0,b0,b0,b0,A.Z(b0,b0,B.fG,b0,b0,b0,b0,b0,b1,b0,b0,$.c().L(28),b0,b0,b0,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0),b0,b0,b0),new A.aKw(b5),b0)],o)
if(a9.x&&a9.y)l.push(A.a6(""+a9.cx.length+" فرق | "+a9.fr.length+"/6 فئات",b0,b0,b0,b0,b0,b0,b0,A.Z(b0,b0,B.h,b0,b0,b0,b0,b0,b1,b0,b0,$.c().L(28),b0,b0,b0,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0),b0,b0,b0))
j=a9.x
if(j)i=b4?a9.gax9():b0
else i=a9.w?a9.gajt():a9.gaqJ()
j=!j||b4?B.aq:B.bD
h=40*$.c().gq()
g=15*$.c().gp()
f=$.c()
f=A.hZ(b0,b0,j,b0,b0,b0,b0,b0,b0,b0,b0,b0,b0,new A.S(h,g,h,g),b0,new A.c2(A.ay(15*Math.min(f.gq(),f.gp())),B.y),b0,b0,b0,b0,b0)
if(a9.x)j=a9.y?"ابدأ التحدي":"بانتظار المضيف..."
else j=a9.w?"إنشاء الغرفة":"انضمام للغرفة"
l.push(A.jg(A.a6(j,b0,b0,b0,b0,b0,b0,b0,A.Z(b0,b0,B.h,b0,b0,b0,b0,b0,b1,b0,b0,$.c().L(30),b0,b0,B.o,b0,b0,!0,b0,b0,b0,b0,b0,b0,b0,b0),b0,b0,b0),i,f))
return A.zt(b0,A.ag(b0,A.qP(!0,A.cU(B.aQ,A.b([b2,new A.e_(B.bg,b0,b0,A.ag(b0,A.bZ(l,B.p,B.eI,B.t,0,b0),B.j,b0,b0,new A.ar(B.qa,b0,m,n,k,b0,b0,B.u),b0,b0,new A.S(0,0,0,25*s),new A.S(q,p,q,p),b0,b0,r.a.a*0.85),b0)],o),B.D,B.ag),!0),B.j,b0,b0,B.p5,b0,b0,b0,b0,b0,b0,b0),b0)}}
A.aJe.prototype={
$0(){var s=this.a,r=this.b,q=J.aw(r),p=q.h(r,"hasDiscount")
s.as=p==null?!1:p
p=q.h(r,"originalPrice")
p=p==null?null:J.b7(p)
s.at=p==null?"":p
p=q.h(r,"currentPrice")
p=p==null?null:J.b7(p)
s.ax=p==null?"4.99":p
r=q.h(r,"currency")
r=r==null?null:J.b7(r)
s.ay=r==null?"$":r
s.ch=!1},
$S:0}
A.aJf.prototype={
$0(){var s=this.a
s.ax="4.99"
s.ay="$"
s.ch=s.as=!1},
$S:0}
A.aJg.prototype={
$0(){var s=this.a
s.ax="4.99"
s.ay="$"
s.ch=s.as=!1},
$S:0}
A.aJY.prototype={
$1(a){return new A.oI(new A.aJX(this.a),null)},
$S:140}
A.aJX.prototype={
$2(a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=null,c="FFHekaya",b=150*$.c().gq(),a=20*$.c().gp(),a0=$.c().gp(),a1=$.c().gq(),a2=$.c().gp(),a3=$.c().gq(),a4=$.c().gp(),a5=$.c()
a5=A.ay(30*Math.min(a5.gq(),a5.gp()))
s=A.bo(A.U(204,B.S.m()>>>16&255,B.S.m()>>>8&255,B.S.m()&255),3*$.c().gq())
r=A.U(102,B.l.m()>>>16&255,B.l.m()>>>8&255,B.l.m()&255)
q=$.c()
q=Math.min(q.gq(),q.gp())
p=t.V
q=A.b([new A.be(0,B.H,r,new A.h(0,10*$.c().gp()),20*q)],p)
r=A.a6("النسخة الكاملة",d,d,d,d,d,d,d,A.Z(d,d,B.k,d,d,d,d,d,c,d,d,$.c().L(85),d,d,B.o,d,d,!0,d,d,d,d,d,d,d,d),d,d,d)
o=A.aa(d,5*$.c().gp(),d)
n=A.a6(u.y,d,d,d,d,d,d,d,A.Z(d,d,B.bD,d,d,d,d,d,c,d,d,$.c().L(38),d,d,d,d,1.3,!0,d,d,d,d,d,d,d,d),d,d,d)
m=A.aa(d,20*$.c().gp(),d)
l=$.c()
l=15*Math.min(l.gq(),l.gp())
k=A.U(13,B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255)
j=$.c()
j=A.ay(20*Math.min(j.gq(),j.gp()))
i=A.bo(A.U(B.d.T(25.5),B.k.m()>>>16&255,B.k.m()>>>8&255,B.k.m()&255),1)
h=this.a
g=t.p
l=A.bP(A.bf(A.b([r,o,n,m,A.ag(d,A.bf(A.b([h.CZ(u.W),h.CZ("تويستات بلا حدود لزيادة الحماس والمقالب."),h.CZ("تجربة لعب صافية بدون إعلانات مزعجة."),h.CZ("دفع لمرة واحدة وامتلاك مدى الحياة.")],g),B.an,B.r,B.t),B.j,d,d,new A.ar(k,d,i,j,d,d,d,B.u),d,d,d,new A.S(l,l,l,l),d,d,d)],g),B.an,B.r,B.Z),3)
j=A.aa(d,d,40*$.c().gq())
i=$.c()
i=25*Math.min(i.gq(),i.gp())
k=$.c()
k=A.ay(25*Math.min(k.gq(),k.gp()))
m=A.bo(A.U(B.d.T(127.5),B.S.m()>>>16&255,B.S.m()>>>8&255,B.S.m()&255),2*$.c().gq())
n=$.c()
n=Math.min(n.gq(),n.gp())
n=A.b([new A.be(0,B.H,B.cd,new A.h(0,5*$.c().gp()),10*n)],p)
o=A.b([],g)
if(h.as)o.push(A.a6(h.at+" "+h.ay,d,d,d,d,d,d,d,A.Z(d,d,B.fG,d,B.jQ,B.l3,d,2,c,d,d,$.c().L(55),d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d))
r=h.ax
f=h.ay
e=h.as?$.c().L(120):$.c().L(125)
o.push(A.a6(r+" "+f,d,d,d,d,d,d,d,A.Z(d,d,h.as?B.S:B.k,d,d,d,d,d,c,d,d,e,d,d,B.o,d,1.1,!0,d,d,d,d,d,d,d,d),d,d,d))
o.push(A.aa(d,25*$.c().gp(),d))
r=$.c().gp()
f=h.ch?d:new A.aJU(h,a7,a6)
e=$.c()
e=A.hZ(d,d,B.aq,B.dh,d,d,8,d,d,d,d,d,d,d,d,new A.c2(A.ay(20*Math.min(e.gq(),e.gp())),B.y),d,d,d,d,d)
o.push(A.aa(A.jg(h.ch?B.pu:A.bZ(A.b([A.a6("اشتري الآن",d,d,d,d,d,d,d,A.Z(d,d,B.h,d,d,d,d,d,c,d,d,$.c().L(75),d,d,B.o,d,d,!0,d,d,d,d,d,d,d,d),d,d,d)],g),B.p,B.ad,B.t,0,d),f,e),95*r,1/0))
o.push(A.aa(d,15*$.c().gp(),d))
o.push(A.vQ(A.a6("لاحقاً",d,d,d,d,d,d,d,A.Z(d,d,B.ij,d,B.dt,d,d,d,c,d,d,$.c().L(26),d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d),new A.aJV(a6),d))
r=A.b([A.ag(d,A.bf(o,B.p,B.r,B.Z),B.j,d,d,new A.ar(B.h,d,m,k,n,d,d,B.u),d,d,d,new A.S(i,i,i,i),d,d,d)],g)
if(h.as&&!h.ch){o=$.c().gp()
n=$.c().gq()
m=15*$.c().gq()
k=8*$.c().gp()
i=$.c()
i=A.ay(10*Math.min(i.gq(),i.gp()))
f=$.c()
f=Math.min(f.gq(),f.gp())
f=A.b([new A.be(0,B.H,B.bu,new A.h(2*$.c().gq(),2*$.c().gp()),4*f)],p)
r.push(A.eu(d,A.YC(0.2,A.ag(d,A.a6("عرض خاص!",d,d,d,d,d,d,d,A.Z(d,d,B.h,d,d,d,d,d,c,d,d,$.c().L(22),d,d,B.o,d,d,!0,d,d,d,d,d,d,d,d),d,d,d),B.j,d,d,new A.ar(d,d,d,i,f,B.rU,d,B.u),d,d,d,new A.S(m,k,m,k),d,d,d)),d,d,d,-(15*n),-(15*o),d))}a0=A.ag(d,A.bZ(A.b([l,j,A.bP(A.cU(B.aQ,r,B.j,B.ag),2)],g),B.p,B.r,B.t,0,d),B.j,d,d,new A.ar(d,d,s,a5,q,B.rW,d,B.u),d,d,new A.S(0,30*a0,0,0),new A.S(30*a1,30*a2,30*a3,30*a4),d,d,d)
a1=$.c()
a1=18*Math.min(a1.gq(),a1.gp())
a2=A.bo(B.h,4*$.c().gq())
a3=A.U(153,B.S.m()>>>16&255,B.S.m()>>>8&255,B.S.m()&255)
a4=$.c()
a4=Math.min(a4.gq(),a4.gp())
p=A.b([new A.be(0,B.H,a3,new A.h(0,5*$.c().gp()),15*a4)],p)
a1=A.eu(d,A.ag(d,A.bL(B.m8,B.h,d,$.c().L(60)),B.j,d,d,new A.ar(d,d,a2,d,p,B.rV,d,B.ae),d,d,d,new A.S(a1,a1,a1,a1),d,d,d),d,d,d,d,0,d)
p=$.c().gp()
a2=$.c().gq()
return A.DE(A.DA(d,B.B,A.cU(B.c8,A.b([a0,a1,A.eu(15*p,A.b0o(A.bL(B.rt,B.bE,d,$.c().L(24)),A.a6("",d,d,d,d,d,d,d,A.Z(d,d,B.bE,d,B.dt,B.bE,d,d,c,d,d,$.c().L(22),d,d,B.o,d,d,!0,d,d,d,d,d,d,d,d),d,d,d),new A.aJW(h,a7,a6)),d,d,20*a2,d,d,d)],g),B.j,B.ag),d,d,0,new A.S(b,a,b,a),B.hr,d,d,d),B.T)},
$S:266}
A.aJU.prototype={
$0(){var s=0,r=A.t(t.H),q=1,p=[],o=[],n=this,m,l,k,j,i,h,g,f,e
var $async$$0=A.o(function(a,b){if(a===1){p.push(b)
s=q}for(;;)switch(s){case 0:q=3
j=n.a
n.b.$1(new A.aJQ(j))
s=6
return A.n(A.Vv("full_version_id",B.CB),$async$$0)
case 6:m=b
l=A.hT(A.z(m).a,null)==="PurchaseResult"?m.a:m
i=l.gFk().a.h(0,"premium_access")
s=(i==null?null:i.glt())===!0?7:8
break
case 7:j.P(new A.aJR(j))
A.cK(n.c,!1).hK(null)
j.Zk()
i=A.di(u.k,0,null)
h=t.N
g=A.V(["Content-Type","application/json"],h,h)
s=9
return A.n(A.aRt(i,B.aS.va(A.V(["userId",j.a.c],h,h),null),g).iy(new A.aJS()),$async$$0)
case 9:j.uj()
case 8:o.push(5)
s=4
break
case 3:q=2
e=p.pop()
k=A.a7(e)
A.hW().$1("خطأ في الدفع: "+A.j(k))
o.push(5)
s=4
break
case 2:o=[1]
case 4:q=1
n.b.$1(new A.aJT(n.a))
s=o.pop()
break
case 5:return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$$0,r)},
$S:11}
A.aJQ.prototype={
$0(){return this.a.ch=!0},
$S:0}
A.aJR.prototype={
$0(){return this.a.fy=!0},
$S:0}
A.aJS.prototype={
$1(a){return A.hW().$1("DB Update Error: "+A.j(a))},
$S:9}
A.aJT.prototype={
$0(){return this.a.ch=!1},
$S:0}
A.aJV.prototype={
$0(){A.cK(this.a,!1).hK(null)
return null},
$S:0}
A.aJW.prototype={
$0(){var s=0,r=A.t(t.H),q=1,p=[],o=[],n=this,m,l,k,j,i,h,g
var $async$$0=A.o(function(a,b){if(a===1){p.push(b)
s=q}for(;;)switch(s){case 0:q=3
l=n.a
n.b.$1(new A.aJM(l))
s=6
return A.n(A.Vw(),$async$$0)
case 6:m=b
k=m.a.a.h(0,"premium_access")
s=(k==null?null:k.b)===!0?7:9
break
case 7:l.P(new A.aJN(l))
A.cK(n.c,!1).hK(null)
l.Zk()
k=A.di(u.k,0,null)
j=t.N
i=A.V(["Content-Type","application/json"],j,j)
s=10
return A.n(A.aRt(k,B.aS.va(A.V(["userId",l.a.c],j,j),null),i).iy(new A.aJO()),$async$$0)
case 10:l.uj()
s=8
break
case 9:l.Zj("لم يتم العثور على مشتريات سابقة.",!1)
case 8:o.push(5)
s=4
break
case 3:q=2
g=p.pop()
n.a.Zj("حدث خطأ أثناء الاستعادة.",!1)
o.push(5)
s=4
break
case 2:o=[1]
case 4:q=1
n.b.$1(new A.aJP(n.a))
s=o.pop()
break
case 5:return A.q(null,r)
case 1:return A.p(p.at(-1),r)}})
return A.r($async$$0,r)},
$S:11}
A.aJM.prototype={
$0(){return this.a.ch=!0},
$S:0}
A.aJN.prototype={
$0(){return this.a.fy=!0},
$S:0}
A.aJO.prototype={
$1(a){return A.hW().$1("DB Update Error: "+A.j(a))},
$S:9}
A.aJP.prototype={
$0(){return this.a.ch=!1},
$S:0}
A.aK0.prototype={
$1(a){var s=null
return A.DE(A.DA(s,B.B,A.ra(new A.aK_(),s,B.hX,B.qD,new A.aG(0.1,1,t.Y),t.i),s,s,0,s,B.hr,s,s,s),B.T)},
$S:649}
A.aK_.prototype={
$3(a,b,c){var s,r,q,p,o,n,m,l,k,j,i,h,g=null,f="FFHekaya",e=$.c().gq(),d=$.c()
d=30*Math.min(d.gq(),d.gp())
s=$.c()
s=A.ay(30*Math.min(s.gq(),s.gp()))
r=A.bo(B.aq,4*$.c().gq())
q=$.c()
q=Math.min(q.gq(),q.gp())
q=A.b([new A.be(0,B.H,B.kY,new A.h(0,10*$.c().gp()),20*q)],t.V)
p=$.c()
p=20*Math.min(p.gq(),p.gp())
o=A.U(38,B.aq.m()>>>16&255,B.aq.m()>>>8&255,B.aq.m()&255)
p=A.ag(g,A.bL(B.rp,B.aq,g,$.c().L(100)),B.j,g,g,new A.ar(o,g,g,g,g,g,g,B.ae),g,g,g,new A.S(p,p,p,p),g,g,g)
o=A.aa(g,20*$.c().gp(),g)
n=A.a6("تم التفعيل بنجاح!",g,g,g,g,g,g,g,A.Z(g,g,B.aq,g,g,g,g,g,f,g,g,$.c().L(60),g,g,B.o,g,g,!0,g,g,g,g,g,g,g,g),g,g,g)
m=A.aa(g,10*$.c().gp(),g)
l=A.a6("جميع الفئات والتويستات أصبحت مفتوحة لك الآن 🔓",g,g,g,g,g,g,g,A.Z(g,g,B.bD,g,g,g,g,g,f,g,g,$.c().L(35),g,g,g,g,1.3,!0,g,g,g,g,g,g,g,g),B.N,g,g)
k=A.aa(g,35*$.c().gp(),g)
j=$.c()
j=A.ay(15*Math.min(j.gq(),j.gp()))
i=50*$.c().gq()
h=15*$.c().gp()
j=A.hZ(g,g,B.k,g,g,g,5,g,g,g,g,g,g,new A.S(i,h,i,h),g,new A.c2(j,B.y),g,g,g,g,g)
return A.Am(A.ag(g,A.bf(A.b([p,o,n,m,l,k,A.jg(A.a6("هيا نلعب",g,g,g,g,g,g,g,A.Z(g,g,B.h,g,g,g,g,g,f,g,g,$.c().L(40),g,g,B.o,g,g,!0,g,g,g,g,g,g,g,g),g,g,g),new A.aJZ(a),j)],t.p),B.p,B.r,B.Z),B.j,g,g,new A.ar(B.h,g,r,s,q,g,g,B.u),g,g,g,new A.S(d,d,d,d),g,g,500*e),b)},
$S:61}
A.aJZ.prototype={
$0(){A.cK(this.a,!1).hK(null)
return null},
$S:0}
A.aJy.prototype={
$1(a){var s=this.a
if(s.c!=null)s.P(new A.aJx(s,a))
s.m1()},
$S:3}
A.aJx.prototype={
$0(){var s=this.a,r=this.b,q=J.aw(r)
s.z=q.h(r,"roomCode")
s.CW=q.h(r,"players")
s.x=s.y=!0},
$S:0}
A.aJz.prototype={
$1(a){var s=this.a
if(s.c!=null)s.P(new A.aJw(s,a))
s.m1()},
$S:3}
A.aJw.prototype={
$0(){var s=this.a,r=this.b,q=J.aw(r)
s.z=q.h(r,"roomCode")
s.CW=q.h(r,"players")
s.y=!1
s.x=!0},
$S:0}
A.aJA.prototype={
$1(a){var s=this.a
if(s.c!=null)s.P(new A.aJv(s,a))},
$S:3}
A.aJv.prototype={
$0(){var s=this.a,r=this.b,q=J.aw(r),p=q.h(r,"players")
s.CW=p==null?[]:p
if(!s.y&&q.h(r,"teams")!=null){r=J.j5(t.j.a(q.h(r,"teams")),new A.aJq(),t.v4)
r=A.a0(r,r.$ti.i("ao.E"))
s.cx=r}},
$S:0}
A.aJq.prototype={
$1(a){var s,r,q=a.h(0,"id"),p=a.h(0,"name"),o=a.h(0,"color")
o=A.aJ(o==null?B.eK.m():o)
s=a.h(0,"avatarPath")
if(s==null)s="assets/players/blue.png"
r=a.h(0,"members")
if(r==null)r=[]
return new A.fW(q,p,o,s,A.fd(r,!0,t.z))},
$S:650}
A.aJE.prototype={
$1(a){var s,r=this.a
if(r.c!=null){s=J.av(a,"message")
r.qI(s==null?"خطأ في الانضمام":s)}},
$S:3}
A.aJF.prototype={
$1(a){var s,r=this.a
if(r.c!=null){r.Q=!0
r.VE()
s=r.c
s.toString
A.aTP(s,A.hg(new A.aJu(r,a),null,t.z))}},
$S:3}
A.aJu.prototype={
$1(a){var s,r=this.a,q=r.y,p=r.a,o=p.c
p=p.d
s=J.av(this.b,"roomCode")
return A.aYR(r.p4,r.k4,r.ok,r.p3,null,!1,r.p1,q,s,o,p)},
$S:265}
A.aJG.prototype={
$1(a){var s,r=this.a
if(r.c!=null){s=J.av(a,"message")
r.qI(s==null?"تم إنهاء الجلسة من قبل المضيف":s)
r.P(new A.aJt(r))}},
$S:3}
A.aJt.prototype={
$0(){var s=this.a
s.w=s.x=!1
B.b.R(s.cx)},
$S:0}
A.aJH.prototype={
$1(a){var s,r=this.a
if(r.c!=null){s=J.av(a,"message")
r.qI(s==null?"انقطع اتصال الهاتف المضيف":s)
r.P(new A.aJs(r))}},
$S:3}
A.aJs.prototype={
$0(){var s=this.a
s.w=s.x=!1
B.b.R(s.cx)},
$S:0}
A.aJI.prototype={
$1(a){var s,r=this.a
if(r.c!=null){s=J.aw(a)
r.k3.E(0,J.b7(s.h(a,"peerId")))
r.oG(s.h(a,"peerId"))}},
$S:3}
A.aJJ.prototype={
$1(a){var s,r,q,p,o,n=this.a
if(n.c!=null){s=J.av(a,"peers")
for(r=J.bh(s==null?[]:s),q=n.k3;r.B();){p=r.gN()
o=J.jQ(p)
q.E(0,o.j(p))
n.oG(o.j(p))}}},
$S:3}
A.aJK.prototype={
$1(a){var s,r,q=this.a
if(q.c!=null){s=J.av(a,"peerId")
if(s!=null){q.k3.G(0,s)
q=q.ok
r=q.h(0,s)
if(r!=null)r.ar()
q.G(0,s)}}},
$S:3}
A.aJL.prototype={
$1(a){var s=J.aw(a)
return this.a.oH(s.h(a,"from"),s.h(a,"offer"))},
$S:87}
A.aJB.prototype={
$1(a){var s=J.aw(a)
return this.a.Cy(s.h(a,"from"),s.h(a,"answer"))},
$S:87}
A.aJC.prototype={
$1(a){var s=J.aw(a)
return this.a.xC(s.h(a,"from"),s.h(a,"candidate"))},
$S:87}
A.aJD.prototype={
$1(a){var s=this.a
if(s.c!=null)s.P(new A.aJr(s,a))},
$S:3}
A.aJr.prototype={
$0(){var s=J.av(this.b,"categories")
if(s==null)s=[]
this.a.fr=A.fd(s,!0,t.N)},
$S:0}
A.aKx.prototype={
$1(a){return a.dG()},
$S:51}
A.aKy.prototype={
$2(a,b){return b.ar()},
$S:93}
A.aJj.prototype={
$0(){this.a.go=!0},
$S:0}
A.aJk.prototype={
$0(){var s=this.a
s.p2=!0
s.go=!1},
$S:0}
A.aJl.prototype={
$0(){this.a.go=!1},
$S:0}
A.aK4.prototype={
$1(a){return this.a9n(a)},
a9n(a){var s=0,r=A.t(t.H),q,p=this,o,n,m,l,k,j,i,h,g,f,e
var $async$$1=A.o(function(b,c){if(b===1)return A.p(c,r)
for(;;)switch(s){case 0:e=p.a
if(!e.p2||e.k4==null){s=1
break}o=e.k3
o=A.a0(o,A.m(o).c)
n=o.length
m=e.ok
l=0
case 3:if(!(l<o.length)){s=5
break}k=o[l]
j=m.h(0,k)
s=j==null?6:8
break
case 6:i=!0
s=7
break
case 8:s=9
return A.n(j.wg(),$async$$1)
case 9:h=c
i=h===B.hl||h===B.hm||h===B.eZ
case 7:if(i){g="🔄 Watchdog Lobby: انقطاع مع "+k+"، جاري الإصلاح..."
f=$.a8L
if(f==null)A.a8K(g)
else f.$1(g)
e.oG(k)}case 4:o.length===n||(0,A.A)(o),++l
s=3
break
case 5:case 1:return A.q(q,r)}})
return A.r($async$$1,r)},
$S:109}
A.aK3.prototype={
$1(a){return this.a9m(a)},
a9m(a){var s=0,r=A.t(t.H),q,p=2,o=[],n=this,m,l,k,j,i,h,g,f
var $async$$1=A.o(function(b,c){if(b===1){o.push(c)
s=p}for(;;)switch(s){case 0:g=n.a
if(g.p1||g.k4==null||g.ok.a===0){if(g.c!=null&&g.id>0.01)g.P(new A.aK1(g))
s=1
break}p=4
j={}
i=g.ok
m=new A.bp(i,A.m(i).i("bp<2>")).gY(0)
s=7
return A.n(m.wr(),$async$$1)
case 7:l=c
j.a=0
for(i=J.bh(l);i.B();){k=i.gN()
if(k.b==="media-source"&&k.d.ad("audioLevel")){j.a=A.kH(J.b7(k.d.h(0,"audioLevel")))
break}}if(g.c!=null)g.P(new A.aK2(j,g))
p=2
s=6
break
case 4:p=3
f=o.pop()
s=6
break
case 3:s=2
break
case 6:case 1:return A.q(q,r)
case 2:return A.p(o.at(-1),r)}})
return A.r($async$$1,r)},
$S:109}
A.aK1.prototype={
$0(){var s=this.a
return s.id=Math.max(0,s.id-0.1)},
$S:0}
A.aK2.prototype={
$0(){var s=B.d.c6(Math.sqrt(this.a.a)*1.8,0,1),r=this.b
r.id=r.id*0.2+s*0.8},
$S:0}
A.aJ8.prototype={
$1(a){var s=this.a.k4
s.toString
return this.b.E8(a,s)},
$S:51}
A.aJ9.prototype={
$1(a){var s=A.V(["to",this.b,"candidate",a.AH()],t.N,t.z),r=this.a.r.a
r===$&&A.a()
r.c7("webrtc_ice_candidate",s)},
$S:128}
A.aJa.prototype={
$1(a){if(a.c.d.kind==="audio"&&a.b.length!==0)this.a.p3.push(a.b[0])},
$S:129}
A.aJh.prototype={
$0(){return A.b([],t.Wy)},
$S:100}
A.aJi.prototype={
$0(){return A.b([],t.Wy)},
$S:100}
A.aK7.prototype={
$0(){var s=this.a
return s.p1=!s.p1},
$S:0}
A.aK8.prototype={
$1(a){var s=!this.a.p1
a.sll(s)
return s},
$S:51}
A.aJm.prototype={
$1(a){return B.dY},
$S:53}
A.aJn.prototype={
$1(a){return!1},
$S:30}
A.aJb.prototype={
$0(){var s=this.a
s.dy=this.b
s.fy=s.fy||this.c
s.fx=!1},
$S:0}
A.aJc.prototype={
$0(){return this.a.fx=!1},
$S:0}
A.aJd.prototype={
$0(){return this.a.fx=!1},
$S:0}
A.aK6.prototype={
$0(){var s,r=this.a,q=this.b
if(B.b.D(r.fr,q))B.b.G(r.fr,q)
else{s=r.fr
if(s.length<6)s.push(q)
else r.qI("يمكنك اختيار 6 فئات فقط")}},
$S:0}
A.aK5.prototype={
$1(a){return a.fh()},
$S:272}
A.aKb.prototype={
$1(a){return a.fh()},
$S:272}
A.aJ0.prototype={
$1(a){return a.c},
$S:652}
A.aJ_.prototype={
$1(a){return!this.a.D(0,a)},
$S:267}
A.aJ1.prototype={
$0(){var s=this.b,r=s.f
B.b.E(s.cx,new A.fW("team_"+Date.now(),B.c.d1(r.a.a),B.b.gY(this.a.a),s.db,[]))
r.qn(B.E2)},
$S:0}
A.aJp.prototype={
$0(){return B.b.fg(this.a.cx,new A.aJo(this.b))},
$S:0}
A.aJo.prototype={
$1(a){return a.a===this.a},
$S:273}
A.aJ4.prototype={
$0(){var s,r,q,p,o,n
for(s=this.a,r=s.cx,q=r.length,p=this.b,o=0;o<r.length;r.length===q||(0,A.A)(r),++o){n=r[o].e
n.$flags&1&&A.X(n,16)
B.b.y9(n,new A.aJ2(p),!0)}B.b.vr(s.cx,new A.aJ3(this.c)).e.push(p)},
$S:0}
A.aJ2.prototype={
$1(a){return J.d(J.av(a,"id"),this.a.h(0,"id"))},
$S:92}
A.aJ3.prototype={
$1(a){return a.a===this.a},
$S:273}
A.aKa.prototype={
$0(){var s,r,q,p,o
for(s=this.a.cx,r=s.length,q=this.b,p=0;p<s.length;s.length===r||(0,A.A)(s),++p){o=s[p].e
o.$flags&1&&A.X(o,16)
B.b.y9(o,new A.aK9(q),!0)}},
$S:0}
A.aK9.prototype={
$1(a){return J.d(J.av(a,"id"),this.a)},
$S:92}
A.aJ7.prototype={
$0(){var s=this.a
if(this.b)s.Zi()
else s.atm(this.c)},
$S:0}
A.aJ6.prototype={
$2(a,b){var s=null,r=A.U(153,B.h.m()>>>16&255,B.h.m()>>>8&255,B.h.m()&255)
return A.aUe(B.cs,A.ag(s,s,B.j,B.cs,s,s,s,s,s,s,s,s,s),r)},
$S:137}
A.aJ5.prototype={
$3(a,b,c){return A.bL(B.fU,B.dk,null,$.c().L(24))},
$S:268}
A.aKo.prototype={
$1(a){var s,r,q
for(s=this.a.cx,r=s.length,q=0;q<s.length;s.length===r||(0,A.A)(s),++q)if(B.b.iv(s[q].e,new A.aKn(a)))return!1
return!0},
$S:92}
A.aKn.prototype={
$1(a){return J.d(J.av(a,"id"),J.av(this.a,"id"))},
$S:92}
A.aKp.prototype={
$2(a,b){var s,r=null,q=this.a,p=5*$.c().gq(),o=q.cy,n=q.db===o[b]?B.bk:B.B
n=A.bo(n,3*$.c().gq())
s=$.c()
s=Math.min(s.gq(),s.gp())
return A.fA(r,A.ag(r,A.xg(r,new A.kP(o[b],r,r),r,50*s),B.j,r,r,new A.ar(r,r,n,r,r,r,r,B.ae),r,r,new A.S(p,0,p,0),r,r,r,r),B.a8,!1,r,r,r,r,r,r,r,r,r,r,r,r,r,r,new A.aKm(q,b),r,r,r,r,r,r)},
$S:269}
A.aKm.prototype={
$0(){var s=this.a
return s.P(new A.aKf(s,this.b))},
$S:0}
A.aKf.prototype={
$0(){var s=this.a
return s.db=s.cy[this.b]},
$S:0}
A.aKq.prototype={
$1(a){var s=this.a
return A.aYn(new A.aKk(s,a),new A.aKl(s,a),t.a)},
$S:655}
A.aKl.prototype={
$1(a){return this.a.ahk(a,this.b.a)},
$S:108}
A.aKk.prototype={
$3(a,b,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=null,e="FFHekaya",d=$.c().gq(),c=$.c()
c=15*Math.min(c.gq(),c.gp())
s=b.length!==0?this.b.c.by(0.3):B.h
r=this.b
q=r.c
p=A.bo(q,3*$.c().gq())
o=$.c()
o=A.ay(15*Math.min(o.gq(),o.gp()))
n=$.c()
n=A.b([new A.be(0,B.H,B.cd,B.i,5*Math.min(n.gq(),n.gp()))],t.V)
m=$.c()
l=t.p
q=A.b([A.xg(f,new A.kP(r.d,f,f),f,25*Math.min(m.gq(),m.gp())),A.aa(f,f,10*$.c().gq()),A.bP(A.a6(r.b,f,f,f,f,f,f,f,A.Z(f,f,q,f,f,f,f,f,e,f,f,$.c().L(35),f,f,B.o,f,f,!0,f,f,f,f,f,f,f,f),f,f,f),1)],l)
m=this.a
if(m.y)q.push(A.ahP(f,f,A.bL(B.rm,B.cD,f,$.c().L(28)),f,f,new A.aKd(m,r),f,f,f))
q=A.bZ(q,B.p,B.r,B.t,0,f)
k=A.ad9(f,f,f)
j=$.c().gq()
i=$.c().gp()
h=r.e
if(h.length===0)r=A.b([A.a6("اسحب اللاعبين هنا",f,f,f,f,f,f,f,A.Z(f,f,B.dk,f,f,f,f,f,e,f,f,$.c().L(24),f,f,f,f,f,!0,f,f,f,f,f,f,f,f),f,f,f)],l)
else{g=A.a2(h).i("a4<1,tj>")
r=A.a0(new A.a4(h,new A.aKe(m,r),g),g.i("ao.E"))}return A.kN(A.bf(A.b([q,k,A.JU(B.dw,r,8*i,8*j)],l),B.p,B.r,B.t),f,B.O,new A.ar(s,f,p,o,n,f,f,B.u),B.aa,f,f,f,new A.S(c,c,c,c),350*d)},
$S:656}
A.aKd.prototype={
$0(){return this.a.atl(this.b.a)},
$S:0}
A.aKe.prototype={
$1(a){var s=null,r=A.a6(J.av(a,"name"),s,s,s,s,s,s,s,A.Z(s,s,s,s,s,s,s,s,"FFHekaya",s,s,$.c().L(24),s,s,B.o,s,s,!0,s,s,s,s,s,s,s,s),s,s,s),q=this.b.c.by(0.1),p=this.a,o=p.y?A.bL(B.rk,B.ak,s,$.c().L(20)):s
return A.aXA(s,q,o,s,r,p.y?new A.aKc(p,a):s,s)},
$S:657}
A.aKc.prototype={
$0(){return this.a.a1_(J.av(this.b,"id"))},
$S:0}
A.aKs.prototype={
$1(a){return this.a.a1_(a.h(0,"id"))},
$S:108}
A.aKr.prototype={
$3(a,b,c){var s,r,q,p,o,n,m,l=null,k=$.c().gp(),j=$.c()
j=10*Math.min(j.gq(),j.gp())
s=A.U(B.d.T(127.5),B.h.m()>>>16&255,B.h.m()>>>8&255,B.h.m()&255)
r=$.c()
r=A.ay(15*Math.min(r.gq(),r.gp()))
q=b.length!==0?B.cD:B.B
q=A.bo(q,2*$.c().gq())
p=this.b
if(p.length===0)p=A.cc(A.a6("لا يوجد لاعبين غير معينين",l,l,l,l,l,l,l,A.Z(l,l,B.dk,l,l,l,l,l,"FFHekaya",l,l,$.c().L(28),l,l,l,l,l,!0,l,l,l,l,l,l,l,l),l,l,l),l,l)
else{o=$.c().gq()
n=$.c().gp()
m=A.a2(p).i("a4<1,k>")
p=A.a0(new A.a4(p,new A.aKj(this.a),m),m.i("ao.E"))
p=A.JU(B.dw,p,10*n,10*o)}return A.ag(l,p,B.j,l,new A.al(0,1/0,300*k,1/0),new A.ar(s,l,q,r,l,l,l,B.u),l,l,l,new A.S(j,j,j,j),l,l,1/0)},
$S:658}
A.aKj.prototype={
$1(a){return this.a.ahz(a)},
$S:261}
A.aKt.prototype={
$2(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g=null,f=this.a,e=f.dy,d=new A.aR(e,A.m(e).i("aR<1>")).de(0,b)
e=f.dy.h(0,d)
e.toString
s=$.c().gp()
r=$.c().gq()
q=$.c().gq()
p=$.c().gp()
o=$.c().gp()
n=$.c().gq()
m=$.c().gq()
l=$.c()
l=A.ay(20*Math.min(l.gq(),l.gp()))
k=A.U(B.d.T(127.5),B.S.m()>>>16&255,B.S.m()>>>8&255,B.S.m()&255)
j=$.c().gq()
i=$.c()
i=A.ay(20*Math.min(i.gq(),i.gp()))
h=10*$.c().gq()
h=A.ua(g,new A.e2(4,i,B.hR),g,new A.S(10*n,50*p,10*m,20*o),g,g,g,g,!0,new A.e2(4,l,new A.aW(k,2*j,B.z,-1)),g,g,g,g,g,g,g,B.r5,B.eD,g,g,g,g,g,g,g,g,g,g,g,g,g,g,g,g,g,g,g,A.ag(g,A.a6(d,g,g,g,g,g,g,g,A.Z(g,g,B.S,g,g,g,g,g,"FFHekaya",g,g,$.c().L(40),g,g,B.o,g,g,!0,g,g,g,g,g,g,g,g),g,g,g),B.j,B.ap,g,g,g,g,g,new A.S(h,0,h,0),g,g,g),g,g,!0,!0,!1,g,g,g,g,g,g,g,g,g,g,g,g,g,g)
j=$.c().gq()
return new A.bi(new A.S(5*r,0,5*q,30*s),A.aTs(g,A.aTj(new A.zM(6,10*$.c().gp(),10*j,0.8),new A.aKi(f,e),e.length,B.jc,!0),h,!1,!1,!1,!1,B.N,g),g)},
$S:270}
A.aKi.prototype={
$2(a,b){return this.a.ati(this.b[b])},
$S:88}
A.aKu.prototype={
$0(){var s=this.a
return s.P(new A.aKh(s))},
$S:0}
A.aKh.prototype={
$0(){return this.a.w=!0},
$S:0}
A.aKv.prototype={
$0(){var s=this.a
return s.P(new A.aKg(s))},
$S:0}
A.aKg.prototype={
$0(){return this.a.w=!1},
$S:0}
A.aKw.prototype={
$0(){A.cK(this.a,!1).hK(null)
return null},
$S:0}
A.auG.prototype={
aGA(){var s=this,r=A.aVl("https://api.3krooot.com",A.V(["transports",A.b(["websocket"],t.s),"autoConnect",!1],t.N,t.z))
s.a=r
r.z_()
s.a.bD("connect",new A.auH())
s.a.bD("disconnect",new A.auI())
s.a.bD("connect_error",new A.auJ())}}
A.auH.prototype={
$1(a){A.en("✅ Socket Connected to https://api.3krooot.com")},
$S:3}
A.auI.prototype={
$1(a){A.en("❌ Socket Disconnected")},
$S:3}
A.auJ.prototype={
$1(a){return A.en("Socket Error: "+A.j(a))},
$S:9}
A.uj.prototype={
k(a,b){if(b==null)return!1
return b instanceof A.uj&&this.b===b.b},
iW(a,b){return B.f.iW(this.b,b.gt())},
kX(a,b){return B.f.kX(this.b,b.gt())},
jr(a,b){return B.f.jr(this.b,b.gt())},
k5(a,b){return this.b>=b.b},
b9(a,b){return this.b-b.b},
gv(a){return this.b},
j(a){return this.a},
$icd:1,
gaQ(){return this.a}}
A.ajt.prototype={
j(a){return"["+this.a.a+"] "+this.d+": "+this.b}}
A.yy.prototype={
ga54(){var s=this.b,r=s==null?null:s.a.length!==0,q=this.a
return r===!0?s.ga54()+"."+q:q},
gQ2(){var s,r
if(this.b==null){s=this.c
s.toString
r=s}else{s=$.aWp().c
s.toString
r=s}return r},
aY(a,b,c,d){var s,r=this,q=a.b
if(q>=r.gQ2().b){if(q>=2000){A.Y_()
if(c==null)a.j(0)}q=r.ga54()
Date.now()
$.aZK=$.aZK+1
s=new A.ajt(a,b,q)
if(r.b==null)r.ZT(s)
else $.aWp().ZT(s)}},
ZT(a){return null},
gaQ(){return this.a}}
A.aju.prototype={
$0(){var s,r,q,p=this.a
if(B.c.b7(p,"."))A.a1(A.bv("name shouldn't start with a '.'",null))
if(B.c.fW(p,"."))A.a1(A.bv("name shouldn't end with a '.'",null))
s=B.c.rO(p,".")
if(s===-1)r=p!==""?A.mq(""):null
else{r=A.mq(B.c.W(p,0,s))
p=B.c.bG(p,s+1)}q=new A.yy(p,r,A.v(t.N,t.JW))
if(r==null)q.c=B.Qf
else r.d.n(0,p,q)
return q},
$S:659}
A.x2.prototype={
Ud(a,b,c,d,e,f,g,h,a0){var s,r,q,p,o,n,m,l,k,j=this,i=j.r
i.d=c
i.e=f
i.ax=g
i=j.d
s=j.x
i.bu(s)
r=j.w
i.bu(r)
for(q=j.y,p=0;p<q.length;++p)i.bu(q[p])
o=j.z
n=o!=null
if(n)i.bu(o)
m=j.gAh()
s.a.push(m)
r.a.push(m)
for(p=0;p<e.length;++p)q[p].a.push(m)
if(n)o.a.push(m)
l=i.gyM()
if(l!=null){s=l.a
r=A.b([],t.u)
s=new A.cg(r,A.bl(s.a,t.i))
r.push(m)
j.as=s
i.bu(s)}k=i.gzl()
if(k!=null)j.ax=A.aT0(m,i,k)},
aJg(){this.c.r=!0},
iX(a,b){var s,r,q,p,o,n,m,l
for(s=a.length-1,r=null;s>=0;--s){q=a[s]
if(q instanceof A.ku&&q.d===B.nf)r=q}if(r!=null)r.c.push(this.gAh())
for(s=b.length-1,p=t.rM,o=t.KJ,n=this.gAh(),m=this.e,l=null;s>=0;--s){q=b[s]
if(q instanceof A.ku&&q.d===B.nf){if(l!=null)m.push(l)
l=new A.LV(A.b([],o),q)
q.c.push(n)}else if(p.b(q)){if(l==null)l=new A.LV(A.b([],o),r)
l.a.push(q)}}if(l!=null)m.push(l)},
jc(a1,a2,a3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=this,b="StrokeContent#draw",a="StrokeContent#buildPath",a0="StrokeContent#drawPath"
A.et(b)
s=new Float64Array(3)
r=new A.ek(s)
r.iY(0,0,0)
r.Eh(a2)
q=new Float64Array(3)
p=new A.ek(q)
p.iY(37394.729378,39575.2343807,0)
p.Eh(a2)
if(s[0]===q[0]||s[1]===q[1]){A.cZ(b)
return}s=c.r
q=B.f.c6(B.d.T(a3/255*c.x.gt()/100*255),0,255)
o=A.aJ(s.r)
s.r=A.U(q,o.m()>>>16&255,o.m()>>>8&255,o.m()&255).gt()
o=c.w.gt()*A.aTG(a2)
s.c=o
if(o<=0){A.cZ(b)
return}n=c.as
if(n!=null){m=n.gt()
if(m===0)s.z=null
else if(m!==c.at)s.z=c.d.Hz(m)
c.at=m}for(q=c.e,o=c.a,l=a2.a,k=o.e,j=0;j<q.length;++j){i=q[j]
if(i.b!=null)c.ahh(a1,i,a2)
else{A.et(a)
o.cO()
for(h=i.a,g=h.length-1;g>=0;--g){f=new A.fq(h[g].cm(),B.i,l)
k.push(f)
e=o.d
if(e!=null)f.ck(e)}A.cZ(a)
A.et(a0)
d=c.ax
if(d!=null)d.nD(a1,o)
a1.dn(c.DQ(o,a2),s)
A.cZ(a0)}}A.cZ(b)},
ahh(a8,a9,b0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6=this,a7="StrokeContent#applyTrimPath"
A.et(a7)
s=a9.b
if(s==null){A.cZ(a7)
return}r=a6.a
r.cO()
for(q=a9.a,p=q.length-1,o=b0.a,n=r.e;p>=0;--p){m=new A.fq(q[p].cm(),B.i,o)
n.push(m)
l=r.d
if(l!=null)m.ck(l)}k=s.e.gt()/100
j=s.f.gt()/100
n=s.r.gt()
if(k<0.01&&j>0.99){a8.dn(r,a6.r)
A.cZ(a7)
return}m=t.sp
l=t.EX.i("E.E")
i=A.a0(new A.o1(new A.o0(r,!1,A.b([],m))),l)
h=B.b.rA(i,0,new A.aaf())
g=h*(n/360)
f=h*k+g
e=Math.min(h*j+g,f+h-1)
for(p=q.length-1,r=a6.b,n=a6.r,d=e>h,c=r.e,b=e-h,a=f>h,a0=f-h,a1=0;p>=0;--p){a2=A.aTA(q[p].cm(),o)
r.cO()
a2=new A.fq(a2,B.i,null)
c.push(a2)
a3=r.d
if(a3!=null)a2.ck(a3)
i=A.a0(new A.o1(new A.o0(r,!1,A.b([],m))),l)
if(i.length!==0){a2=B.b.gY(i)
a4=a2.gF(a2)}else a4=0
if(d&&b<a1+a4&&a1<b){a5=a?a0/a4:0
A.aUy(r,a5,Math.min(b/a4,1),0)
a8.dn(a6.DQ(r,b0),n)}else{a2=a1+a4
if(!(a2<f||a1>e))if(a2<=e&&f<a1)a8.dn(a6.DQ(r,b0),n)
else{a5=f<a1?0:(f-a1)/a4
A.aUy(r,a5,e>a2?1:(e-a1)/a4,0)
a8.dn(a6.DQ(r,b0),n)}}a1+=a4}A.cZ(a7)},
h3(a,b){var s,r,q,p,o,n,m,l,k,j,i="StrokeContent#getBounds"
A.et(i)
s=this.a
s.cO()
for(r=this.e,q=a.a,p=s.e,o=0;o<r.length;++o)for(n=r[o].a,m=0;m<n.length;++m){l=new A.fq(n[m].cm(),B.i,q)
p.push(l)
k=s.d
if(k!=null)l.ck(k)}s=s.geG().a
s===$&&A.a()
j=A.rR(s.a.getBounds()).cs(this.w.gt()/2).cs(1)
A.cZ(i)
return j},
DQ(a,b){var s,r,q,p,o,n,m,l="StrokeContent#applyDashPattern"
A.et(l)
s=this.y
if(s.length===0){A.cZ(l)
return a}r=A.aTG(b)
for(q=this.f,p=0;p<s.length;++p){o=s[p].gt()
q[p]=o
if(B.f.bb(p,2)===0){if(o<1){q[p]=1
o=1}}else if(o<0.1){q[p]=0.1
o=0.1}q[p]=o*r}s=this.z
if(s==null)n=0
else n=s.gt()*r
m=A.bmI(a,q,n)
A.cZ(l)
return m},
$icW:1,
$ifx:1}
A.Q3.prototype={
$1(a){return new A.cg(A.b([],t.u),A.bl(a.a,t.i))},
$S:660}
A.aaf.prototype={
$2(a,b){return a+b.gF(b)},
$S:661}
A.LV.prototype={}
A.xz.prototype={
ck(a){var s,r
for(s=this.a,r=s.length-1;r>=0;--r)A.bhu(a,s[r])}}
A.pE.prototype={
Uf(a,b,c,d,e,f){var s,r,q,p,o
if(e!=null){s=A.w2(e)
s.a2e(b)
s.a_(this.grX())
this.x=s}r=A.b([],t.oJ)
for(s=this.f,q=s.length-1,p=t.xB;q>=0;--q){o=s[q]
if(p.b(o))r.push(o)}for(q=r.length-1;q>=0;--q)r[q].azi(s)},
Ai(){this.r.r=!0},
iX(a,b){var s,r,q,p=A.b([],t.kQ)
B.b.I(p,a)
for(s=this.f,r=s.length-1;r>=0;--r){q=s[r]
q.iX(p,B.b.cj(s,0,r))
p.push(q)}},
cm(){var s,r,q,p,o,n,m,l,k=this,j=k.b
j.bq()
s=k.x
if(s!=null)s.n0().r7(j)
s=k.c
s.cO()
if(k.e)return s
for(r=k.f,q=r.length-1,p=t.rM,j=j.a,o=s.e;q>=0;--q){n=r[q]
if(p.b(n)){m=new A.fq(n.cm(),B.i,j)
o.push(m)
l=s.d
if(l!=null)m.ck(l)}}return s},
jc(a,b,c){var s,r,q,p,o,n,m=this
if(m.e)return
s=m.b
b.r7(s)
r=m.x
if(r!=null){s.cU(r.n0())
r=m.x
q=B.d.T(((r==null?null:r.z)==null?100:r.z.gt())/100*c/255*255)}else q=c
for(r=m.f,p=r.length-1,o=t.R7;p>=0;--p){n=r[p]
if(o.b(n))n.jc(a,s,q)}},
h3(a,b){var s,r,q,p,o,n=this.b
a.r7(n)
s=this.x
if(s!=null)n.cU(s.n0())
for(s=this.f,r=s.length-1,q=t.R7,p=B.P;r>=0;--r){o=s[r]
if(q.b(o))p=p.fX(o.h3(n,b))}return p},
$icW:1,
$ifx:1,
$ijz:1,
gaQ(){return this.d}}
A.DX.prototype={
rL(){this.w=!1
this.c.r=!0},
iX(a,b){var s,r,q,p
for(s=this.r.a,r=this.gmz(),q=0;q<a.length;++q){p=a[q]
if(p instanceof A.ku&&p.d===B.f3){s.push(p)
p.c.push(r)}}},
cm(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=this
if(f.w)return f.a
s=f.a
s.cO()
r=f.f
if(r.e){f.w=!0
return s}q=f.d.gt()
p=q.a/2
o=q.b/2
n=p*0.55228
m=o*0.55228
s.cO()
l=-o
k=0-n
j=-p
i=0-m
h=0+m
g=0+n
if(r.d){s.ab(new A.dC(0,l))
s.ab(new A.fV(k,l,j,i,j,0))
s.ab(new A.fV(j,h,k,o,0,o))
s.ab(new A.fV(g,o,p,h,p,0))
s.ab(new A.fV(p,i,g,l,0,l))}else{s.ab(new A.dC(0,l))
s.ab(new A.fV(g,l,p,i,p,0))
s.ab(new A.fV(p,h,g,o,0,o))
s.ab(new A.fV(k,o,j,h,j,0))
s.ab(new A.fV(j,i,k,l,0,l))}r=A.Fh(s,f.e.gt())
s.cO()
s.ab(new A.fq(r,B.i,null))
s.ab(new A.is())
f.r.ck(s)
f.w=!0
return s},
$icW:1,
$ijz:1,
gaQ(){return this.b}}
A.Ec.prototype={
afY(a,b,c){var s,r,q,p,o,n=this,m=n.b,l=m.gyM()
if(l!=null){s=l.a
r=A.b([],t.u)
s=new A.cg(r,A.bl(s.a,t.i))
r.push(n.grX())
n.y=s
m.bu(s)}q=m.gzl()
if(q!=null)n.Q=A.aT0(n.grX(),m,q)
s=c.d
if(s==null)return
n.a.spo(c.b)
s=s.a
r=t.u
p=A.b([],r)
s=new A.np(p,A.bl(s,t.G))
n.f!==$&&A.b0()
n.f=s
o=n.grX()
p.push(o)
m.bu(s)
r=A.b([],r)
s=new A.mm(r,A.bl(c.e.a,t.S))
n.r!==$&&A.b0()
n.r=s
r.push(o)
m.bu(s)},
Ai(){this.x.r=!0},
iX(a,b){var s,r,q,p
for(s=t.rM,r=this.e,q=0;q<b.length;++q){p=b[q]
if(s.b(p))r.push(p)}},
jc(a,b,c){var s,r,q,p,o,n,m,l,k,j,i=this,h="FillContent#draw"
if(i.d)return
A.et(h)
$.a_()
s=A.as()
r=i.f
r===$&&A.a()
