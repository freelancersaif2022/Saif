(()=>{var ud=0,nh=1,dd=2;var no=1,Ba=2,qi=3,bi=0,qe=1,Fe=2,ln=0,Ui=1,ke=2,sh=3,rh=4,fd=5,wn=100,pd=101,md=102,gd=103,xd=104,_d=200,yd=201,vd=202,Md=203,la=204,ca=205,bd=206,wd=207,Sd=208,Ed=209,Td=210,Ad=211,Rd=212,Cd=213,Id=214,Oa=0,za=1,Ha=2,Vn=3,Va=4,Ga=5,Wa=6,Xa=7,qa=0,Pd=1,Ld=2,cn=0,Dd=1,Ud=2,Nd=3,Ya=4,Fd=5,kd=6,Bd=7,Wc="attached",Od="detached",oh=300,jn=301,Qn=302,Za=303,$a=304,so=306,Ts=1e3,bn=1001,ha=1002,li=1003,zd=1004;var ro=1005;var Ni=1006,Ja=1007;var Rn=1008;var ki=1009,ah=1010,lh=1011,zs=1012,Ka=1013,Cn=1014,Si=1015,Hs=1016,ja=1017,Qa=1018,Vs=1020,ch=35902,hh=35899,uh=1021,dh=1022,gi=1023,As=1026,Gs=1027,tl=1028,el=1029,fh=1030,il=1031;var nl=1033,oo=33776,ao=33777,lo=33778,co=33779,sl=35840,rl=35841,ol=35842,al=35843,ll=36196,cl=37492,hl=37496,ul=37808,dl=37809,fl=37810,pl=37811,ml=37812,gl=37813,xl=37814,_l=37815,yl=37816,vl=37817,Ml=37818,bl=37819,wl=37820,Sl=37821,El=36492,Tl=36494,Al=36495,Rl=36283,Cl=36284,Il=36285,Pl=36286;var Mr=2300,ua=2301,aa=2302,Xc=2400,qc=2401,Yc=2402;var Hd=3200,Vd=3201;var Ll=0,Gd=1,Bi="",Ne="srgb",Gn="srgb-linear",br="linear",he="srgb";var Hn=7680;var Zc=519,Wd=512,Xd=513,qd=514,ph=515,Yd=516,Zd=517,$d=518,Jd=519,da=35044,mh=35048;var gh="300 es",Li=2e3,wr=2001;var rn=class{addEventListener(t,e){this._listeners===void 0&&(this._listeners={});let i=this._listeners;i[t]===void 0&&(i[t]=[]),i[t].indexOf(e)===-1&&i[t].push(e)}hasEventListener(t,e){let i=this._listeners;return i===void 0?!1:i[t]!==void 0&&i[t].indexOf(e)!==-1}removeEventListener(t,e){let i=this._listeners;if(i===void 0)return;let n=i[t];if(n!==void 0){let r=n.indexOf(e);r!==-1&&n.splice(r,1)}}dispatchEvent(t){let e=this._listeners;if(e===void 0)return;let i=e[t.type];if(i!==void 0){t.target=this;let n=i.slice(0);for(let r=0,o=n.length;r<o;r++)n[r].call(this,t);t.target=null}}},$e=["00","01","02","03","04","05","06","07","08","09","0a","0b","0c","0d","0e","0f","10","11","12","13","14","15","16","17","18","19","1a","1b","1c","1d","1e","1f","20","21","22","23","24","25","26","27","28","29","2a","2b","2c","2d","2e","2f","30","31","32","33","34","35","36","37","38","39","3a","3b","3c","3d","3e","3f","40","41","42","43","44","45","46","47","48","49","4a","4b","4c","4d","4e","4f","50","51","52","53","54","55","56","57","58","59","5a","5b","5c","5d","5e","5f","60","61","62","63","64","65","66","67","68","69","6a","6b","6c","6d","6e","6f","70","71","72","73","74","75","76","77","78","79","7a","7b","7c","7d","7e","7f","80","81","82","83","84","85","86","87","88","89","8a","8b","8c","8d","8e","8f","90","91","92","93","94","95","96","97","98","99","9a","9b","9c","9d","9e","9f","a0","a1","a2","a3","a4","a5","a6","a7","a8","a9","aa","ab","ac","ad","ae","af","b0","b1","b2","b3","b4","b5","b6","b7","b8","b9","ba","bb","bc","bd","be","bf","c0","c1","c2","c3","c4","c5","c6","c7","c8","c9","ca","cb","cc","cd","ce","cf","d0","d1","d2","d3","d4","d5","d6","d7","d8","d9","da","db","dc","dd","de","df","e0","e1","e2","e3","e4","e5","e6","e7","e8","e9","ea","eb","ec","ed","ee","ef","f0","f1","f2","f3","f4","f5","f6","f7","f8","f9","fa","fb","fc","fd","fe","ff"],Ru=1234567,xr=Math.PI/180,Rs=180/Math.PI;function Di(){let s=Math.random()*4294967295|0,t=Math.random()*4294967295|0,e=Math.random()*4294967295|0,i=Math.random()*4294967295|0;return($e[s&255]+$e[s>>8&255]+$e[s>>16&255]+$e[s>>24&255]+"-"+$e[t&255]+$e[t>>8&255]+"-"+$e[t>>16&15|64]+$e[t>>24&255]+"-"+$e[e&63|128]+$e[e>>8&255]+"-"+$e[e>>16&255]+$e[e>>24&255]+$e[i&255]+$e[i>>8&255]+$e[i>>16&255]+$e[i>>24&255]).toLowerCase()}function Zt(s,t,e){return Math.max(t,Math.min(e,s))}function xh(s,t){return(s%t+t)%t}function Ip(s,t,e,i,n){return i+(s-t)*(n-i)/(e-t)}function Pp(s,t,e){return s!==t?(e-s)/(t-s):0}function _r(s,t,e){return(1-e)*s+e*t}function Lp(s,t,e,i){return _r(s,t,1-Math.exp(-e*i))}function Dp(s,t=1){return t-Math.abs(xh(s,t*2)-t)}function Up(s,t,e){return s<=t?0:s>=e?1:(s=(s-t)/(e-t),s*s*(3-2*s))}function Np(s,t,e){return s<=t?0:s>=e?1:(s=(s-t)/(e-t),s*s*s*(s*(s*6-15)+10))}function Fp(s,t){return s+Math.floor(Math.random()*(t-s+1))}function kp(s,t){return s+Math.random()*(t-s)}function Bp(s){return s*(.5-Math.random())}function Op(s){s!==void 0&&(Ru=s);let t=Ru+=1831565813;return t=Math.imul(t^t>>>15,t|1),t^=t+Math.imul(t^t>>>7,t|61),((t^t>>>14)>>>0)/4294967296}function zp(s){return s*xr}function Hp(s){return s*Rs}function Vp(s){return(s&s-1)===0&&s!==0}function Gp(s){return Math.pow(2,Math.ceil(Math.log(s)/Math.LN2))}function Wp(s){return Math.pow(2,Math.floor(Math.log(s)/Math.LN2))}function Xp(s,t,e,i,n){let r=Math.cos,o=Math.sin,a=r(e/2),l=o(e/2),c=r((t+i)/2),h=o((t+i)/2),u=r((t-i)/2),f=o((t-i)/2),d=r((i-t)/2),g=o((i-t)/2);switch(n){case"XYX":s.set(a*h,l*u,l*f,a*c);break;case"YZY":s.set(l*f,a*h,l*u,a*c);break;case"ZXZ":s.set(l*u,l*f,a*h,a*c);break;case"XZX":s.set(a*h,l*g,l*d,a*c);break;case"YXY":s.set(l*d,a*h,l*g,a*c);break;case"ZYZ":s.set(l*g,l*d,a*h,a*c);break;default:console.warn("THREE.MathUtils: .setQuaternionFromProperEuler() encountered an unknown order: "+n)}}function Pi(s,t){switch(t.constructor){case Float32Array:return s;case Uint32Array:return s/4294967295;case Uint16Array:return s/65535;case Uint8Array:return s/255;case Int32Array:return Math.max(s/2147483647,-1);case Int16Array:return Math.max(s/32767,-1);case Int8Array:return Math.max(s/127,-1);default:throw new Error("Invalid component type.")}}function ce(s,t){switch(t.constructor){case Float32Array:return s;case Uint32Array:return Math.round(s*4294967295);case Uint16Array:return Math.round(s*65535);case Uint8Array:return Math.round(s*255);case Int32Array:return Math.round(s*2147483647);case Int16Array:return Math.round(s*32767);case Int8Array:return Math.round(s*127);default:throw new Error("Invalid component type.")}}var ho={DEG2RAD:xr,RAD2DEG:Rs,generateUUID:Di,clamp:Zt,euclideanModulo:xh,mapLinear:Ip,inverseLerp:Pp,lerp:_r,damp:Lp,pingpong:Dp,smoothstep:Up,smootherstep:Np,randInt:Fp,randFloat:kp,randFloatSpread:Bp,seededRandom:Op,degToRad:zp,radToDeg:Hp,isPowerOfTwo:Vp,ceilPowerOfTwo:Gp,floorPowerOfTwo:Wp,setQuaternionFromProperEuler:Xp,normalize:ce,denormalize:Pi},nt=class s{constructor(t=0,e=0){s.prototype.isVector2=!0,this.x=t,this.y=e}get width(){return this.x}set width(t){this.x=t}get height(){return this.y}set height(t){this.y=t}set(t,e){return this.x=t,this.y=e,this}setScalar(t){return this.x=t,this.y=t,this}setX(t){return this.x=t,this}setY(t){return this.y=t,this}setComponent(t,e){switch(t){case 0:this.x=e;break;case 1:this.y=e;break;default:throw new Error("index is out of range: "+t)}return this}getComponent(t){switch(t){case 0:return this.x;case 1:return this.y;default:throw new Error("index is out of range: "+t)}}clone(){return new this.constructor(this.x,this.y)}copy(t){return this.x=t.x,this.y=t.y,this}add(t){return this.x+=t.x,this.y+=t.y,this}addScalar(t){return this.x+=t,this.y+=t,this}addVectors(t,e){return this.x=t.x+e.x,this.y=t.y+e.y,this}addScaledVector(t,e){return this.x+=t.x*e,this.y+=t.y*e,this}sub(t){return this.x-=t.x,this.y-=t.y,this}subScalar(t){return this.x-=t,this.y-=t,this}subVectors(t,e){return this.x=t.x-e.x,this.y=t.y-e.y,this}multiply(t){return this.x*=t.x,this.y*=t.y,this}multiplyScalar(t){return this.x*=t,this.y*=t,this}divide(t){return this.x/=t.x,this.y/=t.y,this}divideScalar(t){return this.multiplyScalar(1/t)}applyMatrix3(t){let e=this.x,i=this.y,n=t.elements;return this.x=n[0]*e+n[3]*i+n[6],this.y=n[1]*e+n[4]*i+n[7],this}min(t){return this.x=Math.min(this.x,t.x),this.y=Math.min(this.y,t.y),this}max(t){return this.x=Math.max(this.x,t.x),this.y=Math.max(this.y,t.y),this}clamp(t,e){return this.x=Zt(this.x,t.x,e.x),this.y=Zt(this.y,t.y,e.y),this}clampScalar(t,e){return this.x=Zt(this.x,t,e),this.y=Zt(this.y,t,e),this}clampLength(t,e){let i=this.length();return this.divideScalar(i||1).multiplyScalar(Zt(i,t,e))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this}negate(){return this.x=-this.x,this.y=-this.y,this}dot(t){return this.x*t.x+this.y*t.y}cross(t){return this.x*t.y-this.y*t.x}lengthSq(){return this.x*this.x+this.y*this.y}length(){return Math.sqrt(this.x*this.x+this.y*this.y)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)}normalize(){return this.divideScalar(this.length()||1)}angle(){return Math.atan2(-this.y,-this.x)+Math.PI}angleTo(t){let e=Math.sqrt(this.lengthSq()*t.lengthSq());if(e===0)return Math.PI/2;let i=this.dot(t)/e;return Math.acos(Zt(i,-1,1))}distanceTo(t){return Math.sqrt(this.distanceToSquared(t))}distanceToSquared(t){let e=this.x-t.x,i=this.y-t.y;return e*e+i*i}manhattanDistanceTo(t){return Math.abs(this.x-t.x)+Math.abs(this.y-t.y)}setLength(t){return this.normalize().multiplyScalar(t)}lerp(t,e){return this.x+=(t.x-this.x)*e,this.y+=(t.y-this.y)*e,this}lerpVectors(t,e,i){return this.x=t.x+(e.x-t.x)*i,this.y=t.y+(e.y-t.y)*i,this}equals(t){return t.x===this.x&&t.y===this.y}fromArray(t,e=0){return this.x=t[e],this.y=t[e+1],this}toArray(t=[],e=0){return t[e]=this.x,t[e+1]=this.y,t}fromBufferAttribute(t,e){return this.x=t.getX(e),this.y=t.getY(e),this}rotateAround(t,e){let i=Math.cos(e),n=Math.sin(e),r=this.x-t.x,o=this.y-t.y;return this.x=r*i-o*n+t.x,this.y=r*n+o*i+t.y,this}random(){return this.x=Math.random(),this.y=Math.random(),this}*[Symbol.iterator](){yield this.x,yield this.y}},_e=class{constructor(t=0,e=0,i=0,n=1){this.isQuaternion=!0,this._x=t,this._y=e,this._z=i,this._w=n}static slerpFlat(t,e,i,n,r,o,a){let l=i[n+0],c=i[n+1],h=i[n+2],u=i[n+3],f=r[o+0],d=r[o+1],g=r[o+2],x=r[o+3];if(a===0){t[e+0]=l,t[e+1]=c,t[e+2]=h,t[e+3]=u;return}if(a===1){t[e+0]=f,t[e+1]=d,t[e+2]=g,t[e+3]=x;return}if(u!==x||l!==f||c!==d||h!==g){let m=1-a,p=l*f+c*d+h*g+u*x,M=p>=0?1:-1,y=1-p*p;if(y>Number.EPSILON){let b=Math.sqrt(y),E=Math.atan2(b,p*M);m=Math.sin(m*E)/b,a=Math.sin(a*E)/b}let _=a*M;if(l=l*m+f*_,c=c*m+d*_,h=h*m+g*_,u=u*m+x*_,m===1-a){let b=1/Math.sqrt(l*l+c*c+h*h+u*u);l*=b,c*=b,h*=b,u*=b}}t[e]=l,t[e+1]=c,t[e+2]=h,t[e+3]=u}static multiplyQuaternionsFlat(t,e,i,n,r,o){let a=i[n],l=i[n+1],c=i[n+2],h=i[n+3],u=r[o],f=r[o+1],d=r[o+2],g=r[o+3];return t[e]=a*g+h*u+l*d-c*f,t[e+1]=l*g+h*f+c*u-a*d,t[e+2]=c*g+h*d+a*f-l*u,t[e+3]=h*g-a*u-l*f-c*d,t}get x(){return this._x}set x(t){this._x=t,this._onChangeCallback()}get y(){return this._y}set y(t){this._y=t,this._onChangeCallback()}get z(){return this._z}set z(t){this._z=t,this._onChangeCallback()}get w(){return this._w}set w(t){this._w=t,this._onChangeCallback()}set(t,e,i,n){return this._x=t,this._y=e,this._z=i,this._w=n,this._onChangeCallback(),this}clone(){return new this.constructor(this._x,this._y,this._z,this._w)}copy(t){return this._x=t.x,this._y=t.y,this._z=t.z,this._w=t.w,this._onChangeCallback(),this}setFromEuler(t,e=!0){let i=t._x,n=t._y,r=t._z,o=t._order,a=Math.cos,l=Math.sin,c=a(i/2),h=a(n/2),u=a(r/2),f=l(i/2),d=l(n/2),g=l(r/2);switch(o){case"XYZ":this._x=f*h*u+c*d*g,this._y=c*d*u-f*h*g,this._z=c*h*g+f*d*u,this._w=c*h*u-f*d*g;break;case"YXZ":this._x=f*h*u+c*d*g,this._y=c*d*u-f*h*g,this._z=c*h*g-f*d*u,this._w=c*h*u+f*d*g;break;case"ZXY":this._x=f*h*u-c*d*g,this._y=c*d*u+f*h*g,this._z=c*h*g+f*d*u,this._w=c*h*u-f*d*g;break;case"ZYX":this._x=f*h*u-c*d*g,this._y=c*d*u+f*h*g,this._z=c*h*g-f*d*u,this._w=c*h*u+f*d*g;break;case"YZX":this._x=f*h*u+c*d*g,this._y=c*d*u+f*h*g,this._z=c*h*g-f*d*u,this._w=c*h*u-f*d*g;break;case"XZY":this._x=f*h*u-c*d*g,this._y=c*d*u-f*h*g,this._z=c*h*g+f*d*u,this._w=c*h*u+f*d*g;break;default:console.warn("THREE.Quaternion: .setFromEuler() encountered an unknown order: "+o)}return e===!0&&this._onChangeCallback(),this}setFromAxisAngle(t,e){let i=e/2,n=Math.sin(i);return this._x=t.x*n,this._y=t.y*n,this._z=t.z*n,this._w=Math.cos(i),this._onChangeCallback(),this}setFromRotationMatrix(t){let e=t.elements,i=e[0],n=e[4],r=e[8],o=e[1],a=e[5],l=e[9],c=e[2],h=e[6],u=e[10],f=i+a+u;if(f>0){let d=.5/Math.sqrt(f+1);this._w=.25/d,this._x=(h-l)*d,this._y=(r-c)*d,this._z=(o-n)*d}else if(i>a&&i>u){let d=2*Math.sqrt(1+i-a-u);this._w=(h-l)/d,this._x=.25*d,this._y=(n+o)/d,this._z=(r+c)/d}else if(a>u){let d=2*Math.sqrt(1+a-i-u);this._w=(r-c)/d,this._x=(n+o)/d,this._y=.25*d,this._z=(l+h)/d}else{let d=2*Math.sqrt(1+u-i-a);this._w=(o-n)/d,this._x=(r+c)/d,this._y=(l+h)/d,this._z=.25*d}return this._onChangeCallback(),this}setFromUnitVectors(t,e){let i=t.dot(e)+1;return i<1e-8?(i=0,Math.abs(t.x)>Math.abs(t.z)?(this._x=-t.y,this._y=t.x,this._z=0,this._w=i):(this._x=0,this._y=-t.z,this._z=t.y,this._w=i)):(this._x=t.y*e.z-t.z*e.y,this._y=t.z*e.x-t.x*e.z,this._z=t.x*e.y-t.y*e.x,this._w=i),this.normalize()}angleTo(t){return 2*Math.acos(Math.abs(Zt(this.dot(t),-1,1)))}rotateTowards(t,e){let i=this.angleTo(t);if(i===0)return this;let n=Math.min(1,e/i);return this.slerp(t,n),this}identity(){return this.set(0,0,0,1)}invert(){return this.conjugate()}conjugate(){return this._x*=-1,this._y*=-1,this._z*=-1,this._onChangeCallback(),this}dot(t){return this._x*t._x+this._y*t._y+this._z*t._z+this._w*t._w}lengthSq(){return this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w}length(){return Math.sqrt(this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w)}normalize(){let t=this.length();return t===0?(this._x=0,this._y=0,this._z=0,this._w=1):(t=1/t,this._x=this._x*t,this._y=this._y*t,this._z=this._z*t,this._w=this._w*t),this._onChangeCallback(),this}multiply(t){return this.multiplyQuaternions(this,t)}premultiply(t){return this.multiplyQuaternions(t,this)}multiplyQuaternions(t,e){let i=t._x,n=t._y,r=t._z,o=t._w,a=e._x,l=e._y,c=e._z,h=e._w;return this._x=i*h+o*a+n*c-r*l,this._y=n*h+o*l+r*a-i*c,this._z=r*h+o*c+i*l-n*a,this._w=o*h-i*a-n*l-r*c,this._onChangeCallback(),this}slerp(t,e){if(e===0)return this;if(e===1)return this.copy(t);let i=this._x,n=this._y,r=this._z,o=this._w,a=o*t._w+i*t._x+n*t._y+r*t._z;if(a<0?(this._w=-t._w,this._x=-t._x,this._y=-t._y,this._z=-t._z,a=-a):this.copy(t),a>=1)return this._w=o,this._x=i,this._y=n,this._z=r,this;let l=1-a*a;if(l<=Number.EPSILON){let d=1-e;return this._w=d*o+e*this._w,this._x=d*i+e*this._x,this._y=d*n+e*this._y,this._z=d*r+e*this._z,this.normalize(),this}let c=Math.sqrt(l),h=Math.atan2(c,a),u=Math.sin((1-e)*h)/c,f=Math.sin(e*h)/c;return this._w=o*u+this._w*f,this._x=i*u+this._x*f,this._y=n*u+this._y*f,this._z=r*u+this._z*f,this._onChangeCallback(),this}slerpQuaternions(t,e,i){return this.copy(t).slerp(e,i)}random(){let t=2*Math.PI*Math.random(),e=2*Math.PI*Math.random(),i=Math.random(),n=Math.sqrt(1-i),r=Math.sqrt(i);return this.set(n*Math.sin(t),n*Math.cos(t),r*Math.sin(e),r*Math.cos(e))}equals(t){return t._x===this._x&&t._y===this._y&&t._z===this._z&&t._w===this._w}fromArray(t,e=0){return this._x=t[e],this._y=t[e+1],this._z=t[e+2],this._w=t[e+3],this._onChangeCallback(),this}toArray(t=[],e=0){return t[e]=this._x,t[e+1]=this._y,t[e+2]=this._z,t[e+3]=this._w,t}fromBufferAttribute(t,e){return this._x=t.getX(e),this._y=t.getY(e),this._z=t.getZ(e),this._w=t.getW(e),this._onChangeCallback(),this}toJSON(){return this.toArray()}_onChange(t){return this._onChangeCallback=t,this}_onChangeCallback(){}*[Symbol.iterator](){yield this._x,yield this._y,yield this._z,yield this._w}},T=class s{constructor(t=0,e=0,i=0){s.prototype.isVector3=!0,this.x=t,this.y=e,this.z=i}set(t,e,i){return i===void 0&&(i=this.z),this.x=t,this.y=e,this.z=i,this}setScalar(t){return this.x=t,this.y=t,this.z=t,this}setX(t){return this.x=t,this}setY(t){return this.y=t,this}setZ(t){return this.z=t,this}setComponent(t,e){switch(t){case 0:this.x=e;break;case 1:this.y=e;break;case 2:this.z=e;break;default:throw new Error("index is out of range: "+t)}return this}getComponent(t){switch(t){case 0:return this.x;case 1:return this.y;case 2:return this.z;default:throw new Error("index is out of range: "+t)}}clone(){return new this.constructor(this.x,this.y,this.z)}copy(t){return this.x=t.x,this.y=t.y,this.z=t.z,this}add(t){return this.x+=t.x,this.y+=t.y,this.z+=t.z,this}addScalar(t){return this.x+=t,this.y+=t,this.z+=t,this}addVectors(t,e){return this.x=t.x+e.x,this.y=t.y+e.y,this.z=t.z+e.z,this}addScaledVector(t,e){return this.x+=t.x*e,this.y+=t.y*e,this.z+=t.z*e,this}sub(t){return this.x-=t.x,this.y-=t.y,this.z-=t.z,this}subScalar(t){return this.x-=t,this.y-=t,this.z-=t,this}subVectors(t,e){return this.x=t.x-e.x,this.y=t.y-e.y,this.z=t.z-e.z,this}multiply(t){return this.x*=t.x,this.y*=t.y,this.z*=t.z,this}multiplyScalar(t){return this.x*=t,this.y*=t,this.z*=t,this}multiplyVectors(t,e){return this.x=t.x*e.x,this.y=t.y*e.y,this.z=t.z*e.z,this}applyEuler(t){return this.applyQuaternion(Cu.setFromEuler(t))}applyAxisAngle(t,e){return this.applyQuaternion(Cu.setFromAxisAngle(t,e))}applyMatrix3(t){let e=this.x,i=this.y,n=this.z,r=t.elements;return this.x=r[0]*e+r[3]*i+r[6]*n,this.y=r[1]*e+r[4]*i+r[7]*n,this.z=r[2]*e+r[5]*i+r[8]*n,this}applyNormalMatrix(t){return this.applyMatrix3(t).normalize()}applyMatrix4(t){let e=this.x,i=this.y,n=this.z,r=t.elements,o=1/(r[3]*e+r[7]*i+r[11]*n+r[15]);return this.x=(r[0]*e+r[4]*i+r[8]*n+r[12])*o,this.y=(r[1]*e+r[5]*i+r[9]*n+r[13])*o,this.z=(r[2]*e+r[6]*i+r[10]*n+r[14])*o,this}applyQuaternion(t){let e=this.x,i=this.y,n=this.z,r=t.x,o=t.y,a=t.z,l=t.w,c=2*(o*n-a*i),h=2*(a*e-r*n),u=2*(r*i-o*e);return this.x=e+l*c+o*u-a*h,this.y=i+l*h+a*c-r*u,this.z=n+l*u+r*h-o*c,this}project(t){return this.applyMatrix4(t.matrixWorldInverse).applyMatrix4(t.projectionMatrix)}unproject(t){return this.applyMatrix4(t.projectionMatrixInverse).applyMatrix4(t.matrixWorld)}transformDirection(t){let e=this.x,i=this.y,n=this.z,r=t.elements;return this.x=r[0]*e+r[4]*i+r[8]*n,this.y=r[1]*e+r[5]*i+r[9]*n,this.z=r[2]*e+r[6]*i+r[10]*n,this.normalize()}divide(t){return this.x/=t.x,this.y/=t.y,this.z/=t.z,this}divideScalar(t){return this.multiplyScalar(1/t)}min(t){return this.x=Math.min(this.x,t.x),this.y=Math.min(this.y,t.y),this.z=Math.min(this.z,t.z),this}max(t){return this.x=Math.max(this.x,t.x),this.y=Math.max(this.y,t.y),this.z=Math.max(this.z,t.z),this}clamp(t,e){return this.x=Zt(this.x,t.x,e.x),this.y=Zt(this.y,t.y,e.y),this.z=Zt(this.z,t.z,e.z),this}clampScalar(t,e){return this.x=Zt(this.x,t,e),this.y=Zt(this.y,t,e),this.z=Zt(this.z,t,e),this}clampLength(t,e){let i=this.length();return this.divideScalar(i||1).multiplyScalar(Zt(i,t,e))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this.z=Math.trunc(this.z),this}negate(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this}dot(t){return this.x*t.x+this.y*t.y+this.z*t.z}lengthSq(){return this.x*this.x+this.y*this.y+this.z*this.z}length(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)}normalize(){return this.divideScalar(this.length()||1)}setLength(t){return this.normalize().multiplyScalar(t)}lerp(t,e){return this.x+=(t.x-this.x)*e,this.y+=(t.y-this.y)*e,this.z+=(t.z-this.z)*e,this}lerpVectors(t,e,i){return this.x=t.x+(e.x-t.x)*i,this.y=t.y+(e.y-t.y)*i,this.z=t.z+(e.z-t.z)*i,this}cross(t){return this.crossVectors(this,t)}crossVectors(t,e){let i=t.x,n=t.y,r=t.z,o=e.x,a=e.y,l=e.z;return this.x=n*l-r*a,this.y=r*o-i*l,this.z=i*a-n*o,this}projectOnVector(t){let e=t.lengthSq();if(e===0)return this.set(0,0,0);let i=t.dot(this)/e;return this.copy(t).multiplyScalar(i)}projectOnPlane(t){return mc.copy(this).projectOnVector(t),this.sub(mc)}reflect(t){return this.sub(mc.copy(t).multiplyScalar(2*this.dot(t)))}angleTo(t){let e=Math.sqrt(this.lengthSq()*t.lengthSq());if(e===0)return Math.PI/2;let i=this.dot(t)/e;return Math.acos(Zt(i,-1,1))}distanceTo(t){return Math.sqrt(this.distanceToSquared(t))}distanceToSquared(t){let e=this.x-t.x,i=this.y-t.y,n=this.z-t.z;return e*e+i*i+n*n}manhattanDistanceTo(t){return Math.abs(this.x-t.x)+Math.abs(this.y-t.y)+Math.abs(this.z-t.z)}setFromSpherical(t){return this.setFromSphericalCoords(t.radius,t.phi,t.theta)}setFromSphericalCoords(t,e,i){let n=Math.sin(e)*t;return this.x=n*Math.sin(i),this.y=Math.cos(e)*t,this.z=n*Math.cos(i),this}setFromCylindrical(t){return this.setFromCylindricalCoords(t.radius,t.theta,t.y)}setFromCylindricalCoords(t,e,i){return this.x=t*Math.sin(e),this.y=i,this.z=t*Math.cos(e),this}setFromMatrixPosition(t){let e=t.elements;return this.x=e[12],this.y=e[13],this.z=e[14],this}setFromMatrixScale(t){let e=this.setFromMatrixColumn(t,0).length(),i=this.setFromMatrixColumn(t,1).length(),n=this.setFromMatrixColumn(t,2).length();return this.x=e,this.y=i,this.z=n,this}setFromMatrixColumn(t,e){return this.fromArray(t.elements,e*4)}setFromMatrix3Column(t,e){return this.fromArray(t.elements,e*3)}setFromEuler(t){return this.x=t._x,this.y=t._y,this.z=t._z,this}setFromColor(t){return this.x=t.r,this.y=t.g,this.z=t.b,this}equals(t){return t.x===this.x&&t.y===this.y&&t.z===this.z}fromArray(t,e=0){return this.x=t[e],this.y=t[e+1],this.z=t[e+2],this}toArray(t=[],e=0){return t[e]=this.x,t[e+1]=this.y,t[e+2]=this.z,t}fromBufferAttribute(t,e){return this.x=t.getX(e),this.y=t.getY(e),this.z=t.getZ(e),this}random(){return this.x=Math.random(),this.y=Math.random(),this.z=Math.random(),this}randomDirection(){let t=Math.random()*Math.PI*2,e=Math.random()*2-1,i=Math.sqrt(1-e*e);return this.x=i*Math.cos(t),this.y=e,this.z=i*Math.sin(t),this}*[Symbol.iterator](){yield this.x,yield this.y,yield this.z}},mc=new T,Cu=new _e,Xt=class s{constructor(t,e,i,n,r,o,a,l,c){s.prototype.isMatrix3=!0,this.elements=[1,0,0,0,1,0,0,0,1],t!==void 0&&this.set(t,e,i,n,r,o,a,l,c)}set(t,e,i,n,r,o,a,l,c){let h=this.elements;return h[0]=t,h[1]=n,h[2]=a,h[3]=e,h[4]=r,h[5]=l,h[6]=i,h[7]=o,h[8]=c,this}identity(){return this.set(1,0,0,0,1,0,0,0,1),this}copy(t){let e=this.elements,i=t.elements;return e[0]=i[0],e[1]=i[1],e[2]=i[2],e[3]=i[3],e[4]=i[4],e[5]=i[5],e[6]=i[6],e[7]=i[7],e[8]=i[8],this}extractBasis(t,e,i){return t.setFromMatrix3Column(this,0),e.setFromMatrix3Column(this,1),i.setFromMatrix3Column(this,2),this}setFromMatrix4(t){let e=t.elements;return this.set(e[0],e[4],e[8],e[1],e[5],e[9],e[2],e[6],e[10]),this}multiply(t){return this.multiplyMatrices(this,t)}premultiply(t){return this.multiplyMatrices(t,this)}multiplyMatrices(t,e){let i=t.elements,n=e.elements,r=this.elements,o=i[0],a=i[3],l=i[6],c=i[1],h=i[4],u=i[7],f=i[2],d=i[5],g=i[8],x=n[0],m=n[3],p=n[6],M=n[1],y=n[4],_=n[7],b=n[2],E=n[5],P=n[8];return r[0]=o*x+a*M+l*b,r[3]=o*m+a*y+l*E,r[6]=o*p+a*_+l*P,r[1]=c*x+h*M+u*b,r[4]=c*m+h*y+u*E,r[7]=c*p+h*_+u*P,r[2]=f*x+d*M+g*b,r[5]=f*m+d*y+g*E,r[8]=f*p+d*_+g*P,this}multiplyScalar(t){let e=this.elements;return e[0]*=t,e[3]*=t,e[6]*=t,e[1]*=t,e[4]*=t,e[7]*=t,e[2]*=t,e[5]*=t,e[8]*=t,this}determinant(){let t=this.elements,e=t[0],i=t[1],n=t[2],r=t[3],o=t[4],a=t[5],l=t[6],c=t[7],h=t[8];return e*o*h-e*a*c-i*r*h+i*a*l+n*r*c-n*o*l}invert(){let t=this.elements,e=t[0],i=t[1],n=t[2],r=t[3],o=t[4],a=t[5],l=t[6],c=t[7],h=t[8],u=h*o-a*c,f=a*l-h*r,d=c*r-o*l,g=e*u+i*f+n*d;if(g===0)return this.set(0,0,0,0,0,0,0,0,0);let x=1/g;return t[0]=u*x,t[1]=(n*c-h*i)*x,t[2]=(a*i-n*o)*x,t[3]=f*x,t[4]=(h*e-n*l)*x,t[5]=(n*r-a*e)*x,t[6]=d*x,t[7]=(i*l-c*e)*x,t[8]=(o*e-i*r)*x,this}transpose(){let t,e=this.elements;return t=e[1],e[1]=e[3],e[3]=t,t=e[2],e[2]=e[6],e[6]=t,t=e[5],e[5]=e[7],e[7]=t,this}getNormalMatrix(t){return this.setFromMatrix4(t).invert().transpose()}transposeIntoArray(t){let e=this.elements;return t[0]=e[0],t[1]=e[3],t[2]=e[6],t[3]=e[1],t[4]=e[4],t[5]=e[7],t[6]=e[2],t[7]=e[5],t[8]=e[8],this}setUvTransform(t,e,i,n,r,o,a){let l=Math.cos(r),c=Math.sin(r);return this.set(i*l,i*c,-i*(l*o+c*a)+o+t,-n*c,n*l,-n*(-c*o+l*a)+a+e,0,0,1),this}scale(t,e){return this.premultiply(gc.makeScale(t,e)),this}rotate(t){return this.premultiply(gc.makeRotation(-t)),this}translate(t,e){return this.premultiply(gc.makeTranslation(t,e)),this}makeTranslation(t,e){return t.isVector2?this.set(1,0,t.x,0,1,t.y,0,0,1):this.set(1,0,t,0,1,e,0,0,1),this}makeRotation(t){let e=Math.cos(t),i=Math.sin(t);return this.set(e,-i,0,i,e,0,0,0,1),this}makeScale(t,e){return this.set(t,0,0,0,e,0,0,0,1),this}equals(t){let e=this.elements,i=t.elements;for(let n=0;n<9;n++)if(e[n]!==i[n])return!1;return!0}fromArray(t,e=0){for(let i=0;i<9;i++)this.elements[i]=t[i+e];return this}toArray(t=[],e=0){let i=this.elements;return t[e]=i[0],t[e+1]=i[1],t[e+2]=i[2],t[e+3]=i[3],t[e+4]=i[4],t[e+5]=i[5],t[e+6]=i[6],t[e+7]=i[7],t[e+8]=i[8],t}clone(){return new this.constructor().fromArray(this.elements)}},gc=new Xt;function _h(s){for(let t=s.length-1;t>=0;--t)if(s[t]>=65535)return!0;return!1}function Sr(s){return document.createElementNS("http://www.w3.org/1999/xhtml",s)}function Kd(){let s=Sr("canvas");return s.style.display="block",s}var Iu={};function Cs(s){s in Iu||(Iu[s]=!0,console.warn(s))}function jd(s,t,e){return new Promise(function(i,n){function r(){switch(s.clientWaitSync(t,s.SYNC_FLUSH_COMMANDS_BIT,0)){case s.WAIT_FAILED:n();break;case s.TIMEOUT_EXPIRED:setTimeout(r,e);break;default:i()}}setTimeout(r,e)})}var Pu=new Xt().set(.4123908,.3575843,.1804808,.212639,.7151687,.0721923,.0193308,.1191948,.9505322),Lu=new Xt().set(3.2409699,-1.5373832,-.4986108,-.9692436,1.8759675,.0415551,.0556301,-.203977,1.0569715);function qp(){let s={enabled:!0,workingColorSpace:Gn,spaces:{},convert:function(n,r,o){return this.enabled===!1||r===o||!r||!o||(this.spaces[r].transfer===he&&(n.r=sn(n.r),n.g=sn(n.g),n.b=sn(n.b)),this.spaces[r].primaries!==this.spaces[o].primaries&&(n.applyMatrix3(this.spaces[r].toXYZ),n.applyMatrix3(this.spaces[o].fromXYZ)),this.spaces[o].transfer===he&&(n.r=Es(n.r),n.g=Es(n.g),n.b=Es(n.b))),n},workingToColorSpace:function(n,r){return this.convert(n,this.workingColorSpace,r)},colorSpaceToWorking:function(n,r){return this.convert(n,r,this.workingColorSpace)},getPrimaries:function(n){return this.spaces[n].primaries},getTransfer:function(n){return n===Bi?br:this.spaces[n].transfer},getToneMappingMode:function(n){return this.spaces[n].outputColorSpaceConfig.toneMappingMode||"standard"},getLuminanceCoefficients:function(n,r=this.workingColorSpace){return n.fromArray(this.spaces[r].luminanceCoefficients)},define:function(n){Object.assign(this.spaces,n)},_getMatrix:function(n,r,o){return n.copy(this.spaces[r].toXYZ).multiply(this.spaces[o].fromXYZ)},_getDrawingBufferColorSpace:function(n){return this.spaces[n].outputColorSpaceConfig.drawingBufferColorSpace},_getUnpackColorSpace:function(n=this.workingColorSpace){return this.spaces[n].workingColorSpaceConfig.unpackColorSpace},fromWorkingColorSpace:function(n,r){return Cs("THREE.ColorManagement: .fromWorkingColorSpace() has been renamed to .workingToColorSpace()."),s.workingToColorSpace(n,r)},toWorkingColorSpace:function(n,r){return Cs("THREE.ColorManagement: .toWorkingColorSpace() has been renamed to .colorSpaceToWorking()."),s.colorSpaceToWorking(n,r)}},t=[.64,.33,.3,.6,.15,.06],e=[.2126,.7152,.0722],i=[.3127,.329];return s.define({[Gn]:{primaries:t,whitePoint:i,transfer:br,toXYZ:Pu,fromXYZ:Lu,luminanceCoefficients:e,workingColorSpaceConfig:{unpackColorSpace:Ne},outputColorSpaceConfig:{drawingBufferColorSpace:Ne}},[Ne]:{primaries:t,whitePoint:i,transfer:he,toXYZ:Pu,fromXYZ:Lu,luminanceCoefficients:e,outputColorSpaceConfig:{drawingBufferColorSpace:Ne}}}),s}var te=qp();function sn(s){return s<.04045?s*.0773993808:Math.pow(s*.9478672986+.0521327014,2.4)}function Es(s){return s<.0031308?s*12.92:1.055*Math.pow(s,.41666)-.055}var ls,fa=class{static getDataURL(t,e="image/png"){if(/^data:/i.test(t.src)||typeof HTMLCanvasElement>"u")return t.src;let i;if(t instanceof HTMLCanvasElement)i=t;else{ls===void 0&&(ls=Sr("canvas")),ls.width=t.width,ls.height=t.height;let n=ls.getContext("2d");t instanceof ImageData?n.putImageData(t,0,0):n.drawImage(t,0,0,t.width,t.height),i=ls}return i.toDataURL(e)}static sRGBToLinear(t){if(typeof HTMLImageElement<"u"&&t instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&t instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&t instanceof ImageBitmap){let e=Sr("canvas");e.width=t.width,e.height=t.height;let i=e.getContext("2d");i.drawImage(t,0,0,t.width,t.height);let n=i.getImageData(0,0,t.width,t.height),r=n.data;for(let o=0;o<r.length;o++)r[o]=sn(r[o]/255)*255;return i.putImageData(n,0,0),e}else if(t.data){let e=t.data.slice(0);for(let i=0;i<e.length;i++)e instanceof Uint8Array||e instanceof Uint8ClampedArray?e[i]=Math.floor(sn(e[i]/255)*255):e[i]=sn(e[i]);return{data:e,width:t.width,height:t.height}}else return console.warn("THREE.ImageUtils.sRGBToLinear(): Unsupported image type. No color space conversion applied."),t}},Yp=0,Is=class{constructor(t=null){this.isSource=!0,Object.defineProperty(this,"id",{value:Yp++}),this.uuid=Di(),this.data=t,this.dataReady=!0,this.version=0}getSize(t){let e=this.data;return typeof HTMLVideoElement<"u"&&e instanceof HTMLVideoElement?t.set(e.videoWidth,e.videoHeight,0):e instanceof VideoFrame?t.set(e.displayHeight,e.displayWidth,0):e!==null?t.set(e.width,e.height,e.depth||0):t.set(0,0,0),t}set needsUpdate(t){t===!0&&this.version++}toJSON(t){let e=t===void 0||typeof t=="string";if(!e&&t.images[this.uuid]!==void 0)return t.images[this.uuid];let i={uuid:this.uuid,url:""},n=this.data;if(n!==null){let r;if(Array.isArray(n)){r=[];for(let o=0,a=n.length;o<a;o++)n[o].isDataTexture?r.push(xc(n[o].image)):r.push(xc(n[o]))}else r=xc(n);i.url=r}return e||(t.images[this.uuid]=i),i}};function xc(s){return typeof HTMLImageElement<"u"&&s instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&s instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&s instanceof ImageBitmap?fa.getDataURL(s):s.data?{data:Array.from(s.data),width:s.width,height:s.height,type:s.data.constructor.name}:(console.warn("THREE.Texture: Unable to serialize Texture."),{})}var Zp=0,_c=new T,si=class s extends rn{constructor(t=s.DEFAULT_IMAGE,e=s.DEFAULT_MAPPING,i=bn,n=bn,r=Ni,o=Rn,a=gi,l=ki,c=s.DEFAULT_ANISOTROPY,h=Bi){super(),this.isTexture=!0,Object.defineProperty(this,"id",{value:Zp++}),this.uuid=Di(),this.name="",this.source=new Is(t),this.mipmaps=[],this.mapping=e,this.channel=0,this.wrapS=i,this.wrapT=n,this.magFilter=r,this.minFilter=o,this.anisotropy=c,this.format=a,this.internalFormat=null,this.type=l,this.offset=new nt(0,0),this.repeat=new nt(1,1),this.center=new nt(0,0),this.rotation=0,this.matrixAutoUpdate=!0,this.matrix=new Xt,this.generateMipmaps=!0,this.premultiplyAlpha=!1,this.flipY=!0,this.unpackAlignment=4,this.colorSpace=h,this.userData={},this.updateRanges=[],this.version=0,this.onUpdate=null,this.renderTarget=null,this.isRenderTargetTexture=!1,this.isArrayTexture=!!(t&&t.depth&&t.depth>1),this.pmremVersion=0}get width(){return this.source.getSize(_c).x}get height(){return this.source.getSize(_c).y}get depth(){return this.source.getSize(_c).z}get image(){return this.source.data}set image(t=null){this.source.data=t}updateMatrix(){this.matrix.setUvTransform(this.offset.x,this.offset.y,this.repeat.x,this.repeat.y,this.rotation,this.center.x,this.center.y)}addUpdateRange(t,e){this.updateRanges.push({start:t,count:e})}clearUpdateRanges(){this.updateRanges.length=0}clone(){return new this.constructor().copy(this)}copy(t){return this.name=t.name,this.source=t.source,this.mipmaps=t.mipmaps.slice(0),this.mapping=t.mapping,this.channel=t.channel,this.wrapS=t.wrapS,this.wrapT=t.wrapT,this.magFilter=t.magFilter,this.minFilter=t.minFilter,this.anisotropy=t.anisotropy,this.format=t.format,this.internalFormat=t.internalFormat,this.type=t.type,this.offset.copy(t.offset),this.repeat.copy(t.repeat),this.center.copy(t.center),this.rotation=t.rotation,this.matrixAutoUpdate=t.matrixAutoUpdate,this.matrix.copy(t.matrix),this.generateMipmaps=t.generateMipmaps,this.premultiplyAlpha=t.premultiplyAlpha,this.flipY=t.flipY,this.unpackAlignment=t.unpackAlignment,this.colorSpace=t.colorSpace,this.renderTarget=t.renderTarget,this.isRenderTargetTexture=t.isRenderTargetTexture,this.isArrayTexture=t.isArrayTexture,this.userData=JSON.parse(JSON.stringify(t.userData)),this.needsUpdate=!0,this}setValues(t){for(let e in t){let i=t[e];if(i===void 0){console.warn(`THREE.Texture.setValues(): parameter '${e}' has value of undefined.`);continue}let n=this[e];if(n===void 0){console.warn(`THREE.Texture.setValues(): property '${e}' does not exist.`);continue}n&&i&&n.isVector2&&i.isVector2||n&&i&&n.isVector3&&i.isVector3||n&&i&&n.isMatrix3&&i.isMatrix3?n.copy(i):this[e]=i}}toJSON(t){let e=t===void 0||typeof t=="string";if(!e&&t.textures[this.uuid]!==void 0)return t.textures[this.uuid];let i={metadata:{version:4.7,type:"Texture",generator:"Texture.toJSON"},uuid:this.uuid,name:this.name,image:this.source.toJSON(t).uuid,mapping:this.mapping,channel:this.channel,repeat:[this.repeat.x,this.repeat.y],offset:[this.offset.x,this.offset.y],center:[this.center.x,this.center.y],rotation:this.rotation,wrap:[this.wrapS,this.wrapT],format:this.format,internalFormat:this.internalFormat,type:this.type,colorSpace:this.colorSpace,minFilter:this.minFilter,magFilter:this.magFilter,anisotropy:this.anisotropy,flipY:this.flipY,generateMipmaps:this.generateMipmaps,premultiplyAlpha:this.premultiplyAlpha,unpackAlignment:this.unpackAlignment};return Object.keys(this.userData).length>0&&(i.userData=this.userData),e||(t.textures[this.uuid]=i),i}dispose(){this.dispatchEvent({type:"dispose"})}transformUv(t){if(this.mapping!==oh)return t;if(t.applyMatrix3(this.matrix),t.x<0||t.x>1)switch(this.wrapS){case Ts:t.x=t.x-Math.floor(t.x);break;case bn:t.x=t.x<0?0:1;break;case ha:Math.abs(Math.floor(t.x)%2)===1?t.x=Math.ceil(t.x)-t.x:t.x=t.x-Math.floor(t.x);break}if(t.y<0||t.y>1)switch(this.wrapT){case Ts:t.y=t.y-Math.floor(t.y);break;case bn:t.y=t.y<0?0:1;break;case ha:Math.abs(Math.floor(t.y)%2)===1?t.y=Math.ceil(t.y)-t.y:t.y=t.y-Math.floor(t.y);break}return this.flipY&&(t.y=1-t.y),t}set needsUpdate(t){t===!0&&(this.version++,this.source.needsUpdate=!0)}set needsPMREMUpdate(t){t===!0&&this.pmremVersion++}};si.DEFAULT_IMAGE=null;si.DEFAULT_MAPPING=oh;si.DEFAULT_ANISOTROPY=1;var ie=class s{constructor(t=0,e=0,i=0,n=1){s.prototype.isVector4=!0,this.x=t,this.y=e,this.z=i,this.w=n}get width(){return this.z}set width(t){this.z=t}get height(){return this.w}set height(t){this.w=t}set(t,e,i,n){return this.x=t,this.y=e,this.z=i,this.w=n,this}setScalar(t){return this.x=t,this.y=t,this.z=t,this.w=t,this}setX(t){return this.x=t,this}setY(t){return this.y=t,this}setZ(t){return this.z=t,this}setW(t){return this.w=t,this}setComponent(t,e){switch(t){case 0:this.x=e;break;case 1:this.y=e;break;case 2:this.z=e;break;case 3:this.w=e;break;default:throw new Error("index is out of range: "+t)}return this}getComponent(t){switch(t){case 0:return this.x;case 1:return this.y;case 2:return this.z;case 3:return this.w;default:throw new Error("index is out of range: "+t)}}clone(){return new this.constructor(this.x,this.y,this.z,this.w)}copy(t){return this.x=t.x,this.y=t.y,this.z=t.z,this.w=t.w!==void 0?t.w:1,this}add(t){return this.x+=t.x,this.y+=t.y,this.z+=t.z,this.w+=t.w,this}addScalar(t){return this.x+=t,this.y+=t,this.z+=t,this.w+=t,this}addVectors(t,e){return this.x=t.x+e.x,this.y=t.y+e.y,this.z=t.z+e.z,this.w=t.w+e.w,this}addScaledVector(t,e){return this.x+=t.x*e,this.y+=t.y*e,this.z+=t.z*e,this.w+=t.w*e,this}sub(t){return this.x-=t.x,this.y-=t.y,this.z-=t.z,this.w-=t.w,this}subScalar(t){return this.x-=t,this.y-=t,this.z-=t,this.w-=t,this}subVectors(t,e){return this.x=t.x-e.x,this.y=t.y-e.y,this.z=t.z-e.z,this.w=t.w-e.w,this}multiply(t){return this.x*=t.x,this.y*=t.y,this.z*=t.z,this.w*=t.w,this}multiplyScalar(t){return this.x*=t,this.y*=t,this.z*=t,this.w*=t,this}applyMatrix4(t){let e=this.x,i=this.y,n=this.z,r=this.w,o=t.elements;return this.x=o[0]*e+o[4]*i+o[8]*n+o[12]*r,this.y=o[1]*e+o[5]*i+o[9]*n+o[13]*r,this.z=o[2]*e+o[6]*i+o[10]*n+o[14]*r,this.w=o[3]*e+o[7]*i+o[11]*n+o[15]*r,this}divide(t){return this.x/=t.x,this.y/=t.y,this.z/=t.z,this.w/=t.w,this}divideScalar(t){return this.multiplyScalar(1/t)}setAxisAngleFromQuaternion(t){this.w=2*Math.acos(t.w);let e=Math.sqrt(1-t.w*t.w);return e<1e-4?(this.x=1,this.y=0,this.z=0):(this.x=t.x/e,this.y=t.y/e,this.z=t.z/e),this}setAxisAngleFromRotationMatrix(t){let e,i,n,r,l=t.elements,c=l[0],h=l[4],u=l[8],f=l[1],d=l[5],g=l[9],x=l[2],m=l[6],p=l[10];if(Math.abs(h-f)<.01&&Math.abs(u-x)<.01&&Math.abs(g-m)<.01){if(Math.abs(h+f)<.1&&Math.abs(u+x)<.1&&Math.abs(g+m)<.1&&Math.abs(c+d+p-3)<.1)return this.set(1,0,0,0),this;e=Math.PI;let y=(c+1)/2,_=(d+1)/2,b=(p+1)/2,E=(h+f)/4,P=(u+x)/4,L=(g+m)/4;return y>_&&y>b?y<.01?(i=0,n=.707106781,r=.707106781):(i=Math.sqrt(y),n=E/i,r=P/i):_>b?_<.01?(i=.707106781,n=0,r=.707106781):(n=Math.sqrt(_),i=E/n,r=L/n):b<.01?(i=.707106781,n=.707106781,r=0):(r=Math.sqrt(b),i=P/r,n=L/r),this.set(i,n,r,e),this}let M=Math.sqrt((m-g)*(m-g)+(u-x)*(u-x)+(f-h)*(f-h));return Math.abs(M)<.001&&(M=1),this.x=(m-g)/M,this.y=(u-x)/M,this.z=(f-h)/M,this.w=Math.acos((c+d+p-1)/2),this}setFromMatrixPosition(t){let e=t.elements;return this.x=e[12],this.y=e[13],this.z=e[14],this.w=e[15],this}min(t){return this.x=Math.min(this.x,t.x),this.y=Math.min(this.y,t.y),this.z=Math.min(this.z,t.z),this.w=Math.min(this.w,t.w),this}max(t){return this.x=Math.max(this.x,t.x),this.y=Math.max(this.y,t.y),this.z=Math.max(this.z,t.z),this.w=Math.max(this.w,t.w),this}clamp(t,e){return this.x=Zt(this.x,t.x,e.x),this.y=Zt(this.y,t.y,e.y),this.z=Zt(this.z,t.z,e.z),this.w=Zt(this.w,t.w,e.w),this}clampScalar(t,e){return this.x=Zt(this.x,t,e),this.y=Zt(this.y,t,e),this.z=Zt(this.z,t,e),this.w=Zt(this.w,t,e),this}clampLength(t,e){let i=this.length();return this.divideScalar(i||1).multiplyScalar(Zt(i,t,e))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this.w=Math.floor(this.w),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this.w=Math.ceil(this.w),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this.w=Math.round(this.w),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this.z=Math.trunc(this.z),this.w=Math.trunc(this.w),this}negate(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this.w=-this.w,this}dot(t){return this.x*t.x+this.y*t.y+this.z*t.z+this.w*t.w}lengthSq(){return this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w}length(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)+Math.abs(this.w)}normalize(){return this.divideScalar(this.length()||1)}setLength(t){return this.normalize().multiplyScalar(t)}lerp(t,e){return this.x+=(t.x-this.x)*e,this.y+=(t.y-this.y)*e,this.z+=(t.z-this.z)*e,this.w+=(t.w-this.w)*e,this}lerpVectors(t,e,i){return this.x=t.x+(e.x-t.x)*i,this.y=t.y+(e.y-t.y)*i,this.z=t.z+(e.z-t.z)*i,this.w=t.w+(e.w-t.w)*i,this}equals(t){return t.x===this.x&&t.y===this.y&&t.z===this.z&&t.w===this.w}fromArray(t,e=0){return this.x=t[e],this.y=t[e+1],this.z=t[e+2],this.w=t[e+3],this}toArray(t=[],e=0){return t[e]=this.x,t[e+1]=this.y,t[e+2]=this.z,t[e+3]=this.w,t}fromBufferAttribute(t,e){return this.x=t.getX(e),this.y=t.getY(e),this.z=t.getZ(e),this.w=t.getW(e),this}random(){return this.x=Math.random(),this.y=Math.random(),this.z=Math.random(),this.w=Math.random(),this}*[Symbol.iterator](){yield this.x,yield this.y,yield this.z,yield this.w}},pa=class extends rn{constructor(t=1,e=1,i={}){super(),i=Object.assign({generateMipmaps:!1,internalFormat:null,minFilter:Ni,depthBuffer:!0,stencilBuffer:!1,resolveDepthBuffer:!0,resolveStencilBuffer:!0,depthTexture:null,samples:0,count:1,depth:1,multiview:!1},i),this.isRenderTarget=!0,this.width=t,this.height=e,this.depth=i.depth,this.scissor=new ie(0,0,t,e),this.scissorTest=!1,this.viewport=new ie(0,0,t,e);let n={width:t,height:e,depth:i.depth},r=new si(n);this.textures=[];let o=i.count;for(let a=0;a<o;a++)this.textures[a]=r.clone(),this.textures[a].isRenderTargetTexture=!0,this.textures[a].renderTarget=this;this._setTextureOptions(i),this.depthBuffer=i.depthBuffer,this.stencilBuffer=i.stencilBuffer,this.resolveDepthBuffer=i.resolveDepthBuffer,this.resolveStencilBuffer=i.resolveStencilBuffer,this._depthTexture=null,this.depthTexture=i.depthTexture,this.samples=i.samples,this.multiview=i.multiview}_setTextureOptions(t={}){let e={minFilter:Ni,generateMipmaps:!1,flipY:!1,internalFormat:null};t.mapping!==void 0&&(e.mapping=t.mapping),t.wrapS!==void 0&&(e.wrapS=t.wrapS),t.wrapT!==void 0&&(e.wrapT=t.wrapT),t.wrapR!==void 0&&(e.wrapR=t.wrapR),t.magFilter!==void 0&&(e.magFilter=t.magFilter),t.minFilter!==void 0&&(e.minFilter=t.minFilter),t.format!==void 0&&(e.format=t.format),t.type!==void 0&&(e.type=t.type),t.anisotropy!==void 0&&(e.anisotropy=t.anisotropy),t.colorSpace!==void 0&&(e.colorSpace=t.colorSpace),t.flipY!==void 0&&(e.flipY=t.flipY),t.generateMipmaps!==void 0&&(e.generateMipmaps=t.generateMipmaps),t.internalFormat!==void 0&&(e.internalFormat=t.internalFormat);for(let i=0;i<this.textures.length;i++)this.textures[i].setValues(e)}get texture(){return this.textures[0]}set texture(t){this.textures[0]=t}set depthTexture(t){this._depthTexture!==null&&(this._depthTexture.renderTarget=null),t!==null&&(t.renderTarget=this),this._depthTexture=t}get depthTexture(){return this._depthTexture}setSize(t,e,i=1){if(this.width!==t||this.height!==e||this.depth!==i){this.width=t,this.height=e,this.depth=i;for(let n=0,r=this.textures.length;n<r;n++)this.textures[n].image.width=t,this.textures[n].image.height=e,this.textures[n].image.depth=i,this.textures[n].isArrayTexture=this.textures[n].image.depth>1;this.dispose()}this.viewport.set(0,0,t,e),this.scissor.set(0,0,t,e)}clone(){return new this.constructor().copy(this)}copy(t){this.width=t.width,this.height=t.height,this.depth=t.depth,this.scissor.copy(t.scissor),this.scissorTest=t.scissorTest,this.viewport.copy(t.viewport),this.textures.length=0;for(let e=0,i=t.textures.length;e<i;e++){this.textures[e]=t.textures[e].clone(),this.textures[e].isRenderTargetTexture=!0,this.textures[e].renderTarget=this;let n=Object.assign({},t.textures[e].image);this.textures[e].source=new Is(n)}return this.depthBuffer=t.depthBuffer,this.stencilBuffer=t.stencilBuffer,this.resolveDepthBuffer=t.resolveDepthBuffer,this.resolveStencilBuffer=t.resolveStencilBuffer,t.depthTexture!==null&&(this.depthTexture=t.depthTexture.clone()),this.samples=t.samples,this}dispose(){this.dispatchEvent({type:"dispose"})}},wi=class extends pa{constructor(t=1,e=1,i={}){super(t,e,i),this.isWebGLRenderTarget=!0}},Er=class extends si{constructor(t=null,e=1,i=1,n=1){super(null),this.isDataArrayTexture=!0,this.image={data:t,width:e,height:i,depth:n},this.magFilter=li,this.minFilter=li,this.wrapR=bn,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1,this.layerUpdates=new Set}addLayerUpdate(t){this.layerUpdates.add(t)}clearLayerUpdates(){this.layerUpdates.clear()}};var ma=class extends si{constructor(t=null,e=1,i=1,n=1){super(null),this.isData3DTexture=!0,this.image={data:t,width:e,height:i,depth:n},this.magFilter=li,this.minFilter=li,this.wrapR=bn,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1}};var We=class{constructor(t=new T(1/0,1/0,1/0),e=new T(-1/0,-1/0,-1/0)){this.isBox3=!0,this.min=t,this.max=e}set(t,e){return this.min.copy(t),this.max.copy(e),this}setFromArray(t){this.makeEmpty();for(let e=0,i=t.length;e<i;e+=3)this.expandByPoint(Ri.fromArray(t,e));return this}setFromBufferAttribute(t){this.makeEmpty();for(let e=0,i=t.count;e<i;e++)this.expandByPoint(Ri.fromBufferAttribute(t,e));return this}setFromPoints(t){this.makeEmpty();for(let e=0,i=t.length;e<i;e++)this.expandByPoint(t[e]);return this}setFromCenterAndSize(t,e){let i=Ri.copy(e).multiplyScalar(.5);return this.min.copy(t).sub(i),this.max.copy(t).add(i),this}setFromObject(t,e=!1){return this.makeEmpty(),this.expandByObject(t,e)}clone(){return new this.constructor().copy(this)}copy(t){return this.min.copy(t.min),this.max.copy(t.max),this}makeEmpty(){return this.min.x=this.min.y=this.min.z=1/0,this.max.x=this.max.y=this.max.z=-1/0,this}isEmpty(){return this.max.x<this.min.x||this.max.y<this.min.y||this.max.z<this.min.z}getCenter(t){return this.isEmpty()?t.set(0,0,0):t.addVectors(this.min,this.max).multiplyScalar(.5)}getSize(t){return this.isEmpty()?t.set(0,0,0):t.subVectors(this.max,this.min)}expandByPoint(t){return this.min.min(t),this.max.max(t),this}expandByVector(t){return this.min.sub(t),this.max.add(t),this}expandByScalar(t){return this.min.addScalar(-t),this.max.addScalar(t),this}expandByObject(t,e=!1){t.updateWorldMatrix(!1,!1);let i=t.geometry;if(i!==void 0){let r=i.getAttribute("position");if(e===!0&&r!==void 0&&t.isInstancedMesh!==!0)for(let o=0,a=r.count;o<a;o++)t.isMesh===!0?t.getVertexPosition(o,Ri):Ri.fromBufferAttribute(r,o),Ri.applyMatrix4(t.matrixWorld),this.expandByPoint(Ri);else t.boundingBox!==void 0?(t.boundingBox===null&&t.computeBoundingBox(),Do.copy(t.boundingBox)):(i.boundingBox===null&&i.computeBoundingBox(),Do.copy(i.boundingBox)),Do.applyMatrix4(t.matrixWorld),this.union(Do)}let n=t.children;for(let r=0,o=n.length;r<o;r++)this.expandByObject(n[r],e);return this}containsPoint(t){return t.x>=this.min.x&&t.x<=this.max.x&&t.y>=this.min.y&&t.y<=this.max.y&&t.z>=this.min.z&&t.z<=this.max.z}containsBox(t){return this.min.x<=t.min.x&&t.max.x<=this.max.x&&this.min.y<=t.min.y&&t.max.y<=this.max.y&&this.min.z<=t.min.z&&t.max.z<=this.max.z}getParameter(t,e){return e.set((t.x-this.min.x)/(this.max.x-this.min.x),(t.y-this.min.y)/(this.max.y-this.min.y),(t.z-this.min.z)/(this.max.z-this.min.z))}intersectsBox(t){return t.max.x>=this.min.x&&t.min.x<=this.max.x&&t.max.y>=this.min.y&&t.min.y<=this.max.y&&t.max.z>=this.min.z&&t.min.z<=this.max.z}intersectsSphere(t){return this.clampPoint(t.center,Ri),Ri.distanceToSquared(t.center)<=t.radius*t.radius}intersectsPlane(t){let e,i;return t.normal.x>0?(e=t.normal.x*this.min.x,i=t.normal.x*this.max.x):(e=t.normal.x*this.max.x,i=t.normal.x*this.min.x),t.normal.y>0?(e+=t.normal.y*this.min.y,i+=t.normal.y*this.max.y):(e+=t.normal.y*this.max.y,i+=t.normal.y*this.min.y),t.normal.z>0?(e+=t.normal.z*this.min.z,i+=t.normal.z*this.max.z):(e+=t.normal.z*this.max.z,i+=t.normal.z*this.min.z),e<=-t.constant&&i>=-t.constant}intersectsTriangle(t){if(this.isEmpty())return!1;this.getCenter(or),Uo.subVectors(this.max,or),cs.subVectors(t.a,or),hs.subVectors(t.b,or),us.subVectors(t.c,or),gn.subVectors(hs,cs),xn.subVectors(us,hs),kn.subVectors(cs,us);let e=[0,-gn.z,gn.y,0,-xn.z,xn.y,0,-kn.z,kn.y,gn.z,0,-gn.x,xn.z,0,-xn.x,kn.z,0,-kn.x,-gn.y,gn.x,0,-xn.y,xn.x,0,-kn.y,kn.x,0];return!yc(e,cs,hs,us,Uo)||(e=[1,0,0,0,1,0,0,0,1],!yc(e,cs,hs,us,Uo))?!1:(No.crossVectors(gn,xn),e=[No.x,No.y,No.z],yc(e,cs,hs,us,Uo))}clampPoint(t,e){return e.copy(t).clamp(this.min,this.max)}distanceToPoint(t){return this.clampPoint(t,Ri).distanceTo(t)}getBoundingSphere(t){return this.isEmpty()?t.makeEmpty():(this.getCenter(t.center),t.radius=this.getSize(Ri).length()*.5),t}intersect(t){return this.min.max(t.min),this.max.min(t.max),this.isEmpty()&&this.makeEmpty(),this}union(t){return this.min.min(t.min),this.max.max(t.max),this}applyMatrix4(t){return this.isEmpty()?this:(Ki[0].set(this.min.x,this.min.y,this.min.z).applyMatrix4(t),Ki[1].set(this.min.x,this.min.y,this.max.z).applyMatrix4(t),Ki[2].set(this.min.x,this.max.y,this.min.z).applyMatrix4(t),Ki[3].set(this.min.x,this.max.y,this.max.z).applyMatrix4(t),Ki[4].set(this.max.x,this.min.y,this.min.z).applyMatrix4(t),Ki[5].set(this.max.x,this.min.y,this.max.z).applyMatrix4(t),Ki[6].set(this.max.x,this.max.y,this.min.z).applyMatrix4(t),Ki[7].set(this.max.x,this.max.y,this.max.z).applyMatrix4(t),this.setFromPoints(Ki),this)}translate(t){return this.min.add(t),this.max.add(t),this}equals(t){return t.min.equals(this.min)&&t.max.equals(this.max)}toJSON(){return{min:this.min.toArray(),max:this.max.toArray()}}fromJSON(t){return this.min.fromArray(t.min),this.max.fromArray(t.max),this}},Ki=[new T,new T,new T,new T,new T,new T,new T,new T],Ri=new T,Do=new We,cs=new T,hs=new T,us=new T,gn=new T,xn=new T,kn=new T,or=new T,Uo=new T,No=new T,Bn=new T;function yc(s,t,e,i,n){for(let r=0,o=s.length-3;r<=o;r+=3){Bn.fromArray(s,r);let a=n.x*Math.abs(Bn.x)+n.y*Math.abs(Bn.y)+n.z*Math.abs(Bn.z),l=t.dot(Bn),c=e.dot(Bn),h=i.dot(Bn);if(Math.max(-Math.max(l,c,h),Math.min(l,c,h))>a)return!1}return!0}var $p=new We,ar=new T,vc=new T,ri=class{constructor(t=new T,e=-1){this.isSphere=!0,this.center=t,this.radius=e}set(t,e){return this.center.copy(t),this.radius=e,this}setFromPoints(t,e){let i=this.center;e!==void 0?i.copy(e):$p.setFromPoints(t).getCenter(i);let n=0;for(let r=0,o=t.length;r<o;r++)n=Math.max(n,i.distanceToSquared(t[r]));return this.radius=Math.sqrt(n),this}copy(t){return this.center.copy(t.center),this.radius=t.radius,this}isEmpty(){return this.radius<0}makeEmpty(){return this.center.set(0,0,0),this.radius=-1,this}containsPoint(t){return t.distanceToSquared(this.center)<=this.radius*this.radius}distanceToPoint(t){return t.distanceTo(this.center)-this.radius}intersectsSphere(t){let e=this.radius+t.radius;return t.center.distanceToSquared(this.center)<=e*e}intersectsBox(t){return t.intersectsSphere(this)}intersectsPlane(t){return Math.abs(t.distanceToPoint(this.center))<=this.radius}clampPoint(t,e){let i=this.center.distanceToSquared(t);return e.copy(t),i>this.radius*this.radius&&(e.sub(this.center).normalize(),e.multiplyScalar(this.radius).add(this.center)),e}getBoundingBox(t){return this.isEmpty()?(t.makeEmpty(),t):(t.set(this.center,this.center),t.expandByScalar(this.radius),t)}applyMatrix4(t){return this.center.applyMatrix4(t),this.radius=this.radius*t.getMaxScaleOnAxis(),this}translate(t){return this.center.add(t),this}expandByPoint(t){if(this.isEmpty())return this.center.copy(t),this.radius=0,this;ar.subVectors(t,this.center);let e=ar.lengthSq();if(e>this.radius*this.radius){let i=Math.sqrt(e),n=(i-this.radius)*.5;this.center.addScaledVector(ar,n/i),this.radius+=n}return this}union(t){return t.isEmpty()?this:this.isEmpty()?(this.copy(t),this):(this.center.equals(t.center)===!0?this.radius=Math.max(this.radius,t.radius):(vc.subVectors(t.center,this.center).setLength(t.radius),this.expandByPoint(ar.copy(t.center).add(vc)),this.expandByPoint(ar.copy(t.center).sub(vc))),this)}equals(t){return t.center.equals(this.center)&&t.radius===this.radius}clone(){return new this.constructor().copy(this)}toJSON(){return{radius:this.radius,center:this.center.toArray()}}fromJSON(t){return this.radius=t.radius,this.center.fromArray(t.center),this}},ji=new T,Mc=new T,Fo=new T,_n=new T,bc=new T,ko=new T,wc=new T,Ps=class{constructor(t=new T,e=new T(0,0,-1)){this.origin=t,this.direction=e}set(t,e){return this.origin.copy(t),this.direction.copy(e),this}copy(t){return this.origin.copy(t.origin),this.direction.copy(t.direction),this}at(t,e){return e.copy(this.origin).addScaledVector(this.direction,t)}lookAt(t){return this.direction.copy(t).sub(this.origin).normalize(),this}recast(t){return this.origin.copy(this.at(t,ji)),this}closestPointToPoint(t,e){e.subVectors(t,this.origin);let i=e.dot(this.direction);return i<0?e.copy(this.origin):e.copy(this.origin).addScaledVector(this.direction,i)}distanceToPoint(t){return Math.sqrt(this.distanceSqToPoint(t))}distanceSqToPoint(t){let e=ji.subVectors(t,this.origin).dot(this.direction);return e<0?this.origin.distanceToSquared(t):(ji.copy(this.origin).addScaledVector(this.direction,e),ji.distanceToSquared(t))}distanceSqToSegment(t,e,i,n){Mc.copy(t).add(e).multiplyScalar(.5),Fo.copy(e).sub(t).normalize(),_n.copy(this.origin).sub(Mc);let r=t.distanceTo(e)*.5,o=-this.direction.dot(Fo),a=_n.dot(this.direction),l=-_n.dot(Fo),c=_n.lengthSq(),h=Math.abs(1-o*o),u,f,d,g;if(h>0)if(u=o*l-a,f=o*a-l,g=r*h,u>=0)if(f>=-g)if(f<=g){let x=1/h;u*=x,f*=x,d=u*(u+o*f+2*a)+f*(o*u+f+2*l)+c}else f=r,u=Math.max(0,-(o*f+a)),d=-u*u+f*(f+2*l)+c;else f=-r,u=Math.max(0,-(o*f+a)),d=-u*u+f*(f+2*l)+c;else f<=-g?(u=Math.max(0,-(-o*r+a)),f=u>0?-r:Math.min(Math.max(-r,-l),r),d=-u*u+f*(f+2*l)+c):f<=g?(u=0,f=Math.min(Math.max(-r,-l),r),d=f*(f+2*l)+c):(u=Math.max(0,-(o*r+a)),f=u>0?r:Math.min(Math.max(-r,-l),r),d=-u*u+f*(f+2*l)+c);else f=o>0?-r:r,u=Math.max(0,-(o*f+a)),d=-u*u+f*(f+2*l)+c;return i&&i.copy(this.origin).addScaledVector(this.direction,u),n&&n.copy(Mc).addScaledVector(Fo,f),d}intersectSphere(t,e){ji.subVectors(t.center,this.origin);let i=ji.dot(this.direction),n=ji.dot(ji)-i*i,r=t.radius*t.radius;if(n>r)return null;let o=Math.sqrt(r-n),a=i-o,l=i+o;return l<0?null:a<0?this.at(l,e):this.at(a,e)}intersectsSphere(t){return t.radius<0?!1:this.distanceSqToPoint(t.center)<=t.radius*t.radius}distanceToPlane(t){let e=t.normal.dot(this.direction);if(e===0)return t.distanceToPoint(this.origin)===0?0:null;let i=-(this.origin.dot(t.normal)+t.constant)/e;return i>=0?i:null}intersectPlane(t,e){let i=this.distanceToPlane(t);return i===null?null:this.at(i,e)}intersectsPlane(t){let e=t.distanceToPoint(this.origin);return e===0||t.normal.dot(this.direction)*e<0}intersectBox(t,e){let i,n,r,o,a,l,c=1/this.direction.x,h=1/this.direction.y,u=1/this.direction.z,f=this.origin;return c>=0?(i=(t.min.x-f.x)*c,n=(t.max.x-f.x)*c):(i=(t.max.x-f.x)*c,n=(t.min.x-f.x)*c),h>=0?(r=(t.min.y-f.y)*h,o=(t.max.y-f.y)*h):(r=(t.max.y-f.y)*h,o=(t.min.y-f.y)*h),i>o||r>n||((r>i||isNaN(i))&&(i=r),(o<n||isNaN(n))&&(n=o),u>=0?(a=(t.min.z-f.z)*u,l=(t.max.z-f.z)*u):(a=(t.max.z-f.z)*u,l=(t.min.z-f.z)*u),i>l||a>n)||((a>i||i!==i)&&(i=a),(l<n||n!==n)&&(n=l),n<0)?null:this.at(i>=0?i:n,e)}intersectsBox(t){return this.intersectBox(t,ji)!==null}intersectTriangle(t,e,i,n,r){bc.subVectors(e,t),ko.subVectors(i,t),wc.crossVectors(bc,ko);let o=this.direction.dot(wc),a;if(o>0){if(n)return null;a=1}else if(o<0)a=-1,o=-o;else return null;_n.subVectors(this.origin,t);let l=a*this.direction.dot(ko.crossVectors(_n,ko));if(l<0)return null;let c=a*this.direction.dot(bc.cross(_n));if(c<0||l+c>o)return null;let h=-a*_n.dot(wc);return h<0?null:this.at(h/o,r)}applyMatrix4(t){return this.origin.applyMatrix4(t),this.direction.transformDirection(t),this}equals(t){return t.origin.equals(this.origin)&&t.direction.equals(this.direction)}clone(){return new this.constructor().copy(this)}},Ut=class s{constructor(t,e,i,n,r,o,a,l,c,h,u,f,d,g,x,m){s.prototype.isMatrix4=!0,this.elements=[1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1],t!==void 0&&this.set(t,e,i,n,r,o,a,l,c,h,u,f,d,g,x,m)}set(t,e,i,n,r,o,a,l,c,h,u,f,d,g,x,m){let p=this.elements;return p[0]=t,p[4]=e,p[8]=i,p[12]=n,p[1]=r,p[5]=o,p[9]=a,p[13]=l,p[2]=c,p[6]=h,p[10]=u,p[14]=f,p[3]=d,p[7]=g,p[11]=x,p[15]=m,this}identity(){return this.set(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1),this}clone(){return new s().fromArray(this.elements)}copy(t){let e=this.elements,i=t.elements;return e[0]=i[0],e[1]=i[1],e[2]=i[2],e[3]=i[3],e[4]=i[4],e[5]=i[5],e[6]=i[6],e[7]=i[7],e[8]=i[8],e[9]=i[9],e[10]=i[10],e[11]=i[11],e[12]=i[12],e[13]=i[13],e[14]=i[14],e[15]=i[15],this}copyPosition(t){let e=this.elements,i=t.elements;return e[12]=i[12],e[13]=i[13],e[14]=i[14],this}setFromMatrix3(t){let e=t.elements;return this.set(e[0],e[3],e[6],0,e[1],e[4],e[7],0,e[2],e[5],e[8],0,0,0,0,1),this}extractBasis(t,e,i){return t.setFromMatrixColumn(this,0),e.setFromMatrixColumn(this,1),i.setFromMatrixColumn(this,2),this}makeBasis(t,e,i){return this.set(t.x,e.x,i.x,0,t.y,e.y,i.y,0,t.z,e.z,i.z,0,0,0,0,1),this}extractRotation(t){let e=this.elements,i=t.elements,n=1/ds.setFromMatrixColumn(t,0).length(),r=1/ds.setFromMatrixColumn(t,1).length(),o=1/ds.setFromMatrixColumn(t,2).length();return e[0]=i[0]*n,e[1]=i[1]*n,e[2]=i[2]*n,e[3]=0,e[4]=i[4]*r,e[5]=i[5]*r,e[6]=i[6]*r,e[7]=0,e[8]=i[8]*o,e[9]=i[9]*o,e[10]=i[10]*o,e[11]=0,e[12]=0,e[13]=0,e[14]=0,e[15]=1,this}makeRotationFromEuler(t){let e=this.elements,i=t.x,n=t.y,r=t.z,o=Math.cos(i),a=Math.sin(i),l=Math.cos(n),c=Math.sin(n),h=Math.cos(r),u=Math.sin(r);if(t.order==="XYZ"){let f=o*h,d=o*u,g=a*h,x=a*u;e[0]=l*h,e[4]=-l*u,e[8]=c,e[1]=d+g*c,e[5]=f-x*c,e[9]=-a*l,e[2]=x-f*c,e[6]=g+d*c,e[10]=o*l}else if(t.order==="YXZ"){let f=l*h,d=l*u,g=c*h,x=c*u;e[0]=f+x*a,e[4]=g*a-d,e[8]=o*c,e[1]=o*u,e[5]=o*h,e[9]=-a,e[2]=d*a-g,e[6]=x+f*a,e[10]=o*l}else if(t.order==="ZXY"){let f=l*h,d=l*u,g=c*h,x=c*u;e[0]=f-x*a,e[4]=-o*u,e[8]=g+d*a,e[1]=d+g*a,e[5]=o*h,e[9]=x-f*a,e[2]=-o*c,e[6]=a,e[10]=o*l}else if(t.order==="ZYX"){let f=o*h,d=o*u,g=a*h,x=a*u;e[0]=l*h,e[4]=g*c-d,e[8]=f*c+x,e[1]=l*u,e[5]=x*c+f,e[9]=d*c-g,e[2]=-c,e[6]=a*l,e[10]=o*l}else if(t.order==="YZX"){let f=o*l,d=o*c,g=a*l,x=a*c;e[0]=l*h,e[4]=x-f*u,e[8]=g*u+d,e[1]=u,e[5]=o*h,e[9]=-a*h,e[2]=-c*h,e[6]=d*u+g,e[10]=f-x*u}else if(t.order==="XZY"){let f=o*l,d=o*c,g=a*l,x=a*c;e[0]=l*h,e[4]=-u,e[8]=c*h,e[1]=f*u+x,e[5]=o*h,e[9]=d*u-g,e[2]=g*u-d,e[6]=a*h,e[10]=x*u+f}return e[3]=0,e[7]=0,e[11]=0,e[12]=0,e[13]=0,e[14]=0,e[15]=1,this}makeRotationFromQuaternion(t){return this.compose(Jp,t,Kp)}lookAt(t,e,i){let n=this.elements;return di.subVectors(t,e),di.lengthSq()===0&&(di.z=1),di.normalize(),yn.crossVectors(i,di),yn.lengthSq()===0&&(Math.abs(i.z)===1?di.x+=1e-4:di.z+=1e-4,di.normalize(),yn.crossVectors(i,di)),yn.normalize(),Bo.crossVectors(di,yn),n[0]=yn.x,n[4]=Bo.x,n[8]=di.x,n[1]=yn.y,n[5]=Bo.y,n[9]=di.y,n[2]=yn.z,n[6]=Bo.z,n[10]=di.z,this}multiply(t){return this.multiplyMatrices(this,t)}premultiply(t){return this.multiplyMatrices(t,this)}multiplyMatrices(t,e){let i=t.elements,n=e.elements,r=this.elements,o=i[0],a=i[4],l=i[8],c=i[12],h=i[1],u=i[5],f=i[9],d=i[13],g=i[2],x=i[6],m=i[10],p=i[14],M=i[3],y=i[7],_=i[11],b=i[15],E=n[0],P=n[4],L=n[8],w=n[12],v=n[1],C=n[5],U=n[9],O=n[13],z=n[2],q=n[6],H=n[10],it=n[14],X=n[3],ct=n[7],mt=n[11],bt=n[15];return r[0]=o*E+a*v+l*z+c*X,r[4]=o*P+a*C+l*q+c*ct,r[8]=o*L+a*U+l*H+c*mt,r[12]=o*w+a*O+l*it+c*bt,r[1]=h*E+u*v+f*z+d*X,r[5]=h*P+u*C+f*q+d*ct,r[9]=h*L+u*U+f*H+d*mt,r[13]=h*w+u*O+f*it+d*bt,r[2]=g*E+x*v+m*z+p*X,r[6]=g*P+x*C+m*q+p*ct,r[10]=g*L+x*U+m*H+p*mt,r[14]=g*w+x*O+m*it+p*bt,r[3]=M*E+y*v+_*z+b*X,r[7]=M*P+y*C+_*q+b*ct,r[11]=M*L+y*U+_*H+b*mt,r[15]=M*w+y*O+_*it+b*bt,this}multiplyScalar(t){let e=this.elements;return e[0]*=t,e[4]*=t,e[8]*=t,e[12]*=t,e[1]*=t,e[5]*=t,e[9]*=t,e[13]*=t,e[2]*=t,e[6]*=t,e[10]*=t,e[14]*=t,e[3]*=t,e[7]*=t,e[11]*=t,e[15]*=t,this}determinant(){let t=this.elements,e=t[0],i=t[4],n=t[8],r=t[12],o=t[1],a=t[5],l=t[9],c=t[13],h=t[2],u=t[6],f=t[10],d=t[14],g=t[3],x=t[7],m=t[11],p=t[15];return g*(+r*l*u-n*c*u-r*a*f+i*c*f+n*a*d-i*l*d)+x*(+e*l*d-e*c*f+r*o*f-n*o*d+n*c*h-r*l*h)+m*(+e*c*u-e*a*d-r*o*u+i*o*d+r*a*h-i*c*h)+p*(-n*a*h-e*l*u+e*a*f+n*o*u-i*o*f+i*l*h)}transpose(){let t=this.elements,e;return e=t[1],t[1]=t[4],t[4]=e,e=t[2],t[2]=t[8],t[8]=e,e=t[6],t[6]=t[9],t[9]=e,e=t[3],t[3]=t[12],t[12]=e,e=t[7],t[7]=t[13],t[13]=e,e=t[11],t[11]=t[14],t[14]=e,this}setPosition(t,e,i){let n=this.elements;return t.isVector3?(n[12]=t.x,n[13]=t.y,n[14]=t.z):(n[12]=t,n[13]=e,n[14]=i),this}invert(){let t=this.elements,e=t[0],i=t[1],n=t[2],r=t[3],o=t[4],a=t[5],l=t[6],c=t[7],h=t[8],u=t[9],f=t[10],d=t[11],g=t[12],x=t[13],m=t[14],p=t[15],M=u*m*c-x*f*c+x*l*d-a*m*d-u*l*p+a*f*p,y=g*f*c-h*m*c-g*l*d+o*m*d+h*l*p-o*f*p,_=h*x*c-g*u*c+g*a*d-o*x*d-h*a*p+o*u*p,b=g*u*l-h*x*l-g*a*f+o*x*f+h*a*m-o*u*m,E=e*M+i*y+n*_+r*b;if(E===0)return this.set(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);let P=1/E;return t[0]=M*P,t[1]=(x*f*r-u*m*r-x*n*d+i*m*d+u*n*p-i*f*p)*P,t[2]=(a*m*r-x*l*r+x*n*c-i*m*c-a*n*p+i*l*p)*P,t[3]=(u*l*r-a*f*r-u*n*c+i*f*c+a*n*d-i*l*d)*P,t[4]=y*P,t[5]=(h*m*r-g*f*r+g*n*d-e*m*d-h*n*p+e*f*p)*P,t[6]=(g*l*r-o*m*r-g*n*c+e*m*c+o*n*p-e*l*p)*P,t[7]=(o*f*r-h*l*r+h*n*c-e*f*c-o*n*d+e*l*d)*P,t[8]=_*P,t[9]=(g*u*r-h*x*r-g*i*d+e*x*d+h*i*p-e*u*p)*P,t[10]=(o*x*r-g*a*r+g*i*c-e*x*c-o*i*p+e*a*p)*P,t[11]=(h*a*r-o*u*r-h*i*c+e*u*c+o*i*d-e*a*d)*P,t[12]=b*P,t[13]=(h*x*n-g*u*n+g*i*f-e*x*f-h*i*m+e*u*m)*P,t[14]=(g*a*n-o*x*n-g*i*l+e*x*l+o*i*m-e*a*m)*P,t[15]=(o*u*n-h*a*n+h*i*l-e*u*l-o*i*f+e*a*f)*P,this}scale(t){let e=this.elements,i=t.x,n=t.y,r=t.z;return e[0]*=i,e[4]*=n,e[8]*=r,e[1]*=i,e[5]*=n,e[9]*=r,e[2]*=i,e[6]*=n,e[10]*=r,e[3]*=i,e[7]*=n,e[11]*=r,this}getMaxScaleOnAxis(){let t=this.elements,e=t[0]*t[0]+t[1]*t[1]+t[2]*t[2],i=t[4]*t[4]+t[5]*t[5]+t[6]*t[6],n=t[8]*t[8]+t[9]*t[9]+t[10]*t[10];return Math.sqrt(Math.max(e,i,n))}makeTranslation(t,e,i){return t.isVector3?this.set(1,0,0,t.x,0,1,0,t.y,0,0,1,t.z,0,0,0,1):this.set(1,0,0,t,0,1,0,e,0,0,1,i,0,0,0,1),this}makeRotationX(t){let e=Math.cos(t),i=Math.sin(t);return this.set(1,0,0,0,0,e,-i,0,0,i,e,0,0,0,0,1),this}makeRotationY(t){let e=Math.cos(t),i=Math.sin(t);return this.set(e,0,i,0,0,1,0,0,-i,0,e,0,0,0,0,1),this}makeRotationZ(t){let e=Math.cos(t),i=Math.sin(t);return this.set(e,-i,0,0,i,e,0,0,0,0,1,0,0,0,0,1),this}makeRotationAxis(t,e){let i=Math.cos(e),n=Math.sin(e),r=1-i,o=t.x,a=t.y,l=t.z,c=r*o,h=r*a;return this.set(c*o+i,c*a-n*l,c*l+n*a,0,c*a+n*l,h*a+i,h*l-n*o,0,c*l-n*a,h*l+n*o,r*l*l+i,0,0,0,0,1),this}makeScale(t,e,i){return this.set(t,0,0,0,0,e,0,0,0,0,i,0,0,0,0,1),this}makeShear(t,e,i,n,r,o){return this.set(1,i,r,0,t,1,o,0,e,n,1,0,0,0,0,1),this}compose(t,e,i){let n=this.elements,r=e._x,o=e._y,a=e._z,l=e._w,c=r+r,h=o+o,u=a+a,f=r*c,d=r*h,g=r*u,x=o*h,m=o*u,p=a*u,M=l*c,y=l*h,_=l*u,b=i.x,E=i.y,P=i.z;return n[0]=(1-(x+p))*b,n[1]=(d+_)*b,n[2]=(g-y)*b,n[3]=0,n[4]=(d-_)*E,n[5]=(1-(f+p))*E,n[6]=(m+M)*E,n[7]=0,n[8]=(g+y)*P,n[9]=(m-M)*P,n[10]=(1-(f+x))*P,n[11]=0,n[12]=t.x,n[13]=t.y,n[14]=t.z,n[15]=1,this}decompose(t,e,i){let n=this.elements,r=ds.set(n[0],n[1],n[2]).length(),o=ds.set(n[4],n[5],n[6]).length(),a=ds.set(n[8],n[9],n[10]).length();this.determinant()<0&&(r=-r),t.x=n[12],t.y=n[13],t.z=n[14],Ci.copy(this);let c=1/r,h=1/o,u=1/a;return Ci.elements[0]*=c,Ci.elements[1]*=c,Ci.elements[2]*=c,Ci.elements[4]*=h,Ci.elements[5]*=h,Ci.elements[6]*=h,Ci.elements[8]*=u,Ci.elements[9]*=u,Ci.elements[10]*=u,e.setFromRotationMatrix(Ci),i.x=r,i.y=o,i.z=a,this}makePerspective(t,e,i,n,r,o,a=Li,l=!1){let c=this.elements,h=2*r/(e-t),u=2*r/(i-n),f=(e+t)/(e-t),d=(i+n)/(i-n),g,x;if(l)g=r/(o-r),x=o*r/(o-r);else if(a===Li)g=-(o+r)/(o-r),x=-2*o*r/(o-r);else if(a===wr)g=-o/(o-r),x=-o*r/(o-r);else throw new Error("THREE.Matrix4.makePerspective(): Invalid coordinate system: "+a);return c[0]=h,c[4]=0,c[8]=f,c[12]=0,c[1]=0,c[5]=u,c[9]=d,c[13]=0,c[2]=0,c[6]=0,c[10]=g,c[14]=x,c[3]=0,c[7]=0,c[11]=-1,c[15]=0,this}makeOrthographic(t,e,i,n,r,o,a=Li,l=!1){let c=this.elements,h=2/(e-t),u=2/(i-n),f=-(e+t)/(e-t),d=-(i+n)/(i-n),g,x;if(l)g=1/(o-r),x=o/(o-r);else if(a===Li)g=-2/(o-r),x=-(o+r)/(o-r);else if(a===wr)g=-1/(o-r),x=-r/(o-r);else throw new Error("THREE.Matrix4.makeOrthographic(): Invalid coordinate system: "+a);return c[0]=h,c[4]=0,c[8]=0,c[12]=f,c[1]=0,c[5]=u,c[9]=0,c[13]=d,c[2]=0,c[6]=0,c[10]=g,c[14]=x,c[3]=0,c[7]=0,c[11]=0,c[15]=1,this}equals(t){let e=this.elements,i=t.elements;for(let n=0;n<16;n++)if(e[n]!==i[n])return!1;return!0}fromArray(t,e=0){for(let i=0;i<16;i++)this.elements[i]=t[i+e];return this}toArray(t=[],e=0){let i=this.elements;return t[e]=i[0],t[e+1]=i[1],t[e+2]=i[2],t[e+3]=i[3],t[e+4]=i[4],t[e+5]=i[5],t[e+6]=i[6],t[e+7]=i[7],t[e+8]=i[8],t[e+9]=i[9],t[e+10]=i[10],t[e+11]=i[11],t[e+12]=i[12],t[e+13]=i[13],t[e+14]=i[14],t[e+15]=i[15],t}},ds=new T,Ci=new Ut,Jp=new T(0,0,0),Kp=new T(1,1,1),yn=new T,Bo=new T,di=new T,Du=new Ut,Uu=new _e,Re=class s{constructor(t=0,e=0,i=0,n=s.DEFAULT_ORDER){this.isEuler=!0,this._x=t,this._y=e,this._z=i,this._order=n}get x(){return this._x}set x(t){this._x=t,this._onChangeCallback()}get y(){return this._y}set y(t){this._y=t,this._onChangeCallback()}get z(){return this._z}set z(t){this._z=t,this._onChangeCallback()}get order(){return this._order}set order(t){this._order=t,this._onChangeCallback()}set(t,e,i,n=this._order){return this._x=t,this._y=e,this._z=i,this._order=n,this._onChangeCallback(),this}clone(){return new this.constructor(this._x,this._y,this._z,this._order)}copy(t){return this._x=t._x,this._y=t._y,this._z=t._z,this._order=t._order,this._onChangeCallback(),this}setFromRotationMatrix(t,e=this._order,i=!0){let n=t.elements,r=n[0],o=n[4],a=n[8],l=n[1],c=n[5],h=n[9],u=n[2],f=n[6],d=n[10];switch(e){case"XYZ":this._y=Math.asin(Zt(a,-1,1)),Math.abs(a)<.9999999?(this._x=Math.atan2(-h,d),this._z=Math.atan2(-o,r)):(this._x=Math.atan2(f,c),this._z=0);break;case"YXZ":this._x=Math.asin(-Zt(h,-1,1)),Math.abs(h)<.9999999?(this._y=Math.atan2(a,d),this._z=Math.atan2(l,c)):(this._y=Math.atan2(-u,r),this._z=0);break;case"ZXY":this._x=Math.asin(Zt(f,-1,1)),Math.abs(f)<.9999999?(this._y=Math.atan2(-u,d),this._z=Math.atan2(-o,c)):(this._y=0,this._z=Math.atan2(l,r));break;case"ZYX":this._y=Math.asin(-Zt(u,-1,1)),Math.abs(u)<.9999999?(this._x=Math.atan2(f,d),this._z=Math.atan2(l,r)):(this._x=0,this._z=Math.atan2(-o,c));break;case"YZX":this._z=Math.asin(Zt(l,-1,1)),Math.abs(l)<.9999999?(this._x=Math.atan2(-h,c),this._y=Math.atan2(-u,r)):(this._x=0,this._y=Math.atan2(a,d));break;case"XZY":this._z=Math.asin(-Zt(o,-1,1)),Math.abs(o)<.9999999?(this._x=Math.atan2(f,c),this._y=Math.atan2(a,r)):(this._x=Math.atan2(-h,d),this._y=0);break;default:console.warn("THREE.Euler: .setFromRotationMatrix() encountered an unknown order: "+e)}return this._order=e,i===!0&&this._onChangeCallback(),this}setFromQuaternion(t,e,i){return Du.makeRotationFromQuaternion(t),this.setFromRotationMatrix(Du,e,i)}setFromVector3(t,e=this._order){return this.set(t.x,t.y,t.z,e)}reorder(t){return Uu.setFromEuler(this),this.setFromQuaternion(Uu,t)}equals(t){return t._x===this._x&&t._y===this._y&&t._z===this._z&&t._order===this._order}fromArray(t){return this._x=t[0],this._y=t[1],this._z=t[2],t[3]!==void 0&&(this._order=t[3]),this._onChangeCallback(),this}toArray(t=[],e=0){return t[e]=this._x,t[e+1]=this._y,t[e+2]=this._z,t[e+3]=this._order,t}_onChange(t){return this._onChangeCallback=t,this}_onChangeCallback(){}*[Symbol.iterator](){yield this._x,yield this._y,yield this._z,yield this._order}};Re.DEFAULT_ORDER="XYZ";var Tr=class{constructor(){this.mask=1}set(t){this.mask=(1<<t|0)>>>0}enable(t){this.mask|=1<<t|0}enableAll(){this.mask=-1}toggle(t){this.mask^=1<<t|0}disable(t){this.mask&=~(1<<t|0)}disableAll(){this.mask=0}test(t){return(this.mask&t.mask)!==0}isEnabled(t){return(this.mask&(1<<t|0))!==0}},jp=0,Nu=new T,fs=new _e,Qi=new Ut,Oo=new T,lr=new T,Qp=new T,t0=new _e,Fu=new T(1,0,0),ku=new T(0,1,0),Bu=new T(0,0,1),Ou={type:"added"},e0={type:"removed"},ps={type:"childadded",child:null},Sc={type:"childremoved",child:null},Ee=class s extends rn{constructor(){super(),this.isObject3D=!0,Object.defineProperty(this,"id",{value:jp++}),this.uuid=Di(),this.name="",this.type="Object3D",this.parent=null,this.children=[],this.up=s.DEFAULT_UP.clone();let t=new T,e=new Re,i=new _e,n=new T(1,1,1);function r(){i.setFromEuler(e,!1)}function o(){e.setFromQuaternion(i,void 0,!1)}e._onChange(r),i._onChange(o),Object.defineProperties(this,{position:{configurable:!0,enumerable:!0,value:t},rotation:{configurable:!0,enumerable:!0,value:e},quaternion:{configurable:!0,enumerable:!0,value:i},scale:{configurable:!0,enumerable:!0,value:n},modelViewMatrix:{value:new Ut},normalMatrix:{value:new Xt}}),this.matrix=new Ut,this.matrixWorld=new Ut,this.matrixAutoUpdate=s.DEFAULT_MATRIX_AUTO_UPDATE,this.matrixWorldAutoUpdate=s.DEFAULT_MATRIX_WORLD_AUTO_UPDATE,this.matrixWorldNeedsUpdate=!1,this.layers=new Tr,this.visible=!0,this.castShadow=!1,this.receiveShadow=!1,this.frustumCulled=!0,this.renderOrder=0,this.animations=[],this.customDepthMaterial=void 0,this.customDistanceMaterial=void 0,this.userData={}}onBeforeShadow(){}onAfterShadow(){}onBeforeRender(){}onAfterRender(){}applyMatrix4(t){this.matrixAutoUpdate&&this.updateMatrix(),this.matrix.premultiply(t),this.matrix.decompose(this.position,this.quaternion,this.scale)}applyQuaternion(t){return this.quaternion.premultiply(t),this}setRotationFromAxisAngle(t,e){this.quaternion.setFromAxisAngle(t,e)}setRotationFromEuler(t){this.quaternion.setFromEuler(t,!0)}setRotationFromMatrix(t){this.quaternion.setFromRotationMatrix(t)}setRotationFromQuaternion(t){this.quaternion.copy(t)}rotateOnAxis(t,e){return fs.setFromAxisAngle(t,e),this.quaternion.multiply(fs),this}rotateOnWorldAxis(t,e){return fs.setFromAxisAngle(t,e),this.quaternion.premultiply(fs),this}rotateX(t){return this.rotateOnAxis(Fu,t)}rotateY(t){return this.rotateOnAxis(ku,t)}rotateZ(t){return this.rotateOnAxis(Bu,t)}translateOnAxis(t,e){return Nu.copy(t).applyQuaternion(this.quaternion),this.position.add(Nu.multiplyScalar(e)),this}translateX(t){return this.translateOnAxis(Fu,t)}translateY(t){return this.translateOnAxis(ku,t)}translateZ(t){return this.translateOnAxis(Bu,t)}localToWorld(t){return this.updateWorldMatrix(!0,!1),t.applyMatrix4(this.matrixWorld)}worldToLocal(t){return this.updateWorldMatrix(!0,!1),t.applyMatrix4(Qi.copy(this.matrixWorld).invert())}lookAt(t,e,i){t.isVector3?Oo.copy(t):Oo.set(t,e,i);let n=this.parent;this.updateWorldMatrix(!0,!1),lr.setFromMatrixPosition(this.matrixWorld),this.isCamera||this.isLight?Qi.lookAt(lr,Oo,this.up):Qi.lookAt(Oo,lr,this.up),this.quaternion.setFromRotationMatrix(Qi),n&&(Qi.extractRotation(n.matrixWorld),fs.setFromRotationMatrix(Qi),this.quaternion.premultiply(fs.invert()))}add(t){if(arguments.length>1){for(let e=0;e<arguments.length;e++)this.add(arguments[e]);return this}return t===this?(console.error("THREE.Object3D.add: object can't be added as a child of itself.",t),this):(t&&t.isObject3D?(t.removeFromParent(),t.parent=this,this.children.push(t),t.dispatchEvent(Ou),ps.child=t,this.dispatchEvent(ps),ps.child=null):console.error("THREE.Object3D.add: object not an instance of THREE.Object3D.",t),this)}remove(t){if(arguments.length>1){for(let i=0;i<arguments.length;i++)this.remove(arguments[i]);return this}let e=this.children.indexOf(t);return e!==-1&&(t.parent=null,this.children.splice(e,1),t.dispatchEvent(e0),Sc.child=t,this.dispatchEvent(Sc),Sc.child=null),this}removeFromParent(){let t=this.parent;return t!==null&&t.remove(this),this}clear(){return this.remove(...this.children)}attach(t){return this.updateWorldMatrix(!0,!1),Qi.copy(this.matrixWorld).invert(),t.parent!==null&&(t.parent.updateWorldMatrix(!0,!1),Qi.multiply(t.parent.matrixWorld)),t.applyMatrix4(Qi),t.removeFromParent(),t.parent=this,this.children.push(t),t.updateWorldMatrix(!1,!0),t.dispatchEvent(Ou),ps.child=t,this.dispatchEvent(ps),ps.child=null,this}getObjectById(t){return this.getObjectByProperty("id",t)}getObjectByName(t){return this.getObjectByProperty("name",t)}getObjectByProperty(t,e){if(this[t]===e)return this;for(let i=0,n=this.children.length;i<n;i++){let o=this.children[i].getObjectByProperty(t,e);if(o!==void 0)return o}}getObjectsByProperty(t,e,i=[]){this[t]===e&&i.push(this);let n=this.children;for(let r=0,o=n.length;r<o;r++)n[r].getObjectsByProperty(t,e,i);return i}getWorldPosition(t){return this.updateWorldMatrix(!0,!1),t.setFromMatrixPosition(this.matrixWorld)}getWorldQuaternion(t){return this.updateWorldMatrix(!0,!1),this.matrixWorld.decompose(lr,t,Qp),t}getWorldScale(t){return this.updateWorldMatrix(!0,!1),this.matrixWorld.decompose(lr,t0,t),t}getWorldDirection(t){this.updateWorldMatrix(!0,!1);let e=this.matrixWorld.elements;return t.set(e[8],e[9],e[10]).normalize()}raycast(){}traverse(t){t(this);let e=this.children;for(let i=0,n=e.length;i<n;i++)e[i].traverse(t)}traverseVisible(t){if(this.visible===!1)return;t(this);let e=this.children;for(let i=0,n=e.length;i<n;i++)e[i].traverseVisible(t)}traverseAncestors(t){let e=this.parent;e!==null&&(t(e),e.traverseAncestors(t))}updateMatrix(){this.matrix.compose(this.position,this.quaternion,this.scale),this.matrixWorldNeedsUpdate=!0}updateMatrixWorld(t){this.matrixAutoUpdate&&this.updateMatrix(),(this.matrixWorldNeedsUpdate||t)&&(this.matrixWorldAutoUpdate===!0&&(this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix)),this.matrixWorldNeedsUpdate=!1,t=!0);let e=this.children;for(let i=0,n=e.length;i<n;i++)e[i].updateMatrixWorld(t)}updateWorldMatrix(t,e){let i=this.parent;if(t===!0&&i!==null&&i.updateWorldMatrix(!0,!1),this.matrixAutoUpdate&&this.updateMatrix(),this.matrixWorldAutoUpdate===!0&&(this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix)),e===!0){let n=this.children;for(let r=0,o=n.length;r<o;r++)n[r].updateWorldMatrix(!1,!0)}}toJSON(t){let e=t===void 0||typeof t=="string",i={};e&&(t={geometries:{},materials:{},textures:{},images:{},shapes:{},skeletons:{},animations:{},nodes:{}},i.metadata={version:4.7,type:"Object",generator:"Object3D.toJSON"});let n={};n.uuid=this.uuid,n.type=this.type,this.name!==""&&(n.name=this.name),this.castShadow===!0&&(n.castShadow=!0),this.receiveShadow===!0&&(n.receiveShadow=!0),this.visible===!1&&(n.visible=!1),this.frustumCulled===!1&&(n.frustumCulled=!1),this.renderOrder!==0&&(n.renderOrder=this.renderOrder),Object.keys(this.userData).length>0&&(n.userData=this.userData),n.layers=this.layers.mask,n.matrix=this.matrix.toArray(),n.up=this.up.toArray(),this.matrixAutoUpdate===!1&&(n.matrixAutoUpdate=!1),this.isInstancedMesh&&(n.type="InstancedMesh",n.count=this.count,n.instanceMatrix=this.instanceMatrix.toJSON(),this.instanceColor!==null&&(n.instanceColor=this.instanceColor.toJSON())),this.isBatchedMesh&&(n.type="BatchedMesh",n.perObjectFrustumCulled=this.perObjectFrustumCulled,n.sortObjects=this.sortObjects,n.drawRanges=this._drawRanges,n.reservedRanges=this._reservedRanges,n.geometryInfo=this._geometryInfo.map(a=>({...a,boundingBox:a.boundingBox?a.boundingBox.toJSON():void 0,boundingSphere:a.boundingSphere?a.boundingSphere.toJSON():void 0})),n.instanceInfo=this._instanceInfo.map(a=>({...a})),n.availableInstanceIds=this._availableInstanceIds.slice(),n.availableGeometryIds=this._availableGeometryIds.slice(),n.nextIndexStart=this._nextIndexStart,n.nextVertexStart=this._nextVertexStart,n.geometryCount=this._geometryCount,n.maxInstanceCount=this._maxInstanceCount,n.maxVertexCount=this._maxVertexCount,n.maxIndexCount=this._maxIndexCount,n.geometryInitialized=this._geometryInitialized,n.matricesTexture=this._matricesTexture.toJSON(t),n.indirectTexture=this._indirectTexture.toJSON(t),this._colorsTexture!==null&&(n.colorsTexture=this._colorsTexture.toJSON(t)),this.boundingSphere!==null&&(n.boundingSphere=this.boundingSphere.toJSON()),this.boundingBox!==null&&(n.boundingBox=this.boundingBox.toJSON()));function r(a,l){return a[l.uuid]===void 0&&(a[l.uuid]=l.toJSON(t)),l.uuid}if(this.isScene)this.background&&(this.background.isColor?n.background=this.background.toJSON():this.background.isTexture&&(n.background=this.background.toJSON(t).uuid)),this.environment&&this.environment.isTexture&&this.environment.isRenderTargetTexture!==!0&&(n.environment=this.environment.toJSON(t).uuid);else if(this.isMesh||this.isLine||this.isPoints){n.geometry=r(t.geometries,this.geometry);let a=this.geometry.parameters;if(a!==void 0&&a.shapes!==void 0){let l=a.shapes;if(Array.isArray(l))for(let c=0,h=l.length;c<h;c++){let u=l[c];r(t.shapes,u)}else r(t.shapes,l)}}if(this.isSkinnedMesh&&(n.bindMode=this.bindMode,n.bindMatrix=this.bindMatrix.toArray(),this.skeleton!==void 0&&(r(t.skeletons,this.skeleton),n.skeleton=this.skeleton.uuid)),this.material!==void 0)if(Array.isArray(this.material)){let a=[];for(let l=0,c=this.material.length;l<c;l++)a.push(r(t.materials,this.material[l]));n.material=a}else n.material=r(t.materials,this.material);if(this.children.length>0){n.children=[];for(let a=0;a<this.children.length;a++)n.children.push(this.children[a].toJSON(t).object)}if(this.animations.length>0){n.animations=[];for(let a=0;a<this.animations.length;a++){let l=this.animations[a];n.animations.push(r(t.animations,l))}}if(e){let a=o(t.geometries),l=o(t.materials),c=o(t.textures),h=o(t.images),u=o(t.shapes),f=o(t.skeletons),d=o(t.animations),g=o(t.nodes);a.length>0&&(i.geometries=a),l.length>0&&(i.materials=l),c.length>0&&(i.textures=c),h.length>0&&(i.images=h),u.length>0&&(i.shapes=u),f.length>0&&(i.skeletons=f),d.length>0&&(i.animations=d),g.length>0&&(i.nodes=g)}return i.object=n,i;function o(a){let l=[];for(let c in a){let h=a[c];delete h.metadata,l.push(h)}return l}}clone(t){return new this.constructor().copy(this,t)}copy(t,e=!0){if(this.name=t.name,this.up.copy(t.up),this.position.copy(t.position),this.rotation.order=t.rotation.order,this.quaternion.copy(t.quaternion),this.scale.copy(t.scale),this.matrix.copy(t.matrix),this.matrixWorld.copy(t.matrixWorld),this.matrixAutoUpdate=t.matrixAutoUpdate,this.matrixWorldAutoUpdate=t.matrixWorldAutoUpdate,this.matrixWorldNeedsUpdate=t.matrixWorldNeedsUpdate,this.layers.mask=t.layers.mask,this.visible=t.visible,this.castShadow=t.castShadow,this.receiveShadow=t.receiveShadow,this.frustumCulled=t.frustumCulled,this.renderOrder=t.renderOrder,this.animations=t.animations.slice(),this.userData=JSON.parse(JSON.stringify(t.userData)),e===!0)for(let i=0;i<t.children.length;i++){let n=t.children[i];this.add(n.clone())}return this}};Ee.DEFAULT_UP=new T(0,1,0);Ee.DEFAULT_MATRIX_AUTO_UPDATE=!0;Ee.DEFAULT_MATRIX_WORLD_AUTO_UPDATE=!0;var Ii=new T,tn=new T,Ec=new T,en=new T,ms=new T,gs=new T,zu=new T,Tc=new T,Ac=new T,Rc=new T,Cc=new ie,Ic=new ie,Pc=new ie,nn=class s{constructor(t=new T,e=new T,i=new T){this.a=t,this.b=e,this.c=i}static getNormal(t,e,i,n){n.subVectors(i,e),Ii.subVectors(t,e),n.cross(Ii);let r=n.lengthSq();return r>0?n.multiplyScalar(1/Math.sqrt(r)):n.set(0,0,0)}static getBarycoord(t,e,i,n,r){Ii.subVectors(n,e),tn.subVectors(i,e),Ec.subVectors(t,e);let o=Ii.dot(Ii),a=Ii.dot(tn),l=Ii.dot(Ec),c=tn.dot(tn),h=tn.dot(Ec),u=o*c-a*a;if(u===0)return r.set(0,0,0),null;let f=1/u,d=(c*l-a*h)*f,g=(o*h-a*l)*f;return r.set(1-d-g,g,d)}static containsPoint(t,e,i,n){return this.getBarycoord(t,e,i,n,en)===null?!1:en.x>=0&&en.y>=0&&en.x+en.y<=1}static getInterpolation(t,e,i,n,r,o,a,l){return this.getBarycoord(t,e,i,n,en)===null?(l.x=0,l.y=0,"z"in l&&(l.z=0),"w"in l&&(l.w=0),null):(l.setScalar(0),l.addScaledVector(r,en.x),l.addScaledVector(o,en.y),l.addScaledVector(a,en.z),l)}static getInterpolatedAttribute(t,e,i,n,r,o){return Cc.setScalar(0),Ic.setScalar(0),Pc.setScalar(0),Cc.fromBufferAttribute(t,e),Ic.fromBufferAttribute(t,i),Pc.fromBufferAttribute(t,n),o.setScalar(0),o.addScaledVector(Cc,r.x),o.addScaledVector(Ic,r.y),o.addScaledVector(Pc,r.z),o}static isFrontFacing(t,e,i,n){return Ii.subVectors(i,e),tn.subVectors(t,e),Ii.cross(tn).dot(n)<0}set(t,e,i){return this.a.copy(t),this.b.copy(e),this.c.copy(i),this}setFromPointsAndIndices(t,e,i,n){return this.a.copy(t[e]),this.b.copy(t[i]),this.c.copy(t[n]),this}setFromAttributeAndIndices(t,e,i,n){return this.a.fromBufferAttribute(t,e),this.b.fromBufferAttribute(t,i),this.c.fromBufferAttribute(t,n),this}clone(){return new this.constructor().copy(this)}copy(t){return this.a.copy(t.a),this.b.copy(t.b),this.c.copy(t.c),this}getArea(){return Ii.subVectors(this.c,this.b),tn.subVectors(this.a,this.b),Ii.cross(tn).length()*.5}getMidpoint(t){return t.addVectors(this.a,this.b).add(this.c).multiplyScalar(1/3)}getNormal(t){return s.getNormal(this.a,this.b,this.c,t)}getPlane(t){return t.setFromCoplanarPoints(this.a,this.b,this.c)}getBarycoord(t,e){return s.getBarycoord(t,this.a,this.b,this.c,e)}getInterpolation(t,e,i,n,r){return s.getInterpolation(t,this.a,this.b,this.c,e,i,n,r)}containsPoint(t){return s.containsPoint(t,this.a,this.b,this.c)}isFrontFacing(t){return s.isFrontFacing(this.a,this.b,this.c,t)}intersectsBox(t){return t.intersectsTriangle(this)}closestPointToPoint(t,e){let i=this.a,n=this.b,r=this.c,o,a;ms.subVectors(n,i),gs.subVectors(r,i),Tc.subVectors(t,i);let l=ms.dot(Tc),c=gs.dot(Tc);if(l<=0&&c<=0)return e.copy(i);Ac.subVectors(t,n);let h=ms.dot(Ac),u=gs.dot(Ac);if(h>=0&&u<=h)return e.copy(n);let f=l*u-h*c;if(f<=0&&l>=0&&h<=0)return o=l/(l-h),e.copy(i).addScaledVector(ms,o);Rc.subVectors(t,r);let d=ms.dot(Rc),g=gs.dot(Rc);if(g>=0&&d<=g)return e.copy(r);let x=d*c-l*g;if(x<=0&&c>=0&&g<=0)return a=c/(c-g),e.copy(i).addScaledVector(gs,a);let m=h*g-d*u;if(m<=0&&u-h>=0&&d-g>=0)return zu.subVectors(r,n),a=(u-h)/(u-h+(d-g)),e.copy(n).addScaledVector(zu,a);let p=1/(m+x+f);return o=x*p,a=f*p,e.copy(i).addScaledVector(ms,o).addScaledVector(gs,a)}equals(t){return t.a.equals(this.a)&&t.b.equals(this.b)&&t.c.equals(this.c)}},Qd={aliceblue:15792383,antiquewhite:16444375,aqua:65535,aquamarine:8388564,azure:15794175,beige:16119260,bisque:16770244,black:0,blanchedalmond:16772045,blue:255,blueviolet:9055202,brown:10824234,burlywood:14596231,cadetblue:6266528,chartreuse:8388352,chocolate:13789470,coral:16744272,cornflowerblue:6591981,cornsilk:16775388,crimson:14423100,cyan:65535,darkblue:139,darkcyan:35723,darkgoldenrod:12092939,darkgray:11119017,darkgreen:25600,darkgrey:11119017,darkkhaki:12433259,darkmagenta:9109643,darkolivegreen:5597999,darkorange:16747520,darkorchid:10040012,darkred:9109504,darksalmon:15308410,darkseagreen:9419919,darkslateblue:4734347,darkslategray:3100495,darkslategrey:3100495,darkturquoise:52945,darkviolet:9699539,deeppink:16716947,deepskyblue:49151,dimgray:6908265,dimgrey:6908265,dodgerblue:2003199,firebrick:11674146,floralwhite:16775920,forestgreen:2263842,fuchsia:16711935,gainsboro:14474460,ghostwhite:16316671,gold:16766720,goldenrod:14329120,gray:8421504,green:32768,greenyellow:11403055,grey:8421504,honeydew:15794160,hotpink:16738740,indianred:13458524,indigo:4915330,ivory:16777200,khaki:15787660,lavender:15132410,lavenderblush:16773365,lawngreen:8190976,lemonchiffon:16775885,lightblue:11393254,lightcoral:15761536,lightcyan:14745599,lightgoldenrodyellow:16448210,lightgray:13882323,lightgreen:9498256,lightgrey:13882323,lightpink:16758465,lightsalmon:16752762,lightseagreen:2142890,lightskyblue:8900346,lightslategray:7833753,lightslategrey:7833753,lightsteelblue:11584734,lightyellow:16777184,lime:65280,limegreen:3329330,linen:16445670,magenta:16711935,maroon:8388608,mediumaquamarine:6737322,mediumblue:205,mediumorchid:12211667,mediumpurple:9662683,mediumseagreen:3978097,mediumslateblue:8087790,mediumspringgreen:64154,mediumturquoise:4772300,mediumvioletred:13047173,midnightblue:1644912,mintcream:16121850,mistyrose:16770273,moccasin:16770229,navajowhite:16768685,navy:128,oldlace:16643558,olive:8421376,olivedrab:7048739,orange:16753920,orangered:16729344,orchid:14315734,palegoldenrod:15657130,palegreen:10025880,paleturquoise:11529966,palevioletred:14381203,papayawhip:16773077,peachpuff:16767673,peru:13468991,pink:16761035,plum:14524637,powderblue:11591910,purple:8388736,rebeccapurple:6697881,red:16711680,rosybrown:12357519,royalblue:4286945,saddlebrown:9127187,salmon:16416882,sandybrown:16032864,seagreen:3050327,seashell:16774638,sienna:10506797,silver:12632256,skyblue:8900331,slateblue:6970061,slategray:7372944,slategrey:7372944,snow:16775930,springgreen:65407,steelblue:4620980,tan:13808780,teal:32896,thistle:14204888,tomato:16737095,turquoise:4251856,violet:15631086,wheat:16113331,white:16777215,whitesmoke:16119285,yellow:16776960,yellowgreen:10145074},vn={h:0,s:0,l:0},zo={h:0,s:0,l:0};function Lc(s,t,e){return e<0&&(e+=1),e>1&&(e-=1),e<1/6?s+(t-s)*6*e:e<1/2?t:e<2/3?s+(t-s)*6*(2/3-e):s}var _t=class{constructor(t,e,i){return this.isColor=!0,this.r=1,this.g=1,this.b=1,this.set(t,e,i)}set(t,e,i){if(e===void 0&&i===void 0){let n=t;n&&n.isColor?this.copy(n):typeof n=="number"?this.setHex(n):typeof n=="string"&&this.setStyle(n)}else this.setRGB(t,e,i);return this}setScalar(t){return this.r=t,this.g=t,this.b=t,this}setHex(t,e=Ne){return t=Math.floor(t),this.r=(t>>16&255)/255,this.g=(t>>8&255)/255,this.b=(t&255)/255,te.colorSpaceToWorking(this,e),this}setRGB(t,e,i,n=te.workingColorSpace){return this.r=t,this.g=e,this.b=i,te.colorSpaceToWorking(this,n),this}setHSL(t,e,i,n=te.workingColorSpace){if(t=xh(t,1),e=Zt(e,0,1),i=Zt(i,0,1),e===0)this.r=this.g=this.b=i;else{let r=i<=.5?i*(1+e):i+e-i*e,o=2*i-r;this.r=Lc(o,r,t+1/3),this.g=Lc(o,r,t),this.b=Lc(o,r,t-1/3)}return te.colorSpaceToWorking(this,n),this}setStyle(t,e=Ne){function i(r){r!==void 0&&parseFloat(r)<1&&console.warn("THREE.Color: Alpha component of "+t+" will be ignored.")}let n;if(n=/^(\w+)\(([^\)]*)\)/.exec(t)){let r,o=n[1],a=n[2];switch(o){case"rgb":case"rgba":if(r=/^\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(a))return i(r[4]),this.setRGB(Math.min(255,parseInt(r[1],10))/255,Math.min(255,parseInt(r[2],10))/255,Math.min(255,parseInt(r[3],10))/255,e);if(r=/^\s*(\d+)\%\s*,\s*(\d+)\%\s*,\s*(\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(a))return i(r[4]),this.setRGB(Math.min(100,parseInt(r[1],10))/100,Math.min(100,parseInt(r[2],10))/100,Math.min(100,parseInt(r[3],10))/100,e);break;case"hsl":case"hsla":if(r=/^\s*(\d*\.?\d+)\s*,\s*(\d*\.?\d+)\%\s*,\s*(\d*\.?\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(a))return i(r[4]),this.setHSL(parseFloat(r[1])/360,parseFloat(r[2])/100,parseFloat(r[3])/100,e);break;default:console.warn("THREE.Color: Unknown color model "+t)}}else if(n=/^\#([A-Fa-f\d]+)$/.exec(t)){let r=n[1],o=r.length;if(o===3)return this.setRGB(parseInt(r.charAt(0),16)/15,parseInt(r.charAt(1),16)/15,parseInt(r.charAt(2),16)/15,e);if(o===6)return this.setHex(parseInt(r,16),e);console.warn("THREE.Color: Invalid hex color "+t)}else if(t&&t.length>0)return this.setColorName(t,e);return this}setColorName(t,e=Ne){let i=Qd[t.toLowerCase()];return i!==void 0?this.setHex(i,e):console.warn("THREE.Color: Unknown color "+t),this}clone(){return new this.constructor(this.r,this.g,this.b)}copy(t){return this.r=t.r,this.g=t.g,this.b=t.b,this}copySRGBToLinear(t){return this.r=sn(t.r),this.g=sn(t.g),this.b=sn(t.b),this}copyLinearToSRGB(t){return this.r=Es(t.r),this.g=Es(t.g),this.b=Es(t.b),this}convertSRGBToLinear(){return this.copySRGBToLinear(this),this}convertLinearToSRGB(){return this.copyLinearToSRGB(this),this}getHex(t=Ne){return te.workingToColorSpace(Je.copy(this),t),Math.round(Zt(Je.r*255,0,255))*65536+Math.round(Zt(Je.g*255,0,255))*256+Math.round(Zt(Je.b*255,0,255))}getHexString(t=Ne){return("000000"+this.getHex(t).toString(16)).slice(-6)}getHSL(t,e=te.workingColorSpace){te.workingToColorSpace(Je.copy(this),e);let i=Je.r,n=Je.g,r=Je.b,o=Math.max(i,n,r),a=Math.min(i,n,r),l,c,h=(a+o)/2;if(a===o)l=0,c=0;else{let u=o-a;switch(c=h<=.5?u/(o+a):u/(2-o-a),o){case i:l=(n-r)/u+(n<r?6:0);break;case n:l=(r-i)/u+2;break;case r:l=(i-n)/u+4;break}l/=6}return t.h=l,t.s=c,t.l=h,t}getRGB(t,e=te.workingColorSpace){return te.workingToColorSpace(Je.copy(this),e),t.r=Je.r,t.g=Je.g,t.b=Je.b,t}getStyle(t=Ne){te.workingToColorSpace(Je.copy(this),t);let e=Je.r,i=Je.g,n=Je.b;return t!==Ne?`color(${t} ${e.toFixed(3)} ${i.toFixed(3)} ${n.toFixed(3)})`:`rgb(${Math.round(e*255)},${Math.round(i*255)},${Math.round(n*255)})`}offsetHSL(t,e,i){return this.getHSL(vn),this.setHSL(vn.h+t,vn.s+e,vn.l+i)}add(t){return this.r+=t.r,this.g+=t.g,this.b+=t.b,this}addColors(t,e){return this.r=t.r+e.r,this.g=t.g+e.g,this.b=t.b+e.b,this}addScalar(t){return this.r+=t,this.g+=t,this.b+=t,this}sub(t){return this.r=Math.max(0,this.r-t.r),this.g=Math.max(0,this.g-t.g),this.b=Math.max(0,this.b-t.b),this}multiply(t){return this.r*=t.r,this.g*=t.g,this.b*=t.b,this}multiplyScalar(t){return this.r*=t,this.g*=t,this.b*=t,this}lerp(t,e){return this.r+=(t.r-this.r)*e,this.g+=(t.g-this.g)*e,this.b+=(t.b-this.b)*e,this}lerpColors(t,e,i){return this.r=t.r+(e.r-t.r)*i,this.g=t.g+(e.g-t.g)*i,this.b=t.b+(e.b-t.b)*i,this}lerpHSL(t,e){this.getHSL(vn),t.getHSL(zo);let i=_r(vn.h,zo.h,e),n=_r(vn.s,zo.s,e),r=_r(vn.l,zo.l,e);return this.setHSL(i,n,r),this}setFromVector3(t){return this.r=t.x,this.g=t.y,this.b=t.z,this}applyMatrix3(t){let e=this.r,i=this.g,n=this.b,r=t.elements;return this.r=r[0]*e+r[3]*i+r[6]*n,this.g=r[1]*e+r[4]*i+r[7]*n,this.b=r[2]*e+r[5]*i+r[8]*n,this}equals(t){return t.r===this.r&&t.g===this.g&&t.b===this.b}fromArray(t,e=0){return this.r=t[e],this.g=t[e+1],this.b=t[e+2],this}toArray(t=[],e=0){return t[e]=this.r,t[e+1]=this.g,t[e+2]=this.b,t}fromBufferAttribute(t,e){return this.r=t.getX(e),this.g=t.getY(e),this.b=t.getZ(e),this}toJSON(){return this.getHex()}*[Symbol.iterator](){yield this.r,yield this.g,yield this.b}},Je=new _t;_t.NAMES=Qd;var i0=0,Fi=class extends rn{constructor(){super(),this.isMaterial=!0,Object.defineProperty(this,"id",{value:i0++}),this.uuid=Di(),this.name="",this.type="Material",this.blending=Ui,this.side=bi,this.vertexColors=!1,this.opacity=1,this.transparent=!1,this.alphaHash=!1,this.blendSrc=la,this.blendDst=ca,this.blendEquation=wn,this.blendSrcAlpha=null,this.blendDstAlpha=null,this.blendEquationAlpha=null,this.blendColor=new _t(0,0,0),this.blendAlpha=0,this.depthFunc=Vn,this.depthTest=!0,this.depthWrite=!0,this.stencilWriteMask=255,this.stencilFunc=Zc,this.stencilRef=0,this.stencilFuncMask=255,this.stencilFail=Hn,this.stencilZFail=Hn,this.stencilZPass=Hn,this.stencilWrite=!1,this.clippingPlanes=null,this.clipIntersection=!1,this.clipShadows=!1,this.shadowSide=null,this.colorWrite=!0,this.precision=null,this.polygonOffset=!1,this.polygonOffsetFactor=0,this.polygonOffsetUnits=0,this.dithering=!1,this.alphaToCoverage=!1,this.premultipliedAlpha=!1,this.forceSinglePass=!1,this.allowOverride=!0,this.visible=!0,this.toneMapped=!0,this.userData={},this.version=0,this._alphaTest=0}get alphaTest(){return this._alphaTest}set alphaTest(t){this._alphaTest>0!=t>0&&this.version++,this._alphaTest=t}onBeforeRender(){}onBeforeCompile(){}customProgramCacheKey(){return this.onBeforeCompile.toString()}setValues(t){if(t!==void 0)for(let e in t){let i=t[e];if(i===void 0){console.warn(`THREE.Material: parameter '${e}' has value of undefined.`);continue}let n=this[e];if(n===void 0){console.warn(`THREE.Material: '${e}' is not a property of THREE.${this.type}.`);continue}n&&n.isColor?n.set(i):n&&n.isVector3&&i&&i.isVector3?n.copy(i):this[e]=i}}toJSON(t){let e=t===void 0||typeof t=="string";e&&(t={textures:{},images:{}});let i={metadata:{version:4.7,type:"Material",generator:"Material.toJSON"}};i.uuid=this.uuid,i.type=this.type,this.name!==""&&(i.name=this.name),this.color&&this.color.isColor&&(i.color=this.color.getHex()),this.roughness!==void 0&&(i.roughness=this.roughness),this.metalness!==void 0&&(i.metalness=this.metalness),this.sheen!==void 0&&(i.sheen=this.sheen),this.sheenColor&&this.sheenColor.isColor&&(i.sheenColor=this.sheenColor.getHex()),this.sheenRoughness!==void 0&&(i.sheenRoughness=this.sheenRoughness),this.emissive&&this.emissive.isColor&&(i.emissive=this.emissive.getHex()),this.emissiveIntensity!==void 0&&this.emissiveIntensity!==1&&(i.emissiveIntensity=this.emissiveIntensity),this.specular&&this.specular.isColor&&(i.specular=this.specular.getHex()),this.specularIntensity!==void 0&&(i.specularIntensity=this.specularIntensity),this.specularColor&&this.specularColor.isColor&&(i.specularColor=this.specularColor.getHex()),this.shininess!==void 0&&(i.shininess=this.shininess),this.clearcoat!==void 0&&(i.clearcoat=this.clearcoat),this.clearcoatRoughness!==void 0&&(i.clearcoatRoughness=this.clearcoatRoughness),this.clearcoatMap&&this.clearcoatMap.isTexture&&(i.clearcoatMap=this.clearcoatMap.toJSON(t).uuid),this.clearcoatRoughnessMap&&this.clearcoatRoughnessMap.isTexture&&(i.clearcoatRoughnessMap=this.clearcoatRoughnessMap.toJSON(t).uuid),this.clearcoatNormalMap&&this.clearcoatNormalMap.isTexture&&(i.clearcoatNormalMap=this.clearcoatNormalMap.toJSON(t).uuid,i.clearcoatNormalScale=this.clearcoatNormalScale.toArray()),this.sheenColorMap&&this.sheenColorMap.isTexture&&(i.sheenColorMap=this.sheenColorMap.toJSON(t).uuid),this.sheenRoughnessMap&&this.sheenRoughnessMap.isTexture&&(i.sheenRoughnessMap=this.sheenRoughnessMap.toJSON(t).uuid),this.dispersion!==void 0&&(i.dispersion=this.dispersion),this.iridescence!==void 0&&(i.iridescence=this.iridescence),this.iridescenceIOR!==void 0&&(i.iridescenceIOR=this.iridescenceIOR),this.iridescenceThicknessRange!==void 0&&(i.iridescenceThicknessRange=this.iridescenceThicknessRange),this.iridescenceMap&&this.iridescenceMap.isTexture&&(i.iridescenceMap=this.iridescenceMap.toJSON(t).uuid),this.iridescenceThicknessMap&&this.iridescenceThicknessMap.isTexture&&(i.iridescenceThicknessMap=this.iridescenceThicknessMap.toJSON(t).uuid),this.anisotropy!==void 0&&(i.anisotropy=this.anisotropy),this.anisotropyRotation!==void 0&&(i.anisotropyRotation=this.anisotropyRotation),this.anisotropyMap&&this.anisotropyMap.isTexture&&(i.anisotropyMap=this.anisotropyMap.toJSON(t).uuid),this.map&&this.map.isTexture&&(i.map=this.map.toJSON(t).uuid),this.matcap&&this.matcap.isTexture&&(i.matcap=this.matcap.toJSON(t).uuid),this.alphaMap&&this.alphaMap.isTexture&&(i.alphaMap=this.alphaMap.toJSON(t).uuid),this.lightMap&&this.lightMap.isTexture&&(i.lightMap=this.lightMap.toJSON(t).uuid,i.lightMapIntensity=this.lightMapIntensity),this.aoMap&&this.aoMap.isTexture&&(i.aoMap=this.aoMap.toJSON(t).uuid,i.aoMapIntensity=this.aoMapIntensity),this.bumpMap&&this.bumpMap.isTexture&&(i.bumpMap=this.bumpMap.toJSON(t).uuid,i.bumpScale=this.bumpScale),this.normalMap&&this.normalMap.isTexture&&(i.normalMap=this.normalMap.toJSON(t).uuid,i.normalMapType=this.normalMapType,i.normalScale=this.normalScale.toArray()),this.displacementMap&&this.displacementMap.isTexture&&(i.displacementMap=this.displacementMap.toJSON(t).uuid,i.displacementScale=this.displacementScale,i.displacementBias=this.displacementBias),this.roughnessMap&&this.roughnessMap.isTexture&&(i.roughnessMap=this.roughnessMap.toJSON(t).uuid),this.metalnessMap&&this.metalnessMap.isTexture&&(i.metalnessMap=this.metalnessMap.toJSON(t).uuid),this.emissiveMap&&this.emissiveMap.isTexture&&(i.emissiveMap=this.emissiveMap.toJSON(t).uuid),this.specularMap&&this.specularMap.isTexture&&(i.specularMap=this.specularMap.toJSON(t).uuid),this.specularIntensityMap&&this.specularIntensityMap.isTexture&&(i.specularIntensityMap=this.specularIntensityMap.toJSON(t).uuid),this.specularColorMap&&this.specularColorMap.isTexture&&(i.specularColorMap=this.specularColorMap.toJSON(t).uuid),this.envMap&&this.envMap.isTexture&&(i.envMap=this.envMap.toJSON(t).uuid,this.combine!==void 0&&(i.combine=this.combine)),this.envMapRotation!==void 0&&(i.envMapRotation=this.envMapRotation.toArray()),this.envMapIntensity!==void 0&&(i.envMapIntensity=this.envMapIntensity),this.reflectivity!==void 0&&(i.reflectivity=this.reflectivity),this.refractionRatio!==void 0&&(i.refractionRatio=this.refractionRatio),this.gradientMap&&this.gradientMap.isTexture&&(i.gradientMap=this.gradientMap.toJSON(t).uuid),this.transmission!==void 0&&(i.transmission=this.transmission),this.transmissionMap&&this.transmissionMap.isTexture&&(i.transmissionMap=this.transmissionMap.toJSON(t).uuid),this.thickness!==void 0&&(i.thickness=this.thickness),this.thicknessMap&&this.thicknessMap.isTexture&&(i.thicknessMap=this.thicknessMap.toJSON(t).uuid),this.attenuationDistance!==void 0&&this.attenuationDistance!==1/0&&(i.attenuationDistance=this.attenuationDistance),this.attenuationColor!==void 0&&(i.attenuationColor=this.attenuationColor.getHex()),this.size!==void 0&&(i.size=this.size),this.shadowSide!==null&&(i.shadowSide=this.shadowSide),this.sizeAttenuation!==void 0&&(i.sizeAttenuation=this.sizeAttenuation),this.blending!==Ui&&(i.blending=this.blending),this.side!==bi&&(i.side=this.side),this.vertexColors===!0&&(i.vertexColors=!0),this.opacity<1&&(i.opacity=this.opacity),this.transparent===!0&&(i.transparent=!0),this.blendSrc!==la&&(i.blendSrc=this.blendSrc),this.blendDst!==ca&&(i.blendDst=this.blendDst),this.blendEquation!==wn&&(i.blendEquation=this.blendEquation),this.blendSrcAlpha!==null&&(i.blendSrcAlpha=this.blendSrcAlpha),this.blendDstAlpha!==null&&(i.blendDstAlpha=this.blendDstAlpha),this.blendEquationAlpha!==null&&(i.blendEquationAlpha=this.blendEquationAlpha),this.blendColor&&this.blendColor.isColor&&(i.blendColor=this.blendColor.getHex()),this.blendAlpha!==0&&(i.blendAlpha=this.blendAlpha),this.depthFunc!==Vn&&(i.depthFunc=this.depthFunc),this.depthTest===!1&&(i.depthTest=this.depthTest),this.depthWrite===!1&&(i.depthWrite=this.depthWrite),this.colorWrite===!1&&(i.colorWrite=this.colorWrite),this.stencilWriteMask!==255&&(i.stencilWriteMask=this.stencilWriteMask),this.stencilFunc!==Zc&&(i.stencilFunc=this.stencilFunc),this.stencilRef!==0&&(i.stencilRef=this.stencilRef),this.stencilFuncMask!==255&&(i.stencilFuncMask=this.stencilFuncMask),this.stencilFail!==Hn&&(i.stencilFail=this.stencilFail),this.stencilZFail!==Hn&&(i.stencilZFail=this.stencilZFail),this.stencilZPass!==Hn&&(i.stencilZPass=this.stencilZPass),this.stencilWrite===!0&&(i.stencilWrite=this.stencilWrite),this.rotation!==void 0&&this.rotation!==0&&(i.rotation=this.rotation),this.polygonOffset===!0&&(i.polygonOffset=!0),this.polygonOffsetFactor!==0&&(i.polygonOffsetFactor=this.polygonOffsetFactor),this.polygonOffsetUnits!==0&&(i.polygonOffsetUnits=this.polygonOffsetUnits),this.linewidth!==void 0&&this.linewidth!==1&&(i.linewidth=this.linewidth),this.dashSize!==void 0&&(i.dashSize=this.dashSize),this.gapSize!==void 0&&(i.gapSize=this.gapSize),this.scale!==void 0&&(i.scale=this.scale),this.dithering===!0&&(i.dithering=!0),this.alphaTest>0&&(i.alphaTest=this.alphaTest),this.alphaHash===!0&&(i.alphaHash=!0),this.alphaToCoverage===!0&&(i.alphaToCoverage=!0),this.premultipliedAlpha===!0&&(i.premultipliedAlpha=!0),this.forceSinglePass===!0&&(i.forceSinglePass=!0),this.wireframe===!0&&(i.wireframe=!0),this.wireframeLinewidth>1&&(i.wireframeLinewidth=this.wireframeLinewidth),this.wireframeLinecap!=="round"&&(i.wireframeLinecap=this.wireframeLinecap),this.wireframeLinejoin!=="round"&&(i.wireframeLinejoin=this.wireframeLinejoin),this.flatShading===!0&&(i.flatShading=!0),this.visible===!1&&(i.visible=!1),this.toneMapped===!1&&(i.toneMapped=!1),this.fog===!1&&(i.fog=!1),Object.keys(this.userData).length>0&&(i.userData=this.userData);function n(r){let o=[];for(let a in r){let l=r[a];delete l.metadata,o.push(l)}return o}if(e){let r=n(t.textures),o=n(t.images);r.length>0&&(i.textures=r),o.length>0&&(i.images=o)}return i}clone(){return new this.constructor().copy(this)}copy(t){this.name=t.name,this.blending=t.blending,this.side=t.side,this.vertexColors=t.vertexColors,this.opacity=t.opacity,this.transparent=t.transparent,this.blendSrc=t.blendSrc,this.blendDst=t.blendDst,this.blendEquation=t.blendEquation,this.blendSrcAlpha=t.blendSrcAlpha,this.blendDstAlpha=t.blendDstAlpha,this.blendEquationAlpha=t.blendEquationAlpha,this.blendColor.copy(t.blendColor),this.blendAlpha=t.blendAlpha,this.depthFunc=t.depthFunc,this.depthTest=t.depthTest,this.depthWrite=t.depthWrite,this.stencilWriteMask=t.stencilWriteMask,this.stencilFunc=t.stencilFunc,this.stencilRef=t.stencilRef,this.stencilFuncMask=t.stencilFuncMask,this.stencilFail=t.stencilFail,this.stencilZFail=t.stencilZFail,this.stencilZPass=t.stencilZPass,this.stencilWrite=t.stencilWrite;let e=t.clippingPlanes,i=null;if(e!==null){let n=e.length;i=new Array(n);for(let r=0;r!==n;++r)i[r]=e[r].clone()}return this.clippingPlanes=i,this.clipIntersection=t.clipIntersection,this.clipShadows=t.clipShadows,this.shadowSide=t.shadowSide,this.colorWrite=t.colorWrite,this.precision=t.precision,this.polygonOffset=t.polygonOffset,this.polygonOffsetFactor=t.polygonOffsetFactor,this.polygonOffsetUnits=t.polygonOffsetUnits,this.dithering=t.dithering,this.alphaTest=t.alphaTest,this.alphaHash=t.alphaHash,this.alphaToCoverage=t.alphaToCoverage,this.premultipliedAlpha=t.premultipliedAlpha,this.forceSinglePass=t.forceSinglePass,this.visible=t.visible,this.toneMapped=t.toneMapped,this.userData=JSON.parse(JSON.stringify(t.userData)),this}dispose(){this.dispatchEvent({type:"dispose"})}set needsUpdate(t){t===!0&&this.version++}},ye=class extends Fi{constructor(t){super(),this.isMeshBasicMaterial=!0,this.type="MeshBasicMaterial",this.color=new _t(16777215),this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.specularMap=null,this.alphaMap=null,this.envMap=null,this.envMapRotation=new Re,this.combine=qa,this.reflectivity=1,this.refractionRatio=.98,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.lightMap=t.lightMap,this.lightMapIntensity=t.lightMapIntensity,this.aoMap=t.aoMap,this.aoMapIntensity=t.aoMapIntensity,this.specularMap=t.specularMap,this.alphaMap=t.alphaMap,this.envMap=t.envMap,this.envMapRotation.copy(t.envMapRotation),this.combine=t.combine,this.reflectivity=t.reflectivity,this.refractionRatio=t.refractionRatio,this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this.wireframeLinecap=t.wireframeLinecap,this.wireframeLinejoin=t.wireframeLinejoin,this.fog=t.fog,this}};var Ue=new T,Ho=new nt,n0=0,ne=class{constructor(t,e,i=!1){if(Array.isArray(t))throw new TypeError("THREE.BufferAttribute: array should be a Typed Array.");this.isBufferAttribute=!0,Object.defineProperty(this,"id",{value:n0++}),this.name="",this.array=t,this.itemSize=e,this.count=t!==void 0?t.length/e:0,this.normalized=i,this.usage=da,this.updateRanges=[],this.gpuType=Si,this.version=0}onUploadCallback(){}set needsUpdate(t){t===!0&&this.version++}setUsage(t){return this.usage=t,this}addUpdateRange(t,e){this.updateRanges.push({start:t,count:e})}clearUpdateRanges(){this.updateRanges.length=0}copy(t){return this.name=t.name,this.array=new t.array.constructor(t.array),this.itemSize=t.itemSize,this.count=t.count,this.normalized=t.normalized,this.usage=t.usage,this.gpuType=t.gpuType,this}copyAt(t,e,i){t*=this.itemSize,i*=e.itemSize;for(let n=0,r=this.itemSize;n<r;n++)this.array[t+n]=e.array[i+n];return this}copyArray(t){return this.array.set(t),this}applyMatrix3(t){if(this.itemSize===2)for(let e=0,i=this.count;e<i;e++)Ho.fromBufferAttribute(this,e),Ho.applyMatrix3(t),this.setXY(e,Ho.x,Ho.y);else if(this.itemSize===3)for(let e=0,i=this.count;e<i;e++)Ue.fromBufferAttribute(this,e),Ue.applyMatrix3(t),this.setXYZ(e,Ue.x,Ue.y,Ue.z);return this}applyMatrix4(t){for(let e=0,i=this.count;e<i;e++)Ue.fromBufferAttribute(this,e),Ue.applyMatrix4(t),this.setXYZ(e,Ue.x,Ue.y,Ue.z);return this}applyNormalMatrix(t){for(let e=0,i=this.count;e<i;e++)Ue.fromBufferAttribute(this,e),Ue.applyNormalMatrix(t),this.setXYZ(e,Ue.x,Ue.y,Ue.z);return this}transformDirection(t){for(let e=0,i=this.count;e<i;e++)Ue.fromBufferAttribute(this,e),Ue.transformDirection(t),this.setXYZ(e,Ue.x,Ue.y,Ue.z);return this}set(t,e=0){return this.array.set(t,e),this}getComponent(t,e){let i=this.array[t*this.itemSize+e];return this.normalized&&(i=Pi(i,this.array)),i}setComponent(t,e,i){return this.normalized&&(i=ce(i,this.array)),this.array[t*this.itemSize+e]=i,this}getX(t){let e=this.array[t*this.itemSize];return this.normalized&&(e=Pi(e,this.array)),e}setX(t,e){return this.normalized&&(e=ce(e,this.array)),this.array[t*this.itemSize]=e,this}getY(t){let e=this.array[t*this.itemSize+1];return this.normalized&&(e=Pi(e,this.array)),e}setY(t,e){return this.normalized&&(e=ce(e,this.array)),this.array[t*this.itemSize+1]=e,this}getZ(t){let e=this.array[t*this.itemSize+2];return this.normalized&&(e=Pi(e,this.array)),e}setZ(t,e){return this.normalized&&(e=ce(e,this.array)),this.array[t*this.itemSize+2]=e,this}getW(t){let e=this.array[t*this.itemSize+3];return this.normalized&&(e=Pi(e,this.array)),e}setW(t,e){return this.normalized&&(e=ce(e,this.array)),this.array[t*this.itemSize+3]=e,this}setXY(t,e,i){return t*=this.itemSize,this.normalized&&(e=ce(e,this.array),i=ce(i,this.array)),this.array[t+0]=e,this.array[t+1]=i,this}setXYZ(t,e,i,n){return t*=this.itemSize,this.normalized&&(e=ce(e,this.array),i=ce(i,this.array),n=ce(n,this.array)),this.array[t+0]=e,this.array[t+1]=i,this.array[t+2]=n,this}setXYZW(t,e,i,n,r){return t*=this.itemSize,this.normalized&&(e=ce(e,this.array),i=ce(i,this.array),n=ce(n,this.array),r=ce(r,this.array)),this.array[t+0]=e,this.array[t+1]=i,this.array[t+2]=n,this.array[t+3]=r,this}onUpload(t){return this.onUploadCallback=t,this}clone(){return new this.constructor(this.array,this.itemSize).copy(this)}toJSON(){let t={itemSize:this.itemSize,type:this.array.constructor.name,array:Array.from(this.array),normalized:this.normalized};return this.name!==""&&(t.name=this.name),this.usage!==da&&(t.usage=this.usage),t}};var Wn=class extends ne{constructor(t,e,i){super(new Uint16Array(t),e,i)}};var Ar=class extends ne{constructor(t,e,i){super(new Uint32Array(t),e,i)}};var Ht=class extends ne{constructor(t,e,i){super(new Float32Array(t),e,i)}},s0=0,Mi=new Ut,Dc=new Ee,xs=new T,fi=new We,cr=new We,Ve=new T,ue=class s extends rn{constructor(){super(),this.isBufferGeometry=!0,Object.defineProperty(this,"id",{value:s0++}),this.uuid=Di(),this.name="",this.type="BufferGeometry",this.index=null,this.indirect=null,this.attributes={},this.morphAttributes={},this.morphTargetsRelative=!1,this.groups=[],this.boundingBox=null,this.boundingSphere=null,this.drawRange={start:0,count:1/0},this.userData={}}getIndex(){return this.index}setIndex(t){return Array.isArray(t)?this.index=new(_h(t)?Ar:Wn)(t,1):this.index=t,this}setIndirect(t){return this.indirect=t,this}getIndirect(){return this.indirect}getAttribute(t){return this.attributes[t]}setAttribute(t,e){return this.attributes[t]=e,this}deleteAttribute(t){return delete this.attributes[t],this}hasAttribute(t){return this.attributes[t]!==void 0}addGroup(t,e,i=0){this.groups.push({start:t,count:e,materialIndex:i})}clearGroups(){this.groups=[]}setDrawRange(t,e){this.drawRange.start=t,this.drawRange.count=e}applyMatrix4(t){let e=this.attributes.position;e!==void 0&&(e.applyMatrix4(t),e.needsUpdate=!0);let i=this.attributes.normal;if(i!==void 0){let r=new Xt().getNormalMatrix(t);i.applyNormalMatrix(r),i.needsUpdate=!0}let n=this.attributes.tangent;return n!==void 0&&(n.transformDirection(t),n.needsUpdate=!0),this.boundingBox!==null&&this.computeBoundingBox(),this.boundingSphere!==null&&this.computeBoundingSphere(),this}applyQuaternion(t){return Mi.makeRotationFromQuaternion(t),this.applyMatrix4(Mi),this}rotateX(t){return Mi.makeRotationX(t),this.applyMatrix4(Mi),this}rotateY(t){return Mi.makeRotationY(t),this.applyMatrix4(Mi),this}rotateZ(t){return Mi.makeRotationZ(t),this.applyMatrix4(Mi),this}translate(t,e,i){return Mi.makeTranslation(t,e,i),this.applyMatrix4(Mi),this}scale(t,e,i){return Mi.makeScale(t,e,i),this.applyMatrix4(Mi),this}lookAt(t){return Dc.lookAt(t),Dc.updateMatrix(),this.applyMatrix4(Dc.matrix),this}center(){return this.computeBoundingBox(),this.boundingBox.getCenter(xs).negate(),this.translate(xs.x,xs.y,xs.z),this}setFromPoints(t){let e=this.getAttribute("position");if(e===void 0){let i=[];for(let n=0,r=t.length;n<r;n++){let o=t[n];i.push(o.x,o.y,o.z||0)}this.setAttribute("position",new Ht(i,3))}else{let i=Math.min(t.length,e.count);for(let n=0;n<i;n++){let r=t[n];e.setXYZ(n,r.x,r.y,r.z||0)}t.length>e.count&&console.warn("THREE.BufferGeometry: Buffer size too small for points data. Use .dispose() and create a new geometry."),e.needsUpdate=!0}return this}computeBoundingBox(){this.boundingBox===null&&(this.boundingBox=new We);let t=this.attributes.position,e=this.morphAttributes.position;if(t&&t.isGLBufferAttribute){console.error("THREE.BufferGeometry.computeBoundingBox(): GLBufferAttribute requires a manual bounding box.",this),this.boundingBox.set(new T(-1/0,-1/0,-1/0),new T(1/0,1/0,1/0));return}if(t!==void 0){if(this.boundingBox.setFromBufferAttribute(t),e)for(let i=0,n=e.length;i<n;i++){let r=e[i];fi.setFromBufferAttribute(r),this.morphTargetsRelative?(Ve.addVectors(this.boundingBox.min,fi.min),this.boundingBox.expandByPoint(Ve),Ve.addVectors(this.boundingBox.max,fi.max),this.boundingBox.expandByPoint(Ve)):(this.boundingBox.expandByPoint(fi.min),this.boundingBox.expandByPoint(fi.max))}}else this.boundingBox.makeEmpty();(isNaN(this.boundingBox.min.x)||isNaN(this.boundingBox.min.y)||isNaN(this.boundingBox.min.z))&&console.error('THREE.BufferGeometry.computeBoundingBox(): Computed min/max have NaN values. The "position" attribute is likely to have NaN values.',this)}computeBoundingSphere(){this.boundingSphere===null&&(this.boundingSphere=new ri);let t=this.attributes.position,e=this.morphAttributes.position;if(t&&t.isGLBufferAttribute){console.error("THREE.BufferGeometry.computeBoundingSphere(): GLBufferAttribute requires a manual bounding sphere.",this),this.boundingSphere.set(new T,1/0);return}if(t){let i=this.boundingSphere.center;if(fi.setFromBufferAttribute(t),e)for(let r=0,o=e.length;r<o;r++){let a=e[r];cr.setFromBufferAttribute(a),this.morphTargetsRelative?(Ve.addVectors(fi.min,cr.min),fi.expandByPoint(Ve),Ve.addVectors(fi.max,cr.max),fi.expandByPoint(Ve)):(fi.expandByPoint(cr.min),fi.expandByPoint(cr.max))}fi.getCenter(i);let n=0;for(let r=0,o=t.count;r<o;r++)Ve.fromBufferAttribute(t,r),n=Math.max(n,i.distanceToSquared(Ve));if(e)for(let r=0,o=e.length;r<o;r++){let a=e[r],l=this.morphTargetsRelative;for(let c=0,h=a.count;c<h;c++)Ve.fromBufferAttribute(a,c),l&&(xs.fromBufferAttribute(t,c),Ve.add(xs)),n=Math.max(n,i.distanceToSquared(Ve))}this.boundingSphere.radius=Math.sqrt(n),isNaN(this.boundingSphere.radius)&&console.error('THREE.BufferGeometry.computeBoundingSphere(): Computed radius is NaN. The "position" attribute is likely to have NaN values.',this)}}computeTangents(){let t=this.index,e=this.attributes;if(t===null||e.position===void 0||e.normal===void 0||e.uv===void 0){console.error("THREE.BufferGeometry: .computeTangents() failed. Missing required attributes (index, position, normal or uv)");return}let i=e.position,n=e.normal,r=e.uv;this.hasAttribute("tangent")===!1&&this.setAttribute("tangent",new ne(new Float32Array(4*i.count),4));let o=this.getAttribute("tangent"),a=[],l=[];for(let L=0;L<i.count;L++)a[L]=new T,l[L]=new T;let c=new T,h=new T,u=new T,f=new nt,d=new nt,g=new nt,x=new T,m=new T;function p(L,w,v){c.fromBufferAttribute(i,L),h.fromBufferAttribute(i,w),u.fromBufferAttribute(i,v),f.fromBufferAttribute(r,L),d.fromBufferAttribute(r,w),g.fromBufferAttribute(r,v),h.sub(c),u.sub(c),d.sub(f),g.sub(f);let C=1/(d.x*g.y-g.x*d.y);isFinite(C)&&(x.copy(h).multiplyScalar(g.y).addScaledVector(u,-d.y).multiplyScalar(C),m.copy(u).multiplyScalar(d.x).addScaledVector(h,-g.x).multiplyScalar(C),a[L].add(x),a[w].add(x),a[v].add(x),l[L].add(m),l[w].add(m),l[v].add(m))}let M=this.groups;M.length===0&&(M=[{start:0,count:t.count}]);for(let L=0,w=M.length;L<w;++L){let v=M[L],C=v.start,U=v.count;for(let O=C,z=C+U;O<z;O+=3)p(t.getX(O+0),t.getX(O+1),t.getX(O+2))}let y=new T,_=new T,b=new T,E=new T;function P(L){b.fromBufferAttribute(n,L),E.copy(b);let w=a[L];y.copy(w),y.sub(b.multiplyScalar(b.dot(w))).normalize(),_.crossVectors(E,w);let C=_.dot(l[L])<0?-1:1;o.setXYZW(L,y.x,y.y,y.z,C)}for(let L=0,w=M.length;L<w;++L){let v=M[L],C=v.start,U=v.count;for(let O=C,z=C+U;O<z;O+=3)P(t.getX(O+0)),P(t.getX(O+1)),P(t.getX(O+2))}}computeVertexNormals(){let t=this.index,e=this.getAttribute("position");if(e!==void 0){let i=this.getAttribute("normal");if(i===void 0)i=new ne(new Float32Array(e.count*3),3),this.setAttribute("normal",i);else for(let f=0,d=i.count;f<d;f++)i.setXYZ(f,0,0,0);let n=new T,r=new T,o=new T,a=new T,l=new T,c=new T,h=new T,u=new T;if(t)for(let f=0,d=t.count;f<d;f+=3){let g=t.getX(f+0),x=t.getX(f+1),m=t.getX(f+2);n.fromBufferAttribute(e,g),r.fromBufferAttribute(e,x),o.fromBufferAttribute(e,m),h.subVectors(o,r),u.subVectors(n,r),h.cross(u),a.fromBufferAttribute(i,g),l.fromBufferAttribute(i,x),c.fromBufferAttribute(i,m),a.add(h),l.add(h),c.add(h),i.setXYZ(g,a.x,a.y,a.z),i.setXYZ(x,l.x,l.y,l.z),i.setXYZ(m,c.x,c.y,c.z)}else for(let f=0,d=e.count;f<d;f+=3)n.fromBufferAttribute(e,f+0),r.fromBufferAttribute(e,f+1),o.fromBufferAttribute(e,f+2),h.subVectors(o,r),u.subVectors(n,r),h.cross(u),i.setXYZ(f+0,h.x,h.y,h.z),i.setXYZ(f+1,h.x,h.y,h.z),i.setXYZ(f+2,h.x,h.y,h.z);this.normalizeNormals(),i.needsUpdate=!0}}normalizeNormals(){let t=this.attributes.normal;for(let e=0,i=t.count;e<i;e++)Ve.fromBufferAttribute(t,e),Ve.normalize(),t.setXYZ(e,Ve.x,Ve.y,Ve.z)}toNonIndexed(){function t(a,l){let c=a.array,h=a.itemSize,u=a.normalized,f=new c.constructor(l.length*h),d=0,g=0;for(let x=0,m=l.length;x<m;x++){a.isInterleavedBufferAttribute?d=l[x]*a.data.stride+a.offset:d=l[x]*h;for(let p=0;p<h;p++)f[g++]=c[d++]}return new ne(f,h,u)}if(this.index===null)return console.warn("THREE.BufferGeometry.toNonIndexed(): BufferGeometry is already non-indexed."),this;let e=new s,i=this.index.array,n=this.attributes;for(let a in n){let l=n[a],c=t(l,i);e.setAttribute(a,c)}let r=this.morphAttributes;for(let a in r){let l=[],c=r[a];for(let h=0,u=c.length;h<u;h++){let f=c[h],d=t(f,i);l.push(d)}e.morphAttributes[a]=l}e.morphTargetsRelative=this.morphTargetsRelative;let o=this.groups;for(let a=0,l=o.length;a<l;a++){let c=o[a];e.addGroup(c.start,c.count,c.materialIndex)}return e}toJSON(){let t={metadata:{version:4.7,type:"BufferGeometry",generator:"BufferGeometry.toJSON"}};if(t.uuid=this.uuid,t.type=this.type,this.name!==""&&(t.name=this.name),Object.keys(this.userData).length>0&&(t.userData=this.userData),this.parameters!==void 0){let l=this.parameters;for(let c in l)l[c]!==void 0&&(t[c]=l[c]);return t}t.data={attributes:{}};let e=this.index;e!==null&&(t.data.index={type:e.array.constructor.name,array:Array.prototype.slice.call(e.array)});let i=this.attributes;for(let l in i){let c=i[l];t.data.attributes[l]=c.toJSON(t.data)}let n={},r=!1;for(let l in this.morphAttributes){let c=this.morphAttributes[l],h=[];for(let u=0,f=c.length;u<f;u++){let d=c[u];h.push(d.toJSON(t.data))}h.length>0&&(n[l]=h,r=!0)}r&&(t.data.morphAttributes=n,t.data.morphTargetsRelative=this.morphTargetsRelative);let o=this.groups;o.length>0&&(t.data.groups=JSON.parse(JSON.stringify(o)));let a=this.boundingSphere;return a!==null&&(t.data.boundingSphere=a.toJSON()),t}clone(){return new this.constructor().copy(this)}copy(t){this.index=null,this.attributes={},this.morphAttributes={},this.groups=[],this.boundingBox=null,this.boundingSphere=null;let e={};this.name=t.name;let i=t.index;i!==null&&this.setIndex(i.clone());let n=t.attributes;for(let c in n){let h=n[c];this.setAttribute(c,h.clone(e))}let r=t.morphAttributes;for(let c in r){let h=[],u=r[c];for(let f=0,d=u.length;f<d;f++)h.push(u[f].clone(e));this.morphAttributes[c]=h}this.morphTargetsRelative=t.morphTargetsRelative;let o=t.groups;for(let c=0,h=o.length;c<h;c++){let u=o[c];this.addGroup(u.start,u.count,u.materialIndex)}let a=t.boundingBox;a!==null&&(this.boundingBox=a.clone());let l=t.boundingSphere;return l!==null&&(this.boundingSphere=l.clone()),this.drawRange.start=t.drawRange.start,this.drawRange.count=t.drawRange.count,this.userData=t.userData,this}dispose(){this.dispatchEvent({type:"dispose"})}},Hu=new Ut,On=new Ps,Vo=new ri,Vu=new T,Go=new T,Wo=new T,Xo=new T,Uc=new T,qo=new T,Gu=new T,Yo=new T,Et=class extends Ee{constructor(t=new ue,e=new ye){super(),this.isMesh=!0,this.type="Mesh",this.geometry=t,this.material=e,this.morphTargetDictionary=void 0,this.morphTargetInfluences=void 0,this.count=1,this.updateMorphTargets()}copy(t,e){return super.copy(t,e),t.morphTargetInfluences!==void 0&&(this.morphTargetInfluences=t.morphTargetInfluences.slice()),t.morphTargetDictionary!==void 0&&(this.morphTargetDictionary=Object.assign({},t.morphTargetDictionary)),this.material=Array.isArray(t.material)?t.material.slice():t.material,this.geometry=t.geometry,this}updateMorphTargets(){let e=this.geometry.morphAttributes,i=Object.keys(e);if(i.length>0){let n=e[i[0]];if(n!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let r=0,o=n.length;r<o;r++){let a=n[r].name||String(r);this.morphTargetInfluences.push(0),this.morphTargetDictionary[a]=r}}}}getVertexPosition(t,e){let i=this.geometry,n=i.attributes.position,r=i.morphAttributes.position,o=i.morphTargetsRelative;e.fromBufferAttribute(n,t);let a=this.morphTargetInfluences;if(r&&a){qo.set(0,0,0);for(let l=0,c=r.length;l<c;l++){let h=a[l],u=r[l];h!==0&&(Uc.fromBufferAttribute(u,t),o?qo.addScaledVector(Uc,h):qo.addScaledVector(Uc.sub(e),h))}e.add(qo)}return e}raycast(t,e){let i=this.geometry,n=this.material,r=this.matrixWorld;n!==void 0&&(i.boundingSphere===null&&i.computeBoundingSphere(),Vo.copy(i.boundingSphere),Vo.applyMatrix4(r),On.copy(t.ray).recast(t.near),!(Vo.containsPoint(On.origin)===!1&&(On.intersectSphere(Vo,Vu)===null||On.origin.distanceToSquared(Vu)>(t.far-t.near)**2))&&(Hu.copy(r).invert(),On.copy(t.ray).applyMatrix4(Hu),!(i.boundingBox!==null&&On.intersectsBox(i.boundingBox)===!1)&&this._computeIntersections(t,e,On)))}_computeIntersections(t,e,i){let n,r=this.geometry,o=this.material,a=r.index,l=r.attributes.position,c=r.attributes.uv,h=r.attributes.uv1,u=r.attributes.normal,f=r.groups,d=r.drawRange;if(a!==null)if(Array.isArray(o))for(let g=0,x=f.length;g<x;g++){let m=f[g],p=o[m.materialIndex],M=Math.max(m.start,d.start),y=Math.min(a.count,Math.min(m.start+m.count,d.start+d.count));for(let _=M,b=y;_<b;_+=3){let E=a.getX(_),P=a.getX(_+1),L=a.getX(_+2);n=Zo(this,p,t,i,c,h,u,E,P,L),n&&(n.faceIndex=Math.floor(_/3),n.face.materialIndex=m.materialIndex,e.push(n))}}else{let g=Math.max(0,d.start),x=Math.min(a.count,d.start+d.count);for(let m=g,p=x;m<p;m+=3){let M=a.getX(m),y=a.getX(m+1),_=a.getX(m+2);n=Zo(this,o,t,i,c,h,u,M,y,_),n&&(n.faceIndex=Math.floor(m/3),e.push(n))}}else if(l!==void 0)if(Array.isArray(o))for(let g=0,x=f.length;g<x;g++){let m=f[g],p=o[m.materialIndex],M=Math.max(m.start,d.start),y=Math.min(l.count,Math.min(m.start+m.count,d.start+d.count));for(let _=M,b=y;_<b;_+=3){let E=_,P=_+1,L=_+2;n=Zo(this,p,t,i,c,h,u,E,P,L),n&&(n.faceIndex=Math.floor(_/3),n.face.materialIndex=m.materialIndex,e.push(n))}}else{let g=Math.max(0,d.start),x=Math.min(l.count,d.start+d.count);for(let m=g,p=x;m<p;m+=3){let M=m,y=m+1,_=m+2;n=Zo(this,o,t,i,c,h,u,M,y,_),n&&(n.faceIndex=Math.floor(m/3),e.push(n))}}}};function r0(s,t,e,i,n,r,o,a){let l;if(t.side===qe?l=i.intersectTriangle(o,r,n,!0,a):l=i.intersectTriangle(n,r,o,t.side===bi,a),l===null)return null;Yo.copy(a),Yo.applyMatrix4(s.matrixWorld);let c=e.ray.origin.distanceTo(Yo);return c<e.near||c>e.far?null:{distance:c,point:Yo.clone(),object:s}}function Zo(s,t,e,i,n,r,o,a,l,c){s.getVertexPosition(a,Go),s.getVertexPosition(l,Wo),s.getVertexPosition(c,Xo);let h=r0(s,t,e,i,Go,Wo,Xo,Gu);if(h){let u=new T;nn.getBarycoord(Gu,Go,Wo,Xo,u),n&&(h.uv=nn.getInterpolatedAttribute(n,a,l,c,u,new nt)),r&&(h.uv1=nn.getInterpolatedAttribute(r,a,l,c,u,new nt)),o&&(h.normal=nn.getInterpolatedAttribute(o,a,l,c,u,new T),h.normal.dot(i.direction)>0&&h.normal.multiplyScalar(-1));let f={a,b:l,c,normal:new T,materialIndex:0};nn.getNormal(Go,Wo,Xo,f.normal),h.face=f,h.barycoord=u}return h}var oi=class s extends ue{constructor(t=1,e=1,i=1,n=1,r=1,o=1){super(),this.type="BoxGeometry",this.parameters={width:t,height:e,depth:i,widthSegments:n,heightSegments:r,depthSegments:o};let a=this;n=Math.floor(n),r=Math.floor(r),o=Math.floor(o);let l=[],c=[],h=[],u=[],f=0,d=0;g("z","y","x",-1,-1,i,e,t,o,r,0),g("z","y","x",1,-1,i,e,-t,o,r,1),g("x","z","y",1,1,t,i,e,n,o,2),g("x","z","y",1,-1,t,i,-e,n,o,3),g("x","y","z",1,-1,t,e,i,n,r,4),g("x","y","z",-1,-1,t,e,-i,n,r,5),this.setIndex(l),this.setAttribute("position",new Ht(c,3)),this.setAttribute("normal",new Ht(h,3)),this.setAttribute("uv",new Ht(u,2));function g(x,m,p,M,y,_,b,E,P,L,w){let v=_/P,C=b/L,U=_/2,O=b/2,z=E/2,q=P+1,H=L+1,it=0,X=0,ct=new T;for(let mt=0;mt<H;mt++){let bt=mt*C-O;for(let Wt=0;Wt<q;Wt++){let jt=Wt*v-U;ct[x]=jt*M,ct[m]=bt*y,ct[p]=z,c.push(ct.x,ct.y,ct.z),ct[x]=0,ct[m]=0,ct[p]=E>0?1:-1,h.push(ct.x,ct.y,ct.z),u.push(Wt/P),u.push(1-mt/L),it+=1}}for(let mt=0;mt<L;mt++)for(let bt=0;bt<P;bt++){let Wt=f+bt+q*mt,jt=f+bt+q*(mt+1),le=f+(bt+1)+q*(mt+1),Qt=f+(bt+1)+q*mt;l.push(Wt,jt,Qt),l.push(jt,le,Qt),X+=6}a.addGroup(d,X,w),d+=X,f+=it}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new s(t.width,t.height,t.depth,t.widthSegments,t.heightSegments,t.depthSegments)}};function ts(s){let t={};for(let e in s){t[e]={};for(let i in s[e]){let n=s[e][i];n&&(n.isColor||n.isMatrix3||n.isMatrix4||n.isVector2||n.isVector3||n.isVector4||n.isTexture||n.isQuaternion)?n.isRenderTargetTexture?(console.warn("UniformsUtils: Textures of render targets cannot be cloned via cloneUniforms() or mergeUniforms()."),t[e][i]=null):t[e][i]=n.clone():Array.isArray(n)?t[e][i]=n.slice():t[e][i]=n}}return t}function Qe(s){let t={};for(let e=0;e<s.length;e++){let i=ts(s[e]);for(let n in i)t[n]=i[n]}return t}function o0(s){let t=[];for(let e=0;e<s.length;e++)t.push(s[e].clone());return t}function yh(s){let t=s.getRenderTarget();return t===null?s.outputColorSpace:t.isXRRenderTarget===!0?t.texture.colorSpace:te.workingColorSpace}var Dl={clone:ts,merge:Qe},a0=`void main() {
	gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}`,l0=`void main() {
	gl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );
}`,Xe=class extends Fi{constructor(t){super(),this.isShaderMaterial=!0,this.type="ShaderMaterial",this.defines={},this.uniforms={},this.uniformsGroups=[],this.vertexShader=a0,this.fragmentShader=l0,this.linewidth=1,this.wireframe=!1,this.wireframeLinewidth=1,this.fog=!1,this.lights=!1,this.clipping=!1,this.forceSinglePass=!0,this.extensions={clipCullDistance:!1,multiDraw:!1},this.defaultAttributeValues={color:[1,1,1],uv:[0,0],uv1:[0,0]},this.index0AttributeName=void 0,this.uniformsNeedUpdate=!1,this.glslVersion=null,t!==void 0&&this.setValues(t)}copy(t){return super.copy(t),this.fragmentShader=t.fragmentShader,this.vertexShader=t.vertexShader,this.uniforms=ts(t.uniforms),this.uniformsGroups=o0(t.uniformsGroups),this.defines=Object.assign({},t.defines),this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this.fog=t.fog,this.lights=t.lights,this.clipping=t.clipping,this.extensions=Object.assign({},t.extensions),this.glslVersion=t.glslVersion,this}toJSON(t){let e=super.toJSON(t);e.glslVersion=this.glslVersion,e.uniforms={};for(let n in this.uniforms){let o=this.uniforms[n].value;o&&o.isTexture?e.uniforms[n]={type:"t",value:o.toJSON(t).uuid}:o&&o.isColor?e.uniforms[n]={type:"c",value:o.getHex()}:o&&o.isVector2?e.uniforms[n]={type:"v2",value:o.toArray()}:o&&o.isVector3?e.uniforms[n]={type:"v3",value:o.toArray()}:o&&o.isVector4?e.uniforms[n]={type:"v4",value:o.toArray()}:o&&o.isMatrix3?e.uniforms[n]={type:"m3",value:o.toArray()}:o&&o.isMatrix4?e.uniforms[n]={type:"m4",value:o.toArray()}:e.uniforms[n]={value:o}}Object.keys(this.defines).length>0&&(e.defines=this.defines),e.vertexShader=this.vertexShader,e.fragmentShader=this.fragmentShader,e.lights=this.lights,e.clipping=this.clipping;let i={};for(let n in this.extensions)this.extensions[n]===!0&&(i[n]=!0);return Object.keys(i).length>0&&(e.extensions=i),e}},Rr=class extends Ee{constructor(){super(),this.isCamera=!0,this.type="Camera",this.matrixWorldInverse=new Ut,this.projectionMatrix=new Ut,this.projectionMatrixInverse=new Ut,this.coordinateSystem=Li,this._reversedDepth=!1}get reversedDepth(){return this._reversedDepth}copy(t,e){return super.copy(t,e),this.matrixWorldInverse.copy(t.matrixWorldInverse),this.projectionMatrix.copy(t.projectionMatrix),this.projectionMatrixInverse.copy(t.projectionMatrixInverse),this.coordinateSystem=t.coordinateSystem,this}getWorldDirection(t){return super.getWorldDirection(t).negate()}updateMatrixWorld(t){super.updateMatrixWorld(t),this.matrixWorldInverse.copy(this.matrixWorld).invert()}updateWorldMatrix(t,e){super.updateWorldMatrix(t,e),this.matrixWorldInverse.copy(this.matrixWorld).invert()}clone(){return new this.constructor().copy(this)}},Mn=new T,Wu=new nt,Xu=new nt,Le=class extends Rr{constructor(t=50,e=1,i=.1,n=2e3){super(),this.isPerspectiveCamera=!0,this.type="PerspectiveCamera",this.fov=t,this.zoom=1,this.near=i,this.far=n,this.focus=10,this.aspect=e,this.view=null,this.filmGauge=35,this.filmOffset=0,this.updateProjectionMatrix()}copy(t,e){return super.copy(t,e),this.fov=t.fov,this.zoom=t.zoom,this.near=t.near,this.far=t.far,this.focus=t.focus,this.aspect=t.aspect,this.view=t.view===null?null:Object.assign({},t.view),this.filmGauge=t.filmGauge,this.filmOffset=t.filmOffset,this}setFocalLength(t){let e=.5*this.getFilmHeight()/t;this.fov=Rs*2*Math.atan(e),this.updateProjectionMatrix()}getFocalLength(){let t=Math.tan(xr*.5*this.fov);return .5*this.getFilmHeight()/t}getEffectiveFOV(){return Rs*2*Math.atan(Math.tan(xr*.5*this.fov)/this.zoom)}getFilmWidth(){return this.filmGauge*Math.min(this.aspect,1)}getFilmHeight(){return this.filmGauge/Math.max(this.aspect,1)}getViewBounds(t,e,i){Mn.set(-1,-1,.5).applyMatrix4(this.projectionMatrixInverse),e.set(Mn.x,Mn.y).multiplyScalar(-t/Mn.z),Mn.set(1,1,.5).applyMatrix4(this.projectionMatrixInverse),i.set(Mn.x,Mn.y).multiplyScalar(-t/Mn.z)}getViewSize(t,e){return this.getViewBounds(t,Wu,Xu),e.subVectors(Xu,Wu)}setViewOffset(t,e,i,n,r,o){this.aspect=t/e,this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=t,this.view.fullHeight=e,this.view.offsetX=i,this.view.offsetY=n,this.view.width=r,this.view.height=o,this.updateProjectionMatrix()}clearViewOffset(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()}updateProjectionMatrix(){let t=this.near,e=t*Math.tan(xr*.5*this.fov)/this.zoom,i=2*e,n=this.aspect*i,r=-.5*n,o=this.view;if(this.view!==null&&this.view.enabled){let l=o.fullWidth,c=o.fullHeight;r+=o.offsetX*n/l,e-=o.offsetY*i/c,n*=o.width/l,i*=o.height/c}let a=this.filmOffset;a!==0&&(r+=t*a/this.getFilmWidth()),this.projectionMatrix.makePerspective(r,r+n,e,e-i,t,this.far,this.coordinateSystem,this.reversedDepth),this.projectionMatrixInverse.copy(this.projectionMatrix).invert()}toJSON(t){let e=super.toJSON(t);return e.object.fov=this.fov,e.object.zoom=this.zoom,e.object.near=this.near,e.object.far=this.far,e.object.focus=this.focus,e.object.aspect=this.aspect,this.view!==null&&(e.object.view=Object.assign({},this.view)),e.object.filmGauge=this.filmGauge,e.object.filmOffset=this.filmOffset,e}},_s=-90,ys=1,ga=class extends Ee{constructor(t,e,i){super(),this.type="CubeCamera",this.renderTarget=i,this.coordinateSystem=null,this.activeMipmapLevel=0;let n=new Le(_s,ys,t,e);n.layers=this.layers,this.add(n);let r=new Le(_s,ys,t,e);r.layers=this.layers,this.add(r);let o=new Le(_s,ys,t,e);o.layers=this.layers,this.add(o);let a=new Le(_s,ys,t,e);a.layers=this.layers,this.add(a);let l=new Le(_s,ys,t,e);l.layers=this.layers,this.add(l);let c=new Le(_s,ys,t,e);c.layers=this.layers,this.add(c)}updateCoordinateSystem(){let t=this.coordinateSystem,e=this.children.concat(),[i,n,r,o,a,l]=e;for(let c of e)this.remove(c);if(t===Li)i.up.set(0,1,0),i.lookAt(1,0,0),n.up.set(0,1,0),n.lookAt(-1,0,0),r.up.set(0,0,-1),r.lookAt(0,1,0),o.up.set(0,0,1),o.lookAt(0,-1,0),a.up.set(0,1,0),a.lookAt(0,0,1),l.up.set(0,1,0),l.lookAt(0,0,-1);else if(t===wr)i.up.set(0,-1,0),i.lookAt(-1,0,0),n.up.set(0,-1,0),n.lookAt(1,0,0),r.up.set(0,0,1),r.lookAt(0,1,0),o.up.set(0,0,-1),o.lookAt(0,-1,0),a.up.set(0,-1,0),a.lookAt(0,0,1),l.up.set(0,-1,0),l.lookAt(0,0,-1);else throw new Error("THREE.CubeCamera.updateCoordinateSystem(): Invalid coordinate system: "+t);for(let c of e)this.add(c),c.updateMatrixWorld()}update(t,e){this.parent===null&&this.updateMatrixWorld();let{renderTarget:i,activeMipmapLevel:n}=this;this.coordinateSystem!==t.coordinateSystem&&(this.coordinateSystem=t.coordinateSystem,this.updateCoordinateSystem());let[r,o,a,l,c,h]=this.children,u=t.getRenderTarget(),f=t.getActiveCubeFace(),d=t.getActiveMipmapLevel(),g=t.xr.enabled;t.xr.enabled=!1;let x=i.texture.generateMipmaps;i.texture.generateMipmaps=!1,t.setRenderTarget(i,0,n),t.render(e,r),t.setRenderTarget(i,1,n),t.render(e,o),t.setRenderTarget(i,2,n),t.render(e,a),t.setRenderTarget(i,3,n),t.render(e,l),t.setRenderTarget(i,4,n),t.render(e,c),i.texture.generateMipmaps=x,t.setRenderTarget(i,5,n),t.render(e,h),t.setRenderTarget(u,f,d),t.xr.enabled=g,i.texture.needsPMREMUpdate=!0}},Cr=class extends si{constructor(t=[],e=jn,i,n,r,o,a,l,c,h){super(t,e,i,n,r,o,a,l,c,h),this.isCubeTexture=!0,this.flipY=!1}get images(){return this.image}set images(t){this.image=t}},xa=class extends wi{constructor(t=1,e={}){super(t,t,e),this.isWebGLCubeRenderTarget=!0;let i={width:t,height:t,depth:1},n=[i,i,i,i,i,i];this.texture=new Cr(n),this._setTextureOptions(e),this.texture.isRenderTargetTexture=!0}fromEquirectangularTexture(t,e){this.texture.type=e.type,this.texture.colorSpace=e.colorSpace,this.texture.generateMipmaps=e.generateMipmaps,this.texture.minFilter=e.minFilter,this.texture.magFilter=e.magFilter;let i={uniforms:{tEquirect:{value:null}},vertexShader:`

				varying vec3 vWorldDirection;

				vec3 transformDirection( in vec3 dir, in mat4 matrix ) {

					return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );

				}

				void main() {

					vWorldDirection = transformDirection( position, modelMatrix );

					#include <begin_vertex>
					#include <project_vertex>

				}
			`,fragmentShader:`

				uniform sampler2D tEquirect;

				varying vec3 vWorldDirection;

				#include <common>

				void main() {

					vec3 direction = normalize( vWorldDirection );

					vec2 sampleUV = equirectUv( direction );

					gl_FragColor = texture2D( tEquirect, sampleUV );

				}
			`},n=new oi(5,5,5),r=new Xe({name:"CubemapFromEquirect",uniforms:ts(i.uniforms),vertexShader:i.vertexShader,fragmentShader:i.fragmentShader,side:qe,blending:ln});r.uniforms.tEquirect.value=e;let o=new Et(n,r),a=e.minFilter;return e.minFilter===Rn&&(e.minFilter=Ni),new ga(1,10,this).update(t,o),e.minFilter=a,o.geometry.dispose(),o.material.dispose(),this}clear(t,e=!0,i=!0,n=!0){let r=t.getRenderTarget();for(let o=0;o<6;o++)t.setRenderTarget(this,o),t.clear(e,i,n);t.setRenderTarget(r)}},fe=class extends Ee{constructor(){super(),this.isGroup=!0,this.type="Group"}},c0={type:"move"},Ls=class{constructor(){this._targetRay=null,this._grip=null,this._hand=null}getHandSpace(){return this._hand===null&&(this._hand=new fe,this._hand.matrixAutoUpdate=!1,this._hand.visible=!1,this._hand.joints={},this._hand.inputState={pinching:!1}),this._hand}getTargetRaySpace(){return this._targetRay===null&&(this._targetRay=new fe,this._targetRay.matrixAutoUpdate=!1,this._targetRay.visible=!1,this._targetRay.hasLinearVelocity=!1,this._targetRay.linearVelocity=new T,this._targetRay.hasAngularVelocity=!1,this._targetRay.angularVelocity=new T),this._targetRay}getGripSpace(){return this._grip===null&&(this._grip=new fe,this._grip.matrixAutoUpdate=!1,this._grip.visible=!1,this._grip.hasLinearVelocity=!1,this._grip.linearVelocity=new T,this._grip.hasAngularVelocity=!1,this._grip.angularVelocity=new T),this._grip}dispatchEvent(t){return this._targetRay!==null&&this._targetRay.dispatchEvent(t),this._grip!==null&&this._grip.dispatchEvent(t),this._hand!==null&&this._hand.dispatchEvent(t),this}connect(t){if(t&&t.hand){let e=this._hand;if(e)for(let i of t.hand.values())this._getHandJoint(e,i)}return this.dispatchEvent({type:"connected",data:t}),this}disconnect(t){return this.dispatchEvent({type:"disconnected",data:t}),this._targetRay!==null&&(this._targetRay.visible=!1),this._grip!==null&&(this._grip.visible=!1),this._hand!==null&&(this._hand.visible=!1),this}update(t,e,i){let n=null,r=null,o=null,a=this._targetRay,l=this._grip,c=this._hand;if(t&&e.session.visibilityState!=="visible-blurred"){if(c&&t.hand){o=!0;for(let x of t.hand.values()){let m=e.getJointPose(x,i),p=this._getHandJoint(c,x);m!==null&&(p.matrix.fromArray(m.transform.matrix),p.matrix.decompose(p.position,p.rotation,p.scale),p.matrixWorldNeedsUpdate=!0,p.jointRadius=m.radius),p.visible=m!==null}let h=c.joints["index-finger-tip"],u=c.joints["thumb-tip"],f=h.position.distanceTo(u.position),d=.02,g=.005;c.inputState.pinching&&f>d+g?(c.inputState.pinching=!1,this.dispatchEvent({type:"pinchend",handedness:t.handedness,target:this})):!c.inputState.pinching&&f<=d-g&&(c.inputState.pinching=!0,this.dispatchEvent({type:"pinchstart",handedness:t.handedness,target:this}))}else l!==null&&t.gripSpace&&(r=e.getPose(t.gripSpace,i),r!==null&&(l.matrix.fromArray(r.transform.matrix),l.matrix.decompose(l.position,l.rotation,l.scale),l.matrixWorldNeedsUpdate=!0,r.linearVelocity?(l.hasLinearVelocity=!0,l.linearVelocity.copy(r.linearVelocity)):l.hasLinearVelocity=!1,r.angularVelocity?(l.hasAngularVelocity=!0,l.angularVelocity.copy(r.angularVelocity)):l.hasAngularVelocity=!1));a!==null&&(n=e.getPose(t.targetRaySpace,i),n===null&&r!==null&&(n=r),n!==null&&(a.matrix.fromArray(n.transform.matrix),a.matrix.decompose(a.position,a.rotation,a.scale),a.matrixWorldNeedsUpdate=!0,n.linearVelocity?(a.hasLinearVelocity=!0,a.linearVelocity.copy(n.linearVelocity)):a.hasLinearVelocity=!1,n.angularVelocity?(a.hasAngularVelocity=!0,a.angularVelocity.copy(n.angularVelocity)):a.hasAngularVelocity=!1,this.dispatchEvent(c0)))}return a!==null&&(a.visible=n!==null),l!==null&&(l.visible=r!==null),c!==null&&(c.visible=o!==null),this}_getHandJoint(t,e){if(t.joints[e.jointName]===void 0){let i=new fe;i.matrixAutoUpdate=!1,i.visible=!1,t.joints[e.jointName]=i,t.add(i)}return t.joints[e.jointName]}};var Ir=class s{constructor(t,e=1,i=1e3){this.isFog=!0,this.name="",this.color=new _t(t),this.near=e,this.far=i}clone(){return new s(this.color,this.near,this.far)}toJSON(){return{type:"Fog",name:this.name,color:this.color.getHex(),near:this.near,far:this.far}}},Gi=class extends Ee{constructor(){super(),this.isScene=!0,this.type="Scene",this.background=null,this.environment=null,this.fog=null,this.backgroundBlurriness=0,this.backgroundIntensity=1,this.backgroundRotation=new Re,this.environmentIntensity=1,this.environmentRotation=new Re,this.overrideMaterial=null,typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}copy(t,e){return super.copy(t,e),t.background!==null&&(this.background=t.background.clone()),t.environment!==null&&(this.environment=t.environment.clone()),t.fog!==null&&(this.fog=t.fog.clone()),this.backgroundBlurriness=t.backgroundBlurriness,this.backgroundIntensity=t.backgroundIntensity,this.backgroundRotation.copy(t.backgroundRotation),this.environmentIntensity=t.environmentIntensity,this.environmentRotation.copy(t.environmentRotation),t.overrideMaterial!==null&&(this.overrideMaterial=t.overrideMaterial.clone()),this.matrixAutoUpdate=t.matrixAutoUpdate,this}toJSON(t){let e=super.toJSON(t);return this.fog!==null&&(e.object.fog=this.fog.toJSON()),this.backgroundBlurriness>0&&(e.object.backgroundBlurriness=this.backgroundBlurriness),this.backgroundIntensity!==1&&(e.object.backgroundIntensity=this.backgroundIntensity),e.object.backgroundRotation=this.backgroundRotation.toArray(),this.environmentIntensity!==1&&(e.object.environmentIntensity=this.environmentIntensity),e.object.environmentRotation=this.environmentRotation.toArray(),e}},Pr=class{constructor(t,e){this.isInterleavedBuffer=!0,this.array=t,this.stride=e,this.count=t!==void 0?t.length/e:0,this.usage=da,this.updateRanges=[],this.version=0,this.uuid=Di()}onUploadCallback(){}set needsUpdate(t){t===!0&&this.version++}setUsage(t){return this.usage=t,this}addUpdateRange(t,e){this.updateRanges.push({start:t,count:e})}clearUpdateRanges(){this.updateRanges.length=0}copy(t){return this.array=new t.array.constructor(t.array),this.count=t.count,this.stride=t.stride,this.usage=t.usage,this}copyAt(t,e,i){t*=this.stride,i*=e.stride;for(let n=0,r=this.stride;n<r;n++)this.array[t+n]=e.array[i+n];return this}set(t,e=0){return this.array.set(t,e),this}clone(t){t.arrayBuffers===void 0&&(t.arrayBuffers={}),this.array.buffer._uuid===void 0&&(this.array.buffer._uuid=Di()),t.arrayBuffers[this.array.buffer._uuid]===void 0&&(t.arrayBuffers[this.array.buffer._uuid]=this.array.slice(0).buffer);let e=new this.array.constructor(t.arrayBuffers[this.array.buffer._uuid]),i=new this.constructor(e,this.stride);return i.setUsage(this.usage),i}onUpload(t){return this.onUploadCallback=t,this}toJSON(t){return t.arrayBuffers===void 0&&(t.arrayBuffers={}),this.array.buffer._uuid===void 0&&(this.array.buffer._uuid=Di()),t.arrayBuffers[this.array.buffer._uuid]===void 0&&(t.arrayBuffers[this.array.buffer._uuid]=Array.from(new Uint32Array(this.array.buffer))),{uuid:this.uuid,buffer:this.array.buffer._uuid,type:this.array.constructor.name,stride:this.stride}}},ni=new T,Ds=class s{constructor(t,e,i,n=!1){this.isInterleavedBufferAttribute=!0,this.name="",this.data=t,this.itemSize=e,this.offset=i,this.normalized=n}get count(){return this.data.count}get array(){return this.data.array}set needsUpdate(t){this.data.needsUpdate=t}applyMatrix4(t){for(let e=0,i=this.data.count;e<i;e++)ni.fromBufferAttribute(this,e),ni.applyMatrix4(t),this.setXYZ(e,ni.x,ni.y,ni.z);return this}applyNormalMatrix(t){for(let e=0,i=this.count;e<i;e++)ni.fromBufferAttribute(this,e),ni.applyNormalMatrix(t),this.setXYZ(e,ni.x,ni.y,ni.z);return this}transformDirection(t){for(let e=0,i=this.count;e<i;e++)ni.fromBufferAttribute(this,e),ni.transformDirection(t),this.setXYZ(e,ni.x,ni.y,ni.z);return this}getComponent(t,e){let i=this.array[t*this.data.stride+this.offset+e];return this.normalized&&(i=Pi(i,this.array)),i}setComponent(t,e,i){return this.normalized&&(i=ce(i,this.array)),this.data.array[t*this.data.stride+this.offset+e]=i,this}setX(t,e){return this.normalized&&(e=ce(e,this.array)),this.data.array[t*this.data.stride+this.offset]=e,this}setY(t,e){return this.normalized&&(e=ce(e,this.array)),this.data.array[t*this.data.stride+this.offset+1]=e,this}setZ(t,e){return this.normalized&&(e=ce(e,this.array)),this.data.array[t*this.data.stride+this.offset+2]=e,this}setW(t,e){return this.normalized&&(e=ce(e,this.array)),this.data.array[t*this.data.stride+this.offset+3]=e,this}getX(t){let e=this.data.array[t*this.data.stride+this.offset];return this.normalized&&(e=Pi(e,this.array)),e}getY(t){let e=this.data.array[t*this.data.stride+this.offset+1];return this.normalized&&(e=Pi(e,this.array)),e}getZ(t){let e=this.data.array[t*this.data.stride+this.offset+2];return this.normalized&&(e=Pi(e,this.array)),e}getW(t){let e=this.data.array[t*this.data.stride+this.offset+3];return this.normalized&&(e=Pi(e,this.array)),e}setXY(t,e,i){return t=t*this.data.stride+this.offset,this.normalized&&(e=ce(e,this.array),i=ce(i,this.array)),this.data.array[t+0]=e,this.data.array[t+1]=i,this}setXYZ(t,e,i,n){return t=t*this.data.stride+this.offset,this.normalized&&(e=ce(e,this.array),i=ce(i,this.array),n=ce(n,this.array)),this.data.array[t+0]=e,this.data.array[t+1]=i,this.data.array[t+2]=n,this}setXYZW(t,e,i,n,r){return t=t*this.data.stride+this.offset,this.normalized&&(e=ce(e,this.array),i=ce(i,this.array),n=ce(n,this.array),r=ce(r,this.array)),this.data.array[t+0]=e,this.data.array[t+1]=i,this.data.array[t+2]=n,this.data.array[t+3]=r,this}clone(t){if(t===void 0){console.log("THREE.InterleavedBufferAttribute.clone(): Cloning an interleaved buffer attribute will de-interleave buffer data.");let e=[];for(let i=0;i<this.count;i++){let n=i*this.data.stride+this.offset;for(let r=0;r<this.itemSize;r++)e.push(this.data.array[n+r])}return new ne(new this.array.constructor(e),this.itemSize,this.normalized)}else return t.interleavedBuffers===void 0&&(t.interleavedBuffers={}),t.interleavedBuffers[this.data.uuid]===void 0&&(t.interleavedBuffers[this.data.uuid]=this.data.clone(t)),new s(t.interleavedBuffers[this.data.uuid],this.itemSize,this.offset,this.normalized)}toJSON(t){if(t===void 0){console.log("THREE.InterleavedBufferAttribute.toJSON(): Serializing an interleaved buffer attribute will de-interleave buffer data.");let e=[];for(let i=0;i<this.count;i++){let n=i*this.data.stride+this.offset;for(let r=0;r<this.itemSize;r++)e.push(this.data.array[n+r])}return{itemSize:this.itemSize,type:this.array.constructor.name,array:e,normalized:this.normalized}}else return t.interleavedBuffers===void 0&&(t.interleavedBuffers={}),t.interleavedBuffers[this.data.uuid]===void 0&&(t.interleavedBuffers[this.data.uuid]=this.data.toJSON(t)),{isInterleavedBufferAttribute:!0,itemSize:this.itemSize,data:this.data.uuid,offset:this.offset,normalized:this.normalized}}},Us=class extends Fi{constructor(t){super(),this.isSpriteMaterial=!0,this.type="SpriteMaterial",this.color=new _t(16777215),this.map=null,this.alphaMap=null,this.rotation=0,this.sizeAttenuation=!0,this.transparent=!0,this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.alphaMap=t.alphaMap,this.rotation=t.rotation,this.sizeAttenuation=t.sizeAttenuation,this.fog=t.fog,this}},vs,hr=new T,Ms=new T,bs=new T,ws=new nt,ur=new nt,tf=new Ut,$o=new T,dr=new T,Jo=new T,qu=new nt,Nc=new nt,Yu=new nt,Xn=class extends Ee{constructor(t=new Us){if(super(),this.isSprite=!0,this.type="Sprite",vs===void 0){vs=new ue;let e=new Float32Array([-.5,-.5,0,0,0,.5,-.5,0,1,0,.5,.5,0,1,1,-.5,.5,0,0,1]),i=new Pr(e,5);vs.setIndex([0,1,2,0,2,3]),vs.setAttribute("position",new Ds(i,3,0,!1)),vs.setAttribute("uv",new Ds(i,2,3,!1))}this.geometry=vs,this.material=t,this.center=new nt(.5,.5),this.count=1}raycast(t,e){t.camera===null&&console.error('THREE.Sprite: "Raycaster.camera" needs to be set in order to raycast against sprites.'),Ms.setFromMatrixScale(this.matrixWorld),tf.copy(t.camera.matrixWorld),this.modelViewMatrix.multiplyMatrices(t.camera.matrixWorldInverse,this.matrixWorld),bs.setFromMatrixPosition(this.modelViewMatrix),t.camera.isPerspectiveCamera&&this.material.sizeAttenuation===!1&&Ms.multiplyScalar(-bs.z);let i=this.material.rotation,n,r;i!==0&&(r=Math.cos(i),n=Math.sin(i));let o=this.center;Ko($o.set(-.5,-.5,0),bs,o,Ms,n,r),Ko(dr.set(.5,-.5,0),bs,o,Ms,n,r),Ko(Jo.set(.5,.5,0),bs,o,Ms,n,r),qu.set(0,0),Nc.set(1,0),Yu.set(1,1);let a=t.ray.intersectTriangle($o,dr,Jo,!1,hr);if(a===null&&(Ko(dr.set(-.5,.5,0),bs,o,Ms,n,r),Nc.set(0,1),a=t.ray.intersectTriangle($o,Jo,dr,!1,hr),a===null))return;let l=t.ray.origin.distanceTo(hr);l<t.near||l>t.far||e.push({distance:l,point:hr.clone(),uv:nn.getInterpolation(hr,$o,dr,Jo,qu,Nc,Yu,new nt),face:null,object:this})}copy(t,e){return super.copy(t,e),t.center!==void 0&&this.center.copy(t.center),this.material=t.material,this}};function Ko(s,t,e,i,n,r){ws.subVectors(s,e).addScalar(.5).multiply(i),n!==void 0?(ur.x=r*ws.x-n*ws.y,ur.y=n*ws.x+r*ws.y):ur.copy(ws),s.copy(t),s.x+=ur.x,s.y+=ur.y,s.applyMatrix4(tf)}var Zu=new T,$u=new ie,Ju=new ie,h0=new T,Ku=new Ut,jo=new T,Fc=new ri,ju=new Ut,kc=new Ps,Lr=class extends Et{constructor(t,e){super(t,e),this.isSkinnedMesh=!0,this.type="SkinnedMesh",this.bindMode=Wc,this.bindMatrix=new Ut,this.bindMatrixInverse=new Ut,this.boundingBox=null,this.boundingSphere=null}computeBoundingBox(){let t=this.geometry;this.boundingBox===null&&(this.boundingBox=new We),this.boundingBox.makeEmpty();let e=t.getAttribute("position");for(let i=0;i<e.count;i++)this.getVertexPosition(i,jo),this.boundingBox.expandByPoint(jo)}computeBoundingSphere(){let t=this.geometry;this.boundingSphere===null&&(this.boundingSphere=new ri),this.boundingSphere.makeEmpty();let e=t.getAttribute("position");for(let i=0;i<e.count;i++)this.getVertexPosition(i,jo),this.boundingSphere.expandByPoint(jo)}copy(t,e){return super.copy(t,e),this.bindMode=t.bindMode,this.bindMatrix.copy(t.bindMatrix),this.bindMatrixInverse.copy(t.bindMatrixInverse),this.skeleton=t.skeleton,t.boundingBox!==null&&(this.boundingBox=t.boundingBox.clone()),t.boundingSphere!==null&&(this.boundingSphere=t.boundingSphere.clone()),this}raycast(t,e){let i=this.material,n=this.matrixWorld;i!==void 0&&(this.boundingSphere===null&&this.computeBoundingSphere(),Fc.copy(this.boundingSphere),Fc.applyMatrix4(n),t.ray.intersectsSphere(Fc)!==!1&&(ju.copy(n).invert(),kc.copy(t.ray).applyMatrix4(ju),!(this.boundingBox!==null&&kc.intersectsBox(this.boundingBox)===!1)&&this._computeIntersections(t,e,kc)))}getVertexPosition(t,e){return super.getVertexPosition(t,e),this.applyBoneTransform(t,e),e}bind(t,e){this.skeleton=t,e===void 0&&(this.updateMatrixWorld(!0),this.skeleton.calculateInverses(),e=this.matrixWorld),this.bindMatrix.copy(e),this.bindMatrixInverse.copy(e).invert()}pose(){this.skeleton.pose()}normalizeSkinWeights(){let t=new ie,e=this.geometry.attributes.skinWeight;for(let i=0,n=e.count;i<n;i++){t.fromBufferAttribute(e,i);let r=1/t.manhattanLength();r!==1/0?t.multiplyScalar(r):t.set(1,0,0,0),e.setXYZW(i,t.x,t.y,t.z,t.w)}}updateMatrixWorld(t){super.updateMatrixWorld(t),this.bindMode===Wc?this.bindMatrixInverse.copy(this.matrixWorld).invert():this.bindMode===Od?this.bindMatrixInverse.copy(this.bindMatrix).invert():console.warn("THREE.SkinnedMesh: Unrecognized bindMode: "+this.bindMode)}applyBoneTransform(t,e){let i=this.skeleton,n=this.geometry;$u.fromBufferAttribute(n.attributes.skinIndex,t),Ju.fromBufferAttribute(n.attributes.skinWeight,t),Zu.copy(e).applyMatrix4(this.bindMatrix),e.set(0,0,0);for(let r=0;r<4;r++){let o=Ju.getComponent(r);if(o!==0){let a=$u.getComponent(r);Ku.multiplyMatrices(i.bones[a].matrixWorld,i.boneInverses[a]),e.addScaledVector(h0.copy(Zu).applyMatrix4(Ku),o)}}return e.applyMatrix4(this.bindMatrixInverse)}},qn=class extends Ee{constructor(){super(),this.isBone=!0,this.type="Bone"}},Dr=class extends si{constructor(t=null,e=1,i=1,n,r,o,a,l,c=li,h=li,u,f){super(null,o,a,l,c,h,n,r,u,f),this.isDataTexture=!0,this.image={data:t,width:e,height:i},this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1}},Qu=new Ut,u0=new Ut,Ur=class s{constructor(t=[],e=[]){this.uuid=Di(),this.bones=t.slice(0),this.boneInverses=e,this.boneMatrices=null,this.boneTexture=null,this.init()}init(){let t=this.bones,e=this.boneInverses;if(this.boneMatrices=new Float32Array(t.length*16),e.length===0)this.calculateInverses();else if(t.length!==e.length){console.warn("THREE.Skeleton: Number of inverse bone matrices does not match amount of bones."),this.boneInverses=[];for(let i=0,n=this.bones.length;i<n;i++)this.boneInverses.push(new Ut)}}calculateInverses(){this.boneInverses.length=0;for(let t=0,e=this.bones.length;t<e;t++){let i=new Ut;this.bones[t]&&i.copy(this.bones[t].matrixWorld).invert(),this.boneInverses.push(i)}}pose(){for(let t=0,e=this.bones.length;t<e;t++){let i=this.bones[t];i&&i.matrixWorld.copy(this.boneInverses[t]).invert()}for(let t=0,e=this.bones.length;t<e;t++){let i=this.bones[t];i&&(i.parent&&i.parent.isBone?(i.matrix.copy(i.parent.matrixWorld).invert(),i.matrix.multiply(i.matrixWorld)):i.matrix.copy(i.matrixWorld),i.matrix.decompose(i.position,i.quaternion,i.scale))}}update(){let t=this.bones,e=this.boneInverses,i=this.boneMatrices,n=this.boneTexture;for(let r=0,o=t.length;r<o;r++){let a=t[r]?t[r].matrixWorld:u0;Qu.multiplyMatrices(a,e[r]),Qu.toArray(i,r*16)}n!==null&&(n.needsUpdate=!0)}clone(){return new s(this.bones,this.boneInverses)}computeBoneTexture(){let t=Math.sqrt(this.bones.length*4);t=Math.ceil(t/4)*4,t=Math.max(t,4);let e=new Float32Array(t*t*4);e.set(this.boneMatrices);let i=new Dr(e,t,t,gi,Si);return i.needsUpdate=!0,this.boneMatrices=e,this.boneTexture=i,this}getBoneByName(t){for(let e=0,i=this.bones.length;e<i;e++){let n=this.bones[e];if(n.name===t)return n}}dispose(){this.boneTexture!==null&&(this.boneTexture.dispose(),this.boneTexture=null)}fromJSON(t,e){this.uuid=t.uuid;for(let i=0,n=t.bones.length;i<n;i++){let r=t.bones[i],o=e[r];o===void 0&&(console.warn("THREE.Skeleton: No bone found with UUID:",r),o=new qn),this.bones.push(o),this.boneInverses.push(new Ut().fromArray(t.boneInverses[i]))}return this.init(),this}toJSON(){let t={metadata:{version:4.7,type:"Skeleton",generator:"Skeleton.toJSON"},bones:[],boneInverses:[]};t.uuid=this.uuid;let e=this.bones,i=this.boneInverses;for(let n=0,r=e.length;n<r;n++){let o=e[n];t.bones.push(o.uuid);let a=i[n];t.boneInverses.push(a.toArray())}return t}},Ns=class extends ne{constructor(t,e,i,n=1){super(t,e,i),this.isInstancedBufferAttribute=!0,this.meshPerAttribute=n}copy(t){return super.copy(t),this.meshPerAttribute=t.meshPerAttribute,this}toJSON(){let t=super.toJSON();return t.meshPerAttribute=this.meshPerAttribute,t.isInstancedBufferAttribute=!0,t}},Ss=new Ut,td=new Ut,Qo=[],ed=new We,d0=new Ut,fr=new Et,pr=new ri,Yn=class extends Et{constructor(t,e,i){super(t,e),this.isInstancedMesh=!0,this.instanceMatrix=new Ns(new Float32Array(i*16),16),this.instanceColor=null,this.morphTexture=null,this.count=i,this.boundingBox=null,this.boundingSphere=null;for(let n=0;n<i;n++)this.setMatrixAt(n,d0)}computeBoundingBox(){let t=this.geometry,e=this.count;this.boundingBox===null&&(this.boundingBox=new We),t.boundingBox===null&&t.computeBoundingBox(),this.boundingBox.makeEmpty();for(let i=0;i<e;i++)this.getMatrixAt(i,Ss),ed.copy(t.boundingBox).applyMatrix4(Ss),this.boundingBox.union(ed)}computeBoundingSphere(){let t=this.geometry,e=this.count;this.boundingSphere===null&&(this.boundingSphere=new ri),t.boundingSphere===null&&t.computeBoundingSphere(),this.boundingSphere.makeEmpty();for(let i=0;i<e;i++)this.getMatrixAt(i,Ss),pr.copy(t.boundingSphere).applyMatrix4(Ss),this.boundingSphere.union(pr)}copy(t,e){return super.copy(t,e),this.instanceMatrix.copy(t.instanceMatrix),t.morphTexture!==null&&(this.morphTexture=t.morphTexture.clone()),t.instanceColor!==null&&(this.instanceColor=t.instanceColor.clone()),this.count=t.count,t.boundingBox!==null&&(this.boundingBox=t.boundingBox.clone()),t.boundingSphere!==null&&(this.boundingSphere=t.boundingSphere.clone()),this}getColorAt(t,e){e.fromArray(this.instanceColor.array,t*3)}getMatrixAt(t,e){e.fromArray(this.instanceMatrix.array,t*16)}getMorphAt(t,e){let i=e.morphTargetInfluences,n=this.morphTexture.source.data.data,r=i.length+1,o=t*r+1;for(let a=0;a<i.length;a++)i[a]=n[o+a]}raycast(t,e){let i=this.matrixWorld,n=this.count;if(fr.geometry=this.geometry,fr.material=this.material,fr.material!==void 0&&(this.boundingSphere===null&&this.computeBoundingSphere(),pr.copy(this.boundingSphere),pr.applyMatrix4(i),t.ray.intersectsSphere(pr)!==!1))for(let r=0;r<n;r++){this.getMatrixAt(r,Ss),td.multiplyMatrices(i,Ss),fr.matrixWorld=td,fr.raycast(t,Qo);for(let o=0,a=Qo.length;o<a;o++){let l=Qo[o];l.instanceId=r,l.object=this,e.push(l)}Qo.length=0}}setColorAt(t,e){this.instanceColor===null&&(this.instanceColor=new Ns(new Float32Array(this.instanceMatrix.count*3).fill(1),3)),e.toArray(this.instanceColor.array,t*3)}setMatrixAt(t,e){e.toArray(this.instanceMatrix.array,t*16)}setMorphAt(t,e){let i=e.morphTargetInfluences,n=i.length+1;this.morphTexture===null&&(this.morphTexture=new Dr(new Float32Array(n*this.count),n,this.count,tl,Si));let r=this.morphTexture.source.data.data,o=0;for(let c=0;c<i.length;c++)o+=i[c];let a=this.geometry.morphTargetsRelative?1:1-o,l=n*t;r[l]=a,r.set(i,l+1)}updateMorphTargets(){}dispose(){this.dispatchEvent({type:"dispose"}),this.morphTexture!==null&&(this.morphTexture.dispose(),this.morphTexture=null)}},Bc=new T,f0=new T,p0=new Xt,Hi=class{constructor(t=new T(1,0,0),e=0){this.isPlane=!0,this.normal=t,this.constant=e}set(t,e){return this.normal.copy(t),this.constant=e,this}setComponents(t,e,i,n){return this.normal.set(t,e,i),this.constant=n,this}setFromNormalAndCoplanarPoint(t,e){return this.normal.copy(t),this.constant=-e.dot(this.normal),this}setFromCoplanarPoints(t,e,i){let n=Bc.subVectors(i,e).cross(f0.subVectors(t,e)).normalize();return this.setFromNormalAndCoplanarPoint(n,t),this}copy(t){return this.normal.copy(t.normal),this.constant=t.constant,this}normalize(){let t=1/this.normal.length();return this.normal.multiplyScalar(t),this.constant*=t,this}negate(){return this.constant*=-1,this.normal.negate(),this}distanceToPoint(t){return this.normal.dot(t)+this.constant}distanceToSphere(t){return this.distanceToPoint(t.center)-t.radius}projectPoint(t,e){return e.copy(t).addScaledVector(this.normal,-this.distanceToPoint(t))}intersectLine(t,e){let i=t.delta(Bc),n=this.normal.dot(i);if(n===0)return this.distanceToPoint(t.start)===0?e.copy(t.start):null;let r=-(t.start.dot(this.normal)+this.constant)/n;return r<0||r>1?null:e.copy(t.start).addScaledVector(i,r)}intersectsLine(t){let e=this.distanceToPoint(t.start),i=this.distanceToPoint(t.end);return e<0&&i>0||i<0&&e>0}intersectsBox(t){return t.intersectsPlane(this)}intersectsSphere(t){return t.intersectsPlane(this)}coplanarPoint(t){return t.copy(this.normal).multiplyScalar(-this.constant)}applyMatrix4(t,e){let i=e||p0.getNormalMatrix(t),n=this.coplanarPoint(Bc).applyMatrix4(t),r=this.normal.applyMatrix3(i).normalize();return this.constant=-n.dot(r),this}translate(t){return this.constant-=t.dot(this.normal),this}equals(t){return t.normal.equals(this.normal)&&t.constant===this.constant}clone(){return new this.constructor().copy(this)}},zn=new ri,m0=new nt(.5,.5),ta=new T,Sn=class{constructor(t=new Hi,e=new Hi,i=new Hi,n=new Hi,r=new Hi,o=new Hi){this.planes=[t,e,i,n,r,o]}set(t,e,i,n,r,o){let a=this.planes;return a[0].copy(t),a[1].copy(e),a[2].copy(i),a[3].copy(n),a[4].copy(r),a[5].copy(o),this}copy(t){let e=this.planes;for(let i=0;i<6;i++)e[i].copy(t.planes[i]);return this}setFromProjectionMatrix(t,e=Li,i=!1){let n=this.planes,r=t.elements,o=r[0],a=r[1],l=r[2],c=r[3],h=r[4],u=r[5],f=r[6],d=r[7],g=r[8],x=r[9],m=r[10],p=r[11],M=r[12],y=r[13],_=r[14],b=r[15];if(n[0].setComponents(c-o,d-h,p-g,b-M).normalize(),n[1].setComponents(c+o,d+h,p+g,b+M).normalize(),n[2].setComponents(c+a,d+u,p+x,b+y).normalize(),n[3].setComponents(c-a,d-u,p-x,b-y).normalize(),i)n[4].setComponents(l,f,m,_).normalize(),n[5].setComponents(c-l,d-f,p-m,b-_).normalize();else if(n[4].setComponents(c-l,d-f,p-m,b-_).normalize(),e===Li)n[5].setComponents(c+l,d+f,p+m,b+_).normalize();else if(e===wr)n[5].setComponents(l,f,m,_).normalize();else throw new Error("THREE.Frustum.setFromProjectionMatrix(): Invalid coordinate system: "+e);return this}intersectsObject(t){if(t.boundingSphere!==void 0)t.boundingSphere===null&&t.computeBoundingSphere(),zn.copy(t.boundingSphere).applyMatrix4(t.matrixWorld);else{let e=t.geometry;e.boundingSphere===null&&e.computeBoundingSphere(),zn.copy(e.boundingSphere).applyMatrix4(t.matrixWorld)}return this.intersectsSphere(zn)}intersectsSprite(t){zn.center.set(0,0,0);let e=m0.distanceTo(t.center);return zn.radius=.7071067811865476+e,zn.applyMatrix4(t.matrixWorld),this.intersectsSphere(zn)}intersectsSphere(t){let e=this.planes,i=t.center,n=-t.radius;for(let r=0;r<6;r++)if(e[r].distanceToPoint(i)<n)return!1;return!0}intersectsBox(t){let e=this.planes;for(let i=0;i<6;i++){let n=e[i];if(ta.x=n.normal.x>0?t.max.x:t.min.x,ta.y=n.normal.y>0?t.max.y:t.min.y,ta.z=n.normal.z>0?t.max.z:t.min.z,n.distanceToPoint(ta)<0)return!1}return!0}containsPoint(t){let e=this.planes;for(let i=0;i<6;i++)if(e[i].distanceToPoint(t)<0)return!1;return!0}clone(){return new this.constructor().copy(this)}};var _a=class extends Fi{constructor(t){super(),this.isPointsMaterial=!0,this.type="PointsMaterial",this.color=new _t(16777215),this.map=null,this.alphaMap=null,this.size=1,this.sizeAttenuation=!0,this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.alphaMap=t.alphaMap,this.size=t.size,this.sizeAttenuation=t.sizeAttenuation,this.fog=t.fog,this}},id=new Ut,$c=new Ps,ea=new ri,ia=new T,Nr=class extends Ee{constructor(t=new ue,e=new _a){super(),this.isPoints=!0,this.type="Points",this.geometry=t,this.material=e,this.morphTargetDictionary=void 0,this.morphTargetInfluences=void 0,this.updateMorphTargets()}copy(t,e){return super.copy(t,e),this.material=Array.isArray(t.material)?t.material.slice():t.material,this.geometry=t.geometry,this}raycast(t,e){let i=this.geometry,n=this.matrixWorld,r=t.params.Points.threshold,o=i.drawRange;if(i.boundingSphere===null&&i.computeBoundingSphere(),ea.copy(i.boundingSphere),ea.applyMatrix4(n),ea.radius+=r,t.ray.intersectsSphere(ea)===!1)return;id.copy(n).invert(),$c.copy(t.ray).applyMatrix4(id);let a=r/((this.scale.x+this.scale.y+this.scale.z)/3),l=a*a,c=i.index,u=i.attributes.position;if(c!==null){let f=Math.max(0,o.start),d=Math.min(c.count,o.start+o.count);for(let g=f,x=d;g<x;g++){let m=c.getX(g);ia.fromBufferAttribute(u,m),nd(ia,m,l,n,t,e,this)}}else{let f=Math.max(0,o.start),d=Math.min(u.count,o.start+o.count);for(let g=f,x=d;g<x;g++)ia.fromBufferAttribute(u,g),nd(ia,g,l,n,t,e,this)}}updateMorphTargets(){let e=this.geometry.morphAttributes,i=Object.keys(e);if(i.length>0){let n=e[i[0]];if(n!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let r=0,o=n.length;r<o;r++){let a=n[r].name||String(r);this.morphTargetInfluences.push(0),this.morphTargetDictionary[a]=r}}}}};function nd(s,t,e,i,n,r,o){let a=$c.distanceSqToPoint(s);if(a<e){let l=new T;$c.closestPointToPoint(s,l),l.applyMatrix4(i);let c=n.ray.origin.distanceTo(l);if(c<n.near||c>n.far)return;r.push({distance:c,distanceToRay:Math.sqrt(a),point:l,index:t,face:null,faceIndex:null,barycoord:null,object:o})}}var Fr=class extends si{constructor(t,e,i,n,r,o,a,l,c){super(t,e,i,n,r,o,a,l,c),this.isCanvasTexture=!0,this.needsUpdate=!0}},kr=class extends si{constructor(t,e,i=Cn,n,r,o,a=li,l=li,c,h=As,u=1){if(h!==As&&h!==Gs)throw new Error("DepthTexture format must be either THREE.DepthFormat or THREE.DepthStencilFormat");let f={width:t,height:e,depth:u};super(f,n,r,o,a,l,h,i,c),this.isDepthTexture=!0,this.flipY=!1,this.generateMipmaps=!1,this.compareFunction=null}copy(t){return super.copy(t),this.source=new Is(Object.assign({},t.image)),this.compareFunction=t.compareFunction,this}toJSON(t){let e=super.toJSON(t);return this.compareFunction!==null&&(e.compareFunction=this.compareFunction),e}},Br=class extends si{constructor(t=null){super(),this.sourceTexture=t,this.isExternalTexture=!0}copy(t){return super.copy(t),this.sourceTexture=t.sourceTexture,this}},Or=class s extends ue{constructor(t=1,e=1,i=4,n=8,r=1){super(),this.type="CapsuleGeometry",this.parameters={radius:t,height:e,capSegments:i,radialSegments:n,heightSegments:r},e=Math.max(0,e),i=Math.max(1,Math.floor(i)),n=Math.max(3,Math.floor(n)),r=Math.max(1,Math.floor(r));let o=[],a=[],l=[],c=[],h=e/2,u=Math.PI/2*t,f=e,d=2*u+f,g=i*2+r,x=n+1,m=new T,p=new T;for(let M=0;M<=g;M++){let y=0,_=0,b=0,E=0;if(M<=i){let w=M/i,v=w*Math.PI/2;_=-h-t*Math.cos(v),b=t*Math.sin(v),E=-t*Math.cos(v),y=w*u}else if(M<=i+r){let w=(M-i)/r;_=-h+w*e,b=t,E=0,y=u+w*f}else{let w=(M-i-r)/i,v=w*Math.PI/2;_=h+t*Math.sin(v),b=t*Math.cos(v),E=t*Math.sin(v),y=u+f+w*u}let P=Math.max(0,Math.min(1,y/d)),L=0;M===0?L=.5/n:M===g&&(L=-.5/n);for(let w=0;w<=n;w++){let v=w/n,C=v*Math.PI*2,U=Math.sin(C),O=Math.cos(C);p.x=-b*O,p.y=_,p.z=b*U,a.push(p.x,p.y,p.z),m.set(-b*O,E,b*U),m.normalize(),l.push(m.x,m.y,m.z),c.push(v+L,P)}if(M>0){let w=(M-1)*x;for(let v=0;v<n;v++){let C=w+v,U=w+v+1,O=M*x+v,z=M*x+v+1;o.push(C,U,O),o.push(U,z,O)}}}this.setIndex(o),this.setAttribute("position",new Ht(a,3)),this.setAttribute("normal",new Ht(l,3)),this.setAttribute("uv",new Ht(c,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new s(t.radius,t.height,t.capSegments,t.radialSegments,t.heightSegments)}};var Wi=class s extends ue{constructor(t=1,e=1,i=1,n=32,r=1,o=!1,a=0,l=Math.PI*2){super(),this.type="CylinderGeometry",this.parameters={radiusTop:t,radiusBottom:e,height:i,radialSegments:n,heightSegments:r,openEnded:o,thetaStart:a,thetaLength:l};let c=this;n=Math.floor(n),r=Math.floor(r);let h=[],u=[],f=[],d=[],g=0,x=[],m=i/2,p=0;M(),o===!1&&(t>0&&y(!0),e>0&&y(!1)),this.setIndex(h),this.setAttribute("position",new Ht(u,3)),this.setAttribute("normal",new Ht(f,3)),this.setAttribute("uv",new Ht(d,2));function M(){let _=new T,b=new T,E=0,P=(e-t)/i;for(let L=0;L<=r;L++){let w=[],v=L/r,C=v*(e-t)+t;for(let U=0;U<=n;U++){let O=U/n,z=O*l+a,q=Math.sin(z),H=Math.cos(z);b.x=C*q,b.y=-v*i+m,b.z=C*H,u.push(b.x,b.y,b.z),_.set(q,P,H).normalize(),f.push(_.x,_.y,_.z),d.push(O,1-v),w.push(g++)}x.push(w)}for(let L=0;L<n;L++)for(let w=0;w<r;w++){let v=x[w][L],C=x[w+1][L],U=x[w+1][L+1],O=x[w][L+1];(t>0||w!==0)&&(h.push(v,C,O),E+=3),(e>0||w!==r-1)&&(h.push(C,U,O),E+=3)}c.addGroup(p,E,0),p+=E}function y(_){let b=g,E=new nt,P=new T,L=0,w=_===!0?t:e,v=_===!0?1:-1;for(let U=1;U<=n;U++)u.push(0,m*v,0),f.push(0,v,0),d.push(.5,.5),g++;let C=g;for(let U=0;U<=n;U++){let z=U/n*l+a,q=Math.cos(z),H=Math.sin(z);P.x=w*H,P.y=m*v,P.z=w*q,u.push(P.x,P.y,P.z),f.push(0,v,0),E.x=q*.5+.5,E.y=H*.5*v+.5,d.push(E.x,E.y),g++}for(let U=0;U<n;U++){let O=b+U,z=C+U;_===!0?h.push(z,z+1,O):h.push(z+1,z,O),L+=3}c.addGroup(p,L,_===!0?1:2),p+=L}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new s(t.radiusTop,t.radiusBottom,t.height,t.radialSegments,t.heightSegments,t.openEnded,t.thetaStart,t.thetaLength)}},zr=class s extends Wi{constructor(t=1,e=1,i=32,n=1,r=!1,o=0,a=Math.PI*2){super(0,t,e,i,n,r,o,a),this.type="ConeGeometry",this.parameters={radius:t,height:e,radialSegments:i,heightSegments:n,openEnded:r,thetaStart:o,thetaLength:a}}static fromJSON(t){return new s(t.radius,t.height,t.radialSegments,t.heightSegments,t.openEnded,t.thetaStart,t.thetaLength)}},Hr=class s extends ue{constructor(t=[],e=[],i=1,n=0){super(),this.type="PolyhedronGeometry",this.parameters={vertices:t,indices:e,radius:i,detail:n};let r=[],o=[];a(n),c(i),h(),this.setAttribute("position",new Ht(r,3)),this.setAttribute("normal",new Ht(r.slice(),3)),this.setAttribute("uv",new Ht(o,2)),n===0?this.computeVertexNormals():this.normalizeNormals();function a(M){let y=new T,_=new T,b=new T;for(let E=0;E<e.length;E+=3)d(e[E+0],y),d(e[E+1],_),d(e[E+2],b),l(y,_,b,M)}function l(M,y,_,b){let E=b+1,P=[];for(let L=0;L<=E;L++){P[L]=[];let w=M.clone().lerp(_,L/E),v=y.clone().lerp(_,L/E),C=E-L;for(let U=0;U<=C;U++)U===0&&L===E?P[L][U]=w:P[L][U]=w.clone().lerp(v,U/C)}for(let L=0;L<E;L++)for(let w=0;w<2*(E-L)-1;w++){let v=Math.floor(w/2);w%2===0?(f(P[L][v+1]),f(P[L+1][v]),f(P[L][v])):(f(P[L][v+1]),f(P[L+1][v+1]),f(P[L+1][v]))}}function c(M){let y=new T;for(let _=0;_<r.length;_+=3)y.x=r[_+0],y.y=r[_+1],y.z=r[_+2],y.normalize().multiplyScalar(M),r[_+0]=y.x,r[_+1]=y.y,r[_+2]=y.z}function h(){let M=new T;for(let y=0;y<r.length;y+=3){M.x=r[y+0],M.y=r[y+1],M.z=r[y+2];let _=m(M)/2/Math.PI+.5,b=p(M)/Math.PI+.5;o.push(_,1-b)}g(),u()}function u(){for(let M=0;M<o.length;M+=6){let y=o[M+0],_=o[M+2],b=o[M+4],E=Math.max(y,_,b),P=Math.min(y,_,b);E>.9&&P<.1&&(y<.2&&(o[M+0]+=1),_<.2&&(o[M+2]+=1),b<.2&&(o[M+4]+=1))}}function f(M){r.push(M.x,M.y,M.z)}function d(M,y){let _=M*3;y.x=t[_+0],y.y=t[_+1],y.z=t[_+2]}function g(){let M=new T,y=new T,_=new T,b=new T,E=new nt,P=new nt,L=new nt;for(let w=0,v=0;w<r.length;w+=9,v+=6){M.set(r[w+0],r[w+1],r[w+2]),y.set(r[w+3],r[w+4],r[w+5]),_.set(r[w+6],r[w+7],r[w+8]),E.set(o[v+0],o[v+1]),P.set(o[v+2],o[v+3]),L.set(o[v+4],o[v+5]),b.copy(M).add(y).add(_).divideScalar(3);let C=m(b);x(E,v+0,M,C),x(P,v+2,y,C),x(L,v+4,_,C)}}function x(M,y,_,b){b<0&&M.x===1&&(o[y]=M.x-1),_.x===0&&_.z===0&&(o[y]=b/2/Math.PI+.5)}function m(M){return Math.atan2(M.z,-M.x)}function p(M){return Math.atan2(-M.y,Math.sqrt(M.x*M.x+M.z*M.z))}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new s(t.vertices,t.indices,t.radius,t.details)}},Vr=class s extends Hr{constructor(t=1,e=0){let i=(1+Math.sqrt(5))/2,n=1/i,r=[-1,-1,-1,-1,-1,1,-1,1,-1,-1,1,1,1,-1,-1,1,-1,1,1,1,-1,1,1,1,0,-n,-i,0,-n,i,0,n,-i,0,n,i,-n,-i,0,-n,i,0,n,-i,0,n,i,0,-i,0,-n,i,0,-n,-i,0,n,i,0,n],o=[3,11,7,3,7,15,3,15,13,7,19,17,7,17,6,7,6,15,17,4,8,17,8,10,17,10,6,8,0,16,8,16,2,8,2,10,0,12,1,0,1,18,0,18,16,6,10,2,6,2,13,6,13,15,2,16,18,2,18,3,2,3,13,18,1,9,18,9,11,18,11,3,4,14,12,4,12,0,4,0,8,11,9,5,11,5,19,11,19,7,19,5,14,19,14,4,19,4,17,1,12,14,1,14,5,1,5,9];super(r,o,t,e),this.type="DodecahedronGeometry",this.parameters={radius:t,detail:e}}static fromJSON(t){return new s(t.radius,t.detail)}};var pi=class{constructor(){this.type="Curve",this.arcLengthDivisions=200,this.needsUpdate=!1,this.cacheArcLengths=null}getPoint(){console.warn("THREE.Curve: .getPoint() not implemented.")}getPointAt(t,e){let i=this.getUtoTmapping(t);return this.getPoint(i,e)}getPoints(t=5){let e=[];for(let i=0;i<=t;i++)e.push(this.getPoint(i/t));return e}getSpacedPoints(t=5){let e=[];for(let i=0;i<=t;i++)e.push(this.getPointAt(i/t));return e}getLength(){let t=this.getLengths();return t[t.length-1]}getLengths(t=this.arcLengthDivisions){if(this.cacheArcLengths&&this.cacheArcLengths.length===t+1&&!this.needsUpdate)return this.cacheArcLengths;this.needsUpdate=!1;let e=[],i,n=this.getPoint(0),r=0;e.push(0);for(let o=1;o<=t;o++)i=this.getPoint(o/t),r+=i.distanceTo(n),e.push(r),n=i;return this.cacheArcLengths=e,e}updateArcLengths(){this.needsUpdate=!0,this.getLengths()}getUtoTmapping(t,e=null){let i=this.getLengths(),n=0,r=i.length,o;e?o=e:o=t*i[r-1];let a=0,l=r-1,c;for(;a<=l;)if(n=Math.floor(a+(l-a)/2),c=i[n]-o,c<0)a=n+1;else if(c>0)l=n-1;else{l=n;break}if(n=l,i[n]===o)return n/(r-1);let h=i[n],f=i[n+1]-h,d=(o-h)/f;return(n+d)/(r-1)}getTangent(t,e){let n=t-1e-4,r=t+1e-4;n<0&&(n=0),r>1&&(r=1);let o=this.getPoint(n),a=this.getPoint(r),l=e||(o.isVector2?new nt:new T);return l.copy(a).sub(o).normalize(),l}getTangentAt(t,e){let i=this.getUtoTmapping(t);return this.getTangent(i,e)}computeFrenetFrames(t,e=!1){let i=new T,n=[],r=[],o=[],a=new T,l=new Ut;for(let d=0;d<=t;d++){let g=d/t;n[d]=this.getTangentAt(g,new T)}r[0]=new T,o[0]=new T;let c=Number.MAX_VALUE,h=Math.abs(n[0].x),u=Math.abs(n[0].y),f=Math.abs(n[0].z);h<=c&&(c=h,i.set(1,0,0)),u<=c&&(c=u,i.set(0,1,0)),f<=c&&i.set(0,0,1),a.crossVectors(n[0],i).normalize(),r[0].crossVectors(n[0],a),o[0].crossVectors(n[0],r[0]);for(let d=1;d<=t;d++){if(r[d]=r[d-1].clone(),o[d]=o[d-1].clone(),a.crossVectors(n[d-1],n[d]),a.length()>Number.EPSILON){a.normalize();let g=Math.acos(Zt(n[d-1].dot(n[d]),-1,1));r[d].applyMatrix4(l.makeRotationAxis(a,g))}o[d].crossVectors(n[d],r[d])}if(e===!0){let d=Math.acos(Zt(r[0].dot(r[t]),-1,1));d/=t,n[0].dot(a.crossVectors(r[0],r[t]))>0&&(d=-d);for(let g=1;g<=t;g++)r[g].applyMatrix4(l.makeRotationAxis(n[g],d*g)),o[g].crossVectors(n[g],r[g])}return{tangents:n,normals:r,binormals:o}}clone(){return new this.constructor().copy(this)}copy(t){return this.arcLengthDivisions=t.arcLengthDivisions,this}toJSON(){let t={metadata:{version:4.7,type:"Curve",generator:"Curve.toJSON"}};return t.arcLengthDivisions=this.arcLengthDivisions,t.type=this.type,t}fromJSON(t){return this.arcLengthDivisions=t.arcLengthDivisions,this}},Fs=class extends pi{constructor(t=0,e=0,i=1,n=1,r=0,o=Math.PI*2,a=!1,l=0){super(),this.isEllipseCurve=!0,this.type="EllipseCurve",this.aX=t,this.aY=e,this.xRadius=i,this.yRadius=n,this.aStartAngle=r,this.aEndAngle=o,this.aClockwise=a,this.aRotation=l}getPoint(t,e=new nt){let i=e,n=Math.PI*2,r=this.aEndAngle-this.aStartAngle,o=Math.abs(r)<Number.EPSILON;for(;r<0;)r+=n;for(;r>n;)r-=n;r<Number.EPSILON&&(o?r=0:r=n),this.aClockwise===!0&&!o&&(r===n?r=-n:r=r-n);let a=this.aStartAngle+t*r,l=this.aX+this.xRadius*Math.cos(a),c=this.aY+this.yRadius*Math.sin(a);if(this.aRotation!==0){let h=Math.cos(this.aRotation),u=Math.sin(this.aRotation),f=l-this.aX,d=c-this.aY;l=f*h-d*u+this.aX,c=f*u+d*h+this.aY}return i.set(l,c)}copy(t){return super.copy(t),this.aX=t.aX,this.aY=t.aY,this.xRadius=t.xRadius,this.yRadius=t.yRadius,this.aStartAngle=t.aStartAngle,this.aEndAngle=t.aEndAngle,this.aClockwise=t.aClockwise,this.aRotation=t.aRotation,this}toJSON(){let t=super.toJSON();return t.aX=this.aX,t.aY=this.aY,t.xRadius=this.xRadius,t.yRadius=this.yRadius,t.aStartAngle=this.aStartAngle,t.aEndAngle=this.aEndAngle,t.aClockwise=this.aClockwise,t.aRotation=this.aRotation,t}fromJSON(t){return super.fromJSON(t),this.aX=t.aX,this.aY=t.aY,this.xRadius=t.xRadius,this.yRadius=t.yRadius,this.aStartAngle=t.aStartAngle,this.aEndAngle=t.aEndAngle,this.aClockwise=t.aClockwise,this.aRotation=t.aRotation,this}},ya=class extends Fs{constructor(t,e,i,n,r,o){super(t,e,i,i,n,r,o),this.isArcCurve=!0,this.type="ArcCurve"}};function vh(){let s=0,t=0,e=0,i=0;function n(r,o,a,l){s=r,t=a,e=-3*r+3*o-2*a-l,i=2*r-2*o+a+l}return{initCatmullRom:function(r,o,a,l,c){n(o,a,c*(a-r),c*(l-o))},initNonuniformCatmullRom:function(r,o,a,l,c,h,u){let f=(o-r)/c-(a-r)/(c+h)+(a-o)/h,d=(a-o)/h-(l-o)/(h+u)+(l-a)/u;f*=h,d*=h,n(o,a,f,d)},calc:function(r){let o=r*r,a=o*r;return s+t*r+e*o+i*a}}}var na=new T,Oc=new vh,zc=new vh,Hc=new vh,va=class extends pi{constructor(t=[],e=!1,i="centripetal",n=.5){super(),this.isCatmullRomCurve3=!0,this.type="CatmullRomCurve3",this.points=t,this.closed=e,this.curveType=i,this.tension=n}getPoint(t,e=new T){let i=e,n=this.points,r=n.length,o=(r-(this.closed?0:1))*t,a=Math.floor(o),l=o-a;this.closed?a+=a>0?0:(Math.floor(Math.abs(a)/r)+1)*r:l===0&&a===r-1&&(a=r-2,l=1);let c,h;this.closed||a>0?c=n[(a-1)%r]:(na.subVectors(n[0],n[1]).add(n[0]),c=na);let u=n[a%r],f=n[(a+1)%r];if(this.closed||a+2<r?h=n[(a+2)%r]:(na.subVectors(n[r-1],n[r-2]).add(n[r-1]),h=na),this.curveType==="centripetal"||this.curveType==="chordal"){let d=this.curveType==="chordal"?.5:.25,g=Math.pow(c.distanceToSquared(u),d),x=Math.pow(u.distanceToSquared(f),d),m=Math.pow(f.distanceToSquared(h),d);x<1e-4&&(x=1),g<1e-4&&(g=x),m<1e-4&&(m=x),Oc.initNonuniformCatmullRom(c.x,u.x,f.x,h.x,g,x,m),zc.initNonuniformCatmullRom(c.y,u.y,f.y,h.y,g,x,m),Hc.initNonuniformCatmullRom(c.z,u.z,f.z,h.z,g,x,m)}else this.curveType==="catmullrom"&&(Oc.initCatmullRom(c.x,u.x,f.x,h.x,this.tension),zc.initCatmullRom(c.y,u.y,f.y,h.y,this.tension),Hc.initCatmullRom(c.z,u.z,f.z,h.z,this.tension));return i.set(Oc.calc(l),zc.calc(l),Hc.calc(l)),i}copy(t){super.copy(t),this.points=[];for(let e=0,i=t.points.length;e<i;e++){let n=t.points[e];this.points.push(n.clone())}return this.closed=t.closed,this.curveType=t.curveType,this.tension=t.tension,this}toJSON(){let t=super.toJSON();t.points=[];for(let e=0,i=this.points.length;e<i;e++){let n=this.points[e];t.points.push(n.toArray())}return t.closed=this.closed,t.curveType=this.curveType,t.tension=this.tension,t}fromJSON(t){super.fromJSON(t),this.points=[];for(let e=0,i=t.points.length;e<i;e++){let n=t.points[e];this.points.push(new T().fromArray(n))}return this.closed=t.closed,this.curveType=t.curveType,this.tension=t.tension,this}};function sd(s,t,e,i,n){let r=(i-t)*.5,o=(n-e)*.5,a=s*s,l=s*a;return(2*e-2*i+r+o)*l+(-3*e+3*i-2*r-o)*a+r*s+e}function g0(s,t){let e=1-s;return e*e*t}function x0(s,t){return 2*(1-s)*s*t}function _0(s,t){return s*s*t}function yr(s,t,e,i){return g0(s,t)+x0(s,e)+_0(s,i)}function y0(s,t){let e=1-s;return e*e*e*t}function v0(s,t){let e=1-s;return 3*e*e*s*t}function M0(s,t){return 3*(1-s)*s*s*t}function b0(s,t){return s*s*s*t}function vr(s,t,e,i,n){return y0(s,t)+v0(s,e)+M0(s,i)+b0(s,n)}var Gr=class extends pi{constructor(t=new nt,e=new nt,i=new nt,n=new nt){super(),this.isCubicBezierCurve=!0,this.type="CubicBezierCurve",this.v0=t,this.v1=e,this.v2=i,this.v3=n}getPoint(t,e=new nt){let i=e,n=this.v0,r=this.v1,o=this.v2,a=this.v3;return i.set(vr(t,n.x,r.x,o.x,a.x),vr(t,n.y,r.y,o.y,a.y)),i}copy(t){return super.copy(t),this.v0.copy(t.v0),this.v1.copy(t.v1),this.v2.copy(t.v2),this.v3.copy(t.v3),this}toJSON(){let t=super.toJSON();return t.v0=this.v0.toArray(),t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t.v3=this.v3.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v0.fromArray(t.v0),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this.v3.fromArray(t.v3),this}},Ma=class extends pi{constructor(t=new T,e=new T,i=new T,n=new T){super(),this.isCubicBezierCurve3=!0,this.type="CubicBezierCurve3",this.v0=t,this.v1=e,this.v2=i,this.v3=n}getPoint(t,e=new T){let i=e,n=this.v0,r=this.v1,o=this.v2,a=this.v3;return i.set(vr(t,n.x,r.x,o.x,a.x),vr(t,n.y,r.y,o.y,a.y),vr(t,n.z,r.z,o.z,a.z)),i}copy(t){return super.copy(t),this.v0.copy(t.v0),this.v1.copy(t.v1),this.v2.copy(t.v2),this.v3.copy(t.v3),this}toJSON(){let t=super.toJSON();return t.v0=this.v0.toArray(),t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t.v3=this.v3.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v0.fromArray(t.v0),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this.v3.fromArray(t.v3),this}},Wr=class extends pi{constructor(t=new nt,e=new nt){super(),this.isLineCurve=!0,this.type="LineCurve",this.v1=t,this.v2=e}getPoint(t,e=new nt){let i=e;return t===1?i.copy(this.v2):(i.copy(this.v2).sub(this.v1),i.multiplyScalar(t).add(this.v1)),i}getPointAt(t,e){return this.getPoint(t,e)}getTangent(t,e=new nt){return e.subVectors(this.v2,this.v1).normalize()}getTangentAt(t,e){return this.getTangent(t,e)}copy(t){return super.copy(t),this.v1.copy(t.v1),this.v2.copy(t.v2),this}toJSON(){let t=super.toJSON();return t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this}},ba=class extends pi{constructor(t=new T,e=new T){super(),this.isLineCurve3=!0,this.type="LineCurve3",this.v1=t,this.v2=e}getPoint(t,e=new T){let i=e;return t===1?i.copy(this.v2):(i.copy(this.v2).sub(this.v1),i.multiplyScalar(t).add(this.v1)),i}getPointAt(t,e){return this.getPoint(t,e)}getTangent(t,e=new T){return e.subVectors(this.v2,this.v1).normalize()}getTangentAt(t,e){return this.getTangent(t,e)}copy(t){return super.copy(t),this.v1.copy(t.v1),this.v2.copy(t.v2),this}toJSON(){let t=super.toJSON();return t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this}},Xr=class extends pi{constructor(t=new nt,e=new nt,i=new nt){super(),this.isQuadraticBezierCurve=!0,this.type="QuadraticBezierCurve",this.v0=t,this.v1=e,this.v2=i}getPoint(t,e=new nt){let i=e,n=this.v0,r=this.v1,o=this.v2;return i.set(yr(t,n.x,r.x,o.x),yr(t,n.y,r.y,o.y)),i}copy(t){return super.copy(t),this.v0.copy(t.v0),this.v1.copy(t.v1),this.v2.copy(t.v2),this}toJSON(){let t=super.toJSON();return t.v0=this.v0.toArray(),t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v0.fromArray(t.v0),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this}},wa=class extends pi{constructor(t=new T,e=new T,i=new T){super(),this.isQuadraticBezierCurve3=!0,this.type="QuadraticBezierCurve3",this.v0=t,this.v1=e,this.v2=i}getPoint(t,e=new T){let i=e,n=this.v0,r=this.v1,o=this.v2;return i.set(yr(t,n.x,r.x,o.x),yr(t,n.y,r.y,o.y),yr(t,n.z,r.z,o.z)),i}copy(t){return super.copy(t),this.v0.copy(t.v0),this.v1.copy(t.v1),this.v2.copy(t.v2),this}toJSON(){let t=super.toJSON();return t.v0=this.v0.toArray(),t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v0.fromArray(t.v0),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this}},qr=class extends pi{constructor(t=[]){super(),this.isSplineCurve=!0,this.type="SplineCurve",this.points=t}getPoint(t,e=new nt){let i=e,n=this.points,r=(n.length-1)*t,o=Math.floor(r),a=r-o,l=n[o===0?o:o-1],c=n[o],h=n[o>n.length-2?n.length-1:o+1],u=n[o>n.length-3?n.length-1:o+2];return i.set(sd(a,l.x,c.x,h.x,u.x),sd(a,l.y,c.y,h.y,u.y)),i}copy(t){super.copy(t),this.points=[];for(let e=0,i=t.points.length;e<i;e++){let n=t.points[e];this.points.push(n.clone())}return this}toJSON(){let t=super.toJSON();t.points=[];for(let e=0,i=this.points.length;e<i;e++){let n=this.points[e];t.points.push(n.toArray())}return t}fromJSON(t){super.fromJSON(t),this.points=[];for(let e=0,i=t.points.length;e<i;e++){let n=t.points[e];this.points.push(new nt().fromArray(n))}return this}},Jc=Object.freeze({__proto__:null,ArcCurve:ya,CatmullRomCurve3:va,CubicBezierCurve:Gr,CubicBezierCurve3:Ma,EllipseCurve:Fs,LineCurve:Wr,LineCurve3:ba,QuadraticBezierCurve:Xr,QuadraticBezierCurve3:wa,SplineCurve:qr}),Sa=class extends pi{constructor(){super(),this.type="CurvePath",this.curves=[],this.autoClose=!1}add(t){this.curves.push(t)}closePath(){let t=this.curves[0].getPoint(0),e=this.curves[this.curves.length-1].getPoint(1);if(!t.equals(e)){let i=t.isVector2===!0?"LineCurve":"LineCurve3";this.curves.push(new Jc[i](e,t))}return this}getPoint(t,e){let i=t*this.getLength(),n=this.getCurveLengths(),r=0;for(;r<n.length;){if(n[r]>=i){let o=n[r]-i,a=this.curves[r],l=a.getLength(),c=l===0?0:1-o/l;return a.getPointAt(c,e)}r++}return null}getLength(){let t=this.getCurveLengths();return t[t.length-1]}updateArcLengths(){this.needsUpdate=!0,this.cacheLengths=null,this.getCurveLengths()}getCurveLengths(){if(this.cacheLengths&&this.cacheLengths.length===this.curves.length)return this.cacheLengths;let t=[],e=0;for(let i=0,n=this.curves.length;i<n;i++)e+=this.curves[i].getLength(),t.push(e);return this.cacheLengths=t,t}getSpacedPoints(t=40){let e=[];for(let i=0;i<=t;i++)e.push(this.getPoint(i/t));return this.autoClose&&e.push(e[0]),e}getPoints(t=12){let e=[],i;for(let n=0,r=this.curves;n<r.length;n++){let o=r[n],a=o.isEllipseCurve?t*2:o.isLineCurve||o.isLineCurve3?1:o.isSplineCurve?t*o.points.length:t,l=o.getPoints(a);for(let c=0;c<l.length;c++){let h=l[c];i&&i.equals(h)||(e.push(h),i=h)}}return this.autoClose&&e.length>1&&!e[e.length-1].equals(e[0])&&e.push(e[0]),e}copy(t){super.copy(t),this.curves=[];for(let e=0,i=t.curves.length;e<i;e++){let n=t.curves[e];this.curves.push(n.clone())}return this.autoClose=t.autoClose,this}toJSON(){let t=super.toJSON();t.autoClose=this.autoClose,t.curves=[];for(let e=0,i=this.curves.length;e<i;e++){let n=this.curves[e];t.curves.push(n.toJSON())}return t}fromJSON(t){super.fromJSON(t),this.autoClose=t.autoClose,this.curves=[];for(let e=0,i=t.curves.length;e<i;e++){let n=t.curves[e];this.curves.push(new Jc[n.type]().fromJSON(n))}return this}},Yr=class extends Sa{constructor(t){super(),this.type="Path",this.currentPoint=new nt,t&&this.setFromPoints(t)}setFromPoints(t){this.moveTo(t[0].x,t[0].y);for(let e=1,i=t.length;e<i;e++)this.lineTo(t[e].x,t[e].y);return this}moveTo(t,e){return this.currentPoint.set(t,e),this}lineTo(t,e){let i=new Wr(this.currentPoint.clone(),new nt(t,e));return this.curves.push(i),this.currentPoint.set(t,e),this}quadraticCurveTo(t,e,i,n){let r=new Xr(this.currentPoint.clone(),new nt(t,e),new nt(i,n));return this.curves.push(r),this.currentPoint.set(i,n),this}bezierCurveTo(t,e,i,n,r,o){let a=new Gr(this.currentPoint.clone(),new nt(t,e),new nt(i,n),new nt(r,o));return this.curves.push(a),this.currentPoint.set(r,o),this}splineThru(t){let e=[this.currentPoint.clone()].concat(t),i=new qr(e);return this.curves.push(i),this.currentPoint.copy(t[t.length-1]),this}arc(t,e,i,n,r,o){let a=this.currentPoint.x,l=this.currentPoint.y;return this.absarc(t+a,e+l,i,n,r,o),this}absarc(t,e,i,n,r,o){return this.absellipse(t,e,i,i,n,r,o),this}ellipse(t,e,i,n,r,o,a,l){let c=this.currentPoint.x,h=this.currentPoint.y;return this.absellipse(t+c,e+h,i,n,r,o,a,l),this}absellipse(t,e,i,n,r,o,a,l){let c=new Fs(t,e,i,n,r,o,a,l);if(this.curves.length>0){let u=c.getPoint(0);u.equals(this.currentPoint)||this.lineTo(u.x,u.y)}this.curves.push(c);let h=c.getPoint(1);return this.currentPoint.copy(h),this}copy(t){return super.copy(t),this.currentPoint.copy(t.currentPoint),this}toJSON(){let t=super.toJSON();return t.currentPoint=this.currentPoint.toArray(),t}fromJSON(t){return super.fromJSON(t),this.currentPoint.fromArray(t.currentPoint),this}},on=class extends Yr{constructor(t){super(t),this.uuid=Di(),this.type="Shape",this.holes=[]}getPointsHoles(t){let e=[];for(let i=0,n=this.holes.length;i<n;i++)e[i]=this.holes[i].getPoints(t);return e}extractPoints(t){return{shape:this.getPoints(t),holes:this.getPointsHoles(t)}}copy(t){super.copy(t),this.holes=[];for(let e=0,i=t.holes.length;e<i;e++){let n=t.holes[e];this.holes.push(n.clone())}return this}toJSON(){let t=super.toJSON();t.uuid=this.uuid,t.holes=[];for(let e=0,i=this.holes.length;e<i;e++){let n=this.holes[e];t.holes.push(n.toJSON())}return t}fromJSON(t){super.fromJSON(t),this.uuid=t.uuid,this.holes=[];for(let e=0,i=t.holes.length;e<i;e++){let n=t.holes[e];this.holes.push(new Yr().fromJSON(n))}return this}};function w0(s,t,e=2){let i=t&&t.length,n=i?t[0]*e:s.length,r=ef(s,0,n,e,!0),o=[];if(!r||r.next===r.prev)return o;let a,l,c;if(i&&(r=R0(s,t,r,e)),s.length>80*e){a=1/0,l=1/0;let h=-1/0,u=-1/0;for(let f=e;f<n;f+=e){let d=s[f],g=s[f+1];d<a&&(a=d),g<l&&(l=g),d>h&&(h=d),g>u&&(u=g)}c=Math.max(h-a,u-l),c=c!==0?32767/c:0}return Zr(r,o,e,a,l,c,0),o}function ef(s,t,e,i,n){let r;if(n===O0(s,t,e,i)>0)for(let o=t;o<e;o+=i)r=rd(o/i|0,s[o],s[o+1],r);else for(let o=e-i;o>=t;o-=i)r=rd(o/i|0,s[o],s[o+1],r);return r&&ks(r,r.next)&&(Jr(r),r=r.next),r}function Zn(s,t){if(!s)return s;t||(t=s);let e=s,i;do if(i=!1,!e.steiner&&(ks(e,e.next)||Se(e.prev,e,e.next)===0)){if(Jr(e),e=t=e.prev,e===e.next)break;i=!0}else e=e.next;while(i||e!==t);return t}function Zr(s,t,e,i,n,r,o){if(!s)return;!o&&r&&D0(s,i,n,r);let a=s;for(;s.prev!==s.next;){let l=s.prev,c=s.next;if(r?E0(s,i,n,r):S0(s)){t.push(l.i,s.i,c.i),Jr(s),s=c.next,a=c.next;continue}if(s=c,s===a){o?o===1?(s=T0(Zn(s),t),Zr(s,t,e,i,n,r,2)):o===2&&A0(s,t,e,i,n,r):Zr(Zn(s),t,e,i,n,r,1);break}}}function S0(s){let t=s.prev,e=s,i=s.next;if(Se(t,e,i)>=0)return!1;let n=t.x,r=e.x,o=i.x,a=t.y,l=e.y,c=i.y,h=Math.min(n,r,o),u=Math.min(a,l,c),f=Math.max(n,r,o),d=Math.max(a,l,c),g=i.next;for(;g!==t;){if(g.x>=h&&g.x<=f&&g.y>=u&&g.y<=d&&gr(n,a,r,l,o,c,g.x,g.y)&&Se(g.prev,g,g.next)>=0)return!1;g=g.next}return!0}function E0(s,t,e,i){let n=s.prev,r=s,o=s.next;if(Se(n,r,o)>=0)return!1;let a=n.x,l=r.x,c=o.x,h=n.y,u=r.y,f=o.y,d=Math.min(a,l,c),g=Math.min(h,u,f),x=Math.max(a,l,c),m=Math.max(h,u,f),p=Kc(d,g,t,e,i),M=Kc(x,m,t,e,i),y=s.prevZ,_=s.nextZ;for(;y&&y.z>=p&&_&&_.z<=M;){if(y.x>=d&&y.x<=x&&y.y>=g&&y.y<=m&&y!==n&&y!==o&&gr(a,h,l,u,c,f,y.x,y.y)&&Se(y.prev,y,y.next)>=0||(y=y.prevZ,_.x>=d&&_.x<=x&&_.y>=g&&_.y<=m&&_!==n&&_!==o&&gr(a,h,l,u,c,f,_.x,_.y)&&Se(_.prev,_,_.next)>=0))return!1;_=_.nextZ}for(;y&&y.z>=p;){if(y.x>=d&&y.x<=x&&y.y>=g&&y.y<=m&&y!==n&&y!==o&&gr(a,h,l,u,c,f,y.x,y.y)&&Se(y.prev,y,y.next)>=0)return!1;y=y.prevZ}for(;_&&_.z<=M;){if(_.x>=d&&_.x<=x&&_.y>=g&&_.y<=m&&_!==n&&_!==o&&gr(a,h,l,u,c,f,_.x,_.y)&&Se(_.prev,_,_.next)>=0)return!1;_=_.nextZ}return!0}function T0(s,t){let e=s;do{let i=e.prev,n=e.next.next;!ks(i,n)&&sf(i,e,e.next,n)&&$r(i,n)&&$r(n,i)&&(t.push(i.i,e.i,n.i),Jr(e),Jr(e.next),e=s=n),e=e.next}while(e!==s);return Zn(e)}function A0(s,t,e,i,n,r){let o=s;do{let a=o.next.next;for(;a!==o.prev;){if(o.i!==a.i&&F0(o,a)){let l=rf(o,a);o=Zn(o,o.next),l=Zn(l,l.next),Zr(o,t,e,i,n,r,0),Zr(l,t,e,i,n,r,0);return}a=a.next}o=o.next}while(o!==s)}function R0(s,t,e,i){let n=[];for(let r=0,o=t.length;r<o;r++){let a=t[r]*i,l=r<o-1?t[r+1]*i:s.length,c=ef(s,a,l,i,!1);c===c.next&&(c.steiner=!0),n.push(N0(c))}n.sort(C0);for(let r=0;r<n.length;r++)e=I0(n[r],e);return e}function C0(s,t){let e=s.x-t.x;if(e===0&&(e=s.y-t.y,e===0)){let i=(s.next.y-s.y)/(s.next.x-s.x),n=(t.next.y-t.y)/(t.next.x-t.x);e=i-n}return e}function I0(s,t){let e=P0(s,t);if(!e)return t;let i=rf(e,s);return Zn(i,i.next),Zn(e,e.next)}function P0(s,t){let e=t,i=s.x,n=s.y,r=-1/0,o;if(ks(s,e))return e;do{if(ks(s,e.next))return e.next;if(n<=e.y&&n>=e.next.y&&e.next.y!==e.y){let u=e.x+(n-e.y)*(e.next.x-e.x)/(e.next.y-e.y);if(u<=i&&u>r&&(r=u,o=e.x<e.next.x?e:e.next,u===i))return o}e=e.next}while(e!==t);if(!o)return null;let a=o,l=o.x,c=o.y,h=1/0;e=o;do{if(i>=e.x&&e.x>=l&&i!==e.x&&nf(n<c?i:r,n,l,c,n<c?r:i,n,e.x,e.y)){let u=Math.abs(n-e.y)/(i-e.x);$r(e,s)&&(u<h||u===h&&(e.x>o.x||e.x===o.x&&L0(o,e)))&&(o=e,h=u)}e=e.next}while(e!==a);return o}function L0(s,t){return Se(s.prev,s,t.prev)<0&&Se(t.next,s,s.next)<0}function D0(s,t,e,i){let n=s;do n.z===0&&(n.z=Kc(n.x,n.y,t,e,i)),n.prevZ=n.prev,n.nextZ=n.next,n=n.next;while(n!==s);n.prevZ.nextZ=null,n.prevZ=null,U0(n)}function U0(s){let t,e=1;do{let i=s,n;s=null;let r=null;for(t=0;i;){t++;let o=i,a=0;for(let c=0;c<e&&(a++,o=o.nextZ,!!o);c++);let l=e;for(;a>0||l>0&&o;)a!==0&&(l===0||!o||i.z<=o.z)?(n=i,i=i.nextZ,a--):(n=o,o=o.nextZ,l--),r?r.nextZ=n:s=n,n.prevZ=r,r=n;i=o}r.nextZ=null,e*=2}while(t>1);return s}function Kc(s,t,e,i,n){return s=(s-e)*n|0,t=(t-i)*n|0,s=(s|s<<8)&16711935,s=(s|s<<4)&252645135,s=(s|s<<2)&858993459,s=(s|s<<1)&1431655765,t=(t|t<<8)&16711935,t=(t|t<<4)&252645135,t=(t|t<<2)&858993459,t=(t|t<<1)&1431655765,s|t<<1}function N0(s){let t=s,e=s;do(t.x<e.x||t.x===e.x&&t.y<e.y)&&(e=t),t=t.next;while(t!==s);return e}function nf(s,t,e,i,n,r,o,a){return(n-o)*(t-a)>=(s-o)*(r-a)&&(s-o)*(i-a)>=(e-o)*(t-a)&&(e-o)*(r-a)>=(n-o)*(i-a)}function gr(s,t,e,i,n,r,o,a){return!(s===o&&t===a)&&nf(s,t,e,i,n,r,o,a)}function F0(s,t){return s.next.i!==t.i&&s.prev.i!==t.i&&!k0(s,t)&&($r(s,t)&&$r(t,s)&&B0(s,t)&&(Se(s.prev,s,t.prev)||Se(s,t.prev,t))||ks(s,t)&&Se(s.prev,s,s.next)>0&&Se(t.prev,t,t.next)>0)}function Se(s,t,e){return(t.y-s.y)*(e.x-t.x)-(t.x-s.x)*(e.y-t.y)}function ks(s,t){return s.x===t.x&&s.y===t.y}function sf(s,t,e,i){let n=ra(Se(s,t,e)),r=ra(Se(s,t,i)),o=ra(Se(e,i,s)),a=ra(Se(e,i,t));return!!(n!==r&&o!==a||n===0&&sa(s,e,t)||r===0&&sa(s,i,t)||o===0&&sa(e,s,i)||a===0&&sa(e,t,i))}function sa(s,t,e){return t.x<=Math.max(s.x,e.x)&&t.x>=Math.min(s.x,e.x)&&t.y<=Math.max(s.y,e.y)&&t.y>=Math.min(s.y,e.y)}function ra(s){return s>0?1:s<0?-1:0}function k0(s,t){let e=s;do{if(e.i!==s.i&&e.next.i!==s.i&&e.i!==t.i&&e.next.i!==t.i&&sf(e,e.next,s,t))return!0;e=e.next}while(e!==s);return!1}function $r(s,t){return Se(s.prev,s,s.next)<0?Se(s,t,s.next)>=0&&Se(s,s.prev,t)>=0:Se(s,t,s.prev)<0||Se(s,s.next,t)<0}function B0(s,t){let e=s,i=!1,n=(s.x+t.x)/2,r=(s.y+t.y)/2;do e.y>r!=e.next.y>r&&e.next.y!==e.y&&n<(e.next.x-e.x)*(r-e.y)/(e.next.y-e.y)+e.x&&(i=!i),e=e.next;while(e!==s);return i}function rf(s,t){let e=jc(s.i,s.x,s.y),i=jc(t.i,t.x,t.y),n=s.next,r=t.prev;return s.next=t,t.prev=s,e.next=n,n.prev=e,i.next=e,e.prev=i,r.next=i,i.prev=r,i}function rd(s,t,e,i){let n=jc(s,t,e);return i?(n.next=i.next,n.prev=i,i.next.prev=n,i.next=n):(n.prev=n,n.next=n),n}function Jr(s){s.next.prev=s.prev,s.prev.next=s.next,s.prevZ&&(s.prevZ.nextZ=s.nextZ),s.nextZ&&(s.nextZ.prevZ=s.prevZ)}function jc(s,t,e){return{i:s,x:t,y:e,prev:null,next:null,z:0,prevZ:null,nextZ:null,steiner:!1}}function O0(s,t,e,i){let n=0;for(let r=t,o=e-i;r<e;r+=i)n+=(s[o]-s[r])*(s[r+1]+s[o+1]),o=r;return n}var Qc=class{static triangulate(t,e,i=2){return w0(t,e,i)}},Vi=class s{static area(t){let e=t.length,i=0;for(let n=e-1,r=0;r<e;n=r++)i+=t[n].x*t[r].y-t[r].x*t[n].y;return i*.5}static isClockWise(t){return s.area(t)<0}static triangulateShape(t,e){let i=[],n=[],r=[];od(t),ad(i,t);let o=t.length;e.forEach(od);for(let l=0;l<e.length;l++)n.push(o),o+=e[l].length,ad(i,e[l]);let a=Qc.triangulate(i,n);for(let l=0;l<a.length;l+=3)r.push(a.slice(l,l+3));return r}};function od(s){let t=s.length;t>2&&s[t-1].equals(s[0])&&s.pop()}function ad(s,t){for(let e=0;e<t.length;e++)s.push(t[e].x),s.push(t[e].y)}var Kr=class s extends ue{constructor(t=new on([new nt(.5,.5),new nt(-.5,.5),new nt(-.5,-.5),new nt(.5,-.5)]),e={}){super(),this.type="ExtrudeGeometry",this.parameters={shapes:t,options:e},t=Array.isArray(t)?t:[t];let i=this,n=[],r=[];for(let a=0,l=t.length;a<l;a++){let c=t[a];o(c)}this.setAttribute("position",new Ht(n,3)),this.setAttribute("uv",new Ht(r,2)),this.computeVertexNormals();function o(a){let l=[],c=e.curveSegments!==void 0?e.curveSegments:12,h=e.steps!==void 0?e.steps:1,u=e.depth!==void 0?e.depth:1,f=e.bevelEnabled!==void 0?e.bevelEnabled:!0,d=e.bevelThickness!==void 0?e.bevelThickness:.2,g=e.bevelSize!==void 0?e.bevelSize:d-.1,x=e.bevelOffset!==void 0?e.bevelOffset:0,m=e.bevelSegments!==void 0?e.bevelSegments:3,p=e.extrudePath,M=e.UVGenerator!==void 0?e.UVGenerator:z0,y,_=!1,b,E,P,L;p&&(y=p.getSpacedPoints(h),_=!0,f=!1,b=p.computeFrenetFrames(h,!1),E=new T,P=new T,L=new T),f||(m=0,d=0,g=0,x=0);let w=a.extractPoints(c),v=w.shape,C=w.holes;if(!Vi.isClockWise(v)){v=v.reverse();for(let tt=0,K=C.length;tt<K;tt++){let J=C[tt];Vi.isClockWise(J)&&(C[tt]=J.reverse())}}function O(tt){let J=10000000000000001e-36,$=tt[0];for(let ut=1;ut<=tt.length;ut++){let st=ut%tt.length,dt=tt[st],Vt=dt.x-$.x,zt=dt.y-$.y,I=Vt*Vt+zt*zt,S=Math.max(Math.abs(dt.x),Math.abs(dt.y),Math.abs($.x),Math.abs($.y)),B=J*S*S;if(I<=B){tt.splice(st,1),ut--;continue}$=dt}}O(v),C.forEach(O);let z=C.length,q=v;for(let tt=0;tt<z;tt++){let K=C[tt];v=v.concat(K)}function H(tt,K,J){return K||console.error("THREE.ExtrudeGeometry: vec does not exist"),tt.clone().addScaledVector(K,J)}let it=v.length;function X(tt,K,J){let $,ut,st,dt=tt.x-K.x,Vt=tt.y-K.y,zt=J.x-tt.x,I=J.y-tt.y,S=dt*dt+Vt*Vt,B=dt*I-Vt*zt;if(Math.abs(B)>Number.EPSILON){let W=Math.sqrt(S),Q=Math.sqrt(zt*zt+I*I),Y=K.x-Vt/W,It=K.y+dt/W,ht=J.x-I/Q,At=J.y+zt/Q,Rt=((ht-Y)*I-(At-It)*zt)/(dt*I-Vt*zt);$=Y+dt*Rt-tt.x,ut=It+Vt*Rt-tt.y;let rt=$*$+ut*ut;if(rt<=2)return new nt($,ut);st=Math.sqrt(rt/2)}else{let W=!1;dt>Number.EPSILON?zt>Number.EPSILON&&(W=!0):dt<-Number.EPSILON?zt<-Number.EPSILON&&(W=!0):Math.sign(Vt)===Math.sign(I)&&(W=!0),W?($=-Vt,ut=dt,st=Math.sqrt(S)):($=dt,ut=Vt,st=Math.sqrt(S/2))}return new nt($/st,ut/st)}let ct=[];for(let tt=0,K=q.length,J=K-1,$=tt+1;tt<K;tt++,J++,$++)J===K&&(J=0),$===K&&($=0),ct[tt]=X(q[tt],q[J],q[$]);let mt=[],bt,Wt=ct.concat();for(let tt=0,K=z;tt<K;tt++){let J=C[tt];bt=[];for(let $=0,ut=J.length,st=ut-1,dt=$+1;$<ut;$++,st++,dt++)st===ut&&(st=0),dt===ut&&(dt=0),bt[$]=X(J[$],J[st],J[dt]);mt.push(bt),Wt=Wt.concat(bt)}let jt;if(m===0)jt=Vi.triangulateShape(q,C);else{let tt=[],K=[];for(let J=0;J<m;J++){let $=J/m,ut=d*Math.cos($*Math.PI/2),st=g*Math.sin($*Math.PI/2)+x;for(let dt=0,Vt=q.length;dt<Vt;dt++){let zt=H(q[dt],ct[dt],st);Lt(zt.x,zt.y,-ut),$===0&&tt.push(zt)}for(let dt=0,Vt=z;dt<Vt;dt++){let zt=C[dt];bt=mt[dt];let I=[];for(let S=0,B=zt.length;S<B;S++){let W=H(zt[S],bt[S],st);Lt(W.x,W.y,-ut),$===0&&I.push(W)}$===0&&K.push(I)}}jt=Vi.triangulateShape(tt,K)}let le=jt.length,Qt=g+x;for(let tt=0;tt<it;tt++){let K=f?H(v[tt],Wt[tt],Qt):v[tt];_?(P.copy(b.normals[0]).multiplyScalar(K.x),E.copy(b.binormals[0]).multiplyScalar(K.y),L.copy(y[0]).add(P).add(E),Lt(L.x,L.y,L.z)):Lt(K.x,K.y,0)}for(let tt=1;tt<=h;tt++)for(let K=0;K<it;K++){let J=f?H(v[K],Wt[K],Qt):v[K];_?(P.copy(b.normals[tt]).multiplyScalar(J.x),E.copy(b.binormals[tt]).multiplyScalar(J.y),L.copy(y[tt]).add(P).add(E),Lt(L.x,L.y,L.z)):Lt(J.x,J.y,u/h*tt)}for(let tt=m-1;tt>=0;tt--){let K=tt/m,J=d*Math.cos(K*Math.PI/2),$=g*Math.sin(K*Math.PI/2)+x;for(let ut=0,st=q.length;ut<st;ut++){let dt=H(q[ut],ct[ut],$);Lt(dt.x,dt.y,u+J)}for(let ut=0,st=C.length;ut<st;ut++){let dt=C[ut];bt=mt[ut];for(let Vt=0,zt=dt.length;Vt<zt;Vt++){let I=H(dt[Vt],bt[Vt],$);_?Lt(I.x,I.y+y[h-1].y,y[h-1].x+J):Lt(I.x,I.y,u+J)}}}Z(),et();function Z(){let tt=n.length/3;if(f){let K=0,J=it*K;for(let $=0;$<le;$++){let ut=jt[$];Tt(ut[2]+J,ut[1]+J,ut[0]+J)}K=h+m*2,J=it*K;for(let $=0;$<le;$++){let ut=jt[$];Tt(ut[0]+J,ut[1]+J,ut[2]+J)}}else{for(let K=0;K<le;K++){let J=jt[K];Tt(J[2],J[1],J[0])}for(let K=0;K<le;K++){let J=jt[K];Tt(J[0]+it*h,J[1]+it*h,J[2]+it*h)}}i.addGroup(tt,n.length/3-tt,0)}function et(){let tt=n.length/3,K=0;Mt(q,K),K+=q.length;for(let J=0,$=C.length;J<$;J++){let ut=C[J];Mt(ut,K),K+=ut.length}i.addGroup(tt,n.length/3-tt,1)}function Mt(tt,K){let J=tt.length;for(;--J>=0;){let $=J,ut=J-1;ut<0&&(ut=tt.length-1);for(let st=0,dt=h+m*2;st<dt;st++){let Vt=it*st,zt=it*(st+1),I=K+$+Vt,S=K+ut+Vt,B=K+ut+zt,W=K+$+zt;Jt(I,S,B,W)}}}function Lt(tt,K,J){l.push(tt),l.push(K),l.push(J)}function Tt(tt,K,J){ge(tt),ge(K),ge(J);let $=n.length/3,ut=M.generateTopUV(i,n,$-3,$-2,$-1);D(ut[0]),D(ut[1]),D(ut[2])}function Jt(tt,K,J,$){ge(tt),ge(K),ge($),ge(K),ge(J),ge($);let ut=n.length/3,st=M.generateSideWallUV(i,n,ut-6,ut-3,ut-2,ut-1);D(st[0]),D(st[1]),D(st[3]),D(st[1]),D(st[2]),D(st[3])}function ge(tt){n.push(l[tt*3+0]),n.push(l[tt*3+1]),n.push(l[tt*3+2])}function D(tt){r.push(tt.x),r.push(tt.y)}}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}toJSON(){let t=super.toJSON(),e=this.parameters.shapes,i=this.parameters.options;return H0(e,i,t)}static fromJSON(t,e){let i=[];for(let r=0,o=t.shapes.length;r<o;r++){let a=e[t.shapes[r]];i.push(a)}let n=t.options.extrudePath;return n!==void 0&&(t.options.extrudePath=new Jc[n.type]().fromJSON(n)),new s(i,t.options)}},z0={generateTopUV:function(s,t,e,i,n){let r=t[e*3],o=t[e*3+1],a=t[i*3],l=t[i*3+1],c=t[n*3],h=t[n*3+1];return[new nt(r,o),new nt(a,l),new nt(c,h)]},generateSideWallUV:function(s,t,e,i,n,r){let o=t[e*3],a=t[e*3+1],l=t[e*3+2],c=t[i*3],h=t[i*3+1],u=t[i*3+2],f=t[n*3],d=t[n*3+1],g=t[n*3+2],x=t[r*3],m=t[r*3+1],p=t[r*3+2];return Math.abs(a-h)<Math.abs(o-c)?[new nt(o,1-l),new nt(c,1-u),new nt(f,1-g),new nt(x,1-p)]:[new nt(a,1-l),new nt(h,1-u),new nt(d,1-g),new nt(m,1-p)]}};function H0(s,t,e){if(e.shapes=[],Array.isArray(s))for(let i=0,n=s.length;i<n;i++){let r=s[i];e.shapes.push(r.uuid)}else e.shapes.push(s.uuid);return e.options=Object.assign({},t),t.extrudePath!==void 0&&(e.options.extrudePath=t.extrudePath.toJSON()),e}var jr=class s extends Hr{constructor(t=1,e=0){let i=(1+Math.sqrt(5))/2,n=[-1,i,0,1,i,0,-1,-i,0,1,-i,0,0,-1,i,0,1,i,0,-1,-i,0,1,-i,i,0,-1,i,0,1,-i,0,-1,-i,0,1],r=[0,11,5,0,5,1,0,1,7,0,7,10,0,10,11,1,5,9,5,11,4,11,10,2,10,7,6,7,1,8,3,9,4,3,4,2,3,2,6,3,6,8,3,8,9,4,9,5,2,4,11,6,2,10,8,6,7,9,8,1];super(n,r,t,e),this.type="IcosahedronGeometry",this.parameters={radius:t,detail:e}}static fromJSON(t){return new s(t.radius,t.detail)}},Qr=class s extends ue{constructor(t=[new nt(0,-.5),new nt(.5,0),new nt(0,.5)],e=12,i=0,n=Math.PI*2){super(),this.type="LatheGeometry",this.parameters={points:t,segments:e,phiStart:i,phiLength:n},e=Math.floor(e),n=Zt(n,0,Math.PI*2);let r=[],o=[],a=[],l=[],c=[],h=1/e,u=new T,f=new nt,d=new T,g=new T,x=new T,m=0,p=0;for(let M=0;M<=t.length-1;M++)switch(M){case 0:m=t[M+1].x-t[M].x,p=t[M+1].y-t[M].y,d.x=p*1,d.y=-m,d.z=p*0,x.copy(d),d.normalize(),l.push(d.x,d.y,d.z);break;case t.length-1:l.push(x.x,x.y,x.z);break;default:m=t[M+1].x-t[M].x,p=t[M+1].y-t[M].y,d.x=p*1,d.y=-m,d.z=p*0,g.copy(d),d.x+=x.x,d.y+=x.y,d.z+=x.z,d.normalize(),l.push(d.x,d.y,d.z),x.copy(g)}for(let M=0;M<=e;M++){let y=i+M*h*n,_=Math.sin(y),b=Math.cos(y);for(let E=0;E<=t.length-1;E++){u.x=t[E].x*_,u.y=t[E].y,u.z=t[E].x*b,o.push(u.x,u.y,u.z),f.x=M/e,f.y=E/(t.length-1),a.push(f.x,f.y);let P=l[3*E+0]*_,L=l[3*E+1],w=l[3*E+0]*b;c.push(P,L,w)}}for(let M=0;M<e;M++)for(let y=0;y<t.length-1;y++){let _=y+M*t.length,b=_,E=_+t.length,P=_+t.length+1,L=_+1;r.push(b,E,L),r.push(P,L,E)}this.setIndex(r),this.setAttribute("position",new Ht(o,3)),this.setAttribute("uv",new Ht(a,2)),this.setAttribute("normal",new Ht(c,3))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new s(t.points,t.segments,t.phiStart,t.phiLength)}};var Ke=class s extends ue{constructor(t=1,e=1,i=1,n=1){super(),this.type="PlaneGeometry",this.parameters={width:t,height:e,widthSegments:i,heightSegments:n};let r=t/2,o=e/2,a=Math.floor(i),l=Math.floor(n),c=a+1,h=l+1,u=t/a,f=e/l,d=[],g=[],x=[],m=[];for(let p=0;p<h;p++){let M=p*f-o;for(let y=0;y<c;y++){let _=y*u-r;g.push(_,-M,0),x.push(0,0,1),m.push(y/a),m.push(1-p/l)}}for(let p=0;p<l;p++)for(let M=0;M<a;M++){let y=M+c*p,_=M+c*(p+1),b=M+1+c*(p+1),E=M+1+c*p;d.push(y,_,E),d.push(_,b,E)}this.setIndex(d),this.setAttribute("position",new Ht(g,3)),this.setAttribute("normal",new Ht(x,3)),this.setAttribute("uv",new Ht(m,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new s(t.width,t.height,t.widthSegments,t.heightSegments)}},to=class s extends ue{constructor(t=.5,e=1,i=32,n=1,r=0,o=Math.PI*2){super(),this.type="RingGeometry",this.parameters={innerRadius:t,outerRadius:e,thetaSegments:i,phiSegments:n,thetaStart:r,thetaLength:o},i=Math.max(3,i),n=Math.max(1,n);let a=[],l=[],c=[],h=[],u=t,f=(e-t)/n,d=new T,g=new nt;for(let x=0;x<=n;x++){for(let m=0;m<=i;m++){let p=r+m/i*o;d.x=u*Math.cos(p),d.y=u*Math.sin(p),l.push(d.x,d.y,d.z),c.push(0,0,1),g.x=(d.x/e+1)/2,g.y=(d.y/e+1)/2,h.push(g.x,g.y)}u+=f}for(let x=0;x<n;x++){let m=x*(i+1);for(let p=0;p<i;p++){let M=p+m,y=M,_=M+i+1,b=M+i+2,E=M+1;a.push(y,_,E),a.push(_,b,E)}}this.setIndex(a),this.setAttribute("position",new Ht(l,3)),this.setAttribute("normal",new Ht(c,3)),this.setAttribute("uv",new Ht(h,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new s(t.innerRadius,t.outerRadius,t.thetaSegments,t.phiSegments,t.thetaStart,t.thetaLength)}},$n=class s extends ue{constructor(t=new on([new nt(0,.5),new nt(-.5,-.5),new nt(.5,-.5)]),e=12){super(),this.type="ShapeGeometry",this.parameters={shapes:t,curveSegments:e};let i=[],n=[],r=[],o=[],a=0,l=0;if(Array.isArray(t)===!1)c(t);else for(let h=0;h<t.length;h++)c(t[h]),this.addGroup(a,l,h),a+=l,l=0;this.setIndex(i),this.setAttribute("position",new Ht(n,3)),this.setAttribute("normal",new Ht(r,3)),this.setAttribute("uv",new Ht(o,2));function c(h){let u=n.length/3,f=h.extractPoints(e),d=f.shape,g=f.holes;Vi.isClockWise(d)===!1&&(d=d.reverse());for(let m=0,p=g.length;m<p;m++){let M=g[m];Vi.isClockWise(M)===!0&&(g[m]=M.reverse())}let x=Vi.triangulateShape(d,g);for(let m=0,p=g.length;m<p;m++){let M=g[m];d=d.concat(M)}for(let m=0,p=d.length;m<p;m++){let M=d[m];n.push(M.x,M.y,0),r.push(0,0,1),o.push(M.x,M.y)}for(let m=0,p=x.length;m<p;m++){let M=x[m],y=M[0]+u,_=M[1]+u,b=M[2]+u;i.push(y,_,b),l+=3}}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}toJSON(){let t=super.toJSON(),e=this.parameters.shapes;return V0(e,t)}static fromJSON(t,e){let i=[];for(let n=0,r=t.shapes.length;n<r;n++){let o=e[t.shapes[n]];i.push(o)}return new s(i,t.curveSegments)}};function V0(s,t){if(t.shapes=[],Array.isArray(s))for(let e=0,i=s.length;e<i;e++){let n=s[e];t.shapes.push(n.uuid)}else t.shapes.push(s.uuid);return t}var ci=class s extends ue{constructor(t=1,e=32,i=16,n=0,r=Math.PI*2,o=0,a=Math.PI){super(),this.type="SphereGeometry",this.parameters={radius:t,widthSegments:e,heightSegments:i,phiStart:n,phiLength:r,thetaStart:o,thetaLength:a},e=Math.max(3,Math.floor(e)),i=Math.max(2,Math.floor(i));let l=Math.min(o+a,Math.PI),c=0,h=[],u=new T,f=new T,d=[],g=[],x=[],m=[];for(let p=0;p<=i;p++){let M=[],y=p/i,_=0;p===0&&o===0?_=.5/e:p===i&&l===Math.PI&&(_=-.5/e);for(let b=0;b<=e;b++){let E=b/e;u.x=-t*Math.cos(n+E*r)*Math.sin(o+y*a),u.y=t*Math.cos(o+y*a),u.z=t*Math.sin(n+E*r)*Math.sin(o+y*a),g.push(u.x,u.y,u.z),f.copy(u).normalize(),x.push(f.x,f.y,f.z),m.push(E+_,1-y),M.push(c++)}h.push(M)}for(let p=0;p<i;p++)for(let M=0;M<e;M++){let y=h[p][M+1],_=h[p][M],b=h[p+1][M],E=h[p+1][M+1];(p!==0||o>0)&&d.push(y,_,E),(p!==i-1||l<Math.PI)&&d.push(_,b,E)}this.setIndex(d),this.setAttribute("position",new Ht(g,3)),this.setAttribute("normal",new Ht(x,3)),this.setAttribute("uv",new Ht(m,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new s(t.radius,t.widthSegments,t.heightSegments,t.phiStart,t.phiLength,t.thetaStart,t.thetaLength)}};var eo=class s extends ue{constructor(t=1,e=.4,i=12,n=48,r=Math.PI*2){super(),this.type="TorusGeometry",this.parameters={radius:t,tube:e,radialSegments:i,tubularSegments:n,arc:r},i=Math.floor(i),n=Math.floor(n);let o=[],a=[],l=[],c=[],h=new T,u=new T,f=new T;for(let d=0;d<=i;d++)for(let g=0;g<=n;g++){let x=g/n*r,m=d/i*Math.PI*2;u.x=(t+e*Math.cos(m))*Math.cos(x),u.y=(t+e*Math.cos(m))*Math.sin(x),u.z=e*Math.sin(m),a.push(u.x,u.y,u.z),h.x=t*Math.cos(x),h.y=t*Math.sin(x),f.subVectors(u,h).normalize(),l.push(f.x,f.y,f.z),c.push(g/n),c.push(d/i)}for(let d=1;d<=i;d++)for(let g=1;g<=n;g++){let x=(n+1)*d+g-1,m=(n+1)*(d-1)+g-1,p=(n+1)*(d-1)+g,M=(n+1)*d+g;o.push(x,m,M),o.push(m,p,M)}this.setIndex(o),this.setAttribute("position",new Ht(a,3)),this.setAttribute("normal",new Ht(l,3)),this.setAttribute("uv",new Ht(c,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new s(t.radius,t.tube,t.radialSegments,t.tubularSegments,t.arc)}};var je=class extends Fi{constructor(t){super(),this.isMeshStandardMaterial=!0,this.type="MeshStandardMaterial",this.defines={STANDARD:""},this.color=new _t(16777215),this.roughness=1,this.metalness=0,this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.emissive=new _t(0),this.emissiveIntensity=1,this.emissiveMap=null,this.bumpMap=null,this.bumpScale=1,this.normalMap=null,this.normalMapType=Ll,this.normalScale=new nt(1,1),this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.roughnessMap=null,this.metalnessMap=null,this.alphaMap=null,this.envMap=null,this.envMapRotation=new Re,this.envMapIntensity=1,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.flatShading=!1,this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.defines={STANDARD:""},this.color.copy(t.color),this.roughness=t.roughness,this.metalness=t.metalness,this.map=t.map,this.lightMap=t.lightMap,this.lightMapIntensity=t.lightMapIntensity,this.aoMap=t.aoMap,this.aoMapIntensity=t.aoMapIntensity,this.emissive.copy(t.emissive),this.emissiveMap=t.emissiveMap,this.emissiveIntensity=t.emissiveIntensity,this.bumpMap=t.bumpMap,this.bumpScale=t.bumpScale,this.normalMap=t.normalMap,this.normalMapType=t.normalMapType,this.normalScale.copy(t.normalScale),this.displacementMap=t.displacementMap,this.displacementScale=t.displacementScale,this.displacementBias=t.displacementBias,this.roughnessMap=t.roughnessMap,this.metalnessMap=t.metalnessMap,this.alphaMap=t.alphaMap,this.envMap=t.envMap,this.envMapRotation.copy(t.envMapRotation),this.envMapIntensity=t.envMapIntensity,this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this.wireframeLinecap=t.wireframeLinecap,this.wireframeLinejoin=t.wireframeLinejoin,this.flatShading=t.flatShading,this.fog=t.fog,this}};var an=class extends Fi{constructor(t){super(),this.isMeshLambertMaterial=!0,this.type="MeshLambertMaterial",this.color=new _t(16777215),this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.emissive=new _t(0),this.emissiveIntensity=1,this.emissiveMap=null,this.bumpMap=null,this.bumpScale=1,this.normalMap=null,this.normalMapType=Ll,this.normalScale=new nt(1,1),this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.specularMap=null,this.alphaMap=null,this.envMap=null,this.envMapRotation=new Re,this.combine=qa,this.reflectivity=1,this.refractionRatio=.98,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.flatShading=!1,this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.lightMap=t.lightMap,this.lightMapIntensity=t.lightMapIntensity,this.aoMap=t.aoMap,this.aoMapIntensity=t.aoMapIntensity,this.emissive.copy(t.emissive),this.emissiveMap=t.emissiveMap,this.emissiveIntensity=t.emissiveIntensity,this.bumpMap=t.bumpMap,this.bumpScale=t.bumpScale,this.normalMap=t.normalMap,this.normalMapType=t.normalMapType,this.normalScale.copy(t.normalScale),this.displacementMap=t.displacementMap,this.displacementScale=t.displacementScale,this.displacementBias=t.displacementBias,this.specularMap=t.specularMap,this.alphaMap=t.alphaMap,this.envMap=t.envMap,this.envMapRotation.copy(t.envMapRotation),this.combine=t.combine,this.reflectivity=t.reflectivity,this.refractionRatio=t.refractionRatio,this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this.wireframeLinecap=t.wireframeLinecap,this.wireframeLinejoin=t.wireframeLinejoin,this.flatShading=t.flatShading,this.fog=t.fog,this}},Ea=class extends Fi{constructor(t){super(),this.isMeshDepthMaterial=!0,this.type="MeshDepthMaterial",this.depthPacking=Hd,this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.wireframe=!1,this.wireframeLinewidth=1,this.setValues(t)}copy(t){return super.copy(t),this.depthPacking=t.depthPacking,this.map=t.map,this.alphaMap=t.alphaMap,this.displacementMap=t.displacementMap,this.displacementScale=t.displacementScale,this.displacementBias=t.displacementBias,this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this}},Ta=class extends Fi{constructor(t){super(),this.isMeshDistanceMaterial=!0,this.type="MeshDistanceMaterial",this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.setValues(t)}copy(t){return super.copy(t),this.map=t.map,this.alphaMap=t.alphaMap,this.displacementMap=t.displacementMap,this.displacementScale=t.displacementScale,this.displacementBias=t.displacementBias,this}};function oa(s,t){return!s||s.constructor===t?s:typeof t.BYTES_PER_ELEMENT=="number"?new t(s):Array.prototype.slice.call(s)}function G0(s){return ArrayBuffer.isView(s)&&!(s instanceof DataView)}var Jn=class{constructor(t,e,i,n){this.parameterPositions=t,this._cachedIndex=0,this.resultBuffer=n!==void 0?n:new e.constructor(i),this.sampleValues=e,this.valueSize=i,this.settings=null,this.DefaultSettings_={}}evaluate(t){let e=this.parameterPositions,i=this._cachedIndex,n=e[i],r=e[i-1];i:{t:{let o;e:{n:if(!(t<n)){for(let a=i+2;;){if(n===void 0){if(t<r)break n;return i=e.length,this._cachedIndex=i,this.copySampleValue_(i-1)}if(i===a)break;if(r=n,n=e[++i],t<n)break t}o=e.length;break e}if(!(t>=r)){let a=e[1];t<a&&(i=2,r=a);for(let l=i-2;;){if(r===void 0)return this._cachedIndex=0,this.copySampleValue_(0);if(i===l)break;if(n=r,r=e[--i-1],t>=r)break t}o=i,i=0;break e}break i}for(;i<o;){let a=i+o>>>1;t<e[a]?o=a:i=a+1}if(n=e[i],r=e[i-1],r===void 0)return this._cachedIndex=0,this.copySampleValue_(0);if(n===void 0)return i=e.length,this._cachedIndex=i,this.copySampleValue_(i-1)}this._cachedIndex=i,this.intervalChanged_(i,r,n)}return this.interpolate_(i,r,t,n)}getSettings_(){return this.settings||this.DefaultSettings_}copySampleValue_(t){let e=this.resultBuffer,i=this.sampleValues,n=this.valueSize,r=t*n;for(let o=0;o!==n;++o)e[o]=i[r+o];return e}interpolate_(){throw new Error("call to abstract method")}intervalChanged_(){}},Aa=class extends Jn{constructor(t,e,i,n){super(t,e,i,n),this._weightPrev=-0,this._offsetPrev=-0,this._weightNext=-0,this._offsetNext=-0,this.DefaultSettings_={endingStart:Xc,endingEnd:Xc}}intervalChanged_(t,e,i){let n=this.parameterPositions,r=t-2,o=t+1,a=n[r],l=n[o];if(a===void 0)switch(this.getSettings_().endingStart){case qc:r=t,a=2*e-i;break;case Yc:r=n.length-2,a=e+n[r]-n[r+1];break;default:r=t,a=i}if(l===void 0)switch(this.getSettings_().endingEnd){case qc:o=t,l=2*i-e;break;case Yc:o=1,l=i+n[1]-n[0];break;default:o=t-1,l=e}let c=(i-e)*.5,h=this.valueSize;this._weightPrev=c/(e-a),this._weightNext=c/(l-i),this._offsetPrev=r*h,this._offsetNext=o*h}interpolate_(t,e,i,n){let r=this.resultBuffer,o=this.sampleValues,a=this.valueSize,l=t*a,c=l-a,h=this._offsetPrev,u=this._offsetNext,f=this._weightPrev,d=this._weightNext,g=(i-e)/(n-e),x=g*g,m=x*g,p=-f*m+2*f*x-f*g,M=(1+f)*m+(-1.5-2*f)*x+(-.5+f)*g+1,y=(-1-d)*m+(1.5+d)*x+.5*g,_=d*m-d*x;for(let b=0;b!==a;++b)r[b]=p*o[h+b]+M*o[c+b]+y*o[l+b]+_*o[u+b];return r}},Ra=class extends Jn{constructor(t,e,i,n){super(t,e,i,n)}interpolate_(t,e,i,n){let r=this.resultBuffer,o=this.sampleValues,a=this.valueSize,l=t*a,c=l-a,h=(i-e)/(n-e),u=1-h;for(let f=0;f!==a;++f)r[f]=o[c+f]*u+o[l+f]*h;return r}},Ca=class extends Jn{constructor(t,e,i,n){super(t,e,i,n)}interpolate_(t){return this.copySampleValue_(t-1)}},mi=class{constructor(t,e,i,n){if(t===void 0)throw new Error("THREE.KeyframeTrack: track name is undefined");if(e===void 0||e.length===0)throw new Error("THREE.KeyframeTrack: no keyframes in track named "+t);this.name=t,this.times=oa(e,this.TimeBufferType),this.values=oa(i,this.ValueBufferType),this.setInterpolation(n||this.DefaultInterpolation)}static toJSON(t){let e=t.constructor,i;if(e.toJSON!==this.toJSON)i=e.toJSON(t);else{i={name:t.name,times:oa(t.times,Array),values:oa(t.values,Array)};let n=t.getInterpolation();n!==t.DefaultInterpolation&&(i.interpolation=n)}return i.type=t.ValueTypeName,i}InterpolantFactoryMethodDiscrete(t){return new Ca(this.times,this.values,this.getValueSize(),t)}InterpolantFactoryMethodLinear(t){return new Ra(this.times,this.values,this.getValueSize(),t)}InterpolantFactoryMethodSmooth(t){return new Aa(this.times,this.values,this.getValueSize(),t)}setInterpolation(t){let e;switch(t){case Mr:e=this.InterpolantFactoryMethodDiscrete;break;case ua:e=this.InterpolantFactoryMethodLinear;break;case aa:e=this.InterpolantFactoryMethodSmooth;break}if(e===void 0){let i="unsupported interpolation for "+this.ValueTypeName+" keyframe track named "+this.name;if(this.createInterpolant===void 0)if(t!==this.DefaultInterpolation)this.setInterpolation(this.DefaultInterpolation);else throw new Error(i);return console.warn("THREE.KeyframeTrack:",i),this}return this.createInterpolant=e,this}getInterpolation(){switch(this.createInterpolant){case this.InterpolantFactoryMethodDiscrete:return Mr;case this.InterpolantFactoryMethodLinear:return ua;case this.InterpolantFactoryMethodSmooth:return aa}}getValueSize(){return this.values.length/this.times.length}shift(t){if(t!==0){let e=this.times;for(let i=0,n=e.length;i!==n;++i)e[i]+=t}return this}scale(t){if(t!==1){let e=this.times;for(let i=0,n=e.length;i!==n;++i)e[i]*=t}return this}trim(t,e){let i=this.times,n=i.length,r=0,o=n-1;for(;r!==n&&i[r]<t;)++r;for(;o!==-1&&i[o]>e;)--o;if(++o,r!==0||o!==n){r>=o&&(o=Math.max(o,1),r=o-1);let a=this.getValueSize();this.times=i.slice(r,o),this.values=this.values.slice(r*a,o*a)}return this}validate(){let t=!0,e=this.getValueSize();e-Math.floor(e)!==0&&(console.error("THREE.KeyframeTrack: Invalid value size in track.",this),t=!1);let i=this.times,n=this.values,r=i.length;r===0&&(console.error("THREE.KeyframeTrack: Track is empty.",this),t=!1);let o=null;for(let a=0;a!==r;a++){let l=i[a];if(typeof l=="number"&&isNaN(l)){console.error("THREE.KeyframeTrack: Time is not a valid number.",this,a,l),t=!1;break}if(o!==null&&o>l){console.error("THREE.KeyframeTrack: Out of order keys.",this,a,l,o),t=!1;break}o=l}if(n!==void 0&&G0(n))for(let a=0,l=n.length;a!==l;++a){let c=n[a];if(isNaN(c)){console.error("THREE.KeyframeTrack: Value is not a valid number.",this,a,c),t=!1;break}}return t}optimize(){let t=this.times.slice(),e=this.values.slice(),i=this.getValueSize(),n=this.getInterpolation()===aa,r=t.length-1,o=1;for(let a=1;a<r;++a){let l=!1,c=t[a],h=t[a+1];if(c!==h&&(a!==1||c!==t[0]))if(n)l=!0;else{let u=a*i,f=u-i,d=u+i;for(let g=0;g!==i;++g){let x=e[u+g];if(x!==e[f+g]||x!==e[d+g]){l=!0;break}}}if(l){if(a!==o){t[o]=t[a];let u=a*i,f=o*i;for(let d=0;d!==i;++d)e[f+d]=e[u+d]}++o}}if(r>0){t[o]=t[r];for(let a=r*i,l=o*i,c=0;c!==i;++c)e[l+c]=e[a+c];++o}return o!==t.length?(this.times=t.slice(0,o),this.values=e.slice(0,o*i)):(this.times=t,this.values=e),this}clone(){let t=this.times.slice(),e=this.values.slice(),i=this.constructor,n=new i(this.name,t,e);return n.createInterpolant=this.createInterpolant,n}};mi.prototype.ValueTypeName="";mi.prototype.TimeBufferType=Float32Array;mi.prototype.ValueBufferType=Float32Array;mi.prototype.DefaultInterpolation=ua;var En=class extends mi{constructor(t,e,i){super(t,e,i)}};En.prototype.ValueTypeName="bool";En.prototype.ValueBufferType=Array;En.prototype.DefaultInterpolation=Mr;En.prototype.InterpolantFactoryMethodLinear=void 0;En.prototype.InterpolantFactoryMethodSmooth=void 0;var Ia=class extends mi{constructor(t,e,i,n){super(t,e,i,n)}};Ia.prototype.ValueTypeName="color";var Pa=class extends mi{constructor(t,e,i,n){super(t,e,i,n)}};Pa.prototype.ValueTypeName="number";var La=class extends Jn{constructor(t,e,i,n){super(t,e,i,n)}interpolate_(t,e,i,n){let r=this.resultBuffer,o=this.sampleValues,a=this.valueSize,l=(i-e)/(n-e),c=t*a;for(let h=c+a;c!==h;c+=4)_e.slerpFlat(r,0,o,c-a,o,c,l);return r}},io=class extends mi{constructor(t,e,i,n){super(t,e,i,n)}InterpolantFactoryMethodLinear(t){return new La(this.times,this.values,this.getValueSize(),t)}};io.prototype.ValueTypeName="quaternion";io.prototype.InterpolantFactoryMethodSmooth=void 0;var Tn=class extends mi{constructor(t,e,i){super(t,e,i)}};Tn.prototype.ValueTypeName="string";Tn.prototype.ValueBufferType=Array;Tn.prototype.DefaultInterpolation=Mr;Tn.prototype.InterpolantFactoryMethodLinear=void 0;Tn.prototype.InterpolantFactoryMethodSmooth=void 0;var Da=class extends mi{constructor(t,e,i,n){super(t,e,i,n)}};Da.prototype.ValueTypeName="vector";var Ua=class{constructor(t,e,i){let n=this,r=!1,o=0,a=0,l,c=[];this.onStart=void 0,this.onLoad=t,this.onProgress=e,this.onError=i,this.abortController=new AbortController,this.itemStart=function(h){a++,r===!1&&n.onStart!==void 0&&n.onStart(h,o,a),r=!0},this.itemEnd=function(h){o++,n.onProgress!==void 0&&n.onProgress(h,o,a),o===a&&(r=!1,n.onLoad!==void 0&&n.onLoad())},this.itemError=function(h){n.onError!==void 0&&n.onError(h)},this.resolveURL=function(h){return l?l(h):h},this.setURLModifier=function(h){return l=h,this},this.addHandler=function(h,u){return c.push(h,u),this},this.removeHandler=function(h){let u=c.indexOf(h);return u!==-1&&c.splice(u,2),this},this.getHandler=function(h){for(let u=0,f=c.length;u<f;u+=2){let d=c[u],g=c[u+1];if(d.global&&(d.lastIndex=0),d.test(h))return g}return null},this.abort=function(){return this.abortController.abort(),this.abortController=new AbortController,this}}},of=new Ua,Na=class{constructor(t){this.manager=t!==void 0?t:of,this.crossOrigin="anonymous",this.withCredentials=!1,this.path="",this.resourcePath="",this.requestHeader={}}load(){}loadAsync(t,e){let i=this;return new Promise(function(n,r){i.load(t,n,e,r)})}parse(){}setCrossOrigin(t){return this.crossOrigin=t,this}setWithCredentials(t){return this.withCredentials=t,this}setPath(t){return this.path=t,this}setResourcePath(t){return this.resourcePath=t,this}setRequestHeader(t){return this.requestHeader=t,this}abort(){return this}};Na.DEFAULT_MATERIAL_NAME="__DEFAULT";var Bs=class extends Ee{constructor(t,e=1){super(),this.isLight=!0,this.type="Light",this.color=new _t(t),this.intensity=e}dispose(){}copy(t,e){return super.copy(t,e),this.color.copy(t.color),this.intensity=t.intensity,this}toJSON(t){let e=super.toJSON(t);return e.object.color=this.color.getHex(),e.object.intensity=this.intensity,this.groundColor!==void 0&&(e.object.groundColor=this.groundColor.getHex()),this.distance!==void 0&&(e.object.distance=this.distance),this.angle!==void 0&&(e.object.angle=this.angle),this.decay!==void 0&&(e.object.decay=this.decay),this.penumbra!==void 0&&(e.object.penumbra=this.penumbra),this.shadow!==void 0&&(e.object.shadow=this.shadow.toJSON()),this.target!==void 0&&(e.object.target=this.target.uuid),e}},Kn=class extends Bs{constructor(t,e,i){super(t,i),this.isHemisphereLight=!0,this.type="HemisphereLight",this.position.copy(Ee.DEFAULT_UP),this.updateMatrix(),this.groundColor=new _t(e)}copy(t,e){return super.copy(t,e),this.groundColor.copy(t.groundColor),this}},Vc=new Ut,ld=new T,cd=new T,Fa=class{constructor(t){this.camera=t,this.intensity=1,this.bias=0,this.normalBias=0,this.radius=1,this.blurSamples=8,this.mapSize=new nt(512,512),this.mapType=ki,this.map=null,this.mapPass=null,this.matrix=new Ut,this.autoUpdate=!0,this.needsUpdate=!1,this._frustum=new Sn,this._frameExtents=new nt(1,1),this._viewportCount=1,this._viewports=[new ie(0,0,1,1)]}getViewportCount(){return this._viewportCount}getFrustum(){return this._frustum}updateMatrices(t){let e=this.camera,i=this.matrix;ld.setFromMatrixPosition(t.matrixWorld),e.position.copy(ld),cd.setFromMatrixPosition(t.target.matrixWorld),e.lookAt(cd),e.updateMatrixWorld(),Vc.multiplyMatrices(e.projectionMatrix,e.matrixWorldInverse),this._frustum.setFromProjectionMatrix(Vc,e.coordinateSystem,e.reversedDepth),e.reversedDepth?i.set(.5,0,0,.5,0,.5,0,.5,0,0,1,0,0,0,0,1):i.set(.5,0,0,.5,0,.5,0,.5,0,0,.5,.5,0,0,0,1),i.multiply(Vc)}getViewport(t){return this._viewports[t]}getFrameExtents(){return this._frameExtents}dispose(){this.map&&this.map.dispose(),this.mapPass&&this.mapPass.dispose()}copy(t){return this.camera=t.camera.clone(),this.intensity=t.intensity,this.bias=t.bias,this.radius=t.radius,this.autoUpdate=t.autoUpdate,this.needsUpdate=t.needsUpdate,this.normalBias=t.normalBias,this.blurSamples=t.blurSamples,this.mapSize.copy(t.mapSize),this}clone(){return new this.constructor().copy(this)}toJSON(){let t={};return this.intensity!==1&&(t.intensity=this.intensity),this.bias!==0&&(t.bias=this.bias),this.normalBias!==0&&(t.normalBias=this.normalBias),this.radius!==1&&(t.radius=this.radius),(this.mapSize.x!==512||this.mapSize.y!==512)&&(t.mapSize=this.mapSize.toArray()),t.camera=this.camera.toJSON(!1).object,delete t.camera.matrix,t}};var hd=new Ut,mr=new T,Gc=new T,th=class extends Fa{constructor(){super(new Le(90,1,.5,500)),this.isPointLightShadow=!0,this._frameExtents=new nt(4,2),this._viewportCount=6,this._viewports=[new ie(2,1,1,1),new ie(0,1,1,1),new ie(3,1,1,1),new ie(1,1,1,1),new ie(3,0,1,1),new ie(1,0,1,1)],this._cubeDirections=[new T(1,0,0),new T(-1,0,0),new T(0,0,1),new T(0,0,-1),new T(0,1,0),new T(0,-1,0)],this._cubeUps=[new T(0,1,0),new T(0,1,0),new T(0,1,0),new T(0,1,0),new T(0,0,1),new T(0,0,-1)]}updateMatrices(t,e=0){let i=this.camera,n=this.matrix,r=t.distance||i.far;r!==i.far&&(i.far=r,i.updateProjectionMatrix()),mr.setFromMatrixPosition(t.matrixWorld),i.position.copy(mr),Gc.copy(i.position),Gc.add(this._cubeDirections[e]),i.up.copy(this._cubeUps[e]),i.lookAt(Gc),i.updateMatrixWorld(),n.makeTranslation(-mr.x,-mr.y,-mr.z),hd.multiplyMatrices(i.projectionMatrix,i.matrixWorldInverse),this._frustum.setFromProjectionMatrix(hd,i.coordinateSystem,i.reversedDepth)}},Os=class extends Bs{constructor(t,e,i=0,n=2){super(t,e),this.isPointLight=!0,this.type="PointLight",this.distance=i,this.decay=n,this.shadow=new th}get power(){return this.intensity*4*Math.PI}set power(t){this.intensity=t/(4*Math.PI)}dispose(){this.shadow.dispose()}copy(t,e){return super.copy(t,e),this.distance=t.distance,this.decay=t.decay,this.shadow=t.shadow.clone(),this}},Xi=class extends Rr{constructor(t=-1,e=1,i=1,n=-1,r=.1,o=2e3){super(),this.isOrthographicCamera=!0,this.type="OrthographicCamera",this.zoom=1,this.view=null,this.left=t,this.right=e,this.top=i,this.bottom=n,this.near=r,this.far=o,this.updateProjectionMatrix()}copy(t,e){return super.copy(t,e),this.left=t.left,this.right=t.right,this.top=t.top,this.bottom=t.bottom,this.near=t.near,this.far=t.far,this.zoom=t.zoom,this.view=t.view===null?null:Object.assign({},t.view),this}setViewOffset(t,e,i,n,r,o){this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=t,this.view.fullHeight=e,this.view.offsetX=i,this.view.offsetY=n,this.view.width=r,this.view.height=o,this.updateProjectionMatrix()}clearViewOffset(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()}updateProjectionMatrix(){let t=(this.right-this.left)/(2*this.zoom),e=(this.top-this.bottom)/(2*this.zoom),i=(this.right+this.left)/2,n=(this.top+this.bottom)/2,r=i-t,o=i+t,a=n+e,l=n-e;if(this.view!==null&&this.view.enabled){let c=(this.right-this.left)/this.view.fullWidth/this.zoom,h=(this.top-this.bottom)/this.view.fullHeight/this.zoom;r+=c*this.view.offsetX,o=r+c*this.view.width,a-=h*this.view.offsetY,l=a-h*this.view.height}this.projectionMatrix.makeOrthographic(r,o,a,l,this.near,this.far,this.coordinateSystem,this.reversedDepth),this.projectionMatrixInverse.copy(this.projectionMatrix).invert()}toJSON(t){let e=super.toJSON(t);return e.object.zoom=this.zoom,e.object.left=this.left,e.object.right=this.right,e.object.top=this.top,e.object.bottom=this.bottom,e.object.near=this.near,e.object.far=this.far,this.view!==null&&(e.object.view=Object.assign({},this.view)),e}},eh=class extends Fa{constructor(){super(new Xi(-5,5,5,-5,.5,500)),this.isDirectionalLightShadow=!0}},An=class extends Bs{constructor(t,e){super(t,e),this.isDirectionalLight=!0,this.type="DirectionalLight",this.position.copy(Ee.DEFAULT_UP),this.updateMatrix(),this.target=new Ee,this.shadow=new eh}dispose(){this.shadow.dispose()}copy(t){return super.copy(t),this.target=t.target.clone(),this.shadow=t.shadow.clone(),this}};var ka=class extends Le{constructor(t=[]){super(),this.isArrayCamera=!0,this.isMultiViewCamera=!1,this.cameras=t}};var Mh="\\[\\]\\.:\\/",W0=new RegExp("["+Mh+"]","g"),bh="[^"+Mh+"]",X0="[^"+Mh.replace("\\.","")+"]",q0=/((?:WC+[\/:])*)/.source.replace("WC",bh),Y0=/(WCOD+)?/.source.replace("WCOD",X0),Z0=/(?:\.(WC+)(?:\[(.+)\])?)?/.source.replace("WC",bh),$0=/\.(WC+)(?:\[(.+)\])?/.source.replace("WC",bh),J0=new RegExp("^"+q0+Y0+Z0+$0+"$"),K0=["material","materials","bones","map"],ih=class{constructor(t,e,i){let n=i||Me.parseTrackName(e);this._targetGroup=t,this._bindings=t.subscribe_(e,n)}getValue(t,e){this.bind();let i=this._targetGroup.nCachedObjects_,n=this._bindings[i];n!==void 0&&n.getValue(t,e)}setValue(t,e){let i=this._bindings;for(let n=this._targetGroup.nCachedObjects_,r=i.length;n!==r;++n)i[n].setValue(t,e)}bind(){let t=this._bindings;for(let e=this._targetGroup.nCachedObjects_,i=t.length;e!==i;++e)t[e].bind()}unbind(){let t=this._bindings;for(let e=this._targetGroup.nCachedObjects_,i=t.length;e!==i;++e)t[e].unbind()}},Me=class s{constructor(t,e,i){this.path=e,this.parsedPath=i||s.parseTrackName(e),this.node=s.findNode(t,this.parsedPath.nodeName),this.rootNode=t,this.getValue=this._getValue_unbound,this.setValue=this._setValue_unbound}static create(t,e,i){return t&&t.isAnimationObjectGroup?new s.Composite(t,e,i):new s(t,e,i)}static sanitizeNodeName(t){return t.replace(/\s/g,"_").replace(W0,"")}static parseTrackName(t){let e=J0.exec(t);if(e===null)throw new Error("PropertyBinding: Cannot parse trackName: "+t);let i={nodeName:e[2],objectName:e[3],objectIndex:e[4],propertyName:e[5],propertyIndex:e[6]},n=i.nodeName&&i.nodeName.lastIndexOf(".");if(n!==void 0&&n!==-1){let r=i.nodeName.substring(n+1);K0.indexOf(r)!==-1&&(i.nodeName=i.nodeName.substring(0,n),i.objectName=r)}if(i.propertyName===null||i.propertyName.length===0)throw new Error("PropertyBinding: can not parse propertyName from trackName: "+t);return i}static findNode(t,e){if(e===void 0||e===""||e==="."||e===-1||e===t.name||e===t.uuid)return t;if(t.skeleton){let i=t.skeleton.getBoneByName(e);if(i!==void 0)return i}if(t.children){let i=function(r){for(let o=0;o<r.length;o++){let a=r[o];if(a.name===e||a.uuid===e)return a;let l=i(a.children);if(l)return l}return null},n=i(t.children);if(n)return n}return null}_getValue_unavailable(){}_setValue_unavailable(){}_getValue_direct(t,e){t[e]=this.targetObject[this.propertyName]}_getValue_array(t,e){let i=this.resolvedProperty;for(let n=0,r=i.length;n!==r;++n)t[e++]=i[n]}_getValue_arrayElement(t,e){t[e]=this.resolvedProperty[this.propertyIndex]}_getValue_toArray(t,e){this.resolvedProperty.toArray(t,e)}_setValue_direct(t,e){this.targetObject[this.propertyName]=t[e]}_setValue_direct_setNeedsUpdate(t,e){this.targetObject[this.propertyName]=t[e],this.targetObject.needsUpdate=!0}_setValue_direct_setMatrixWorldNeedsUpdate(t,e){this.targetObject[this.propertyName]=t[e],this.targetObject.matrixWorldNeedsUpdate=!0}_setValue_array(t,e){let i=this.resolvedProperty;for(let n=0,r=i.length;n!==r;++n)i[n]=t[e++]}_setValue_array_setNeedsUpdate(t,e){let i=this.resolvedProperty;for(let n=0,r=i.length;n!==r;++n)i[n]=t[e++];this.targetObject.needsUpdate=!0}_setValue_array_setMatrixWorldNeedsUpdate(t,e){let i=this.resolvedProperty;for(let n=0,r=i.length;n!==r;++n)i[n]=t[e++];this.targetObject.matrixWorldNeedsUpdate=!0}_setValue_arrayElement(t,e){this.resolvedProperty[this.propertyIndex]=t[e]}_setValue_arrayElement_setNeedsUpdate(t,e){this.resolvedProperty[this.propertyIndex]=t[e],this.targetObject.needsUpdate=!0}_setValue_arrayElement_setMatrixWorldNeedsUpdate(t,e){this.resolvedProperty[this.propertyIndex]=t[e],this.targetObject.matrixWorldNeedsUpdate=!0}_setValue_fromArray(t,e){this.resolvedProperty.fromArray(t,e)}_setValue_fromArray_setNeedsUpdate(t,e){this.resolvedProperty.fromArray(t,e),this.targetObject.needsUpdate=!0}_setValue_fromArray_setMatrixWorldNeedsUpdate(t,e){this.resolvedProperty.fromArray(t,e),this.targetObject.matrixWorldNeedsUpdate=!0}_getValue_unbound(t,e){this.bind(),this.getValue(t,e)}_setValue_unbound(t,e){this.bind(),this.setValue(t,e)}bind(){let t=this.node,e=this.parsedPath,i=e.objectName,n=e.propertyName,r=e.propertyIndex;if(t||(t=s.findNode(this.rootNode,e.nodeName),this.node=t),this.getValue=this._getValue_unavailable,this.setValue=this._setValue_unavailable,!t){console.warn("THREE.PropertyBinding: No target node found for track: "+this.path+".");return}if(i){let c=e.objectIndex;switch(i){case"materials":if(!t.material){console.error("THREE.PropertyBinding: Can not bind to material as node does not have a material.",this);return}if(!t.material.materials){console.error("THREE.PropertyBinding: Can not bind to material.materials as node.material does not have a materials array.",this);return}t=t.material.materials;break;case"bones":if(!t.skeleton){console.error("THREE.PropertyBinding: Can not bind to bones as node does not have a skeleton.",this);return}t=t.skeleton.bones;for(let h=0;h<t.length;h++)if(t[h].name===c){c=h;break}break;case"map":if("map"in t){t=t.map;break}if(!t.material){console.error("THREE.PropertyBinding: Can not bind to material as node does not have a material.",this);return}if(!t.material.map){console.error("THREE.PropertyBinding: Can not bind to material.map as node.material does not have a map.",this);return}t=t.material.map;break;default:if(t[i]===void 0){console.error("THREE.PropertyBinding: Can not bind to objectName of node undefined.",this);return}t=t[i]}if(c!==void 0){if(t[c]===void 0){console.error("THREE.PropertyBinding: Trying to bind to objectIndex of objectName, but is undefined.",this,t);return}t=t[c]}}let o=t[n];if(o===void 0){let c=e.nodeName;console.error("THREE.PropertyBinding: Trying to update property for track: "+c+"."+n+" but it wasn't found.",t);return}let a=this.Versioning.None;this.targetObject=t,t.isMaterial===!0?a=this.Versioning.NeedsUpdate:t.isObject3D===!0&&(a=this.Versioning.MatrixWorldNeedsUpdate);let l=this.BindingType.Direct;if(r!==void 0){if(n==="morphTargetInfluences"){if(!t.geometry){console.error("THREE.PropertyBinding: Can not bind to morphTargetInfluences because node does not have a geometry.",this);return}if(!t.geometry.morphAttributes){console.error("THREE.PropertyBinding: Can not bind to morphTargetInfluences because node does not have a geometry.morphAttributes.",this);return}t.morphTargetDictionary[r]!==void 0&&(r=t.morphTargetDictionary[r])}l=this.BindingType.ArrayElement,this.resolvedProperty=o,this.propertyIndex=r}else o.fromArray!==void 0&&o.toArray!==void 0?(l=this.BindingType.HasFromToArray,this.resolvedProperty=o):Array.isArray(o)?(l=this.BindingType.EntireArray,this.resolvedProperty=o):this.propertyName=n;this.getValue=this.GetterByBindingType[l],this.setValue=this.SetterByBindingTypeAndVersioning[l][a]}unbind(){this.node=null,this.getValue=this._getValue_unbound,this.setValue=this._setValue_unbound}};Me.Composite=ih;Me.prototype.BindingType={Direct:0,EntireArray:1,ArrayElement:2,HasFromToArray:3};Me.prototype.Versioning={None:0,NeedsUpdate:1,MatrixWorldNeedsUpdate:2};Me.prototype.GetterByBindingType=[Me.prototype._getValue_direct,Me.prototype._getValue_array,Me.prototype._getValue_arrayElement,Me.prototype._getValue_toArray];Me.prototype.SetterByBindingTypeAndVersioning=[[Me.prototype._setValue_direct,Me.prototype._setValue_direct_setNeedsUpdate,Me.prototype._setValue_direct_setMatrixWorldNeedsUpdate],[Me.prototype._setValue_array,Me.prototype._setValue_array_setNeedsUpdate,Me.prototype._setValue_array_setMatrixWorldNeedsUpdate],[Me.prototype._setValue_arrayElement,Me.prototype._setValue_arrayElement_setNeedsUpdate,Me.prototype._setValue_arrayElement_setMatrixWorldNeedsUpdate],[Me.prototype._setValue_fromArray,Me.prototype._setValue_fromArray_setNeedsUpdate,Me.prototype._setValue_fromArray_setMatrixWorldNeedsUpdate]];var Ev=new Float32Array(1);function wh(s,t,e,i){let n=j0(i);switch(e){case uh:return s*t;case tl:return s*t/n.components*n.byteLength;case el:return s*t/n.components*n.byteLength;case fh:return s*t*2/n.components*n.byteLength;case il:return s*t*2/n.components*n.byteLength;case dh:return s*t*3/n.components*n.byteLength;case gi:return s*t*4/n.components*n.byteLength;case nl:return s*t*4/n.components*n.byteLength;case oo:case ao:return Math.floor((s+3)/4)*Math.floor((t+3)/4)*8;case lo:case co:return Math.floor((s+3)/4)*Math.floor((t+3)/4)*16;case rl:case al:return Math.max(s,16)*Math.max(t,8)/4;case sl:case ol:return Math.max(s,8)*Math.max(t,8)/2;case ll:case cl:return Math.floor((s+3)/4)*Math.floor((t+3)/4)*8;case hl:return Math.floor((s+3)/4)*Math.floor((t+3)/4)*16;case ul:return Math.floor((s+3)/4)*Math.floor((t+3)/4)*16;case dl:return Math.floor((s+4)/5)*Math.floor((t+3)/4)*16;case fl:return Math.floor((s+4)/5)*Math.floor((t+4)/5)*16;case pl:return Math.floor((s+5)/6)*Math.floor((t+4)/5)*16;case ml:return Math.floor((s+5)/6)*Math.floor((t+5)/6)*16;case gl:return Math.floor((s+7)/8)*Math.floor((t+4)/5)*16;case xl:return Math.floor((s+7)/8)*Math.floor((t+5)/6)*16;case _l:return Math.floor((s+7)/8)*Math.floor((t+7)/8)*16;case yl:return Math.floor((s+9)/10)*Math.floor((t+4)/5)*16;case vl:return Math.floor((s+9)/10)*Math.floor((t+5)/6)*16;case Ml:return Math.floor((s+9)/10)*Math.floor((t+7)/8)*16;case bl:return Math.floor((s+9)/10)*Math.floor((t+9)/10)*16;case wl:return Math.floor((s+11)/12)*Math.floor((t+9)/10)*16;case Sl:return Math.floor((s+11)/12)*Math.floor((t+11)/12)*16;case El:case Tl:case Al:return Math.ceil(s/4)*Math.ceil(t/4)*16;case Rl:case Cl:return Math.ceil(s/4)*Math.ceil(t/4)*8;case Il:case Pl:return Math.ceil(s/4)*Math.ceil(t/4)*16}throw new Error(`Unable to determine texture byte length for ${e} format.`)}function j0(s){switch(s){case ki:case ah:return{byteLength:1,components:1};case zs:case lh:case Hs:return{byteLength:2,components:1};case ja:case Qa:return{byteLength:2,components:4};case Cn:case Ka:case Si:return{byteLength:4,components:1};case ch:case hh:return{byteLength:4,components:3}}throw new Error(`Unknown texture type ${s}.`)}typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("register",{detail:{revision:"180"}}));typeof window<"u"&&(window.__THREE__?console.warn("WARNING: Multiple instances of Three.js being imported."):window.__THREE__="180");function If(){let s=null,t=!1,e=null,i=null;function n(r,o){e(r,o),i=s.requestAnimationFrame(n)}return{start:function(){t!==!0&&e!==null&&(i=s.requestAnimationFrame(n),t=!0)},stop:function(){s.cancelAnimationFrame(i),t=!1},setAnimationLoop:function(r){e=r},setContext:function(r){s=r}}}function nm(s){let t=new WeakMap;function e(a,l){let c=a.array,h=a.usage,u=c.byteLength,f=s.createBuffer();s.bindBuffer(l,f),s.bufferData(l,c,h),a.onUploadCallback();let d;if(c instanceof Float32Array)d=s.FLOAT;else if(typeof Float16Array<"u"&&c instanceof Float16Array)d=s.HALF_FLOAT;else if(c instanceof Uint16Array)a.isFloat16BufferAttribute?d=s.HALF_FLOAT:d=s.UNSIGNED_SHORT;else if(c instanceof Int16Array)d=s.SHORT;else if(c instanceof Uint32Array)d=s.UNSIGNED_INT;else if(c instanceof Int32Array)d=s.INT;else if(c instanceof Int8Array)d=s.BYTE;else if(c instanceof Uint8Array)d=s.UNSIGNED_BYTE;else if(c instanceof Uint8ClampedArray)d=s.UNSIGNED_BYTE;else throw new Error("THREE.WebGLAttributes: Unsupported buffer data format: "+c);return{buffer:f,type:d,bytesPerElement:c.BYTES_PER_ELEMENT,version:a.version,size:u}}function i(a,l,c){let h=l.array,u=l.updateRanges;if(s.bindBuffer(c,a),u.length===0)s.bufferSubData(c,0,h);else{u.sort((d,g)=>d.start-g.start);let f=0;for(let d=1;d<u.length;d++){let g=u[f],x=u[d];x.start<=g.start+g.count+1?g.count=Math.max(g.count,x.start+x.count-g.start):(++f,u[f]=x)}u.length=f+1;for(let d=0,g=u.length;d<g;d++){let x=u[d];s.bufferSubData(c,x.start*h.BYTES_PER_ELEMENT,h,x.start,x.count)}l.clearUpdateRanges()}l.onUploadCallback()}function n(a){return a.isInterleavedBufferAttribute&&(a=a.data),t.get(a)}function r(a){a.isInterleavedBufferAttribute&&(a=a.data);let l=t.get(a);l&&(s.deleteBuffer(l.buffer),t.delete(a))}function o(a,l){if(a.isInterleavedBufferAttribute&&(a=a.data),a.isGLBufferAttribute){let h=t.get(a);(!h||h.version<a.version)&&t.set(a,{buffer:a.buffer,type:a.type,bytesPerElement:a.elementSize,version:a.version});return}let c=t.get(a);if(c===void 0)t.set(a,e(a,l));else if(c.version<a.version){if(c.size!==a.array.byteLength)throw new Error("THREE.WebGLAttributes: The size of the buffer attribute's array buffer does not match the original size. Resizing buffer attributes is not supported.");i(c.buffer,a,l),c.version=a.version}}return{get:n,remove:r,update:o}}var sm=`#ifdef USE_ALPHAHASH
	if ( diffuseColor.a < getAlphaHashThreshold( vPosition ) ) discard;
#endif`,rm=`#ifdef USE_ALPHAHASH
	const float ALPHA_HASH_SCALE = 0.05;
	float hash2D( vec2 value ) {
		return fract( 1.0e4 * sin( 17.0 * value.x + 0.1 * value.y ) * ( 0.1 + abs( sin( 13.0 * value.y + value.x ) ) ) );
	}
	float hash3D( vec3 value ) {
		return hash2D( vec2( hash2D( value.xy ), value.z ) );
	}
	float getAlphaHashThreshold( vec3 position ) {
		float maxDeriv = max(
			length( dFdx( position.xyz ) ),
			length( dFdy( position.xyz ) )
		);
		float pixScale = 1.0 / ( ALPHA_HASH_SCALE * maxDeriv );
		vec2 pixScales = vec2(
			exp2( floor( log2( pixScale ) ) ),
			exp2( ceil( log2( pixScale ) ) )
		);
		vec2 alpha = vec2(
			hash3D( floor( pixScales.x * position.xyz ) ),
			hash3D( floor( pixScales.y * position.xyz ) )
		);
		float lerpFactor = fract( log2( pixScale ) );
		float x = ( 1.0 - lerpFactor ) * alpha.x + lerpFactor * alpha.y;
		float a = min( lerpFactor, 1.0 - lerpFactor );
		vec3 cases = vec3(
			x * x / ( 2.0 * a * ( 1.0 - a ) ),
			( x - 0.5 * a ) / ( 1.0 - a ),
			1.0 - ( ( 1.0 - x ) * ( 1.0 - x ) / ( 2.0 * a * ( 1.0 - a ) ) )
		);
		float threshold = ( x < ( 1.0 - a ) )
			? ( ( x < a ) ? cases.x : cases.y )
			: cases.z;
		return clamp( threshold , 1.0e-6, 1.0 );
	}
#endif`,om=`#ifdef USE_ALPHAMAP
	diffuseColor.a *= texture2D( alphaMap, vAlphaMapUv ).g;
#endif`,am=`#ifdef USE_ALPHAMAP
	uniform sampler2D alphaMap;
#endif`,lm=`#ifdef USE_ALPHATEST
	#ifdef ALPHA_TO_COVERAGE
	diffuseColor.a = smoothstep( alphaTest, alphaTest + fwidth( diffuseColor.a ), diffuseColor.a );
	if ( diffuseColor.a == 0.0 ) discard;
	#else
	if ( diffuseColor.a < alphaTest ) discard;
	#endif
#endif`,cm=`#ifdef USE_ALPHATEST
	uniform float alphaTest;
#endif`,hm=`#ifdef USE_AOMAP
	float ambientOcclusion = ( texture2D( aoMap, vAoMapUv ).r - 1.0 ) * aoMapIntensity + 1.0;
	reflectedLight.indirectDiffuse *= ambientOcclusion;
	#if defined( USE_CLEARCOAT ) 
		clearcoatSpecularIndirect *= ambientOcclusion;
	#endif
	#if defined( USE_SHEEN ) 
		sheenSpecularIndirect *= ambientOcclusion;
	#endif
	#if defined( USE_ENVMAP ) && defined( STANDARD )
		float dotNV = saturate( dot( geometryNormal, geometryViewDir ) );
		reflectedLight.indirectSpecular *= computeSpecularOcclusion( dotNV, ambientOcclusion, material.roughness );
	#endif
#endif`,um=`#ifdef USE_AOMAP
	uniform sampler2D aoMap;
	uniform float aoMapIntensity;
#endif`,dm=`#ifdef USE_BATCHING
	#if ! defined( GL_ANGLE_multi_draw )
	#define gl_DrawID _gl_DrawID
	uniform int _gl_DrawID;
	#endif
	uniform highp sampler2D batchingTexture;
	uniform highp usampler2D batchingIdTexture;
	mat4 getBatchingMatrix( const in float i ) {
		int size = textureSize( batchingTexture, 0 ).x;
		int j = int( i ) * 4;
		int x = j % size;
		int y = j / size;
		vec4 v1 = texelFetch( batchingTexture, ivec2( x, y ), 0 );
		vec4 v2 = texelFetch( batchingTexture, ivec2( x + 1, y ), 0 );
		vec4 v3 = texelFetch( batchingTexture, ivec2( x + 2, y ), 0 );
		vec4 v4 = texelFetch( batchingTexture, ivec2( x + 3, y ), 0 );
		return mat4( v1, v2, v3, v4 );
	}
	float getIndirectIndex( const in int i ) {
		int size = textureSize( batchingIdTexture, 0 ).x;
		int x = i % size;
		int y = i / size;
		return float( texelFetch( batchingIdTexture, ivec2( x, y ), 0 ).r );
	}
#endif
#ifdef USE_BATCHING_COLOR
	uniform sampler2D batchingColorTexture;
	vec3 getBatchingColor( const in float i ) {
		int size = textureSize( batchingColorTexture, 0 ).x;
		int j = int( i );
		int x = j % size;
		int y = j / size;
		return texelFetch( batchingColorTexture, ivec2( x, y ), 0 ).rgb;
	}
#endif`,fm=`#ifdef USE_BATCHING
	mat4 batchingMatrix = getBatchingMatrix( getIndirectIndex( gl_DrawID ) );
#endif`,pm=`vec3 transformed = vec3( position );
#ifdef USE_ALPHAHASH
	vPosition = vec3( position );
#endif`,mm=`vec3 objectNormal = vec3( normal );
#ifdef USE_TANGENT
	vec3 objectTangent = vec3( tangent.xyz );
#endif`,gm=`float G_BlinnPhong_Implicit( ) {
	return 0.25;
}
float D_BlinnPhong( const in float shininess, const in float dotNH ) {
	return RECIPROCAL_PI * ( shininess * 0.5 + 1.0 ) * pow( dotNH, shininess );
}
vec3 BRDF_BlinnPhong( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in vec3 specularColor, const in float shininess ) {
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNH = saturate( dot( normal, halfDir ) );
	float dotVH = saturate( dot( viewDir, halfDir ) );
	vec3 F = F_Schlick( specularColor, 1.0, dotVH );
	float G = G_BlinnPhong_Implicit( );
	float D = D_BlinnPhong( shininess, dotNH );
	return F * ( G * D );
} // validated`,xm=`#ifdef USE_IRIDESCENCE
	const mat3 XYZ_TO_REC709 = mat3(
		 3.2404542, -0.9692660,  0.0556434,
		-1.5371385,  1.8760108, -0.2040259,
		-0.4985314,  0.0415560,  1.0572252
	);
	vec3 Fresnel0ToIor( vec3 fresnel0 ) {
		vec3 sqrtF0 = sqrt( fresnel0 );
		return ( vec3( 1.0 ) + sqrtF0 ) / ( vec3( 1.0 ) - sqrtF0 );
	}
	vec3 IorToFresnel0( vec3 transmittedIor, float incidentIor ) {
		return pow2( ( transmittedIor - vec3( incidentIor ) ) / ( transmittedIor + vec3( incidentIor ) ) );
	}
	float IorToFresnel0( float transmittedIor, float incidentIor ) {
		return pow2( ( transmittedIor - incidentIor ) / ( transmittedIor + incidentIor ));
	}
	vec3 evalSensitivity( float OPD, vec3 shift ) {
		float phase = 2.0 * PI * OPD * 1.0e-9;
		vec3 val = vec3( 5.4856e-13, 4.4201e-13, 5.2481e-13 );
		vec3 pos = vec3( 1.6810e+06, 1.7953e+06, 2.2084e+06 );
		vec3 var = vec3( 4.3278e+09, 9.3046e+09, 6.6121e+09 );
		vec3 xyz = val * sqrt( 2.0 * PI * var ) * cos( pos * phase + shift ) * exp( - pow2( phase ) * var );
		xyz.x += 9.7470e-14 * sqrt( 2.0 * PI * 4.5282e+09 ) * cos( 2.2399e+06 * phase + shift[ 0 ] ) * exp( - 4.5282e+09 * pow2( phase ) );
		xyz /= 1.0685e-7;
		vec3 rgb = XYZ_TO_REC709 * xyz;
		return rgb;
	}
	vec3 evalIridescence( float outsideIOR, float eta2, float cosTheta1, float thinFilmThickness, vec3 baseF0 ) {
		vec3 I;
		float iridescenceIOR = mix( outsideIOR, eta2, smoothstep( 0.0, 0.03, thinFilmThickness ) );
		float sinTheta2Sq = pow2( outsideIOR / iridescenceIOR ) * ( 1.0 - pow2( cosTheta1 ) );
		float cosTheta2Sq = 1.0 - sinTheta2Sq;
		if ( cosTheta2Sq < 0.0 ) {
			return vec3( 1.0 );
		}
		float cosTheta2 = sqrt( cosTheta2Sq );
		float R0 = IorToFresnel0( iridescenceIOR, outsideIOR );
		float R12 = F_Schlick( R0, 1.0, cosTheta1 );
		float T121 = 1.0 - R12;
		float phi12 = 0.0;
		if ( iridescenceIOR < outsideIOR ) phi12 = PI;
		float phi21 = PI - phi12;
		vec3 baseIOR = Fresnel0ToIor( clamp( baseF0, 0.0, 0.9999 ) );		vec3 R1 = IorToFresnel0( baseIOR, iridescenceIOR );
		vec3 R23 = F_Schlick( R1, 1.0, cosTheta2 );
		vec3 phi23 = vec3( 0.0 );
		if ( baseIOR[ 0 ] < iridescenceIOR ) phi23[ 0 ] = PI;
		if ( baseIOR[ 1 ] < iridescenceIOR ) phi23[ 1 ] = PI;
		if ( baseIOR[ 2 ] < iridescenceIOR ) phi23[ 2 ] = PI;
		float OPD = 2.0 * iridescenceIOR * thinFilmThickness * cosTheta2;
		vec3 phi = vec3( phi21 ) + phi23;
		vec3 R123 = clamp( R12 * R23, 1e-5, 0.9999 );
		vec3 r123 = sqrt( R123 );
		vec3 Rs = pow2( T121 ) * R23 / ( vec3( 1.0 ) - R123 );
		vec3 C0 = R12 + Rs;
		I = C0;
		vec3 Cm = Rs - T121;
		for ( int m = 1; m <= 2; ++ m ) {
			Cm *= r123;
			vec3 Sm = 2.0 * evalSensitivity( float( m ) * OPD, float( m ) * phi );
			I += Cm * Sm;
		}
		return max( I, vec3( 0.0 ) );
	}
#endif`,_m=`#ifdef USE_BUMPMAP
	uniform sampler2D bumpMap;
	uniform float bumpScale;
	vec2 dHdxy_fwd() {
		vec2 dSTdx = dFdx( vBumpMapUv );
		vec2 dSTdy = dFdy( vBumpMapUv );
		float Hll = bumpScale * texture2D( bumpMap, vBumpMapUv ).x;
		float dBx = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdx ).x - Hll;
		float dBy = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdy ).x - Hll;
		return vec2( dBx, dBy );
	}
	vec3 perturbNormalArb( vec3 surf_pos, vec3 surf_norm, vec2 dHdxy, float faceDirection ) {
		vec3 vSigmaX = normalize( dFdx( surf_pos.xyz ) );
		vec3 vSigmaY = normalize( dFdy( surf_pos.xyz ) );
		vec3 vN = surf_norm;
		vec3 R1 = cross( vSigmaY, vN );
		vec3 R2 = cross( vN, vSigmaX );
		float fDet = dot( vSigmaX, R1 ) * faceDirection;
		vec3 vGrad = sign( fDet ) * ( dHdxy.x * R1 + dHdxy.y * R2 );
		return normalize( abs( fDet ) * surf_norm - vGrad );
	}
#endif`,ym=`#if NUM_CLIPPING_PLANES > 0
	vec4 plane;
	#ifdef ALPHA_TO_COVERAGE
		float distanceToPlane, distanceGradient;
		float clipOpacity = 1.0;
		#pragma unroll_loop_start
		for ( int i = 0; i < UNION_CLIPPING_PLANES; i ++ ) {
			plane = clippingPlanes[ i ];
			distanceToPlane = - dot( vClipPosition, plane.xyz ) + plane.w;
			distanceGradient = fwidth( distanceToPlane ) / 2.0;
			clipOpacity *= smoothstep( - distanceGradient, distanceGradient, distanceToPlane );
			if ( clipOpacity == 0.0 ) discard;
		}
		#pragma unroll_loop_end
		#if UNION_CLIPPING_PLANES < NUM_CLIPPING_PLANES
			float unionClipOpacity = 1.0;
			#pragma unroll_loop_start
			for ( int i = UNION_CLIPPING_PLANES; i < NUM_CLIPPING_PLANES; i ++ ) {
				plane = clippingPlanes[ i ];
				distanceToPlane = - dot( vClipPosition, plane.xyz ) + plane.w;
				distanceGradient = fwidth( distanceToPlane ) / 2.0;
				unionClipOpacity *= 1.0 - smoothstep( - distanceGradient, distanceGradient, distanceToPlane );
			}
			#pragma unroll_loop_end
			clipOpacity *= 1.0 - unionClipOpacity;
		#endif
		diffuseColor.a *= clipOpacity;
		if ( diffuseColor.a == 0.0 ) discard;
	#else
		#pragma unroll_loop_start
		for ( int i = 0; i < UNION_CLIPPING_PLANES; i ++ ) {
			plane = clippingPlanes[ i ];
			if ( dot( vClipPosition, plane.xyz ) > plane.w ) discard;
		}
		#pragma unroll_loop_end
		#if UNION_CLIPPING_PLANES < NUM_CLIPPING_PLANES
			bool clipped = true;
			#pragma unroll_loop_start
			for ( int i = UNION_CLIPPING_PLANES; i < NUM_CLIPPING_PLANES; i ++ ) {
				plane = clippingPlanes[ i ];
				clipped = ( dot( vClipPosition, plane.xyz ) > plane.w ) && clipped;
			}
			#pragma unroll_loop_end
			if ( clipped ) discard;
		#endif
	#endif
#endif`,vm=`#if NUM_CLIPPING_PLANES > 0
	varying vec3 vClipPosition;
	uniform vec4 clippingPlanes[ NUM_CLIPPING_PLANES ];
#endif`,Mm=`#if NUM_CLIPPING_PLANES > 0
	varying vec3 vClipPosition;
#endif`,bm=`#if NUM_CLIPPING_PLANES > 0
	vClipPosition = - mvPosition.xyz;
#endif`,wm=`#if defined( USE_COLOR_ALPHA )
	diffuseColor *= vColor;
#elif defined( USE_COLOR )
	diffuseColor.rgb *= vColor;
#endif`,Sm=`#if defined( USE_COLOR_ALPHA )
	varying vec4 vColor;
#elif defined( USE_COLOR )
	varying vec3 vColor;
#endif`,Em=`#if defined( USE_COLOR_ALPHA )
	varying vec4 vColor;
#elif defined( USE_COLOR ) || defined( USE_INSTANCING_COLOR ) || defined( USE_BATCHING_COLOR )
	varying vec3 vColor;
#endif`,Tm=`#if defined( USE_COLOR_ALPHA )
	vColor = vec4( 1.0 );
#elif defined( USE_COLOR ) || defined( USE_INSTANCING_COLOR ) || defined( USE_BATCHING_COLOR )
	vColor = vec3( 1.0 );
#endif
#ifdef USE_COLOR
	vColor *= color;
#endif
#ifdef USE_INSTANCING_COLOR
	vColor.xyz *= instanceColor.xyz;
#endif
#ifdef USE_BATCHING_COLOR
	vec3 batchingColor = getBatchingColor( getIndirectIndex( gl_DrawID ) );
	vColor.xyz *= batchingColor.xyz;
#endif`,Am=`#define PI 3.141592653589793
#define PI2 6.283185307179586
#define PI_HALF 1.5707963267948966
#define RECIPROCAL_PI 0.3183098861837907
#define RECIPROCAL_PI2 0.15915494309189535
#define EPSILON 1e-6
#ifndef saturate
#define saturate( a ) clamp( a, 0.0, 1.0 )
#endif
#define whiteComplement( a ) ( 1.0 - saturate( a ) )
float pow2( const in float x ) { return x*x; }
vec3 pow2( const in vec3 x ) { return x*x; }
float pow3( const in float x ) { return x*x*x; }
float pow4( const in float x ) { float x2 = x*x; return x2*x2; }
float max3( const in vec3 v ) { return max( max( v.x, v.y ), v.z ); }
float average( const in vec3 v ) { return dot( v, vec3( 0.3333333 ) ); }
highp float rand( const in vec2 uv ) {
	const highp float a = 12.9898, b = 78.233, c = 43758.5453;
	highp float dt = dot( uv.xy, vec2( a,b ) ), sn = mod( dt, PI );
	return fract( sin( sn ) * c );
}
#ifdef HIGH_PRECISION
	float precisionSafeLength( vec3 v ) { return length( v ); }
#else
	float precisionSafeLength( vec3 v ) {
		float maxComponent = max3( abs( v ) );
		return length( v / maxComponent ) * maxComponent;
	}
#endif
struct IncidentLight {
	vec3 color;
	vec3 direction;
	bool visible;
};
struct ReflectedLight {
	vec3 directDiffuse;
	vec3 directSpecular;
	vec3 indirectDiffuse;
	vec3 indirectSpecular;
};
#ifdef USE_ALPHAHASH
	varying vec3 vPosition;
#endif
vec3 transformDirection( in vec3 dir, in mat4 matrix ) {
	return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );
}
vec3 inverseTransformDirection( in vec3 dir, in mat4 matrix ) {
	return normalize( ( vec4( dir, 0.0 ) * matrix ).xyz );
}
mat3 transposeMat3( const in mat3 m ) {
	mat3 tmp;
	tmp[ 0 ] = vec3( m[ 0 ].x, m[ 1 ].x, m[ 2 ].x );
	tmp[ 1 ] = vec3( m[ 0 ].y, m[ 1 ].y, m[ 2 ].y );
	tmp[ 2 ] = vec3( m[ 0 ].z, m[ 1 ].z, m[ 2 ].z );
	return tmp;
}
bool isPerspectiveMatrix( mat4 m ) {
	return m[ 2 ][ 3 ] == - 1.0;
}
vec2 equirectUv( in vec3 dir ) {
	float u = atan( dir.z, dir.x ) * RECIPROCAL_PI2 + 0.5;
	float v = asin( clamp( dir.y, - 1.0, 1.0 ) ) * RECIPROCAL_PI + 0.5;
	return vec2( u, v );
}
vec3 BRDF_Lambert( const in vec3 diffuseColor ) {
	return RECIPROCAL_PI * diffuseColor;
}
vec3 F_Schlick( const in vec3 f0, const in float f90, const in float dotVH ) {
	float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );
	return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );
}
float F_Schlick( const in float f0, const in float f90, const in float dotVH ) {
	float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );
	return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );
} // validated`,Rm=`#ifdef ENVMAP_TYPE_CUBE_UV
	#define cubeUV_minMipLevel 4.0
	#define cubeUV_minTileSize 16.0
	float getFace( vec3 direction ) {
		vec3 absDirection = abs( direction );
		float face = - 1.0;
		if ( absDirection.x > absDirection.z ) {
			if ( absDirection.x > absDirection.y )
				face = direction.x > 0.0 ? 0.0 : 3.0;
			else
				face = direction.y > 0.0 ? 1.0 : 4.0;
		} else {
			if ( absDirection.z > absDirection.y )
				face = direction.z > 0.0 ? 2.0 : 5.0;
			else
				face = direction.y > 0.0 ? 1.0 : 4.0;
		}
		return face;
	}
	vec2 getUV( vec3 direction, float face ) {
		vec2 uv;
		if ( face == 0.0 ) {
			uv = vec2( direction.z, direction.y ) / abs( direction.x );
		} else if ( face == 1.0 ) {
			uv = vec2( - direction.x, - direction.z ) / abs( direction.y );
		} else if ( face == 2.0 ) {
			uv = vec2( - direction.x, direction.y ) / abs( direction.z );
		} else if ( face == 3.0 ) {
			uv = vec2( - direction.z, direction.y ) / abs( direction.x );
		} else if ( face == 4.0 ) {
			uv = vec2( - direction.x, direction.z ) / abs( direction.y );
		} else {
			uv = vec2( direction.x, direction.y ) / abs( direction.z );
		}
		return 0.5 * ( uv + 1.0 );
	}
	vec3 bilinearCubeUV( sampler2D envMap, vec3 direction, float mipInt ) {
		float face = getFace( direction );
		float filterInt = max( cubeUV_minMipLevel - mipInt, 0.0 );
		mipInt = max( mipInt, cubeUV_minMipLevel );
		float faceSize = exp2( mipInt );
		highp vec2 uv = getUV( direction, face ) * ( faceSize - 2.0 ) + 1.0;
		if ( face > 2.0 ) {
			uv.y += faceSize;
			face -= 3.0;
		}
		uv.x += face * faceSize;
		uv.x += filterInt * 3.0 * cubeUV_minTileSize;
		uv.y += 4.0 * ( exp2( CUBEUV_MAX_MIP ) - faceSize );
		uv.x *= CUBEUV_TEXEL_WIDTH;
		uv.y *= CUBEUV_TEXEL_HEIGHT;
		#ifdef texture2DGradEXT
			return texture2DGradEXT( envMap, uv, vec2( 0.0 ), vec2( 0.0 ) ).rgb;
		#else
			return texture2D( envMap, uv ).rgb;
		#endif
	}
	#define cubeUV_r0 1.0
	#define cubeUV_m0 - 2.0
	#define cubeUV_r1 0.8
	#define cubeUV_m1 - 1.0
	#define cubeUV_r4 0.4
	#define cubeUV_m4 2.0
	#define cubeUV_r5 0.305
	#define cubeUV_m5 3.0
	#define cubeUV_r6 0.21
	#define cubeUV_m6 4.0
	float roughnessToMip( float roughness ) {
		float mip = 0.0;
		if ( roughness >= cubeUV_r1 ) {
			mip = ( cubeUV_r0 - roughness ) * ( cubeUV_m1 - cubeUV_m0 ) / ( cubeUV_r0 - cubeUV_r1 ) + cubeUV_m0;
		} else if ( roughness >= cubeUV_r4 ) {
			mip = ( cubeUV_r1 - roughness ) * ( cubeUV_m4 - cubeUV_m1 ) / ( cubeUV_r1 - cubeUV_r4 ) + cubeUV_m1;
		} else if ( roughness >= cubeUV_r5 ) {
			mip = ( cubeUV_r4 - roughness ) * ( cubeUV_m5 - cubeUV_m4 ) / ( cubeUV_r4 - cubeUV_r5 ) + cubeUV_m4;
		} else if ( roughness >= cubeUV_r6 ) {
			mip = ( cubeUV_r5 - roughness ) * ( cubeUV_m6 - cubeUV_m5 ) / ( cubeUV_r5 - cubeUV_r6 ) + cubeUV_m5;
		} else {
			mip = - 2.0 * log2( 1.16 * roughness );		}
		return mip;
	}
	vec4 textureCubeUV( sampler2D envMap, vec3 sampleDir, float roughness ) {
		float mip = clamp( roughnessToMip( roughness ), cubeUV_m0, CUBEUV_MAX_MIP );
		float mipF = fract( mip );
		float mipInt = floor( mip );
		vec3 color0 = bilinearCubeUV( envMap, sampleDir, mipInt );
		if ( mipF == 0.0 ) {
			return vec4( color0, 1.0 );
		} else {
			vec3 color1 = bilinearCubeUV( envMap, sampleDir, mipInt + 1.0 );
			return vec4( mix( color0, color1, mipF ), 1.0 );
		}
	}
#endif`,Cm=`vec3 transformedNormal = objectNormal;
#ifdef USE_TANGENT
	vec3 transformedTangent = objectTangent;
#endif
#ifdef USE_BATCHING
	mat3 bm = mat3( batchingMatrix );
	transformedNormal /= vec3( dot( bm[ 0 ], bm[ 0 ] ), dot( bm[ 1 ], bm[ 1 ] ), dot( bm[ 2 ], bm[ 2 ] ) );
	transformedNormal = bm * transformedNormal;
	#ifdef USE_TANGENT
		transformedTangent = bm * transformedTangent;
	#endif
#endif
#ifdef USE_INSTANCING
	mat3 im = mat3( instanceMatrix );
	transformedNormal /= vec3( dot( im[ 0 ], im[ 0 ] ), dot( im[ 1 ], im[ 1 ] ), dot( im[ 2 ], im[ 2 ] ) );
	transformedNormal = im * transformedNormal;
	#ifdef USE_TANGENT
		transformedTangent = im * transformedTangent;
	#endif
#endif
transformedNormal = normalMatrix * transformedNormal;
#ifdef FLIP_SIDED
	transformedNormal = - transformedNormal;
#endif
#ifdef USE_TANGENT
	transformedTangent = ( modelViewMatrix * vec4( transformedTangent, 0.0 ) ).xyz;
	#ifdef FLIP_SIDED
		transformedTangent = - transformedTangent;
	#endif
#endif`,Im=`#ifdef USE_DISPLACEMENTMAP
	uniform sampler2D displacementMap;
	uniform float displacementScale;
	uniform float displacementBias;
#endif`,Pm=`#ifdef USE_DISPLACEMENTMAP
	transformed += normalize( objectNormal ) * ( texture2D( displacementMap, vDisplacementMapUv ).x * displacementScale + displacementBias );
#endif`,Lm=`#ifdef USE_EMISSIVEMAP
	vec4 emissiveColor = texture2D( emissiveMap, vEmissiveMapUv );
	#ifdef DECODE_VIDEO_TEXTURE_EMISSIVE
		emissiveColor = sRGBTransferEOTF( emissiveColor );
	#endif
	totalEmissiveRadiance *= emissiveColor.rgb;
#endif`,Dm=`#ifdef USE_EMISSIVEMAP
	uniform sampler2D emissiveMap;
#endif`,Um="gl_FragColor = linearToOutputTexel( gl_FragColor );",Nm=`vec4 LinearTransferOETF( in vec4 value ) {
	return value;
}
vec4 sRGBTransferEOTF( in vec4 value ) {
	return vec4( mix( pow( value.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), value.rgb * 0.0773993808, vec3( lessThanEqual( value.rgb, vec3( 0.04045 ) ) ) ), value.a );
}
vec4 sRGBTransferOETF( in vec4 value ) {
	return vec4( mix( pow( value.rgb, vec3( 0.41666 ) ) * 1.055 - vec3( 0.055 ), value.rgb * 12.92, vec3( lessThanEqual( value.rgb, vec3( 0.0031308 ) ) ) ), value.a );
}`,Fm=`#ifdef USE_ENVMAP
	#ifdef ENV_WORLDPOS
		vec3 cameraToFrag;
		if ( isOrthographic ) {
			cameraToFrag = normalize( vec3( - viewMatrix[ 0 ][ 2 ], - viewMatrix[ 1 ][ 2 ], - viewMatrix[ 2 ][ 2 ] ) );
		} else {
			cameraToFrag = normalize( vWorldPosition - cameraPosition );
		}
		vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );
		#ifdef ENVMAP_MODE_REFLECTION
			vec3 reflectVec = reflect( cameraToFrag, worldNormal );
		#else
			vec3 reflectVec = refract( cameraToFrag, worldNormal, refractionRatio );
		#endif
	#else
		vec3 reflectVec = vReflect;
	#endif
	#ifdef ENVMAP_TYPE_CUBE
		vec4 envColor = textureCube( envMap, envMapRotation * vec3( flipEnvMap * reflectVec.x, reflectVec.yz ) );
	#else
		vec4 envColor = vec4( 0.0 );
	#endif
	#ifdef ENVMAP_BLENDING_MULTIPLY
		outgoingLight = mix( outgoingLight, outgoingLight * envColor.xyz, specularStrength * reflectivity );
	#elif defined( ENVMAP_BLENDING_MIX )
		outgoingLight = mix( outgoingLight, envColor.xyz, specularStrength * reflectivity );
	#elif defined( ENVMAP_BLENDING_ADD )
		outgoingLight += envColor.xyz * specularStrength * reflectivity;
	#endif
#endif`,km=`#ifdef USE_ENVMAP
	uniform float envMapIntensity;
	uniform float flipEnvMap;
	uniform mat3 envMapRotation;
	#ifdef ENVMAP_TYPE_CUBE
		uniform samplerCube envMap;
	#else
		uniform sampler2D envMap;
	#endif
	
#endif`,Bm=`#ifdef USE_ENVMAP
	uniform float reflectivity;
	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )
		#define ENV_WORLDPOS
	#endif
	#ifdef ENV_WORLDPOS
		varying vec3 vWorldPosition;
		uniform float refractionRatio;
	#else
		varying vec3 vReflect;
	#endif
#endif`,Om=`#ifdef USE_ENVMAP
	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )
		#define ENV_WORLDPOS
	#endif
	#ifdef ENV_WORLDPOS
		
		varying vec3 vWorldPosition;
	#else
		varying vec3 vReflect;
		uniform float refractionRatio;
	#endif
#endif`,zm=`#ifdef USE_ENVMAP
	#ifdef ENV_WORLDPOS
		vWorldPosition = worldPosition.xyz;
	#else
		vec3 cameraToVertex;
		if ( isOrthographic ) {
			cameraToVertex = normalize( vec3( - viewMatrix[ 0 ][ 2 ], - viewMatrix[ 1 ][ 2 ], - viewMatrix[ 2 ][ 2 ] ) );
		} else {
			cameraToVertex = normalize( worldPosition.xyz - cameraPosition );
		}
		vec3 worldNormal = inverseTransformDirection( transformedNormal, viewMatrix );
		#ifdef ENVMAP_MODE_REFLECTION
			vReflect = reflect( cameraToVertex, worldNormal );
		#else
			vReflect = refract( cameraToVertex, worldNormal, refractionRatio );
		#endif
	#endif
#endif`,Hm=`#ifdef USE_FOG
	vFogDepth = - mvPosition.z;
#endif`,Vm=`#ifdef USE_FOG
	varying float vFogDepth;
#endif`,Gm=`#ifdef USE_FOG
	#ifdef FOG_EXP2
		float fogFactor = 1.0 - exp( - fogDensity * fogDensity * vFogDepth * vFogDepth );
	#else
		float fogFactor = smoothstep( fogNear, fogFar, vFogDepth );
	#endif
	gl_FragColor.rgb = mix( gl_FragColor.rgb, fogColor, fogFactor );
#endif`,Wm=`#ifdef USE_FOG
	uniform vec3 fogColor;
	varying float vFogDepth;
	#ifdef FOG_EXP2
		uniform float fogDensity;
	#else
		uniform float fogNear;
		uniform float fogFar;
	#endif
#endif`,Xm=`#ifdef USE_GRADIENTMAP
	uniform sampler2D gradientMap;
#endif
vec3 getGradientIrradiance( vec3 normal, vec3 lightDirection ) {
	float dotNL = dot( normal, lightDirection );
	vec2 coord = vec2( dotNL * 0.5 + 0.5, 0.0 );
	#ifdef USE_GRADIENTMAP
		return vec3( texture2D( gradientMap, coord ).r );
	#else
		vec2 fw = fwidth( coord ) * 0.5;
		return mix( vec3( 0.7 ), vec3( 1.0 ), smoothstep( 0.7 - fw.x, 0.7 + fw.x, coord.x ) );
	#endif
}`,qm=`#ifdef USE_LIGHTMAP
	uniform sampler2D lightMap;
	uniform float lightMapIntensity;
#endif`,Ym=`LambertMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.specularStrength = specularStrength;`,Zm=`varying vec3 vViewPosition;
struct LambertMaterial {
	vec3 diffuseColor;
	float specularStrength;
};
void RE_Direct_Lambert( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in LambertMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Lambert( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in LambertMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_Lambert
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Lambert`,$m=`uniform bool receiveShadow;
uniform vec3 ambientLightColor;
#if defined( USE_LIGHT_PROBES )
	uniform vec3 lightProbe[ 9 ];
#endif
vec3 shGetIrradianceAt( in vec3 normal, in vec3 shCoefficients[ 9 ] ) {
	float x = normal.x, y = normal.y, z = normal.z;
	vec3 result = shCoefficients[ 0 ] * 0.886227;
	result += shCoefficients[ 1 ] * 2.0 * 0.511664 * y;
	result += shCoefficients[ 2 ] * 2.0 * 0.511664 * z;
	result += shCoefficients[ 3 ] * 2.0 * 0.511664 * x;
	result += shCoefficients[ 4 ] * 2.0 * 0.429043 * x * y;
	result += shCoefficients[ 5 ] * 2.0 * 0.429043 * y * z;
	result += shCoefficients[ 6 ] * ( 0.743125 * z * z - 0.247708 );
	result += shCoefficients[ 7 ] * 2.0 * 0.429043 * x * z;
	result += shCoefficients[ 8 ] * 0.429043 * ( x * x - y * y );
	return result;
}
vec3 getLightProbeIrradiance( const in vec3 lightProbe[ 9 ], const in vec3 normal ) {
	vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );
	vec3 irradiance = shGetIrradianceAt( worldNormal, lightProbe );
	return irradiance;
}
vec3 getAmbientLightIrradiance( const in vec3 ambientLightColor ) {
	vec3 irradiance = ambientLightColor;
	return irradiance;
}
float getDistanceAttenuation( const in float lightDistance, const in float cutoffDistance, const in float decayExponent ) {
	float distanceFalloff = 1.0 / max( pow( lightDistance, decayExponent ), 0.01 );
	if ( cutoffDistance > 0.0 ) {
		distanceFalloff *= pow2( saturate( 1.0 - pow4( lightDistance / cutoffDistance ) ) );
	}
	return distanceFalloff;
}
float getSpotAttenuation( const in float coneCosine, const in float penumbraCosine, const in float angleCosine ) {
	return smoothstep( coneCosine, penumbraCosine, angleCosine );
}
#if NUM_DIR_LIGHTS > 0
	struct DirectionalLight {
		vec3 direction;
		vec3 color;
	};
	uniform DirectionalLight directionalLights[ NUM_DIR_LIGHTS ];
	void getDirectionalLightInfo( const in DirectionalLight directionalLight, out IncidentLight light ) {
		light.color = directionalLight.color;
		light.direction = directionalLight.direction;
		light.visible = true;
	}
#endif
#if NUM_POINT_LIGHTS > 0
	struct PointLight {
		vec3 position;
		vec3 color;
		float distance;
		float decay;
	};
	uniform PointLight pointLights[ NUM_POINT_LIGHTS ];
	void getPointLightInfo( const in PointLight pointLight, const in vec3 geometryPosition, out IncidentLight light ) {
		vec3 lVector = pointLight.position - geometryPosition;
		light.direction = normalize( lVector );
		float lightDistance = length( lVector );
		light.color = pointLight.color;
		light.color *= getDistanceAttenuation( lightDistance, pointLight.distance, pointLight.decay );
		light.visible = ( light.color != vec3( 0.0 ) );
	}
#endif
#if NUM_SPOT_LIGHTS > 0
	struct SpotLight {
		vec3 position;
		vec3 direction;
		vec3 color;
		float distance;
		float decay;
		float coneCos;
		float penumbraCos;
	};
	uniform SpotLight spotLights[ NUM_SPOT_LIGHTS ];
	void getSpotLightInfo( const in SpotLight spotLight, const in vec3 geometryPosition, out IncidentLight light ) {
		vec3 lVector = spotLight.position - geometryPosition;
		light.direction = normalize( lVector );
		float angleCos = dot( light.direction, spotLight.direction );
		float spotAttenuation = getSpotAttenuation( spotLight.coneCos, spotLight.penumbraCos, angleCos );
		if ( spotAttenuation > 0.0 ) {
			float lightDistance = length( lVector );
			light.color = spotLight.color * spotAttenuation;
			light.color *= getDistanceAttenuation( lightDistance, spotLight.distance, spotLight.decay );
			light.visible = ( light.color != vec3( 0.0 ) );
		} else {
			light.color = vec3( 0.0 );
			light.visible = false;
		}
	}
#endif
#if NUM_RECT_AREA_LIGHTS > 0
	struct RectAreaLight {
		vec3 color;
		vec3 position;
		vec3 halfWidth;
		vec3 halfHeight;
	};
	uniform sampler2D ltc_1;	uniform sampler2D ltc_2;
	uniform RectAreaLight rectAreaLights[ NUM_RECT_AREA_LIGHTS ];
#endif
#if NUM_HEMI_LIGHTS > 0
	struct HemisphereLight {
		vec3 direction;
		vec3 skyColor;
		vec3 groundColor;
	};
	uniform HemisphereLight hemisphereLights[ NUM_HEMI_LIGHTS ];
	vec3 getHemisphereLightIrradiance( const in HemisphereLight hemiLight, const in vec3 normal ) {
		float dotNL = dot( normal, hemiLight.direction );
		float hemiDiffuseWeight = 0.5 * dotNL + 0.5;
		vec3 irradiance = mix( hemiLight.groundColor, hemiLight.skyColor, hemiDiffuseWeight );
		return irradiance;
	}
#endif`,Jm=`#ifdef USE_ENVMAP
	vec3 getIBLIrradiance( const in vec3 normal ) {
		#ifdef ENVMAP_TYPE_CUBE_UV
			vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );
			vec4 envMapColor = textureCubeUV( envMap, envMapRotation * worldNormal, 1.0 );
			return PI * envMapColor.rgb * envMapIntensity;
		#else
			return vec3( 0.0 );
		#endif
	}
	vec3 getIBLRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness ) {
		#ifdef ENVMAP_TYPE_CUBE_UV
			vec3 reflectVec = reflect( - viewDir, normal );
			reflectVec = normalize( mix( reflectVec, normal, roughness * roughness) );
			reflectVec = inverseTransformDirection( reflectVec, viewMatrix );
			vec4 envMapColor = textureCubeUV( envMap, envMapRotation * reflectVec, roughness );
			return envMapColor.rgb * envMapIntensity;
		#else
			return vec3( 0.0 );
		#endif
	}
	#ifdef USE_ANISOTROPY
		vec3 getIBLAnisotropyRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness, const in vec3 bitangent, const in float anisotropy ) {
			#ifdef ENVMAP_TYPE_CUBE_UV
				vec3 bentNormal = cross( bitangent, viewDir );
				bentNormal = normalize( cross( bentNormal, bitangent ) );
				bentNormal = normalize( mix( bentNormal, normal, pow2( pow2( 1.0 - anisotropy * ( 1.0 - roughness ) ) ) ) );
				return getIBLRadiance( viewDir, bentNormal, roughness );
			#else
				return vec3( 0.0 );
			#endif
		}
	#endif
#endif`,Km=`ToonMaterial material;
material.diffuseColor = diffuseColor.rgb;`,jm=`varying vec3 vViewPosition;
struct ToonMaterial {
	vec3 diffuseColor;
};
void RE_Direct_Toon( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in ToonMaterial material, inout ReflectedLight reflectedLight ) {
	vec3 irradiance = getGradientIrradiance( geometryNormal, directLight.direction ) * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Toon( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in ToonMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_Toon
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Toon`,Qm=`BlinnPhongMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.specularColor = specular;
material.specularShininess = shininess;
material.specularStrength = specularStrength;`,tg=`varying vec3 vViewPosition;
struct BlinnPhongMaterial {
	vec3 diffuseColor;
	vec3 specularColor;
	float specularShininess;
	float specularStrength;
};
void RE_Direct_BlinnPhong( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
	reflectedLight.directSpecular += irradiance * BRDF_BlinnPhong( directLight.direction, geometryViewDir, geometryNormal, material.specularColor, material.specularShininess ) * material.specularStrength;
}
void RE_IndirectDiffuse_BlinnPhong( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_BlinnPhong
#define RE_IndirectDiffuse		RE_IndirectDiffuse_BlinnPhong`,eg=`PhysicalMaterial material;
material.diffuseColor = diffuseColor.rgb * ( 1.0 - metalnessFactor );
vec3 dxy = max( abs( dFdx( nonPerturbedNormal ) ), abs( dFdy( nonPerturbedNormal ) ) );
float geometryRoughness = max( max( dxy.x, dxy.y ), dxy.z );
material.roughness = max( roughnessFactor, 0.0525 );material.roughness += geometryRoughness;
material.roughness = min( material.roughness, 1.0 );
#ifdef IOR
	material.ior = ior;
	#ifdef USE_SPECULAR
		float specularIntensityFactor = specularIntensity;
		vec3 specularColorFactor = specularColor;
		#ifdef USE_SPECULAR_COLORMAP
			specularColorFactor *= texture2D( specularColorMap, vSpecularColorMapUv ).rgb;
		#endif
		#ifdef USE_SPECULAR_INTENSITYMAP
			specularIntensityFactor *= texture2D( specularIntensityMap, vSpecularIntensityMapUv ).a;
		#endif
		material.specularF90 = mix( specularIntensityFactor, 1.0, metalnessFactor );
	#else
		float specularIntensityFactor = 1.0;
		vec3 specularColorFactor = vec3( 1.0 );
		material.specularF90 = 1.0;
	#endif
	material.specularColor = mix( min( pow2( ( material.ior - 1.0 ) / ( material.ior + 1.0 ) ) * specularColorFactor, vec3( 1.0 ) ) * specularIntensityFactor, diffuseColor.rgb, metalnessFactor );
#else
	material.specularColor = mix( vec3( 0.04 ), diffuseColor.rgb, metalnessFactor );
	material.specularF90 = 1.0;
#endif
#ifdef USE_CLEARCOAT
	material.clearcoat = clearcoat;
	material.clearcoatRoughness = clearcoatRoughness;
	material.clearcoatF0 = vec3( 0.04 );
	material.clearcoatF90 = 1.0;
	#ifdef USE_CLEARCOATMAP
		material.clearcoat *= texture2D( clearcoatMap, vClearcoatMapUv ).x;
	#endif
	#ifdef USE_CLEARCOAT_ROUGHNESSMAP
		material.clearcoatRoughness *= texture2D( clearcoatRoughnessMap, vClearcoatRoughnessMapUv ).y;
	#endif
	material.clearcoat = saturate( material.clearcoat );	material.clearcoatRoughness = max( material.clearcoatRoughness, 0.0525 );
	material.clearcoatRoughness += geometryRoughness;
	material.clearcoatRoughness = min( material.clearcoatRoughness, 1.0 );
#endif
#ifdef USE_DISPERSION
	material.dispersion = dispersion;
#endif
#ifdef USE_IRIDESCENCE
	material.iridescence = iridescence;
	material.iridescenceIOR = iridescenceIOR;
	#ifdef USE_IRIDESCENCEMAP
		material.iridescence *= texture2D( iridescenceMap, vIridescenceMapUv ).r;
	#endif
	#ifdef USE_IRIDESCENCE_THICKNESSMAP
		material.iridescenceThickness = (iridescenceThicknessMaximum - iridescenceThicknessMinimum) * texture2D( iridescenceThicknessMap, vIridescenceThicknessMapUv ).g + iridescenceThicknessMinimum;
	#else
		material.iridescenceThickness = iridescenceThicknessMaximum;
	#endif
#endif
#ifdef USE_SHEEN
	material.sheenColor = sheenColor;
	#ifdef USE_SHEEN_COLORMAP
		material.sheenColor *= texture2D( sheenColorMap, vSheenColorMapUv ).rgb;
	#endif
	material.sheenRoughness = clamp( sheenRoughness, 0.07, 1.0 );
	#ifdef USE_SHEEN_ROUGHNESSMAP
		material.sheenRoughness *= texture2D( sheenRoughnessMap, vSheenRoughnessMapUv ).a;
	#endif
#endif
#ifdef USE_ANISOTROPY
	#ifdef USE_ANISOTROPYMAP
		mat2 anisotropyMat = mat2( anisotropyVector.x, anisotropyVector.y, - anisotropyVector.y, anisotropyVector.x );
		vec3 anisotropyPolar = texture2D( anisotropyMap, vAnisotropyMapUv ).rgb;
		vec2 anisotropyV = anisotropyMat * normalize( 2.0 * anisotropyPolar.rg - vec2( 1.0 ) ) * anisotropyPolar.b;
	#else
		vec2 anisotropyV = anisotropyVector;
	#endif
	material.anisotropy = length( anisotropyV );
	if( material.anisotropy == 0.0 ) {
		anisotropyV = vec2( 1.0, 0.0 );
	} else {
		anisotropyV /= material.anisotropy;
		material.anisotropy = saturate( material.anisotropy );
	}
	material.alphaT = mix( pow2( material.roughness ), 1.0, pow2( material.anisotropy ) );
	material.anisotropyT = tbn[ 0 ] * anisotropyV.x + tbn[ 1 ] * anisotropyV.y;
	material.anisotropyB = tbn[ 1 ] * anisotropyV.x - tbn[ 0 ] * anisotropyV.y;
#endif`,ig=`struct PhysicalMaterial {
	vec3 diffuseColor;
	float roughness;
	vec3 specularColor;
	float specularF90;
	float dispersion;
	#ifdef USE_CLEARCOAT
		float clearcoat;
		float clearcoatRoughness;
		vec3 clearcoatF0;
		float clearcoatF90;
	#endif
	#ifdef USE_IRIDESCENCE
		float iridescence;
		float iridescenceIOR;
		float iridescenceThickness;
		vec3 iridescenceFresnel;
		vec3 iridescenceF0;
	#endif
	#ifdef USE_SHEEN
		vec3 sheenColor;
		float sheenRoughness;
	#endif
	#ifdef IOR
		float ior;
	#endif
	#ifdef USE_TRANSMISSION
		float transmission;
		float transmissionAlpha;
		float thickness;
		float attenuationDistance;
		vec3 attenuationColor;
	#endif
	#ifdef USE_ANISOTROPY
		float anisotropy;
		float alphaT;
		vec3 anisotropyT;
		vec3 anisotropyB;
	#endif
};
vec3 clearcoatSpecularDirect = vec3( 0.0 );
vec3 clearcoatSpecularIndirect = vec3( 0.0 );
vec3 sheenSpecularDirect = vec3( 0.0 );
vec3 sheenSpecularIndirect = vec3(0.0 );
vec3 Schlick_to_F0( const in vec3 f, const in float f90, const in float dotVH ) {
    float x = clamp( 1.0 - dotVH, 0.0, 1.0 );
    float x2 = x * x;
    float x5 = clamp( x * x2 * x2, 0.0, 0.9999 );
    return ( f - vec3( f90 ) * x5 ) / ( 1.0 - x5 );
}
float V_GGX_SmithCorrelated( const in float alpha, const in float dotNL, const in float dotNV ) {
	float a2 = pow2( alpha );
	float gv = dotNL * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNV ) );
	float gl = dotNV * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNL ) );
	return 0.5 / max( gv + gl, EPSILON );
}
float D_GGX( const in float alpha, const in float dotNH ) {
	float a2 = pow2( alpha );
	float denom = pow2( dotNH ) * ( a2 - 1.0 ) + 1.0;
	return RECIPROCAL_PI * a2 / pow2( denom );
}
#ifdef USE_ANISOTROPY
	float V_GGX_SmithCorrelated_Anisotropic( const in float alphaT, const in float alphaB, const in float dotTV, const in float dotBV, const in float dotTL, const in float dotBL, const in float dotNV, const in float dotNL ) {
		float gv = dotNL * length( vec3( alphaT * dotTV, alphaB * dotBV, dotNV ) );
		float gl = dotNV * length( vec3( alphaT * dotTL, alphaB * dotBL, dotNL ) );
		float v = 0.5 / ( gv + gl );
		return saturate(v);
	}
	float D_GGX_Anisotropic( const in float alphaT, const in float alphaB, const in float dotNH, const in float dotTH, const in float dotBH ) {
		float a2 = alphaT * alphaB;
		highp vec3 v = vec3( alphaB * dotTH, alphaT * dotBH, a2 * dotNH );
		highp float v2 = dot( v, v );
		float w2 = a2 / v2;
		return RECIPROCAL_PI * a2 * pow2 ( w2 );
	}
#endif
#ifdef USE_CLEARCOAT
	vec3 BRDF_GGX_Clearcoat( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in PhysicalMaterial material) {
		vec3 f0 = material.clearcoatF0;
		float f90 = material.clearcoatF90;
		float roughness = material.clearcoatRoughness;
		float alpha = pow2( roughness );
		vec3 halfDir = normalize( lightDir + viewDir );
		float dotNL = saturate( dot( normal, lightDir ) );
		float dotNV = saturate( dot( normal, viewDir ) );
		float dotNH = saturate( dot( normal, halfDir ) );
		float dotVH = saturate( dot( viewDir, halfDir ) );
		vec3 F = F_Schlick( f0, f90, dotVH );
		float V = V_GGX_SmithCorrelated( alpha, dotNL, dotNV );
		float D = D_GGX( alpha, dotNH );
		return F * ( V * D );
	}
#endif
vec3 BRDF_GGX( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in PhysicalMaterial material ) {
	vec3 f0 = material.specularColor;
	float f90 = material.specularF90;
	float roughness = material.roughness;
	float alpha = pow2( roughness );
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNL = saturate( dot( normal, lightDir ) );
	float dotNV = saturate( dot( normal, viewDir ) );
	float dotNH = saturate( dot( normal, halfDir ) );
	float dotVH = saturate( dot( viewDir, halfDir ) );
	vec3 F = F_Schlick( f0, f90, dotVH );
	#ifdef USE_IRIDESCENCE
		F = mix( F, material.iridescenceFresnel, material.iridescence );
	#endif
	#ifdef USE_ANISOTROPY
		float dotTL = dot( material.anisotropyT, lightDir );
		float dotTV = dot( material.anisotropyT, viewDir );
		float dotTH = dot( material.anisotropyT, halfDir );
		float dotBL = dot( material.anisotropyB, lightDir );
		float dotBV = dot( material.anisotropyB, viewDir );
		float dotBH = dot( material.anisotropyB, halfDir );
		float V = V_GGX_SmithCorrelated_Anisotropic( material.alphaT, alpha, dotTV, dotBV, dotTL, dotBL, dotNV, dotNL );
		float D = D_GGX_Anisotropic( material.alphaT, alpha, dotNH, dotTH, dotBH );
	#else
		float V = V_GGX_SmithCorrelated( alpha, dotNL, dotNV );
		float D = D_GGX( alpha, dotNH );
	#endif
	return F * ( V * D );
}
vec2 LTC_Uv( const in vec3 N, const in vec3 V, const in float roughness ) {
	const float LUT_SIZE = 64.0;
	const float LUT_SCALE = ( LUT_SIZE - 1.0 ) / LUT_SIZE;
	const float LUT_BIAS = 0.5 / LUT_SIZE;
	float dotNV = saturate( dot( N, V ) );
	vec2 uv = vec2( roughness, sqrt( 1.0 - dotNV ) );
	uv = uv * LUT_SCALE + LUT_BIAS;
	return uv;
}
float LTC_ClippedSphereFormFactor( const in vec3 f ) {
	float l = length( f );
	return max( ( l * l + f.z ) / ( l + 1.0 ), 0.0 );
}
vec3 LTC_EdgeVectorFormFactor( const in vec3 v1, const in vec3 v2 ) {
	float x = dot( v1, v2 );
	float y = abs( x );
	float a = 0.8543985 + ( 0.4965155 + 0.0145206 * y ) * y;
	float b = 3.4175940 + ( 4.1616724 + y ) * y;
	float v = a / b;
	float theta_sintheta = ( x > 0.0 ) ? v : 0.5 * inversesqrt( max( 1.0 - x * x, 1e-7 ) ) - v;
	return cross( v1, v2 ) * theta_sintheta;
}
vec3 LTC_Evaluate( const in vec3 N, const in vec3 V, const in vec3 P, const in mat3 mInv, const in vec3 rectCoords[ 4 ] ) {
	vec3 v1 = rectCoords[ 1 ] - rectCoords[ 0 ];
	vec3 v2 = rectCoords[ 3 ] - rectCoords[ 0 ];
	vec3 lightNormal = cross( v1, v2 );
	if( dot( lightNormal, P - rectCoords[ 0 ] ) < 0.0 ) return vec3( 0.0 );
	vec3 T1, T2;
	T1 = normalize( V - N * dot( V, N ) );
	T2 = - cross( N, T1 );
	mat3 mat = mInv * transposeMat3( mat3( T1, T2, N ) );
	vec3 coords[ 4 ];
	coords[ 0 ] = mat * ( rectCoords[ 0 ] - P );
	coords[ 1 ] = mat * ( rectCoords[ 1 ] - P );
	coords[ 2 ] = mat * ( rectCoords[ 2 ] - P );
	coords[ 3 ] = mat * ( rectCoords[ 3 ] - P );
	coords[ 0 ] = normalize( coords[ 0 ] );
	coords[ 1 ] = normalize( coords[ 1 ] );
	coords[ 2 ] = normalize( coords[ 2 ] );
	coords[ 3 ] = normalize( coords[ 3 ] );
	vec3 vectorFormFactor = vec3( 0.0 );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 0 ], coords[ 1 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 1 ], coords[ 2 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 2 ], coords[ 3 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 3 ], coords[ 0 ] );
	float result = LTC_ClippedSphereFormFactor( vectorFormFactor );
	return vec3( result );
}
#if defined( USE_SHEEN )
float D_Charlie( float roughness, float dotNH ) {
	float alpha = pow2( roughness );
	float invAlpha = 1.0 / alpha;
	float cos2h = dotNH * dotNH;
	float sin2h = max( 1.0 - cos2h, 0.0078125 );
	return ( 2.0 + invAlpha ) * pow( sin2h, invAlpha * 0.5 ) / ( 2.0 * PI );
}
float V_Neubelt( float dotNV, float dotNL ) {
	return saturate( 1.0 / ( 4.0 * ( dotNL + dotNV - dotNL * dotNV ) ) );
}
vec3 BRDF_Sheen( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, vec3 sheenColor, const in float sheenRoughness ) {
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNL = saturate( dot( normal, lightDir ) );
	float dotNV = saturate( dot( normal, viewDir ) );
	float dotNH = saturate( dot( normal, halfDir ) );
	float D = D_Charlie( sheenRoughness, dotNH );
	float V = V_Neubelt( dotNV, dotNL );
	return sheenColor * ( D * V );
}
#endif
float IBLSheenBRDF( const in vec3 normal, const in vec3 viewDir, const in float roughness ) {
	float dotNV = saturate( dot( normal, viewDir ) );
	float r2 = roughness * roughness;
	float a = roughness < 0.25 ? -339.2 * r2 + 161.4 * roughness - 25.9 : -8.48 * r2 + 14.3 * roughness - 9.95;
	float b = roughness < 0.25 ? 44.0 * r2 - 23.7 * roughness + 3.26 : 1.97 * r2 - 3.27 * roughness + 0.72;
	float DG = exp( a * dotNV + b ) + ( roughness < 0.25 ? 0.0 : 0.1 * ( roughness - 0.25 ) );
	return saturate( DG * RECIPROCAL_PI );
}
vec2 DFGApprox( const in vec3 normal, const in vec3 viewDir, const in float roughness ) {
	float dotNV = saturate( dot( normal, viewDir ) );
	const vec4 c0 = vec4( - 1, - 0.0275, - 0.572, 0.022 );
	const vec4 c1 = vec4( 1, 0.0425, 1.04, - 0.04 );
	vec4 r = roughness * c0 + c1;
	float a004 = min( r.x * r.x, exp2( - 9.28 * dotNV ) ) * r.x + r.y;
	vec2 fab = vec2( - 1.04, 1.04 ) * a004 + r.zw;
	return fab;
}
vec3 EnvironmentBRDF( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float roughness ) {
	vec2 fab = DFGApprox( normal, viewDir, roughness );
	return specularColor * fab.x + specularF90 * fab.y;
}
#ifdef USE_IRIDESCENCE
void computeMultiscatteringIridescence( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float iridescence, const in vec3 iridescenceF0, const in float roughness, inout vec3 singleScatter, inout vec3 multiScatter ) {
#else
void computeMultiscattering( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float roughness, inout vec3 singleScatter, inout vec3 multiScatter ) {
#endif
	vec2 fab = DFGApprox( normal, viewDir, roughness );
	#ifdef USE_IRIDESCENCE
		vec3 Fr = mix( specularColor, iridescenceF0, iridescence );
	#else
		vec3 Fr = specularColor;
	#endif
	vec3 FssEss = Fr * fab.x + specularF90 * fab.y;
	float Ess = fab.x + fab.y;
	float Ems = 1.0 - Ess;
	vec3 Favg = Fr + ( 1.0 - Fr ) * 0.047619;	vec3 Fms = FssEss * Favg / ( 1.0 - Ems * Favg );
	singleScatter += FssEss;
	multiScatter += Fms * Ems;
}
#if NUM_RECT_AREA_LIGHTS > 0
	void RE_Direct_RectArea_Physical( const in RectAreaLight rectAreaLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
		vec3 normal = geometryNormal;
		vec3 viewDir = geometryViewDir;
		vec3 position = geometryPosition;
		vec3 lightPos = rectAreaLight.position;
		vec3 halfWidth = rectAreaLight.halfWidth;
		vec3 halfHeight = rectAreaLight.halfHeight;
		vec3 lightColor = rectAreaLight.color;
		float roughness = material.roughness;
		vec3 rectCoords[ 4 ];
		rectCoords[ 0 ] = lightPos + halfWidth - halfHeight;		rectCoords[ 1 ] = lightPos - halfWidth - halfHeight;
		rectCoords[ 2 ] = lightPos - halfWidth + halfHeight;
		rectCoords[ 3 ] = lightPos + halfWidth + halfHeight;
		vec2 uv = LTC_Uv( normal, viewDir, roughness );
		vec4 t1 = texture2D( ltc_1, uv );
		vec4 t2 = texture2D( ltc_2, uv );
		mat3 mInv = mat3(
			vec3( t1.x, 0, t1.y ),
			vec3(    0, 1,    0 ),
			vec3( t1.z, 0, t1.w )
		);
		vec3 fresnel = ( material.specularColor * t2.x + ( vec3( 1.0 ) - material.specularColor ) * t2.y );
		reflectedLight.directSpecular += lightColor * fresnel * LTC_Evaluate( normal, viewDir, position, mInv, rectCoords );
		reflectedLight.directDiffuse += lightColor * material.diffuseColor * LTC_Evaluate( normal, viewDir, position, mat3( 1.0 ), rectCoords );
	}
#endif
void RE_Direct_Physical( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	#ifdef USE_CLEARCOAT
		float dotNLcc = saturate( dot( geometryClearcoatNormal, directLight.direction ) );
		vec3 ccIrradiance = dotNLcc * directLight.color;
		clearcoatSpecularDirect += ccIrradiance * BRDF_GGX_Clearcoat( directLight.direction, geometryViewDir, geometryClearcoatNormal, material );
	#endif
	#ifdef USE_SHEEN
		sheenSpecularDirect += irradiance * BRDF_Sheen( directLight.direction, geometryViewDir, geometryNormal, material.sheenColor, material.sheenRoughness );
	#endif
	reflectedLight.directSpecular += irradiance * BRDF_GGX( directLight.direction, geometryViewDir, geometryNormal, material );
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Physical( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectSpecular_Physical( const in vec3 radiance, const in vec3 irradiance, const in vec3 clearcoatRadiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight) {
	#ifdef USE_CLEARCOAT
		clearcoatSpecularIndirect += clearcoatRadiance * EnvironmentBRDF( geometryClearcoatNormal, geometryViewDir, material.clearcoatF0, material.clearcoatF90, material.clearcoatRoughness );
	#endif
	#ifdef USE_SHEEN
		sheenSpecularIndirect += irradiance * material.sheenColor * IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness );
	#endif
	vec3 singleScattering = vec3( 0.0 );
	vec3 multiScattering = vec3( 0.0 );
	vec3 cosineWeightedIrradiance = irradiance * RECIPROCAL_PI;
	#ifdef USE_IRIDESCENCE
		computeMultiscatteringIridescence( geometryNormal, geometryViewDir, material.specularColor, material.specularF90, material.iridescence, material.iridescenceFresnel, material.roughness, singleScattering, multiScattering );
	#else
		computeMultiscattering( geometryNormal, geometryViewDir, material.specularColor, material.specularF90, material.roughness, singleScattering, multiScattering );
	#endif
	vec3 totalScattering = singleScattering + multiScattering;
	vec3 diffuse = material.diffuseColor * ( 1.0 - max( max( totalScattering.r, totalScattering.g ), totalScattering.b ) );
	reflectedLight.indirectSpecular += radiance * singleScattering;
	reflectedLight.indirectSpecular += multiScattering * cosineWeightedIrradiance;
	reflectedLight.indirectDiffuse += diffuse * cosineWeightedIrradiance;
}
#define RE_Direct				RE_Direct_Physical
#define RE_Direct_RectArea		RE_Direct_RectArea_Physical
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Physical
#define RE_IndirectSpecular		RE_IndirectSpecular_Physical
float computeSpecularOcclusion( const in float dotNV, const in float ambientOcclusion, const in float roughness ) {
	return saturate( pow( dotNV + ambientOcclusion, exp2( - 16.0 * roughness - 1.0 ) ) - 1.0 + ambientOcclusion );
}`,ng=`
vec3 geometryPosition = - vViewPosition;
vec3 geometryNormal = normal;
vec3 geometryViewDir = ( isOrthographic ) ? vec3( 0, 0, 1 ) : normalize( vViewPosition );
vec3 geometryClearcoatNormal = vec3( 0.0 );
#ifdef USE_CLEARCOAT
	geometryClearcoatNormal = clearcoatNormal;
#endif
#ifdef USE_IRIDESCENCE
	float dotNVi = saturate( dot( normal, geometryViewDir ) );
	if ( material.iridescenceThickness == 0.0 ) {
		material.iridescence = 0.0;
	} else {
		material.iridescence = saturate( material.iridescence );
	}
	if ( material.iridescence > 0.0 ) {
		material.iridescenceFresnel = evalIridescence( 1.0, material.iridescenceIOR, dotNVi, material.iridescenceThickness, material.specularColor );
		material.iridescenceF0 = Schlick_to_F0( material.iridescenceFresnel, 1.0, dotNVi );
	}
#endif
IncidentLight directLight;
#if ( NUM_POINT_LIGHTS > 0 ) && defined( RE_Direct )
	PointLight pointLight;
	#if defined( USE_SHADOWMAP ) && NUM_POINT_LIGHT_SHADOWS > 0
	PointLightShadow pointLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_POINT_LIGHTS; i ++ ) {
		pointLight = pointLights[ i ];
		getPointLightInfo( pointLight, geometryPosition, directLight );
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_POINT_LIGHT_SHADOWS )
		pointLightShadow = pointLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getPointShadow( pointShadowMap[ i ], pointLightShadow.shadowMapSize, pointLightShadow.shadowIntensity, pointLightShadow.shadowBias, pointLightShadow.shadowRadius, vPointShadowCoord[ i ], pointLightShadow.shadowCameraNear, pointLightShadow.shadowCameraFar ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_SPOT_LIGHTS > 0 ) && defined( RE_Direct )
	SpotLight spotLight;
	vec4 spotColor;
	vec3 spotLightCoord;
	bool inSpotLightMap;
	#if defined( USE_SHADOWMAP ) && NUM_SPOT_LIGHT_SHADOWS > 0
	SpotLightShadow spotLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHTS; i ++ ) {
		spotLight = spotLights[ i ];
		getSpotLightInfo( spotLight, geometryPosition, directLight );
		#if ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS )
		#define SPOT_LIGHT_MAP_INDEX UNROLLED_LOOP_INDEX
		#elif ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
		#define SPOT_LIGHT_MAP_INDEX NUM_SPOT_LIGHT_MAPS
		#else
		#define SPOT_LIGHT_MAP_INDEX ( UNROLLED_LOOP_INDEX - NUM_SPOT_LIGHT_SHADOWS + NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS )
		#endif
		#if ( SPOT_LIGHT_MAP_INDEX < NUM_SPOT_LIGHT_MAPS )
			spotLightCoord = vSpotLightCoord[ i ].xyz / vSpotLightCoord[ i ].w;
			inSpotLightMap = all( lessThan( abs( spotLightCoord * 2. - 1. ), vec3( 1.0 ) ) );
			spotColor = texture2D( spotLightMap[ SPOT_LIGHT_MAP_INDEX ], spotLightCoord.xy );
			directLight.color = inSpotLightMap ? directLight.color * spotColor.rgb : directLight.color;
		#endif
		#undef SPOT_LIGHT_MAP_INDEX
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
		spotLightShadow = spotLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getShadow( spotShadowMap[ i ], spotLightShadow.shadowMapSize, spotLightShadow.shadowIntensity, spotLightShadow.shadowBias, spotLightShadow.shadowRadius, vSpotLightCoord[ i ] ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_DIR_LIGHTS > 0 ) && defined( RE_Direct )
	DirectionalLight directionalLight;
	#if defined( USE_SHADOWMAP ) && NUM_DIR_LIGHT_SHADOWS > 0
	DirectionalLightShadow directionalLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_DIR_LIGHTS; i ++ ) {
		directionalLight = directionalLights[ i ];
		getDirectionalLightInfo( directionalLight, directLight );
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_DIR_LIGHT_SHADOWS )
		directionalLightShadow = directionalLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getShadow( directionalShadowMap[ i ], directionalLightShadow.shadowMapSize, directionalLightShadow.shadowIntensity, directionalLightShadow.shadowBias, directionalLightShadow.shadowRadius, vDirectionalShadowCoord[ i ] ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_RECT_AREA_LIGHTS > 0 ) && defined( RE_Direct_RectArea )
	RectAreaLight rectAreaLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_RECT_AREA_LIGHTS; i ++ ) {
		rectAreaLight = rectAreaLights[ i ];
		RE_Direct_RectArea( rectAreaLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if defined( RE_IndirectDiffuse )
	vec3 iblIrradiance = vec3( 0.0 );
	vec3 irradiance = getAmbientLightIrradiance( ambientLightColor );
	#if defined( USE_LIGHT_PROBES )
		irradiance += getLightProbeIrradiance( lightProbe, geometryNormal );
	#endif
	#if ( NUM_HEMI_LIGHTS > 0 )
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_HEMI_LIGHTS; i ++ ) {
			irradiance += getHemisphereLightIrradiance( hemisphereLights[ i ], geometryNormal );
		}
		#pragma unroll_loop_end
	#endif
#endif
#if defined( RE_IndirectSpecular )
	vec3 radiance = vec3( 0.0 );
	vec3 clearcoatRadiance = vec3( 0.0 );
#endif`,sg=`#if defined( RE_IndirectDiffuse )
	#ifdef USE_LIGHTMAP
		vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
		vec3 lightMapIrradiance = lightMapTexel.rgb * lightMapIntensity;
		irradiance += lightMapIrradiance;
	#endif
	#if defined( USE_ENVMAP ) && defined( STANDARD ) && defined( ENVMAP_TYPE_CUBE_UV )
		iblIrradiance += getIBLIrradiance( geometryNormal );
	#endif
#endif
#if defined( USE_ENVMAP ) && defined( RE_IndirectSpecular )
	#ifdef USE_ANISOTROPY
		radiance += getIBLAnisotropyRadiance( geometryViewDir, geometryNormal, material.roughness, material.anisotropyB, material.anisotropy );
	#else
		radiance += getIBLRadiance( geometryViewDir, geometryNormal, material.roughness );
	#endif
	#ifdef USE_CLEARCOAT
		clearcoatRadiance += getIBLRadiance( geometryViewDir, geometryClearcoatNormal, material.clearcoatRoughness );
	#endif
#endif`,rg=`#if defined( RE_IndirectDiffuse )
	RE_IndirectDiffuse( irradiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
#endif
#if defined( RE_IndirectSpecular )
	RE_IndirectSpecular( radiance, iblIrradiance, clearcoatRadiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
#endif`,og=`#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
	gl_FragDepth = vIsPerspective == 0.0 ? gl_FragCoord.z : log2( vFragDepth ) * logDepthBufFC * 0.5;
#endif`,ag=`#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
	uniform float logDepthBufFC;
	varying float vFragDepth;
	varying float vIsPerspective;
#endif`,lg=`#ifdef USE_LOGARITHMIC_DEPTH_BUFFER
	varying float vFragDepth;
	varying float vIsPerspective;
#endif`,cg=`#ifdef USE_LOGARITHMIC_DEPTH_BUFFER
	vFragDepth = 1.0 + gl_Position.w;
	vIsPerspective = float( isPerspectiveMatrix( projectionMatrix ) );
#endif`,hg=`#ifdef USE_MAP
	vec4 sampledDiffuseColor = texture2D( map, vMapUv );
	#ifdef DECODE_VIDEO_TEXTURE
		sampledDiffuseColor = sRGBTransferEOTF( sampledDiffuseColor );
	#endif
	diffuseColor *= sampledDiffuseColor;
#endif`,ug=`#ifdef USE_MAP
	uniform sampler2D map;
#endif`,dg=`#if defined( USE_MAP ) || defined( USE_ALPHAMAP )
	#if defined( USE_POINTS_UV )
		vec2 uv = vUv;
	#else
		vec2 uv = ( uvTransform * vec3( gl_PointCoord.x, 1.0 - gl_PointCoord.y, 1 ) ).xy;
	#endif
#endif
#ifdef USE_MAP
	diffuseColor *= texture2D( map, uv );
#endif
#ifdef USE_ALPHAMAP
	diffuseColor.a *= texture2D( alphaMap, uv ).g;
#endif`,fg=`#if defined( USE_POINTS_UV )
	varying vec2 vUv;
#else
	#if defined( USE_MAP ) || defined( USE_ALPHAMAP )
		uniform mat3 uvTransform;
	#endif
#endif
#ifdef USE_MAP
	uniform sampler2D map;
#endif
#ifdef USE_ALPHAMAP
	uniform sampler2D alphaMap;
#endif`,pg=`float metalnessFactor = metalness;
#ifdef USE_METALNESSMAP
	vec4 texelMetalness = texture2D( metalnessMap, vMetalnessMapUv );
	metalnessFactor *= texelMetalness.b;
#endif`,mg=`#ifdef USE_METALNESSMAP
	uniform sampler2D metalnessMap;
#endif`,gg=`#ifdef USE_INSTANCING_MORPH
	float morphTargetInfluences[ MORPHTARGETS_COUNT ];
	float morphTargetBaseInfluence = texelFetch( morphTexture, ivec2( 0, gl_InstanceID ), 0 ).r;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		morphTargetInfluences[i] =  texelFetch( morphTexture, ivec2( i + 1, gl_InstanceID ), 0 ).r;
	}
#endif`,xg=`#if defined( USE_MORPHCOLORS )
	vColor *= morphTargetBaseInfluence;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		#if defined( USE_COLOR_ALPHA )
			if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ) * morphTargetInfluences[ i ];
		#elif defined( USE_COLOR )
			if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ).rgb * morphTargetInfluences[ i ];
		#endif
	}
#endif`,_g=`#ifdef USE_MORPHNORMALS
	objectNormal *= morphTargetBaseInfluence;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		if ( morphTargetInfluences[ i ] != 0.0 ) objectNormal += getMorph( gl_VertexID, i, 1 ).xyz * morphTargetInfluences[ i ];
	}
#endif`,yg=`#ifdef USE_MORPHTARGETS
	#ifndef USE_INSTANCING_MORPH
		uniform float morphTargetBaseInfluence;
		uniform float morphTargetInfluences[ MORPHTARGETS_COUNT ];
	#endif
	uniform sampler2DArray morphTargetsTexture;
	uniform ivec2 morphTargetsTextureSize;
	vec4 getMorph( const in int vertexIndex, const in int morphTargetIndex, const in int offset ) {
		int texelIndex = vertexIndex * MORPHTARGETS_TEXTURE_STRIDE + offset;
		int y = texelIndex / morphTargetsTextureSize.x;
		int x = texelIndex - y * morphTargetsTextureSize.x;
		ivec3 morphUV = ivec3( x, y, morphTargetIndex );
		return texelFetch( morphTargetsTexture, morphUV, 0 );
	}
#endif`,vg=`#ifdef USE_MORPHTARGETS
	transformed *= morphTargetBaseInfluence;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		if ( morphTargetInfluences[ i ] != 0.0 ) transformed += getMorph( gl_VertexID, i, 0 ).xyz * morphTargetInfluences[ i ];
	}
#endif`,Mg=`float faceDirection = gl_FrontFacing ? 1.0 : - 1.0;
#ifdef FLAT_SHADED
	vec3 fdx = dFdx( vViewPosition );
	vec3 fdy = dFdy( vViewPosition );
	vec3 normal = normalize( cross( fdx, fdy ) );
#else
	vec3 normal = normalize( vNormal );
	#ifdef DOUBLE_SIDED
		normal *= faceDirection;
	#endif
#endif
#if defined( USE_NORMALMAP_TANGENTSPACE ) || defined( USE_CLEARCOAT_NORMALMAP ) || defined( USE_ANISOTROPY )
	#ifdef USE_TANGENT
		mat3 tbn = mat3( normalize( vTangent ), normalize( vBitangent ), normal );
	#else
		mat3 tbn = getTangentFrame( - vViewPosition, normal,
		#if defined( USE_NORMALMAP )
			vNormalMapUv
		#elif defined( USE_CLEARCOAT_NORMALMAP )
			vClearcoatNormalMapUv
		#else
			vUv
		#endif
		);
	#endif
	#if defined( DOUBLE_SIDED ) && ! defined( FLAT_SHADED )
		tbn[0] *= faceDirection;
		tbn[1] *= faceDirection;
	#endif
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	#ifdef USE_TANGENT
		mat3 tbn2 = mat3( normalize( vTangent ), normalize( vBitangent ), normal );
	#else
		mat3 tbn2 = getTangentFrame( - vViewPosition, normal, vClearcoatNormalMapUv );
	#endif
	#if defined( DOUBLE_SIDED ) && ! defined( FLAT_SHADED )
		tbn2[0] *= faceDirection;
		tbn2[1] *= faceDirection;
	#endif
#endif
vec3 nonPerturbedNormal = normal;`,bg=`#ifdef USE_NORMALMAP_OBJECTSPACE
	normal = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;
	#ifdef FLIP_SIDED
		normal = - normal;
	#endif
	#ifdef DOUBLE_SIDED
		normal = normal * faceDirection;
	#endif
	normal = normalize( normalMatrix * normal );
#elif defined( USE_NORMALMAP_TANGENTSPACE )
	vec3 mapN = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;
	mapN.xy *= normalScale;
	normal = normalize( tbn * mapN );
#elif defined( USE_BUMPMAP )
	normal = perturbNormalArb( - vViewPosition, normal, dHdxy_fwd(), faceDirection );
#endif`,wg=`#ifndef FLAT_SHADED
	varying vec3 vNormal;
	#ifdef USE_TANGENT
		varying vec3 vTangent;
		varying vec3 vBitangent;
	#endif
#endif`,Sg=`#ifndef FLAT_SHADED
	varying vec3 vNormal;
	#ifdef USE_TANGENT
		varying vec3 vTangent;
		varying vec3 vBitangent;
	#endif
#endif`,Eg=`#ifndef FLAT_SHADED
	vNormal = normalize( transformedNormal );
	#ifdef USE_TANGENT
		vTangent = normalize( transformedTangent );
		vBitangent = normalize( cross( vNormal, vTangent ) * tangent.w );
	#endif
#endif`,Tg=`#ifdef USE_NORMALMAP
	uniform sampler2D normalMap;
	uniform vec2 normalScale;
#endif
#ifdef USE_NORMALMAP_OBJECTSPACE
	uniform mat3 normalMatrix;
#endif
#if ! defined ( USE_TANGENT ) && ( defined ( USE_NORMALMAP_TANGENTSPACE ) || defined ( USE_CLEARCOAT_NORMALMAP ) || defined( USE_ANISOTROPY ) )
	mat3 getTangentFrame( vec3 eye_pos, vec3 surf_norm, vec2 uv ) {
		vec3 q0 = dFdx( eye_pos.xyz );
		vec3 q1 = dFdy( eye_pos.xyz );
		vec2 st0 = dFdx( uv.st );
		vec2 st1 = dFdy( uv.st );
		vec3 N = surf_norm;
		vec3 q1perp = cross( q1, N );
		vec3 q0perp = cross( N, q0 );
		vec3 T = q1perp * st0.x + q0perp * st1.x;
		vec3 B = q1perp * st0.y + q0perp * st1.y;
		float det = max( dot( T, T ), dot( B, B ) );
		float scale = ( det == 0.0 ) ? 0.0 : inversesqrt( det );
		return mat3( T * scale, B * scale, N );
	}
#endif`,Ag=`#ifdef USE_CLEARCOAT
	vec3 clearcoatNormal = nonPerturbedNormal;
#endif`,Rg=`#ifdef USE_CLEARCOAT_NORMALMAP
	vec3 clearcoatMapN = texture2D( clearcoatNormalMap, vClearcoatNormalMapUv ).xyz * 2.0 - 1.0;
	clearcoatMapN.xy *= clearcoatNormalScale;
	clearcoatNormal = normalize( tbn2 * clearcoatMapN );
#endif`,Cg=`#ifdef USE_CLEARCOATMAP
	uniform sampler2D clearcoatMap;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	uniform sampler2D clearcoatNormalMap;
	uniform vec2 clearcoatNormalScale;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	uniform sampler2D clearcoatRoughnessMap;
#endif`,Ig=`#ifdef USE_IRIDESCENCEMAP
	uniform sampler2D iridescenceMap;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	uniform sampler2D iridescenceThicknessMap;
#endif`,Pg=`#ifdef OPAQUE
diffuseColor.a = 1.0;
#endif
#ifdef USE_TRANSMISSION
diffuseColor.a *= material.transmissionAlpha;
#endif
gl_FragColor = vec4( outgoingLight, diffuseColor.a );`,Lg=`vec3 packNormalToRGB( const in vec3 normal ) {
	return normalize( normal ) * 0.5 + 0.5;
}
vec3 unpackRGBToNormal( const in vec3 rgb ) {
	return 2.0 * rgb.xyz - 1.0;
}
const float PackUpscale = 256. / 255.;const float UnpackDownscale = 255. / 256.;const float ShiftRight8 = 1. / 256.;
const float Inv255 = 1. / 255.;
const vec4 PackFactors = vec4( 1.0, 256.0, 256.0 * 256.0, 256.0 * 256.0 * 256.0 );
const vec2 UnpackFactors2 = vec2( UnpackDownscale, 1.0 / PackFactors.g );
const vec3 UnpackFactors3 = vec3( UnpackDownscale / PackFactors.rg, 1.0 / PackFactors.b );
const vec4 UnpackFactors4 = vec4( UnpackDownscale / PackFactors.rgb, 1.0 / PackFactors.a );
vec4 packDepthToRGBA( const in float v ) {
	if( v <= 0.0 )
		return vec4( 0., 0., 0., 0. );
	if( v >= 1.0 )
		return vec4( 1., 1., 1., 1. );
	float vuf;
	float af = modf( v * PackFactors.a, vuf );
	float bf = modf( vuf * ShiftRight8, vuf );
	float gf = modf( vuf * ShiftRight8, vuf );
	return vec4( vuf * Inv255, gf * PackUpscale, bf * PackUpscale, af );
}
vec3 packDepthToRGB( const in float v ) {
	if( v <= 0.0 )
		return vec3( 0., 0., 0. );
	if( v >= 1.0 )
		return vec3( 1., 1., 1. );
	float vuf;
	float bf = modf( v * PackFactors.b, vuf );
	float gf = modf( vuf * ShiftRight8, vuf );
	return vec3( vuf * Inv255, gf * PackUpscale, bf );
}
vec2 packDepthToRG( const in float v ) {
	if( v <= 0.0 )
		return vec2( 0., 0. );
	if( v >= 1.0 )
		return vec2( 1., 1. );
	float vuf;
	float gf = modf( v * 256., vuf );
	return vec2( vuf * Inv255, gf );
}
float unpackRGBAToDepth( const in vec4 v ) {
	return dot( v, UnpackFactors4 );
}
float unpackRGBToDepth( const in vec3 v ) {
	return dot( v, UnpackFactors3 );
}
float unpackRGToDepth( const in vec2 v ) {
	return v.r * UnpackFactors2.r + v.g * UnpackFactors2.g;
}
vec4 pack2HalfToRGBA( const in vec2 v ) {
	vec4 r = vec4( v.x, fract( v.x * 255.0 ), v.y, fract( v.y * 255.0 ) );
	return vec4( r.x - r.y / 255.0, r.y, r.z - r.w / 255.0, r.w );
}
vec2 unpackRGBATo2Half( const in vec4 v ) {
	return vec2( v.x + ( v.y / 255.0 ), v.z + ( v.w / 255.0 ) );
}
float viewZToOrthographicDepth( const in float viewZ, const in float near, const in float far ) {
	return ( viewZ + near ) / ( near - far );
}
float orthographicDepthToViewZ( const in float depth, const in float near, const in float far ) {
	return depth * ( near - far ) - near;
}
float viewZToPerspectiveDepth( const in float viewZ, const in float near, const in float far ) {
	return ( ( near + viewZ ) * far ) / ( ( far - near ) * viewZ );
}
float perspectiveDepthToViewZ( const in float depth, const in float near, const in float far ) {
	return ( near * far ) / ( ( far - near ) * depth - far );
}`,Dg=`#ifdef PREMULTIPLIED_ALPHA
	gl_FragColor.rgb *= gl_FragColor.a;
#endif`,Ug=`vec4 mvPosition = vec4( transformed, 1.0 );
#ifdef USE_BATCHING
	mvPosition = batchingMatrix * mvPosition;
#endif
#ifdef USE_INSTANCING
	mvPosition = instanceMatrix * mvPosition;
#endif
mvPosition = modelViewMatrix * mvPosition;
gl_Position = projectionMatrix * mvPosition;`,Ng=`#ifdef DITHERING
	gl_FragColor.rgb = dithering( gl_FragColor.rgb );
#endif`,Fg=`#ifdef DITHERING
	vec3 dithering( vec3 color ) {
		float grid_position = rand( gl_FragCoord.xy );
		vec3 dither_shift_RGB = vec3( 0.25 / 255.0, -0.25 / 255.0, 0.25 / 255.0 );
		dither_shift_RGB = mix( 2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position );
		return color + dither_shift_RGB;
	}
#endif`,kg=`float roughnessFactor = roughness;
#ifdef USE_ROUGHNESSMAP
	vec4 texelRoughness = texture2D( roughnessMap, vRoughnessMapUv );
	roughnessFactor *= texelRoughness.g;
#endif`,Bg=`#ifdef USE_ROUGHNESSMAP
	uniform sampler2D roughnessMap;
#endif`,Og=`#if NUM_SPOT_LIGHT_COORDS > 0
	varying vec4 vSpotLightCoord[ NUM_SPOT_LIGHT_COORDS ];
#endif
#if NUM_SPOT_LIGHT_MAPS > 0
	uniform sampler2D spotLightMap[ NUM_SPOT_LIGHT_MAPS ];
#endif
#ifdef USE_SHADOWMAP
	#if NUM_DIR_LIGHT_SHADOWS > 0
		uniform sampler2D directionalShadowMap[ NUM_DIR_LIGHT_SHADOWS ];
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHT_SHADOWS ];
		struct DirectionalLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform DirectionalLightShadow directionalLightShadows[ NUM_DIR_LIGHT_SHADOWS ];
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
		uniform sampler2D spotShadowMap[ NUM_SPOT_LIGHT_SHADOWS ];
		struct SpotLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform SpotLightShadow spotLightShadows[ NUM_SPOT_LIGHT_SHADOWS ];
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		uniform sampler2D pointShadowMap[ NUM_POINT_LIGHT_SHADOWS ];
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHT_SHADOWS ];
		struct PointLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
			float shadowCameraNear;
			float shadowCameraFar;
		};
		uniform PointLightShadow pointLightShadows[ NUM_POINT_LIGHT_SHADOWS ];
	#endif
	float texture2DCompare( sampler2D depths, vec2 uv, float compare ) {
		float depth = unpackRGBAToDepth( texture2D( depths, uv ) );
		#ifdef USE_REVERSED_DEPTH_BUFFER
			return step( depth, compare );
		#else
			return step( compare, depth );
		#endif
	}
	vec2 texture2DDistribution( sampler2D shadow, vec2 uv ) {
		return unpackRGBATo2Half( texture2D( shadow, uv ) );
	}
	float VSMShadow( sampler2D shadow, vec2 uv, float compare ) {
		float occlusion = 1.0;
		vec2 distribution = texture2DDistribution( shadow, uv );
		#ifdef USE_REVERSED_DEPTH_BUFFER
			float hard_shadow = step( distribution.x, compare );
		#else
			float hard_shadow = step( compare, distribution.x );
		#endif
		if ( hard_shadow != 1.0 ) {
			float distance = compare - distribution.x;
			float variance = max( 0.00000, distribution.y * distribution.y );
			float softness_probability = variance / (variance + distance * distance );			softness_probability = clamp( ( softness_probability - 0.3 ) / ( 0.95 - 0.3 ), 0.0, 1.0 );			occlusion = clamp( max( hard_shadow, softness_probability ), 0.0, 1.0 );
		}
		return occlusion;
	}
	float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord ) {
		float shadow = 1.0;
		shadowCoord.xyz /= shadowCoord.w;
		shadowCoord.z += shadowBias;
		bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
		bool frustumTest = inFrustum && shadowCoord.z <= 1.0;
		if ( frustumTest ) {
		#if defined( SHADOWMAP_TYPE_PCF )
			vec2 texelSize = vec2( 1.0 ) / shadowMapSize;
			float dx0 = - texelSize.x * shadowRadius;
			float dy0 = - texelSize.y * shadowRadius;
			float dx1 = + texelSize.x * shadowRadius;
			float dy1 = + texelSize.y * shadowRadius;
			float dx2 = dx0 / 2.0;
			float dy2 = dy0 / 2.0;
			float dx3 = dx1 / 2.0;
			float dy3 = dy1 / 2.0;
			shadow = (
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, dy0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, dy0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx2, dy2 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy2 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx3, dy2 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx2, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy, shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx3, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx2, dy3 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy3 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx3, dy3 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, dy1 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy1 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, dy1 ), shadowCoord.z )
			) * ( 1.0 / 17.0 );
		#elif defined( SHADOWMAP_TYPE_PCF_SOFT )
			vec2 texelSize = vec2( 1.0 ) / shadowMapSize;
			float dx = texelSize.x;
			float dy = texelSize.y;
			vec2 uv = shadowCoord.xy;
			vec2 f = fract( uv * shadowMapSize + 0.5 );
			uv -= f * texelSize;
			shadow = (
				texture2DCompare( shadowMap, uv, shadowCoord.z ) +
				texture2DCompare( shadowMap, uv + vec2( dx, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, uv + vec2( 0.0, dy ), shadowCoord.z ) +
				texture2DCompare( shadowMap, uv + texelSize, shadowCoord.z ) +
				mix( texture2DCompare( shadowMap, uv + vec2( -dx, 0.0 ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, 0.0 ), shadowCoord.z ),
					 f.x ) +
				mix( texture2DCompare( shadowMap, uv + vec2( -dx, dy ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, dy ), shadowCoord.z ),
					 f.x ) +
				mix( texture2DCompare( shadowMap, uv + vec2( 0.0, -dy ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( 0.0, 2.0 * dy ), shadowCoord.z ),
					 f.y ) +
				mix( texture2DCompare( shadowMap, uv + vec2( dx, -dy ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( dx, 2.0 * dy ), shadowCoord.z ),
					 f.y ) +
				mix( mix( texture2DCompare( shadowMap, uv + vec2( -dx, -dy ), shadowCoord.z ),
						  texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, -dy ), shadowCoord.z ),
						  f.x ),
					 mix( texture2DCompare( shadowMap, uv + vec2( -dx, 2.0 * dy ), shadowCoord.z ),
						  texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, 2.0 * dy ), shadowCoord.z ),
						  f.x ),
					 f.y )
			) * ( 1.0 / 9.0 );
		#elif defined( SHADOWMAP_TYPE_VSM )
			shadow = VSMShadow( shadowMap, shadowCoord.xy, shadowCoord.z );
		#else
			shadow = texture2DCompare( shadowMap, shadowCoord.xy, shadowCoord.z );
		#endif
		}
		return mix( 1.0, shadow, shadowIntensity );
	}
	vec2 cubeToUV( vec3 v, float texelSizeY ) {
		vec3 absV = abs( v );
		float scaleToCube = 1.0 / max( absV.x, max( absV.y, absV.z ) );
		absV *= scaleToCube;
		v *= scaleToCube * ( 1.0 - 2.0 * texelSizeY );
		vec2 planar = v.xy;
		float almostATexel = 1.5 * texelSizeY;
		float almostOne = 1.0 - almostATexel;
		if ( absV.z >= almostOne ) {
			if ( v.z > 0.0 )
				planar.x = 4.0 - v.x;
		} else if ( absV.x >= almostOne ) {
			float signX = sign( v.x );
			planar.x = v.z * signX + 2.0 * signX;
		} else if ( absV.y >= almostOne ) {
			float signY = sign( v.y );
			planar.x = v.x + 2.0 * signY + 2.0;
			planar.y = v.z * signY - 2.0;
		}
		return vec2( 0.125, 0.25 ) * planar + vec2( 0.375, 0.75 );
	}
	float getPointShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord, float shadowCameraNear, float shadowCameraFar ) {
		float shadow = 1.0;
		vec3 lightToPosition = shadowCoord.xyz;
		
		float lightToPositionLength = length( lightToPosition );
		if ( lightToPositionLength - shadowCameraFar <= 0.0 && lightToPositionLength - shadowCameraNear >= 0.0 ) {
			float dp = ( lightToPositionLength - shadowCameraNear ) / ( shadowCameraFar - shadowCameraNear );			dp += shadowBias;
			vec3 bd3D = normalize( lightToPosition );
			vec2 texelSize = vec2( 1.0 ) / ( shadowMapSize * vec2( 4.0, 2.0 ) );
			#if defined( SHADOWMAP_TYPE_PCF ) || defined( SHADOWMAP_TYPE_PCF_SOFT ) || defined( SHADOWMAP_TYPE_VSM )
				vec2 offset = vec2( - 1, 1 ) * shadowRadius * texelSize.y;
				shadow = (
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyy, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyy, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyx, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyx, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxy, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxy, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxx, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxx, texelSize.y ), dp )
				) * ( 1.0 / 9.0 );
			#else
				shadow = texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp );
			#endif
		}
		return mix( 1.0, shadow, shadowIntensity );
	}
#endif`,zg=`#if NUM_SPOT_LIGHT_COORDS > 0
	uniform mat4 spotLightMatrix[ NUM_SPOT_LIGHT_COORDS ];
	varying vec4 vSpotLightCoord[ NUM_SPOT_LIGHT_COORDS ];
#endif
#ifdef USE_SHADOWMAP
	#if NUM_DIR_LIGHT_SHADOWS > 0
		uniform mat4 directionalShadowMatrix[ NUM_DIR_LIGHT_SHADOWS ];
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHT_SHADOWS ];
		struct DirectionalLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform DirectionalLightShadow directionalLightShadows[ NUM_DIR_LIGHT_SHADOWS ];
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
		struct SpotLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform SpotLightShadow spotLightShadows[ NUM_SPOT_LIGHT_SHADOWS ];
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		uniform mat4 pointShadowMatrix[ NUM_POINT_LIGHT_SHADOWS ];
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHT_SHADOWS ];
		struct PointLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
			float shadowCameraNear;
			float shadowCameraFar;
		};
		uniform PointLightShadow pointLightShadows[ NUM_POINT_LIGHT_SHADOWS ];
	#endif
#endif`,Hg=`#if ( defined( USE_SHADOWMAP ) && ( NUM_DIR_LIGHT_SHADOWS > 0 || NUM_POINT_LIGHT_SHADOWS > 0 ) ) || ( NUM_SPOT_LIGHT_COORDS > 0 )
	vec3 shadowWorldNormal = inverseTransformDirection( transformedNormal, viewMatrix );
	vec4 shadowWorldPosition;
#endif
#if defined( USE_SHADOWMAP )
	#if NUM_DIR_LIGHT_SHADOWS > 0
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_DIR_LIGHT_SHADOWS; i ++ ) {
			shadowWorldPosition = worldPosition + vec4( shadowWorldNormal * directionalLightShadows[ i ].shadowNormalBias, 0 );
			vDirectionalShadowCoord[ i ] = directionalShadowMatrix[ i ] * shadowWorldPosition;
		}
		#pragma unroll_loop_end
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_POINT_LIGHT_SHADOWS; i ++ ) {
			shadowWorldPosition = worldPosition + vec4( shadowWorldNormal * pointLightShadows[ i ].shadowNormalBias, 0 );
			vPointShadowCoord[ i ] = pointShadowMatrix[ i ] * shadowWorldPosition;
		}
		#pragma unroll_loop_end
	#endif
#endif
#if NUM_SPOT_LIGHT_COORDS > 0
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHT_COORDS; i ++ ) {
		shadowWorldPosition = worldPosition;
		#if ( defined( USE_SHADOWMAP ) && UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
			shadowWorldPosition.xyz += shadowWorldNormal * spotLightShadows[ i ].shadowNormalBias;
		#endif
		vSpotLightCoord[ i ] = spotLightMatrix[ i ] * shadowWorldPosition;
	}
	#pragma unroll_loop_end
#endif`,Vg=`float getShadowMask() {
	float shadow = 1.0;
	#ifdef USE_SHADOWMAP
	#if NUM_DIR_LIGHT_SHADOWS > 0
	DirectionalLightShadow directionalLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_DIR_LIGHT_SHADOWS; i ++ ) {
		directionalLight = directionalLightShadows[ i ];
		shadow *= receiveShadow ? getShadow( directionalShadowMap[ i ], directionalLight.shadowMapSize, directionalLight.shadowIntensity, directionalLight.shadowBias, directionalLight.shadowRadius, vDirectionalShadowCoord[ i ] ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
	SpotLightShadow spotLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHT_SHADOWS; i ++ ) {
		spotLight = spotLightShadows[ i ];
		shadow *= receiveShadow ? getShadow( spotShadowMap[ i ], spotLight.shadowMapSize, spotLight.shadowIntensity, spotLight.shadowBias, spotLight.shadowRadius, vSpotLightCoord[ i ] ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
	PointLightShadow pointLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_POINT_LIGHT_SHADOWS; i ++ ) {
		pointLight = pointLightShadows[ i ];
		shadow *= receiveShadow ? getPointShadow( pointShadowMap[ i ], pointLight.shadowMapSize, pointLight.shadowIntensity, pointLight.shadowBias, pointLight.shadowRadius, vPointShadowCoord[ i ], pointLight.shadowCameraNear, pointLight.shadowCameraFar ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#endif
	return shadow;
}`,Gg=`#ifdef USE_SKINNING
	mat4 boneMatX = getBoneMatrix( skinIndex.x );
	mat4 boneMatY = getBoneMatrix( skinIndex.y );
	mat4 boneMatZ = getBoneMatrix( skinIndex.z );
	mat4 boneMatW = getBoneMatrix( skinIndex.w );
#endif`,Wg=`#ifdef USE_SKINNING
	uniform mat4 bindMatrix;
	uniform mat4 bindMatrixInverse;
	uniform highp sampler2D boneTexture;
	mat4 getBoneMatrix( const in float i ) {
		int size = textureSize( boneTexture, 0 ).x;
		int j = int( i ) * 4;
		int x = j % size;
		int y = j / size;
		vec4 v1 = texelFetch( boneTexture, ivec2( x, y ), 0 );
		vec4 v2 = texelFetch( boneTexture, ivec2( x + 1, y ), 0 );
		vec4 v3 = texelFetch( boneTexture, ivec2( x + 2, y ), 0 );
		vec4 v4 = texelFetch( boneTexture, ivec2( x + 3, y ), 0 );
		return mat4( v1, v2, v3, v4 );
	}
#endif`,Xg=`#ifdef USE_SKINNING
	vec4 skinVertex = bindMatrix * vec4( transformed, 1.0 );
	vec4 skinned = vec4( 0.0 );
	skinned += boneMatX * skinVertex * skinWeight.x;
	skinned += boneMatY * skinVertex * skinWeight.y;
	skinned += boneMatZ * skinVertex * skinWeight.z;
	skinned += boneMatW * skinVertex * skinWeight.w;
	transformed = ( bindMatrixInverse * skinned ).xyz;
#endif`,qg=`#ifdef USE_SKINNING
	mat4 skinMatrix = mat4( 0.0 );
	skinMatrix += skinWeight.x * boneMatX;
	skinMatrix += skinWeight.y * boneMatY;
	skinMatrix += skinWeight.z * boneMatZ;
	skinMatrix += skinWeight.w * boneMatW;
	skinMatrix = bindMatrixInverse * skinMatrix * bindMatrix;
	objectNormal = vec4( skinMatrix * vec4( objectNormal, 0.0 ) ).xyz;
	#ifdef USE_TANGENT
		objectTangent = vec4( skinMatrix * vec4( objectTangent, 0.0 ) ).xyz;
	#endif
#endif`,Yg=`float specularStrength;
#ifdef USE_SPECULARMAP
	vec4 texelSpecular = texture2D( specularMap, vSpecularMapUv );
	specularStrength = texelSpecular.r;
#else
	specularStrength = 1.0;
#endif`,Zg=`#ifdef USE_SPECULARMAP
	uniform sampler2D specularMap;
#endif`,$g=`#if defined( TONE_MAPPING )
	gl_FragColor.rgb = toneMapping( gl_FragColor.rgb );
#endif`,Jg=`#ifndef saturate
#define saturate( a ) clamp( a, 0.0, 1.0 )
#endif
uniform float toneMappingExposure;
vec3 LinearToneMapping( vec3 color ) {
	return saturate( toneMappingExposure * color );
}
vec3 ReinhardToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	return saturate( color / ( vec3( 1.0 ) + color ) );
}
vec3 CineonToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	color = max( vec3( 0.0 ), color - 0.004 );
	return pow( ( color * ( 6.2 * color + 0.5 ) ) / ( color * ( 6.2 * color + 1.7 ) + 0.06 ), vec3( 2.2 ) );
}
vec3 RRTAndODTFit( vec3 v ) {
	vec3 a = v * ( v + 0.0245786 ) - 0.000090537;
	vec3 b = v * ( 0.983729 * v + 0.4329510 ) + 0.238081;
	return a / b;
}
vec3 ACESFilmicToneMapping( vec3 color ) {
	const mat3 ACESInputMat = mat3(
		vec3( 0.59719, 0.07600, 0.02840 ),		vec3( 0.35458, 0.90834, 0.13383 ),
		vec3( 0.04823, 0.01566, 0.83777 )
	);
	const mat3 ACESOutputMat = mat3(
		vec3(  1.60475, -0.10208, -0.00327 ),		vec3( -0.53108,  1.10813, -0.07276 ),
		vec3( -0.07367, -0.00605,  1.07602 )
	);
	color *= toneMappingExposure / 0.6;
	color = ACESInputMat * color;
	color = RRTAndODTFit( color );
	color = ACESOutputMat * color;
	return saturate( color );
}
const mat3 LINEAR_REC2020_TO_LINEAR_SRGB = mat3(
	vec3( 1.6605, - 0.1246, - 0.0182 ),
	vec3( - 0.5876, 1.1329, - 0.1006 ),
	vec3( - 0.0728, - 0.0083, 1.1187 )
);
const mat3 LINEAR_SRGB_TO_LINEAR_REC2020 = mat3(
	vec3( 0.6274, 0.0691, 0.0164 ),
	vec3( 0.3293, 0.9195, 0.0880 ),
	vec3( 0.0433, 0.0113, 0.8956 )
);
vec3 agxDefaultContrastApprox( vec3 x ) {
	vec3 x2 = x * x;
	vec3 x4 = x2 * x2;
	return + 15.5 * x4 * x2
		- 40.14 * x4 * x
		+ 31.96 * x4
		- 6.868 * x2 * x
		+ 0.4298 * x2
		+ 0.1191 * x
		- 0.00232;
}
vec3 AgXToneMapping( vec3 color ) {
	const mat3 AgXInsetMatrix = mat3(
		vec3( 0.856627153315983, 0.137318972929847, 0.11189821299995 ),
		vec3( 0.0951212405381588, 0.761241990602591, 0.0767994186031903 ),
		vec3( 0.0482516061458583, 0.101439036467562, 0.811302368396859 )
	);
	const mat3 AgXOutsetMatrix = mat3(
		vec3( 1.1271005818144368, - 0.1413297634984383, - 0.14132976349843826 ),
		vec3( - 0.11060664309660323, 1.157823702216272, - 0.11060664309660294 ),
		vec3( - 0.016493938717834573, - 0.016493938717834257, 1.2519364065950405 )
	);
	const float AgxMinEv = - 12.47393;	const float AgxMaxEv = 4.026069;
	color *= toneMappingExposure;
	color = LINEAR_SRGB_TO_LINEAR_REC2020 * color;
	color = AgXInsetMatrix * color;
	color = max( color, 1e-10 );	color = log2( color );
	color = ( color - AgxMinEv ) / ( AgxMaxEv - AgxMinEv );
	color = clamp( color, 0.0, 1.0 );
	color = agxDefaultContrastApprox( color );
	color = AgXOutsetMatrix * color;
	color = pow( max( vec3( 0.0 ), color ), vec3( 2.2 ) );
	color = LINEAR_REC2020_TO_LINEAR_SRGB * color;
	color = clamp( color, 0.0, 1.0 );
	return color;
}
vec3 NeutralToneMapping( vec3 color ) {
	const float StartCompression = 0.8 - 0.04;
	const float Desaturation = 0.15;
	color *= toneMappingExposure;
	float x = min( color.r, min( color.g, color.b ) );
	float offset = x < 0.08 ? x - 6.25 * x * x : 0.04;
	color -= offset;
	float peak = max( color.r, max( color.g, color.b ) );
	if ( peak < StartCompression ) return color;
	float d = 1. - StartCompression;
	float newPeak = 1. - d * d / ( peak + d - StartCompression );
	color *= newPeak / peak;
	float g = 1. - 1. / ( Desaturation * ( peak - newPeak ) + 1. );
	return mix( color, vec3( newPeak ), g );
}
vec3 CustomToneMapping( vec3 color ) { return color; }`,Kg=`#ifdef USE_TRANSMISSION
	material.transmission = transmission;
	material.transmissionAlpha = 1.0;
	material.thickness = thickness;
	material.attenuationDistance = attenuationDistance;
	material.attenuationColor = attenuationColor;
	#ifdef USE_TRANSMISSIONMAP
		material.transmission *= texture2D( transmissionMap, vTransmissionMapUv ).r;
	#endif
	#ifdef USE_THICKNESSMAP
		material.thickness *= texture2D( thicknessMap, vThicknessMapUv ).g;
	#endif
	vec3 pos = vWorldPosition;
	vec3 v = normalize( cameraPosition - pos );
	vec3 n = inverseTransformDirection( normal, viewMatrix );
	vec4 transmitted = getIBLVolumeRefraction(
		n, v, material.roughness, material.diffuseColor, material.specularColor, material.specularF90,
		pos, modelMatrix, viewMatrix, projectionMatrix, material.dispersion, material.ior, material.thickness,
		material.attenuationColor, material.attenuationDistance );
	material.transmissionAlpha = mix( material.transmissionAlpha, transmitted.a, material.transmission );
	totalDiffuse = mix( totalDiffuse, transmitted.rgb, material.transmission );
#endif`,jg=`#ifdef USE_TRANSMISSION
	uniform float transmission;
	uniform float thickness;
	uniform float attenuationDistance;
	uniform vec3 attenuationColor;
	#ifdef USE_TRANSMISSIONMAP
		uniform sampler2D transmissionMap;
	#endif
	#ifdef USE_THICKNESSMAP
		uniform sampler2D thicknessMap;
	#endif
	uniform vec2 transmissionSamplerSize;
	uniform sampler2D transmissionSamplerMap;
	uniform mat4 modelMatrix;
	uniform mat4 projectionMatrix;
	varying vec3 vWorldPosition;
	float w0( float a ) {
		return ( 1.0 / 6.0 ) * ( a * ( a * ( - a + 3.0 ) - 3.0 ) + 1.0 );
	}
	float w1( float a ) {
		return ( 1.0 / 6.0 ) * ( a *  a * ( 3.0 * a - 6.0 ) + 4.0 );
	}
	float w2( float a ){
		return ( 1.0 / 6.0 ) * ( a * ( a * ( - 3.0 * a + 3.0 ) + 3.0 ) + 1.0 );
	}
	float w3( float a ) {
		return ( 1.0 / 6.0 ) * ( a * a * a );
	}
	float g0( float a ) {
		return w0( a ) + w1( a );
	}
	float g1( float a ) {
		return w2( a ) + w3( a );
	}
	float h0( float a ) {
		return - 1.0 + w1( a ) / ( w0( a ) + w1( a ) );
	}
	float h1( float a ) {
		return 1.0 + w3( a ) / ( w2( a ) + w3( a ) );
	}
	vec4 bicubic( sampler2D tex, vec2 uv, vec4 texelSize, float lod ) {
		uv = uv * texelSize.zw + 0.5;
		vec2 iuv = floor( uv );
		vec2 fuv = fract( uv );
		float g0x = g0( fuv.x );
		float g1x = g1( fuv.x );
		float h0x = h0( fuv.x );
		float h1x = h1( fuv.x );
		float h0y = h0( fuv.y );
		float h1y = h1( fuv.y );
		vec2 p0 = ( vec2( iuv.x + h0x, iuv.y + h0y ) - 0.5 ) * texelSize.xy;
		vec2 p1 = ( vec2( iuv.x + h1x, iuv.y + h0y ) - 0.5 ) * texelSize.xy;
		vec2 p2 = ( vec2( iuv.x + h0x, iuv.y + h1y ) - 0.5 ) * texelSize.xy;
		vec2 p3 = ( vec2( iuv.x + h1x, iuv.y + h1y ) - 0.5 ) * texelSize.xy;
		return g0( fuv.y ) * ( g0x * textureLod( tex, p0, lod ) + g1x * textureLod( tex, p1, lod ) ) +
			g1( fuv.y ) * ( g0x * textureLod( tex, p2, lod ) + g1x * textureLod( tex, p3, lod ) );
	}
	vec4 textureBicubic( sampler2D sampler, vec2 uv, float lod ) {
		vec2 fLodSize = vec2( textureSize( sampler, int( lod ) ) );
		vec2 cLodSize = vec2( textureSize( sampler, int( lod + 1.0 ) ) );
		vec2 fLodSizeInv = 1.0 / fLodSize;
		vec2 cLodSizeInv = 1.0 / cLodSize;
		vec4 fSample = bicubic( sampler, uv, vec4( fLodSizeInv, fLodSize ), floor( lod ) );
		vec4 cSample = bicubic( sampler, uv, vec4( cLodSizeInv, cLodSize ), ceil( lod ) );
		return mix( fSample, cSample, fract( lod ) );
	}
	vec3 getVolumeTransmissionRay( const in vec3 n, const in vec3 v, const in float thickness, const in float ior, const in mat4 modelMatrix ) {
		vec3 refractionVector = refract( - v, normalize( n ), 1.0 / ior );
		vec3 modelScale;
		modelScale.x = length( vec3( modelMatrix[ 0 ].xyz ) );
		modelScale.y = length( vec3( modelMatrix[ 1 ].xyz ) );
		modelScale.z = length( vec3( modelMatrix[ 2 ].xyz ) );
		return normalize( refractionVector ) * thickness * modelScale;
	}
	float applyIorToRoughness( const in float roughness, const in float ior ) {
		return roughness * clamp( ior * 2.0 - 2.0, 0.0, 1.0 );
	}
	vec4 getTransmissionSample( const in vec2 fragCoord, const in float roughness, const in float ior ) {
		float lod = log2( transmissionSamplerSize.x ) * applyIorToRoughness( roughness, ior );
		return textureBicubic( transmissionSamplerMap, fragCoord.xy, lod );
	}
	vec3 volumeAttenuation( const in float transmissionDistance, const in vec3 attenuationColor, const in float attenuationDistance ) {
		if ( isinf( attenuationDistance ) ) {
			return vec3( 1.0 );
		} else {
			vec3 attenuationCoefficient = -log( attenuationColor ) / attenuationDistance;
			vec3 transmittance = exp( - attenuationCoefficient * transmissionDistance );			return transmittance;
		}
	}
	vec4 getIBLVolumeRefraction( const in vec3 n, const in vec3 v, const in float roughness, const in vec3 diffuseColor,
		const in vec3 specularColor, const in float specularF90, const in vec3 position, const in mat4 modelMatrix,
		const in mat4 viewMatrix, const in mat4 projMatrix, const in float dispersion, const in float ior, const in float thickness,
		const in vec3 attenuationColor, const in float attenuationDistance ) {
		vec4 transmittedLight;
		vec3 transmittance;
		#ifdef USE_DISPERSION
			float halfSpread = ( ior - 1.0 ) * 0.025 * dispersion;
			vec3 iors = vec3( ior - halfSpread, ior, ior + halfSpread );
			for ( int i = 0; i < 3; i ++ ) {
				vec3 transmissionRay = getVolumeTransmissionRay( n, v, thickness, iors[ i ], modelMatrix );
				vec3 refractedRayExit = position + transmissionRay;
				vec4 ndcPos = projMatrix * viewMatrix * vec4( refractedRayExit, 1.0 );
				vec2 refractionCoords = ndcPos.xy / ndcPos.w;
				refractionCoords += 1.0;
				refractionCoords /= 2.0;
				vec4 transmissionSample = getTransmissionSample( refractionCoords, roughness, iors[ i ] );
				transmittedLight[ i ] = transmissionSample[ i ];
				transmittedLight.a += transmissionSample.a;
				transmittance[ i ] = diffuseColor[ i ] * volumeAttenuation( length( transmissionRay ), attenuationColor, attenuationDistance )[ i ];
			}
			transmittedLight.a /= 3.0;
		#else
			vec3 transmissionRay = getVolumeTransmissionRay( n, v, thickness, ior, modelMatrix );
			vec3 refractedRayExit = position + transmissionRay;
			vec4 ndcPos = projMatrix * viewMatrix * vec4( refractedRayExit, 1.0 );
			vec2 refractionCoords = ndcPos.xy / ndcPos.w;
			refractionCoords += 1.0;
			refractionCoords /= 2.0;
			transmittedLight = getTransmissionSample( refractionCoords, roughness, ior );
			transmittance = diffuseColor * volumeAttenuation( length( transmissionRay ), attenuationColor, attenuationDistance );
		#endif
		vec3 attenuatedColor = transmittance * transmittedLight.rgb;
		vec3 F = EnvironmentBRDF( n, v, specularColor, specularF90, roughness );
		float transmittanceFactor = ( transmittance.r + transmittance.g + transmittance.b ) / 3.0;
		return vec4( ( 1.0 - F ) * attenuatedColor, 1.0 - ( 1.0 - transmittedLight.a ) * transmittanceFactor );
	}
#endif`,Qg=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	varying vec2 vUv;
#endif
#ifdef USE_MAP
	varying vec2 vMapUv;
#endif
#ifdef USE_ALPHAMAP
	varying vec2 vAlphaMapUv;
#endif
#ifdef USE_LIGHTMAP
	varying vec2 vLightMapUv;
#endif
#ifdef USE_AOMAP
	varying vec2 vAoMapUv;
#endif
#ifdef USE_BUMPMAP
	varying vec2 vBumpMapUv;
#endif
#ifdef USE_NORMALMAP
	varying vec2 vNormalMapUv;
#endif
#ifdef USE_EMISSIVEMAP
	varying vec2 vEmissiveMapUv;
#endif
#ifdef USE_METALNESSMAP
	varying vec2 vMetalnessMapUv;
#endif
#ifdef USE_ROUGHNESSMAP
	varying vec2 vRoughnessMapUv;
#endif
#ifdef USE_ANISOTROPYMAP
	varying vec2 vAnisotropyMapUv;
#endif
#ifdef USE_CLEARCOATMAP
	varying vec2 vClearcoatMapUv;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	varying vec2 vClearcoatNormalMapUv;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	varying vec2 vClearcoatRoughnessMapUv;
#endif
#ifdef USE_IRIDESCENCEMAP
	varying vec2 vIridescenceMapUv;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	varying vec2 vIridescenceThicknessMapUv;
#endif
#ifdef USE_SHEEN_COLORMAP
	varying vec2 vSheenColorMapUv;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	varying vec2 vSheenRoughnessMapUv;
#endif
#ifdef USE_SPECULARMAP
	varying vec2 vSpecularMapUv;
#endif
#ifdef USE_SPECULAR_COLORMAP
	varying vec2 vSpecularColorMapUv;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	varying vec2 vSpecularIntensityMapUv;
#endif
#ifdef USE_TRANSMISSIONMAP
	uniform mat3 transmissionMapTransform;
	varying vec2 vTransmissionMapUv;
#endif
#ifdef USE_THICKNESSMAP
	uniform mat3 thicknessMapTransform;
	varying vec2 vThicknessMapUv;
#endif`,tx=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	varying vec2 vUv;
#endif
#ifdef USE_MAP
	uniform mat3 mapTransform;
	varying vec2 vMapUv;
#endif
#ifdef USE_ALPHAMAP
	uniform mat3 alphaMapTransform;
	varying vec2 vAlphaMapUv;
#endif
#ifdef USE_LIGHTMAP
	uniform mat3 lightMapTransform;
	varying vec2 vLightMapUv;
#endif
#ifdef USE_AOMAP
	uniform mat3 aoMapTransform;
	varying vec2 vAoMapUv;
#endif
#ifdef USE_BUMPMAP
	uniform mat3 bumpMapTransform;
	varying vec2 vBumpMapUv;
#endif
#ifdef USE_NORMALMAP
	uniform mat3 normalMapTransform;
	varying vec2 vNormalMapUv;
#endif
#ifdef USE_DISPLACEMENTMAP
	uniform mat3 displacementMapTransform;
	varying vec2 vDisplacementMapUv;
#endif
#ifdef USE_EMISSIVEMAP
	uniform mat3 emissiveMapTransform;
	varying vec2 vEmissiveMapUv;
#endif
#ifdef USE_METALNESSMAP
	uniform mat3 metalnessMapTransform;
	varying vec2 vMetalnessMapUv;
#endif
#ifdef USE_ROUGHNESSMAP
	uniform mat3 roughnessMapTransform;
	varying vec2 vRoughnessMapUv;
#endif
#ifdef USE_ANISOTROPYMAP
	uniform mat3 anisotropyMapTransform;
	varying vec2 vAnisotropyMapUv;
#endif
#ifdef USE_CLEARCOATMAP
	uniform mat3 clearcoatMapTransform;
	varying vec2 vClearcoatMapUv;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	uniform mat3 clearcoatNormalMapTransform;
	varying vec2 vClearcoatNormalMapUv;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	uniform mat3 clearcoatRoughnessMapTransform;
	varying vec2 vClearcoatRoughnessMapUv;
#endif
#ifdef USE_SHEEN_COLORMAP
	uniform mat3 sheenColorMapTransform;
	varying vec2 vSheenColorMapUv;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	uniform mat3 sheenRoughnessMapTransform;
	varying vec2 vSheenRoughnessMapUv;
#endif
#ifdef USE_IRIDESCENCEMAP
	uniform mat3 iridescenceMapTransform;
	varying vec2 vIridescenceMapUv;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	uniform mat3 iridescenceThicknessMapTransform;
	varying vec2 vIridescenceThicknessMapUv;
#endif
#ifdef USE_SPECULARMAP
	uniform mat3 specularMapTransform;
	varying vec2 vSpecularMapUv;
#endif
#ifdef USE_SPECULAR_COLORMAP
	uniform mat3 specularColorMapTransform;
	varying vec2 vSpecularColorMapUv;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	uniform mat3 specularIntensityMapTransform;
	varying vec2 vSpecularIntensityMapUv;
#endif
#ifdef USE_TRANSMISSIONMAP
	uniform mat3 transmissionMapTransform;
	varying vec2 vTransmissionMapUv;
#endif
#ifdef USE_THICKNESSMAP
	uniform mat3 thicknessMapTransform;
	varying vec2 vThicknessMapUv;
#endif`,ex=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	vUv = vec3( uv, 1 ).xy;
#endif
#ifdef USE_MAP
	vMapUv = ( mapTransform * vec3( MAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ALPHAMAP
	vAlphaMapUv = ( alphaMapTransform * vec3( ALPHAMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_LIGHTMAP
	vLightMapUv = ( lightMapTransform * vec3( LIGHTMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_AOMAP
	vAoMapUv = ( aoMapTransform * vec3( AOMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_BUMPMAP
	vBumpMapUv = ( bumpMapTransform * vec3( BUMPMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_NORMALMAP
	vNormalMapUv = ( normalMapTransform * vec3( NORMALMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_DISPLACEMENTMAP
	vDisplacementMapUv = ( displacementMapTransform * vec3( DISPLACEMENTMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_EMISSIVEMAP
	vEmissiveMapUv = ( emissiveMapTransform * vec3( EMISSIVEMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_METALNESSMAP
	vMetalnessMapUv = ( metalnessMapTransform * vec3( METALNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ROUGHNESSMAP
	vRoughnessMapUv = ( roughnessMapTransform * vec3( ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ANISOTROPYMAP
	vAnisotropyMapUv = ( anisotropyMapTransform * vec3( ANISOTROPYMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOATMAP
	vClearcoatMapUv = ( clearcoatMapTransform * vec3( CLEARCOATMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	vClearcoatNormalMapUv = ( clearcoatNormalMapTransform * vec3( CLEARCOAT_NORMALMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	vClearcoatRoughnessMapUv = ( clearcoatRoughnessMapTransform * vec3( CLEARCOAT_ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_IRIDESCENCEMAP
	vIridescenceMapUv = ( iridescenceMapTransform * vec3( IRIDESCENCEMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	vIridescenceThicknessMapUv = ( iridescenceThicknessMapTransform * vec3( IRIDESCENCE_THICKNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SHEEN_COLORMAP
	vSheenColorMapUv = ( sheenColorMapTransform * vec3( SHEEN_COLORMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	vSheenRoughnessMapUv = ( sheenRoughnessMapTransform * vec3( SHEEN_ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULARMAP
	vSpecularMapUv = ( specularMapTransform * vec3( SPECULARMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULAR_COLORMAP
	vSpecularColorMapUv = ( specularColorMapTransform * vec3( SPECULAR_COLORMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	vSpecularIntensityMapUv = ( specularIntensityMapTransform * vec3( SPECULAR_INTENSITYMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_TRANSMISSIONMAP
	vTransmissionMapUv = ( transmissionMapTransform * vec3( TRANSMISSIONMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_THICKNESSMAP
	vThicknessMapUv = ( thicknessMapTransform * vec3( THICKNESSMAP_UV, 1 ) ).xy;
#endif`,ix=`#if defined( USE_ENVMAP ) || defined( DISTANCE ) || defined ( USE_SHADOWMAP ) || defined ( USE_TRANSMISSION ) || NUM_SPOT_LIGHT_COORDS > 0
	vec4 worldPosition = vec4( transformed, 1.0 );
	#ifdef USE_BATCHING
		worldPosition = batchingMatrix * worldPosition;
	#endif
	#ifdef USE_INSTANCING
		worldPosition = instanceMatrix * worldPosition;
	#endif
	worldPosition = modelMatrix * worldPosition;
#endif`,nx=`varying vec2 vUv;
uniform mat3 uvTransform;
void main() {
	vUv = ( uvTransform * vec3( uv, 1 ) ).xy;
	gl_Position = vec4( position.xy, 1.0, 1.0 );
}`,sx=`uniform sampler2D t2D;
uniform float backgroundIntensity;
varying vec2 vUv;
void main() {
	vec4 texColor = texture2D( t2D, vUv );
	#ifdef DECODE_VIDEO_TEXTURE
		texColor = vec4( mix( pow( texColor.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), texColor.rgb * 0.0773993808, vec3( lessThanEqual( texColor.rgb, vec3( 0.04045 ) ) ) ), texColor.w );
	#endif
	texColor.rgb *= backgroundIntensity;
	gl_FragColor = texColor;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,rx=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
	gl_Position.z = gl_Position.w;
}`,ox=`#ifdef ENVMAP_TYPE_CUBE
	uniform samplerCube envMap;
#elif defined( ENVMAP_TYPE_CUBE_UV )
	uniform sampler2D envMap;
#endif
uniform float flipEnvMap;
uniform float backgroundBlurriness;
uniform float backgroundIntensity;
uniform mat3 backgroundRotation;
varying vec3 vWorldDirection;
#include <cube_uv_reflection_fragment>
void main() {
	#ifdef ENVMAP_TYPE_CUBE
		vec4 texColor = textureCube( envMap, backgroundRotation * vec3( flipEnvMap * vWorldDirection.x, vWorldDirection.yz ) );
	#elif defined( ENVMAP_TYPE_CUBE_UV )
		vec4 texColor = textureCubeUV( envMap, backgroundRotation * vWorldDirection, backgroundBlurriness );
	#else
		vec4 texColor = vec4( 0.0, 0.0, 0.0, 1.0 );
	#endif
	texColor.rgb *= backgroundIntensity;
	gl_FragColor = texColor;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,ax=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
	gl_Position.z = gl_Position.w;
}`,lx=`uniform samplerCube tCube;
uniform float tFlip;
uniform float opacity;
varying vec3 vWorldDirection;
void main() {
	vec4 texColor = textureCube( tCube, vec3( tFlip * vWorldDirection.x, vWorldDirection.yz ) );
	gl_FragColor = texColor;
	gl_FragColor.a *= opacity;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,cx=`#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
varying vec2 vHighPrecisionZW;
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <skinbase_vertex>
	#include <morphinstance_vertex>
	#ifdef USE_DISPLACEMENTMAP
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vHighPrecisionZW = gl_Position.zw;
}`,hx=`#if DEPTH_PACKING == 3200
	uniform float opacity;
#endif
#include <common>
#include <packing>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
varying vec2 vHighPrecisionZW;
void main() {
	vec4 diffuseColor = vec4( 1.0 );
	#include <clipping_planes_fragment>
	#if DEPTH_PACKING == 3200
		diffuseColor.a = opacity;
	#endif
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <logdepthbuf_fragment>
	#ifdef USE_REVERSED_DEPTH_BUFFER
		float fragCoordZ = vHighPrecisionZW[ 0 ] / vHighPrecisionZW[ 1 ];
	#else
		float fragCoordZ = 0.5 * vHighPrecisionZW[ 0 ] / vHighPrecisionZW[ 1 ] + 0.5;
	#endif
	#if DEPTH_PACKING == 3200
		gl_FragColor = vec4( vec3( 1.0 - fragCoordZ ), opacity );
	#elif DEPTH_PACKING == 3201
		gl_FragColor = packDepthToRGBA( fragCoordZ );
	#elif DEPTH_PACKING == 3202
		gl_FragColor = vec4( packDepthToRGB( fragCoordZ ), 1.0 );
	#elif DEPTH_PACKING == 3203
		gl_FragColor = vec4( packDepthToRG( fragCoordZ ), 0.0, 1.0 );
	#endif
}`,ux=`#define DISTANCE
varying vec3 vWorldPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <skinbase_vertex>
	#include <morphinstance_vertex>
	#ifdef USE_DISPLACEMENTMAP
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <worldpos_vertex>
	#include <clipping_planes_vertex>
	vWorldPosition = worldPosition.xyz;
}`,dx=`#define DISTANCE
uniform vec3 referencePosition;
uniform float nearDistance;
uniform float farDistance;
varying vec3 vWorldPosition;
#include <common>
#include <packing>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <clipping_planes_pars_fragment>
void main () {
	vec4 diffuseColor = vec4( 1.0 );
	#include <clipping_planes_fragment>
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	float dist = length( vWorldPosition - referencePosition );
	dist = ( dist - nearDistance ) / ( farDistance - nearDistance );
	dist = saturate( dist );
	gl_FragColor = packDepthToRGBA( dist );
}`,fx=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
}`,px=`uniform sampler2D tEquirect;
varying vec3 vWorldDirection;
#include <common>
void main() {
	vec3 direction = normalize( vWorldDirection );
	vec2 sampleUV = equirectUv( direction );
	gl_FragColor = texture2D( tEquirect, sampleUV );
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,mx=`uniform float scale;
attribute float lineDistance;
varying float vLineDistance;
#include <common>
#include <uv_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	vLineDistance = scale * lineDistance;
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
}`,gx=`uniform vec3 diffuse;
uniform float opacity;
uniform float dashSize;
uniform float totalSize;
varying float vLineDistance;
#include <common>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	if ( mod( vLineDistance, totalSize ) > dashSize ) {
		discard;
	}
	vec3 outgoingLight = vec3( 0.0 );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
}`,xx=`#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#if defined ( USE_ENVMAP ) || defined ( USE_SKINNING )
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinbase_vertex>
		#include <skinnormal_vertex>
		#include <defaultnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <fog_vertex>
}`,_x=`uniform vec3 diffuse;
uniform float opacity;
#ifndef FLAT_SHADED
	varying vec3 vNormal;
#endif
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	#ifdef USE_LIGHTMAP
		vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
		reflectedLight.indirectDiffuse += lightMapTexel.rgb * lightMapIntensity * RECIPROCAL_PI;
	#else
		reflectedLight.indirectDiffuse += vec3( 1.0 );
	#endif
	#include <aomap_fragment>
	reflectedLight.indirectDiffuse *= diffuseColor.rgb;
	vec3 outgoingLight = reflectedLight.indirectDiffuse;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,yx=`#define LAMBERT
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,vx=`#define LAMBERT
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float opacity;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_lambert_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_lambert_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + totalEmissiveRadiance;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,Mx=`#define MATCAP
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <color_pars_vertex>
#include <displacementmap_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
	vViewPosition = - mvPosition.xyz;
}`,bx=`#define MATCAP
uniform vec3 diffuse;
uniform float opacity;
uniform sampler2D matcap;
varying vec3 vViewPosition;
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <normal_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	vec3 viewDir = normalize( vViewPosition );
	vec3 x = normalize( vec3( viewDir.z, 0.0, - viewDir.x ) );
	vec3 y = cross( viewDir, x );
	vec2 uv = vec2( dot( x, normal ), dot( y, normal ) ) * 0.495 + 0.5;
	#ifdef USE_MATCAP
		vec4 matcapColor = texture2D( matcap, uv );
	#else
		vec4 matcapColor = vec4( vec3( mix( 0.2, 0.8, uv.y ) ), 1.0 );
	#endif
	vec3 outgoingLight = diffuseColor.rgb * matcapColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,wx=`#define NORMAL
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	varying vec3 vViewPosition;
#endif
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphinstance_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	vViewPosition = - mvPosition.xyz;
#endif
}`,Sx=`#define NORMAL
uniform float opacity;
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	varying vec3 vViewPosition;
#endif
#include <packing>
#include <uv_pars_fragment>
#include <normal_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( 0.0, 0.0, 0.0, opacity );
	#include <clipping_planes_fragment>
	#include <logdepthbuf_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	gl_FragColor = vec4( packNormalToRGB( normal ), diffuseColor.a );
	#ifdef OPAQUE
		gl_FragColor.a = 1.0;
	#endif
}`,Ex=`#define PHONG
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphinstance_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,Tx=`#define PHONG
uniform vec3 diffuse;
uniform vec3 emissive;
uniform vec3 specular;
uniform float shininess;
uniform float opacity;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_phong_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_phong_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular + reflectedLight.indirectSpecular + totalEmissiveRadiance;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,Ax=`#define STANDARD
varying vec3 vViewPosition;
#ifdef USE_TRANSMISSION
	varying vec3 vWorldPosition;
#endif
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
#ifdef USE_TRANSMISSION
	vWorldPosition = worldPosition.xyz;
#endif
}`,Rx=`#define STANDARD
#ifdef PHYSICAL
	#define IOR
	#define USE_SPECULAR
#endif
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float roughness;
uniform float metalness;
uniform float opacity;
#ifdef IOR
	uniform float ior;
#endif
#ifdef USE_SPECULAR
	uniform float specularIntensity;
	uniform vec3 specularColor;
	#ifdef USE_SPECULAR_COLORMAP
		uniform sampler2D specularColorMap;
	#endif
	#ifdef USE_SPECULAR_INTENSITYMAP
		uniform sampler2D specularIntensityMap;
	#endif
#endif
#ifdef USE_CLEARCOAT
	uniform float clearcoat;
	uniform float clearcoatRoughness;
#endif
#ifdef USE_DISPERSION
	uniform float dispersion;
#endif
#ifdef USE_IRIDESCENCE
	uniform float iridescence;
	uniform float iridescenceIOR;
	uniform float iridescenceThicknessMinimum;
	uniform float iridescenceThicknessMaximum;
#endif
#ifdef USE_SHEEN
	uniform vec3 sheenColor;
	uniform float sheenRoughness;
	#ifdef USE_SHEEN_COLORMAP
		uniform sampler2D sheenColorMap;
	#endif
	#ifdef USE_SHEEN_ROUGHNESSMAP
		uniform sampler2D sheenRoughnessMap;
	#endif
#endif
#ifdef USE_ANISOTROPY
	uniform vec2 anisotropyVector;
	#ifdef USE_ANISOTROPYMAP
		uniform sampler2D anisotropyMap;
	#endif
#endif
varying vec3 vViewPosition;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <iridescence_fragment>
#include <cube_uv_reflection_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_physical_pars_fragment>
#include <fog_pars_fragment>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_physical_pars_fragment>
#include <transmission_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <clearcoat_pars_fragment>
#include <iridescence_pars_fragment>
#include <roughnessmap_pars_fragment>
#include <metalnessmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <roughnessmap_fragment>
	#include <metalnessmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <clearcoat_normal_fragment_begin>
	#include <clearcoat_normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_physical_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 totalDiffuse = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse;
	vec3 totalSpecular = reflectedLight.directSpecular + reflectedLight.indirectSpecular;
	#include <transmission_fragment>
	vec3 outgoingLight = totalDiffuse + totalSpecular + totalEmissiveRadiance;
	#ifdef USE_SHEEN
		float sheenEnergyComp = 1.0 - 0.157 * max3( material.sheenColor );
		outgoingLight = outgoingLight * sheenEnergyComp + sheenSpecularDirect + sheenSpecularIndirect;
	#endif
	#ifdef USE_CLEARCOAT
		float dotNVcc = saturate( dot( geometryClearcoatNormal, geometryViewDir ) );
		vec3 Fcc = F_Schlick( material.clearcoatF0, material.clearcoatF90, dotNVcc );
		outgoingLight = outgoingLight * ( 1.0 - material.clearcoat * Fcc ) + ( clearcoatSpecularDirect + clearcoatSpecularIndirect ) * material.clearcoat;
	#endif
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,Cx=`#define TOON
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,Ix=`#define TOON
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float opacity;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <gradientmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_toon_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_toon_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + totalEmissiveRadiance;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,Px=`uniform float size;
uniform float scale;
#include <common>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
#ifdef USE_POINTS_UV
	varying vec2 vUv;
	uniform mat3 uvTransform;
#endif
void main() {
	#ifdef USE_POINTS_UV
		vUv = ( uvTransform * vec3( uv, 1 ) ).xy;
	#endif
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <project_vertex>
	gl_PointSize = size;
	#ifdef USE_SIZEATTENUATION
		bool isPerspective = isPerspectiveMatrix( projectionMatrix );
		if ( isPerspective ) gl_PointSize *= ( scale / - mvPosition.z );
	#endif
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <worldpos_vertex>
	#include <fog_vertex>
}`,Lx=`uniform vec3 diffuse;
uniform float opacity;
#include <common>
#include <color_pars_fragment>
#include <map_particle_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	vec3 outgoingLight = vec3( 0.0 );
	#include <logdepthbuf_fragment>
	#include <map_particle_fragment>
	#include <color_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
}`,Dx=`#include <common>
#include <batching_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <shadowmap_pars_vertex>
void main() {
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphinstance_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,Ux=`uniform vec3 color;
uniform float opacity;
#include <common>
#include <packing>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <logdepthbuf_pars_fragment>
#include <shadowmap_pars_fragment>
#include <shadowmask_pars_fragment>
void main() {
	#include <logdepthbuf_fragment>
	gl_FragColor = vec4( color, opacity * ( 1.0 - getShadowMask() ) );
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
}`,Nx=`uniform float rotation;
uniform vec2 center;
#include <common>
#include <uv_pars_vertex>
#include <fog_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	vec4 mvPosition = modelViewMatrix[ 3 ];
	vec2 scale = vec2( length( modelMatrix[ 0 ].xyz ), length( modelMatrix[ 1 ].xyz ) );
	#ifndef USE_SIZEATTENUATION
		bool isPerspective = isPerspectiveMatrix( projectionMatrix );
		if ( isPerspective ) scale *= - mvPosition.z;
	#endif
	vec2 alignedPosition = ( position.xy - ( center - vec2( 0.5 ) ) ) * scale;
	vec2 rotatedPosition;
	rotatedPosition.x = cos( rotation ) * alignedPosition.x - sin( rotation ) * alignedPosition.y;
	rotatedPosition.y = sin( rotation ) * alignedPosition.x + cos( rotation ) * alignedPosition.y;
	mvPosition.xy += rotatedPosition;
	gl_Position = projectionMatrix * mvPosition;
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
}`,Fx=`uniform vec3 diffuse;
uniform float opacity;
#include <common>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	vec3 outgoingLight = vec3( 0.0 );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
}`,Yt={alphahash_fragment:sm,alphahash_pars_fragment:rm,alphamap_fragment:om,alphamap_pars_fragment:am,alphatest_fragment:lm,alphatest_pars_fragment:cm,aomap_fragment:hm,aomap_pars_fragment:um,batching_pars_vertex:dm,batching_vertex:fm,begin_vertex:pm,beginnormal_vertex:mm,bsdfs:gm,iridescence_fragment:xm,bumpmap_pars_fragment:_m,clipping_planes_fragment:ym,clipping_planes_pars_fragment:vm,clipping_planes_pars_vertex:Mm,clipping_planes_vertex:bm,color_fragment:wm,color_pars_fragment:Sm,color_pars_vertex:Em,color_vertex:Tm,common:Am,cube_uv_reflection_fragment:Rm,defaultnormal_vertex:Cm,displacementmap_pars_vertex:Im,displacementmap_vertex:Pm,emissivemap_fragment:Lm,emissivemap_pars_fragment:Dm,colorspace_fragment:Um,colorspace_pars_fragment:Nm,envmap_fragment:Fm,envmap_common_pars_fragment:km,envmap_pars_fragment:Bm,envmap_pars_vertex:Om,envmap_physical_pars_fragment:Jm,envmap_vertex:zm,fog_vertex:Hm,fog_pars_vertex:Vm,fog_fragment:Gm,fog_pars_fragment:Wm,gradientmap_pars_fragment:Xm,lightmap_pars_fragment:qm,lights_lambert_fragment:Ym,lights_lambert_pars_fragment:Zm,lights_pars_begin:$m,lights_toon_fragment:Km,lights_toon_pars_fragment:jm,lights_phong_fragment:Qm,lights_phong_pars_fragment:tg,lights_physical_fragment:eg,lights_physical_pars_fragment:ig,lights_fragment_begin:ng,lights_fragment_maps:sg,lights_fragment_end:rg,logdepthbuf_fragment:og,logdepthbuf_pars_fragment:ag,logdepthbuf_pars_vertex:lg,logdepthbuf_vertex:cg,map_fragment:hg,map_pars_fragment:ug,map_particle_fragment:dg,map_particle_pars_fragment:fg,metalnessmap_fragment:pg,metalnessmap_pars_fragment:mg,morphinstance_vertex:gg,morphcolor_vertex:xg,morphnormal_vertex:_g,morphtarget_pars_vertex:yg,morphtarget_vertex:vg,normal_fragment_begin:Mg,normal_fragment_maps:bg,normal_pars_fragment:wg,normal_pars_vertex:Sg,normal_vertex:Eg,normalmap_pars_fragment:Tg,clearcoat_normal_fragment_begin:Ag,clearcoat_normal_fragment_maps:Rg,clearcoat_pars_fragment:Cg,iridescence_pars_fragment:Ig,opaque_fragment:Pg,packing:Lg,premultiplied_alpha_fragment:Dg,project_vertex:Ug,dithering_fragment:Ng,dithering_pars_fragment:Fg,roughnessmap_fragment:kg,roughnessmap_pars_fragment:Bg,shadowmap_pars_fragment:Og,shadowmap_pars_vertex:zg,shadowmap_vertex:Hg,shadowmask_pars_fragment:Vg,skinbase_vertex:Gg,skinning_pars_vertex:Wg,skinning_vertex:Xg,skinnormal_vertex:qg,specularmap_fragment:Yg,specularmap_pars_fragment:Zg,tonemapping_fragment:$g,tonemapping_pars_fragment:Jg,transmission_fragment:Kg,transmission_pars_fragment:jg,uv_pars_fragment:Qg,uv_pars_vertex:tx,uv_vertex:ex,worldpos_vertex:ix,background_vert:nx,background_frag:sx,backgroundCube_vert:rx,backgroundCube_frag:ox,cube_vert:ax,cube_frag:lx,depth_vert:cx,depth_frag:hx,distanceRGBA_vert:ux,distanceRGBA_frag:dx,equirect_vert:fx,equirect_frag:px,linedashed_vert:mx,linedashed_frag:gx,meshbasic_vert:xx,meshbasic_frag:_x,meshlambert_vert:yx,meshlambert_frag:vx,meshmatcap_vert:Mx,meshmatcap_frag:bx,meshnormal_vert:wx,meshnormal_frag:Sx,meshphong_vert:Ex,meshphong_frag:Tx,meshphysical_vert:Ax,meshphysical_frag:Rx,meshtoon_vert:Cx,meshtoon_frag:Ix,points_vert:Px,points_frag:Lx,shadow_vert:Dx,shadow_frag:Ux,sprite_vert:Nx,sprite_frag:Fx},pt={common:{diffuse:{value:new _t(16777215)},opacity:{value:1},map:{value:null},mapTransform:{value:new Xt},alphaMap:{value:null},alphaMapTransform:{value:new Xt},alphaTest:{value:0}},specularmap:{specularMap:{value:null},specularMapTransform:{value:new Xt}},envmap:{envMap:{value:null},envMapRotation:{value:new Xt},flipEnvMap:{value:-1},reflectivity:{value:1},ior:{value:1.5},refractionRatio:{value:.98}},aomap:{aoMap:{value:null},aoMapIntensity:{value:1},aoMapTransform:{value:new Xt}},lightmap:{lightMap:{value:null},lightMapIntensity:{value:1},lightMapTransform:{value:new Xt}},bumpmap:{bumpMap:{value:null},bumpMapTransform:{value:new Xt},bumpScale:{value:1}},normalmap:{normalMap:{value:null},normalMapTransform:{value:new Xt},normalScale:{value:new nt(1,1)}},displacementmap:{displacementMap:{value:null},displacementMapTransform:{value:new Xt},displacementScale:{value:1},displacementBias:{value:0}},emissivemap:{emissiveMap:{value:null},emissiveMapTransform:{value:new Xt}},metalnessmap:{metalnessMap:{value:null},metalnessMapTransform:{value:new Xt}},roughnessmap:{roughnessMap:{value:null},roughnessMapTransform:{value:new Xt}},gradientmap:{gradientMap:{value:null}},fog:{fogDensity:{value:25e-5},fogNear:{value:1},fogFar:{value:2e3},fogColor:{value:new _t(16777215)}},lights:{ambientLightColor:{value:[]},lightProbe:{value:[]},directionalLights:{value:[],properties:{direction:{},color:{}}},directionalLightShadows:{value:[],properties:{shadowIntensity:1,shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},directionalShadowMap:{value:[]},directionalShadowMatrix:{value:[]},spotLights:{value:[],properties:{color:{},position:{},direction:{},distance:{},coneCos:{},penumbraCos:{},decay:{}}},spotLightShadows:{value:[],properties:{shadowIntensity:1,shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},spotLightMap:{value:[]},spotShadowMap:{value:[]},spotLightMatrix:{value:[]},pointLights:{value:[],properties:{color:{},position:{},decay:{},distance:{}}},pointLightShadows:{value:[],properties:{shadowIntensity:1,shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{},shadowCameraNear:{},shadowCameraFar:{}}},pointShadowMap:{value:[]},pointShadowMatrix:{value:[]},hemisphereLights:{value:[],properties:{direction:{},skyColor:{},groundColor:{}}},rectAreaLights:{value:[],properties:{color:{},position:{},width:{},height:{}}},ltc_1:{value:null},ltc_2:{value:null}},points:{diffuse:{value:new _t(16777215)},opacity:{value:1},size:{value:1},scale:{value:1},map:{value:null},alphaMap:{value:null},alphaMapTransform:{value:new Xt},alphaTest:{value:0},uvTransform:{value:new Xt}},sprite:{diffuse:{value:new _t(16777215)},opacity:{value:1},center:{value:new nt(.5,.5)},rotation:{value:0},map:{value:null},mapTransform:{value:new Xt},alphaMap:{value:null},alphaMapTransform:{value:new Xt},alphaTest:{value:0}}},Yi={basic:{uniforms:Qe([pt.common,pt.specularmap,pt.envmap,pt.aomap,pt.lightmap,pt.fog]),vertexShader:Yt.meshbasic_vert,fragmentShader:Yt.meshbasic_frag},lambert:{uniforms:Qe([pt.common,pt.specularmap,pt.envmap,pt.aomap,pt.lightmap,pt.emissivemap,pt.bumpmap,pt.normalmap,pt.displacementmap,pt.fog,pt.lights,{emissive:{value:new _t(0)}}]),vertexShader:Yt.meshlambert_vert,fragmentShader:Yt.meshlambert_frag},phong:{uniforms:Qe([pt.common,pt.specularmap,pt.envmap,pt.aomap,pt.lightmap,pt.emissivemap,pt.bumpmap,pt.normalmap,pt.displacementmap,pt.fog,pt.lights,{emissive:{value:new _t(0)},specular:{value:new _t(1118481)},shininess:{value:30}}]),vertexShader:Yt.meshphong_vert,fragmentShader:Yt.meshphong_frag},standard:{uniforms:Qe([pt.common,pt.envmap,pt.aomap,pt.lightmap,pt.emissivemap,pt.bumpmap,pt.normalmap,pt.displacementmap,pt.roughnessmap,pt.metalnessmap,pt.fog,pt.lights,{emissive:{value:new _t(0)},roughness:{value:1},metalness:{value:0},envMapIntensity:{value:1}}]),vertexShader:Yt.meshphysical_vert,fragmentShader:Yt.meshphysical_frag},toon:{uniforms:Qe([pt.common,pt.aomap,pt.lightmap,pt.emissivemap,pt.bumpmap,pt.normalmap,pt.displacementmap,pt.gradientmap,pt.fog,pt.lights,{emissive:{value:new _t(0)}}]),vertexShader:Yt.meshtoon_vert,fragmentShader:Yt.meshtoon_frag},matcap:{uniforms:Qe([pt.common,pt.bumpmap,pt.normalmap,pt.displacementmap,pt.fog,{matcap:{value:null}}]),vertexShader:Yt.meshmatcap_vert,fragmentShader:Yt.meshmatcap_frag},points:{uniforms:Qe([pt.points,pt.fog]),vertexShader:Yt.points_vert,fragmentShader:Yt.points_frag},dashed:{uniforms:Qe([pt.common,pt.fog,{scale:{value:1},dashSize:{value:1},totalSize:{value:2}}]),vertexShader:Yt.linedashed_vert,fragmentShader:Yt.linedashed_frag},depth:{uniforms:Qe([pt.common,pt.displacementmap]),vertexShader:Yt.depth_vert,fragmentShader:Yt.depth_frag},normal:{uniforms:Qe([pt.common,pt.bumpmap,pt.normalmap,pt.displacementmap,{opacity:{value:1}}]),vertexShader:Yt.meshnormal_vert,fragmentShader:Yt.meshnormal_frag},sprite:{uniforms:Qe([pt.sprite,pt.fog]),vertexShader:Yt.sprite_vert,fragmentShader:Yt.sprite_frag},background:{uniforms:{uvTransform:{value:new Xt},t2D:{value:null},backgroundIntensity:{value:1}},vertexShader:Yt.background_vert,fragmentShader:Yt.background_frag},backgroundCube:{uniforms:{envMap:{value:null},flipEnvMap:{value:-1},backgroundBlurriness:{value:0},backgroundIntensity:{value:1},backgroundRotation:{value:new Xt}},vertexShader:Yt.backgroundCube_vert,fragmentShader:Yt.backgroundCube_frag},cube:{uniforms:{tCube:{value:null},tFlip:{value:-1},opacity:{value:1}},vertexShader:Yt.cube_vert,fragmentShader:Yt.cube_frag},equirect:{uniforms:{tEquirect:{value:null}},vertexShader:Yt.equirect_vert,fragmentShader:Yt.equirect_frag},distanceRGBA:{uniforms:Qe([pt.common,pt.displacementmap,{referencePosition:{value:new T},nearDistance:{value:1},farDistance:{value:1e3}}]),vertexShader:Yt.distanceRGBA_vert,fragmentShader:Yt.distanceRGBA_frag},shadow:{uniforms:Qe([pt.lights,pt.fog,{color:{value:new _t(0)},opacity:{value:1}}]),vertexShader:Yt.shadow_vert,fragmentShader:Yt.shadow_frag}};Yi.physical={uniforms:Qe([Yi.standard.uniforms,{clearcoat:{value:0},clearcoatMap:{value:null},clearcoatMapTransform:{value:new Xt},clearcoatNormalMap:{value:null},clearcoatNormalMapTransform:{value:new Xt},clearcoatNormalScale:{value:new nt(1,1)},clearcoatRoughness:{value:0},clearcoatRoughnessMap:{value:null},clearcoatRoughnessMapTransform:{value:new Xt},dispersion:{value:0},iridescence:{value:0},iridescenceMap:{value:null},iridescenceMapTransform:{value:new Xt},iridescenceIOR:{value:1.3},iridescenceThicknessMinimum:{value:100},iridescenceThicknessMaximum:{value:400},iridescenceThicknessMap:{value:null},iridescenceThicknessMapTransform:{value:new Xt},sheen:{value:0},sheenColor:{value:new _t(0)},sheenColorMap:{value:null},sheenColorMapTransform:{value:new Xt},sheenRoughness:{value:1},sheenRoughnessMap:{value:null},sheenRoughnessMapTransform:{value:new Xt},transmission:{value:0},transmissionMap:{value:null},transmissionMapTransform:{value:new Xt},transmissionSamplerSize:{value:new nt},transmissionSamplerMap:{value:null},thickness:{value:0},thicknessMap:{value:null},thicknessMapTransform:{value:new Xt},attenuationDistance:{value:0},attenuationColor:{value:new _t(0)},specularColor:{value:new _t(1,1,1)},specularColorMap:{value:null},specularColorMapTransform:{value:new Xt},specularIntensity:{value:1},specularIntensityMap:{value:null},specularIntensityMapTransform:{value:new Xt},anisotropyVector:{value:new nt},anisotropyMap:{value:null},anisotropyMapTransform:{value:new Xt}}]),vertexShader:Yt.meshphysical_vert,fragmentShader:Yt.meshphysical_frag};var Ul={r:0,b:0,g:0},es=new Re,kx=new Ut;function Bx(s,t,e,i,n,r,o){let a=new _t(0),l=r===!0?0:1,c,h,u=null,f=0,d=null;function g(y){let _=y.isScene===!0?y.background:null;return _&&_.isTexture&&(_=(y.backgroundBlurriness>0?e:t).get(_)),_}function x(y){let _=!1,b=g(y);b===null?p(a,l):b&&b.isColor&&(p(b,1),_=!0);let E=s.xr.getEnvironmentBlendMode();E==="additive"?i.buffers.color.setClear(0,0,0,1,o):E==="alpha-blend"&&i.buffers.color.setClear(0,0,0,0,o),(s.autoClear||_)&&(i.buffers.depth.setTest(!0),i.buffers.depth.setMask(!0),i.buffers.color.setMask(!0),s.clear(s.autoClearColor,s.autoClearDepth,s.autoClearStencil))}function m(y,_){let b=g(_);b&&(b.isCubeTexture||b.mapping===so)?(h===void 0&&(h=new Et(new oi(1,1,1),new Xe({name:"BackgroundCubeMaterial",uniforms:ts(Yi.backgroundCube.uniforms),vertexShader:Yi.backgroundCube.vertexShader,fragmentShader:Yi.backgroundCube.fragmentShader,side:qe,depthTest:!1,depthWrite:!1,fog:!1,allowOverride:!1})),h.geometry.deleteAttribute("normal"),h.geometry.deleteAttribute("uv"),h.onBeforeRender=function(E,P,L){this.matrixWorld.copyPosition(L.matrixWorld)},Object.defineProperty(h.material,"envMap",{get:function(){return this.uniforms.envMap.value}}),n.update(h)),es.copy(_.backgroundRotation),es.x*=-1,es.y*=-1,es.z*=-1,b.isCubeTexture&&b.isRenderTargetTexture===!1&&(es.y*=-1,es.z*=-1),h.material.uniforms.envMap.value=b,h.material.uniforms.flipEnvMap.value=b.isCubeTexture&&b.isRenderTargetTexture===!1?-1:1,h.material.uniforms.backgroundBlurriness.value=_.backgroundBlurriness,h.material.uniforms.backgroundIntensity.value=_.backgroundIntensity,h.material.uniforms.backgroundRotation.value.setFromMatrix4(kx.makeRotationFromEuler(es)),h.material.toneMapped=te.getTransfer(b.colorSpace)!==he,(u!==b||f!==b.version||d!==s.toneMapping)&&(h.material.needsUpdate=!0,u=b,f=b.version,d=s.toneMapping),h.layers.enableAll(),y.unshift(h,h.geometry,h.material,0,0,null)):b&&b.isTexture&&(c===void 0&&(c=new Et(new Ke(2,2),new Xe({name:"BackgroundMaterial",uniforms:ts(Yi.background.uniforms),vertexShader:Yi.background.vertexShader,fragmentShader:Yi.background.fragmentShader,side:bi,depthTest:!1,depthWrite:!1,fog:!1,allowOverride:!1})),c.geometry.deleteAttribute("normal"),Object.defineProperty(c.material,"map",{get:function(){return this.uniforms.t2D.value}}),n.update(c)),c.material.uniforms.t2D.value=b,c.material.uniforms.backgroundIntensity.value=_.backgroundIntensity,c.material.toneMapped=te.getTransfer(b.colorSpace)!==he,b.matrixAutoUpdate===!0&&b.updateMatrix(),c.material.uniforms.uvTransform.value.copy(b.matrix),(u!==b||f!==b.version||d!==s.toneMapping)&&(c.material.needsUpdate=!0,u=b,f=b.version,d=s.toneMapping),c.layers.enableAll(),y.unshift(c,c.geometry,c.material,0,0,null))}function p(y,_){y.getRGB(Ul,yh(s)),i.buffers.color.setClear(Ul.r,Ul.g,Ul.b,_,o)}function M(){h!==void 0&&(h.geometry.dispose(),h.material.dispose(),h=void 0),c!==void 0&&(c.geometry.dispose(),c.material.dispose(),c=void 0)}return{getClearColor:function(){return a},setClearColor:function(y,_=1){a.set(y),l=_,p(a,l)},getClearAlpha:function(){return l},setClearAlpha:function(y){l=y,p(a,l)},render:x,addToRenderList:m,dispose:M}}function Ox(s,t){let e=s.getParameter(s.MAX_VERTEX_ATTRIBS),i={},n=f(null),r=n,o=!1;function a(v,C,U,O,z){let q=!1,H=u(O,U,C);r!==H&&(r=H,c(r.object)),q=d(v,O,U,z),q&&g(v,O,U,z),z!==null&&t.update(z,s.ELEMENT_ARRAY_BUFFER),(q||o)&&(o=!1,_(v,C,U,O),z!==null&&s.bindBuffer(s.ELEMENT_ARRAY_BUFFER,t.get(z).buffer))}function l(){return s.createVertexArray()}function c(v){return s.bindVertexArray(v)}function h(v){return s.deleteVertexArray(v)}function u(v,C,U){let O=U.wireframe===!0,z=i[v.id];z===void 0&&(z={},i[v.id]=z);let q=z[C.id];q===void 0&&(q={},z[C.id]=q);let H=q[O];return H===void 0&&(H=f(l()),q[O]=H),H}function f(v){let C=[],U=[],O=[];for(let z=0;z<e;z++)C[z]=0,U[z]=0,O[z]=0;return{geometry:null,program:null,wireframe:!1,newAttributes:C,enabledAttributes:U,attributeDivisors:O,object:v,attributes:{},index:null}}function d(v,C,U,O){let z=r.attributes,q=C.attributes,H=0,it=U.getAttributes();for(let X in it)if(it[X].location>=0){let mt=z[X],bt=q[X];if(bt===void 0&&(X==="instanceMatrix"&&v.instanceMatrix&&(bt=v.instanceMatrix),X==="instanceColor"&&v.instanceColor&&(bt=v.instanceColor)),mt===void 0||mt.attribute!==bt||bt&&mt.data!==bt.data)return!0;H++}return r.attributesNum!==H||r.index!==O}function g(v,C,U,O){let z={},q=C.attributes,H=0,it=U.getAttributes();for(let X in it)if(it[X].location>=0){let mt=q[X];mt===void 0&&(X==="instanceMatrix"&&v.instanceMatrix&&(mt=v.instanceMatrix),X==="instanceColor"&&v.instanceColor&&(mt=v.instanceColor));let bt={};bt.attribute=mt,mt&&mt.data&&(bt.data=mt.data),z[X]=bt,H++}r.attributes=z,r.attributesNum=H,r.index=O}function x(){let v=r.newAttributes;for(let C=0,U=v.length;C<U;C++)v[C]=0}function m(v){p(v,0)}function p(v,C){let U=r.newAttributes,O=r.enabledAttributes,z=r.attributeDivisors;U[v]=1,O[v]===0&&(s.enableVertexAttribArray(v),O[v]=1),z[v]!==C&&(s.vertexAttribDivisor(v,C),z[v]=C)}function M(){let v=r.newAttributes,C=r.enabledAttributes;for(let U=0,O=C.length;U<O;U++)C[U]!==v[U]&&(s.disableVertexAttribArray(U),C[U]=0)}function y(v,C,U,O,z,q,H){H===!0?s.vertexAttribIPointer(v,C,U,z,q):s.vertexAttribPointer(v,C,U,O,z,q)}function _(v,C,U,O){x();let z=O.attributes,q=U.getAttributes(),H=C.defaultAttributeValues;for(let it in q){let X=q[it];if(X.location>=0){let ct=z[it];if(ct===void 0&&(it==="instanceMatrix"&&v.instanceMatrix&&(ct=v.instanceMatrix),it==="instanceColor"&&v.instanceColor&&(ct=v.instanceColor)),ct!==void 0){let mt=ct.normalized,bt=ct.itemSize,Wt=t.get(ct);if(Wt===void 0)continue;let jt=Wt.buffer,le=Wt.type,Qt=Wt.bytesPerElement,Z=le===s.INT||le===s.UNSIGNED_INT||ct.gpuType===Ka;if(ct.isInterleavedBufferAttribute){let et=ct.data,Mt=et.stride,Lt=ct.offset;if(et.isInstancedInterleavedBuffer){for(let Tt=0;Tt<X.locationSize;Tt++)p(X.location+Tt,et.meshPerAttribute);v.isInstancedMesh!==!0&&O._maxInstanceCount===void 0&&(O._maxInstanceCount=et.meshPerAttribute*et.count)}else for(let Tt=0;Tt<X.locationSize;Tt++)m(X.location+Tt);s.bindBuffer(s.ARRAY_BUFFER,jt);for(let Tt=0;Tt<X.locationSize;Tt++)y(X.location+Tt,bt/X.locationSize,le,mt,Mt*Qt,(Lt+bt/X.locationSize*Tt)*Qt,Z)}else{if(ct.isInstancedBufferAttribute){for(let et=0;et<X.locationSize;et++)p(X.location+et,ct.meshPerAttribute);v.isInstancedMesh!==!0&&O._maxInstanceCount===void 0&&(O._maxInstanceCount=ct.meshPerAttribute*ct.count)}else for(let et=0;et<X.locationSize;et++)m(X.location+et);s.bindBuffer(s.ARRAY_BUFFER,jt);for(let et=0;et<X.locationSize;et++)y(X.location+et,bt/X.locationSize,le,mt,bt*Qt,bt/X.locationSize*et*Qt,Z)}}else if(H!==void 0){let mt=H[it];if(mt!==void 0)switch(mt.length){case 2:s.vertexAttrib2fv(X.location,mt);break;case 3:s.vertexAttrib3fv(X.location,mt);break;case 4:s.vertexAttrib4fv(X.location,mt);break;default:s.vertexAttrib1fv(X.location,mt)}}}}M()}function b(){L();for(let v in i){let C=i[v];for(let U in C){let O=C[U];for(let z in O)h(O[z].object),delete O[z];delete C[U]}delete i[v]}}function E(v){if(i[v.id]===void 0)return;let C=i[v.id];for(let U in C){let O=C[U];for(let z in O)h(O[z].object),delete O[z];delete C[U]}delete i[v.id]}function P(v){for(let C in i){let U=i[C];if(U[v.id]===void 0)continue;let O=U[v.id];for(let z in O)h(O[z].object),delete O[z];delete U[v.id]}}function L(){w(),o=!0,r!==n&&(r=n,c(r.object))}function w(){n.geometry=null,n.program=null,n.wireframe=!1}return{setup:a,reset:L,resetDefaultState:w,dispose:b,releaseStatesOfGeometry:E,releaseStatesOfProgram:P,initAttributes:x,enableAttribute:m,disableUnusedAttributes:M}}function zx(s,t,e){let i;function n(c){i=c}function r(c,h){s.drawArrays(i,c,h),e.update(h,i,1)}function o(c,h,u){u!==0&&(s.drawArraysInstanced(i,c,h,u),e.update(h,i,u))}function a(c,h,u){if(u===0)return;t.get("WEBGL_multi_draw").multiDrawArraysWEBGL(i,c,0,h,0,u);let d=0;for(let g=0;g<u;g++)d+=h[g];e.update(d,i,1)}function l(c,h,u,f){if(u===0)return;let d=t.get("WEBGL_multi_draw");if(d===null)for(let g=0;g<c.length;g++)o(c[g],h[g],f[g]);else{d.multiDrawArraysInstancedWEBGL(i,c,0,h,0,f,0,u);let g=0;for(let x=0;x<u;x++)g+=h[x]*f[x];e.update(g,i,1)}}this.setMode=n,this.render=r,this.renderInstances=o,this.renderMultiDraw=a,this.renderMultiDrawInstances=l}function Hx(s,t,e,i){let n;function r(){if(n!==void 0)return n;if(t.has("EXT_texture_filter_anisotropic")===!0){let P=t.get("EXT_texture_filter_anisotropic");n=s.getParameter(P.MAX_TEXTURE_MAX_ANISOTROPY_EXT)}else n=0;return n}function o(P){return!(P!==gi&&i.convert(P)!==s.getParameter(s.IMPLEMENTATION_COLOR_READ_FORMAT))}function a(P){let L=P===Hs&&(t.has("EXT_color_buffer_half_float")||t.has("EXT_color_buffer_float"));return!(P!==ki&&i.convert(P)!==s.getParameter(s.IMPLEMENTATION_COLOR_READ_TYPE)&&P!==Si&&!L)}function l(P){if(P==="highp"){if(s.getShaderPrecisionFormat(s.VERTEX_SHADER,s.HIGH_FLOAT).precision>0&&s.getShaderPrecisionFormat(s.FRAGMENT_SHADER,s.HIGH_FLOAT).precision>0)return"highp";P="mediump"}return P==="mediump"&&s.getShaderPrecisionFormat(s.VERTEX_SHADER,s.MEDIUM_FLOAT).precision>0&&s.getShaderPrecisionFormat(s.FRAGMENT_SHADER,s.MEDIUM_FLOAT).precision>0?"mediump":"lowp"}let c=e.precision!==void 0?e.precision:"highp",h=l(c);h!==c&&(console.warn("THREE.WebGLRenderer:",c,"not supported, using",h,"instead."),c=h);let u=e.logarithmicDepthBuffer===!0,f=e.reversedDepthBuffer===!0&&t.has("EXT_clip_control"),d=s.getParameter(s.MAX_TEXTURE_IMAGE_UNITS),g=s.getParameter(s.MAX_VERTEX_TEXTURE_IMAGE_UNITS),x=s.getParameter(s.MAX_TEXTURE_SIZE),m=s.getParameter(s.MAX_CUBE_MAP_TEXTURE_SIZE),p=s.getParameter(s.MAX_VERTEX_ATTRIBS),M=s.getParameter(s.MAX_VERTEX_UNIFORM_VECTORS),y=s.getParameter(s.MAX_VARYING_VECTORS),_=s.getParameter(s.MAX_FRAGMENT_UNIFORM_VECTORS),b=g>0,E=s.getParameter(s.MAX_SAMPLES);return{isWebGL2:!0,getMaxAnisotropy:r,getMaxPrecision:l,textureFormatReadable:o,textureTypeReadable:a,precision:c,logarithmicDepthBuffer:u,reversedDepthBuffer:f,maxTextures:d,maxVertexTextures:g,maxTextureSize:x,maxCubemapSize:m,maxAttributes:p,maxVertexUniforms:M,maxVaryings:y,maxFragmentUniforms:_,vertexTextures:b,maxSamples:E}}function Vx(s){let t=this,e=null,i=0,n=!1,r=!1,o=new Hi,a=new Xt,l={value:null,needsUpdate:!1};this.uniform=l,this.numPlanes=0,this.numIntersection=0,this.init=function(u,f){let d=u.length!==0||f||i!==0||n;return n=f,i=u.length,d},this.beginShadows=function(){r=!0,h(null)},this.endShadows=function(){r=!1},this.setGlobalState=function(u,f){e=h(u,f,0)},this.setState=function(u,f,d){let g=u.clippingPlanes,x=u.clipIntersection,m=u.clipShadows,p=s.get(u);if(!n||g===null||g.length===0||r&&!m)r?h(null):c();else{let M=r?0:i,y=M*4,_=p.clippingState||null;l.value=_,_=h(g,f,y,d);for(let b=0;b!==y;++b)_[b]=e[b];p.clippingState=_,this.numIntersection=x?this.numPlanes:0,this.numPlanes+=M}};function c(){l.value!==e&&(l.value=e,l.needsUpdate=i>0),t.numPlanes=i,t.numIntersection=0}function h(u,f,d,g){let x=u!==null?u.length:0,m=null;if(x!==0){if(m=l.value,g!==!0||m===null){let p=d+x*4,M=f.matrixWorldInverse;a.getNormalMatrix(M),(m===null||m.length<p)&&(m=new Float32Array(p));for(let y=0,_=d;y!==x;++y,_+=4)o.copy(u[y]).applyMatrix4(M,a),o.normal.toArray(m,_),m[_+3]=o.constant}l.value=m,l.needsUpdate=!0}return t.numPlanes=x,t.numIntersection=0,m}}function Gx(s){let t=new WeakMap;function e(o,a){return a===Za?o.mapping=jn:a===$a&&(o.mapping=Qn),o}function i(o){if(o&&o.isTexture){let a=o.mapping;if(a===Za||a===$a)if(t.has(o)){let l=t.get(o).texture;return e(l,o.mapping)}else{let l=o.image;if(l&&l.height>0){let c=new xa(l.height);return c.fromEquirectangularTexture(s,o),t.set(o,c),o.addEventListener("dispose",n),e(c.texture,o.mapping)}else return null}}return o}function n(o){let a=o.target;a.removeEventListener("dispose",n);let l=t.get(a);l!==void 0&&(t.delete(a),l.dispose())}function r(){t=new WeakMap}return{get:i,dispose:r}}var Xs=4,af=[.125,.215,.35,.446,.526,.582],ss=20,Sh=new Xi,lf=new _t,Eh=null,Th=0,Ah=0,Rh=!1,ns=(1+Math.sqrt(5))/2,Ws=1/ns,cf=[new T(-ns,Ws,0),new T(ns,Ws,0),new T(-Ws,0,ns),new T(Ws,0,ns),new T(0,ns,-Ws),new T(0,ns,Ws),new T(-1,1,-1),new T(1,1,-1),new T(-1,1,1),new T(1,1,1)],Wx=new T,kl=class{constructor(t){this._renderer=t,this._pingPongRenderTarget=null,this._lodMax=0,this._cubeSize=0,this._lodPlanes=[],this._sizeLods=[],this._sigmas=[],this._blurMaterial=null,this._cubemapMaterial=null,this._equirectMaterial=null,this._compileMaterial(this._blurMaterial)}fromScene(t,e=0,i=.1,n=100,r={}){let{size:o=256,position:a=Wx}=r;Eh=this._renderer.getRenderTarget(),Th=this._renderer.getActiveCubeFace(),Ah=this._renderer.getActiveMipmapLevel(),Rh=this._renderer.xr.enabled,this._renderer.xr.enabled=!1,this._setSize(o);let l=this._allocateTargets();return l.depthBuffer=!0,this._sceneToCubeUV(t,i,n,l,a),e>0&&this._blur(l,0,0,e),this._applyPMREM(l),this._cleanup(l),l}fromEquirectangular(t,e=null){return this._fromTexture(t,e)}fromCubemap(t,e=null){return this._fromTexture(t,e)}compileCubemapShader(){this._cubemapMaterial===null&&(this._cubemapMaterial=df(),this._compileMaterial(this._cubemapMaterial))}compileEquirectangularShader(){this._equirectMaterial===null&&(this._equirectMaterial=uf(),this._compileMaterial(this._equirectMaterial))}dispose(){this._dispose(),this._cubemapMaterial!==null&&this._cubemapMaterial.dispose(),this._equirectMaterial!==null&&this._equirectMaterial.dispose()}_setSize(t){this._lodMax=Math.floor(Math.log2(t)),this._cubeSize=Math.pow(2,this._lodMax)}_dispose(){this._blurMaterial!==null&&this._blurMaterial.dispose(),this._pingPongRenderTarget!==null&&this._pingPongRenderTarget.dispose();for(let t=0;t<this._lodPlanes.length;t++)this._lodPlanes[t].dispose()}_cleanup(t){this._renderer.setRenderTarget(Eh,Th,Ah),this._renderer.xr.enabled=Rh,t.scissorTest=!1,Nl(t,0,0,t.width,t.height)}_fromTexture(t,e){t.mapping===jn||t.mapping===Qn?this._setSize(t.image.length===0?16:t.image[0].width||t.image[0].image.width):this._setSize(t.image.width/4),Eh=this._renderer.getRenderTarget(),Th=this._renderer.getActiveCubeFace(),Ah=this._renderer.getActiveMipmapLevel(),Rh=this._renderer.xr.enabled,this._renderer.xr.enabled=!1;let i=e||this._allocateTargets();return this._textureToCubeUV(t,i),this._applyPMREM(i),this._cleanup(i),i}_allocateTargets(){let t=3*Math.max(this._cubeSize,112),e=4*this._cubeSize,i={magFilter:Ni,minFilter:Ni,generateMipmaps:!1,type:Hs,format:gi,colorSpace:Gn,depthBuffer:!1},n=hf(t,e,i);if(this._pingPongRenderTarget===null||this._pingPongRenderTarget.width!==t||this._pingPongRenderTarget.height!==e){this._pingPongRenderTarget!==null&&this._dispose(),this._pingPongRenderTarget=hf(t,e,i);let{_lodMax:r}=this;({sizeLods:this._sizeLods,lodPlanes:this._lodPlanes,sigmas:this._sigmas}=Xx(r)),this._blurMaterial=qx(r,t,e)}return n}_compileMaterial(t){let e=new Et(this._lodPlanes[0],t);this._renderer.compile(e,Sh)}_sceneToCubeUV(t,e,i,n,r){let l=new Le(90,1,e,i),c=[1,-1,1,1,1,1],h=[1,1,1,-1,-1,-1],u=this._renderer,f=u.autoClear,d=u.toneMapping;u.getClearColor(lf),u.toneMapping=cn,u.autoClear=!1,u.state.buffers.depth.getReversed()&&(u.setRenderTarget(n),u.clearDepth(),u.setRenderTarget(null));let x=new ye({name:"PMREM.Background",side:qe,depthWrite:!1,depthTest:!1}),m=new Et(new oi,x),p=!1,M=t.background;M?M.isColor&&(x.color.copy(M),t.background=null,p=!0):(x.color.copy(lf),p=!0);for(let y=0;y<6;y++){let _=y%3;_===0?(l.up.set(0,c[y],0),l.position.set(r.x,r.y,r.z),l.lookAt(r.x+h[y],r.y,r.z)):_===1?(l.up.set(0,0,c[y]),l.position.set(r.x,r.y,r.z),l.lookAt(r.x,r.y+h[y],r.z)):(l.up.set(0,c[y],0),l.position.set(r.x,r.y,r.z),l.lookAt(r.x,r.y,r.z+h[y]));let b=this._cubeSize;Nl(n,_*b,y>2?b:0,b,b),u.setRenderTarget(n),p&&u.render(m,l),u.render(t,l)}m.geometry.dispose(),m.material.dispose(),u.toneMapping=d,u.autoClear=f,t.background=M}_textureToCubeUV(t,e){let i=this._renderer,n=t.mapping===jn||t.mapping===Qn;n?(this._cubemapMaterial===null&&(this._cubemapMaterial=df()),this._cubemapMaterial.uniforms.flipEnvMap.value=t.isRenderTargetTexture===!1?-1:1):this._equirectMaterial===null&&(this._equirectMaterial=uf());let r=n?this._cubemapMaterial:this._equirectMaterial,o=new Et(this._lodPlanes[0],r),a=r.uniforms;a.envMap.value=t;let l=this._cubeSize;Nl(e,0,0,3*l,2*l),i.setRenderTarget(e),i.render(o,Sh)}_applyPMREM(t){let e=this._renderer,i=e.autoClear;e.autoClear=!1;let n=this._lodPlanes.length;for(let r=1;r<n;r++){let o=Math.sqrt(this._sigmas[r]*this._sigmas[r]-this._sigmas[r-1]*this._sigmas[r-1]),a=cf[(n-r-1)%cf.length];this._blur(t,r-1,r,o,a)}e.autoClear=i}_blur(t,e,i,n,r){let o=this._pingPongRenderTarget;this._halfBlur(t,o,e,i,n,"latitudinal",r),this._halfBlur(o,t,i,i,n,"longitudinal",r)}_halfBlur(t,e,i,n,r,o,a){let l=this._renderer,c=this._blurMaterial;o!=="latitudinal"&&o!=="longitudinal"&&console.error("blur direction must be either latitudinal or longitudinal!");let h=3,u=new Et(this._lodPlanes[n],c),f=c.uniforms,d=this._sizeLods[i]-1,g=isFinite(r)?Math.PI/(2*d):2*Math.PI/(2*ss-1),x=r/g,m=isFinite(r)?1+Math.floor(h*x):ss;m>ss&&console.warn(`sigmaRadians, ${r}, is too large and will clip, as it requested ${m} samples when the maximum is set to ${ss}`);let p=[],M=0;for(let P=0;P<ss;++P){let L=P/x,w=Math.exp(-L*L/2);p.push(w),P===0?M+=w:P<m&&(M+=2*w)}for(let P=0;P<p.length;P++)p[P]=p[P]/M;f.envMap.value=t.texture,f.samples.value=m,f.weights.value=p,f.latitudinal.value=o==="latitudinal",a&&(f.poleAxis.value=a);let{_lodMax:y}=this;f.dTheta.value=g,f.mipInt.value=y-i;let _=this._sizeLods[n],b=3*_*(n>y-Xs?n-y+Xs:0),E=4*(this._cubeSize-_);Nl(e,b,E,3*_,2*_),l.setRenderTarget(e),l.render(u,Sh)}};function Xx(s){let t=[],e=[],i=[],n=s,r=s-Xs+1+af.length;for(let o=0;o<r;o++){let a=Math.pow(2,n);e.push(a);let l=1/a;o>s-Xs?l=af[o-s+Xs-1]:o===0&&(l=0),i.push(l);let c=1/(a-2),h=-c,u=1+c,f=[h,h,u,h,u,u,h,h,u,u,h,u],d=6,g=6,x=3,m=2,p=1,M=new Float32Array(x*g*d),y=new Float32Array(m*g*d),_=new Float32Array(p*g*d);for(let E=0;E<d;E++){let P=E%3*2/3-1,L=E>2?0:-1,w=[P,L,0,P+2/3,L,0,P+2/3,L+1,0,P,L,0,P+2/3,L+1,0,P,L+1,0];M.set(w,x*g*E),y.set(f,m*g*E);let v=[E,E,E,E,E,E];_.set(v,p*g*E)}let b=new ue;b.setAttribute("position",new ne(M,x)),b.setAttribute("uv",new ne(y,m)),b.setAttribute("faceIndex",new ne(_,p)),t.push(b),n>Xs&&n--}return{lodPlanes:t,sizeLods:e,sigmas:i}}function hf(s,t,e){let i=new wi(s,t,e);return i.texture.mapping=so,i.texture.name="PMREM.cubeUv",i.scissorTest=!0,i}function Nl(s,t,e,i,n){s.viewport.set(t,e,i,n),s.scissor.set(t,e,i,n)}function qx(s,t,e){let i=new Float32Array(ss),n=new T(0,1,0);return new Xe({name:"SphericalGaussianBlur",defines:{n:ss,CUBEUV_TEXEL_WIDTH:1/t,CUBEUV_TEXEL_HEIGHT:1/e,CUBEUV_MAX_MIP:`${s}.0`},uniforms:{envMap:{value:null},samples:{value:1},weights:{value:i},latitudinal:{value:!1},dTheta:{value:0},mipInt:{value:0},poleAxis:{value:n}},vertexShader:Bh(),fragmentShader:`

			precision mediump float;
			precision mediump int;

			varying vec3 vOutputDirection;

			uniform sampler2D envMap;
			uniform int samples;
			uniform float weights[ n ];
			uniform bool latitudinal;
			uniform float dTheta;
			uniform float mipInt;
			uniform vec3 poleAxis;

			#define ENVMAP_TYPE_CUBE_UV
			#include <cube_uv_reflection_fragment>

			vec3 getSample( float theta, vec3 axis ) {

				float cosTheta = cos( theta );
				// Rodrigues' axis-angle rotation
				vec3 sampleDirection = vOutputDirection * cosTheta
					+ cross( axis, vOutputDirection ) * sin( theta )
					+ axis * dot( axis, vOutputDirection ) * ( 1.0 - cosTheta );

				return bilinearCubeUV( envMap, sampleDirection, mipInt );

			}

			void main() {

				vec3 axis = latitudinal ? poleAxis : cross( poleAxis, vOutputDirection );

				if ( all( equal( axis, vec3( 0.0 ) ) ) ) {

					axis = vec3( vOutputDirection.z, 0.0, - vOutputDirection.x );

				}

				axis = normalize( axis );

				gl_FragColor = vec4( 0.0, 0.0, 0.0, 1.0 );
				gl_FragColor.rgb += weights[ 0 ] * getSample( 0.0, axis );

				for ( int i = 1; i < n; i++ ) {

					if ( i >= samples ) {

						break;

					}

					float theta = dTheta * float( i );
					gl_FragColor.rgb += weights[ i ] * getSample( -1.0 * theta, axis );
					gl_FragColor.rgb += weights[ i ] * getSample( theta, axis );

				}

			}
		`,blending:ln,depthTest:!1,depthWrite:!1})}function uf(){return new Xe({name:"EquirectangularToCubeUV",uniforms:{envMap:{value:null}},vertexShader:Bh(),fragmentShader:`

			precision mediump float;
			precision mediump int;

			varying vec3 vOutputDirection;

			uniform sampler2D envMap;

			#include <common>

			void main() {

				vec3 outputDirection = normalize( vOutputDirection );
				vec2 uv = equirectUv( outputDirection );

				gl_FragColor = vec4( texture2D ( envMap, uv ).rgb, 1.0 );

			}
		`,blending:ln,depthTest:!1,depthWrite:!1})}function df(){return new Xe({name:"CubemapToCubeUV",uniforms:{envMap:{value:null},flipEnvMap:{value:-1}},vertexShader:Bh(),fragmentShader:`

			precision mediump float;
			precision mediump int;

			uniform float flipEnvMap;

			varying vec3 vOutputDirection;

			uniform samplerCube envMap;

			void main() {

				gl_FragColor = textureCube( envMap, vec3( flipEnvMap * vOutputDirection.x, vOutputDirection.yz ) );

			}
		`,blending:ln,depthTest:!1,depthWrite:!1})}function Bh(){return`

		precision mediump float;
		precision mediump int;

		attribute float faceIndex;

		varying vec3 vOutputDirection;

		// RH coordinate system; PMREM face-indexing convention
		vec3 getDirection( vec2 uv, float face ) {

			uv = 2.0 * uv - 1.0;

			vec3 direction = vec3( uv, 1.0 );

			if ( face == 0.0 ) {

				direction = direction.zyx; // ( 1, v, u ) pos x

			} else if ( face == 1.0 ) {

				direction = direction.xzy;
				direction.xz *= -1.0; // ( -u, 1, -v ) pos y

			} else if ( face == 2.0 ) {

				direction.x *= -1.0; // ( -u, v, 1 ) pos z

			} else if ( face == 3.0 ) {

				direction = direction.zyx;
				direction.xz *= -1.0; // ( -1, v, -u ) neg x

			} else if ( face == 4.0 ) {

				direction = direction.xzy;
				direction.xy *= -1.0; // ( -u, -1, v ) neg y

			} else if ( face == 5.0 ) {

				direction.z *= -1.0; // ( u, v, -1 ) neg z

			}

			return direction;

		}

		void main() {

			vOutputDirection = getDirection( uv, faceIndex );
			gl_Position = vec4( position, 1.0 );

		}
	`}function Yx(s){let t=new WeakMap,e=null;function i(a){if(a&&a.isTexture){let l=a.mapping,c=l===Za||l===$a,h=l===jn||l===Qn;if(c||h){let u=t.get(a),f=u!==void 0?u.texture.pmremVersion:0;if(a.isRenderTargetTexture&&a.pmremVersion!==f)return e===null&&(e=new kl(s)),u=c?e.fromEquirectangular(a,u):e.fromCubemap(a,u),u.texture.pmremVersion=a.pmremVersion,t.set(a,u),u.texture;if(u!==void 0)return u.texture;{let d=a.image;return c&&d&&d.height>0||h&&d&&n(d)?(e===null&&(e=new kl(s)),u=c?e.fromEquirectangular(a):e.fromCubemap(a),u.texture.pmremVersion=a.pmremVersion,t.set(a,u),a.addEventListener("dispose",r),u.texture):null}}}return a}function n(a){let l=0,c=6;for(let h=0;h<c;h++)a[h]!==void 0&&l++;return l===c}function r(a){let l=a.target;l.removeEventListener("dispose",r);let c=t.get(l);c!==void 0&&(t.delete(l),c.dispose())}function o(){t=new WeakMap,e!==null&&(e.dispose(),e=null)}return{get:i,dispose:o}}function Zx(s){let t={};function e(i){if(t[i]!==void 0)return t[i];let n;switch(i){case"WEBGL_depth_texture":n=s.getExtension("WEBGL_depth_texture")||s.getExtension("MOZ_WEBGL_depth_texture")||s.getExtension("WEBKIT_WEBGL_depth_texture");break;case"EXT_texture_filter_anisotropic":n=s.getExtension("EXT_texture_filter_anisotropic")||s.getExtension("MOZ_EXT_texture_filter_anisotropic")||s.getExtension("WEBKIT_EXT_texture_filter_anisotropic");break;case"WEBGL_compressed_texture_s3tc":n=s.getExtension("WEBGL_compressed_texture_s3tc")||s.getExtension("MOZ_WEBGL_compressed_texture_s3tc")||s.getExtension("WEBKIT_WEBGL_compressed_texture_s3tc");break;case"WEBGL_compressed_texture_pvrtc":n=s.getExtension("WEBGL_compressed_texture_pvrtc")||s.getExtension("WEBKIT_WEBGL_compressed_texture_pvrtc");break;default:n=s.getExtension(i)}return t[i]=n,n}return{has:function(i){return e(i)!==null},init:function(){e("EXT_color_buffer_float"),e("WEBGL_clip_cull_distance"),e("OES_texture_float_linear"),e("EXT_color_buffer_half_float"),e("WEBGL_multisampled_render_to_texture"),e("WEBGL_render_shared_exponent")},get:function(i){let n=e(i);return n===null&&Cs("THREE.WebGLRenderer: "+i+" extension not supported."),n}}}function $x(s,t,e,i){let n={},r=new WeakMap;function o(u){let f=u.target;f.index!==null&&t.remove(f.index);for(let g in f.attributes)t.remove(f.attributes[g]);f.removeEventListener("dispose",o),delete n[f.id];let d=r.get(f);d&&(t.remove(d),r.delete(f)),i.releaseStatesOfGeometry(f),f.isInstancedBufferGeometry===!0&&delete f._maxInstanceCount,e.memory.geometries--}function a(u,f){return n[f.id]===!0||(f.addEventListener("dispose",o),n[f.id]=!0,e.memory.geometries++),f}function l(u){let f=u.attributes;for(let d in f)t.update(f[d],s.ARRAY_BUFFER)}function c(u){let f=[],d=u.index,g=u.attributes.position,x=0;if(d!==null){let M=d.array;x=d.version;for(let y=0,_=M.length;y<_;y+=3){let b=M[y+0],E=M[y+1],P=M[y+2];f.push(b,E,E,P,P,b)}}else if(g!==void 0){let M=g.array;x=g.version;for(let y=0,_=M.length/3-1;y<_;y+=3){let b=y+0,E=y+1,P=y+2;f.push(b,E,E,P,P,b)}}else return;let m=new(_h(f)?Ar:Wn)(f,1);m.version=x;let p=r.get(u);p&&t.remove(p),r.set(u,m)}function h(u){let f=r.get(u);if(f){let d=u.index;d!==null&&f.version<d.version&&c(u)}else c(u);return r.get(u)}return{get:a,update:l,getWireframeAttribute:h}}function Jx(s,t,e){let i;function n(f){i=f}let r,o;function a(f){r=f.type,o=f.bytesPerElement}function l(f,d){s.drawElements(i,d,r,f*o),e.update(d,i,1)}function c(f,d,g){g!==0&&(s.drawElementsInstanced(i,d,r,f*o,g),e.update(d,i,g))}function h(f,d,g){if(g===0)return;t.get("WEBGL_multi_draw").multiDrawElementsWEBGL(i,d,0,r,f,0,g);let m=0;for(let p=0;p<g;p++)m+=d[p];e.update(m,i,1)}function u(f,d,g,x){if(g===0)return;let m=t.get("WEBGL_multi_draw");if(m===null)for(let p=0;p<f.length;p++)c(f[p]/o,d[p],x[p]);else{m.multiDrawElementsInstancedWEBGL(i,d,0,r,f,0,x,0,g);let p=0;for(let M=0;M<g;M++)p+=d[M]*x[M];e.update(p,i,1)}}this.setMode=n,this.setIndex=a,this.render=l,this.renderInstances=c,this.renderMultiDraw=h,this.renderMultiDrawInstances=u}function Kx(s){let t={geometries:0,textures:0},e={frame:0,calls:0,triangles:0,points:0,lines:0};function i(r,o,a){switch(e.calls++,o){case s.TRIANGLES:e.triangles+=a*(r/3);break;case s.LINES:e.lines+=a*(r/2);break;case s.LINE_STRIP:e.lines+=a*(r-1);break;case s.LINE_LOOP:e.lines+=a*r;break;case s.POINTS:e.points+=a*r;break;default:console.error("THREE.WebGLInfo: Unknown draw mode:",o);break}}function n(){e.calls=0,e.triangles=0,e.points=0,e.lines=0}return{memory:t,render:e,programs:null,autoReset:!0,reset:n,update:i}}function jx(s,t,e){let i=new WeakMap,n=new ie;function r(o,a,l){let c=o.morphTargetInfluences,h=a.morphAttributes.position||a.morphAttributes.normal||a.morphAttributes.color,u=h!==void 0?h.length:0,f=i.get(a);if(f===void 0||f.count!==u){let w=function(){P.dispose(),i.delete(a),a.removeEventListener("dispose",w)};f!==void 0&&f.texture.dispose();let d=a.morphAttributes.position!==void 0,g=a.morphAttributes.normal!==void 0,x=a.morphAttributes.color!==void 0,m=a.morphAttributes.position||[],p=a.morphAttributes.normal||[],M=a.morphAttributes.color||[],y=0;d===!0&&(y=1),g===!0&&(y=2),x===!0&&(y=3);let _=a.attributes.position.count*y,b=1;_>t.maxTextureSize&&(b=Math.ceil(_/t.maxTextureSize),_=t.maxTextureSize);let E=new Float32Array(_*b*4*u),P=new Er(E,_,b,u);P.type=Si,P.needsUpdate=!0;let L=y*4;for(let v=0;v<u;v++){let C=m[v],U=p[v],O=M[v],z=_*b*4*v;for(let q=0;q<C.count;q++){let H=q*L;d===!0&&(n.fromBufferAttribute(C,q),E[z+H+0]=n.x,E[z+H+1]=n.y,E[z+H+2]=n.z,E[z+H+3]=0),g===!0&&(n.fromBufferAttribute(U,q),E[z+H+4]=n.x,E[z+H+5]=n.y,E[z+H+6]=n.z,E[z+H+7]=0),x===!0&&(n.fromBufferAttribute(O,q),E[z+H+8]=n.x,E[z+H+9]=n.y,E[z+H+10]=n.z,E[z+H+11]=O.itemSize===4?n.w:1)}}f={count:u,texture:P,size:new nt(_,b)},i.set(a,f),a.addEventListener("dispose",w)}if(o.isInstancedMesh===!0&&o.morphTexture!==null)l.getUniforms().setValue(s,"morphTexture",o.morphTexture,e);else{let d=0;for(let x=0;x<c.length;x++)d+=c[x];let g=a.morphTargetsRelative?1:1-d;l.getUniforms().setValue(s,"morphTargetBaseInfluence",g),l.getUniforms().setValue(s,"morphTargetInfluences",c)}l.getUniforms().setValue(s,"morphTargetsTexture",f.texture,e),l.getUniforms().setValue(s,"morphTargetsTextureSize",f.size)}return{update:r}}function Qx(s,t,e,i){let n=new WeakMap;function r(l){let c=i.render.frame,h=l.geometry,u=t.get(l,h);if(n.get(u)!==c&&(t.update(u),n.set(u,c)),l.isInstancedMesh&&(l.hasEventListener("dispose",a)===!1&&l.addEventListener("dispose",a),n.get(l)!==c&&(e.update(l.instanceMatrix,s.ARRAY_BUFFER),l.instanceColor!==null&&e.update(l.instanceColor,s.ARRAY_BUFFER),n.set(l,c))),l.isSkinnedMesh){let f=l.skeleton;n.get(f)!==c&&(f.update(),n.set(f,c))}return u}function o(){n=new WeakMap}function a(l){let c=l.target;c.removeEventListener("dispose",a),e.remove(c.instanceMatrix),c.instanceColor!==null&&e.remove(c.instanceColor)}return{update:r,dispose:o}}var Pf=new si,ff=new kr(1,1),Lf=new Er,Df=new ma,Uf=new Cr,pf=[],mf=[],gf=new Float32Array(16),xf=new Float32Array(9),_f=new Float32Array(4);function Ys(s,t,e){let i=s[0];if(i<=0||i>0)return s;let n=t*e,r=pf[n];if(r===void 0&&(r=new Float32Array(n),pf[n]=r),t!==0){i.toArray(r,0);for(let o=1,a=0;o!==t;++o)a+=e,s[o].toArray(r,a)}return r}function Be(s,t){if(s.length!==t.length)return!1;for(let e=0,i=s.length;e<i;e++)if(s[e]!==t[e])return!1;return!0}function Oe(s,t){for(let e=0,i=t.length;e<i;e++)s[e]=t[e]}function Ol(s,t){let e=mf[t];e===void 0&&(e=new Int32Array(t),mf[t]=e);for(let i=0;i!==t;++i)e[i]=s.allocateTextureUnit();return e}function t_(s,t){let e=this.cache;e[0]!==t&&(s.uniform1f(this.addr,t),e[0]=t)}function e_(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y)&&(s.uniform2f(this.addr,t.x,t.y),e[0]=t.x,e[1]=t.y);else{if(Be(e,t))return;s.uniform2fv(this.addr,t),Oe(e,t)}}function i_(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z)&&(s.uniform3f(this.addr,t.x,t.y,t.z),e[0]=t.x,e[1]=t.y,e[2]=t.z);else if(t.r!==void 0)(e[0]!==t.r||e[1]!==t.g||e[2]!==t.b)&&(s.uniform3f(this.addr,t.r,t.g,t.b),e[0]=t.r,e[1]=t.g,e[2]=t.b);else{if(Be(e,t))return;s.uniform3fv(this.addr,t),Oe(e,t)}}function n_(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z||e[3]!==t.w)&&(s.uniform4f(this.addr,t.x,t.y,t.z,t.w),e[0]=t.x,e[1]=t.y,e[2]=t.z,e[3]=t.w);else{if(Be(e,t))return;s.uniform4fv(this.addr,t),Oe(e,t)}}function s_(s,t){let e=this.cache,i=t.elements;if(i===void 0){if(Be(e,t))return;s.uniformMatrix2fv(this.addr,!1,t),Oe(e,t)}else{if(Be(e,i))return;_f.set(i),s.uniformMatrix2fv(this.addr,!1,_f),Oe(e,i)}}function r_(s,t){let e=this.cache,i=t.elements;if(i===void 0){if(Be(e,t))return;s.uniformMatrix3fv(this.addr,!1,t),Oe(e,t)}else{if(Be(e,i))return;xf.set(i),s.uniformMatrix3fv(this.addr,!1,xf),Oe(e,i)}}function o_(s,t){let e=this.cache,i=t.elements;if(i===void 0){if(Be(e,t))return;s.uniformMatrix4fv(this.addr,!1,t),Oe(e,t)}else{if(Be(e,i))return;gf.set(i),s.uniformMatrix4fv(this.addr,!1,gf),Oe(e,i)}}function a_(s,t){let e=this.cache;e[0]!==t&&(s.uniform1i(this.addr,t),e[0]=t)}function l_(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y)&&(s.uniform2i(this.addr,t.x,t.y),e[0]=t.x,e[1]=t.y);else{if(Be(e,t))return;s.uniform2iv(this.addr,t),Oe(e,t)}}function c_(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z)&&(s.uniform3i(this.addr,t.x,t.y,t.z),e[0]=t.x,e[1]=t.y,e[2]=t.z);else{if(Be(e,t))return;s.uniform3iv(this.addr,t),Oe(e,t)}}function h_(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z||e[3]!==t.w)&&(s.uniform4i(this.addr,t.x,t.y,t.z,t.w),e[0]=t.x,e[1]=t.y,e[2]=t.z,e[3]=t.w);else{if(Be(e,t))return;s.uniform4iv(this.addr,t),Oe(e,t)}}function u_(s,t){let e=this.cache;e[0]!==t&&(s.uniform1ui(this.addr,t),e[0]=t)}function d_(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y)&&(s.uniform2ui(this.addr,t.x,t.y),e[0]=t.x,e[1]=t.y);else{if(Be(e,t))return;s.uniform2uiv(this.addr,t),Oe(e,t)}}function f_(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z)&&(s.uniform3ui(this.addr,t.x,t.y,t.z),e[0]=t.x,e[1]=t.y,e[2]=t.z);else{if(Be(e,t))return;s.uniform3uiv(this.addr,t),Oe(e,t)}}function p_(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z||e[3]!==t.w)&&(s.uniform4ui(this.addr,t.x,t.y,t.z,t.w),e[0]=t.x,e[1]=t.y,e[2]=t.z,e[3]=t.w);else{if(Be(e,t))return;s.uniform4uiv(this.addr,t),Oe(e,t)}}function m_(s,t,e){let i=this.cache,n=e.allocateTextureUnit();i[0]!==n&&(s.uniform1i(this.addr,n),i[0]=n);let r;this.type===s.SAMPLER_2D_SHADOW?(ff.compareFunction=ph,r=ff):r=Pf,e.setTexture2D(t||r,n)}function g_(s,t,e){let i=this.cache,n=e.allocateTextureUnit();i[0]!==n&&(s.uniform1i(this.addr,n),i[0]=n),e.setTexture3D(t||Df,n)}function x_(s,t,e){let i=this.cache,n=e.allocateTextureUnit();i[0]!==n&&(s.uniform1i(this.addr,n),i[0]=n),e.setTextureCube(t||Uf,n)}function __(s,t,e){let i=this.cache,n=e.allocateTextureUnit();i[0]!==n&&(s.uniform1i(this.addr,n),i[0]=n),e.setTexture2DArray(t||Lf,n)}function y_(s){switch(s){case 5126:return t_;case 35664:return e_;case 35665:return i_;case 35666:return n_;case 35674:return s_;case 35675:return r_;case 35676:return o_;case 5124:case 35670:return a_;case 35667:case 35671:return l_;case 35668:case 35672:return c_;case 35669:case 35673:return h_;case 5125:return u_;case 36294:return d_;case 36295:return f_;case 36296:return p_;case 35678:case 36198:case 36298:case 36306:case 35682:return m_;case 35679:case 36299:case 36307:return g_;case 35680:case 36300:case 36308:case 36293:return x_;case 36289:case 36303:case 36311:case 36292:return __}}function v_(s,t){s.uniform1fv(this.addr,t)}function M_(s,t){let e=Ys(t,this.size,2);s.uniform2fv(this.addr,e)}function b_(s,t){let e=Ys(t,this.size,3);s.uniform3fv(this.addr,e)}function w_(s,t){let e=Ys(t,this.size,4);s.uniform4fv(this.addr,e)}function S_(s,t){let e=Ys(t,this.size,4);s.uniformMatrix2fv(this.addr,!1,e)}function E_(s,t){let e=Ys(t,this.size,9);s.uniformMatrix3fv(this.addr,!1,e)}function T_(s,t){let e=Ys(t,this.size,16);s.uniformMatrix4fv(this.addr,!1,e)}function A_(s,t){s.uniform1iv(this.addr,t)}function R_(s,t){s.uniform2iv(this.addr,t)}function C_(s,t){s.uniform3iv(this.addr,t)}function I_(s,t){s.uniform4iv(this.addr,t)}function P_(s,t){s.uniform1uiv(this.addr,t)}function L_(s,t){s.uniform2uiv(this.addr,t)}function D_(s,t){s.uniform3uiv(this.addr,t)}function U_(s,t){s.uniform4uiv(this.addr,t)}function N_(s,t,e){let i=this.cache,n=t.length,r=Ol(e,n);Be(i,r)||(s.uniform1iv(this.addr,r),Oe(i,r));for(let o=0;o!==n;++o)e.setTexture2D(t[o]||Pf,r[o])}function F_(s,t,e){let i=this.cache,n=t.length,r=Ol(e,n);Be(i,r)||(s.uniform1iv(this.addr,r),Oe(i,r));for(let o=0;o!==n;++o)e.setTexture3D(t[o]||Df,r[o])}function k_(s,t,e){let i=this.cache,n=t.length,r=Ol(e,n);Be(i,r)||(s.uniform1iv(this.addr,r),Oe(i,r));for(let o=0;o!==n;++o)e.setTextureCube(t[o]||Uf,r[o])}function B_(s,t,e){let i=this.cache,n=t.length,r=Ol(e,n);Be(i,r)||(s.uniform1iv(this.addr,r),Oe(i,r));for(let o=0;o!==n;++o)e.setTexture2DArray(t[o]||Lf,r[o])}function O_(s){switch(s){case 5126:return v_;case 35664:return M_;case 35665:return b_;case 35666:return w_;case 35674:return S_;case 35675:return E_;case 35676:return T_;case 5124:case 35670:return A_;case 35667:case 35671:return R_;case 35668:case 35672:return C_;case 35669:case 35673:return I_;case 5125:return P_;case 36294:return L_;case 36295:return D_;case 36296:return U_;case 35678:case 36198:case 36298:case 36306:case 35682:return N_;case 35679:case 36299:case 36307:return F_;case 35680:case 36300:case 36308:case 36293:return k_;case 36289:case 36303:case 36311:case 36292:return B_}}var Ih=class{constructor(t,e,i){this.id=t,this.addr=i,this.cache=[],this.type=e.type,this.setValue=y_(e.type)}},Ph=class{constructor(t,e,i){this.id=t,this.addr=i,this.cache=[],this.type=e.type,this.size=e.size,this.setValue=O_(e.type)}},Lh=class{constructor(t){this.id=t,this.seq=[],this.map={}}setValue(t,e,i){let n=this.seq;for(let r=0,o=n.length;r!==o;++r){let a=n[r];a.setValue(t,e[a.id],i)}}},Ch=/(\w+)(\])?(\[|\.)?/g;function yf(s,t){s.seq.push(t),s.map[t.id]=t}function z_(s,t,e){let i=s.name,n=i.length;for(Ch.lastIndex=0;;){let r=Ch.exec(i),o=Ch.lastIndex,a=r[1],l=r[2]==="]",c=r[3];if(l&&(a=a|0),c===void 0||c==="["&&o+2===n){yf(e,c===void 0?new Ih(a,s,t):new Ph(a,s,t));break}else{let u=e.map[a];u===void 0&&(u=new Lh(a),yf(e,u)),e=u}}}var qs=class{constructor(t,e){this.seq=[],this.map={};let i=t.getProgramParameter(e,t.ACTIVE_UNIFORMS);for(let n=0;n<i;++n){let r=t.getActiveUniform(e,n),o=t.getUniformLocation(e,r.name);z_(r,o,this)}}setValue(t,e,i,n){let r=this.map[e];r!==void 0&&r.setValue(t,i,n)}setOptional(t,e,i){let n=e[i];n!==void 0&&this.setValue(t,i,n)}static upload(t,e,i,n){for(let r=0,o=e.length;r!==o;++r){let a=e[r],l=i[a.id];l.needsUpdate!==!1&&a.setValue(t,l.value,n)}}static seqWithValue(t,e){let i=[];for(let n=0,r=t.length;n!==r;++n){let o=t[n];o.id in e&&i.push(o)}return i}};function vf(s,t,e){let i=s.createShader(t);return s.shaderSource(i,e),s.compileShader(i),i}var H_=37297,V_=0;function G_(s,t){let e=s.split(`
`),i=[],n=Math.max(t-6,0),r=Math.min(t+6,e.length);for(let o=n;o<r;o++){let a=o+1;i.push(`${a===t?">":" "} ${a}: ${e[o]}`)}return i.join(`
`)}var Mf=new Xt;function W_(s){te._getMatrix(Mf,te.workingColorSpace,s);let t=`mat3( ${Mf.elements.map(e=>e.toFixed(4))} )`;switch(te.getTransfer(s)){case br:return[t,"LinearTransferOETF"];case he:return[t,"sRGBTransferOETF"];default:return console.warn("THREE.WebGLProgram: Unsupported color space: ",s),[t,"LinearTransferOETF"]}}function bf(s,t,e){let i=s.getShaderParameter(t,s.COMPILE_STATUS),r=(s.getShaderInfoLog(t)||"").trim();if(i&&r==="")return"";let o=/ERROR: 0:(\d+)/.exec(r);if(o){let a=parseInt(o[1]);return e.toUpperCase()+`

`+r+`

`+G_(s.getShaderSource(t),a)}else return r}function X_(s,t){let e=W_(t);return[`vec4 ${s}( vec4 value ) {`,`	return ${e[1]}( vec4( value.rgb * ${e[0]}, value.a ) );`,"}"].join(`
`)}function q_(s,t){let e;switch(t){case Dd:e="Linear";break;case Ud:e="Reinhard";break;case Nd:e="Cineon";break;case Ya:e="ACESFilmic";break;case kd:e="AgX";break;case Bd:e="Neutral";break;case Fd:e="Custom";break;default:console.warn("THREE.WebGLProgram: Unsupported toneMapping:",t),e="Linear"}return"vec3 "+s+"( vec3 color ) { return "+e+"ToneMapping( color ); }"}var Fl=new T;function Y_(){te.getLuminanceCoefficients(Fl);let s=Fl.x.toFixed(4),t=Fl.y.toFixed(4),e=Fl.z.toFixed(4);return["float luminance( const in vec3 rgb ) {",`	const vec3 weights = vec3( ${s}, ${t}, ${e} );`,"	return dot( weights, rgb );","}"].join(`
`)}function Z_(s){return[s.extensionClipCullDistance?"#extension GL_ANGLE_clip_cull_distance : require":"",s.extensionMultiDraw?"#extension GL_ANGLE_multi_draw : require":""].filter(uo).join(`
`)}function $_(s){let t=[];for(let e in s){let i=s[e];i!==!1&&t.push("#define "+e+" "+i)}return t.join(`
`)}function J_(s,t){let e={},i=s.getProgramParameter(t,s.ACTIVE_ATTRIBUTES);for(let n=0;n<i;n++){let r=s.getActiveAttrib(t,n),o=r.name,a=1;r.type===s.FLOAT_MAT2&&(a=2),r.type===s.FLOAT_MAT3&&(a=3),r.type===s.FLOAT_MAT4&&(a=4),e[o]={type:r.type,location:s.getAttribLocation(t,o),locationSize:a}}return e}function uo(s){return s!==""}function wf(s,t){let e=t.numSpotLightShadows+t.numSpotLightMaps-t.numSpotLightShadowsWithMaps;return s.replace(/NUM_DIR_LIGHTS/g,t.numDirLights).replace(/NUM_SPOT_LIGHTS/g,t.numSpotLights).replace(/NUM_SPOT_LIGHT_MAPS/g,t.numSpotLightMaps).replace(/NUM_SPOT_LIGHT_COORDS/g,e).replace(/NUM_RECT_AREA_LIGHTS/g,t.numRectAreaLights).replace(/NUM_POINT_LIGHTS/g,t.numPointLights).replace(/NUM_HEMI_LIGHTS/g,t.numHemiLights).replace(/NUM_DIR_LIGHT_SHADOWS/g,t.numDirLightShadows).replace(/NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS/g,t.numSpotLightShadowsWithMaps).replace(/NUM_SPOT_LIGHT_SHADOWS/g,t.numSpotLightShadows).replace(/NUM_POINT_LIGHT_SHADOWS/g,t.numPointLightShadows)}function Sf(s,t){return s.replace(/NUM_CLIPPING_PLANES/g,t.numClippingPlanes).replace(/UNION_CLIPPING_PLANES/g,t.numClippingPlanes-t.numClipIntersection)}var K_=/^[ \t]*#include +<([\w\d./]+)>/gm;function Dh(s){return s.replace(K_,Q_)}var j_=new Map;function Q_(s,t){let e=Yt[t];if(e===void 0){let i=j_.get(t);if(i!==void 0)e=Yt[i],console.warn('THREE.WebGLRenderer: Shader chunk "%s" has been deprecated. Use "%s" instead.',t,i);else throw new Error("Can not resolve #include <"+t+">")}return Dh(e)}var ty=/#pragma unroll_loop_start\s+for\s*\(\s*int\s+i\s*=\s*(\d+)\s*;\s*i\s*<\s*(\d+)\s*;\s*i\s*\+\+\s*\)\s*{([\s\S]+?)}\s+#pragma unroll_loop_end/g;function Ef(s){return s.replace(ty,ey)}function ey(s,t,e,i){let n="";for(let r=parseInt(t);r<parseInt(e);r++)n+=i.replace(/\[\s*i\s*\]/g,"[ "+r+" ]").replace(/UNROLLED_LOOP_INDEX/g,r);return n}function Tf(s){let t=`precision ${s.precision} float;
	precision ${s.precision} int;
	precision ${s.precision} sampler2D;
	precision ${s.precision} samplerCube;
	precision ${s.precision} sampler3D;
	precision ${s.precision} sampler2DArray;
	precision ${s.precision} sampler2DShadow;
	precision ${s.precision} samplerCubeShadow;
	precision ${s.precision} sampler2DArrayShadow;
	precision ${s.precision} isampler2D;
	precision ${s.precision} isampler3D;
	precision ${s.precision} isamplerCube;
	precision ${s.precision} isampler2DArray;
	precision ${s.precision} usampler2D;
	precision ${s.precision} usampler3D;
	precision ${s.precision} usamplerCube;
	precision ${s.precision} usampler2DArray;
	`;return s.precision==="highp"?t+=`
#define HIGH_PRECISION`:s.precision==="mediump"?t+=`
#define MEDIUM_PRECISION`:s.precision==="lowp"&&(t+=`
#define LOW_PRECISION`),t}function iy(s){let t="SHADOWMAP_TYPE_BASIC";return s.shadowMapType===no?t="SHADOWMAP_TYPE_PCF":s.shadowMapType===Ba?t="SHADOWMAP_TYPE_PCF_SOFT":s.shadowMapType===qi&&(t="SHADOWMAP_TYPE_VSM"),t}function ny(s){let t="ENVMAP_TYPE_CUBE";if(s.envMap)switch(s.envMapMode){case jn:case Qn:t="ENVMAP_TYPE_CUBE";break;case so:t="ENVMAP_TYPE_CUBE_UV";break}return t}function sy(s){let t="ENVMAP_MODE_REFLECTION";if(s.envMap)switch(s.envMapMode){case Qn:t="ENVMAP_MODE_REFRACTION";break}return t}function ry(s){let t="ENVMAP_BLENDING_NONE";if(s.envMap)switch(s.combine){case qa:t="ENVMAP_BLENDING_MULTIPLY";break;case Pd:t="ENVMAP_BLENDING_MIX";break;case Ld:t="ENVMAP_BLENDING_ADD";break}return t}function oy(s){let t=s.envMapCubeUVHeight;if(t===null)return null;let e=Math.log2(t)-2,i=1/t;return{texelWidth:1/(3*Math.max(Math.pow(2,e),112)),texelHeight:i,maxMip:e}}function ay(s,t,e,i){let n=s.getContext(),r=e.defines,o=e.vertexShader,a=e.fragmentShader,l=iy(e),c=ny(e),h=sy(e),u=ry(e),f=oy(e),d=Z_(e),g=$_(r),x=n.createProgram(),m,p,M=e.glslVersion?"#version "+e.glslVersion+`
`:"";e.isRawShaderMaterial?(m=["#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,g].filter(uo).join(`
`),m.length>0&&(m+=`
`),p=["#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,g].filter(uo).join(`
`),p.length>0&&(p+=`
`)):(m=[Tf(e),"#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,g,e.extensionClipCullDistance?"#define USE_CLIP_DISTANCE":"",e.batching?"#define USE_BATCHING":"",e.batchingColor?"#define USE_BATCHING_COLOR":"",e.instancing?"#define USE_INSTANCING":"",e.instancingColor?"#define USE_INSTANCING_COLOR":"",e.instancingMorph?"#define USE_INSTANCING_MORPH":"",e.useFog&&e.fog?"#define USE_FOG":"",e.useFog&&e.fogExp2?"#define FOG_EXP2":"",e.map?"#define USE_MAP":"",e.envMap?"#define USE_ENVMAP":"",e.envMap?"#define "+h:"",e.lightMap?"#define USE_LIGHTMAP":"",e.aoMap?"#define USE_AOMAP":"",e.bumpMap?"#define USE_BUMPMAP":"",e.normalMap?"#define USE_NORMALMAP":"",e.normalMapObjectSpace?"#define USE_NORMALMAP_OBJECTSPACE":"",e.normalMapTangentSpace?"#define USE_NORMALMAP_TANGENTSPACE":"",e.displacementMap?"#define USE_DISPLACEMENTMAP":"",e.emissiveMap?"#define USE_EMISSIVEMAP":"",e.anisotropy?"#define USE_ANISOTROPY":"",e.anisotropyMap?"#define USE_ANISOTROPYMAP":"",e.clearcoatMap?"#define USE_CLEARCOATMAP":"",e.clearcoatRoughnessMap?"#define USE_CLEARCOAT_ROUGHNESSMAP":"",e.clearcoatNormalMap?"#define USE_CLEARCOAT_NORMALMAP":"",e.iridescenceMap?"#define USE_IRIDESCENCEMAP":"",e.iridescenceThicknessMap?"#define USE_IRIDESCENCE_THICKNESSMAP":"",e.specularMap?"#define USE_SPECULARMAP":"",e.specularColorMap?"#define USE_SPECULAR_COLORMAP":"",e.specularIntensityMap?"#define USE_SPECULAR_INTENSITYMAP":"",e.roughnessMap?"#define USE_ROUGHNESSMAP":"",e.metalnessMap?"#define USE_METALNESSMAP":"",e.alphaMap?"#define USE_ALPHAMAP":"",e.alphaHash?"#define USE_ALPHAHASH":"",e.transmission?"#define USE_TRANSMISSION":"",e.transmissionMap?"#define USE_TRANSMISSIONMAP":"",e.thicknessMap?"#define USE_THICKNESSMAP":"",e.sheenColorMap?"#define USE_SHEEN_COLORMAP":"",e.sheenRoughnessMap?"#define USE_SHEEN_ROUGHNESSMAP":"",e.mapUv?"#define MAP_UV "+e.mapUv:"",e.alphaMapUv?"#define ALPHAMAP_UV "+e.alphaMapUv:"",e.lightMapUv?"#define LIGHTMAP_UV "+e.lightMapUv:"",e.aoMapUv?"#define AOMAP_UV "+e.aoMapUv:"",e.emissiveMapUv?"#define EMISSIVEMAP_UV "+e.emissiveMapUv:"",e.bumpMapUv?"#define BUMPMAP_UV "+e.bumpMapUv:"",e.normalMapUv?"#define NORMALMAP_UV "+e.normalMapUv:"",e.displacementMapUv?"#define DISPLACEMENTMAP_UV "+e.displacementMapUv:"",e.metalnessMapUv?"#define METALNESSMAP_UV "+e.metalnessMapUv:"",e.roughnessMapUv?"#define ROUGHNESSMAP_UV "+e.roughnessMapUv:"",e.anisotropyMapUv?"#define ANISOTROPYMAP_UV "+e.anisotropyMapUv:"",e.clearcoatMapUv?"#define CLEARCOATMAP_UV "+e.clearcoatMapUv:"",e.clearcoatNormalMapUv?"#define CLEARCOAT_NORMALMAP_UV "+e.clearcoatNormalMapUv:"",e.clearcoatRoughnessMapUv?"#define CLEARCOAT_ROUGHNESSMAP_UV "+e.clearcoatRoughnessMapUv:"",e.iridescenceMapUv?"#define IRIDESCENCEMAP_UV "+e.iridescenceMapUv:"",e.iridescenceThicknessMapUv?"#define IRIDESCENCE_THICKNESSMAP_UV "+e.iridescenceThicknessMapUv:"",e.sheenColorMapUv?"#define SHEEN_COLORMAP_UV "+e.sheenColorMapUv:"",e.sheenRoughnessMapUv?"#define SHEEN_ROUGHNESSMAP_UV "+e.sheenRoughnessMapUv:"",e.specularMapUv?"#define SPECULARMAP_UV "+e.specularMapUv:"",e.specularColorMapUv?"#define SPECULAR_COLORMAP_UV "+e.specularColorMapUv:"",e.specularIntensityMapUv?"#define SPECULAR_INTENSITYMAP_UV "+e.specularIntensityMapUv:"",e.transmissionMapUv?"#define TRANSMISSIONMAP_UV "+e.transmissionMapUv:"",e.thicknessMapUv?"#define THICKNESSMAP_UV "+e.thicknessMapUv:"",e.vertexTangents&&e.flatShading===!1?"#define USE_TANGENT":"",e.vertexColors?"#define USE_COLOR":"",e.vertexAlphas?"#define USE_COLOR_ALPHA":"",e.vertexUv1s?"#define USE_UV1":"",e.vertexUv2s?"#define USE_UV2":"",e.vertexUv3s?"#define USE_UV3":"",e.pointsUvs?"#define USE_POINTS_UV":"",e.flatShading?"#define FLAT_SHADED":"",e.skinning?"#define USE_SKINNING":"",e.morphTargets?"#define USE_MORPHTARGETS":"",e.morphNormals&&e.flatShading===!1?"#define USE_MORPHNORMALS":"",e.morphColors?"#define USE_MORPHCOLORS":"",e.morphTargetsCount>0?"#define MORPHTARGETS_TEXTURE_STRIDE "+e.morphTextureStride:"",e.morphTargetsCount>0?"#define MORPHTARGETS_COUNT "+e.morphTargetsCount:"",e.doubleSided?"#define DOUBLE_SIDED":"",e.flipSided?"#define FLIP_SIDED":"",e.shadowMapEnabled?"#define USE_SHADOWMAP":"",e.shadowMapEnabled?"#define "+l:"",e.sizeAttenuation?"#define USE_SIZEATTENUATION":"",e.numLightProbes>0?"#define USE_LIGHT_PROBES":"",e.logarithmicDepthBuffer?"#define USE_LOGARITHMIC_DEPTH_BUFFER":"",e.reversedDepthBuffer?"#define USE_REVERSED_DEPTH_BUFFER":"","uniform mat4 modelMatrix;","uniform mat4 modelViewMatrix;","uniform mat4 projectionMatrix;","uniform mat4 viewMatrix;","uniform mat3 normalMatrix;","uniform vec3 cameraPosition;","uniform bool isOrthographic;","#ifdef USE_INSTANCING","	attribute mat4 instanceMatrix;","#endif","#ifdef USE_INSTANCING_COLOR","	attribute vec3 instanceColor;","#endif","#ifdef USE_INSTANCING_MORPH","	uniform sampler2D morphTexture;","#endif","attribute vec3 position;","attribute vec3 normal;","attribute vec2 uv;","#ifdef USE_UV1","	attribute vec2 uv1;","#endif","#ifdef USE_UV2","	attribute vec2 uv2;","#endif","#ifdef USE_UV3","	attribute vec2 uv3;","#endif","#ifdef USE_TANGENT","	attribute vec4 tangent;","#endif","#if defined( USE_COLOR_ALPHA )","	attribute vec4 color;","#elif defined( USE_COLOR )","	attribute vec3 color;","#endif","#ifdef USE_SKINNING","	attribute vec4 skinIndex;","	attribute vec4 skinWeight;","#endif",`
`].filter(uo).join(`
`),p=[Tf(e),"#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,g,e.useFog&&e.fog?"#define USE_FOG":"",e.useFog&&e.fogExp2?"#define FOG_EXP2":"",e.alphaToCoverage?"#define ALPHA_TO_COVERAGE":"",e.map?"#define USE_MAP":"",e.matcap?"#define USE_MATCAP":"",e.envMap?"#define USE_ENVMAP":"",e.envMap?"#define "+c:"",e.envMap?"#define "+h:"",e.envMap?"#define "+u:"",f?"#define CUBEUV_TEXEL_WIDTH "+f.texelWidth:"",f?"#define CUBEUV_TEXEL_HEIGHT "+f.texelHeight:"",f?"#define CUBEUV_MAX_MIP "+f.maxMip+".0":"",e.lightMap?"#define USE_LIGHTMAP":"",e.aoMap?"#define USE_AOMAP":"",e.bumpMap?"#define USE_BUMPMAP":"",e.normalMap?"#define USE_NORMALMAP":"",e.normalMapObjectSpace?"#define USE_NORMALMAP_OBJECTSPACE":"",e.normalMapTangentSpace?"#define USE_NORMALMAP_TANGENTSPACE":"",e.emissiveMap?"#define USE_EMISSIVEMAP":"",e.anisotropy?"#define USE_ANISOTROPY":"",e.anisotropyMap?"#define USE_ANISOTROPYMAP":"",e.clearcoat?"#define USE_CLEARCOAT":"",e.clearcoatMap?"#define USE_CLEARCOATMAP":"",e.clearcoatRoughnessMap?"#define USE_CLEARCOAT_ROUGHNESSMAP":"",e.clearcoatNormalMap?"#define USE_CLEARCOAT_NORMALMAP":"",e.dispersion?"#define USE_DISPERSION":"",e.iridescence?"#define USE_IRIDESCENCE":"",e.iridescenceMap?"#define USE_IRIDESCENCEMAP":"",e.iridescenceThicknessMap?"#define USE_IRIDESCENCE_THICKNESSMAP":"",e.specularMap?"#define USE_SPECULARMAP":"",e.specularColorMap?"#define USE_SPECULAR_COLORMAP":"",e.specularIntensityMap?"#define USE_SPECULAR_INTENSITYMAP":"",e.roughnessMap?"#define USE_ROUGHNESSMAP":"",e.metalnessMap?"#define USE_METALNESSMAP":"",e.alphaMap?"#define USE_ALPHAMAP":"",e.alphaTest?"#define USE_ALPHATEST":"",e.alphaHash?"#define USE_ALPHAHASH":"",e.sheen?"#define USE_SHEEN":"",e.sheenColorMap?"#define USE_SHEEN_COLORMAP":"",e.sheenRoughnessMap?"#define USE_SHEEN_ROUGHNESSMAP":"",e.transmission?"#define USE_TRANSMISSION":"",e.transmissionMap?"#define USE_TRANSMISSIONMAP":"",e.thicknessMap?"#define USE_THICKNESSMAP":"",e.vertexTangents&&e.flatShading===!1?"#define USE_TANGENT":"",e.vertexColors||e.instancingColor||e.batchingColor?"#define USE_COLOR":"",e.vertexAlphas?"#define USE_COLOR_ALPHA":"",e.vertexUv1s?"#define USE_UV1":"",e.vertexUv2s?"#define USE_UV2":"",e.vertexUv3s?"#define USE_UV3":"",e.pointsUvs?"#define USE_POINTS_UV":"",e.gradientMap?"#define USE_GRADIENTMAP":"",e.flatShading?"#define FLAT_SHADED":"",e.doubleSided?"#define DOUBLE_SIDED":"",e.flipSided?"#define FLIP_SIDED":"",e.shadowMapEnabled?"#define USE_SHADOWMAP":"",e.shadowMapEnabled?"#define "+l:"",e.premultipliedAlpha?"#define PREMULTIPLIED_ALPHA":"",e.numLightProbes>0?"#define USE_LIGHT_PROBES":"",e.decodeVideoTexture?"#define DECODE_VIDEO_TEXTURE":"",e.decodeVideoTextureEmissive?"#define DECODE_VIDEO_TEXTURE_EMISSIVE":"",e.logarithmicDepthBuffer?"#define USE_LOGARITHMIC_DEPTH_BUFFER":"",e.reversedDepthBuffer?"#define USE_REVERSED_DEPTH_BUFFER":"","uniform mat4 viewMatrix;","uniform vec3 cameraPosition;","uniform bool isOrthographic;",e.toneMapping!==cn?"#define TONE_MAPPING":"",e.toneMapping!==cn?Yt.tonemapping_pars_fragment:"",e.toneMapping!==cn?q_("toneMapping",e.toneMapping):"",e.dithering?"#define DITHERING":"",e.opaque?"#define OPAQUE":"",Yt.colorspace_pars_fragment,X_("linearToOutputTexel",e.outputColorSpace),Y_(),e.useDepthPacking?"#define DEPTH_PACKING "+e.depthPacking:"",`
`].filter(uo).join(`
`)),o=Dh(o),o=wf(o,e),o=Sf(o,e),a=Dh(a),a=wf(a,e),a=Sf(a,e),o=Ef(o),a=Ef(a),e.isRawShaderMaterial!==!0&&(M=`#version 300 es
`,m=[d,"#define attribute in","#define varying out","#define texture2D texture"].join(`
`)+`
`+m,p=["#define varying in",e.glslVersion===gh?"":"layout(location = 0) out highp vec4 pc_fragColor;",e.glslVersion===gh?"":"#define gl_FragColor pc_fragColor","#define gl_FragDepthEXT gl_FragDepth","#define texture2D texture","#define textureCube texture","#define texture2DProj textureProj","#define texture2DLodEXT textureLod","#define texture2DProjLodEXT textureProjLod","#define textureCubeLodEXT textureLod","#define texture2DGradEXT textureGrad","#define texture2DProjGradEXT textureProjGrad","#define textureCubeGradEXT textureGrad"].join(`
`)+`
`+p);let y=M+m+o,_=M+p+a,b=vf(n,n.VERTEX_SHADER,y),E=vf(n,n.FRAGMENT_SHADER,_);n.attachShader(x,b),n.attachShader(x,E),e.index0AttributeName!==void 0?n.bindAttribLocation(x,0,e.index0AttributeName):e.morphTargets===!0&&n.bindAttribLocation(x,0,"position"),n.linkProgram(x);function P(C){if(s.debug.checkShaderErrors){let U=n.getProgramInfoLog(x)||"",O=n.getShaderInfoLog(b)||"",z=n.getShaderInfoLog(E)||"",q=U.trim(),H=O.trim(),it=z.trim(),X=!0,ct=!0;if(n.getProgramParameter(x,n.LINK_STATUS)===!1)if(X=!1,typeof s.debug.onShaderError=="function")s.debug.onShaderError(n,x,b,E);else{let mt=bf(n,b,"vertex"),bt=bf(n,E,"fragment");console.error("THREE.WebGLProgram: Shader Error "+n.getError()+" - VALIDATE_STATUS "+n.getProgramParameter(x,n.VALIDATE_STATUS)+`

Material Name: `+C.name+`
Material Type: `+C.type+`

Program Info Log: `+q+`
`+mt+`
`+bt)}else q!==""?console.warn("THREE.WebGLProgram: Program Info Log:",q):(H===""||it==="")&&(ct=!1);ct&&(C.diagnostics={runnable:X,programLog:q,vertexShader:{log:H,prefix:m},fragmentShader:{log:it,prefix:p}})}n.deleteShader(b),n.deleteShader(E),L=new qs(n,x),w=J_(n,x)}let L;this.getUniforms=function(){return L===void 0&&P(this),L};let w;this.getAttributes=function(){return w===void 0&&P(this),w};let v=e.rendererExtensionParallelShaderCompile===!1;return this.isReady=function(){return v===!1&&(v=n.getProgramParameter(x,H_)),v},this.destroy=function(){i.releaseStatesOfProgram(this),n.deleteProgram(x),this.program=void 0},this.type=e.shaderType,this.name=e.shaderName,this.id=V_++,this.cacheKey=t,this.usedTimes=1,this.program=x,this.vertexShader=b,this.fragmentShader=E,this}var ly=0,Uh=class{constructor(){this.shaderCache=new Map,this.materialCache=new Map}update(t){let e=t.vertexShader,i=t.fragmentShader,n=this._getShaderStage(e),r=this._getShaderStage(i),o=this._getShaderCacheForMaterial(t);return o.has(n)===!1&&(o.add(n),n.usedTimes++),o.has(r)===!1&&(o.add(r),r.usedTimes++),this}remove(t){let e=this.materialCache.get(t);for(let i of e)i.usedTimes--,i.usedTimes===0&&this.shaderCache.delete(i.code);return this.materialCache.delete(t),this}getVertexShaderID(t){return this._getShaderStage(t.vertexShader).id}getFragmentShaderID(t){return this._getShaderStage(t.fragmentShader).id}dispose(){this.shaderCache.clear(),this.materialCache.clear()}_getShaderCacheForMaterial(t){let e=this.materialCache,i=e.get(t);return i===void 0&&(i=new Set,e.set(t,i)),i}_getShaderStage(t){let e=this.shaderCache,i=e.get(t);return i===void 0&&(i=new Nh(t),e.set(t,i)),i}},Nh=class{constructor(t){this.id=ly++,this.code=t,this.usedTimes=0}};function cy(s,t,e,i,n,r,o){let a=new Tr,l=new Uh,c=new Set,h=[],u=n.logarithmicDepthBuffer,f=n.vertexTextures,d=n.precision,g={MeshDepthMaterial:"depth",MeshDistanceMaterial:"distanceRGBA",MeshNormalMaterial:"normal",MeshBasicMaterial:"basic",MeshLambertMaterial:"lambert",MeshPhongMaterial:"phong",MeshToonMaterial:"toon",MeshStandardMaterial:"physical",MeshPhysicalMaterial:"physical",MeshMatcapMaterial:"matcap",LineBasicMaterial:"basic",LineDashedMaterial:"dashed",PointsMaterial:"points",ShadowMaterial:"shadow",SpriteMaterial:"sprite"};function x(w){return c.add(w),w===0?"uv":`uv${w}`}function m(w,v,C,U,O){let z=U.fog,q=O.geometry,H=w.isMeshStandardMaterial?U.environment:null,it=(w.isMeshStandardMaterial?e:t).get(w.envMap||H),X=it&&it.mapping===so?it.image.height:null,ct=g[w.type];w.precision!==null&&(d=n.getMaxPrecision(w.precision),d!==w.precision&&console.warn("THREE.WebGLProgram.getParameters:",w.precision,"not supported, using",d,"instead."));let mt=q.morphAttributes.position||q.morphAttributes.normal||q.morphAttributes.color,bt=mt!==void 0?mt.length:0,Wt=0;q.morphAttributes.position!==void 0&&(Wt=1),q.morphAttributes.normal!==void 0&&(Wt=2),q.morphAttributes.color!==void 0&&(Wt=3);let jt,le,Qt,Z;if(ct){let oe=Yi[ct];jt=oe.vertexShader,le=oe.fragmentShader}else jt=w.vertexShader,le=w.fragmentShader,l.update(w),Qt=l.getVertexShaderID(w),Z=l.getFragmentShaderID(w);let et=s.getRenderTarget(),Mt=s.state.buffers.depth.getReversed(),Lt=O.isInstancedMesh===!0,Tt=O.isBatchedMesh===!0,Jt=!!w.map,ge=!!w.matcap,D=!!it,tt=!!w.aoMap,K=!!w.lightMap,J=!!w.bumpMap,$=!!w.normalMap,ut=!!w.displacementMap,st=!!w.emissiveMap,dt=!!w.metalnessMap,Vt=!!w.roughnessMap,zt=w.anisotropy>0,I=w.clearcoat>0,S=w.dispersion>0,B=w.iridescence>0,W=w.sheen>0,Q=w.transmission>0,Y=zt&&!!w.anisotropyMap,It=I&&!!w.clearcoatMap,ht=I&&!!w.clearcoatNormalMap,At=I&&!!w.clearcoatRoughnessMap,Rt=B&&!!w.iridescenceMap,rt=B&&!!w.iridescenceThicknessMap,yt=W&&!!w.sheenColorMap,Bt=W&&!!w.sheenRoughnessMap,Pt=!!w.specularMap,gt=!!w.specularColorMap,qt=!!w.specularIntensityMap,N=Q&&!!w.transmissionMap,lt=Q&&!!w.thicknessMap,ft=!!w.gradientMap,wt=!!w.alphaMap,ot=w.alphaTest>0,j=!!w.alphaHash,Ct=!!w.extensions,Gt=cn;w.toneMapped&&(et===null||et.isXRRenderTarget===!0)&&(Gt=s.toneMapping);let xe={shaderID:ct,shaderType:w.type,shaderName:w.name,vertexShader:jt,fragmentShader:le,defines:w.defines,customVertexShaderID:Qt,customFragmentShaderID:Z,isRawShaderMaterial:w.isRawShaderMaterial===!0,glslVersion:w.glslVersion,precision:d,batching:Tt,batchingColor:Tt&&O._colorsTexture!==null,instancing:Lt,instancingColor:Lt&&O.instanceColor!==null,instancingMorph:Lt&&O.morphTexture!==null,supportsVertexTextures:f,outputColorSpace:et===null?s.outputColorSpace:et.isXRRenderTarget===!0?et.texture.colorSpace:Gn,alphaToCoverage:!!w.alphaToCoverage,map:Jt,matcap:ge,envMap:D,envMapMode:D&&it.mapping,envMapCubeUVHeight:X,aoMap:tt,lightMap:K,bumpMap:J,normalMap:$,displacementMap:f&&ut,emissiveMap:st,normalMapObjectSpace:$&&w.normalMapType===Gd,normalMapTangentSpace:$&&w.normalMapType===Ll,metalnessMap:dt,roughnessMap:Vt,anisotropy:zt,anisotropyMap:Y,clearcoat:I,clearcoatMap:It,clearcoatNormalMap:ht,clearcoatRoughnessMap:At,dispersion:S,iridescence:B,iridescenceMap:Rt,iridescenceThicknessMap:rt,sheen:W,sheenColorMap:yt,sheenRoughnessMap:Bt,specularMap:Pt,specularColorMap:gt,specularIntensityMap:qt,transmission:Q,transmissionMap:N,thicknessMap:lt,gradientMap:ft,opaque:w.transparent===!1&&w.blending===Ui&&w.alphaToCoverage===!1,alphaMap:wt,alphaTest:ot,alphaHash:j,combine:w.combine,mapUv:Jt&&x(w.map.channel),aoMapUv:tt&&x(w.aoMap.channel),lightMapUv:K&&x(w.lightMap.channel),bumpMapUv:J&&x(w.bumpMap.channel),normalMapUv:$&&x(w.normalMap.channel),displacementMapUv:ut&&x(w.displacementMap.channel),emissiveMapUv:st&&x(w.emissiveMap.channel),metalnessMapUv:dt&&x(w.metalnessMap.channel),roughnessMapUv:Vt&&x(w.roughnessMap.channel),anisotropyMapUv:Y&&x(w.anisotropyMap.channel),clearcoatMapUv:It&&x(w.clearcoatMap.channel),clearcoatNormalMapUv:ht&&x(w.clearcoatNormalMap.channel),clearcoatRoughnessMapUv:At&&x(w.clearcoatRoughnessMap.channel),iridescenceMapUv:Rt&&x(w.iridescenceMap.channel),iridescenceThicknessMapUv:rt&&x(w.iridescenceThicknessMap.channel),sheenColorMapUv:yt&&x(w.sheenColorMap.channel),sheenRoughnessMapUv:Bt&&x(w.sheenRoughnessMap.channel),specularMapUv:Pt&&x(w.specularMap.channel),specularColorMapUv:gt&&x(w.specularColorMap.channel),specularIntensityMapUv:qt&&x(w.specularIntensityMap.channel),transmissionMapUv:N&&x(w.transmissionMap.channel),thicknessMapUv:lt&&x(w.thicknessMap.channel),alphaMapUv:wt&&x(w.alphaMap.channel),vertexTangents:!!q.attributes.tangent&&($||zt),vertexColors:w.vertexColors,vertexAlphas:w.vertexColors===!0&&!!q.attributes.color&&q.attributes.color.itemSize===4,pointsUvs:O.isPoints===!0&&!!q.attributes.uv&&(Jt||wt),fog:!!z,useFog:w.fog===!0,fogExp2:!!z&&z.isFogExp2,flatShading:w.flatShading===!0&&w.wireframe===!1,sizeAttenuation:w.sizeAttenuation===!0,logarithmicDepthBuffer:u,reversedDepthBuffer:Mt,skinning:O.isSkinnedMesh===!0,morphTargets:q.morphAttributes.position!==void 0,morphNormals:q.morphAttributes.normal!==void 0,morphColors:q.morphAttributes.color!==void 0,morphTargetsCount:bt,morphTextureStride:Wt,numDirLights:v.directional.length,numPointLights:v.point.length,numSpotLights:v.spot.length,numSpotLightMaps:v.spotLightMap.length,numRectAreaLights:v.rectArea.length,numHemiLights:v.hemi.length,numDirLightShadows:v.directionalShadowMap.length,numPointLightShadows:v.pointShadowMap.length,numSpotLightShadows:v.spotShadowMap.length,numSpotLightShadowsWithMaps:v.numSpotLightShadowsWithMaps,numLightProbes:v.numLightProbes,numClippingPlanes:o.numPlanes,numClipIntersection:o.numIntersection,dithering:w.dithering,shadowMapEnabled:s.shadowMap.enabled&&C.length>0,shadowMapType:s.shadowMap.type,toneMapping:Gt,decodeVideoTexture:Jt&&w.map.isVideoTexture===!0&&te.getTransfer(w.map.colorSpace)===he,decodeVideoTextureEmissive:st&&w.emissiveMap.isVideoTexture===!0&&te.getTransfer(w.emissiveMap.colorSpace)===he,premultipliedAlpha:w.premultipliedAlpha,doubleSided:w.side===Fe,flipSided:w.side===qe,useDepthPacking:w.depthPacking>=0,depthPacking:w.depthPacking||0,index0AttributeName:w.index0AttributeName,extensionClipCullDistance:Ct&&w.extensions.clipCullDistance===!0&&i.has("WEBGL_clip_cull_distance"),extensionMultiDraw:(Ct&&w.extensions.multiDraw===!0||Tt)&&i.has("WEBGL_multi_draw"),rendererExtensionParallelShaderCompile:i.has("KHR_parallel_shader_compile"),customProgramCacheKey:w.customProgramCacheKey()};return xe.vertexUv1s=c.has(1),xe.vertexUv2s=c.has(2),xe.vertexUv3s=c.has(3),c.clear(),xe}function p(w){let v=[];if(w.shaderID?v.push(w.shaderID):(v.push(w.customVertexShaderID),v.push(w.customFragmentShaderID)),w.defines!==void 0)for(let C in w.defines)v.push(C),v.push(w.defines[C]);return w.isRawShaderMaterial===!1&&(M(v,w),y(v,w),v.push(s.outputColorSpace)),v.push(w.customProgramCacheKey),v.join()}function M(w,v){w.push(v.precision),w.push(v.outputColorSpace),w.push(v.envMapMode),w.push(v.envMapCubeUVHeight),w.push(v.mapUv),w.push(v.alphaMapUv),w.push(v.lightMapUv),w.push(v.aoMapUv),w.push(v.bumpMapUv),w.push(v.normalMapUv),w.push(v.displacementMapUv),w.push(v.emissiveMapUv),w.push(v.metalnessMapUv),w.push(v.roughnessMapUv),w.push(v.anisotropyMapUv),w.push(v.clearcoatMapUv),w.push(v.clearcoatNormalMapUv),w.push(v.clearcoatRoughnessMapUv),w.push(v.iridescenceMapUv),w.push(v.iridescenceThicknessMapUv),w.push(v.sheenColorMapUv),w.push(v.sheenRoughnessMapUv),w.push(v.specularMapUv),w.push(v.specularColorMapUv),w.push(v.specularIntensityMapUv),w.push(v.transmissionMapUv),w.push(v.thicknessMapUv),w.push(v.combine),w.push(v.fogExp2),w.push(v.sizeAttenuation),w.push(v.morphTargetsCount),w.push(v.morphAttributeCount),w.push(v.numDirLights),w.push(v.numPointLights),w.push(v.numSpotLights),w.push(v.numSpotLightMaps),w.push(v.numHemiLights),w.push(v.numRectAreaLights),w.push(v.numDirLightShadows),w.push(v.numPointLightShadows),w.push(v.numSpotLightShadows),w.push(v.numSpotLightShadowsWithMaps),w.push(v.numLightProbes),w.push(v.shadowMapType),w.push(v.toneMapping),w.push(v.numClippingPlanes),w.push(v.numClipIntersection),w.push(v.depthPacking)}function y(w,v){a.disableAll(),v.supportsVertexTextures&&a.enable(0),v.instancing&&a.enable(1),v.instancingColor&&a.enable(2),v.instancingMorph&&a.enable(3),v.matcap&&a.enable(4),v.envMap&&a.enable(5),v.normalMapObjectSpace&&a.enable(6),v.normalMapTangentSpace&&a.enable(7),v.clearcoat&&a.enable(8),v.iridescence&&a.enable(9),v.alphaTest&&a.enable(10),v.vertexColors&&a.enable(11),v.vertexAlphas&&a.enable(12),v.vertexUv1s&&a.enable(13),v.vertexUv2s&&a.enable(14),v.vertexUv3s&&a.enable(15),v.vertexTangents&&a.enable(16),v.anisotropy&&a.enable(17),v.alphaHash&&a.enable(18),v.batching&&a.enable(19),v.dispersion&&a.enable(20),v.batchingColor&&a.enable(21),v.gradientMap&&a.enable(22),w.push(a.mask),a.disableAll(),v.fog&&a.enable(0),v.useFog&&a.enable(1),v.flatShading&&a.enable(2),v.logarithmicDepthBuffer&&a.enable(3),v.reversedDepthBuffer&&a.enable(4),v.skinning&&a.enable(5),v.morphTargets&&a.enable(6),v.morphNormals&&a.enable(7),v.morphColors&&a.enable(8),v.premultipliedAlpha&&a.enable(9),v.shadowMapEnabled&&a.enable(10),v.doubleSided&&a.enable(11),v.flipSided&&a.enable(12),v.useDepthPacking&&a.enable(13),v.dithering&&a.enable(14),v.transmission&&a.enable(15),v.sheen&&a.enable(16),v.opaque&&a.enable(17),v.pointsUvs&&a.enable(18),v.decodeVideoTexture&&a.enable(19),v.decodeVideoTextureEmissive&&a.enable(20),v.alphaToCoverage&&a.enable(21),w.push(a.mask)}function _(w){let v=g[w.type],C;if(v){let U=Yi[v];C=Dl.clone(U.uniforms)}else C=w.uniforms;return C}function b(w,v){let C;for(let U=0,O=h.length;U<O;U++){let z=h[U];if(z.cacheKey===v){C=z,++C.usedTimes;break}}return C===void 0&&(C=new ay(s,v,w,r),h.push(C)),C}function E(w){if(--w.usedTimes===0){let v=h.indexOf(w);h[v]=h[h.length-1],h.pop(),w.destroy()}}function P(w){l.remove(w)}function L(){l.dispose()}return{getParameters:m,getProgramCacheKey:p,getUniforms:_,acquireProgram:b,releaseProgram:E,releaseShaderCache:P,programs:h,dispose:L}}function hy(){let s=new WeakMap;function t(o){return s.has(o)}function e(o){let a=s.get(o);return a===void 0&&(a={},s.set(o,a)),a}function i(o){s.delete(o)}function n(o,a,l){s.get(o)[a]=l}function r(){s=new WeakMap}return{has:t,get:e,remove:i,update:n,dispose:r}}function uy(s,t){return s.groupOrder!==t.groupOrder?s.groupOrder-t.groupOrder:s.renderOrder!==t.renderOrder?s.renderOrder-t.renderOrder:s.material.id!==t.material.id?s.material.id-t.material.id:s.z!==t.z?s.z-t.z:s.id-t.id}function Af(s,t){return s.groupOrder!==t.groupOrder?s.groupOrder-t.groupOrder:s.renderOrder!==t.renderOrder?s.renderOrder-t.renderOrder:s.z!==t.z?t.z-s.z:s.id-t.id}function Rf(){let s=[],t=0,e=[],i=[],n=[];function r(){t=0,e.length=0,i.length=0,n.length=0}function o(u,f,d,g,x,m){let p=s[t];return p===void 0?(p={id:u.id,object:u,geometry:f,material:d,groupOrder:g,renderOrder:u.renderOrder,z:x,group:m},s[t]=p):(p.id=u.id,p.object=u,p.geometry=f,p.material=d,p.groupOrder=g,p.renderOrder=u.renderOrder,p.z=x,p.group=m),t++,p}function a(u,f,d,g,x,m){let p=o(u,f,d,g,x,m);d.transmission>0?i.push(p):d.transparent===!0?n.push(p):e.push(p)}function l(u,f,d,g,x,m){let p=o(u,f,d,g,x,m);d.transmission>0?i.unshift(p):d.transparent===!0?n.unshift(p):e.unshift(p)}function c(u,f){e.length>1&&e.sort(u||uy),i.length>1&&i.sort(f||Af),n.length>1&&n.sort(f||Af)}function h(){for(let u=t,f=s.length;u<f;u++){let d=s[u];if(d.id===null)break;d.id=null,d.object=null,d.geometry=null,d.material=null,d.group=null}}return{opaque:e,transmissive:i,transparent:n,init:r,push:a,unshift:l,finish:h,sort:c}}function dy(){let s=new WeakMap;function t(i,n){let r=s.get(i),o;return r===void 0?(o=new Rf,s.set(i,[o])):n>=r.length?(o=new Rf,r.push(o)):o=r[n],o}function e(){s=new WeakMap}return{get:t,dispose:e}}function fy(){let s={};return{get:function(t){if(s[t.id]!==void 0)return s[t.id];let e;switch(t.type){case"DirectionalLight":e={direction:new T,color:new _t};break;case"SpotLight":e={position:new T,direction:new T,color:new _t,distance:0,coneCos:0,penumbraCos:0,decay:0};break;case"PointLight":e={position:new T,color:new _t,distance:0,decay:0};break;case"HemisphereLight":e={direction:new T,skyColor:new _t,groundColor:new _t};break;case"RectAreaLight":e={color:new _t,position:new T,halfWidth:new T,halfHeight:new T};break}return s[t.id]=e,e}}}function py(){let s={};return{get:function(t){if(s[t.id]!==void 0)return s[t.id];let e;switch(t.type){case"DirectionalLight":e={shadowIntensity:1,shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new nt};break;case"SpotLight":e={shadowIntensity:1,shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new nt};break;case"PointLight":e={shadowIntensity:1,shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new nt,shadowCameraNear:1,shadowCameraFar:1e3};break}return s[t.id]=e,e}}}var my=0;function gy(s,t){return(t.castShadow?2:0)-(s.castShadow?2:0)+(t.map?1:0)-(s.map?1:0)}function xy(s){let t=new fy,e=py(),i={version:0,hash:{directionalLength:-1,pointLength:-1,spotLength:-1,rectAreaLength:-1,hemiLength:-1,numDirectionalShadows:-1,numPointShadows:-1,numSpotShadows:-1,numSpotMaps:-1,numLightProbes:-1},ambient:[0,0,0],probe:[],directional:[],directionalShadow:[],directionalShadowMap:[],directionalShadowMatrix:[],spot:[],spotLightMap:[],spotShadow:[],spotShadowMap:[],spotLightMatrix:[],rectArea:[],rectAreaLTC1:null,rectAreaLTC2:null,point:[],pointShadow:[],pointShadowMap:[],pointShadowMatrix:[],hemi:[],numSpotLightShadowsWithMaps:0,numLightProbes:0};for(let c=0;c<9;c++)i.probe.push(new T);let n=new T,r=new Ut,o=new Ut;function a(c){let h=0,u=0,f=0;for(let w=0;w<9;w++)i.probe[w].set(0,0,0);let d=0,g=0,x=0,m=0,p=0,M=0,y=0,_=0,b=0,E=0,P=0;c.sort(gy);for(let w=0,v=c.length;w<v;w++){let C=c[w],U=C.color,O=C.intensity,z=C.distance,q=C.shadow&&C.shadow.map?C.shadow.map.texture:null;if(C.isAmbientLight)h+=U.r*O,u+=U.g*O,f+=U.b*O;else if(C.isLightProbe){for(let H=0;H<9;H++)i.probe[H].addScaledVector(C.sh.coefficients[H],O);P++}else if(C.isDirectionalLight){let H=t.get(C);if(H.color.copy(C.color).multiplyScalar(C.intensity),C.castShadow){let it=C.shadow,X=e.get(C);X.shadowIntensity=it.intensity,X.shadowBias=it.bias,X.shadowNormalBias=it.normalBias,X.shadowRadius=it.radius,X.shadowMapSize=it.mapSize,i.directionalShadow[d]=X,i.directionalShadowMap[d]=q,i.directionalShadowMatrix[d]=C.shadow.matrix,M++}i.directional[d]=H,d++}else if(C.isSpotLight){let H=t.get(C);H.position.setFromMatrixPosition(C.matrixWorld),H.color.copy(U).multiplyScalar(O),H.distance=z,H.coneCos=Math.cos(C.angle),H.penumbraCos=Math.cos(C.angle*(1-C.penumbra)),H.decay=C.decay,i.spot[x]=H;let it=C.shadow;if(C.map&&(i.spotLightMap[b]=C.map,b++,it.updateMatrices(C),C.castShadow&&E++),i.spotLightMatrix[x]=it.matrix,C.castShadow){let X=e.get(C);X.shadowIntensity=it.intensity,X.shadowBias=it.bias,X.shadowNormalBias=it.normalBias,X.shadowRadius=it.radius,X.shadowMapSize=it.mapSize,i.spotShadow[x]=X,i.spotShadowMap[x]=q,_++}x++}else if(C.isRectAreaLight){let H=t.get(C);H.color.copy(U).multiplyScalar(O),H.halfWidth.set(C.width*.5,0,0),H.halfHeight.set(0,C.height*.5,0),i.rectArea[m]=H,m++}else if(C.isPointLight){let H=t.get(C);if(H.color.copy(C.color).multiplyScalar(C.intensity),H.distance=C.distance,H.decay=C.decay,C.castShadow){let it=C.shadow,X=e.get(C);X.shadowIntensity=it.intensity,X.shadowBias=it.bias,X.shadowNormalBias=it.normalBias,X.shadowRadius=it.radius,X.shadowMapSize=it.mapSize,X.shadowCameraNear=it.camera.near,X.shadowCameraFar=it.camera.far,i.pointShadow[g]=X,i.pointShadowMap[g]=q,i.pointShadowMatrix[g]=C.shadow.matrix,y++}i.point[g]=H,g++}else if(C.isHemisphereLight){let H=t.get(C);H.skyColor.copy(C.color).multiplyScalar(O),H.groundColor.copy(C.groundColor).multiplyScalar(O),i.hemi[p]=H,p++}}m>0&&(s.has("OES_texture_float_linear")===!0?(i.rectAreaLTC1=pt.LTC_FLOAT_1,i.rectAreaLTC2=pt.LTC_FLOAT_2):(i.rectAreaLTC1=pt.LTC_HALF_1,i.rectAreaLTC2=pt.LTC_HALF_2)),i.ambient[0]=h,i.ambient[1]=u,i.ambient[2]=f;let L=i.hash;(L.directionalLength!==d||L.pointLength!==g||L.spotLength!==x||L.rectAreaLength!==m||L.hemiLength!==p||L.numDirectionalShadows!==M||L.numPointShadows!==y||L.numSpotShadows!==_||L.numSpotMaps!==b||L.numLightProbes!==P)&&(i.directional.length=d,i.spot.length=x,i.rectArea.length=m,i.point.length=g,i.hemi.length=p,i.directionalShadow.length=M,i.directionalShadowMap.length=M,i.pointShadow.length=y,i.pointShadowMap.length=y,i.spotShadow.length=_,i.spotShadowMap.length=_,i.directionalShadowMatrix.length=M,i.pointShadowMatrix.length=y,i.spotLightMatrix.length=_+b-E,i.spotLightMap.length=b,i.numSpotLightShadowsWithMaps=E,i.numLightProbes=P,L.directionalLength=d,L.pointLength=g,L.spotLength=x,L.rectAreaLength=m,L.hemiLength=p,L.numDirectionalShadows=M,L.numPointShadows=y,L.numSpotShadows=_,L.numSpotMaps=b,L.numLightProbes=P,i.version=my++)}function l(c,h){let u=0,f=0,d=0,g=0,x=0,m=h.matrixWorldInverse;for(let p=0,M=c.length;p<M;p++){let y=c[p];if(y.isDirectionalLight){let _=i.directional[u];_.direction.setFromMatrixPosition(y.matrixWorld),n.setFromMatrixPosition(y.target.matrixWorld),_.direction.sub(n),_.direction.transformDirection(m),u++}else if(y.isSpotLight){let _=i.spot[d];_.position.setFromMatrixPosition(y.matrixWorld),_.position.applyMatrix4(m),_.direction.setFromMatrixPosition(y.matrixWorld),n.setFromMatrixPosition(y.target.matrixWorld),_.direction.sub(n),_.direction.transformDirection(m),d++}else if(y.isRectAreaLight){let _=i.rectArea[g];_.position.setFromMatrixPosition(y.matrixWorld),_.position.applyMatrix4(m),o.identity(),r.copy(y.matrixWorld),r.premultiply(m),o.extractRotation(r),_.halfWidth.set(y.width*.5,0,0),_.halfHeight.set(0,y.height*.5,0),_.halfWidth.applyMatrix4(o),_.halfHeight.applyMatrix4(o),g++}else if(y.isPointLight){let _=i.point[f];_.position.setFromMatrixPosition(y.matrixWorld),_.position.applyMatrix4(m),f++}else if(y.isHemisphereLight){let _=i.hemi[x];_.direction.setFromMatrixPosition(y.matrixWorld),_.direction.transformDirection(m),x++}}}return{setup:a,setupView:l,state:i}}function Cf(s){let t=new xy(s),e=[],i=[];function n(h){c.camera=h,e.length=0,i.length=0}function r(h){e.push(h)}function o(h){i.push(h)}function a(){t.setup(e)}function l(h){t.setupView(e,h)}let c={lightsArray:e,shadowsArray:i,camera:null,lights:t,transmissionRenderTarget:{}};return{init:n,state:c,setupLights:a,setupLightsView:l,pushLight:r,pushShadow:o}}function _y(s){let t=new WeakMap;function e(n,r=0){let o=t.get(n),a;return o===void 0?(a=new Cf(s),t.set(n,[a])):r>=o.length?(a=new Cf(s),o.push(a)):a=o[r],a}function i(){t=new WeakMap}return{get:e,dispose:i}}var yy=`void main() {
	gl_Position = vec4( position, 1.0 );
}`,vy=`uniform sampler2D shadow_pass;
uniform vec2 resolution;
uniform float radius;
#include <packing>
void main() {
	const float samples = float( VSM_SAMPLES );
	float mean = 0.0;
	float squared_mean = 0.0;
	float uvStride = samples <= 1.0 ? 0.0 : 2.0 / ( samples - 1.0 );
	float uvStart = samples <= 1.0 ? 0.0 : - 1.0;
	for ( float i = 0.0; i < samples; i ++ ) {
		float uvOffset = uvStart + i * uvStride;
		#ifdef HORIZONTAL_PASS
			vec2 distribution = unpackRGBATo2Half( texture2D( shadow_pass, ( gl_FragCoord.xy + vec2( uvOffset, 0.0 ) * radius ) / resolution ) );
			mean += distribution.x;
			squared_mean += distribution.y * distribution.y + distribution.x * distribution.x;
		#else
			float depth = unpackRGBAToDepth( texture2D( shadow_pass, ( gl_FragCoord.xy + vec2( 0.0, uvOffset ) * radius ) / resolution ) );
			mean += depth;
			squared_mean += depth * depth;
		#endif
	}
	mean = mean / samples;
	squared_mean = squared_mean / samples;
	float std_dev = sqrt( squared_mean - mean * mean );
	gl_FragColor = pack2HalfToRGBA( vec2( mean, std_dev ) );
}`;function My(s,t,e){let i=new Sn,n=new nt,r=new nt,o=new ie,a=new Ea({depthPacking:Vd}),l=new Ta,c={},h=e.maxTextureSize,u={[bi]:qe,[qe]:bi,[Fe]:Fe},f=new Xe({defines:{VSM_SAMPLES:8},uniforms:{shadow_pass:{value:null},resolution:{value:new nt},radius:{value:4}},vertexShader:yy,fragmentShader:vy}),d=f.clone();d.defines.HORIZONTAL_PASS=1;let g=new ue;g.setAttribute("position",new ne(new Float32Array([-1,-1,.5,3,-1,.5,-1,3,.5]),3));let x=new Et(g,f),m=this;this.enabled=!1,this.autoUpdate=!0,this.needsUpdate=!1,this.type=no;let p=this.type;this.render=function(E,P,L){if(m.enabled===!1||m.autoUpdate===!1&&m.needsUpdate===!1||E.length===0)return;let w=s.getRenderTarget(),v=s.getActiveCubeFace(),C=s.getActiveMipmapLevel(),U=s.state;U.setBlending(ln),U.buffers.depth.getReversed()===!0?U.buffers.color.setClear(0,0,0,0):U.buffers.color.setClear(1,1,1,1),U.buffers.depth.setTest(!0),U.setScissorTest(!1);let O=p!==qi&&this.type===qi,z=p===qi&&this.type!==qi;for(let q=0,H=E.length;q<H;q++){let it=E[q],X=it.shadow;if(X===void 0){console.warn("THREE.WebGLShadowMap:",it,"has no shadow.");continue}if(X.autoUpdate===!1&&X.needsUpdate===!1)continue;n.copy(X.mapSize);let ct=X.getFrameExtents();if(n.multiply(ct),r.copy(X.mapSize),(n.x>h||n.y>h)&&(n.x>h&&(r.x=Math.floor(h/ct.x),n.x=r.x*ct.x,X.mapSize.x=r.x),n.y>h&&(r.y=Math.floor(h/ct.y),n.y=r.y*ct.y,X.mapSize.y=r.y)),X.map===null||O===!0||z===!0){let bt=this.type!==qi?{minFilter:li,magFilter:li}:{};X.map!==null&&X.map.dispose(),X.map=new wi(n.x,n.y,bt),X.map.texture.name=it.name+".shadowMap",X.camera.updateProjectionMatrix()}s.setRenderTarget(X.map),s.clear();let mt=X.getViewportCount();for(let bt=0;bt<mt;bt++){let Wt=X.getViewport(bt);o.set(r.x*Wt.x,r.y*Wt.y,r.x*Wt.z,r.y*Wt.w),U.viewport(o),X.updateMatrices(it,bt),i=X.getFrustum(),_(P,L,X.camera,it,this.type)}X.isPointLightShadow!==!0&&this.type===qi&&M(X,L),X.needsUpdate=!1}p=this.type,m.needsUpdate=!1,s.setRenderTarget(w,v,C)};function M(E,P){let L=t.update(x);f.defines.VSM_SAMPLES!==E.blurSamples&&(f.defines.VSM_SAMPLES=E.blurSamples,d.defines.VSM_SAMPLES=E.blurSamples,f.needsUpdate=!0,d.needsUpdate=!0),E.mapPass===null&&(E.mapPass=new wi(n.x,n.y)),f.uniforms.shadow_pass.value=E.map.texture,f.uniforms.resolution.value=E.mapSize,f.uniforms.radius.value=E.radius,s.setRenderTarget(E.mapPass),s.clear(),s.renderBufferDirect(P,null,L,f,x,null),d.uniforms.shadow_pass.value=E.mapPass.texture,d.uniforms.resolution.value=E.mapSize,d.uniforms.radius.value=E.radius,s.setRenderTarget(E.map),s.clear(),s.renderBufferDirect(P,null,L,d,x,null)}function y(E,P,L,w){let v=null,C=L.isPointLight===!0?E.customDistanceMaterial:E.customDepthMaterial;if(C!==void 0)v=C;else if(v=L.isPointLight===!0?l:a,s.localClippingEnabled&&P.clipShadows===!0&&Array.isArray(P.clippingPlanes)&&P.clippingPlanes.length!==0||P.displacementMap&&P.displacementScale!==0||P.alphaMap&&P.alphaTest>0||P.map&&P.alphaTest>0||P.alphaToCoverage===!0){let U=v.uuid,O=P.uuid,z=c[U];z===void 0&&(z={},c[U]=z);let q=z[O];q===void 0&&(q=v.clone(),z[O]=q,P.addEventListener("dispose",b)),v=q}if(v.visible=P.visible,v.wireframe=P.wireframe,w===qi?v.side=P.shadowSide!==null?P.shadowSide:P.side:v.side=P.shadowSide!==null?P.shadowSide:u[P.side],v.alphaMap=P.alphaMap,v.alphaTest=P.alphaToCoverage===!0?.5:P.alphaTest,v.map=P.map,v.clipShadows=P.clipShadows,v.clippingPlanes=P.clippingPlanes,v.clipIntersection=P.clipIntersection,v.displacementMap=P.displacementMap,v.displacementScale=P.displacementScale,v.displacementBias=P.displacementBias,v.wireframeLinewidth=P.wireframeLinewidth,v.linewidth=P.linewidth,L.isPointLight===!0&&v.isMeshDistanceMaterial===!0){let U=s.properties.get(v);U.light=L}return v}function _(E,P,L,w,v){if(E.visible===!1)return;if(E.layers.test(P.layers)&&(E.isMesh||E.isLine||E.isPoints)&&(E.castShadow||E.receiveShadow&&v===qi)&&(!E.frustumCulled||i.intersectsObject(E))){E.modelViewMatrix.multiplyMatrices(L.matrixWorldInverse,E.matrixWorld);let O=t.update(E),z=E.material;if(Array.isArray(z)){let q=O.groups;for(let H=0,it=q.length;H<it;H++){let X=q[H],ct=z[X.materialIndex];if(ct&&ct.visible){let mt=y(E,ct,w,v);E.onBeforeShadow(s,E,P,L,O,mt,X),s.renderBufferDirect(L,null,O,mt,E,X),E.onAfterShadow(s,E,P,L,O,mt,X)}}}else if(z.visible){let q=y(E,z,w,v);E.onBeforeShadow(s,E,P,L,O,q,null),s.renderBufferDirect(L,null,O,q,E,null),E.onAfterShadow(s,E,P,L,O,q,null)}}let U=E.children;for(let O=0,z=U.length;O<z;O++)_(U[O],P,L,w,v)}function b(E){E.target.removeEventListener("dispose",b);for(let L in c){let w=c[L],v=E.target.uuid;v in w&&(w[v].dispose(),delete w[v])}}}var by={[Oa]:za,[Ha]:Wa,[Va]:Xa,[Vn]:Ga,[za]:Oa,[Wa]:Ha,[Xa]:Va,[Ga]:Vn};function wy(s,t){function e(){let N=!1,lt=new ie,ft=null,wt=new ie(0,0,0,0);return{setMask:function(ot){ft!==ot&&!N&&(s.colorMask(ot,ot,ot,ot),ft=ot)},setLocked:function(ot){N=ot},setClear:function(ot,j,Ct,Gt,xe){xe===!0&&(ot*=Gt,j*=Gt,Ct*=Gt),lt.set(ot,j,Ct,Gt),wt.equals(lt)===!1&&(s.clearColor(ot,j,Ct,Gt),wt.copy(lt))},reset:function(){N=!1,ft=null,wt.set(-1,0,0,0)}}}function i(){let N=!1,lt=!1,ft=null,wt=null,ot=null;return{setReversed:function(j){if(lt!==j){let Ct=t.get("EXT_clip_control");j?Ct.clipControlEXT(Ct.LOWER_LEFT_EXT,Ct.ZERO_TO_ONE_EXT):Ct.clipControlEXT(Ct.LOWER_LEFT_EXT,Ct.NEGATIVE_ONE_TO_ONE_EXT),lt=j;let Gt=ot;ot=null,this.setClear(Gt)}},getReversed:function(){return lt},setTest:function(j){j?et(s.DEPTH_TEST):Mt(s.DEPTH_TEST)},setMask:function(j){ft!==j&&!N&&(s.depthMask(j),ft=j)},setFunc:function(j){if(lt&&(j=by[j]),wt!==j){switch(j){case Oa:s.depthFunc(s.NEVER);break;case za:s.depthFunc(s.ALWAYS);break;case Ha:s.depthFunc(s.LESS);break;case Vn:s.depthFunc(s.LEQUAL);break;case Va:s.depthFunc(s.EQUAL);break;case Ga:s.depthFunc(s.GEQUAL);break;case Wa:s.depthFunc(s.GREATER);break;case Xa:s.depthFunc(s.NOTEQUAL);break;default:s.depthFunc(s.LEQUAL)}wt=j}},setLocked:function(j){N=j},setClear:function(j){ot!==j&&(lt&&(j=1-j),s.clearDepth(j),ot=j)},reset:function(){N=!1,ft=null,wt=null,ot=null,lt=!1}}}function n(){let N=!1,lt=null,ft=null,wt=null,ot=null,j=null,Ct=null,Gt=null,xe=null;return{setTest:function(oe){N||(oe?et(s.STENCIL_TEST):Mt(s.STENCIL_TEST))},setMask:function(oe){lt!==oe&&!N&&(s.stencilMask(oe),lt=oe)},setFunc:function(oe,Ji,zi){(ft!==oe||wt!==Ji||ot!==zi)&&(s.stencilFunc(oe,Ji,zi),ft=oe,wt=Ji,ot=zi)},setOp:function(oe,Ji,zi){(j!==oe||Ct!==Ji||Gt!==zi)&&(s.stencilOp(oe,Ji,zi),j=oe,Ct=Ji,Gt=zi)},setLocked:function(oe){N=oe},setClear:function(oe){xe!==oe&&(s.clearStencil(oe),xe=oe)},reset:function(){N=!1,lt=null,ft=null,wt=null,ot=null,j=null,Ct=null,Gt=null,xe=null}}}let r=new e,o=new i,a=new n,l=new WeakMap,c=new WeakMap,h={},u={},f=new WeakMap,d=[],g=null,x=!1,m=null,p=null,M=null,y=null,_=null,b=null,E=null,P=new _t(0,0,0),L=0,w=!1,v=null,C=null,U=null,O=null,z=null,q=s.getParameter(s.MAX_COMBINED_TEXTURE_IMAGE_UNITS),H=!1,it=0,X=s.getParameter(s.VERSION);X.indexOf("WebGL")!==-1?(it=parseFloat(/^WebGL (\d)/.exec(X)[1]),H=it>=1):X.indexOf("OpenGL ES")!==-1&&(it=parseFloat(/^OpenGL ES (\d)/.exec(X)[1]),H=it>=2);let ct=null,mt={},bt=s.getParameter(s.SCISSOR_BOX),Wt=s.getParameter(s.VIEWPORT),jt=new ie().fromArray(bt),le=new ie().fromArray(Wt);function Qt(N,lt,ft,wt){let ot=new Uint8Array(4),j=s.createTexture();s.bindTexture(N,j),s.texParameteri(N,s.TEXTURE_MIN_FILTER,s.NEAREST),s.texParameteri(N,s.TEXTURE_MAG_FILTER,s.NEAREST);for(let Ct=0;Ct<ft;Ct++)N===s.TEXTURE_3D||N===s.TEXTURE_2D_ARRAY?s.texImage3D(lt,0,s.RGBA,1,1,wt,0,s.RGBA,s.UNSIGNED_BYTE,ot):s.texImage2D(lt+Ct,0,s.RGBA,1,1,0,s.RGBA,s.UNSIGNED_BYTE,ot);return j}let Z={};Z[s.TEXTURE_2D]=Qt(s.TEXTURE_2D,s.TEXTURE_2D,1),Z[s.TEXTURE_CUBE_MAP]=Qt(s.TEXTURE_CUBE_MAP,s.TEXTURE_CUBE_MAP_POSITIVE_X,6),Z[s.TEXTURE_2D_ARRAY]=Qt(s.TEXTURE_2D_ARRAY,s.TEXTURE_2D_ARRAY,1,1),Z[s.TEXTURE_3D]=Qt(s.TEXTURE_3D,s.TEXTURE_3D,1,1),r.setClear(0,0,0,1),o.setClear(1),a.setClear(0),et(s.DEPTH_TEST),o.setFunc(Vn),J(!1),$(nh),et(s.CULL_FACE),tt(ln);function et(N){h[N]!==!0&&(s.enable(N),h[N]=!0)}function Mt(N){h[N]!==!1&&(s.disable(N),h[N]=!1)}function Lt(N,lt){return u[N]!==lt?(s.bindFramebuffer(N,lt),u[N]=lt,N===s.DRAW_FRAMEBUFFER&&(u[s.FRAMEBUFFER]=lt),N===s.FRAMEBUFFER&&(u[s.DRAW_FRAMEBUFFER]=lt),!0):!1}function Tt(N,lt){let ft=d,wt=!1;if(N){ft=f.get(lt),ft===void 0&&(ft=[],f.set(lt,ft));let ot=N.textures;if(ft.length!==ot.length||ft[0]!==s.COLOR_ATTACHMENT0){for(let j=0,Ct=ot.length;j<Ct;j++)ft[j]=s.COLOR_ATTACHMENT0+j;ft.length=ot.length,wt=!0}}else ft[0]!==s.BACK&&(ft[0]=s.BACK,wt=!0);wt&&s.drawBuffers(ft)}function Jt(N){return g!==N?(s.useProgram(N),g=N,!0):!1}let ge={[wn]:s.FUNC_ADD,[pd]:s.FUNC_SUBTRACT,[md]:s.FUNC_REVERSE_SUBTRACT};ge[gd]=s.MIN,ge[xd]=s.MAX;let D={[_d]:s.ZERO,[yd]:s.ONE,[vd]:s.SRC_COLOR,[la]:s.SRC_ALPHA,[Td]:s.SRC_ALPHA_SATURATE,[Sd]:s.DST_COLOR,[bd]:s.DST_ALPHA,[Md]:s.ONE_MINUS_SRC_COLOR,[ca]:s.ONE_MINUS_SRC_ALPHA,[Ed]:s.ONE_MINUS_DST_COLOR,[wd]:s.ONE_MINUS_DST_ALPHA,[Ad]:s.CONSTANT_COLOR,[Rd]:s.ONE_MINUS_CONSTANT_COLOR,[Cd]:s.CONSTANT_ALPHA,[Id]:s.ONE_MINUS_CONSTANT_ALPHA};function tt(N,lt,ft,wt,ot,j,Ct,Gt,xe,oe){if(N===ln){x===!0&&(Mt(s.BLEND),x=!1);return}if(x===!1&&(et(s.BLEND),x=!0),N!==fd){if(N!==m||oe!==w){if((p!==wn||_!==wn)&&(s.blendEquation(s.FUNC_ADD),p=wn,_=wn),oe)switch(N){case Ui:s.blendFuncSeparate(s.ONE,s.ONE_MINUS_SRC_ALPHA,s.ONE,s.ONE_MINUS_SRC_ALPHA);break;case ke:s.blendFunc(s.ONE,s.ONE);break;case sh:s.blendFuncSeparate(s.ZERO,s.ONE_MINUS_SRC_COLOR,s.ZERO,s.ONE);break;case rh:s.blendFuncSeparate(s.DST_COLOR,s.ONE_MINUS_SRC_ALPHA,s.ZERO,s.ONE);break;default:console.error("THREE.WebGLState: Invalid blending: ",N);break}else switch(N){case Ui:s.blendFuncSeparate(s.SRC_ALPHA,s.ONE_MINUS_SRC_ALPHA,s.ONE,s.ONE_MINUS_SRC_ALPHA);break;case ke:s.blendFuncSeparate(s.SRC_ALPHA,s.ONE,s.ONE,s.ONE);break;case sh:console.error("THREE.WebGLState: SubtractiveBlending requires material.premultipliedAlpha = true");break;case rh:console.error("THREE.WebGLState: MultiplyBlending requires material.premultipliedAlpha = true");break;default:console.error("THREE.WebGLState: Invalid blending: ",N);break}M=null,y=null,b=null,E=null,P.set(0,0,0),L=0,m=N,w=oe}return}ot=ot||lt,j=j||ft,Ct=Ct||wt,(lt!==p||ot!==_)&&(s.blendEquationSeparate(ge[lt],ge[ot]),p=lt,_=ot),(ft!==M||wt!==y||j!==b||Ct!==E)&&(s.blendFuncSeparate(D[ft],D[wt],D[j],D[Ct]),M=ft,y=wt,b=j,E=Ct),(Gt.equals(P)===!1||xe!==L)&&(s.blendColor(Gt.r,Gt.g,Gt.b,xe),P.copy(Gt),L=xe),m=N,w=!1}function K(N,lt){N.side===Fe?Mt(s.CULL_FACE):et(s.CULL_FACE);let ft=N.side===qe;lt&&(ft=!ft),J(ft),N.blending===Ui&&N.transparent===!1?tt(ln):tt(N.blending,N.blendEquation,N.blendSrc,N.blendDst,N.blendEquationAlpha,N.blendSrcAlpha,N.blendDstAlpha,N.blendColor,N.blendAlpha,N.premultipliedAlpha),o.setFunc(N.depthFunc),o.setTest(N.depthTest),o.setMask(N.depthWrite),r.setMask(N.colorWrite);let wt=N.stencilWrite;a.setTest(wt),wt&&(a.setMask(N.stencilWriteMask),a.setFunc(N.stencilFunc,N.stencilRef,N.stencilFuncMask),a.setOp(N.stencilFail,N.stencilZFail,N.stencilZPass)),st(N.polygonOffset,N.polygonOffsetFactor,N.polygonOffsetUnits),N.alphaToCoverage===!0?et(s.SAMPLE_ALPHA_TO_COVERAGE):Mt(s.SAMPLE_ALPHA_TO_COVERAGE)}function J(N){v!==N&&(N?s.frontFace(s.CW):s.frontFace(s.CCW),v=N)}function $(N){N!==ud?(et(s.CULL_FACE),N!==C&&(N===nh?s.cullFace(s.BACK):N===dd?s.cullFace(s.FRONT):s.cullFace(s.FRONT_AND_BACK))):Mt(s.CULL_FACE),C=N}function ut(N){N!==U&&(H&&s.lineWidth(N),U=N)}function st(N,lt,ft){N?(et(s.POLYGON_OFFSET_FILL),(O!==lt||z!==ft)&&(s.polygonOffset(lt,ft),O=lt,z=ft)):Mt(s.POLYGON_OFFSET_FILL)}function dt(N){N?et(s.SCISSOR_TEST):Mt(s.SCISSOR_TEST)}function Vt(N){N===void 0&&(N=s.TEXTURE0+q-1),ct!==N&&(s.activeTexture(N),ct=N)}function zt(N,lt,ft){ft===void 0&&(ct===null?ft=s.TEXTURE0+q-1:ft=ct);let wt=mt[ft];wt===void 0&&(wt={type:void 0,texture:void 0},mt[ft]=wt),(wt.type!==N||wt.texture!==lt)&&(ct!==ft&&(s.activeTexture(ft),ct=ft),s.bindTexture(N,lt||Z[N]),wt.type=N,wt.texture=lt)}function I(){let N=mt[ct];N!==void 0&&N.type!==void 0&&(s.bindTexture(N.type,null),N.type=void 0,N.texture=void 0)}function S(){try{s.compressedTexImage2D(...arguments)}catch(N){console.error("THREE.WebGLState:",N)}}function B(){try{s.compressedTexImage3D(...arguments)}catch(N){console.error("THREE.WebGLState:",N)}}function W(){try{s.texSubImage2D(...arguments)}catch(N){console.error("THREE.WebGLState:",N)}}function Q(){try{s.texSubImage3D(...arguments)}catch(N){console.error("THREE.WebGLState:",N)}}function Y(){try{s.compressedTexSubImage2D(...arguments)}catch(N){console.error("THREE.WebGLState:",N)}}function It(){try{s.compressedTexSubImage3D(...arguments)}catch(N){console.error("THREE.WebGLState:",N)}}function ht(){try{s.texStorage2D(...arguments)}catch(N){console.error("THREE.WebGLState:",N)}}function At(){try{s.texStorage3D(...arguments)}catch(N){console.error("THREE.WebGLState:",N)}}function Rt(){try{s.texImage2D(...arguments)}catch(N){console.error("THREE.WebGLState:",N)}}function rt(){try{s.texImage3D(...arguments)}catch(N){console.error("THREE.WebGLState:",N)}}function yt(N){jt.equals(N)===!1&&(s.scissor(N.x,N.y,N.z,N.w),jt.copy(N))}function Bt(N){le.equals(N)===!1&&(s.viewport(N.x,N.y,N.z,N.w),le.copy(N))}function Pt(N,lt){let ft=c.get(lt);ft===void 0&&(ft=new WeakMap,c.set(lt,ft));let wt=ft.get(N);wt===void 0&&(wt=s.getUniformBlockIndex(lt,N.name),ft.set(N,wt))}function gt(N,lt){let wt=c.get(lt).get(N);l.get(lt)!==wt&&(s.uniformBlockBinding(lt,wt,N.__bindingPointIndex),l.set(lt,wt))}function qt(){s.disable(s.BLEND),s.disable(s.CULL_FACE),s.disable(s.DEPTH_TEST),s.disable(s.POLYGON_OFFSET_FILL),s.disable(s.SCISSOR_TEST),s.disable(s.STENCIL_TEST),s.disable(s.SAMPLE_ALPHA_TO_COVERAGE),s.blendEquation(s.FUNC_ADD),s.blendFunc(s.ONE,s.ZERO),s.blendFuncSeparate(s.ONE,s.ZERO,s.ONE,s.ZERO),s.blendColor(0,0,0,0),s.colorMask(!0,!0,!0,!0),s.clearColor(0,0,0,0),s.depthMask(!0),s.depthFunc(s.LESS),o.setReversed(!1),s.clearDepth(1),s.stencilMask(4294967295),s.stencilFunc(s.ALWAYS,0,4294967295),s.stencilOp(s.KEEP,s.KEEP,s.KEEP),s.clearStencil(0),s.cullFace(s.BACK),s.frontFace(s.CCW),s.polygonOffset(0,0),s.activeTexture(s.TEXTURE0),s.bindFramebuffer(s.FRAMEBUFFER,null),s.bindFramebuffer(s.DRAW_FRAMEBUFFER,null),s.bindFramebuffer(s.READ_FRAMEBUFFER,null),s.useProgram(null),s.lineWidth(1),s.scissor(0,0,s.canvas.width,s.canvas.height),s.viewport(0,0,s.canvas.width,s.canvas.height),h={},ct=null,mt={},u={},f=new WeakMap,d=[],g=null,x=!1,m=null,p=null,M=null,y=null,_=null,b=null,E=null,P=new _t(0,0,0),L=0,w=!1,v=null,C=null,U=null,O=null,z=null,jt.set(0,0,s.canvas.width,s.canvas.height),le.set(0,0,s.canvas.width,s.canvas.height),r.reset(),o.reset(),a.reset()}return{buffers:{color:r,depth:o,stencil:a},enable:et,disable:Mt,bindFramebuffer:Lt,drawBuffers:Tt,useProgram:Jt,setBlending:tt,setMaterial:K,setFlipSided:J,setCullFace:$,setLineWidth:ut,setPolygonOffset:st,setScissorTest:dt,activeTexture:Vt,bindTexture:zt,unbindTexture:I,compressedTexImage2D:S,compressedTexImage3D:B,texImage2D:Rt,texImage3D:rt,updateUBOMapping:Pt,uniformBlockBinding:gt,texStorage2D:ht,texStorage3D:At,texSubImage2D:W,texSubImage3D:Q,compressedTexSubImage2D:Y,compressedTexSubImage3D:It,scissor:yt,viewport:Bt,reset:qt}}function Sy(s,t,e,i,n,r,o){let a=t.has("WEBGL_multisampled_render_to_texture")?t.get("WEBGL_multisampled_render_to_texture"):null,l=typeof navigator>"u"?!1:/OculusBrowser/g.test(navigator.userAgent),c=new nt,h=new WeakMap,u,f=new WeakMap,d=!1;try{d=typeof OffscreenCanvas<"u"&&new OffscreenCanvas(1,1).getContext("2d")!==null}catch{}function g(I,S){return d?new OffscreenCanvas(I,S):Sr("canvas")}function x(I,S,B){let W=1,Q=zt(I);if((Q.width>B||Q.height>B)&&(W=B/Math.max(Q.width,Q.height)),W<1)if(typeof HTMLImageElement<"u"&&I instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&I instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&I instanceof ImageBitmap||typeof VideoFrame<"u"&&I instanceof VideoFrame){let Y=Math.floor(W*Q.width),It=Math.floor(W*Q.height);u===void 0&&(u=g(Y,It));let ht=S?g(Y,It):u;return ht.width=Y,ht.height=It,ht.getContext("2d").drawImage(I,0,0,Y,It),console.warn("THREE.WebGLRenderer: Texture has been resized from ("+Q.width+"x"+Q.height+") to ("+Y+"x"+It+")."),ht}else return"data"in I&&console.warn("THREE.WebGLRenderer: Image in DataTexture is too big ("+Q.width+"x"+Q.height+")."),I;return I}function m(I){return I.generateMipmaps}function p(I){s.generateMipmap(I)}function M(I){return I.isWebGLCubeRenderTarget?s.TEXTURE_CUBE_MAP:I.isWebGL3DRenderTarget?s.TEXTURE_3D:I.isWebGLArrayRenderTarget||I.isCompressedArrayTexture?s.TEXTURE_2D_ARRAY:s.TEXTURE_2D}function y(I,S,B,W,Q=!1){if(I!==null){if(s[I]!==void 0)return s[I];console.warn("THREE.WebGLRenderer: Attempt to use non-existing WebGL internal format '"+I+"'")}let Y=S;if(S===s.RED&&(B===s.FLOAT&&(Y=s.R32F),B===s.HALF_FLOAT&&(Y=s.R16F),B===s.UNSIGNED_BYTE&&(Y=s.R8)),S===s.RED_INTEGER&&(B===s.UNSIGNED_BYTE&&(Y=s.R8UI),B===s.UNSIGNED_SHORT&&(Y=s.R16UI),B===s.UNSIGNED_INT&&(Y=s.R32UI),B===s.BYTE&&(Y=s.R8I),B===s.SHORT&&(Y=s.R16I),B===s.INT&&(Y=s.R32I)),S===s.RG&&(B===s.FLOAT&&(Y=s.RG32F),B===s.HALF_FLOAT&&(Y=s.RG16F),B===s.UNSIGNED_BYTE&&(Y=s.RG8)),S===s.RG_INTEGER&&(B===s.UNSIGNED_BYTE&&(Y=s.RG8UI),B===s.UNSIGNED_SHORT&&(Y=s.RG16UI),B===s.UNSIGNED_INT&&(Y=s.RG32UI),B===s.BYTE&&(Y=s.RG8I),B===s.SHORT&&(Y=s.RG16I),B===s.INT&&(Y=s.RG32I)),S===s.RGB_INTEGER&&(B===s.UNSIGNED_BYTE&&(Y=s.RGB8UI),B===s.UNSIGNED_SHORT&&(Y=s.RGB16UI),B===s.UNSIGNED_INT&&(Y=s.RGB32UI),B===s.BYTE&&(Y=s.RGB8I),B===s.SHORT&&(Y=s.RGB16I),B===s.INT&&(Y=s.RGB32I)),S===s.RGBA_INTEGER&&(B===s.UNSIGNED_BYTE&&(Y=s.RGBA8UI),B===s.UNSIGNED_SHORT&&(Y=s.RGBA16UI),B===s.UNSIGNED_INT&&(Y=s.RGBA32UI),B===s.BYTE&&(Y=s.RGBA8I),B===s.SHORT&&(Y=s.RGBA16I),B===s.INT&&(Y=s.RGBA32I)),S===s.RGB&&(B===s.UNSIGNED_INT_5_9_9_9_REV&&(Y=s.RGB9_E5),B===s.UNSIGNED_INT_10F_11F_11F_REV&&(Y=s.R11F_G11F_B10F)),S===s.RGBA){let It=Q?br:te.getTransfer(W);B===s.FLOAT&&(Y=s.RGBA32F),B===s.HALF_FLOAT&&(Y=s.RGBA16F),B===s.UNSIGNED_BYTE&&(Y=It===he?s.SRGB8_ALPHA8:s.RGBA8),B===s.UNSIGNED_SHORT_4_4_4_4&&(Y=s.RGBA4),B===s.UNSIGNED_SHORT_5_5_5_1&&(Y=s.RGB5_A1)}return(Y===s.R16F||Y===s.R32F||Y===s.RG16F||Y===s.RG32F||Y===s.RGBA16F||Y===s.RGBA32F)&&t.get("EXT_color_buffer_float"),Y}function _(I,S){let B;return I?S===null||S===Cn||S===Vs?B=s.DEPTH24_STENCIL8:S===Si?B=s.DEPTH32F_STENCIL8:S===zs&&(B=s.DEPTH24_STENCIL8,console.warn("DepthTexture: 16 bit depth attachment is not supported with stencil. Using 24-bit attachment.")):S===null||S===Cn||S===Vs?B=s.DEPTH_COMPONENT24:S===Si?B=s.DEPTH_COMPONENT32F:S===zs&&(B=s.DEPTH_COMPONENT16),B}function b(I,S){return m(I)===!0||I.isFramebufferTexture&&I.minFilter!==li&&I.minFilter!==Ni?Math.log2(Math.max(S.width,S.height))+1:I.mipmaps!==void 0&&I.mipmaps.length>0?I.mipmaps.length:I.isCompressedTexture&&Array.isArray(I.image)?S.mipmaps.length:1}function E(I){let S=I.target;S.removeEventListener("dispose",E),L(S),S.isVideoTexture&&h.delete(S)}function P(I){let S=I.target;S.removeEventListener("dispose",P),v(S)}function L(I){let S=i.get(I);if(S.__webglInit===void 0)return;let B=I.source,W=f.get(B);if(W){let Q=W[S.__cacheKey];Q.usedTimes--,Q.usedTimes===0&&w(I),Object.keys(W).length===0&&f.delete(B)}i.remove(I)}function w(I){let S=i.get(I);s.deleteTexture(S.__webglTexture);let B=I.source,W=f.get(B);delete W[S.__cacheKey],o.memory.textures--}function v(I){let S=i.get(I);if(I.depthTexture&&(I.depthTexture.dispose(),i.remove(I.depthTexture)),I.isWebGLCubeRenderTarget)for(let W=0;W<6;W++){if(Array.isArray(S.__webglFramebuffer[W]))for(let Q=0;Q<S.__webglFramebuffer[W].length;Q++)s.deleteFramebuffer(S.__webglFramebuffer[W][Q]);else s.deleteFramebuffer(S.__webglFramebuffer[W]);S.__webglDepthbuffer&&s.deleteRenderbuffer(S.__webglDepthbuffer[W])}else{if(Array.isArray(S.__webglFramebuffer))for(let W=0;W<S.__webglFramebuffer.length;W++)s.deleteFramebuffer(S.__webglFramebuffer[W]);else s.deleteFramebuffer(S.__webglFramebuffer);if(S.__webglDepthbuffer&&s.deleteRenderbuffer(S.__webglDepthbuffer),S.__webglMultisampledFramebuffer&&s.deleteFramebuffer(S.__webglMultisampledFramebuffer),S.__webglColorRenderbuffer)for(let W=0;W<S.__webglColorRenderbuffer.length;W++)S.__webglColorRenderbuffer[W]&&s.deleteRenderbuffer(S.__webglColorRenderbuffer[W]);S.__webglDepthRenderbuffer&&s.deleteRenderbuffer(S.__webglDepthRenderbuffer)}let B=I.textures;for(let W=0,Q=B.length;W<Q;W++){let Y=i.get(B[W]);Y.__webglTexture&&(s.deleteTexture(Y.__webglTexture),o.memory.textures--),i.remove(B[W])}i.remove(I)}let C=0;function U(){C=0}function O(){let I=C;return I>=n.maxTextures&&console.warn("THREE.WebGLTextures: Trying to use "+I+" texture units while this GPU supports only "+n.maxTextures),C+=1,I}function z(I){let S=[];return S.push(I.wrapS),S.push(I.wrapT),S.push(I.wrapR||0),S.push(I.magFilter),S.push(I.minFilter),S.push(I.anisotropy),S.push(I.internalFormat),S.push(I.format),S.push(I.type),S.push(I.generateMipmaps),S.push(I.premultiplyAlpha),S.push(I.flipY),S.push(I.unpackAlignment),S.push(I.colorSpace),S.join()}function q(I,S){let B=i.get(I);if(I.isVideoTexture&&dt(I),I.isRenderTargetTexture===!1&&I.isExternalTexture!==!0&&I.version>0&&B.__version!==I.version){let W=I.image;if(W===null)console.warn("THREE.WebGLRenderer: Texture marked for update but no image data found.");else if(W.complete===!1)console.warn("THREE.WebGLRenderer: Texture marked for update but image is incomplete");else{Z(B,I,S);return}}else I.isExternalTexture&&(B.__webglTexture=I.sourceTexture?I.sourceTexture:null);e.bindTexture(s.TEXTURE_2D,B.__webglTexture,s.TEXTURE0+S)}function H(I,S){let B=i.get(I);if(I.isRenderTargetTexture===!1&&I.version>0&&B.__version!==I.version){Z(B,I,S);return}e.bindTexture(s.TEXTURE_2D_ARRAY,B.__webglTexture,s.TEXTURE0+S)}function it(I,S){let B=i.get(I);if(I.isRenderTargetTexture===!1&&I.version>0&&B.__version!==I.version){Z(B,I,S);return}e.bindTexture(s.TEXTURE_3D,B.__webglTexture,s.TEXTURE0+S)}function X(I,S){let B=i.get(I);if(I.version>0&&B.__version!==I.version){et(B,I,S);return}e.bindTexture(s.TEXTURE_CUBE_MAP,B.__webglTexture,s.TEXTURE0+S)}let ct={[Ts]:s.REPEAT,[bn]:s.CLAMP_TO_EDGE,[ha]:s.MIRRORED_REPEAT},mt={[li]:s.NEAREST,[zd]:s.NEAREST_MIPMAP_NEAREST,[ro]:s.NEAREST_MIPMAP_LINEAR,[Ni]:s.LINEAR,[Ja]:s.LINEAR_MIPMAP_NEAREST,[Rn]:s.LINEAR_MIPMAP_LINEAR},bt={[Wd]:s.NEVER,[Jd]:s.ALWAYS,[Xd]:s.LESS,[ph]:s.LEQUAL,[qd]:s.EQUAL,[$d]:s.GEQUAL,[Yd]:s.GREATER,[Zd]:s.NOTEQUAL};function Wt(I,S){if(S.type===Si&&t.has("OES_texture_float_linear")===!1&&(S.magFilter===Ni||S.magFilter===Ja||S.magFilter===ro||S.magFilter===Rn||S.minFilter===Ni||S.minFilter===Ja||S.minFilter===ro||S.minFilter===Rn)&&console.warn("THREE.WebGLRenderer: Unable to use linear filtering with floating point textures. OES_texture_float_linear not supported on this device."),s.texParameteri(I,s.TEXTURE_WRAP_S,ct[S.wrapS]),s.texParameteri(I,s.TEXTURE_WRAP_T,ct[S.wrapT]),(I===s.TEXTURE_3D||I===s.TEXTURE_2D_ARRAY)&&s.texParameteri(I,s.TEXTURE_WRAP_R,ct[S.wrapR]),s.texParameteri(I,s.TEXTURE_MAG_FILTER,mt[S.magFilter]),s.texParameteri(I,s.TEXTURE_MIN_FILTER,mt[S.minFilter]),S.compareFunction&&(s.texParameteri(I,s.TEXTURE_COMPARE_MODE,s.COMPARE_REF_TO_TEXTURE),s.texParameteri(I,s.TEXTURE_COMPARE_FUNC,bt[S.compareFunction])),t.has("EXT_texture_filter_anisotropic")===!0){if(S.magFilter===li||S.minFilter!==ro&&S.minFilter!==Rn||S.type===Si&&t.has("OES_texture_float_linear")===!1)return;if(S.anisotropy>1||i.get(S).__currentAnisotropy){let B=t.get("EXT_texture_filter_anisotropic");s.texParameterf(I,B.TEXTURE_MAX_ANISOTROPY_EXT,Math.min(S.anisotropy,n.getMaxAnisotropy())),i.get(S).__currentAnisotropy=S.anisotropy}}}function jt(I,S){let B=!1;I.__webglInit===void 0&&(I.__webglInit=!0,S.addEventListener("dispose",E));let W=S.source,Q=f.get(W);Q===void 0&&(Q={},f.set(W,Q));let Y=z(S);if(Y!==I.__cacheKey){Q[Y]===void 0&&(Q[Y]={texture:s.createTexture(),usedTimes:0},o.memory.textures++,B=!0),Q[Y].usedTimes++;let It=Q[I.__cacheKey];It!==void 0&&(Q[I.__cacheKey].usedTimes--,It.usedTimes===0&&w(S)),I.__cacheKey=Y,I.__webglTexture=Q[Y].texture}return B}function le(I,S,B){return Math.floor(Math.floor(I/B)/S)}function Qt(I,S,B,W){let Y=I.updateRanges;if(Y.length===0)e.texSubImage2D(s.TEXTURE_2D,0,0,0,S.width,S.height,B,W,S.data);else{Y.sort((rt,yt)=>rt.start-yt.start);let It=0;for(let rt=1;rt<Y.length;rt++){let yt=Y[It],Bt=Y[rt],Pt=yt.start+yt.count,gt=le(Bt.start,S.width,4),qt=le(yt.start,S.width,4);Bt.start<=Pt+1&&gt===qt&&le(Bt.start+Bt.count-1,S.width,4)===gt?yt.count=Math.max(yt.count,Bt.start+Bt.count-yt.start):(++It,Y[It]=Bt)}Y.length=It+1;let ht=s.getParameter(s.UNPACK_ROW_LENGTH),At=s.getParameter(s.UNPACK_SKIP_PIXELS),Rt=s.getParameter(s.UNPACK_SKIP_ROWS);s.pixelStorei(s.UNPACK_ROW_LENGTH,S.width);for(let rt=0,yt=Y.length;rt<yt;rt++){let Bt=Y[rt],Pt=Math.floor(Bt.start/4),gt=Math.ceil(Bt.count/4),qt=Pt%S.width,N=Math.floor(Pt/S.width),lt=gt,ft=1;s.pixelStorei(s.UNPACK_SKIP_PIXELS,qt),s.pixelStorei(s.UNPACK_SKIP_ROWS,N),e.texSubImage2D(s.TEXTURE_2D,0,qt,N,lt,ft,B,W,S.data)}I.clearUpdateRanges(),s.pixelStorei(s.UNPACK_ROW_LENGTH,ht),s.pixelStorei(s.UNPACK_SKIP_PIXELS,At),s.pixelStorei(s.UNPACK_SKIP_ROWS,Rt)}}function Z(I,S,B){let W=s.TEXTURE_2D;(S.isDataArrayTexture||S.isCompressedArrayTexture)&&(W=s.TEXTURE_2D_ARRAY),S.isData3DTexture&&(W=s.TEXTURE_3D);let Q=jt(I,S),Y=S.source;e.bindTexture(W,I.__webglTexture,s.TEXTURE0+B);let It=i.get(Y);if(Y.version!==It.__version||Q===!0){e.activeTexture(s.TEXTURE0+B);let ht=te.getPrimaries(te.workingColorSpace),At=S.colorSpace===Bi?null:te.getPrimaries(S.colorSpace),Rt=S.colorSpace===Bi||ht===At?s.NONE:s.BROWSER_DEFAULT_WEBGL;s.pixelStorei(s.UNPACK_FLIP_Y_WEBGL,S.flipY),s.pixelStorei(s.UNPACK_PREMULTIPLY_ALPHA_WEBGL,S.premultiplyAlpha),s.pixelStorei(s.UNPACK_ALIGNMENT,S.unpackAlignment),s.pixelStorei(s.UNPACK_COLORSPACE_CONVERSION_WEBGL,Rt);let rt=x(S.image,!1,n.maxTextureSize);rt=Vt(S,rt);let yt=r.convert(S.format,S.colorSpace),Bt=r.convert(S.type),Pt=y(S.internalFormat,yt,Bt,S.colorSpace,S.isVideoTexture);Wt(W,S);let gt,qt=S.mipmaps,N=S.isVideoTexture!==!0,lt=It.__version===void 0||Q===!0,ft=Y.dataReady,wt=b(S,rt);if(S.isDepthTexture)Pt=_(S.format===Gs,S.type),lt&&(N?e.texStorage2D(s.TEXTURE_2D,1,Pt,rt.width,rt.height):e.texImage2D(s.TEXTURE_2D,0,Pt,rt.width,rt.height,0,yt,Bt,null));else if(S.isDataTexture)if(qt.length>0){N&&lt&&e.texStorage2D(s.TEXTURE_2D,wt,Pt,qt[0].width,qt[0].height);for(let ot=0,j=qt.length;ot<j;ot++)gt=qt[ot],N?ft&&e.texSubImage2D(s.TEXTURE_2D,ot,0,0,gt.width,gt.height,yt,Bt,gt.data):e.texImage2D(s.TEXTURE_2D,ot,Pt,gt.width,gt.height,0,yt,Bt,gt.data);S.generateMipmaps=!1}else N?(lt&&e.texStorage2D(s.TEXTURE_2D,wt,Pt,rt.width,rt.height),ft&&Qt(S,rt,yt,Bt)):e.texImage2D(s.TEXTURE_2D,0,Pt,rt.width,rt.height,0,yt,Bt,rt.data);else if(S.isCompressedTexture)if(S.isCompressedArrayTexture){N&&lt&&e.texStorage3D(s.TEXTURE_2D_ARRAY,wt,Pt,qt[0].width,qt[0].height,rt.depth);for(let ot=0,j=qt.length;ot<j;ot++)if(gt=qt[ot],S.format!==gi)if(yt!==null)if(N){if(ft)if(S.layerUpdates.size>0){let Ct=wh(gt.width,gt.height,S.format,S.type);for(let Gt of S.layerUpdates){let xe=gt.data.subarray(Gt*Ct/gt.data.BYTES_PER_ELEMENT,(Gt+1)*Ct/gt.data.BYTES_PER_ELEMENT);e.compressedTexSubImage3D(s.TEXTURE_2D_ARRAY,ot,0,0,Gt,gt.width,gt.height,1,yt,xe)}S.clearLayerUpdates()}else e.compressedTexSubImage3D(s.TEXTURE_2D_ARRAY,ot,0,0,0,gt.width,gt.height,rt.depth,yt,gt.data)}else e.compressedTexImage3D(s.TEXTURE_2D_ARRAY,ot,Pt,gt.width,gt.height,rt.depth,0,gt.data,0,0);else console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()");else N?ft&&e.texSubImage3D(s.TEXTURE_2D_ARRAY,ot,0,0,0,gt.width,gt.height,rt.depth,yt,Bt,gt.data):e.texImage3D(s.TEXTURE_2D_ARRAY,ot,Pt,gt.width,gt.height,rt.depth,0,yt,Bt,gt.data)}else{N&&lt&&e.texStorage2D(s.TEXTURE_2D,wt,Pt,qt[0].width,qt[0].height);for(let ot=0,j=qt.length;ot<j;ot++)gt=qt[ot],S.format!==gi?yt!==null?N?ft&&e.compressedTexSubImage2D(s.TEXTURE_2D,ot,0,0,gt.width,gt.height,yt,gt.data):e.compressedTexImage2D(s.TEXTURE_2D,ot,Pt,gt.width,gt.height,0,gt.data):console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()"):N?ft&&e.texSubImage2D(s.TEXTURE_2D,ot,0,0,gt.width,gt.height,yt,Bt,gt.data):e.texImage2D(s.TEXTURE_2D,ot,Pt,gt.width,gt.height,0,yt,Bt,gt.data)}else if(S.isDataArrayTexture)if(N){if(lt&&e.texStorage3D(s.TEXTURE_2D_ARRAY,wt,Pt,rt.width,rt.height,rt.depth),ft)if(S.layerUpdates.size>0){let ot=wh(rt.width,rt.height,S.format,S.type);for(let j of S.layerUpdates){let Ct=rt.data.subarray(j*ot/rt.data.BYTES_PER_ELEMENT,(j+1)*ot/rt.data.BYTES_PER_ELEMENT);e.texSubImage3D(s.TEXTURE_2D_ARRAY,0,0,0,j,rt.width,rt.height,1,yt,Bt,Ct)}S.clearLayerUpdates()}else e.texSubImage3D(s.TEXTURE_2D_ARRAY,0,0,0,0,rt.width,rt.height,rt.depth,yt,Bt,rt.data)}else e.texImage3D(s.TEXTURE_2D_ARRAY,0,Pt,rt.width,rt.height,rt.depth,0,yt,Bt,rt.data);else if(S.isData3DTexture)N?(lt&&e.texStorage3D(s.TEXTURE_3D,wt,Pt,rt.width,rt.height,rt.depth),ft&&e.texSubImage3D(s.TEXTURE_3D,0,0,0,0,rt.width,rt.height,rt.depth,yt,Bt,rt.data)):e.texImage3D(s.TEXTURE_3D,0,Pt,rt.width,rt.height,rt.depth,0,yt,Bt,rt.data);else if(S.isFramebufferTexture){if(lt)if(N)e.texStorage2D(s.TEXTURE_2D,wt,Pt,rt.width,rt.height);else{let ot=rt.width,j=rt.height;for(let Ct=0;Ct<wt;Ct++)e.texImage2D(s.TEXTURE_2D,Ct,Pt,ot,j,0,yt,Bt,null),ot>>=1,j>>=1}}else if(qt.length>0){if(N&&lt){let ot=zt(qt[0]);e.texStorage2D(s.TEXTURE_2D,wt,Pt,ot.width,ot.height)}for(let ot=0,j=qt.length;ot<j;ot++)gt=qt[ot],N?ft&&e.texSubImage2D(s.TEXTURE_2D,ot,0,0,yt,Bt,gt):e.texImage2D(s.TEXTURE_2D,ot,Pt,yt,Bt,gt);S.generateMipmaps=!1}else if(N){if(lt){let ot=zt(rt);e.texStorage2D(s.TEXTURE_2D,wt,Pt,ot.width,ot.height)}ft&&e.texSubImage2D(s.TEXTURE_2D,0,0,0,yt,Bt,rt)}else e.texImage2D(s.TEXTURE_2D,0,Pt,yt,Bt,rt);m(S)&&p(W),It.__version=Y.version,S.onUpdate&&S.onUpdate(S)}I.__version=S.version}function et(I,S,B){if(S.image.length!==6)return;let W=jt(I,S),Q=S.source;e.bindTexture(s.TEXTURE_CUBE_MAP,I.__webglTexture,s.TEXTURE0+B);let Y=i.get(Q);if(Q.version!==Y.__version||W===!0){e.activeTexture(s.TEXTURE0+B);let It=te.getPrimaries(te.workingColorSpace),ht=S.colorSpace===Bi?null:te.getPrimaries(S.colorSpace),At=S.colorSpace===Bi||It===ht?s.NONE:s.BROWSER_DEFAULT_WEBGL;s.pixelStorei(s.UNPACK_FLIP_Y_WEBGL,S.flipY),s.pixelStorei(s.UNPACK_PREMULTIPLY_ALPHA_WEBGL,S.premultiplyAlpha),s.pixelStorei(s.UNPACK_ALIGNMENT,S.unpackAlignment),s.pixelStorei(s.UNPACK_COLORSPACE_CONVERSION_WEBGL,At);let Rt=S.isCompressedTexture||S.image[0].isCompressedTexture,rt=S.image[0]&&S.image[0].isDataTexture,yt=[];for(let j=0;j<6;j++)!Rt&&!rt?yt[j]=x(S.image[j],!0,n.maxCubemapSize):yt[j]=rt?S.image[j].image:S.image[j],yt[j]=Vt(S,yt[j]);let Bt=yt[0],Pt=r.convert(S.format,S.colorSpace),gt=r.convert(S.type),qt=y(S.internalFormat,Pt,gt,S.colorSpace),N=S.isVideoTexture!==!0,lt=Y.__version===void 0||W===!0,ft=Q.dataReady,wt=b(S,Bt);Wt(s.TEXTURE_CUBE_MAP,S);let ot;if(Rt){N&&lt&&e.texStorage2D(s.TEXTURE_CUBE_MAP,wt,qt,Bt.width,Bt.height);for(let j=0;j<6;j++){ot=yt[j].mipmaps;for(let Ct=0;Ct<ot.length;Ct++){let Gt=ot[Ct];S.format!==gi?Pt!==null?N?ft&&e.compressedTexSubImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+j,Ct,0,0,Gt.width,Gt.height,Pt,Gt.data):e.compressedTexImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+j,Ct,qt,Gt.width,Gt.height,0,Gt.data):console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .setTextureCube()"):N?ft&&e.texSubImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+j,Ct,0,0,Gt.width,Gt.height,Pt,gt,Gt.data):e.texImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+j,Ct,qt,Gt.width,Gt.height,0,Pt,gt,Gt.data)}}}else{if(ot=S.mipmaps,N&&lt){ot.length>0&&wt++;let j=zt(yt[0]);e.texStorage2D(s.TEXTURE_CUBE_MAP,wt,qt,j.width,j.height)}for(let j=0;j<6;j++)if(rt){N?ft&&e.texSubImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+j,0,0,0,yt[j].width,yt[j].height,Pt,gt,yt[j].data):e.texImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+j,0,qt,yt[j].width,yt[j].height,0,Pt,gt,yt[j].data);for(let Ct=0;Ct<ot.length;Ct++){let xe=ot[Ct].image[j].image;N?ft&&e.texSubImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+j,Ct+1,0,0,xe.width,xe.height,Pt,gt,xe.data):e.texImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+j,Ct+1,qt,xe.width,xe.height,0,Pt,gt,xe.data)}}else{N?ft&&e.texSubImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+j,0,0,0,Pt,gt,yt[j]):e.texImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+j,0,qt,Pt,gt,yt[j]);for(let Ct=0;Ct<ot.length;Ct++){let Gt=ot[Ct];N?ft&&e.texSubImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+j,Ct+1,0,0,Pt,gt,Gt.image[j]):e.texImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+j,Ct+1,qt,Pt,gt,Gt.image[j])}}}m(S)&&p(s.TEXTURE_CUBE_MAP),Y.__version=Q.version,S.onUpdate&&S.onUpdate(S)}I.__version=S.version}function Mt(I,S,B,W,Q,Y){let It=r.convert(B.format,B.colorSpace),ht=r.convert(B.type),At=y(B.internalFormat,It,ht,B.colorSpace),Rt=i.get(S),rt=i.get(B);if(rt.__renderTarget=S,!Rt.__hasExternalTextures){let yt=Math.max(1,S.width>>Y),Bt=Math.max(1,S.height>>Y);Q===s.TEXTURE_3D||Q===s.TEXTURE_2D_ARRAY?e.texImage3D(Q,Y,At,yt,Bt,S.depth,0,It,ht,null):e.texImage2D(Q,Y,At,yt,Bt,0,It,ht,null)}e.bindFramebuffer(s.FRAMEBUFFER,I),st(S)?a.framebufferTexture2DMultisampleEXT(s.FRAMEBUFFER,W,Q,rt.__webglTexture,0,ut(S)):(Q===s.TEXTURE_2D||Q>=s.TEXTURE_CUBE_MAP_POSITIVE_X&&Q<=s.TEXTURE_CUBE_MAP_NEGATIVE_Z)&&s.framebufferTexture2D(s.FRAMEBUFFER,W,Q,rt.__webglTexture,Y),e.bindFramebuffer(s.FRAMEBUFFER,null)}function Lt(I,S,B){if(s.bindRenderbuffer(s.RENDERBUFFER,I),S.depthBuffer){let W=S.depthTexture,Q=W&&W.isDepthTexture?W.type:null,Y=_(S.stencilBuffer,Q),It=S.stencilBuffer?s.DEPTH_STENCIL_ATTACHMENT:s.DEPTH_ATTACHMENT,ht=ut(S);st(S)?a.renderbufferStorageMultisampleEXT(s.RENDERBUFFER,ht,Y,S.width,S.height):B?s.renderbufferStorageMultisample(s.RENDERBUFFER,ht,Y,S.width,S.height):s.renderbufferStorage(s.RENDERBUFFER,Y,S.width,S.height),s.framebufferRenderbuffer(s.FRAMEBUFFER,It,s.RENDERBUFFER,I)}else{let W=S.textures;for(let Q=0;Q<W.length;Q++){let Y=W[Q],It=r.convert(Y.format,Y.colorSpace),ht=r.convert(Y.type),At=y(Y.internalFormat,It,ht,Y.colorSpace),Rt=ut(S);B&&st(S)===!1?s.renderbufferStorageMultisample(s.RENDERBUFFER,Rt,At,S.width,S.height):st(S)?a.renderbufferStorageMultisampleEXT(s.RENDERBUFFER,Rt,At,S.width,S.height):s.renderbufferStorage(s.RENDERBUFFER,At,S.width,S.height)}}s.bindRenderbuffer(s.RENDERBUFFER,null)}function Tt(I,S){if(S&&S.isWebGLCubeRenderTarget)throw new Error("Depth Texture with cube render targets is not supported");if(e.bindFramebuffer(s.FRAMEBUFFER,I),!(S.depthTexture&&S.depthTexture.isDepthTexture))throw new Error("renderTarget.depthTexture must be an instance of THREE.DepthTexture");let W=i.get(S.depthTexture);W.__renderTarget=S,(!W.__webglTexture||S.depthTexture.image.width!==S.width||S.depthTexture.image.height!==S.height)&&(S.depthTexture.image.width=S.width,S.depthTexture.image.height=S.height,S.depthTexture.needsUpdate=!0),q(S.depthTexture,0);let Q=W.__webglTexture,Y=ut(S);if(S.depthTexture.format===As)st(S)?a.framebufferTexture2DMultisampleEXT(s.FRAMEBUFFER,s.DEPTH_ATTACHMENT,s.TEXTURE_2D,Q,0,Y):s.framebufferTexture2D(s.FRAMEBUFFER,s.DEPTH_ATTACHMENT,s.TEXTURE_2D,Q,0);else if(S.depthTexture.format===Gs)st(S)?a.framebufferTexture2DMultisampleEXT(s.FRAMEBUFFER,s.DEPTH_STENCIL_ATTACHMENT,s.TEXTURE_2D,Q,0,Y):s.framebufferTexture2D(s.FRAMEBUFFER,s.DEPTH_STENCIL_ATTACHMENT,s.TEXTURE_2D,Q,0);else throw new Error("Unknown depthTexture format")}function Jt(I){let S=i.get(I),B=I.isWebGLCubeRenderTarget===!0;if(S.__boundDepthTexture!==I.depthTexture){let W=I.depthTexture;if(S.__depthDisposeCallback&&S.__depthDisposeCallback(),W){let Q=()=>{delete S.__boundDepthTexture,delete S.__depthDisposeCallback,W.removeEventListener("dispose",Q)};W.addEventListener("dispose",Q),S.__depthDisposeCallback=Q}S.__boundDepthTexture=W}if(I.depthTexture&&!S.__autoAllocateDepthBuffer){if(B)throw new Error("target.depthTexture not supported in Cube render targets");let W=I.texture.mipmaps;W&&W.length>0?Tt(S.__webglFramebuffer[0],I):Tt(S.__webglFramebuffer,I)}else if(B){S.__webglDepthbuffer=[];for(let W=0;W<6;W++)if(e.bindFramebuffer(s.FRAMEBUFFER,S.__webglFramebuffer[W]),S.__webglDepthbuffer[W]===void 0)S.__webglDepthbuffer[W]=s.createRenderbuffer(),Lt(S.__webglDepthbuffer[W],I,!1);else{let Q=I.stencilBuffer?s.DEPTH_STENCIL_ATTACHMENT:s.DEPTH_ATTACHMENT,Y=S.__webglDepthbuffer[W];s.bindRenderbuffer(s.RENDERBUFFER,Y),s.framebufferRenderbuffer(s.FRAMEBUFFER,Q,s.RENDERBUFFER,Y)}}else{let W=I.texture.mipmaps;if(W&&W.length>0?e.bindFramebuffer(s.FRAMEBUFFER,S.__webglFramebuffer[0]):e.bindFramebuffer(s.FRAMEBUFFER,S.__webglFramebuffer),S.__webglDepthbuffer===void 0)S.__webglDepthbuffer=s.createRenderbuffer(),Lt(S.__webglDepthbuffer,I,!1);else{let Q=I.stencilBuffer?s.DEPTH_STENCIL_ATTACHMENT:s.DEPTH_ATTACHMENT,Y=S.__webglDepthbuffer;s.bindRenderbuffer(s.RENDERBUFFER,Y),s.framebufferRenderbuffer(s.FRAMEBUFFER,Q,s.RENDERBUFFER,Y)}}e.bindFramebuffer(s.FRAMEBUFFER,null)}function ge(I,S,B){let W=i.get(I);S!==void 0&&Mt(W.__webglFramebuffer,I,I.texture,s.COLOR_ATTACHMENT0,s.TEXTURE_2D,0),B!==void 0&&Jt(I)}function D(I){let S=I.texture,B=i.get(I),W=i.get(S);I.addEventListener("dispose",P);let Q=I.textures,Y=I.isWebGLCubeRenderTarget===!0,It=Q.length>1;if(It||(W.__webglTexture===void 0&&(W.__webglTexture=s.createTexture()),W.__version=S.version,o.memory.textures++),Y){B.__webglFramebuffer=[];for(let ht=0;ht<6;ht++)if(S.mipmaps&&S.mipmaps.length>0){B.__webglFramebuffer[ht]=[];for(let At=0;At<S.mipmaps.length;At++)B.__webglFramebuffer[ht][At]=s.createFramebuffer()}else B.__webglFramebuffer[ht]=s.createFramebuffer()}else{if(S.mipmaps&&S.mipmaps.length>0){B.__webglFramebuffer=[];for(let ht=0;ht<S.mipmaps.length;ht++)B.__webglFramebuffer[ht]=s.createFramebuffer()}else B.__webglFramebuffer=s.createFramebuffer();if(It)for(let ht=0,At=Q.length;ht<At;ht++){let Rt=i.get(Q[ht]);Rt.__webglTexture===void 0&&(Rt.__webglTexture=s.createTexture(),o.memory.textures++)}if(I.samples>0&&st(I)===!1){B.__webglMultisampledFramebuffer=s.createFramebuffer(),B.__webglColorRenderbuffer=[],e.bindFramebuffer(s.FRAMEBUFFER,B.__webglMultisampledFramebuffer);for(let ht=0;ht<Q.length;ht++){let At=Q[ht];B.__webglColorRenderbuffer[ht]=s.createRenderbuffer(),s.bindRenderbuffer(s.RENDERBUFFER,B.__webglColorRenderbuffer[ht]);let Rt=r.convert(At.format,At.colorSpace),rt=r.convert(At.type),yt=y(At.internalFormat,Rt,rt,At.colorSpace,I.isXRRenderTarget===!0),Bt=ut(I);s.renderbufferStorageMultisample(s.RENDERBUFFER,Bt,yt,I.width,I.height),s.framebufferRenderbuffer(s.FRAMEBUFFER,s.COLOR_ATTACHMENT0+ht,s.RENDERBUFFER,B.__webglColorRenderbuffer[ht])}s.bindRenderbuffer(s.RENDERBUFFER,null),I.depthBuffer&&(B.__webglDepthRenderbuffer=s.createRenderbuffer(),Lt(B.__webglDepthRenderbuffer,I,!0)),e.bindFramebuffer(s.FRAMEBUFFER,null)}}if(Y){e.bindTexture(s.TEXTURE_CUBE_MAP,W.__webglTexture),Wt(s.TEXTURE_CUBE_MAP,S);for(let ht=0;ht<6;ht++)if(S.mipmaps&&S.mipmaps.length>0)for(let At=0;At<S.mipmaps.length;At++)Mt(B.__webglFramebuffer[ht][At],I,S,s.COLOR_ATTACHMENT0,s.TEXTURE_CUBE_MAP_POSITIVE_X+ht,At);else Mt(B.__webglFramebuffer[ht],I,S,s.COLOR_ATTACHMENT0,s.TEXTURE_CUBE_MAP_POSITIVE_X+ht,0);m(S)&&p(s.TEXTURE_CUBE_MAP),e.unbindTexture()}else if(It){for(let ht=0,At=Q.length;ht<At;ht++){let Rt=Q[ht],rt=i.get(Rt),yt=s.TEXTURE_2D;(I.isWebGL3DRenderTarget||I.isWebGLArrayRenderTarget)&&(yt=I.isWebGL3DRenderTarget?s.TEXTURE_3D:s.TEXTURE_2D_ARRAY),e.bindTexture(yt,rt.__webglTexture),Wt(yt,Rt),Mt(B.__webglFramebuffer,I,Rt,s.COLOR_ATTACHMENT0+ht,yt,0),m(Rt)&&p(yt)}e.unbindTexture()}else{let ht=s.TEXTURE_2D;if((I.isWebGL3DRenderTarget||I.isWebGLArrayRenderTarget)&&(ht=I.isWebGL3DRenderTarget?s.TEXTURE_3D:s.TEXTURE_2D_ARRAY),e.bindTexture(ht,W.__webglTexture),Wt(ht,S),S.mipmaps&&S.mipmaps.length>0)for(let At=0;At<S.mipmaps.length;At++)Mt(B.__webglFramebuffer[At],I,S,s.COLOR_ATTACHMENT0,ht,At);else Mt(B.__webglFramebuffer,I,S,s.COLOR_ATTACHMENT0,ht,0);m(S)&&p(ht),e.unbindTexture()}I.depthBuffer&&Jt(I)}function tt(I){let S=I.textures;for(let B=0,W=S.length;B<W;B++){let Q=S[B];if(m(Q)){let Y=M(I),It=i.get(Q).__webglTexture;e.bindTexture(Y,It),p(Y),e.unbindTexture()}}}let K=[],J=[];function $(I){if(I.samples>0){if(st(I)===!1){let S=I.textures,B=I.width,W=I.height,Q=s.COLOR_BUFFER_BIT,Y=I.stencilBuffer?s.DEPTH_STENCIL_ATTACHMENT:s.DEPTH_ATTACHMENT,It=i.get(I),ht=S.length>1;if(ht)for(let Rt=0;Rt<S.length;Rt++)e.bindFramebuffer(s.FRAMEBUFFER,It.__webglMultisampledFramebuffer),s.framebufferRenderbuffer(s.FRAMEBUFFER,s.COLOR_ATTACHMENT0+Rt,s.RENDERBUFFER,null),e.bindFramebuffer(s.FRAMEBUFFER,It.__webglFramebuffer),s.framebufferTexture2D(s.DRAW_FRAMEBUFFER,s.COLOR_ATTACHMENT0+Rt,s.TEXTURE_2D,null,0);e.bindFramebuffer(s.READ_FRAMEBUFFER,It.__webglMultisampledFramebuffer);let At=I.texture.mipmaps;At&&At.length>0?e.bindFramebuffer(s.DRAW_FRAMEBUFFER,It.__webglFramebuffer[0]):e.bindFramebuffer(s.DRAW_FRAMEBUFFER,It.__webglFramebuffer);for(let Rt=0;Rt<S.length;Rt++){if(I.resolveDepthBuffer&&(I.depthBuffer&&(Q|=s.DEPTH_BUFFER_BIT),I.stencilBuffer&&I.resolveStencilBuffer&&(Q|=s.STENCIL_BUFFER_BIT)),ht){s.framebufferRenderbuffer(s.READ_FRAMEBUFFER,s.COLOR_ATTACHMENT0,s.RENDERBUFFER,It.__webglColorRenderbuffer[Rt]);let rt=i.get(S[Rt]).__webglTexture;s.framebufferTexture2D(s.DRAW_FRAMEBUFFER,s.COLOR_ATTACHMENT0,s.TEXTURE_2D,rt,0)}s.blitFramebuffer(0,0,B,W,0,0,B,W,Q,s.NEAREST),l===!0&&(K.length=0,J.length=0,K.push(s.COLOR_ATTACHMENT0+Rt),I.depthBuffer&&I.resolveDepthBuffer===!1&&(K.push(Y),J.push(Y),s.invalidateFramebuffer(s.DRAW_FRAMEBUFFER,J)),s.invalidateFramebuffer(s.READ_FRAMEBUFFER,K))}if(e.bindFramebuffer(s.READ_FRAMEBUFFER,null),e.bindFramebuffer(s.DRAW_FRAMEBUFFER,null),ht)for(let Rt=0;Rt<S.length;Rt++){e.bindFramebuffer(s.FRAMEBUFFER,It.__webglMultisampledFramebuffer),s.framebufferRenderbuffer(s.FRAMEBUFFER,s.COLOR_ATTACHMENT0+Rt,s.RENDERBUFFER,It.__webglColorRenderbuffer[Rt]);let rt=i.get(S[Rt]).__webglTexture;e.bindFramebuffer(s.FRAMEBUFFER,It.__webglFramebuffer),s.framebufferTexture2D(s.DRAW_FRAMEBUFFER,s.COLOR_ATTACHMENT0+Rt,s.TEXTURE_2D,rt,0)}e.bindFramebuffer(s.DRAW_FRAMEBUFFER,It.__webglMultisampledFramebuffer)}else if(I.depthBuffer&&I.resolveDepthBuffer===!1&&l){let S=I.stencilBuffer?s.DEPTH_STENCIL_ATTACHMENT:s.DEPTH_ATTACHMENT;s.invalidateFramebuffer(s.DRAW_FRAMEBUFFER,[S])}}}function ut(I){return Math.min(n.maxSamples,I.samples)}function st(I){let S=i.get(I);return I.samples>0&&t.has("WEBGL_multisampled_render_to_texture")===!0&&S.__useRenderToTexture!==!1}function dt(I){let S=o.render.frame;h.get(I)!==S&&(h.set(I,S),I.update())}function Vt(I,S){let B=I.colorSpace,W=I.format,Q=I.type;return I.isCompressedTexture===!0||I.isVideoTexture===!0||B!==Gn&&B!==Bi&&(te.getTransfer(B)===he?(W!==gi||Q!==ki)&&console.warn("THREE.WebGLTextures: sRGB encoded textures have to use RGBAFormat and UnsignedByteType."):console.error("THREE.WebGLTextures: Unsupported texture color space:",B)),S}function zt(I){return typeof HTMLImageElement<"u"&&I instanceof HTMLImageElement?(c.width=I.naturalWidth||I.width,c.height=I.naturalHeight||I.height):typeof VideoFrame<"u"&&I instanceof VideoFrame?(c.width=I.displayWidth,c.height=I.displayHeight):(c.width=I.width,c.height=I.height),c}this.allocateTextureUnit=O,this.resetTextureUnits=U,this.setTexture2D=q,this.setTexture2DArray=H,this.setTexture3D=it,this.setTextureCube=X,this.rebindTextures=ge,this.setupRenderTarget=D,this.updateRenderTargetMipmap=tt,this.updateMultisampleRenderTarget=$,this.setupDepthRenderbuffer=Jt,this.setupFrameBufferTexture=Mt,this.useMultisampledRTT=st}function Ey(s,t){function e(i,n=Bi){let r,o=te.getTransfer(n);if(i===ki)return s.UNSIGNED_BYTE;if(i===ja)return s.UNSIGNED_SHORT_4_4_4_4;if(i===Qa)return s.UNSIGNED_SHORT_5_5_5_1;if(i===ch)return s.UNSIGNED_INT_5_9_9_9_REV;if(i===hh)return s.UNSIGNED_INT_10F_11F_11F_REV;if(i===ah)return s.BYTE;if(i===lh)return s.SHORT;if(i===zs)return s.UNSIGNED_SHORT;if(i===Ka)return s.INT;if(i===Cn)return s.UNSIGNED_INT;if(i===Si)return s.FLOAT;if(i===Hs)return s.HALF_FLOAT;if(i===uh)return s.ALPHA;if(i===dh)return s.RGB;if(i===gi)return s.RGBA;if(i===As)return s.DEPTH_COMPONENT;if(i===Gs)return s.DEPTH_STENCIL;if(i===tl)return s.RED;if(i===el)return s.RED_INTEGER;if(i===fh)return s.RG;if(i===il)return s.RG_INTEGER;if(i===nl)return s.RGBA_INTEGER;if(i===oo||i===ao||i===lo||i===co)if(o===he)if(r=t.get("WEBGL_compressed_texture_s3tc_srgb"),r!==null){if(i===oo)return r.COMPRESSED_SRGB_S3TC_DXT1_EXT;if(i===ao)return r.COMPRESSED_SRGB_ALPHA_S3TC_DXT1_EXT;if(i===lo)return r.COMPRESSED_SRGB_ALPHA_S3TC_DXT3_EXT;if(i===co)return r.COMPRESSED_SRGB_ALPHA_S3TC_DXT5_EXT}else return null;else if(r=t.get("WEBGL_compressed_texture_s3tc"),r!==null){if(i===oo)return r.COMPRESSED_RGB_S3TC_DXT1_EXT;if(i===ao)return r.COMPRESSED_RGBA_S3TC_DXT1_EXT;if(i===lo)return r.COMPRESSED_RGBA_S3TC_DXT3_EXT;if(i===co)return r.COMPRESSED_RGBA_S3TC_DXT5_EXT}else return null;if(i===sl||i===rl||i===ol||i===al)if(r=t.get("WEBGL_compressed_texture_pvrtc"),r!==null){if(i===sl)return r.COMPRESSED_RGB_PVRTC_4BPPV1_IMG;if(i===rl)return r.COMPRESSED_RGB_PVRTC_2BPPV1_IMG;if(i===ol)return r.COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;if(i===al)return r.COMPRESSED_RGBA_PVRTC_2BPPV1_IMG}else return null;if(i===ll||i===cl||i===hl)if(r=t.get("WEBGL_compressed_texture_etc"),r!==null){if(i===ll||i===cl)return o===he?r.COMPRESSED_SRGB8_ETC2:r.COMPRESSED_RGB8_ETC2;if(i===hl)return o===he?r.COMPRESSED_SRGB8_ALPHA8_ETC2_EAC:r.COMPRESSED_RGBA8_ETC2_EAC}else return null;if(i===ul||i===dl||i===fl||i===pl||i===ml||i===gl||i===xl||i===_l||i===yl||i===vl||i===Ml||i===bl||i===wl||i===Sl)if(r=t.get("WEBGL_compressed_texture_astc"),r!==null){if(i===ul)return o===he?r.COMPRESSED_SRGB8_ALPHA8_ASTC_4x4_KHR:r.COMPRESSED_RGBA_ASTC_4x4_KHR;if(i===dl)return o===he?r.COMPRESSED_SRGB8_ALPHA8_ASTC_5x4_KHR:r.COMPRESSED_RGBA_ASTC_5x4_KHR;if(i===fl)return o===he?r.COMPRESSED_SRGB8_ALPHA8_ASTC_5x5_KHR:r.COMPRESSED_RGBA_ASTC_5x5_KHR;if(i===pl)return o===he?r.COMPRESSED_SRGB8_ALPHA8_ASTC_6x5_KHR:r.COMPRESSED_RGBA_ASTC_6x5_KHR;if(i===ml)return o===he?r.COMPRESSED_SRGB8_ALPHA8_ASTC_6x6_KHR:r.COMPRESSED_RGBA_ASTC_6x6_KHR;if(i===gl)return o===he?r.COMPRESSED_SRGB8_ALPHA8_ASTC_8x5_KHR:r.COMPRESSED_RGBA_ASTC_8x5_KHR;if(i===xl)return o===he?r.COMPRESSED_SRGB8_ALPHA8_ASTC_8x6_KHR:r.COMPRESSED_RGBA_ASTC_8x6_KHR;if(i===_l)return o===he?r.COMPRESSED_SRGB8_ALPHA8_ASTC_8x8_KHR:r.COMPRESSED_RGBA_ASTC_8x8_KHR;if(i===yl)return o===he?r.COMPRESSED_SRGB8_ALPHA8_ASTC_10x5_KHR:r.COMPRESSED_RGBA_ASTC_10x5_KHR;if(i===vl)return o===he?r.COMPRESSED_SRGB8_ALPHA8_ASTC_10x6_KHR:r.COMPRESSED_RGBA_ASTC_10x6_KHR;if(i===Ml)return o===he?r.COMPRESSED_SRGB8_ALPHA8_ASTC_10x8_KHR:r.COMPRESSED_RGBA_ASTC_10x8_KHR;if(i===bl)return o===he?r.COMPRESSED_SRGB8_ALPHA8_ASTC_10x10_KHR:r.COMPRESSED_RGBA_ASTC_10x10_KHR;if(i===wl)return o===he?r.COMPRESSED_SRGB8_ALPHA8_ASTC_12x10_KHR:r.COMPRESSED_RGBA_ASTC_12x10_KHR;if(i===Sl)return o===he?r.COMPRESSED_SRGB8_ALPHA8_ASTC_12x12_KHR:r.COMPRESSED_RGBA_ASTC_12x12_KHR}else return null;if(i===El||i===Tl||i===Al)if(r=t.get("EXT_texture_compression_bptc"),r!==null){if(i===El)return o===he?r.COMPRESSED_SRGB_ALPHA_BPTC_UNORM_EXT:r.COMPRESSED_RGBA_BPTC_UNORM_EXT;if(i===Tl)return r.COMPRESSED_RGB_BPTC_SIGNED_FLOAT_EXT;if(i===Al)return r.COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT_EXT}else return null;if(i===Rl||i===Cl||i===Il||i===Pl)if(r=t.get("EXT_texture_compression_rgtc"),r!==null){if(i===Rl)return r.COMPRESSED_RED_RGTC1_EXT;if(i===Cl)return r.COMPRESSED_SIGNED_RED_RGTC1_EXT;if(i===Il)return r.COMPRESSED_RED_GREEN_RGTC2_EXT;if(i===Pl)return r.COMPRESSED_SIGNED_RED_GREEN_RGTC2_EXT}else return null;return i===Vs?s.UNSIGNED_INT_24_8:s[i]!==void 0?s[i]:null}return{convert:e}}var Ty=`
void main() {

	gl_Position = vec4( position, 1.0 );

}`,Ay=`
uniform sampler2DArray depthColor;
uniform float depthWidth;
uniform float depthHeight;

void main() {

	vec2 coord = vec2( gl_FragCoord.x / depthWidth, gl_FragCoord.y / depthHeight );

	if ( coord.x >= 1.0 ) {

		gl_FragDepth = texture( depthColor, vec3( coord.x - 1.0, coord.y, 1 ) ).r;

	} else {

		gl_FragDepth = texture( depthColor, vec3( coord.x, coord.y, 0 ) ).r;

	}

}`,Fh=class{constructor(){this.texture=null,this.mesh=null,this.depthNear=0,this.depthFar=0}init(t,e){if(this.texture===null){let i=new Br(t.texture);(t.depthNear!==e.depthNear||t.depthFar!==e.depthFar)&&(this.depthNear=t.depthNear,this.depthFar=t.depthFar),this.texture=i}}getMesh(t){if(this.texture!==null&&this.mesh===null){let e=t.cameras[0].viewport,i=new Xe({vertexShader:Ty,fragmentShader:Ay,uniforms:{depthColor:{value:this.texture},depthWidth:{value:e.z},depthHeight:{value:e.w}}});this.mesh=new Et(new Ke(20,20),i)}return this.mesh}reset(){this.texture=null,this.mesh=null}getDepthTexture(){return this.texture}},kh=class extends rn{constructor(t,e){super();let i=this,n=null,r=1,o=null,a="local-floor",l=1,c=null,h=null,u=null,f=null,d=null,g=null,x=typeof XRWebGLBinding<"u",m=new Fh,p={},M=e.getContextAttributes(),y=null,_=null,b=[],E=[],P=new nt,L=null,w=new Le;w.viewport=new ie;let v=new Le;v.viewport=new ie;let C=[w,v],U=new ka,O=null,z=null;this.cameraAutoUpdate=!0,this.enabled=!1,this.isPresenting=!1,this.getController=function(Z){let et=b[Z];return et===void 0&&(et=new Ls,b[Z]=et),et.getTargetRaySpace()},this.getControllerGrip=function(Z){let et=b[Z];return et===void 0&&(et=new Ls,b[Z]=et),et.getGripSpace()},this.getHand=function(Z){let et=b[Z];return et===void 0&&(et=new Ls,b[Z]=et),et.getHandSpace()};function q(Z){let et=E.indexOf(Z.inputSource);if(et===-1)return;let Mt=b[et];Mt!==void 0&&(Mt.update(Z.inputSource,Z.frame,c||o),Mt.dispatchEvent({type:Z.type,data:Z.inputSource}))}function H(){n.removeEventListener("select",q),n.removeEventListener("selectstart",q),n.removeEventListener("selectend",q),n.removeEventListener("squeeze",q),n.removeEventListener("squeezestart",q),n.removeEventListener("squeezeend",q),n.removeEventListener("end",H),n.removeEventListener("inputsourceschange",it);for(let Z=0;Z<b.length;Z++){let et=E[Z];et!==null&&(E[Z]=null,b[Z].disconnect(et))}O=null,z=null,m.reset();for(let Z in p)delete p[Z];t.setRenderTarget(y),d=null,f=null,u=null,n=null,_=null,Qt.stop(),i.isPresenting=!1,t.setPixelRatio(L),t.setSize(P.width,P.height,!1),i.dispatchEvent({type:"sessionend"})}this.setFramebufferScaleFactor=function(Z){r=Z,i.isPresenting===!0&&console.warn("THREE.WebXRManager: Cannot change framebuffer scale while presenting.")},this.setReferenceSpaceType=function(Z){a=Z,i.isPresenting===!0&&console.warn("THREE.WebXRManager: Cannot change reference space type while presenting.")},this.getReferenceSpace=function(){return c||o},this.setReferenceSpace=function(Z){c=Z},this.getBaseLayer=function(){return f!==null?f:d},this.getBinding=function(){return u===null&&x&&(u=new XRWebGLBinding(n,e)),u},this.getFrame=function(){return g},this.getSession=function(){return n},this.setSession=async function(Z){if(n=Z,n!==null){if(y=t.getRenderTarget(),n.addEventListener("select",q),n.addEventListener("selectstart",q),n.addEventListener("selectend",q),n.addEventListener("squeeze",q),n.addEventListener("squeezestart",q),n.addEventListener("squeezeend",q),n.addEventListener("end",H),n.addEventListener("inputsourceschange",it),M.xrCompatible!==!0&&await e.makeXRCompatible(),L=t.getPixelRatio(),t.getSize(P),x&&"createProjectionLayer"in XRWebGLBinding.prototype){let Mt=null,Lt=null,Tt=null;M.depth&&(Tt=M.stencil?e.DEPTH24_STENCIL8:e.DEPTH_COMPONENT24,Mt=M.stencil?Gs:As,Lt=M.stencil?Vs:Cn);let Jt={colorFormat:e.RGBA8,depthFormat:Tt,scaleFactor:r};u=this.getBinding(),f=u.createProjectionLayer(Jt),n.updateRenderState({layers:[f]}),t.setPixelRatio(1),t.setSize(f.textureWidth,f.textureHeight,!1),_=new wi(f.textureWidth,f.textureHeight,{format:gi,type:ki,depthTexture:new kr(f.textureWidth,f.textureHeight,Lt,void 0,void 0,void 0,void 0,void 0,void 0,Mt),stencilBuffer:M.stencil,colorSpace:t.outputColorSpace,samples:M.antialias?4:0,resolveDepthBuffer:f.ignoreDepthValues===!1,resolveStencilBuffer:f.ignoreDepthValues===!1})}else{let Mt={antialias:M.antialias,alpha:!0,depth:M.depth,stencil:M.stencil,framebufferScaleFactor:r};d=new XRWebGLLayer(n,e,Mt),n.updateRenderState({baseLayer:d}),t.setPixelRatio(1),t.setSize(d.framebufferWidth,d.framebufferHeight,!1),_=new wi(d.framebufferWidth,d.framebufferHeight,{format:gi,type:ki,colorSpace:t.outputColorSpace,stencilBuffer:M.stencil,resolveDepthBuffer:d.ignoreDepthValues===!1,resolveStencilBuffer:d.ignoreDepthValues===!1})}_.isXRRenderTarget=!0,this.setFoveation(l),c=null,o=await n.requestReferenceSpace(a),Qt.setContext(n),Qt.start(),i.isPresenting=!0,i.dispatchEvent({type:"sessionstart"})}},this.getEnvironmentBlendMode=function(){if(n!==null)return n.environmentBlendMode},this.getDepthTexture=function(){return m.getDepthTexture()};function it(Z){for(let et=0;et<Z.removed.length;et++){let Mt=Z.removed[et],Lt=E.indexOf(Mt);Lt>=0&&(E[Lt]=null,b[Lt].disconnect(Mt))}for(let et=0;et<Z.added.length;et++){let Mt=Z.added[et],Lt=E.indexOf(Mt);if(Lt===-1){for(let Jt=0;Jt<b.length;Jt++)if(Jt>=E.length){E.push(Mt),Lt=Jt;break}else if(E[Jt]===null){E[Jt]=Mt,Lt=Jt;break}if(Lt===-1)break}let Tt=b[Lt];Tt&&Tt.connect(Mt)}}let X=new T,ct=new T;function mt(Z,et,Mt){X.setFromMatrixPosition(et.matrixWorld),ct.setFromMatrixPosition(Mt.matrixWorld);let Lt=X.distanceTo(ct),Tt=et.projectionMatrix.elements,Jt=Mt.projectionMatrix.elements,ge=Tt[14]/(Tt[10]-1),D=Tt[14]/(Tt[10]+1),tt=(Tt[9]+1)/Tt[5],K=(Tt[9]-1)/Tt[5],J=(Tt[8]-1)/Tt[0],$=(Jt[8]+1)/Jt[0],ut=ge*J,st=ge*$,dt=Lt/(-J+$),Vt=dt*-J;if(et.matrixWorld.decompose(Z.position,Z.quaternion,Z.scale),Z.translateX(Vt),Z.translateZ(dt),Z.matrixWorld.compose(Z.position,Z.quaternion,Z.scale),Z.matrixWorldInverse.copy(Z.matrixWorld).invert(),Tt[10]===-1)Z.projectionMatrix.copy(et.projectionMatrix),Z.projectionMatrixInverse.copy(et.projectionMatrixInverse);else{let zt=ge+dt,I=D+dt,S=ut-Vt,B=st+(Lt-Vt),W=tt*D/I*zt,Q=K*D/I*zt;Z.projectionMatrix.makePerspective(S,B,W,Q,zt,I),Z.projectionMatrixInverse.copy(Z.projectionMatrix).invert()}}function bt(Z,et){et===null?Z.matrixWorld.copy(Z.matrix):Z.matrixWorld.multiplyMatrices(et.matrixWorld,Z.matrix),Z.matrixWorldInverse.copy(Z.matrixWorld).invert()}this.updateCamera=function(Z){if(n===null)return;let et=Z.near,Mt=Z.far;m.texture!==null&&(m.depthNear>0&&(et=m.depthNear),m.depthFar>0&&(Mt=m.depthFar)),U.near=v.near=w.near=et,U.far=v.far=w.far=Mt,(O!==U.near||z!==U.far)&&(n.updateRenderState({depthNear:U.near,depthFar:U.far}),O=U.near,z=U.far),U.layers.mask=Z.layers.mask|6,w.layers.mask=U.layers.mask&3,v.layers.mask=U.layers.mask&5;let Lt=Z.parent,Tt=U.cameras;bt(U,Lt);for(let Jt=0;Jt<Tt.length;Jt++)bt(Tt[Jt],Lt);Tt.length===2?mt(U,w,v):U.projectionMatrix.copy(w.projectionMatrix),Wt(Z,U,Lt)};function Wt(Z,et,Mt){Mt===null?Z.matrix.copy(et.matrixWorld):(Z.matrix.copy(Mt.matrixWorld),Z.matrix.invert(),Z.matrix.multiply(et.matrixWorld)),Z.matrix.decompose(Z.position,Z.quaternion,Z.scale),Z.updateMatrixWorld(!0),Z.projectionMatrix.copy(et.projectionMatrix),Z.projectionMatrixInverse.copy(et.projectionMatrixInverse),Z.isPerspectiveCamera&&(Z.fov=Rs*2*Math.atan(1/Z.projectionMatrix.elements[5]),Z.zoom=1)}this.getCamera=function(){return U},this.getFoveation=function(){if(!(f===null&&d===null))return l},this.setFoveation=function(Z){l=Z,f!==null&&(f.fixedFoveation=Z),d!==null&&d.fixedFoveation!==void 0&&(d.fixedFoveation=Z)},this.hasDepthSensing=function(){return m.texture!==null},this.getDepthSensingMesh=function(){return m.getMesh(U)},this.getCameraTexture=function(Z){return p[Z]};let jt=null;function le(Z,et){if(h=et.getViewerPose(c||o),g=et,h!==null){let Mt=h.views;d!==null&&(t.setRenderTargetFramebuffer(_,d.framebuffer),t.setRenderTarget(_));let Lt=!1;Mt.length!==U.cameras.length&&(U.cameras.length=0,Lt=!0);for(let D=0;D<Mt.length;D++){let tt=Mt[D],K=null;if(d!==null)K=d.getViewport(tt);else{let $=u.getViewSubImage(f,tt);K=$.viewport,D===0&&(t.setRenderTargetTextures(_,$.colorTexture,$.depthStencilTexture),t.setRenderTarget(_))}let J=C[D];J===void 0&&(J=new Le,J.layers.enable(D),J.viewport=new ie,C[D]=J),J.matrix.fromArray(tt.transform.matrix),J.matrix.decompose(J.position,J.quaternion,J.scale),J.projectionMatrix.fromArray(tt.projectionMatrix),J.projectionMatrixInverse.copy(J.projectionMatrix).invert(),J.viewport.set(K.x,K.y,K.width,K.height),D===0&&(U.matrix.copy(J.matrix),U.matrix.decompose(U.position,U.quaternion,U.scale)),Lt===!0&&U.cameras.push(J)}let Tt=n.enabledFeatures;if(Tt&&Tt.includes("depth-sensing")&&n.depthUsage=="gpu-optimized"&&x){u=i.getBinding();let D=u.getDepthInformation(Mt[0]);D&&D.isValid&&D.texture&&m.init(D,n.renderState)}if(Tt&&Tt.includes("camera-access")&&x){t.state.unbindTexture(),u=i.getBinding();for(let D=0;D<Mt.length;D++){let tt=Mt[D].camera;if(tt){let K=p[tt];K||(K=new Br,p[tt]=K);let J=u.getCameraImage(tt);K.sourceTexture=J}}}}for(let Mt=0;Mt<b.length;Mt++){let Lt=E[Mt],Tt=b[Mt];Lt!==null&&Tt!==void 0&&Tt.update(Lt,et,c||o)}jt&&jt(Z,et),et.detectedPlanes&&i.dispatchEvent({type:"planesdetected",data:et}),g=null}let Qt=new If;Qt.setAnimationLoop(le),this.setAnimationLoop=function(Z){jt=Z},this.dispose=function(){}}},is=new Re,Ry=new Ut;function Cy(s,t){function e(m,p){m.matrixAutoUpdate===!0&&m.updateMatrix(),p.value.copy(m.matrix)}function i(m,p){p.color.getRGB(m.fogColor.value,yh(s)),p.isFog?(m.fogNear.value=p.near,m.fogFar.value=p.far):p.isFogExp2&&(m.fogDensity.value=p.density)}function n(m,p,M,y,_){p.isMeshBasicMaterial||p.isMeshLambertMaterial?r(m,p):p.isMeshToonMaterial?(r(m,p),u(m,p)):p.isMeshPhongMaterial?(r(m,p),h(m,p)):p.isMeshStandardMaterial?(r(m,p),f(m,p),p.isMeshPhysicalMaterial&&d(m,p,_)):p.isMeshMatcapMaterial?(r(m,p),g(m,p)):p.isMeshDepthMaterial?r(m,p):p.isMeshDistanceMaterial?(r(m,p),x(m,p)):p.isMeshNormalMaterial?r(m,p):p.isLineBasicMaterial?(o(m,p),p.isLineDashedMaterial&&a(m,p)):p.isPointsMaterial?l(m,p,M,y):p.isSpriteMaterial?c(m,p):p.isShadowMaterial?(m.color.value.copy(p.color),m.opacity.value=p.opacity):p.isShaderMaterial&&(p.uniformsNeedUpdate=!1)}function r(m,p){m.opacity.value=p.opacity,p.color&&m.diffuse.value.copy(p.color),p.emissive&&m.emissive.value.copy(p.emissive).multiplyScalar(p.emissiveIntensity),p.map&&(m.map.value=p.map,e(p.map,m.mapTransform)),p.alphaMap&&(m.alphaMap.value=p.alphaMap,e(p.alphaMap,m.alphaMapTransform)),p.bumpMap&&(m.bumpMap.value=p.bumpMap,e(p.bumpMap,m.bumpMapTransform),m.bumpScale.value=p.bumpScale,p.side===qe&&(m.bumpScale.value*=-1)),p.normalMap&&(m.normalMap.value=p.normalMap,e(p.normalMap,m.normalMapTransform),m.normalScale.value.copy(p.normalScale),p.side===qe&&m.normalScale.value.negate()),p.displacementMap&&(m.displacementMap.value=p.displacementMap,e(p.displacementMap,m.displacementMapTransform),m.displacementScale.value=p.displacementScale,m.displacementBias.value=p.displacementBias),p.emissiveMap&&(m.emissiveMap.value=p.emissiveMap,e(p.emissiveMap,m.emissiveMapTransform)),p.specularMap&&(m.specularMap.value=p.specularMap,e(p.specularMap,m.specularMapTransform)),p.alphaTest>0&&(m.alphaTest.value=p.alphaTest);let M=t.get(p),y=M.envMap,_=M.envMapRotation;y&&(m.envMap.value=y,is.copy(_),is.x*=-1,is.y*=-1,is.z*=-1,y.isCubeTexture&&y.isRenderTargetTexture===!1&&(is.y*=-1,is.z*=-1),m.envMapRotation.value.setFromMatrix4(Ry.makeRotationFromEuler(is)),m.flipEnvMap.value=y.isCubeTexture&&y.isRenderTargetTexture===!1?-1:1,m.reflectivity.value=p.reflectivity,m.ior.value=p.ior,m.refractionRatio.value=p.refractionRatio),p.lightMap&&(m.lightMap.value=p.lightMap,m.lightMapIntensity.value=p.lightMapIntensity,e(p.lightMap,m.lightMapTransform)),p.aoMap&&(m.aoMap.value=p.aoMap,m.aoMapIntensity.value=p.aoMapIntensity,e(p.aoMap,m.aoMapTransform))}function o(m,p){m.diffuse.value.copy(p.color),m.opacity.value=p.opacity,p.map&&(m.map.value=p.map,e(p.map,m.mapTransform))}function a(m,p){m.dashSize.value=p.dashSize,m.totalSize.value=p.dashSize+p.gapSize,m.scale.value=p.scale}function l(m,p,M,y){m.diffuse.value.copy(p.color),m.opacity.value=p.opacity,m.size.value=p.size*M,m.scale.value=y*.5,p.map&&(m.map.value=p.map,e(p.map,m.uvTransform)),p.alphaMap&&(m.alphaMap.value=p.alphaMap,e(p.alphaMap,m.alphaMapTransform)),p.alphaTest>0&&(m.alphaTest.value=p.alphaTest)}function c(m,p){m.diffuse.value.copy(p.color),m.opacity.value=p.opacity,m.rotation.value=p.rotation,p.map&&(m.map.value=p.map,e(p.map,m.mapTransform)),p.alphaMap&&(m.alphaMap.value=p.alphaMap,e(p.alphaMap,m.alphaMapTransform)),p.alphaTest>0&&(m.alphaTest.value=p.alphaTest)}function h(m,p){m.specular.value.copy(p.specular),m.shininess.value=Math.max(p.shininess,1e-4)}function u(m,p){p.gradientMap&&(m.gradientMap.value=p.gradientMap)}function f(m,p){m.metalness.value=p.metalness,p.metalnessMap&&(m.metalnessMap.value=p.metalnessMap,e(p.metalnessMap,m.metalnessMapTransform)),m.roughness.value=p.roughness,p.roughnessMap&&(m.roughnessMap.value=p.roughnessMap,e(p.roughnessMap,m.roughnessMapTransform)),p.envMap&&(m.envMapIntensity.value=p.envMapIntensity)}function d(m,p,M){m.ior.value=p.ior,p.sheen>0&&(m.sheenColor.value.copy(p.sheenColor).multiplyScalar(p.sheen),m.sheenRoughness.value=p.sheenRoughness,p.sheenColorMap&&(m.sheenColorMap.value=p.sheenColorMap,e(p.sheenColorMap,m.sheenColorMapTransform)),p.sheenRoughnessMap&&(m.sheenRoughnessMap.value=p.sheenRoughnessMap,e(p.sheenRoughnessMap,m.sheenRoughnessMapTransform))),p.clearcoat>0&&(m.clearcoat.value=p.clearcoat,m.clearcoatRoughness.value=p.clearcoatRoughness,p.clearcoatMap&&(m.clearcoatMap.value=p.clearcoatMap,e(p.clearcoatMap,m.clearcoatMapTransform)),p.clearcoatRoughnessMap&&(m.clearcoatRoughnessMap.value=p.clearcoatRoughnessMap,e(p.clearcoatRoughnessMap,m.clearcoatRoughnessMapTransform)),p.clearcoatNormalMap&&(m.clearcoatNormalMap.value=p.clearcoatNormalMap,e(p.clearcoatNormalMap,m.clearcoatNormalMapTransform),m.clearcoatNormalScale.value.copy(p.clearcoatNormalScale),p.side===qe&&m.clearcoatNormalScale.value.negate())),p.dispersion>0&&(m.dispersion.value=p.dispersion),p.iridescence>0&&(m.iridescence.value=p.iridescence,m.iridescenceIOR.value=p.iridescenceIOR,m.iridescenceThicknessMinimum.value=p.iridescenceThicknessRange[0],m.iridescenceThicknessMaximum.value=p.iridescenceThicknessRange[1],p.iridescenceMap&&(m.iridescenceMap.value=p.iridescenceMap,e(p.iridescenceMap,m.iridescenceMapTransform)),p.iridescenceThicknessMap&&(m.iridescenceThicknessMap.value=p.iridescenceThicknessMap,e(p.iridescenceThicknessMap,m.iridescenceThicknessMapTransform))),p.transmission>0&&(m.transmission.value=p.transmission,m.transmissionSamplerMap.value=M.texture,m.transmissionSamplerSize.value.set(M.width,M.height),p.transmissionMap&&(m.transmissionMap.value=p.transmissionMap,e(p.transmissionMap,m.transmissionMapTransform)),m.thickness.value=p.thickness,p.thicknessMap&&(m.thicknessMap.value=p.thicknessMap,e(p.thicknessMap,m.thicknessMapTransform)),m.attenuationDistance.value=p.attenuationDistance,m.attenuationColor.value.copy(p.attenuationColor)),p.anisotropy>0&&(m.anisotropyVector.value.set(p.anisotropy*Math.cos(p.anisotropyRotation),p.anisotropy*Math.sin(p.anisotropyRotation)),p.anisotropyMap&&(m.anisotropyMap.value=p.anisotropyMap,e(p.anisotropyMap,m.anisotropyMapTransform))),m.specularIntensity.value=p.specularIntensity,m.specularColor.value.copy(p.specularColor),p.specularColorMap&&(m.specularColorMap.value=p.specularColorMap,e(p.specularColorMap,m.specularColorMapTransform)),p.specularIntensityMap&&(m.specularIntensityMap.value=p.specularIntensityMap,e(p.specularIntensityMap,m.specularIntensityMapTransform))}function g(m,p){p.matcap&&(m.matcap.value=p.matcap)}function x(m,p){let M=t.get(p).light;m.referencePosition.value.setFromMatrixPosition(M.matrixWorld),m.nearDistance.value=M.shadow.camera.near,m.farDistance.value=M.shadow.camera.far}return{refreshFogUniforms:i,refreshMaterialUniforms:n}}function Iy(s,t,e,i){let n={},r={},o=[],a=s.getParameter(s.MAX_UNIFORM_BUFFER_BINDINGS);function l(M,y){let _=y.program;i.uniformBlockBinding(M,_)}function c(M,y){let _=n[M.id];_===void 0&&(g(M),_=h(M),n[M.id]=_,M.addEventListener("dispose",m));let b=y.program;i.updateUBOMapping(M,b);let E=t.render.frame;r[M.id]!==E&&(f(M),r[M.id]=E)}function h(M){let y=u();M.__bindingPointIndex=y;let _=s.createBuffer(),b=M.__size,E=M.usage;return s.bindBuffer(s.UNIFORM_BUFFER,_),s.bufferData(s.UNIFORM_BUFFER,b,E),s.bindBuffer(s.UNIFORM_BUFFER,null),s.bindBufferBase(s.UNIFORM_BUFFER,y,_),_}function u(){for(let M=0;M<a;M++)if(o.indexOf(M)===-1)return o.push(M),M;return console.error("THREE.WebGLRenderer: Maximum number of simultaneously usable uniforms groups reached."),0}function f(M){let y=n[M.id],_=M.uniforms,b=M.__cache;s.bindBuffer(s.UNIFORM_BUFFER,y);for(let E=0,P=_.length;E<P;E++){let L=Array.isArray(_[E])?_[E]:[_[E]];for(let w=0,v=L.length;w<v;w++){let C=L[w];if(d(C,E,w,b)===!0){let U=C.__offset,O=Array.isArray(C.value)?C.value:[C.value],z=0;for(let q=0;q<O.length;q++){let H=O[q],it=x(H);typeof H=="number"||typeof H=="boolean"?(C.__data[0]=H,s.bufferSubData(s.UNIFORM_BUFFER,U+z,C.__data)):H.isMatrix3?(C.__data[0]=H.elements[0],C.__data[1]=H.elements[1],C.__data[2]=H.elements[2],C.__data[3]=0,C.__data[4]=H.elements[3],C.__data[5]=H.elements[4],C.__data[6]=H.elements[5],C.__data[7]=0,C.__data[8]=H.elements[6],C.__data[9]=H.elements[7],C.__data[10]=H.elements[8],C.__data[11]=0):(H.toArray(C.__data,z),z+=it.storage/Float32Array.BYTES_PER_ELEMENT)}s.bufferSubData(s.UNIFORM_BUFFER,U,C.__data)}}}s.bindBuffer(s.UNIFORM_BUFFER,null)}function d(M,y,_,b){let E=M.value,P=y+"_"+_;if(b[P]===void 0)return typeof E=="number"||typeof E=="boolean"?b[P]=E:b[P]=E.clone(),!0;{let L=b[P];if(typeof E=="number"||typeof E=="boolean"){if(L!==E)return b[P]=E,!0}else if(L.equals(E)===!1)return L.copy(E),!0}return!1}function g(M){let y=M.uniforms,_=0,b=16;for(let P=0,L=y.length;P<L;P++){let w=Array.isArray(y[P])?y[P]:[y[P]];for(let v=0,C=w.length;v<C;v++){let U=w[v],O=Array.isArray(U.value)?U.value:[U.value];for(let z=0,q=O.length;z<q;z++){let H=O[z],it=x(H),X=_%b,ct=X%it.boundary,mt=X+ct;_+=ct,mt!==0&&b-mt<it.storage&&(_+=b-mt),U.__data=new Float32Array(it.storage/Float32Array.BYTES_PER_ELEMENT),U.__offset=_,_+=it.storage}}}let E=_%b;return E>0&&(_+=b-E),M.__size=_,M.__cache={},this}function x(M){let y={boundary:0,storage:0};return typeof M=="number"||typeof M=="boolean"?(y.boundary=4,y.storage=4):M.isVector2?(y.boundary=8,y.storage=8):M.isVector3||M.isColor?(y.boundary=16,y.storage=12):M.isVector4?(y.boundary=16,y.storage=16):M.isMatrix3?(y.boundary=48,y.storage=48):M.isMatrix4?(y.boundary=64,y.storage=64):M.isTexture?console.warn("THREE.WebGLRenderer: Texture samplers can not be part of an uniforms group."):console.warn("THREE.WebGLRenderer: Unsupported uniform value type.",M),y}function m(M){let y=M.target;y.removeEventListener("dispose",m);let _=o.indexOf(y.__bindingPointIndex);o.splice(_,1),s.deleteBuffer(n[y.id]),delete n[y.id],delete r[y.id]}function p(){for(let M in n)s.deleteBuffer(n[M]);o=[],n={},r={}}return{bind:l,update:c,dispose:p}}var Bl=class{constructor(t={}){let{canvas:e=Kd(),context:i=null,depth:n=!0,stencil:r=!1,alpha:o=!1,antialias:a=!1,premultipliedAlpha:l=!0,preserveDrawingBuffer:c=!1,powerPreference:h="default",failIfMajorPerformanceCaveat:u=!1,reversedDepthBuffer:f=!1}=t;this.isWebGLRenderer=!0;let d;if(i!==null){if(typeof WebGLRenderingContext<"u"&&i instanceof WebGLRenderingContext)throw new Error("THREE.WebGLRenderer: WebGL 1 is not supported since r163.");d=i.getContextAttributes().alpha}else d=o;let g=new Uint32Array(4),x=new Int32Array(4),m=null,p=null,M=[],y=[];this.domElement=e,this.debug={checkShaderErrors:!0,onShaderError:null},this.autoClear=!0,this.autoClearColor=!0,this.autoClearDepth=!0,this.autoClearStencil=!0,this.sortObjects=!0,this.clippingPlanes=[],this.localClippingEnabled=!1,this.toneMapping=cn,this.toneMappingExposure=1,this.transmissionResolutionScale=1;let _=this,b=!1;this._outputColorSpace=Ne;let E=0,P=0,L=null,w=-1,v=null,C=new ie,U=new ie,O=null,z=new _t(0),q=0,H=e.width,it=e.height,X=1,ct=null,mt=null,bt=new ie(0,0,H,it),Wt=new ie(0,0,H,it),jt=!1,le=new Sn,Qt=!1,Z=!1,et=new Ut,Mt=new T,Lt=new ie,Tt={background:null,fog:null,environment:null,overrideMaterial:null,isScene:!0},Jt=!1;function ge(){return L===null?X:1}let D=i;function tt(A,F){return e.getContext(A,F)}try{let A={alpha:!0,depth:n,stencil:r,antialias:a,premultipliedAlpha:l,preserveDrawingBuffer:c,powerPreference:h,failIfMajorPerformanceCaveat:u};if("setAttribute"in e&&e.setAttribute("data-engine",`three.js r${"180"}`),e.addEventListener("webglcontextlost",ft,!1),e.addEventListener("webglcontextrestored",wt,!1),e.addEventListener("webglcontextcreationerror",ot,!1),D===null){let F="webgl2";if(D=tt(F,A),D===null)throw tt(F)?new Error("Error creating WebGL context with your selected attributes."):new Error("Error creating WebGL context.")}}catch(A){throw console.error("THREE.WebGLRenderer: "+A.message),A}let K,J,$,ut,st,dt,Vt,zt,I,S,B,W,Q,Y,It,ht,At,Rt,rt,yt,Bt,Pt,gt,qt;function N(){K=new Zx(D),K.init(),Pt=new Ey(D,K),J=new Hx(D,K,t,Pt),$=new wy(D,K),J.reversedDepthBuffer&&f&&$.buffers.depth.setReversed(!0),ut=new Kx(D),st=new hy,dt=new Sy(D,K,$,st,J,Pt,ut),Vt=new Gx(_),zt=new Yx(_),I=new nm(D),gt=new Ox(D,I),S=new $x(D,I,ut,gt),B=new Qx(D,S,I,ut),rt=new jx(D,J,dt),ht=new Vx(st),W=new cy(_,Vt,zt,K,J,gt,ht),Q=new Cy(_,st),Y=new dy,It=new _y(K),Rt=new Bx(_,Vt,zt,$,B,d,l),At=new My(_,B,J),qt=new Iy(D,ut,J,$),yt=new zx(D,K,ut),Bt=new Jx(D,K,ut),ut.programs=W.programs,_.capabilities=J,_.extensions=K,_.properties=st,_.renderLists=Y,_.shadowMap=At,_.state=$,_.info=ut}N();let lt=new kh(_,D);this.xr=lt,this.getContext=function(){return D},this.getContextAttributes=function(){return D.getContextAttributes()},this.forceContextLoss=function(){let A=K.get("WEBGL_lose_context");A&&A.loseContext()},this.forceContextRestore=function(){let A=K.get("WEBGL_lose_context");A&&A.restoreContext()},this.getPixelRatio=function(){return X},this.setPixelRatio=function(A){A!==void 0&&(X=A,this.setSize(H,it,!1))},this.getSize=function(A){return A.set(H,it)},this.setSize=function(A,F,V=!0){if(lt.isPresenting){console.warn("THREE.WebGLRenderer: Can't change size while VR device is presenting.");return}H=A,it=F,e.width=Math.floor(A*X),e.height=Math.floor(F*X),V===!0&&(e.style.width=A+"px",e.style.height=F+"px"),this.setViewport(0,0,A,F)},this.getDrawingBufferSize=function(A){return A.set(H*X,it*X).floor()},this.setDrawingBufferSize=function(A,F,V){H=A,it=F,X=V,e.width=Math.floor(A*V),e.height=Math.floor(F*V),this.setViewport(0,0,A,F)},this.getCurrentViewport=function(A){return A.copy(C)},this.getViewport=function(A){return A.copy(bt)},this.setViewport=function(A,F,V,G){A.isVector4?bt.set(A.x,A.y,A.z,A.w):bt.set(A,F,V,G),$.viewport(C.copy(bt).multiplyScalar(X).round())},this.getScissor=function(A){return A.copy(Wt)},this.setScissor=function(A,F,V,G){A.isVector4?Wt.set(A.x,A.y,A.z,A.w):Wt.set(A,F,V,G),$.scissor(U.copy(Wt).multiplyScalar(X).round())},this.getScissorTest=function(){return jt},this.setScissorTest=function(A){$.setScissorTest(jt=A)},this.setOpaqueSort=function(A){ct=A},this.setTransparentSort=function(A){mt=A},this.getClearColor=function(A){return A.copy(Rt.getClearColor())},this.setClearColor=function(){Rt.setClearColor(...arguments)},this.getClearAlpha=function(){return Rt.getClearAlpha()},this.setClearAlpha=function(){Rt.setClearAlpha(...arguments)},this.clear=function(A=!0,F=!0,V=!0){let G=0;if(A){let k=!1;if(L!==null){let at=L.texture.format;k=at===nl||at===il||at===el}if(k){let at=L.texture.type,xt=at===ki||at===Cn||at===zs||at===Vs||at===ja||at===Qa,St=Rt.getClearColor(),vt=Rt.getClearAlpha(),kt=St.r,Ot=St.g,Dt=St.b;xt?(g[0]=kt,g[1]=Ot,g[2]=Dt,g[3]=vt,D.clearBufferuiv(D.COLOR,0,g)):(x[0]=kt,x[1]=Ot,x[2]=Dt,x[3]=vt,D.clearBufferiv(D.COLOR,0,x))}else G|=D.COLOR_BUFFER_BIT}F&&(G|=D.DEPTH_BUFFER_BIT),V&&(G|=D.STENCIL_BUFFER_BIT,this.state.buffers.stencil.setMask(4294967295)),D.clear(G)},this.clearColor=function(){this.clear(!0,!1,!1)},this.clearDepth=function(){this.clear(!1,!0,!1)},this.clearStencil=function(){this.clear(!1,!1,!0)},this.dispose=function(){e.removeEventListener("webglcontextlost",ft,!1),e.removeEventListener("webglcontextrestored",wt,!1),e.removeEventListener("webglcontextcreationerror",ot,!1),Rt.dispose(),Y.dispose(),It.dispose(),st.dispose(),Vt.dispose(),zt.dispose(),B.dispose(),gt.dispose(),qt.dispose(),W.dispose(),lt.dispose(),lt.removeEventListener("sessionstart",zi),lt.removeEventListener("sessionend",bu),Nn.stop()};function ft(A){A.preventDefault(),console.log("THREE.WebGLRenderer: Context Lost."),b=!0}function wt(){console.log("THREE.WebGLRenderer: Context Restored."),b=!1;let A=ut.autoReset,F=At.enabled,V=At.autoUpdate,G=At.needsUpdate,k=At.type;N(),ut.autoReset=A,At.enabled=F,At.autoUpdate=V,At.needsUpdate=G,At.type=k}function ot(A){console.error("THREE.WebGLRenderer: A WebGL context could not be created. Reason: ",A.statusMessage)}function j(A){let F=A.target;F.removeEventListener("dispose",j),Ct(F)}function Ct(A){Gt(A),st.remove(A)}function Gt(A){let F=st.get(A).programs;F!==void 0&&(F.forEach(function(V){W.releaseProgram(V)}),A.isShaderMaterial&&W.releaseShaderCache(A))}this.renderBufferDirect=function(A,F,V,G,k,at){F===null&&(F=Tt);let xt=k.isMesh&&k.matrixWorld.determinant()<0,St=Sp(A,F,V,G,k);$.setMaterial(G,xt);let vt=V.index,kt=1;if(G.wireframe===!0){if(vt=S.getWireframeAttribute(V),vt===void 0)return;kt=2}let Ot=V.drawRange,Dt=V.attributes.position,Kt=Ot.start*kt,de=(Ot.start+Ot.count)*kt;at!==null&&(Kt=Math.max(Kt,at.start*kt),de=Math.min(de,(at.start+at.count)*kt)),vt!==null?(Kt=Math.max(Kt,0),de=Math.min(de,vt.count)):Dt!=null&&(Kt=Math.max(Kt,0),de=Math.min(de,Dt.count));let Ae=de-Kt;if(Ae<0||Ae===1/0)return;gt.setup(k,G,St,V,vt);let ve,pe=yt;if(vt!==null&&(ve=I.get(vt),pe=Bt,pe.setIndex(ve)),k.isMesh)G.wireframe===!0?($.setLineWidth(G.wireframeLinewidth*ge()),pe.setMode(D.LINES)):pe.setMode(D.TRIANGLES);else if(k.isLine){let Nt=G.linewidth;Nt===void 0&&(Nt=1),$.setLineWidth(Nt*ge()),k.isLineSegments?pe.setMode(D.LINES):k.isLineLoop?pe.setMode(D.LINE_LOOP):pe.setMode(D.LINE_STRIP)}else k.isPoints?pe.setMode(D.POINTS):k.isSprite&&pe.setMode(D.TRIANGLES);if(k.isBatchedMesh)if(k._multiDrawInstances!==null)Cs("THREE.WebGLRenderer: renderMultiDrawInstances has been deprecated and will be removed in r184. Append to renderMultiDraw arguments and use indirection."),pe.renderMultiDrawInstances(k._multiDrawStarts,k._multiDrawCounts,k._multiDrawCount,k._multiDrawInstances);else if(K.get("WEBGL_multi_draw"))pe.renderMultiDraw(k._multiDrawStarts,k._multiDrawCounts,k._multiDrawCount);else{let Nt=k._multiDrawStarts,be=k._multiDrawCounts,ee=k._multiDrawCount,hi=vt?I.get(vt).bytesPerElement:1,as=st.get(G).currentProgram.getUniforms();for(let ui=0;ui<ee;ui++)as.setValue(D,"_gl_DrawID",ui),pe.render(Nt[ui]/hi,be[ui])}else if(k.isInstancedMesh)pe.renderInstances(Kt,Ae,k.count);else if(V.isInstancedBufferGeometry){let Nt=V._maxInstanceCount!==void 0?V._maxInstanceCount:1/0,be=Math.min(V.instanceCount,Nt);pe.renderInstances(Kt,Ae,be)}else pe.render(Kt,Ae)};function xe(A,F,V){A.transparent===!0&&A.side===Fe&&A.forceSinglePass===!1?(A.side=qe,A.needsUpdate=!0,Lo(A,F,V),A.side=bi,A.needsUpdate=!0,Lo(A,F,V),A.side=Fe):Lo(A,F,V)}this.compile=function(A,F,V=null){V===null&&(V=A),p=It.get(V),p.init(F),y.push(p),V.traverseVisible(function(k){k.isLight&&k.layers.test(F.layers)&&(p.pushLight(k),k.castShadow&&p.pushShadow(k))}),A!==V&&A.traverseVisible(function(k){k.isLight&&k.layers.test(F.layers)&&(p.pushLight(k),k.castShadow&&p.pushShadow(k))}),p.setupLights();let G=new Set;return A.traverse(function(k){if(!(k.isMesh||k.isPoints||k.isLine||k.isSprite))return;let at=k.material;if(at)if(Array.isArray(at))for(let xt=0;xt<at.length;xt++){let St=at[xt];xe(St,V,k),G.add(St)}else xe(at,V,k),G.add(at)}),p=y.pop(),G},this.compileAsync=function(A,F,V=null){let G=this.compile(A,F,V);return new Promise(k=>{function at(){if(G.forEach(function(xt){st.get(xt).currentProgram.isReady()&&G.delete(xt)}),G.size===0){k(A);return}setTimeout(at,10)}K.get("KHR_parallel_shader_compile")!==null?at():setTimeout(at,10)})};let oe=null;function Ji(A){oe&&oe(A)}function zi(){Nn.stop()}function bu(){Nn.start()}let Nn=new If;Nn.setAnimationLoop(Ji),typeof self<"u"&&Nn.setContext(self),this.setAnimationLoop=function(A){oe=A,lt.setAnimationLoop(A),A===null?Nn.stop():Nn.start()},lt.addEventListener("sessionstart",zi),lt.addEventListener("sessionend",bu),this.render=function(A,F){if(F!==void 0&&F.isCamera!==!0){console.error("THREE.WebGLRenderer.render: camera is not an instance of THREE.Camera.");return}if(b===!0)return;if(A.matrixWorldAutoUpdate===!0&&A.updateMatrixWorld(),F.parent===null&&F.matrixWorldAutoUpdate===!0&&F.updateMatrixWorld(),lt.enabled===!0&&lt.isPresenting===!0&&(lt.cameraAutoUpdate===!0&&lt.updateCamera(F),F=lt.getCamera()),A.isScene===!0&&A.onBeforeRender(_,A,F,L),p=It.get(A,y.length),p.init(F),y.push(p),et.multiplyMatrices(F.projectionMatrix,F.matrixWorldInverse),le.setFromProjectionMatrix(et,Li,F.reversedDepth),Z=this.localClippingEnabled,Qt=ht.init(this.clippingPlanes,Z),m=Y.get(A,M.length),m.init(),M.push(m),lt.enabled===!0&&lt.isPresenting===!0){let at=_.xr.getDepthSensingMesh();at!==null&&fc(at,F,-1/0,_.sortObjects)}fc(A,F,0,_.sortObjects),m.finish(),_.sortObjects===!0&&m.sort(ct,mt),Jt=lt.enabled===!1||lt.isPresenting===!1||lt.hasDepthSensing()===!1,Jt&&Rt.addToRenderList(m,A),this.info.render.frame++,Qt===!0&&ht.beginShadows();let V=p.state.shadowsArray;At.render(V,A,F),Qt===!0&&ht.endShadows(),this.info.autoReset===!0&&this.info.reset();let G=m.opaque,k=m.transmissive;if(p.setupLights(),F.isArrayCamera){let at=F.cameras;if(k.length>0)for(let xt=0,St=at.length;xt<St;xt++){let vt=at[xt];Su(G,k,A,vt)}Jt&&Rt.render(A);for(let xt=0,St=at.length;xt<St;xt++){let vt=at[xt];wu(m,A,vt,vt.viewport)}}else k.length>0&&Su(G,k,A,F),Jt&&Rt.render(A),wu(m,A,F);L!==null&&P===0&&(dt.updateMultisampleRenderTarget(L),dt.updateRenderTargetMipmap(L)),A.isScene===!0&&A.onAfterRender(_,A,F),gt.resetDefaultState(),w=-1,v=null,y.pop(),y.length>0?(p=y[y.length-1],Qt===!0&&ht.setGlobalState(_.clippingPlanes,p.state.camera)):p=null,M.pop(),M.length>0?m=M[M.length-1]:m=null};function fc(A,F,V,G){if(A.visible===!1)return;if(A.layers.test(F.layers)){if(A.isGroup)V=A.renderOrder;else if(A.isLOD)A.autoUpdate===!0&&A.update(F);else if(A.isLight)p.pushLight(A),A.castShadow&&p.pushShadow(A);else if(A.isSprite){if(!A.frustumCulled||le.intersectsSprite(A)){G&&Lt.setFromMatrixPosition(A.matrixWorld).applyMatrix4(et);let xt=B.update(A),St=A.material;St.visible&&m.push(A,xt,St,V,Lt.z,null)}}else if((A.isMesh||A.isLine||A.isPoints)&&(!A.frustumCulled||le.intersectsObject(A))){let xt=B.update(A),St=A.material;if(G&&(A.boundingSphere!==void 0?(A.boundingSphere===null&&A.computeBoundingSphere(),Lt.copy(A.boundingSphere.center)):(xt.boundingSphere===null&&xt.computeBoundingSphere(),Lt.copy(xt.boundingSphere.center)),Lt.applyMatrix4(A.matrixWorld).applyMatrix4(et)),Array.isArray(St)){let vt=xt.groups;for(let kt=0,Ot=vt.length;kt<Ot;kt++){let Dt=vt[kt],Kt=St[Dt.materialIndex];Kt&&Kt.visible&&m.push(A,xt,Kt,V,Lt.z,Dt)}}else St.visible&&m.push(A,xt,St,V,Lt.z,null)}}let at=A.children;for(let xt=0,St=at.length;xt<St;xt++)fc(at[xt],F,V,G)}function wu(A,F,V,G){let k=A.opaque,at=A.transmissive,xt=A.transparent;p.setupLightsView(V),Qt===!0&&ht.setGlobalState(_.clippingPlanes,V),G&&$.viewport(C.copy(G)),k.length>0&&Po(k,F,V),at.length>0&&Po(at,F,V),xt.length>0&&Po(xt,F,V),$.buffers.depth.setTest(!0),$.buffers.depth.setMask(!0),$.buffers.color.setMask(!0),$.setPolygonOffset(!1)}function Su(A,F,V,G){if((V.isScene===!0?V.overrideMaterial:null)!==null)return;p.state.transmissionRenderTarget[G.id]===void 0&&(p.state.transmissionRenderTarget[G.id]=new wi(1,1,{generateMipmaps:!0,type:K.has("EXT_color_buffer_half_float")||K.has("EXT_color_buffer_float")?Hs:ki,minFilter:Rn,samples:4,stencilBuffer:r,resolveDepthBuffer:!1,resolveStencilBuffer:!1,colorSpace:te.workingColorSpace}));let at=p.state.transmissionRenderTarget[G.id],xt=G.viewport||C;at.setSize(xt.z*_.transmissionResolutionScale,xt.w*_.transmissionResolutionScale);let St=_.getRenderTarget(),vt=_.getActiveCubeFace(),kt=_.getActiveMipmapLevel();_.setRenderTarget(at),_.getClearColor(z),q=_.getClearAlpha(),q<1&&_.setClearColor(16777215,.5),_.clear(),Jt&&Rt.render(V);let Ot=_.toneMapping;_.toneMapping=cn;let Dt=G.viewport;if(G.viewport!==void 0&&(G.viewport=void 0),p.setupLightsView(G),Qt===!0&&ht.setGlobalState(_.clippingPlanes,G),Po(A,V,G),dt.updateMultisampleRenderTarget(at),dt.updateRenderTargetMipmap(at),K.has("WEBGL_multisampled_render_to_texture")===!1){let Kt=!1;for(let de=0,Ae=F.length;de<Ae;de++){let ve=F[de],pe=ve.object,Nt=ve.geometry,be=ve.material,ee=ve.group;if(be.side===Fe&&pe.layers.test(G.layers)){let hi=be.side;be.side=qe,be.needsUpdate=!0,Eu(pe,V,G,Nt,be,ee),be.side=hi,be.needsUpdate=!0,Kt=!0}}Kt===!0&&(dt.updateMultisampleRenderTarget(at),dt.updateRenderTargetMipmap(at))}_.setRenderTarget(St,vt,kt),_.setClearColor(z,q),Dt!==void 0&&(G.viewport=Dt),_.toneMapping=Ot}function Po(A,F,V){let G=F.isScene===!0?F.overrideMaterial:null;for(let k=0,at=A.length;k<at;k++){let xt=A[k],St=xt.object,vt=xt.geometry,kt=xt.group,Ot=xt.material;Ot.allowOverride===!0&&G!==null&&(Ot=G),St.layers.test(V.layers)&&Eu(St,F,V,vt,Ot,kt)}}function Eu(A,F,V,G,k,at){A.onBeforeRender(_,F,V,G,k,at),A.modelViewMatrix.multiplyMatrices(V.matrixWorldInverse,A.matrixWorld),A.normalMatrix.getNormalMatrix(A.modelViewMatrix),k.onBeforeRender(_,F,V,G,A,at),k.transparent===!0&&k.side===Fe&&k.forceSinglePass===!1?(k.side=qe,k.needsUpdate=!0,_.renderBufferDirect(V,F,G,k,A,at),k.side=bi,k.needsUpdate=!0,_.renderBufferDirect(V,F,G,k,A,at),k.side=Fe):_.renderBufferDirect(V,F,G,k,A,at),A.onAfterRender(_,F,V,G,k,at)}function Lo(A,F,V){F.isScene!==!0&&(F=Tt);let G=st.get(A),k=p.state.lights,at=p.state.shadowsArray,xt=k.state.version,St=W.getParameters(A,k.state,at,F,V),vt=W.getProgramCacheKey(St),kt=G.programs;G.environment=A.isMeshStandardMaterial?F.environment:null,G.fog=F.fog,G.envMap=(A.isMeshStandardMaterial?zt:Vt).get(A.envMap||G.environment),G.envMapRotation=G.environment!==null&&A.envMap===null?F.environmentRotation:A.envMapRotation,kt===void 0&&(A.addEventListener("dispose",j),kt=new Map,G.programs=kt);let Ot=kt.get(vt);if(Ot!==void 0){if(G.currentProgram===Ot&&G.lightsStateVersion===xt)return Au(A,St),Ot}else St.uniforms=W.getUniforms(A),A.onBeforeCompile(St,_),Ot=W.acquireProgram(St,vt),kt.set(vt,Ot),G.uniforms=St.uniforms;let Dt=G.uniforms;return(!A.isShaderMaterial&&!A.isRawShaderMaterial||A.clipping===!0)&&(Dt.clippingPlanes=ht.uniform),Au(A,St),G.needsLights=Tp(A),G.lightsStateVersion=xt,G.needsLights&&(Dt.ambientLightColor.value=k.state.ambient,Dt.lightProbe.value=k.state.probe,Dt.directionalLights.value=k.state.directional,Dt.directionalLightShadows.value=k.state.directionalShadow,Dt.spotLights.value=k.state.spot,Dt.spotLightShadows.value=k.state.spotShadow,Dt.rectAreaLights.value=k.state.rectArea,Dt.ltc_1.value=k.state.rectAreaLTC1,Dt.ltc_2.value=k.state.rectAreaLTC2,Dt.pointLights.value=k.state.point,Dt.pointLightShadows.value=k.state.pointShadow,Dt.hemisphereLights.value=k.state.hemi,Dt.directionalShadowMap.value=k.state.directionalShadowMap,Dt.directionalShadowMatrix.value=k.state.directionalShadowMatrix,Dt.spotShadowMap.value=k.state.spotShadowMap,Dt.spotLightMatrix.value=k.state.spotLightMatrix,Dt.spotLightMap.value=k.state.spotLightMap,Dt.pointShadowMap.value=k.state.pointShadowMap,Dt.pointShadowMatrix.value=k.state.pointShadowMatrix),G.currentProgram=Ot,G.uniformsList=null,Ot}function Tu(A){if(A.uniformsList===null){let F=A.currentProgram.getUniforms();A.uniformsList=qs.seqWithValue(F.seq,A.uniforms)}return A.uniformsList}function Au(A,F){let V=st.get(A);V.outputColorSpace=F.outputColorSpace,V.batching=F.batching,V.batchingColor=F.batchingColor,V.instancing=F.instancing,V.instancingColor=F.instancingColor,V.instancingMorph=F.instancingMorph,V.skinning=F.skinning,V.morphTargets=F.morphTargets,V.morphNormals=F.morphNormals,V.morphColors=F.morphColors,V.morphTargetsCount=F.morphTargetsCount,V.numClippingPlanes=F.numClippingPlanes,V.numIntersection=F.numClipIntersection,V.vertexAlphas=F.vertexAlphas,V.vertexTangents=F.vertexTangents,V.toneMapping=F.toneMapping}function Sp(A,F,V,G,k){F.isScene!==!0&&(F=Tt),dt.resetTextureUnits();let at=F.fog,xt=G.isMeshStandardMaterial?F.environment:null,St=L===null?_.outputColorSpace:L.isXRRenderTarget===!0?L.texture.colorSpace:Gn,vt=(G.isMeshStandardMaterial?zt:Vt).get(G.envMap||xt),kt=G.vertexColors===!0&&!!V.attributes.color&&V.attributes.color.itemSize===4,Ot=!!V.attributes.tangent&&(!!G.normalMap||G.anisotropy>0),Dt=!!V.morphAttributes.position,Kt=!!V.morphAttributes.normal,de=!!V.morphAttributes.color,Ae=cn;G.toneMapped&&(L===null||L.isXRRenderTarget===!0)&&(Ae=_.toneMapping);let ve=V.morphAttributes.position||V.morphAttributes.normal||V.morphAttributes.color,pe=ve!==void 0?ve.length:0,Nt=st.get(G),be=p.state.lights;if(Qt===!0&&(Z===!0||A!==v)){let ii=A===v&&G.id===w;ht.setState(G,A,ii)}let ee=!1;G.version===Nt.__version?(Nt.needsLights&&Nt.lightsStateVersion!==be.state.version||Nt.outputColorSpace!==St||k.isBatchedMesh&&Nt.batching===!1||!k.isBatchedMesh&&Nt.batching===!0||k.isBatchedMesh&&Nt.batchingColor===!0&&k.colorTexture===null||k.isBatchedMesh&&Nt.batchingColor===!1&&k.colorTexture!==null||k.isInstancedMesh&&Nt.instancing===!1||!k.isInstancedMesh&&Nt.instancing===!0||k.isSkinnedMesh&&Nt.skinning===!1||!k.isSkinnedMesh&&Nt.skinning===!0||k.isInstancedMesh&&Nt.instancingColor===!0&&k.instanceColor===null||k.isInstancedMesh&&Nt.instancingColor===!1&&k.instanceColor!==null||k.isInstancedMesh&&Nt.instancingMorph===!0&&k.morphTexture===null||k.isInstancedMesh&&Nt.instancingMorph===!1&&k.morphTexture!==null||Nt.envMap!==vt||G.fog===!0&&Nt.fog!==at||Nt.numClippingPlanes!==void 0&&(Nt.numClippingPlanes!==ht.numPlanes||Nt.numIntersection!==ht.numIntersection)||Nt.vertexAlphas!==kt||Nt.vertexTangents!==Ot||Nt.morphTargets!==Dt||Nt.morphNormals!==Kt||Nt.morphColors!==de||Nt.toneMapping!==Ae||Nt.morphTargetsCount!==pe)&&(ee=!0):(ee=!0,Nt.__version=G.version);let hi=Nt.currentProgram;ee===!0&&(hi=Lo(G,F,k));let as=!1,ui=!1,rr=!1,we=hi.getUniforms(),yi=Nt.uniforms;if($.useProgram(hi.program)&&(as=!0,ui=!0,rr=!0),G.id!==w&&(w=G.id,ui=!0),as||v!==A){$.buffers.depth.getReversed()&&A.reversedDepth!==!0&&(A._reversedDepth=!0,A.updateProjectionMatrix()),we.setValue(D,"projectionMatrix",A.projectionMatrix),we.setValue(D,"viewMatrix",A.matrixWorldInverse);let ai=we.map.cameraPosition;ai!==void 0&&ai.setValue(D,Mt.setFromMatrixPosition(A.matrixWorld)),J.logarithmicDepthBuffer&&we.setValue(D,"logDepthBufFC",2/(Math.log(A.far+1)/Math.LN2)),(G.isMeshPhongMaterial||G.isMeshToonMaterial||G.isMeshLambertMaterial||G.isMeshBasicMaterial||G.isMeshStandardMaterial||G.isShaderMaterial)&&we.setValue(D,"isOrthographic",A.isOrthographicCamera===!0),v!==A&&(v=A,ui=!0,rr=!0)}if(k.isSkinnedMesh){we.setOptional(D,k,"bindMatrix"),we.setOptional(D,k,"bindMatrixInverse");let ii=k.skeleton;ii&&(ii.boneTexture===null&&ii.computeBoneTexture(),we.setValue(D,"boneTexture",ii.boneTexture,dt))}k.isBatchedMesh&&(we.setOptional(D,k,"batchingTexture"),we.setValue(D,"batchingTexture",k._matricesTexture,dt),we.setOptional(D,k,"batchingIdTexture"),we.setValue(D,"batchingIdTexture",k._indirectTexture,dt),we.setOptional(D,k,"batchingColorTexture"),k._colorsTexture!==null&&we.setValue(D,"batchingColorTexture",k._colorsTexture,dt));let vi=V.morphAttributes;if((vi.position!==void 0||vi.normal!==void 0||vi.color!==void 0)&&rt.update(k,V,hi),(ui||Nt.receiveShadow!==k.receiveShadow)&&(Nt.receiveShadow=k.receiveShadow,we.setValue(D,"receiveShadow",k.receiveShadow)),G.isMeshGouraudMaterial&&G.envMap!==null&&(yi.envMap.value=vt,yi.flipEnvMap.value=vt.isCubeTexture&&vt.isRenderTargetTexture===!1?-1:1),G.isMeshStandardMaterial&&G.envMap===null&&F.environment!==null&&(yi.envMapIntensity.value=F.environmentIntensity),ui&&(we.setValue(D,"toneMappingExposure",_.toneMappingExposure),Nt.needsLights&&Ep(yi,rr),at&&G.fog===!0&&Q.refreshFogUniforms(yi,at),Q.refreshMaterialUniforms(yi,G,X,it,p.state.transmissionRenderTarget[A.id]),qs.upload(D,Tu(Nt),yi,dt)),G.isShaderMaterial&&G.uniformsNeedUpdate===!0&&(qs.upload(D,Tu(Nt),yi,dt),G.uniformsNeedUpdate=!1),G.isSpriteMaterial&&we.setValue(D,"center",k.center),we.setValue(D,"modelViewMatrix",k.modelViewMatrix),we.setValue(D,"normalMatrix",k.normalMatrix),we.setValue(D,"modelMatrix",k.matrixWorld),G.isShaderMaterial||G.isRawShaderMaterial){let ii=G.uniformsGroups;for(let ai=0,pc=ii.length;ai<pc;ai++){let Fn=ii[ai];qt.update(Fn,hi),qt.bind(Fn,hi)}}return hi}function Ep(A,F){A.ambientLightColor.needsUpdate=F,A.lightProbe.needsUpdate=F,A.directionalLights.needsUpdate=F,A.directionalLightShadows.needsUpdate=F,A.pointLights.needsUpdate=F,A.pointLightShadows.needsUpdate=F,A.spotLights.needsUpdate=F,A.spotLightShadows.needsUpdate=F,A.rectAreaLights.needsUpdate=F,A.hemisphereLights.needsUpdate=F}function Tp(A){return A.isMeshLambertMaterial||A.isMeshToonMaterial||A.isMeshPhongMaterial||A.isMeshStandardMaterial||A.isShadowMaterial||A.isShaderMaterial&&A.lights===!0}this.getActiveCubeFace=function(){return E},this.getActiveMipmapLevel=function(){return P},this.getRenderTarget=function(){return L},this.setRenderTargetTextures=function(A,F,V){let G=st.get(A);G.__autoAllocateDepthBuffer=A.resolveDepthBuffer===!1,G.__autoAllocateDepthBuffer===!1&&(G.__useRenderToTexture=!1),st.get(A.texture).__webglTexture=F,st.get(A.depthTexture).__webglTexture=G.__autoAllocateDepthBuffer?void 0:V,G.__hasExternalTextures=!0},this.setRenderTargetFramebuffer=function(A,F){let V=st.get(A);V.__webglFramebuffer=F,V.__useDefaultFramebuffer=F===void 0};let Ap=D.createFramebuffer();this.setRenderTarget=function(A,F=0,V=0){L=A,E=F,P=V;let G=!0,k=null,at=!1,xt=!1;if(A){let vt=st.get(A);if(vt.__useDefaultFramebuffer!==void 0)$.bindFramebuffer(D.FRAMEBUFFER,null),G=!1;else if(vt.__webglFramebuffer===void 0)dt.setupRenderTarget(A);else if(vt.__hasExternalTextures)dt.rebindTextures(A,st.get(A.texture).__webglTexture,st.get(A.depthTexture).__webglTexture);else if(A.depthBuffer){let Dt=A.depthTexture;if(vt.__boundDepthTexture!==Dt){if(Dt!==null&&st.has(Dt)&&(A.width!==Dt.image.width||A.height!==Dt.image.height))throw new Error("WebGLRenderTarget: Attached DepthTexture is initialized to the incorrect size.");dt.setupDepthRenderbuffer(A)}}let kt=A.texture;(kt.isData3DTexture||kt.isDataArrayTexture||kt.isCompressedArrayTexture)&&(xt=!0);let Ot=st.get(A).__webglFramebuffer;A.isWebGLCubeRenderTarget?(Array.isArray(Ot[F])?k=Ot[F][V]:k=Ot[F],at=!0):A.samples>0&&dt.useMultisampledRTT(A)===!1?k=st.get(A).__webglMultisampledFramebuffer:Array.isArray(Ot)?k=Ot[V]:k=Ot,C.copy(A.viewport),U.copy(A.scissor),O=A.scissorTest}else C.copy(bt).multiplyScalar(X).floor(),U.copy(Wt).multiplyScalar(X).floor(),O=jt;if(V!==0&&(k=Ap),$.bindFramebuffer(D.FRAMEBUFFER,k)&&G&&$.drawBuffers(A,k),$.viewport(C),$.scissor(U),$.setScissorTest(O),at){let vt=st.get(A.texture);D.framebufferTexture2D(D.FRAMEBUFFER,D.COLOR_ATTACHMENT0,D.TEXTURE_CUBE_MAP_POSITIVE_X+F,vt.__webglTexture,V)}else if(xt){let vt=F;for(let kt=0;kt<A.textures.length;kt++){let Ot=st.get(A.textures[kt]);D.framebufferTextureLayer(D.FRAMEBUFFER,D.COLOR_ATTACHMENT0+kt,Ot.__webglTexture,V,vt)}}else if(A!==null&&V!==0){let vt=st.get(A.texture);D.framebufferTexture2D(D.FRAMEBUFFER,D.COLOR_ATTACHMENT0,D.TEXTURE_2D,vt.__webglTexture,V)}w=-1},this.readRenderTargetPixels=function(A,F,V,G,k,at,xt,St=0){if(!(A&&A.isWebGLRenderTarget)){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not THREE.WebGLRenderTarget.");return}let vt=st.get(A).__webglFramebuffer;if(A.isWebGLCubeRenderTarget&&xt!==void 0&&(vt=vt[xt]),vt){$.bindFramebuffer(D.FRAMEBUFFER,vt);try{let kt=A.textures[St],Ot=kt.format,Dt=kt.type;if(!J.textureFormatReadable(Ot)){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not in RGBA or implementation defined format.");return}if(!J.textureTypeReadable(Dt)){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not in UnsignedByteType or implementation defined type.");return}F>=0&&F<=A.width-G&&V>=0&&V<=A.height-k&&(A.textures.length>1&&D.readBuffer(D.COLOR_ATTACHMENT0+St),D.readPixels(F,V,G,k,Pt.convert(Ot),Pt.convert(Dt),at))}finally{let kt=L!==null?st.get(L).__webglFramebuffer:null;$.bindFramebuffer(D.FRAMEBUFFER,kt)}}},this.readRenderTargetPixelsAsync=async function(A,F,V,G,k,at,xt,St=0){if(!(A&&A.isWebGLRenderTarget))throw new Error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not THREE.WebGLRenderTarget.");let vt=st.get(A).__webglFramebuffer;if(A.isWebGLCubeRenderTarget&&xt!==void 0&&(vt=vt[xt]),vt)if(F>=0&&F<=A.width-G&&V>=0&&V<=A.height-k){$.bindFramebuffer(D.FRAMEBUFFER,vt);let kt=A.textures[St],Ot=kt.format,Dt=kt.type;if(!J.textureFormatReadable(Ot))throw new Error("THREE.WebGLRenderer.readRenderTargetPixelsAsync: renderTarget is not in RGBA or implementation defined format.");if(!J.textureTypeReadable(Dt))throw new Error("THREE.WebGLRenderer.readRenderTargetPixelsAsync: renderTarget is not in UnsignedByteType or implementation defined type.");let Kt=D.createBuffer();D.bindBuffer(D.PIXEL_PACK_BUFFER,Kt),D.bufferData(D.PIXEL_PACK_BUFFER,at.byteLength,D.STREAM_READ),A.textures.length>1&&D.readBuffer(D.COLOR_ATTACHMENT0+St),D.readPixels(F,V,G,k,Pt.convert(Ot),Pt.convert(Dt),0);let de=L!==null?st.get(L).__webglFramebuffer:null;$.bindFramebuffer(D.FRAMEBUFFER,de);let Ae=D.fenceSync(D.SYNC_GPU_COMMANDS_COMPLETE,0);return D.flush(),await jd(D,Ae,4),D.bindBuffer(D.PIXEL_PACK_BUFFER,Kt),D.getBufferSubData(D.PIXEL_PACK_BUFFER,0,at),D.deleteBuffer(Kt),D.deleteSync(Ae),at}else throw new Error("THREE.WebGLRenderer.readRenderTargetPixelsAsync: requested read bounds are out of range.")},this.copyFramebufferToTexture=function(A,F=null,V=0){let G=Math.pow(2,-V),k=Math.floor(A.image.width*G),at=Math.floor(A.image.height*G),xt=F!==null?F.x:0,St=F!==null?F.y:0;dt.setTexture2D(A,0),D.copyTexSubImage2D(D.TEXTURE_2D,V,0,0,xt,St,k,at),$.unbindTexture()};let Rp=D.createFramebuffer(),Cp=D.createFramebuffer();this.copyTextureToTexture=function(A,F,V=null,G=null,k=0,at=null){at===null&&(k!==0?(Cs("WebGLRenderer: copyTextureToTexture function signature has changed to support src and dst mipmap levels."),at=k,k=0):at=0);let xt,St,vt,kt,Ot,Dt,Kt,de,Ae,ve=A.isCompressedTexture?A.mipmaps[at]:A.image;if(V!==null)xt=V.max.x-V.min.x,St=V.max.y-V.min.y,vt=V.isBox3?V.max.z-V.min.z:1,kt=V.min.x,Ot=V.min.y,Dt=V.isBox3?V.min.z:0;else{let vi=Math.pow(2,-k);xt=Math.floor(ve.width*vi),St=Math.floor(ve.height*vi),A.isDataArrayTexture?vt=ve.depth:A.isData3DTexture?vt=Math.floor(ve.depth*vi):vt=1,kt=0,Ot=0,Dt=0}G!==null?(Kt=G.x,de=G.y,Ae=G.z):(Kt=0,de=0,Ae=0);let pe=Pt.convert(F.format),Nt=Pt.convert(F.type),be;F.isData3DTexture?(dt.setTexture3D(F,0),be=D.TEXTURE_3D):F.isDataArrayTexture||F.isCompressedArrayTexture?(dt.setTexture2DArray(F,0),be=D.TEXTURE_2D_ARRAY):(dt.setTexture2D(F,0),be=D.TEXTURE_2D),D.pixelStorei(D.UNPACK_FLIP_Y_WEBGL,F.flipY),D.pixelStorei(D.UNPACK_PREMULTIPLY_ALPHA_WEBGL,F.premultiplyAlpha),D.pixelStorei(D.UNPACK_ALIGNMENT,F.unpackAlignment);let ee=D.getParameter(D.UNPACK_ROW_LENGTH),hi=D.getParameter(D.UNPACK_IMAGE_HEIGHT),as=D.getParameter(D.UNPACK_SKIP_PIXELS),ui=D.getParameter(D.UNPACK_SKIP_ROWS),rr=D.getParameter(D.UNPACK_SKIP_IMAGES);D.pixelStorei(D.UNPACK_ROW_LENGTH,ve.width),D.pixelStorei(D.UNPACK_IMAGE_HEIGHT,ve.height),D.pixelStorei(D.UNPACK_SKIP_PIXELS,kt),D.pixelStorei(D.UNPACK_SKIP_ROWS,Ot),D.pixelStorei(D.UNPACK_SKIP_IMAGES,Dt);let we=A.isDataArrayTexture||A.isData3DTexture,yi=F.isDataArrayTexture||F.isData3DTexture;if(A.isDepthTexture){let vi=st.get(A),ii=st.get(F),ai=st.get(vi.__renderTarget),pc=st.get(ii.__renderTarget);$.bindFramebuffer(D.READ_FRAMEBUFFER,ai.__webglFramebuffer),$.bindFramebuffer(D.DRAW_FRAMEBUFFER,pc.__webglFramebuffer);for(let Fn=0;Fn<vt;Fn++)we&&(D.framebufferTextureLayer(D.READ_FRAMEBUFFER,D.COLOR_ATTACHMENT0,st.get(A).__webglTexture,k,Dt+Fn),D.framebufferTextureLayer(D.DRAW_FRAMEBUFFER,D.COLOR_ATTACHMENT0,st.get(F).__webglTexture,at,Ae+Fn)),D.blitFramebuffer(kt,Ot,xt,St,Kt,de,xt,St,D.DEPTH_BUFFER_BIT,D.NEAREST);$.bindFramebuffer(D.READ_FRAMEBUFFER,null),$.bindFramebuffer(D.DRAW_FRAMEBUFFER,null)}else if(k!==0||A.isRenderTargetTexture||st.has(A)){let vi=st.get(A),ii=st.get(F);$.bindFramebuffer(D.READ_FRAMEBUFFER,Rp),$.bindFramebuffer(D.DRAW_FRAMEBUFFER,Cp);for(let ai=0;ai<vt;ai++)we?D.framebufferTextureLayer(D.READ_FRAMEBUFFER,D.COLOR_ATTACHMENT0,vi.__webglTexture,k,Dt+ai):D.framebufferTexture2D(D.READ_FRAMEBUFFER,D.COLOR_ATTACHMENT0,D.TEXTURE_2D,vi.__webglTexture,k),yi?D.framebufferTextureLayer(D.DRAW_FRAMEBUFFER,D.COLOR_ATTACHMENT0,ii.__webglTexture,at,Ae+ai):D.framebufferTexture2D(D.DRAW_FRAMEBUFFER,D.COLOR_ATTACHMENT0,D.TEXTURE_2D,ii.__webglTexture,at),k!==0?D.blitFramebuffer(kt,Ot,xt,St,Kt,de,xt,St,D.COLOR_BUFFER_BIT,D.NEAREST):yi?D.copyTexSubImage3D(be,at,Kt,de,Ae+ai,kt,Ot,xt,St):D.copyTexSubImage2D(be,at,Kt,de,kt,Ot,xt,St);$.bindFramebuffer(D.READ_FRAMEBUFFER,null),$.bindFramebuffer(D.DRAW_FRAMEBUFFER,null)}else yi?A.isDataTexture||A.isData3DTexture?D.texSubImage3D(be,at,Kt,de,Ae,xt,St,vt,pe,Nt,ve.data):F.isCompressedArrayTexture?D.compressedTexSubImage3D(be,at,Kt,de,Ae,xt,St,vt,pe,ve.data):D.texSubImage3D(be,at,Kt,de,Ae,xt,St,vt,pe,Nt,ve):A.isDataTexture?D.texSubImage2D(D.TEXTURE_2D,at,Kt,de,xt,St,pe,Nt,ve.data):A.isCompressedTexture?D.compressedTexSubImage2D(D.TEXTURE_2D,at,Kt,de,ve.width,ve.height,pe,ve.data):D.texSubImage2D(D.TEXTURE_2D,at,Kt,de,xt,St,pe,Nt,ve);D.pixelStorei(D.UNPACK_ROW_LENGTH,ee),D.pixelStorei(D.UNPACK_IMAGE_HEIGHT,hi),D.pixelStorei(D.UNPACK_SKIP_PIXELS,as),D.pixelStorei(D.UNPACK_SKIP_ROWS,ui),D.pixelStorei(D.UNPACK_SKIP_IMAGES,rr),at===0&&F.generateMipmaps&&D.generateMipmap(be),$.unbindTexture()},this.initRenderTarget=function(A){st.get(A).__webglFramebuffer===void 0&&dt.setupRenderTarget(A)},this.initTexture=function(A){A.isCubeTexture?dt.setTextureCube(A,0):A.isData3DTexture?dt.setTexture3D(A,0):A.isDataArrayTexture||A.isCompressedArrayTexture?dt.setTexture2DArray(A,0):dt.setTexture2D(A,0),$.unbindTexture()},this.resetState=function(){E=0,P=0,L=null,$.reset(),gt.reset()},typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}get coordinateSystem(){return Li}get outputColorSpace(){return this._outputColorSpace}set outputColorSpace(t){this._outputColorSpace=t;let e=this.getContext();e.drawingBufferColorSpace=te._getDrawingBufferColorSpace(t),e.unpackColorSpace=te._getUnpackColorSpace()}};var Oh={LOW:{pixelRatio:.75,shadows:!1,shadowMapSize:512,viewChunks:1,terrainRes:14,grassDensity:0,bushDensity:.5,treeDensity:.75,maxEnemies:12,particles:1200,fogNear:30,fogFar:95,antialias:!1,enemyShadows:!1,standardMaterials:!1},MEDIUM:{pixelRatio:1,shadows:!0,shadowMapSize:1024,viewChunks:2,terrainRes:20,grassDensity:.55,bushDensity:.8,treeDensity:.9,maxEnemies:18,particles:2500,fogNear:40,fogFar:140,antialias:!1,enemyShadows:!1,standardMaterials:!0},HIGH:{pixelRatio:1.5,shadows:!0,shadowMapSize:2048,viewChunks:2,terrainRes:28,grassDensity:1,bushDensity:1,treeDensity:1,maxEnemies:26,particles:4e3,fogNear:50,fogFar:170,antialias:!0,enemyShadows:!0,standardMaterials:!0}},zh={rifle:{id:"rifle",name:"Assault Rifle",auto:!0,damage:24,fireInterval:.1,pellets:1,mag:30,reserve:180,maxReserve:300,reload:2,spreadHip:1.6,spreadAim:.45,recoil:.9,range:120,zoomFov:50,penetration:1,armorPiercing:0,spinUp:0,moveMul:.95,sound:"fire_rifle",reloadSound:"reload_rifle",shellScale:1,falloff:60},shotgun:{id:"shotgun",name:"Shotgun",auto:!1,damage:15,fireInterval:.75,pellets:9,mag:8,reserve:40,maxReserve:64,reload:2.6,spreadHip:6.5,spreadAim:4.5,recoil:3.2,range:35,zoomFov:58,penetration:1,armorPiercing:0,spinUp:0,moveMul:.95,sound:"fire_shotgun",reloadSound:"reload_shotgun",shellScale:1.6,falloff:12},sniper:{id:"sniper",name:"Sniper Rifle",auto:!1,damage:160,fireInterval:1.25,pellets:1,mag:5,reserve:30,maxReserve:50,reload:2.8,spreadHip:5,spreadAim:.05,recoil:5,range:320,zoomFov:16,penetration:3,armorPiercing:1,spinUp:0,moveMul:.88,sound:"fire_sniper",reloadSound:"reload_rifle",shellScale:1.4,falloff:250},smg:{id:"smg",name:"SMG",auto:!0,damage:15,fireInterval:.066,pellets:1,mag:35,reserve:210,maxReserve:350,reload:1.6,spreadHip:2.4,spreadAim:1,recoil:.6,range:60,zoomFov:55,penetration:1,armorPiercing:0,spinUp:0,moveMul:1,sound:"fire_smg",reloadSound:"reload_pistol",shellScale:.8,falloff:25},pistol:{id:"pistol",name:"Pistol",auto:!1,damage:32,fireInterval:.2,pellets:1,mag:12,reserve:1/0,maxReserve:1/0,reload:1.2,spreadHip:1.4,spreadAim:.5,recoil:1.5,range:70,zoomFov:55,penetration:1,armorPiercing:0,spinUp:0,moveMul:1.05,sound:"fire_pistol",reloadSound:"reload_pistol",shellScale:.7,falloff:30},minigun:{id:"minigun",name:"Minigun",auto:!0,damage:19,fireInterval:.045,pellets:1,mag:200,reserve:400,maxReserve:800,reload:4.2,spreadHip:2.8,spreadAim:1.8,recoil:.35,range:90,zoomFov:58,penetration:1,armorPiercing:0,spinUp:.55,moveMul:.7,sound:"fire_minigun",reloadSound:"reload_rifle",shellScale:1,falloff:45}},Zs={damage:160,radius:6.5,fuse:2.2,throwSpeed:17},$s={grunt:{id:"grunt",name:"Purple Grunt",hp:110,walk:2.6,run:4.6,damage:12,range:1.9,cooldown:1.1,radius:.55,height:2,scale:1,colors:[2759229,5978762,11816447],resist:1,score:100,coins:3,behavior:"melee",rig:"humanoid"},runner:{id:"runner",name:"Red Stalker",hp:70,walk:4.5,run:8,damage:9,range:1.8,cooldown:.7,radius:.5,height:1.9,scale:.92,colors:[3804429,9379101,16726831],resist:1,score:130,coins:3,behavior:"fast",rig:"humanoid"},tank:{id:"tank",name:"Blue Brute",hp:650,walk:2,run:2.6,damage:28,range:2.8,cooldown:1.8,radius:1,height:3.1,scale:1.55,colors:[859965,2641295,3073791],resist:.5,score:400,coins:10,behavior:"tank",rig:"brute"},crawler:{id:"crawler",name:"Green Crawler",hp:60,walk:4,run:7.2,damage:10,range:1.7,cooldown:.8,radius:.55,height:.9,scale:1,colors:[2240525,6060570,10354478],resist:1,score:120,coins:3,behavior:"crawler",rig:"crawler"},spitter:{id:"spitter",name:"Acid Spitter",hp:95,walk:2.4,run:3.4,damage:14,range:18,cooldown:2.4,radius:.55,height:2,scale:1,colors:[2831114,9083420,14221114],resist:1,score:160,coins:4,behavior:"spitter",rig:"humanoid"},exploder:{id:"exploder",name:"Bloater",hp:55,walk:3.6,run:5.8,damage:45,range:2.2,cooldown:1,radius:.6,height:1.6,scale:.95,colors:[4005898,10704412,16751391],resist:1,score:150,coins:4,behavior:"exploder",rig:"bloater"},flyer:{id:"flyer",name:"Sky Wraith",hp:60,walk:6,run:9,damage:10,range:2,cooldown:1.4,radius:.6,height:1.4,scale:.85,colors:[862771,1866383,5111792],resist:1,score:180,coins:5,behavior:"flyer",rig:"flyer"},elite:{id:"elite",name:"Void Elite",hp:420,walk:3.2,run:5.6,damage:22,range:2.1,cooldown:.9,radius:.65,height:2.3,scale:1.18,colors:[1052693,7035420,16723686],resist:.7,score:450,coins:12,behavior:"elite",rig:"humanoid"},boss:{id:"boss",name:"Hive Titan",hp:3600,walk:2.4,run:3.4,damage:40,range:4.5,cooldown:2,radius:1.8,height:6,scale:3,colors:[1510707,4008591,8019199],resist:.8,score:3e3,coins:60,behavior:"boss",rig:"brute"}};function Nf(){return{mode:"play",seed:Math.floor(Math.random()*1e9),loadout:["rifle","shotgun","pistol"],weapons:{},player:{maxHealth:100,maxArmor:100,startArmor:50,grenades:3,maxGrenades:6},settings:{quality:"MEDIUM",fps:60,sensitivity:1,aimSensitivity:.6,fov:70,invertY:!1,aimAssist:!0,shoulder:1,cameraShake:1,musicVolume:.6,sfxVolume:.9,ambienceVolume:.7,masterVolume:1,controlScale:1,controlOpacity:.85,showFps:!1,layout:null},debug:{god:!1,timeScale:1}}}function Hh(s,t){if(!t||typeof t!="object")return s;let e=Array.isArray(s)?[...s]:{...s};for(let i of Object.keys(t)){let n=t[i];n&&typeof n=="object"&&!Array.isArray(n)&&s[i]&&typeof s[i]=="object"&&!Array.isArray(s[i])?e[i]=Hh(s[i],n):n!==void 0&&(e[i]=n)}return e}window.__bridgeLog=window.__bridgeLog||[];function xi(s,t={}){let e=JSON.stringify({type:s,...t});window.__bridgeLog.push(e),window.__bridgeLog.length>200&&window.__bridgeLog.shift();try{window.GameBridge&&typeof window.GameBridge.postMessage=="function"&&window.GameBridge.postMessage(e)}catch{}}var fo=()=>!!(window.GameBridge&&window.GameBridge.postMessage);var $t=(s,t,e)=>s<t?t:s>e?e:s,De=(s,t,e)=>s+(t-s)*e,Zi=(s,t,e)=>{let i=$t((e-s)/(t-s),0,1);return i*i*(3-2*i)},ze=(s,t)=>1-Math.exp(-s*t),zl=Math.PI/180;function mo(s){for(;s>Math.PI;)s-=Math.PI*2;for(;s<-Math.PI;)s+=Math.PI*2;return s}function go(s,t,e,i){return s+mo(t-s)*ze(e,i)}function me(s){let t=s>>>0,e=()=>{t=t+1831565813>>>0;let i=t;return i=Math.imul(i^i>>>15,i|1),i^=i+Math.imul(i^i>>>7,i|61),((i^i>>>14)>>>0)/4294967296};return e.range=(i,n)=>i+(n-i)*e(),e.int=(i,n)=>Math.floor(i+(n-i+1)*e()),e.pick=i=>i[Math.floor(e()*i.length)],e}function Ff(s,t,e=0){let i=Math.imul(s|0,374761393)^Math.imul(t|0,668265263)^Math.imul(e|0,1274126177);return i=Math.imul(i^i>>>13,1274126177),(i^i>>>16)>>>0}var Vh=[[1,1],[-1,1],[1,-1],[-1,-1],[1,0],[-1,0],[0,1],[0,-1]],Py=.5*(Math.sqrt(3)-1),po=(3-Math.sqrt(3))/6;function _i(s=1){let t=me(s),e=new Uint8Array(256);for(let n=0;n<256;n++)e[n]=n;for(let n=255;n>0;n--){let r=Math.floor(t()*(n+1)),o=e[n];e[n]=e[r],e[r]=o}let i=new Uint8Array(512);for(let n=0;n<512;n++)i[n]=e[n&255];return function(r,o){let a=(r+o)*Py,l=Math.floor(r+a),c=Math.floor(o+a),h=(l+c)*po,u=r-(l-h),f=o-(c-h),d=u>f?1:0,g=u>f?0:1,x=u-d+po,m=f-g+po,p=u-1+2*po,M=f-1+2*po,y=l&255,_=c&255,b=0,E=0,P=0,L=.5-u*u-f*f;if(L>0){let C=Vh[i[y+i[_]]&7];L*=L,b=L*L*(C[0]*u+C[1]*f)}let w=.5-x*x-m*m;if(w>0){let C=Vh[i[y+d+i[_+g]]&7];w*=w,E=w*w*(C[0]*x+C[1]*m)}let v=.5-p*p-M*M;if(v>0){let C=Vh[i[y+1+i[_+1]]&7];v*=v,P=v*v*(C[0]*p+C[1]*M)}return 70*(b+E+P)}}function xo(s,t,e,i=4,n=2,r=.5){let o=1,a=1,l=0,c=0;for(let h=0;h<i;h++)l+=o*s(t*a,e*a),c+=o,o*=r,a*=n;return l/c}function Gh(s,t,e,i,n,r,o,a,l,c){let h=o-s,u=a-t,f=l-e,d=h*i+u*n+f*r,g=h*h+u*u+f*f-d*d,x=c*c;if(g>x)return-1;let m=Math.sqrt(x-g),p=d-m;return p>=0?p:d+m>=0?0:-1}function kf(s,t,e,i,n,r,o,a,l,c,h){let u=s-o,f=e-a,d=i*i+r*r;if(d<1e-8){if(u*u+f*f<=l*l){let y=n>0?c-t:t-h;return y>=0?y:t>=c&&t<=h?0:-1}return-1}let g=2*(u*i+f*r),x=u*u+f*f-l*l;if(x<=0)return t>=c&&t<=h?0:-1;let m=g*g-4*d*x;if(m<0)return-1;let p=(-g-Math.sqrt(m))/(2*d);if(p<0)return-1;let M=t+n*p;return M>=c&&M<=h?p:-1}var Wh=new Map;function $i(s,t=s){let e=document.createElement("canvas");return e.width=s,e.height=t,e}function ti(s,{repeat:t=!0,srgb:e=!0}={}){let i=new Fr(s);return t&&(i.wrapS=i.wrapT=Ts),i.colorSpace=e?Ne:Bi,i.anisotropy=4,i.needsUpdate=!0,i}function rs(s,t,e){let i=$i(s),n=i.getContext("2d"),r=n.createImageData(s,s),o=_i(t),a=Math.PI*2,l=(c,h,u)=>{let f=o(c*u,h*u),d=o((c-1)*u,h*u),g=o(c*u,(h-1)*u),x=o((c-1)*u,(h-1)*u),m=c*c*(3-2*c),p=h*h*(3-2*h);return(f*(1-m)+d*m)*(1-p)+(g*(1-m)+x*m)*p};for(let c=0;c<s;c++)for(let h=0;h<s;h++){let u=e(h/s,c/s,l,a)|0,f=(c*s+h)*4,d=u<0?0:u>255?255:u;r.data[f]=r.data[f+1]=r.data[f+2]=d,r.data[f+3]=255}return n.putImageData(r,0,0),i}function ei(s,t){return Wh.has(s)||Wh.set(s,t()),Wh.get(s)}var ae={ground:()=>ei("ground",()=>ti(rs(256,11,(s,t,e)=>190+40*e(s,t,8)+25*e(s,t,32)))),fabric:()=>ei("fabric",()=>ti(rs(128,3,(s,t,e)=>205+Math.sin(s*128*Math.PI)*Math.sin(t*128*Math.PI)*14+30*e(s,t,6)+12*e(s,t,24)))),skin:()=>ei("skin",()=>ti(rs(128,5,(s,t,e)=>225+18*e(s,t,10)+8*e(s,t,40)))),bark:()=>ei("bark",()=>ti(rs(128,7,(s,t,e)=>120+110*Math.abs(Math.sin(s*Math.PI*10+e(s,t,4)*3))+20*e(s,t,24)))),rock:()=>ei("rock",()=>ti(rs(256,13,(s,t,e)=>{let i=Math.abs(e(s,t,6));return 150+70*e(s,t,3)+40*e(s,t,16)-(i<.05?60:0)}))),alien:()=>ei("alien",()=>ti(rs(256,17,(s,t,e)=>215-(Math.abs(e(s,t,10))<.07?90:0)+30*e(s,t,30)))),metal:()=>ei("metal",()=>ti(rs(128,19,(s,t,e)=>200+30*e(s*.1,t*4,20)+10*e(s,t,40)))),wood:()=>ei("wood",()=>{let s=$i(256),t=s.getContext("2d"),e=me(23);t.fillStyle="#7a5230",t.fillRect(0,0,256,256);for(let i=0;i<4;i++){t.fillStyle=`hsl(28, ${35+e()*15}%, ${26+e()*10}%)`,t.fillRect(0,i*64+2,256,60);for(let n=0;n<40;n++){t.strokeStyle=`rgba(40,20,5,${.15+e()*.25})`,t.lineWidth=1+e(),t.beginPath();let r=i*64+4+e()*56;t.moveTo(0,r),t.bezierCurveTo(80,r+e()*6-3,170,r+e()*6-3,256,r+e()*4-2),t.stroke()}t.fillStyle="rgba(20,10,0,0.7)",t.fillRect(0,i*64,256,2)}return ti(s)}),crate:()=>ei("crate",()=>{let s=$i(256),t=s.getContext("2d"),e=me(29);t.fillStyle="#9a6a3a",t.fillRect(0,0,256,256);for(let i=0;i<5;i++){t.fillStyle=`hsl(30, 45%, ${32+e()*10}%)`,t.fillRect(0,i*51+2,256,48);for(let n=0;n<18;n++){t.strokeStyle=`rgba(50,25,5,${.2+e()*.2})`,t.beginPath();let r=i*51+4+e()*44;t.moveTo(0,r),t.lineTo(256,r+e()*4-2),t.stroke()}}t.strokeStyle="#5a3a1a",t.lineWidth=22,t.strokeRect(11,11,234,234),t.lineWidth=18,t.beginPath(),t.moveTo(20,20),t.lineTo(236,236),t.stroke(),t.fillStyle="#2a2a2a";for(let[i,n]of[[11,11],[245,11],[11,245],[245,245]])t.beginPath(),t.arc(i,n,5,0,Math.PI*2),t.fill();return ti(s,{repeat:!1})}),barrel:()=>ei("barrel",()=>{let s=$i(256,128),t=s.getContext("2d"),e=t.createLinearGradient(0,0,256,0);e.addColorStop(0,"#8f1010"),e.addColorStop(.5,"#d42a1a"),e.addColorStop(1,"#8f1010"),t.fillStyle=e,t.fillRect(0,0,256,128),t.fillStyle="rgba(0,0,0,0.35)",t.fillRect(0,18,256,6),t.fillRect(0,104,256,6),t.fillStyle="#f2c21b",t.beginPath(),t.moveTo(64,38),t.lineTo(90,88),t.lineTo(38,88),t.closePath(),t.fill(),t.strokeStyle="#111",t.lineWidth=3,t.stroke(),t.fillStyle="#111",t.font="bold 30px sans-serif",t.textAlign="center",t.fillText("!",64,84),t.fillStyle="#f2c21b",t.beginPath(),t.moveTo(192,38),t.lineTo(218,88),t.lineTo(166,88),t.closePath(),t.fill(),t.stroke(),t.fillStyle="#111",t.fillText("!",192,84);let i=me(31);for(let n=0;n<60;n++)t.fillStyle=`rgba(60,30,10,${i()*.4})`,t.fillRect(i()*256,i()*128,2+i()*8,1+i()*3);return ti(s,{repeat:!1})}),medkit:()=>ei("medkit",()=>{let s=$i(128),t=s.getContext("2d");return t.fillStyle="#d61f1f",t.fillRect(0,0,128,128),t.fillStyle="#fff",t.fillRect(48,22,32,84),t.fillRect(22,48,84,32),ti(s,{repeat:!1})}),ammo:()=>ei("ammo",()=>{let s=$i(128),t=s.getContext("2d");return t.fillStyle="#3f5a26",t.fillRect(0,0,128,128),t.fillStyle="#e8c547",t.font="bold 26px sans-serif",t.textAlign="center",t.fillText("AMMO",64,74),t.strokeStyle="#2a3d18",t.lineWidth=8,t.strokeRect(4,4,120,120),ti(s,{repeat:!1})}),muzzle:()=>ei("muzzle",()=>{let s=$i(128),t=s.getContext("2d"),e=t.createRadialGradient(64,64,2,64,64,64);e.addColorStop(0,"rgba(255,255,230,1)"),e.addColorStop(.25,"rgba(255,200,80,0.95)"),e.addColorStop(.6,"rgba(255,110,20,0.4)"),e.addColorStop(1,"rgba(255,60,0,0)"),t.fillStyle=e,t.save(),t.translate(64,64);for(let i=0;i<6;i++)t.rotate(Math.PI/3),t.beginPath(),t.moveTo(-10,0),t.lineTo(0,-64),t.lineTo(10,0),t.closePath(),t.fill();return t.restore(),t.beginPath(),t.arc(64,64,34,0,Math.PI*2),t.fill(),ti(s,{repeat:!1})}),glow:()=>ei("glow",()=>{let s=$i(64),t=s.getContext("2d"),e=t.createRadialGradient(32,32,0,32,32,32);return e.addColorStop(0,"rgba(255,255,255,1)"),e.addColorStop(.4,"rgba(255,255,255,0.45)"),e.addColorStop(1,"rgba(255,255,255,0)"),t.fillStyle=e,t.fillRect(0,0,64,64),ti(s,{repeat:!1})}),scorch:()=>ei("scorch",()=>{let s=$i(128),t=s.getContext("2d"),e=me(37);for(let i=0;i<40;i++){let n=e()*Math.PI*2,r=e()*40,o=t.createRadialGradient(64+Math.cos(n)*r,64+Math.sin(n)*r,0,64+Math.cos(n)*r,64+Math.sin(n)*r,10+e()*22);o.addColorStop(0,"rgba(10,8,6,0.5)"),o.addColorStop(1,"rgba(10,8,6,0)"),t.fillStyle=o,t.fillRect(0,0,128,128)}return ti(s,{repeat:!1})}),patch:s=>ei("patch"+s,()=>{let t=$i(64),e=t.getContext("2d");return e.fillStyle="#2c3320",e.fillRect(0,0,64,64),e.fillStyle=s,e.fillRect(6,6,52,52),e.fillStyle="#2c3320",e.fillRect(14,28,36,8),e.fillRect(28,14,8,36),ti(t,{repeat:!1})})};var In=48,Ie=-1.55,Hl=class{constructor(t){this.nh=_i(t),this.nd=_i(t+101),this.np=_i(t+202),this.ns=_i(t+303),this.nc=_i(t+404),this.nw=_i(t+505)}pathMask(t,e){let i=t+18*this.nw(t*.01,e*.01),n=e+18*this.nw(e*.01+50,t*.01),r=this.np(i*.0042,n*.0042);return 1-Zi(.022,.05,Math.abs(r))}streamMask(t,e){let i=t+25*this.nw(t*.007+9,e*.007),n=this.ns(i*.0028+31.7,e*.0028-12.3);return 1-Zi(.014,.034,Math.abs(n))}clearing(t,e){return Zi(.35,.6,this.nc(t*.011,e*.011))}baseHeight(t,e){let i=xo(this.nh,t*.0055,e*.0055,4)*6.5,n=this.nd(t*.05,e*.05)*.35;return i+n+1.2}height(t,e){let i=this.baseHeight(t,e),n=this.pathMask(t,e);n>0&&(i-=n*.18);let r=this.streamMask(t,e);return r>0&&(i=De(i,Math.min(i,Ie-.85),r)),i}normal(t,e,i){let r=this.height(t+.6,e)-this.height(t-.6,e),o=this.height(t,e+.6)-this.height(t,e-.6);return i.set(-r,2*.6,-o).normalize(),i}isWater(t,e){return this.height(t,e)<Ie-.1}findDrySpot(t,e,i=80){let n=new T;for(let r=0;r<=i;r+=3){let o=Math.max(1,Math.floor(r*.8));for(let a=0;a<o;a++){let l=a/o*Math.PI*2,c=t+Math.cos(l)*r,h=e+Math.sin(l)*r;if(!(this.height(c,h)<Ie+.4)&&!(this.normal(c,h,n).y<.93))return{x:c,z:h}}}return{x:t,z:e}}},Ly=new _t(5208618),Dy=new _t(7049012),Uy=new _t(9407046),Ny=new _t(8018490),Fy=new _t(6177579),ky=new _t(7236194),By=new _t(4865840),Oy=new _t(3889698),hn=new _t,_o=new T;function Bf(s,t,e,i){let n=In,r=(i+1)*(i+1),o=new Float32Array(r*3),a=new Float32Array(r*3),l=new Float32Array(r*3),c=new Float32Array(r*2),h=t*n,u=e*n,f=1/0,d=-1/0;for(let p=0,M=0;p<=i;p++)for(let y=0;y<=i;y++,M++){let _=h+y/i*n,b=u+p/i*n,E=s.height(_,b);f=Math.min(f,E),d=Math.max(d,E),o[M*3]=_-h,o[M*3+1]=E,o[M*3+2]=b-u,s.normal(_,b,_o),a[M*3]=_o.x,a[M*3+1]=_o.y,a[M*3+2]=_o.z,c[M*2]=_*.22,c[M*2+1]=b*.22;let P=s.nd(_*.03,b*.03)*.5+.5;hn.copy(Ly).lerp(Dy,P);let L=Zi(.3,.8,s.nc(_*.02+7,b*.02));hn.lerp(Uy,L*.45),hn.lerp(Oy,s.clearing(_,b)<.1?.15:0);let w=s.pathMask(_,b);w>0&&hn.lerp(s.nd(_*.3,b*.3)>0?Ny:Fy,Zi(0,.6,w));let v=1-Zi(Ie+.1,Ie+1,E);v>0&&hn.lerp(By,v);let C=1-_o.y;C>.12&&hn.lerp(ky,Zi(.12,.3,C)),l[M*3]=hn.r,l[M*3+1]=hn.g,l[M*3+2]=hn.b}let g=new(r>65535?Uint32Array:Uint16Array)(i*i*6),x=0;for(let p=0;p<i;p++)for(let M=0;M<i;M++){let y=p*(i+1)+M,_=y+1,b=y+i+1,E=b+1;g[x++]=y,g[x++]=b,g[x++]=_,g[x++]=_,g[x++]=b,g[x++]=E}let m=new ue;return m.setAttribute("position",new ne(o,3)),m.setAttribute("normal",new ne(a,3)),m.setAttribute("color",new ne(l,3)),m.setAttribute("uv",new ne(c,2)),m.setIndex(new ne(g,1)),m.boundingBox=new We(new T(0,f,0),new T(n,d,n)),m.boundingSphere=new ri,m.boundingBox.getBoundingSphere(m.boundingSphere),m}var Xh=null;function Of(s){if(!Xh){let t={vertexColors:!0,map:ae.ground()};Xh=s?new je({...t,roughness:.96,metalness:0}):new an(t)}return Xh}function zf(){let s=new Ke(600,600,1,1);s.rotateX(-Math.PI/2);let t=new Xe({transparent:!0,fog:!0,depthWrite:!1,uniforms:Dl.merge([pt.fog,{uTime:{value:0},uDeep:{value:new _t(1919570)},uShallow:{value:new _t(5216928)},uSky:{value:new _t(12573162)}}]),vertexShader:`
      varying vec3 vWorld;
      #include <fog_pars_vertex>
      void main() {
        vec4 wp = modelMatrix * vec4(position, 1.0);
        vWorld = wp.xyz;
        vec4 mvPosition = viewMatrix * wp;
        gl_Position = projectionMatrix * mvPosition;
        #include <fog_vertex>
      }`,fragmentShader:`
      uniform float uTime; uniform vec3 uDeep; uniform vec3 uShallow; uniform vec3 uSky;
      varying vec3 vWorld;
      #include <fog_pars_fragment>
      float wave(vec2 p) {
        return sin(p.x * 1.7 + uTime * 1.3) * 0.5 + sin(p.y * 2.3 - uTime * 1.1) * 0.5
             + sin((p.x + p.y) * 3.1 + uTime * 2.0) * 0.25;
      }
      void main() {
        vec2 p = vWorld.xz;
        float e = 0.15;
        vec3 n = normalize(vec3(wave(p + vec2(e, 0.0)) - wave(p - vec2(e, 0.0)), 6.0, wave(p + vec2(0.0, e)) - wave(p - vec2(0.0, e))));
        vec3 v = normalize(cameraPosition - vWorld);
        float fres = pow(1.0 - max(dot(n, v), 0.0), 3.0);
        vec3 col = mix(uDeep, uShallow, 0.35 + 0.25 * n.x);
        col = mix(col, uSky, clamp(fres * 0.8 + 0.1, 0.0, 1.0));
        // sun glints from the perturbed normal (no regular pattern)
        vec3 h = normalize(normalize(vec3(0.45, 0.62, -0.64)) + v);
        float glint = pow(max(dot(n, h), 0.0), 220.0) * 0.6;
        gl_FragColor = vec4(col + glint, 0.82);
        #include <fog_fragment>
      }`}),e=new Et(s,t);return e.position.y=Ie,e.renderOrder=2,e}function Vf(s,t=!1){let e=s[0].index!==null,i=new Set(Object.keys(s[0].attributes)),n=new Set(Object.keys(s[0].morphAttributes)),r={},o={},a=s[0].morphTargetsRelative,l=new ue,c=0;for(let h=0;h<s.length;++h){let u=s[h],f=0;if(e!==(u.index!==null))return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+h+". All geometries must have compatible attributes; make sure index attribute exists among all geometries, or in none of them."),null;for(let d in u.attributes){if(!i.has(d))return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+h+'. All geometries must have compatible attributes; make sure "'+d+'" attribute exists among all geometries, or in none of them.'),null;r[d]===void 0&&(r[d]=[]),r[d].push(u.attributes[d]),f++}if(f!==i.size)return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+h+". Make sure all geometries have the same number of attributes."),null;if(a!==u.morphTargetsRelative)return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+h+". .morphTargetsRelative must be consistent throughout all geometries."),null;for(let d in u.morphAttributes){if(!n.has(d))return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+h+".  .morphAttributes must be consistent throughout all geometries."),null;o[d]===void 0&&(o[d]=[]),o[d].push(u.morphAttributes[d])}if(t){let d;if(e)d=u.index.count;else if(u.attributes.position!==void 0)d=u.attributes.position.count;else return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+h+". The geometry must have either an index or a position attribute"),null;l.addGroup(c,d,h),c+=d}}if(e){let h=0,u=[];for(let f=0;f<s.length;++f){let d=s[f].index;for(let g=0;g<d.count;++g)u.push(d.getX(g)+h);h+=s[f].attributes.position.count}l.setIndex(u)}for(let h in r){let u=Hf(r[h]);if(!u)return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed while trying to merge the "+h+" attribute."),null;l.setAttribute(h,u)}for(let h in o){let u=o[h][0].length;if(u===0)break;l.morphAttributes=l.morphAttributes||{},l.morphAttributes[h]=[];for(let f=0;f<u;++f){let d=[];for(let x=0;x<o[h].length;++x)d.push(o[h][x][f]);let g=Hf(d);if(!g)return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed while trying to merge the "+h+" morphAttribute."),null;l.morphAttributes[h].push(g)}}return l}function Hf(s){let t,e,i,n=-1,r=0;for(let c=0;c<s.length;++c){let h=s[c];if(t===void 0&&(t=h.array.constructor),t!==h.array.constructor)return console.error("THREE.BufferGeometryUtils: .mergeAttributes() failed. BufferAttribute.array must be of consistent array types across matching attributes."),null;if(e===void 0&&(e=h.itemSize),e!==h.itemSize)return console.error("THREE.BufferGeometryUtils: .mergeAttributes() failed. BufferAttribute.itemSize must be consistent across matching attributes."),null;if(i===void 0&&(i=h.normalized),i!==h.normalized)return console.error("THREE.BufferGeometryUtils: .mergeAttributes() failed. BufferAttribute.normalized must be consistent across matching attributes."),null;if(n===-1&&(n=h.gpuType),n!==h.gpuType)return console.error("THREE.BufferGeometryUtils: .mergeAttributes() failed. BufferAttribute.gpuType must be consistent across matching attributes."),null;r+=h.count*e}let o=new t(r),a=new ne(o,e,i),l=0;for(let c=0;c<s.length;++c){let h=s[c];if(h.isInterleavedBufferAttribute){let u=l/e;for(let f=0,d=h.count;f<d;f++)for(let g=0;g<e;g++){let x=h.getComponent(f,g);a.setComponent(f+u,g,x)}}else o.set(h.array,l);l+=h.count*e}return n!==void 0&&(a.gpuType=n),a}var Gf=new Ut,Wf=new _e,zy=new Re,qh=new T,Xf=new T,se=class{constructor(){this.parts=[]}add(t,e={}){let i=t.index?t.toNonIndexed():t.clone();if(i.attributes.uv||i.setAttribute("uv",new ne(new Float32Array(i.attributes.position.count*2),2)),e.jitter){let h=i.attributes.position,u=e.rng||Math.random,f=new Map;for(let d=0;d<h.count;d++){let g=`${h.getX(d).toFixed(3)},${h.getY(d).toFixed(3)},${h.getZ(d).toFixed(3)}`,x=f.get(g);x||(x=[(u()-.5)*e.jitter,(u()-.5)*e.jitter,(u()-.5)*e.jitter],f.set(g,x)),h.setXYZ(d,h.getX(d)+x[0],h.getY(d)+x[1],h.getZ(d)+x[2])}}if(e.matrix)i.applyMatrix4(e.matrix);else{let h=e.scale??1;Array.isArray(h)?qh.set(h[0],h[1],h[2]):qh.set(h,h,h);let u=e.rot||[0,0,0];Wf.setFromEuler(zy.set(u[0],u[1],u[2]));let f=e.pos||[0,0,0];Xf.set(f[0],f[1],f[2]),Gf.compose(Xf,Wf,qh),i.applyMatrix4(Gf)}(e.jitter||e.flat)&&i.computeVertexNormals();let n=i.attributes.position.count,r=new Float32Array(n*3),o=new _t(e.color??16777215),a=e.gradient,l=0,c=1;a&&(i.computeBoundingBox(),l=i.boundingBox.min.y,c=i.boundingBox.max.y);for(let h=0;h<n;h++){let u=1;if(a){let f=(i.attributes.position.getY(h)-l)/Math.max(1e-4,c-l);u=a[0]+(a[1]-a[0])*f}r[h*3]=o.r*u,r[h*3+1]=o.g*u,r[h*3+2]=o.b*u}i.setAttribute("color",new ne(r,3));for(let h of Object.keys(i.attributes))["position","normal","uv","color"].includes(h)||i.deleteAttribute(h);return this.parts.push({g:i,glow:!!e.glow,bone:e.bone??0}),this}build({groups:t=!1,skin:e=!1}={}){let i=t?[...this.parts.filter(r=>!r.glow),...this.parts.filter(r=>r.glow)]:this.parts;if(e)for(let r of i){let o=r.g.attributes.position.count,a=new Uint16Array(o*4),l=new Float32Array(o*4);for(let c=0;c<o;c++)a[c*4]=r.bone,l[c*4]=1;r.g.setAttribute("skinIndex",new Wn(a,4)),r.g.setAttribute("skinWeight",new Ht(l,4))}let n=Vf(i.map(r=>r.g),!1);if(n.clearGroups(),t){let r=0;for(let a of i)a.glow||(r+=a.g.attributes.position.count);n.addGroup(0,r,0);let o=n.attributes.position.count;o>r&&n.addGroup(r,o-r,1)}for(let r of this.parts)r.g.dispose();return n.computeBoundingSphere(),n.computeBoundingBox(),n}},R={box:(s=1,t=1,e=1,i=1,n=1,r=1)=>new oi(s,t,e,i,n,r),cyl:(s,t,e,i=10,n=1,r=!1)=>new Wi(s,t,e,i,n,r),cone:(s,t,e=10,i=1)=>new zr(s,t,e,i),sphere:(s,t=12,e=8)=>new ci(s,t,e),ico:(s,t=0)=>new jr(s,t),dodeca:(s,t=0)=>new Vr(s,t),capsule:(s,t,e=4,i=10)=>new Or(s,t,e,i),torus:(s,t,e=8,i=16,n=Math.PI*2)=>new eo(s,t,e,i,n),lathe:(s,t=12)=>new Qr(s.map(([e,i])=>new nt(e,i)),t)};var Zh={value:0};function qf(s,t){return s.onBeforeCompile=e=>{e.uniforms.uWind=Zh,e.vertexShader=`uniform float uWind;
`+e.vertexShader.replace("#include <begin_vertex>",`#include <begin_vertex>
       #ifdef USE_INSTANCING
         vec3 ip = vec3(instanceMatrix[3][0], instanceMatrix[3][1], instanceMatrix[3][2]);
       #else
         vec3 ip = vec3(0.0);
       #endif
       float sway = sin(uWind * 1.7 + ip.x * 0.37 + ip.z * 0.23) + 0.5 * sin(uWind * 3.1 + ip.z * 0.5);
       transformed.x += sway * ${t.toFixed(3)} * max(position.y, 0.0);
       transformed.z += sway * ${(t*.6).toFixed(3)} * max(position.y, 0.0);`)},s.customProgramCacheKey=()=>"wind"+t,s}function Yf(s,t){let e=me(t),i=new se,n=10.5;i.add(R.cyl(.12,.32,n*.75,s?7:5),{pos:[0,n*.375,0],color:5913894,gradient:[.7,1]});let r=s?6:3;for(let o=0;o<r;o++){let a=o/(r-1),l=2.9-a*2.1,c=3.4-a*1.2,h=2.6+a*(n-3.6);i.add(R.cone(l,c,s?9:6,s?2:1),{pos:[0,h+c*.5,0],rot:[0,e()*3,0],color:o%2?2050597:2381099,gradient:[.55,1.15],jitter:s?.35:.2,rng:e})}return i.build()}function Hy(s){let t=me(s),e=new se;e.add(R.cyl(.1,.2,3.6,6),{pos:[0,1.8,0],color:6047280});for(let i=0;i<5;i++){let n=t()*Math.PI*2,r=t()*.9;e.add(R.ico(1+t()*.5,1),{pos:[Math.cos(n)*r,3.6+t()*1.3,Math.sin(n)*r],color:t()>.5?5012010:4155942,gradient:[.6,1.2],jitter:.3,rng:t})}return e.build()}function Vy(s){let t=me(s),e=new se;e.add(R.cyl(.1,.3,7,6),{pos:[0,3.5,0],color:7035466,jitter:.06,rng:t});for(let i=0;i<6;i++){let n=2.5+t()*4,r=t()*Math.PI*2,o=1+t()*1.6;e.add(R.cyl(.03,.08,o,4),{pos:[Math.cos(r)*o*.4,n+o*.3,Math.sin(r)*o*.4],rot:[Math.sin(r)*.9,0,-Math.cos(r)*.9],color:7035466})}return e.build()}function Gy(s){let t=me(s),e=new se;for(let i=0;i<4;i++){let n=i/4*Math.PI*2+t();e.add(R.ico(.42+t()*.22,1),{pos:[Math.cos(n)*.38,.3+t()*.2,Math.sin(n)*.38],scale:[1,.8,1],color:t()>.5?5210160:4288295,gradient:[.55,1.25],jitter:.16,rng:t})}return e.build()}function Wy(s){let t=me(s),e=new se;for(let i=0;i<7;i++){let n=i/7*Math.PI*2+t()*.3;e.add(R.box(.18,.02,1.1),{pos:[Math.cos(n)*.45,.32,Math.sin(n)*.45],rot:[.5*Math.sin(n),-n+Math.PI/2,.5*-Math.cos(n)],color:5212716})}return e.build()}function Vl(s,t){let e=me(s),i=new se,n=7;for(let r=0;r<n;r++){let o=e()*Math.PI*2,a=.35+e()*.4,l=new ue;l.setAttribute("position",new Ht([-.04,0,0,.04,0,0,0,a,0],3)),l.setAttribute("normal",new Ht([0,.6,.8,0,.6,.8,0,1,0],3)),i.add(l,{pos:[Math.cos(o)*.15,0,Math.sin(o)*.15],rot:[(e()-.5)*.6,o,(e()-.5)*.6],color:e()>.5?7313973:8824892,gradient:[.45,1.15]})}if(t)for(let r=0;r<3;r++)i.add(R.ico(.05,0),{pos:[(e()-.5)*.3,.45+e()*.2,(e()-.5)*.3],color:t});return i.build()}function $h(s,t=1){let e=me(s),i=new se;i.add(R.dodeca(1,t),{scale:[1.2,.8,1],color:8223346,jitter:.35,rng:e,flat:!0});let n=i.build(),r=n.attributes.normal,o=n.attributes.color;for(let a=0;a<r.count;a++)r.getY(a)>.6&&o.setXYZ(a,o.getX(a)*.7,o.getY(a)*.95,o.getZ(a)*.55);return n}function Jh(){let s=new se;return s.add(R.cyl(.42,.5,7,10,3),{rot:[0,0,Math.PI/2],color:6965806,jitter:.05,rng:me(5)}),s.add(R.cyl(.36,.36,.05,10),{pos:[3.51,0,0],rot:[0,0,Math.PI/2],color:11569754}),s.add(R.cyl(.44,.44,.05,10),{pos:[-3.51,0,0],rot:[0,0,Math.PI/2],color:11569754}),s.add(R.box(1.8,.12,.6),{pos:[.5,.45,0],color:4153122,jitter:.08,rng:me(6)}),s.add(R.cyl(.05,.08,1.2,4),{pos:[-1.2,.6,.2],rot:[.6,0,.3],color:6965806}),s.build()}var Gl=null;function Xy(s){if(Gl)return Gl;let t=s.standardMaterials,e=l=>t?new je({roughness:.9,metalness:0,...l}):new an(l),i=e({vertexColors:!0,map:ae.fabric()}),n=e({vertexColors:!0,map:ae.bark()}),r=e({vertexColors:!0,map:ae.rock()}),o=qf(e({vertexColors:!0,side:Fe}),.12),a=qf(e({vertexColors:!0,map:ae.fabric()}),.03);return Gl={pineHi:Yf(!0,1),pineLo:Yf(!1,1),broadleaf:Hy(2),dead:Vy(3),bush:Gy(4),fern:Wy(5),grass:Vl(6),flowers:[Vl(7,15921894),Vl(8,15914042),Vl(9,11565784)],rock:$h(10),log:Jh(),leafMat:i,barkMat:n,rockMat:r,grassMat:o,bushMat:a},Gl}var qy=new Ut,Yh=new _e,Zf=new T,$f=new T,Yy=new T(0,1,0);function un(s,t,e,i){if(e.length===0)return null;let n=new Yn(s,t,e.length);for(let r=0;r<e.length;r++){let o=e[r];Yh.setFromAxisAngle(Yy,o.rot),o.tilt&&Yh.multiply(new _e().setFromEuler(new Re(o.tilt[0],0,o.tilt[1]))),$f.set(o.x,o.y,o.z),Zf.set(o.sx??o.s,o.sy??o.s,o.sz??o.s),n.setMatrixAt(r,qy.compose($f,Yh,Zf))}return n.instanceMatrix.needsUpdate=!0,n.computeBoundingSphere(),n.castShadow=i,n.receiveShadow=!0,n}function Jf(s,t,e,i,n){let r=Xy(e),o=me(s.seed^2654435769),a=s.cx*48,l=s.cz*48,c=[],h=[],u=[],f=[],d=[],g=[],x=[],m=[[],[],[]],p=(w,v,C=0)=>{if(t.pathMask(w,v)>.05||t.streamMask(w,v)>.02||t.height(w,v)<Ie+.1)return!1;for(let U of n){let O=w-U.x,z=v-U.z;if(O*O+z*z<(U.r+C)*(U.r+C))return!1}return!0},M=7;for(let w=0;w<48;w+=M)for(let v=0;v<48;v+=M){let C=a+w+o()*M,U=l+v+o()*M,O=t.clearing(C,U);if(o()>(.85-O*.8)*e.treeDensity||!p(C,U,1.5))continue;let z=t.height(C,U),q=o(),H=.75+o()*.6;q<.8?(c.push({x:C,y:z-.2,z:U,rot:o()*6.28,s:H}),i({x:C,z:U,r:.35*H,y0:z-1,y1:z+10*H,kind:"tree"})):q<.94?(h.push({x:C,y:z-.1,z:U,rot:o()*6.28,s:H}),i({x:C,z:U,r:.22*H,y0:z-1,y1:z+5*H,kind:"tree"})):(u.push({x:C,y:z-.1,z:U,rot:o()*6.28,s:H}),i({x:C,z:U,r:.28*H,y0:z-1,y1:z+7*H,kind:"tree"}))}let y=(w,v,C)=>{for(let U=0;U<w;U++){let O=a+o()*48,z=l+o()*48;p(O,z)&&C(O,t.height(O,z),z,v)}};if(y(Math.round(7*e.bushDensity),x,(w,v,C)=>{let U=.4+o()*1.3;x.push({x:w,y:v+.1*U,z:C,rot:o()*6.28,s:U,tilt:[o()*.3,o()*.3]}),U>.6&&i({x:w,z:C,r:1.05*U,y0:v-1,y1:v+.9*U,kind:"rock"})}),y(Math.round(26*e.bushDensity),f,(w,v,C)=>f.push({x:w,y:v-.05,z:C,rot:o()*6.28,s:.55+o()*.5})),y(Math.round(18*e.bushDensity),d,(w,v,C)=>d.push({x:w,y:v,z:C,rot:o()*6.28,s:.7+o()*.6})),e.grassDensity>0){let w=Math.round(420*e.grassDensity);for(let v=0;v<w;v++){let C=a+o()*48,U=l+o()*48;if(t.pathMask(C,U)>.4||t.streamMask(C,U)>.3)continue;let O=t.height(C,U);O<Ie+.15||(o()<.06?m[Math.floor(o()*3)].push({x:C,y:O,z:U,rot:o()*6.28,s:.8+o()*.5}):g.push({x:C,y:O,z:U,rot:o()*6.28,s:.8+o()*.8}))}}let _=new fe,b=[],E=e.shadows,P=un(r.pineHi,r.leafMat,c,E),L=un(r.pineLo,r.leafMat,c,E);P&&(_.add(P),_.add(L),L.visible=!1);for(let w of[un(r.broadleaf,r.leafMat,h,E),un(r.dead,r.barkMat,u,E),un(r.rock,r.rockMat,x,E)])w&&_.add(w);for(let w of[un(r.bush,r.bushMat,f,!1),un(r.fern,r.bushMat,d,!1),un(r.grass,r.grassMat,g,!1),...m.map((v,C)=>un(r.flowers[C],r.grassMat,v,!1))])w&&(_.add(w),b.push(w));return{group:_,detail:b,hi:P,lo:L}}var Wl=null;function Zy(s){if(Wl)return Wl;let t=b=>{if(s)return new je({roughness:.85,metalness:0,...b});let{roughness:E,metalness:P,...L}=b;return new an(L)},e=t({vertexColors:!0,map:ae.wood()}),i=t({vertexColors:!0,map:ae.metal()}),n=t({vertexColors:!0,map:ae.rock()}),r=new ye({vertexColors:!0,toneMapped:!1}),o=new oi(1.2,1.2,1.2),a=t({map:ae.crate()}),l=new Wi(.42,.42,1.25,16,1),c=t({map:ae.barrel(),roughness:.5,metalness:.3}),h=t({color:10099216,roughness:.5,metalness:.3}),u=new se;for(let b=0;b<3;b++)u.add(R.cyl(.16,.16,3.6,8),{pos:[0,.3+b*.36,0],rot:[0,0,Math.PI/2],color:b%2?8017460:6965804});for(let b of[-1.5,1.5])u.add(R.cyl(.12,.12,2,6),{pos:[b,.7,.25],rot:[.5,0,.35],color:6045736}),u.add(R.cyl(.12,.12,2,6),{pos:[b,.7,-.25],rot:[-.5,0,-.35],color:6045736});u.add(R.box(.08,.1,3.4),{pos:[0,.66,0],rot:[0,Math.PI/2,.25],color:9408399});let f=new se;f.add(R.box(2,.12,2),{pos:[0,.06,0],color:5914148});let d=me(77);for(let b=0;b<16;b++){let E=-.75+b%4*.5+(d()-.5)*.1,P=-.75+Math.floor(b/4)*.5+(d()-.5)*.1;f.add(R.cone(.09,.85+d()*.3,5),{pos:[E,.5,P],rot:[(d()-.5)*.25,0,(d()-.5)*.25],color:9071172,gradient:[.8,1.3]})}let g=new se;g.add(R.cyl(.36,.42,.14,16),{pos:[0,.07,0],color:3951148}),g.add(R.cyl(.24,.3,.08,16),{pos:[0,.17,0],color:5660732}),g.add(R.cyl(.06,.06,.06,8),{pos:[0,.23,0],color:2236962});for(let b=0;b<6;b++){let E=b/6*Math.PI*2;g.add(R.box(.05,.05,.05),{pos:[Math.cos(E)*.3,.16,Math.sin(E)*.3],color:2763306})}let x=new se;x.add(R.sphere(.045,8,6),{pos:[.12,.23,0],color:16722458,glow:!0});let m=new se;for(let[b,E]of[[-1.4,-1.4],[1.4,-1.4],[-1.4,1.4],[1.4,1.4]])m.add(R.cyl(.14,.18,7.2,7),{pos:[b*.92,3.6,E*.92],rot:[E*.03,0,-b*.03],color:6045736});for(let b of[1.6,3.8])m.add(R.box(.1,.1,3.8),{pos:[-1.3,b,0],rot:[.75,0,0],color:6965804}),m.add(R.box(.1,.1,3.8),{pos:[1.3,b,0],rot:[-.75,0,0],color:6965804}),m.add(R.box(3.8,.1,.1),{pos:[0,b,-1.3],rot:[0,0,.75],color:6965804}),m.add(R.box(3.8,.1,.1),{pos:[0,b,1.3],rot:[0,0,-.75],color:6965804});m.add(R.box(3.6,.2,3.6),{pos:[0,6.2,0],color:8017460});for(let b of[-1,1])m.add(R.box(3.6,.9,.08),{pos:[0,6.75,b*1.76],color:6965804}),m.add(R.box(.08,.9,3.6),{pos:[b*1.76,6.75,0],color:6965804});for(let[b,E]of[[-1.7,-1.7],[1.7,-1.7],[-1.7,1.7],[1.7,1.7]])m.add(R.cyl(.07,.07,2.4,5),{pos:[b,7.4,E],color:6045736});m.add(R.cone(3.1,1.6,4),{pos:[0,9.3,0],rot:[0,Math.PI/4,0],color:4864554});for(let b=0;b<9;b++)m.add(R.box(.7,.07,.07),{pos:[0,.6+b*.7,1.85],color:8017460});m.add(R.box(.07,6.6,.07),{pos:[-.35,3.3,1.85],color:6045736}),m.add(R.box(.07,6.6,.07),{pos:[.35,3.3,1.85],color:6045736});let p=new se,M=me(91);for(let b=0;b<9;b++){let E=Math.PI*.15+b/8*Math.PI*.7;p.add(R.dodeca(1.9+M()*.9,1),{pos:[Math.cos(E)*3.6,1+M()*1.4,-Math.sin(E)*2-1.2],scale:[1,1.2,1],color:6973022,jitter:.7,rng:M,flat:!0})}p.add(R.dodeca(3.4,1),{pos:[0,3.6,-2.4],scale:[1.4,.75,1],color:6446678,jitter:.8,rng:M,flat:!0}),p.add(R.dodeca(2.6,1),{pos:[0,1.8,-4.4],scale:[1.6,1.1,1],color:5591627,jitter:.6,rng:M,flat:!0});let y=new se;y.add(R.sphere(1.6,16,10),{pos:[0,1.2,-2.2],scale:[1.2,1,.25],color:662058,glow:!0});for(let b=0;b<7;b++)y.add(R.cone(.18+M()*.15,.8+M()*.8,5),{pos:[(M()-.5)*3,.3+M()*.6,-1.6-M()*.6],rot:[(M()-.5)*.8,0,(M()-.5)*.8],color:5232895,glow:!0});let _=new se;for(let b=0;b<18;b++)_.add(R.box(.72,.12,3.2),{pos:[-6.2+b*.73,0,0],rot:[0,0,(d()-.5)*.04],color:b%3?8017460:6965804});for(let b of[-1,1]){_.add(R.box(13.2,.18,.2),{pos:[0,-.12,b*1.2],color:6045736}),_.add(R.box(13.2,.12,.12),{pos:[0,1,b*1.55],color:6965804});for(let E=0;E<7;E++)_.add(R.box(.14,1.1,.14),{pos:[-6+E*2,.5,b*1.55],color:6045736});for(let E of[-5.5,0,5.5])_.add(R.cyl(.18,.2,3.6,7),{pos:[E,-1.8,b*1.4],color:4863008})}return Wl={wood:e,plain:i,rock:n,glow:r,crateGeo:o,crateMat:a,barrelGeo:l,barrelSide:c,barrelCap:h,barricade:u.build(),spikes:f.build(),mine:g.build(),mineLight:x.build(),tower:m.build(),cave:p.build(),caveGlow:y.build(),bridge:_.build(),log:Jh(),boulder:$h(55,1)},Wl}function Kh(s,t){let e=Zy(t),i;switch(s){case"crate":i=new Et(e.crateGeo,e.crateMat),i.position.y=.6;break;case"barrel":{i=new Et(e.barrelGeo,[e.barrelSide,e.barrelCap,e.barrelCap]),i.position.y=.62;break}case"barricade":i=new Et(e.barricade,e.wood);break;case"spikes":i=new Et(e.spikes,e.wood);break;case"mine":{i=new fe,i.add(new Et(e.mine,e.plain));let r=new Et(e.mineLight,e.glow);r.name="light",i.add(r);break}case"tower":i=new Et(e.tower,e.wood);break;case"cave":{i=new fe,i.add(new Et(e.cave,e.rock)),i.add(new Et(e.caveGlow,e.glow));break}case"bridge":i=new Et(e.bridge,e.wood);break;case"log":i=new Et(e.log,e.wood);break;case"boulder":i=new Et(e.boulder,e.rock);break;default:throw new Error("unknown prop "+s)}i.traverse(r=>{r.isMesh&&(r.castShadow=s!=="mine"&&s!=="spikes",r.receiveShadow=!0)});let n=new fe;return n.add(i),n}var Ye=4,jh=(s,t)=>(s+32768)*65536+(t+32768),Xl=class{constructor(){this.cells=new Map,this.decks=new Set,this._stamp=0,this._nextId=1}add(t){t.id=this._nextId++,t._stamp=0;let e=Math.floor((t.x-t.r)/Ye),i=Math.floor((t.x+t.r)/Ye),n=Math.floor((t.z-t.r)/Ye),r=Math.floor((t.z+t.r)/Ye);t._cells=[];for(let o=e;o<=i;o++)for(let a=n;a<=r;a++){let l=jh(o,a),c=this.cells.get(l);c||(c=[],this.cells.set(l,c)),c.push(t),t._cells.push(l)}return t}remove(t){if(t._cells){for(let e of t._cells){let i=this.cells.get(e);if(!i)continue;let n=i.indexOf(t);n>=0&&(i[n]=i[i.length-1],i.pop()),i.length===0&&this.cells.delete(e)}t._cells=null}}query(t,e,i,n){let r=++this._stamp,o=Math.floor((t-i)/Ye),a=Math.floor((t+i)/Ye),l=Math.floor((e-i)/Ye),c=Math.floor((e+i)/Ye);for(let h=o;h<=a;h++)for(let u=l;u<=c;u++){let f=this.cells.get(jh(h,u));if(f)for(let d=0;d<f.length;d++){let g=f[d];if(g._stamp!==r&&(g._stamp=r,n(g)===!1))return}}}resolve(t,e,i=1.8){let n=!1;return this.query(t.x,t.z,e+2,r=>{if(t.y+i<r.y0||t.y>r.y1-.05)return;let o=t.x-r.x,a=t.z-r.z,l=e+r.r,c=o*o+a*a;if(c<l*l){let h=Math.sqrt(c)||1e-4,u=l-h;t.x+=o/h*u,t.z+=a/h*u,n=!0}}),n}blocked(t,e,i){let n=!1;return this.query(t,e,i+2,r=>{let o=t-r.x,a=e-r.z,l=i+r.r;if(o*o+a*a<l*l)return n=!0,!1}),n}raycast(t,e,i,n,r,o,a,l){let c=a,h=null,u=++this._stamp,f=Math.floor(t/Ye),d=Math.floor(i/Ye),g=n>0?1:-1,x=o>0?1:-1,m=Math.abs(n)>1e-9?Ye/Math.abs(n):1/0,p=Math.abs(o)>1e-9?Ye/Math.abs(o):1/0,M=Math.abs(n)>1e-9?(n>0?(f+1)*Ye-t:t-f*Ye)/Math.abs(n):1/0,y=Math.abs(o)>1e-9?(o>0?(d+1)*Ye-i:i-d*Ye)/Math.abs(o):1/0,_=0;for(let b=0;b<512&&_<=c+Ye*1.5;b++){for(let E=-1;E<=1;E++)for(let P=-1;P<=1;P++){let L=this.cells.get(jh(f+E,d+P));if(L)for(let w=0;w<L.length;w++){let v=L[w];if(v._stamp===u||(v._stamp=u,l&&!l(v)))continue;let C=kf(t,e,i,n,r,o,v.x,v.z,v.r,v.y0,v.y1);C>=0&&C<c&&(c=C,h=v)}}M<y?(_=M,M+=m,f+=g):(_=y,y+=p,d+=x)}return h?{t:c,collider:h}:null}addDeck(t){return this.decks.add(t),t}removeDeck(t){this.decks.delete(t)}deckHeight(t,e,i){let n=-1/0;for(let r of this.decks){let o=t-r.x,a=e-r.z,l=o*r.dirX+a*r.dirZ,c=-o*r.dirZ+a*r.dirX;Math.abs(l)<=r.halfLen&&Math.abs(c)<=r.halfWidth&&r.y<=i+.9&&r.y>n&&(n=r.y)}return n}};var ql=class{constructor(t,e,i){this.scene=t,this.quality=e,this.seed=i,this.field=new Hl(i),this.colliders=new Xl,this.chunks=new Map,this.props=[],this.caves=[],this.destroyed=new Set,this.collected=new Set,this.water=zf(),t.add(this.water),this.onPropSpawned=null,this.onPickupSpawned=null,this.onChunkUnloaded=null,this.center={cx:1e9,cz:1e9},this.spawnSafe={x:0,z:0,r:14},this._queue=[]}height(t,e){return this.field.height(t,e)}groundHeight(t,e,i=1/0){let n=this.field.height(t,e),r=this.colliders.deckHeight(t,e,i);return r>n?r:n}isWater(t,e){return this.groundHeight(t,e)<Ie-.1}raycastTerrain(t,e,i){let n=1,r=.2,o=0;if(!(t.y-this.field.height(t.x,t.z)>0))return 0;for(;r<=i;){let l=t.x+e.x*r,c=t.y+e.y*r,h=t.z+e.z*r;if(!(c-this.field.height(l,h)>0)){let f=o,d=r;for(let g=0;g<6;g++){let x=(f+d)*.5;t.y+e.y*x-this.field.height(t.x+e.x*x,t.z+e.z*x)>0?f=x:d=x}return d}o=r,r+=n,r>20&&(n=2)}return-1}warmup(t,e){this.update(new T(t,0,e),!0)}update(t,e=!1){let i=Math.floor(t.x/In),n=Math.floor(t.z/In);this.water.position.x=Math.round(t.x/50)*50,this.water.position.z=Math.round(t.z/50)*50;let r=this.quality.viewChunks;if(i!==this.center.cx||n!==this.center.cz){this.center={cx:i,cz:n};let a=[];for(let l=-r;l<=r;l++)for(let c=-r;c<=r;c++){let h=`${i+c},${n+l}`;this.chunks.has(h)||a.push({cx:i+c,cz:n+l,d:c*c+l*l})}a.sort((l,c)=>l.d-c.d),this._queue=a;for(let[l,c]of this.chunks)(Math.abs(c.cx-i)>r+1||Math.abs(c.cz-n)>r+1)&&this._unload(l,c);for(let l of this.chunks.values())this._applyLod(l)}let o=e?1/0:1;for(;o-- >0&&this._queue.length;){let a=this._queue.shift(),l=`${a.cx},${a.cz}`;if(!this.chunks.has(l)){let c=this._build(a.cx,a.cz);this.chunks.set(l,c),this._applyLod(c)}}}_applyLod(t){let i=Math.max(Math.abs(t.cx-this.center.cx),Math.abs(t.cz-this.center.cz))<=1;t.foliage.hi&&(t.foliage.hi.visible=i,t.foliage.lo.visible=!i);for(let n of t.foliage.detail)n.visible=i}_build(t,e){let i=Ff(t,e,this.seed),n={cx:t,cz:e,seed:i,key:`${t},${e}`,colliders:[],decks:[],props:[],group:new fe},r=t*In,o=e*In,a=new Et(Bf(this.field,t,e,this.quality.terrainRes),Of(this.quality.standardMaterials));a.position.set(r,0,o),a.receiveShadow=!0,n.group.add(a);let l=y=>(y.chunk=n.key,n.colliders.push(this.colliders.add(y)),y),c=me(i),h=[];Math.hypot(this.spawnSafe.x-(r+24),this.spawnSafe.z-(o+24))<60&&h.push({x:this.spawnSafe.x,z:this.spawnSafe.z,r:4});let u=this.field,f=this.quality.standardMaterials,d=(y,_,b,E,P={})=>{let L=u.height(_,b),w=Kh(y,f);return w.position.set(_,L,b),w.rotation.y=E,n.group.add(w),{obj:w,y:L}},g=(y,_)=>{for(let b=0;b<12;b++){let E=r+4+c()*40,P=o+4+c()*40,L=u.pathMask(E,P);if(y===!0&&L<.3||y===!1&&L>.05||u.streamMask(E,P)>.02||u.height(E,P)<Ie+.3)continue;let w=!1;for(let v of h)Math.hypot(E-v.x,P-v.z)<v.r+_&&(w=!0);if(Math.hypot(E-this.spawnSafe.x,P-this.spawnSafe.z)<this.spawnSafe.r&&(w=!0),!w)return h.push({x:E,z:P,r:_}),{x:E,z:P}}return null};for(let y=0;y<64&&n.decks.length===0;y++){let _=r+y%8*6+3,b=o+Math.floor(y/8)*6+3;if(u.pathMask(_,b)>.6&&u.streamMask(_,b)>.8){let P=u.pathMask(_+1.5,b)-u.pathMask(_-1.5,b),w=-(u.pathMask(_,b+1.5)-u.pathMask(_,b-1.5)),v=P,C=Math.hypot(w,v);C<1e-4?(w=1,v=0):(w/=C,v/=C);let U=u.streamMask(_+w*6,b+v*6);if(u.streamMask(_-v*6,b+w*6)<U){let ct=w;w=-v,v=ct}let z=u.height(_+w*6.6,b+v*6.6),q=u.height(_-w*6.6,b-v*6.6),H=Math.max(z,q,Ie+.5)+.12,it=Kh("bridge",f);it.position.set(_,H-.06,b),it.rotation.y=Math.atan2(-v,w),n.group.add(it);let X={x:_,z:b,dirX:w,dirZ:v,halfLen:6.6,halfWidth:1.5,y:H};n.decks.push(this.colliders.addDeck(X)),h.push({x:_,z:b,r:8});for(let ct of[-1,1])for(let mt=-3;mt<=3;mt++)l({x:_+w*mt*2-v*ct*1.6,z:b+v*mt*2+w*ct*1.6,r:.15,y0:H-3,y1:H+1.1,kind:"rail"})}}if(c()<.12){let y=g(!1,5);if(y){let{y:_}=d("tower",y.x,y.z,c()*6.28);for(let[b,E]of[[-1.3,-1.3],[1.3,-1.3],[-1.3,1.3],[1.3,1.3]])l({x:y.x+b,z:y.z+E,r:.25,y0:_-1,y1:_+9,kind:"wood"})}}if(c()<.07){let y=g(!1,8);if(y){let _=c()*6.28,{y:b}=d("cave",y.x,y.z,_),E=Math.cos(_),P=Math.sin(_),L=(v,C)=>({x:y.x+v*E+C*P,z:y.z-v*P+C*E});for(let[v,C,U]of[[-3.6,-1.6,2],[3.6,-1.6,2],[-2.4,-3.4,2],[2.4,-3.4,2],[0,-4.4,2.6]]){let O=L(v,C);l({x:O.x,z:O.z,r:U,y0:b-1,y1:b+5,kind:"rock"})}let w=L(0,.5);this.caves.push({x:w.x,z:w.z,chunk:n.key})}}let x=c()<.5?1:0;for(let y=0;y<x;y++){let _=g(!1,4);if(!_)continue;let b=c()*6.28,{obj:E,y:P}=d("log",_.x,_.z,b);E.position.y=P+.35;for(let L=-3;L<=3;L+=1.5)l({x:_.x+Math.cos(b)*L,z:_.z-Math.sin(b)*L,r:.5,y0:P-1,y1:P+.85,kind:"wood"})}if(c()<.35){let y=g(!1,3);if(y){let{obj:_,y:b}=d("boulder",y.x,y.z,c()*6.28),E=1.3+c()*.8;_.scale.setScalar(E),l({x:y.x,z:y.z,r:1.15*E,y0:b-1,y1:b+.8*E,kind:"rock"})}}let m=(y,_,b,E,P={})=>{let L=`${n.key}:${n.props.length}:${y}`;if(this.destroyed.has(L))return n.props.push(null),null;let{obj:w,y:v}=d(y,_.x,_.z,b),C={id:L,type:y,x:_.x,y:v,z:_.z,obj:w,alive:!0,chunk:n.key,...P};return E&&(C.collider=l({x:_.x,z:_.z,...E(v),kind:y,prop:C})),n.props.push(C),this.props.push(C),this.onPropSpawned&&this.onPropSpawned(C),C},p=c()<.55?1+Math.floor(c()*3):0,M=p?g(!1,3):null;if(M)for(let y=0;y<p;y++){let _={x:M.x+y%2*1.3-.6,z:M.z+Math.floor(y/2)*1.3-.6};m("crate",_,c()*.4,b=>({r:.72,y0:b-1,y1:b+1.2}),{hp:45})}if(c()<.4){let y=g(null,2);y&&m("barrel",y,c()*6.28,_=>({r:.45,y0:_-1,y1:_+1.25}),{hp:25})}if(c()<.32){let y=g(!0,4)||g(!1,4);if(y){let _=c()*6.28,b=m("barricade",y,_,null,{hp:1/0});if(b)for(let E=-1.6;E<=1.6;E+=.8)l({x:y.x+Math.cos(_)*E,z:y.z-Math.sin(_)*E,r:.32,y0:b.y-1,y1:b.y+1.15,kind:"barricade"})}}if(c()<.28){let y=g(null,2.5);y&&m("spikes",y,c()*6.28,null,{radius:1.15,tick:0})}if(c()<.3){let y=g(!0,2)||g(!1,2);y&&m("mine",y,c()*6.28,null,{radius:1,armed:!0,fuse:-1})}if(c()<.22&&this.onPickupSpawned){let y=g(null,1.5),_=`${n.key}:pickup`;if(y&&!this.collected.has(_)){let b=c.pick(["ammo","health","ammo","armor","grenade","coin"]);this.onPickupSpawned(b,new T(y.x,u.height(y.x,y.z),y.z),_)}}return n.foliage=Jf(n,u,this.quality,l,h),n.group.add(n.foliage.group),this.scene.add(n.group),n}_unload(t,e){this.scene.remove(e.group),e.group.traverse(i=>{i.isInstancedMesh?i.dispose():i.isMesh&&i.geometry&&i.geometry.attributes.color&&i.geometry.attributes.uv&&i.parent===e.group&&i.geometry.dispose()});for(let i of e.colliders)this.colliders.remove(i);for(let i of e.decks)this.colliders.removeDeck(i);for(let i of e.props)i&&(i.alive=!1,i.unloaded=!0);this.props=this.props.filter(i=>!i.unloaded),this.caves=this.caves.filter(i=>i.chunk!==t),this.onChunkUnloaded&&this.onChunkUnloaded(e),this.chunks.delete(t)}destroyProp(t){t.alive&&(t.alive=!1,this.destroyed.add(t.id),t.collider&&this.colliders.remove(t.collider),t.obj.parent&&t.obj.parent.remove(t.obj))}validSpawn(t,e,i=.8){if(this.field.height(t,e)<Ie+.2||this.colliders.blocked(t,e,i))return!1;let n=this.quality.viewChunks,r=Math.floor(t/In),o=Math.floor(e/In);return Math.abs(r-this.center.cx)>n||Math.abs(o-this.center.cz)>n?!1:this.chunks.has(`${r},${o}`)}};var Ei={top:new _t(6132687),horizon:new _t(13032422),fog:new _t(11454676),sunDir:new T(.45,.62,-.64).normalize()};function Kf(){let s=new fe,t=new Et(new ci(900,32,16),new Xe({side:qe,depthWrite:!1,fog:!1,uniforms:{uTop:{value:Ei.top},uHorizon:{value:Ei.horizon},uSun:{value:Ei.sunDir}},vertexShader:"varying vec3 vDir; void main(){ vDir = normalize(position); gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0); gl_Position.z = gl_Position.w; }",fragmentShader:`
        uniform vec3 uTop; uniform vec3 uHorizon; uniform vec3 uSun; varying vec3 vDir;
        void main(){
          float h = clamp(vDir.y, -0.2, 1.0);
          vec3 col = mix(uHorizon, uTop, pow(max(h, 0.0), 0.55));
          float s = max(dot(normalize(vDir), uSun), 0.0);
          col += vec3(1.0, 0.92, 0.75) * (pow(s, 600.0) * 2.5 + pow(s, 12.0) * 0.25);
          // soft clouds
          vec2 p = vDir.xz / max(vDir.y, 0.08) * 1.4;
          float c = sin(p.x * 1.3 + sin(p.y * 0.7)) * sin(p.y * 1.1 + sin(p.x * 0.9)) ;
          c = smoothstep(0.35, 0.9, c) * smoothstep(0.02, 0.3, vDir.y) * 0.35;
          col = mix(col, vec3(1.0), c);
          gl_FragColor = vec4(col, 1.0);
        }`}));t.renderOrder=-10,t.frustumCulled=!1,s.add(t);let e=_i(4242),i=(n,r,o,a,l=160)=>{let c=[],h=[];for(let m=0;m<=l;m++){let p=m/l*Math.PI*2,M=xo(e,Math.cos(p)*2+a,Math.sin(p)*2+a,5),y=Math.max(.1,.55+M*.9),_=Math.cos(p)*n,b=Math.sin(p)*n;if(c.push(_,-40,b,_,r*y,b),m<l){let E=m*2;h.push(E,E+2,E+1,E+1,E+2,E+3)}}let u=new ue;u.setAttribute("position",new Ht(c,3)),u.setIndex(h);let f=[],d=new _t(o).lerp(Ei.horizon,.35),g=new _t(o).lerp(new _t(15265522),.25);for(let m=0;m<c.length/3;m++){let p=c[m*3+1],M=Math.max(0,p/r),y=d.clone().lerp(g,M>.75?.9:M*.4);f.push(y.r,y.g,y.b)}u.setAttribute("color",new Ht(f,3));let x=new Et(u,new ye({vertexColors:!0,fog:!1,side:Fe,depthWrite:!1}));return x.renderOrder=-9,x.frustumCulled=!1,x};return s.add(i(720,210,7308436,3.1)),s.add(i(560,110,5599322,7.7)),s}var $y=`
  attribute vec3 aVel;
  attribute vec4 aColor;
  attribute vec4 aParams; // birth, life, size0, size1
  attribute float aGrav;
  uniform float uTime;
  uniform float uScale;
  varying vec4 vColor;
  varying float vAge;
  void main() {
    float age = (uTime - aParams.x) / aParams.y;
    if (age < 0.0 || age > 1.0) { gl_Position = vec4(2.0, 2.0, 2.0, 1.0); gl_PointSize = 0.0; return; }
    float t = uTime - aParams.x;
    // velocity drag
    vec3 p = position + aVel * (1.0 - exp(-2.2 * t)) / 2.2 + vec3(0.0, -0.5 * aGrav * t * t, 0.0);
    vec4 mv = modelViewMatrix * vec4(p, 1.0);
    gl_Position = projectionMatrix * mv;
    float size = mix(aParams.z, aParams.w, age);
    gl_PointSize = size * uScale / max(0.1, -mv.z);
    vColor = aColor;
    vAge = age;
  }`,Jy=`
  varying vec4 vColor;
  varying float vAge;
  uniform float uSoft;
  void main() {
    vec2 c = gl_PointCoord - 0.5;
    float d = length(c) * 2.0;
    float a = smoothstep(1.0, uSoft, d);
    float fade = 1.0 - smoothstep(0.55, 1.0, vAge);
    gl_FragColor = vec4(vColor.rgb, vColor.a * a * fade);
    if (gl_FragColor.a < 0.01) discard;
  }`,yo=class{constructor(t,e){this.capacity=t,this.cursor=0,this.time=0;let i=new ue;this.pos=new Float32Array(t*3),this.vel=new Float32Array(t*3),this.col=new Float32Array(t*4),this.par=new Float32Array(t*4).fill(-1e3),this.grav=new Float32Array(t),this.attrs={position:new ne(this.pos,3),aVel:new ne(this.vel,3),aColor:new ne(this.col,4),aParams:new ne(this.par,4),aGrav:new ne(this.grav,1)};for(let[r,o]of Object.entries(this.attrs))o.setUsage(mh),i.setAttribute(r,o);this.uniforms={uTime:{value:0},uScale:{value:300},uSoft:{value:e?0:.3}};let n=new Xe({vertexShader:$y,fragmentShader:Jy,uniforms:this.uniforms,transparent:!0,depthWrite:!1,blending:e?ke:Ui});this.points=new Nr(i,n),this.points.frustumCulled=!1,this.points.renderOrder=e?5:4,this.dirtyMin=1/0,this.dirtyMax=-1}emit(t,e,i,n,r,o,a,l,c,h,u,f,d,g=0){let x=this.cursor;this.cursor=(this.cursor+1)%this.capacity,this.pos[x*3]=t,this.pos[x*3+1]=e,this.pos[x*3+2]=i,this.vel[x*3]=n,this.vel[x*3+1]=r,this.vel[x*3+2]=o,this.col[x*4]=a,this.col[x*4+1]=l,this.col[x*4+2]=c,this.col[x*4+3]=h,this.par[x*4]=this.time,this.par[x*4+1]=u,this.par[x*4+2]=f,this.par[x*4+3]=d,this.grav[x]=g,x<this.dirtyMin&&(this.dirtyMin=x),x>this.dirtyMax&&(this.dirtyMax=x)}update(t,e,i){if(this.time+=t,this.uniforms.uTime.value=this.time,this.uniforms.uScale.value=e/(2*Math.tan(i*Math.PI/360)),this.dirtyMax>=0){let n=this.dirtyMin,r=this.dirtyMax-this.dirtyMin+1;for(let[o,a]of Object.entries(this.attrs)){let l=o==="aGrav"?1:o==="position"||o==="aVel"?3:4;a.clearUpdateRanges(),a.addUpdateRange(n*l,r*l),a.needsUpdate=!0}this.dirtyMin=1/0,this.dirtyMax=-1}}};var jf={dirt:[[.42,.32,.2],[.55,.45,.3]],rock:[[.55,.53,.5],[.7,.68,.64]],wood:[[.5,.33,.18],[.65,.48,.3]],metal:[[.6,.6,.6],[.9,.9,.9]],water:[[.7,.85,.95],[.9,.95,1]]},Ft=new T,Qf=new _e,Vb=new T(0,0,1),Yl=class{constructor(t,e){this.scene=t,this.quality=e;let i=e.particles;this.add=new yo(i,!0),this.alpha=new yo(Math.round(i*.75),!1),t.add(this.add.points,this.alpha.points),this.mul=e.particles/4e3+.4;let n=new ye({map:ae.muzzle(),transparent:!0,blending:ke,depthWrite:!1,side:Fe,toneMapped:!1});this.flashes=[];for(let f=0;f<3;f++){let d=new fe,g=new Et(new Ke(.22,.6),n);g.position.z=.25,g.rotation.x=Math.PI/2;let x=new Et(new Ke(.6,.22),n);x.position.z=.25,x.rotation.y=Math.PI/2;let m=new Et(new Ke(.42,.42),n);d.add(g,x,m),d.visible=!1,d.userData.t=0,d.renderOrder=6,t.add(d),this.flashes.push(d)}this.flashIdx=0,this.lightsOn=e.standardMaterials,this.muzzleLight=new Os(16752704,0,9,2),this.boomLight=new Os(16742944,0,22,2),this.lightsOn&&t.add(this.muzzleLight,this.boomLight);let r=new oi(.035,.035,1);r.translate(0,0,-.5);let o=new ye({color:16762976,transparent:!0,opacity:.9,blending:ke,depthWrite:!1,toneMapped:!1});this.tracers=[];for(let f=0;f<40;f++){let d=new Et(r,o);d.visible=!1,d.userData={from:new T,to:new T,t:0,dur:0,len:3},t.add(d),this.tracers.push(d)}this.trIdx=0;let a=new Wi(.008,.008,.035,6);a.rotateX(Math.PI/2),this.shellMesh=new Yn(a,new je({color:13148224,metalness:.9,roughness:.3}),48),this.shellMesh.frustumCulled=!1,this.shells=[];for(let f=0;f<48;f++)this.shells.push({p:new T,v:new T,r:new Re,w:new T,t:99,s:1,bounced:!1});this.shellIdx=0,this.shellMesh.count=48,t.add(this.shellMesh),this.onShellLand=null;let l=new Ke(1,1);l.rotateX(-Math.PI/2),this.decals=[];let c=new ye({map:ae.scorch(),transparent:!0,depthWrite:!1,polygonOffset:!0,polygonOffsetFactor:-2});for(let f=0;f<14;f++){let d=new Et(l,c.clone());d.visible=!1,d.renderOrder=1,t.add(d),this.decals.push({m:d,t:0,life:0})}this.decalIdx=0;let h=new to(.85,1,48);h.rotateX(-Math.PI/2),this.rings=[];for(let f=0;f<4;f++){let d=new Et(h,new ye({color:6743807,transparent:!0,blending:ke,depthWrite:!1,side:Fe,toneMapped:!1}));d.visible=!1,t.add(d),this.rings.push({m:d,t:0,dur:0,r:0})}let u=new ye({map:ae.glow(),color:16752704,transparent:!0,blending:ke,depthWrite:!1,toneMapped:!1});this.balls=[];for(let f=0;f<4;f++){let d=new Xn(u.clone());d.visible=!1,t.add(d),this.balls.push({s:d,t:0,r:0})}this.lightT=0,this.boomT=0}muzzleFlash(t,e,i=1){let n=this.flashes[this.flashIdx++%this.flashes.length];n.position.copy(t),n.quaternion.copy(e),n.rotateZ(Math.random()*Math.PI),n.scale.setScalar(i*(.8+Math.random()*.4)),n.visible=!0,n.userData.t=.045,this.lightsOn&&(this.muzzleLight.position.copy(t),this.muzzleLight.intensity=6*i,this.lightT=.05);for(let r=0;r<3*this.mul;r++)Ft.set((Math.random()-.5)*.6,(Math.random()-.5)*.6,1).applyQuaternion(e).multiplyScalar(2+Math.random()*3),this.add.emit(t.x,t.y,t.z,Ft.x,Ft.y,Ft.z,1,.75,.3,1,.12,.05,.01,0);this.alpha.emit(t.x,t.y,t.z,(Math.random()-.5)*.3,.4,(Math.random()-.5)*.3,.6,.6,.6,.18,.7,.12,.45,-.3)}tracer(t,e,i=260){let n=this.tracers[this.trIdx++%this.tracers.length],r=n.userData;r.from.copy(t),r.to.copy(e);let o=t.distanceTo(e);r.dur=Math.max(.03,o/i),r.t=0,r.len=Math.min(4,o*.5),n.visible=!0,n.position.copy(t),n.lookAt(e)}shell(t,e,i=1){let n=this.shells[this.shellIdx++%this.shells.length];n.p.copy(t),n.v.copy(e).multiplyScalar(1.8+Math.random()).add(Ft.set((Math.random()-.5)*.6,2+Math.random(),(Math.random()-.5)*.6)),n.w.set(Math.random()*20,Math.random()*20,Math.random()*20),n.t=0,n.s=i,n.bounced=!1}impact(t,e,i="dirt"){let n=jf[i]||jf.dirt,r=Math.max(2,Math.round(7*this.mul));for(let o=0;o<r;o++){let l=Math.random()>.5?n[0]:n[1];Ft.set(e.x+(Math.random()-.5)*1.4,e.y+Math.random()*.8,e.z+(Math.random()-.5)*1.4).multiplyScalar(2.5+Math.random()*3),this.alpha.emit(t.x,t.y,t.z,Ft.x,Ft.y,Ft.z,l[0],l[1],l[2],.95,.5+Math.random()*.4,.05,.03,9.8)}if(this.alpha.emit(t.x,t.y,t.z,e.x*.4,.5,e.z*.4,n[1][0],n[1][1],n[1][2],.45,.9,.15,.6,-.2),i==="rock"||i==="metal")for(let o=0;o<4;o++)Ft.set(e.x+(Math.random()-.5)*2,e.y+Math.random(),e.z+(Math.random()-.5)*2).multiplyScalar(4+Math.random()*4),this.add.emit(t.x,t.y,t.z,Ft.x,Ft.y,Ft.z,1,.8,.4,1,.25,.04,.01,9.8)}alienHit(t,e,i,n=!1){let r=new _t(i),o=Math.round((n?16:8)*this.mul);for(let a=0;a<o;a++)Ft.set(-e.x+(Math.random()-.5)*1.6,-e.y+Math.random()*1.2,-e.z+(Math.random()-.5)*1.6).multiplyScalar(2+Math.random()*4),this.add.emit(t.x,t.y,t.z,Ft.x,Ft.y,Ft.z,r.r,r.g,r.b,1,.35+Math.random()*.3,.07,.02,7);for(let a=0;a<Math.max(2,o/3);a++)Ft.set((Math.random()-.5)*2,Math.random()*2,(Math.random()-.5)*2),this.alpha.emit(t.x,t.y,t.z,Ft.x,Ft.y,Ft.z,r.r*.5,r.g*.5,r.b*.5,.9,.7,.08,.05,9.8)}alienBurst(t,e,i=1){let n=new _t(e),r=Math.round(40*this.mul*i);for(let o=0;o<r;o++)Ft.set(Math.random()-.5,Math.random()*.8,Math.random()-.5).normalize().multiplyScalar((2+Math.random()*5)*i),this.add.emit(t.x,t.y,t.z,Ft.x,Ft.y,Ft.z,n.r,n.g,n.b,1,.5+Math.random()*.5,.12*i,.02,5)}explosion(t,e=6,i=null){let n=Math.round(60*this.mul);for(let o=0;o<n;o++){Ft.set(Math.random()-.5,Math.random()*.9+.1,Math.random()-.5).normalize().multiplyScalar(e*(.8+Math.random()*1.6));let a=Math.random();this.add.emit(t.x,t.y+.3,t.z,Ft.x,Ft.y,Ft.z,1,.45+a*.4,.1+a*.2,1,.45+Math.random()*.4,.9,.2,2)}for(let o=0;o<n*.5;o++){Ft.set(Math.random()-.5,Math.random()*.8+.4,Math.random()-.5).normalize().multiplyScalar(e*(.3+Math.random()*.6));let a=.18+Math.random()*.15;this.alpha.emit(t.x,t.y+.5,t.z,Ft.x,Ft.y,Ft.z,a,a,a,.65,1.6+Math.random()*1.4,1,3.2,-.4)}for(let o=0;o<n*.3;o++)Ft.set(Math.random()-.5,Math.random()+.5,Math.random()-.5).multiplyScalar(e*2),this.alpha.emit(t.x,t.y+.3,t.z,Ft.x,Ft.y,Ft.z,.2,.15,.1,1,1.2,.08,.06,14);let r=this.balls[Math.floor(Math.random()*this.balls.length)];r.s.visible=!0,r.t=0,r.r=e,r.s.position.copy(t).y+=.8,this.lightsOn&&(this.boomLight.position.copy(t).y+=1.5,this.boomLight.intensity=40,this.boomT=.35),i!==null&&this.decal(t.x,i,t.z,e*.75,"scorch",25)}decal(t,e,i,n,r="scorch",o=20,a=null){let l=this.decals[this.decalIdx++%this.decals.length];l.m.position.set(t,e+.05,i),l.m.scale.set(n,1,n),l.m.rotation.y=Math.random()*6.28,l.m.material.color.set(a??16777215),l.m.material.opacity=1,l.m.material.blending=r==="acid"?ke:Ui,l.m.visible=!0,l.t=0,l.life=o}shockwave(t,e,i=6743807,n=.6){let r=this.rings.find(a=>!a.m.visible)||this.rings[0];r.m.position.copy(t).y+=.15,r.m.material.color.set(i),r.m.visible=!0,r.t=0,r.dur=n,r.r=e;let o=Math.round(30*this.mul);for(let a=0;a<o;a++){let l=a/o*Math.PI*2;this.alpha.emit(t.x+Math.cos(l)*.8,t.y+.2,t.z+Math.sin(l)*.8,Math.cos(l)*e*1.2,1.2,Math.sin(l)*e*1.2,.45,.38,.28,.7,.9,.5,1.6,2)}}acid(t,e=10){for(let i=0;i<e*this.mul;i++)Ft.set(Math.random()-.5,Math.random()*1.2,Math.random()-.5).multiplyScalar(4),this.add.emit(t.x,t.y,t.z,Ft.x,Ft.y,Ft.z,.75,1,.15,1,.5+Math.random()*.4,.09,.03,9)}trail(t,e,i=.12){let n=new _t(e);this.add.emit(t.x,t.y,t.z,(Math.random()-.5)*.4,(Math.random()-.5)*.4,(Math.random()-.5)*.4,n.r,n.g,n.b,.9,.35,i,.01,0)}smoke(t,e=1){for(let i=0;i<2*e;i++)this.alpha.emit(t.x,t.y,t.z,(Math.random()-.5)*.6,.8+Math.random()*.6,(Math.random()-.5)*.6,.25,.25,.25,.4,1.5,.3,1.4,-.2)}dust(t,e=1,i=[.55,.47,.36]){for(let n=0;n<3*e;n++)this.alpha.emit(t.x+(Math.random()-.5)*.3,t.y+.05,t.z+(Math.random()-.5)*.3,(Math.random()-.5)*1.2,.3+Math.random()*.5,(Math.random()-.5)*1.2,i[0],i[1],i[2],.4,.8,.15,.6,0)}splash(t){for(let e=0;e<10*this.mul;e++)Ft.set((Math.random()-.5)*2,2+Math.random()*2,(Math.random()-.5)*2),this.alpha.emit(t.x,t.y,t.z,Ft.x,Ft.y,Ft.z,.85,.92,1,.8,.6,.06,.03,9.8)}portal(t,e,i=2){let n=new _t(e);for(let r=0;r<26*this.mul;r++){let o=Math.random()*Math.PI*2,a=.4+Math.random()*.8;this.add.emit(t.x+Math.cos(o)*a,t.y+Math.random()*.3,t.z+Math.sin(o)*a,-Math.cos(o)*.5,i*(.6+Math.random()),-Math.sin(o)*.5,n.r,n.g,n.b,1,.9,.16,.02,0)}this.dust(t,3,[.3,.25,.2])}sparkle(t,e){let i=new _t(e);for(let n=0;n<14*this.mul;n++)Ft.set(Math.random()-.5,Math.random()*1.5,Math.random()-.5).multiplyScalar(2.5),this.add.emit(t.x,t.y+.4,t.z,Ft.x,Ft.y,Ft.z,i.r,i.g,i.b,1,.6,.1,.02,2)}update(t,e,i){this.add.update(t,i,e.fov),this.alpha.update(t,i,e.fov);for(let o of this.flashes)o.visible&&(o.userData.t-=t,o.userData.t<=0&&(o.visible=!1));this.lightsOn&&(this.lightT-=t,this.lightT<=0&&(this.muzzleLight.intensity=0),this.boomT-=t,this.boomLight.intensity=this.boomT>0?40*(this.boomT/.35):0);for(let o of this.tracers){if(!o.visible)continue;let a=o.userData;a.t+=t;let l=a.t/a.dur;if(l>=1){o.visible=!1;continue}o.position.lerpVectors(a.from,a.to,Math.min(1,l+.15)),o.scale.set(1,1,a.len)}let n=new Ut,r=!1;for(let o=0;o<this.shells.length;o++){let a=this.shells[o];if(a.t>1.6){n.makeScale(0,0,0),this.shellMesh.setMatrixAt(o,n);continue}if(r=!0,a.t+=t,(!a.bounced||a.v.lengthSq()>.01)&&(a.v.y-=14*t,a.p.addScaledVector(a.v,t),a.r.x+=a.w.x*t,a.r.y+=a.w.y*t,a.r.z+=a.w.z*t,this.groundAt)){let l=this.groundAt(a.p.x,a.p.z);a.p.y<l+.01&&(a.p.y=l+.01,!a.bounced&&this.onShellLand&&this.onShellLand(a.p),a.bounced=!0,a.v.multiplyScalar(.3),a.v.y=Math.abs(a.v.y)*.4,a.w.multiplyScalar(.4))}Qf.setFromEuler(a.r),n.compose(a.p,Qf,Ft.set(a.s,a.s,a.s)),this.shellMesh.setMatrixAt(o,n)}(r||this._shellsWereVisible)&&(this.shellMesh.instanceMatrix.needsUpdate=!0),this._shellsWereVisible=r;for(let o of this.decals)o.m.visible&&(o.t+=t,o.t>o.life?o.m.visible=!1:o.t>o.life-3&&(o.m.material.opacity=(o.life-o.t)/3));for(let o of this.rings){if(!o.m.visible)continue;o.t+=t;let a=o.t/o.dur;if(a>=1){o.m.visible=!1;continue}let l=.5+o.r*a;o.m.scale.set(l,1,l),o.m.material.opacity=1-a}for(let o of this.balls){if(!o.s.visible)continue;o.t+=t;let a=o.t/.45;if(a>=1){o.s.visible=!1;continue}o.s.scale.setScalar(o.r*(.5+a*1.3)),o.s.material.opacity=1-a*a}}};var Qh={fire_rifle:[6,.03,.75],fire_shotgun:[3,.05,.9],fire_sniper:[2,.1,1],fire_smg:[6,.025,.65],fire_pistol:[4,.04,.75],fire_minigun:[6,.02,.55],minigun_spin:[1,.2,.5],reload_rifle:[1,.2,.8],reload_shotgun:[1,.2,.8],reload_pistol:[1,.2,.8],empty_click:[1,.15,.7],weapon_switch:[1,.1,.7],shell_1:[4,.03,.25],shell_2:[4,.03,.25],shell_3:[4,.03,.25],grenade_pin:[1,.1,.8],grenade_bounce:[3,.08,.6],explosion_1:[4,.05,1],explosion_2:[4,.05,1],impact_dirt:[5,.03,.4],impact_rock:[5,.03,.45],impact_wood:[5,.03,.45],impact_flesh:[6,.02,.55],headshot:[2,.05,.7],hitmarker:[3,.03,.35],growl_1:[3,.4,.75],growl_2:[3,.4,.75],growl_3:[3,.4,.75],alien_attack:[4,.1,.8],alien_hurt_1:[4,.08,.6],alien_hurt_2:[4,.08,.6],alien_death_1:[4,.06,.85],alien_death_2:[4,.06,.85],alien_step:[6,.05,.35],boss_roar:[1,1,1],boss_slam:[2,.2,1],acid_spit:[3,.1,.7],acid_splash:[3,.1,.6],wing_flap:[3,.15,.5],bloater_beep:[3,.1,.6],shockwave:[2,.2,.9],spawn_portal:[4,.1,.55],amb_forest:[1,0,.7],amb_wind:[1,0,.5],amb_water:[1,0,.7],bird_1:[2,1,.45],bird_2:[2,1,.45],bird_3:[2,1,.45],leaves:[2,.3,.4],step_grass_1:[3,.08,.35],step_grass_2:[3,.08,.35],step_grass_3:[3,.08,.35],step_dirt_1:[3,.08,.35],step_dirt_2:[3,.08,.35],step_water:[3,.08,.45],step_wood:[3,.08,.45],pickup_coin:[3,.04,.6],pickup_gem:[2,.05,.7],pickup_health:[2,.1,.75],pickup_armor:[2,.1,.75],pickup_ammo:[2,.1,.75],pickup_power:[2,.1,.8],heal:[1,.3,.7],shield_on:[1,.3,.8],speed_on:[1,.3,.8],player_hurt_1:[2,.15,.8],player_hurt_2:[2,.15,.8],player_death:[1,1,.9],armor_break:[1,.5,.8],ui_click:[2,.03,.6],ui_select:[2,.03,.6],wave_start:[1,1,.8],wave_clear:[1,1,.8],boss_alert:[1,1,.9],game_over:[1,1,.9],mine_beep:[3,.1,.7],spike_hit:[3,.1,.7],crate_break:[3,.05,.8],jump:[1,.2,.5],land:[2,.1,.5],roll:[1,.2,.6],low_health:[1,0,.6],music_menu:[1,0,.6],music_combat:[1,0,.55],music_boss:[1,0,.6],music_gameover:[1,0,.7]},Ky=36,Zl=class{constructor(t,e){this.ok=!1,this.buffers=new Map,this.voices=new Map,this.lastPlay=new Map,this.active=0,this.hrtf=e==="HIGH";try{let i=window.AudioContext||window.webkitAudioContext;this.ctx=new i({latencyHint:"interactive"}),this.master=this.ctx.createGain(),this.comp=this.ctx.createDynamicsCompressor(),this.comp.threshold.value=-10,this.comp.knee.value=8,this.comp.ratio.value=6,this.comp.attack.value=.003,this.comp.release.value=.2,this.master.connect(this.comp).connect(this.ctx.destination),this.music=this.ctx.createGain(),this.music.connect(this.master),this.sfx=this.ctx.createGain(),this.sfx.connect(this.master),this.amb=this.ctx.createGain(),this.amb.connect(this.master),this.ok=!0}catch(i){console.warn("WebAudio unavailable",i)}this.setVolumes(t),this.musicTrack=null,this.loops=new Map}setVolumes(t){if(!this.ok)return;let e=this.ctx.currentTime;this.master.gain.setTargetAtTime(t.masterVolume??1,e,.05),this.music.gain.setTargetAtTime(t.musicVolume??.6,e,.05),this.sfx.gain.setTargetAtTime(t.sfxVolume??.9,e,.05),this.amb.gain.setTargetAtTime(t.ambienceVolume??.7,e,.05)}unlock(){this.ok&&this.ctx.state!=="running"&&this.ctx.resume().catch(()=>{})}suspend(){this.ok&&this.ctx.suspend().catch(()=>{})}resume(){this.ok&&this.ctx.resume().catch(()=>{})}async load(t="audio/",e){if(!this.ok)return;let i=Object.keys(Qh),n=0;await Promise.all(i.map(async r=>{try{let o=await fetch(`${t}${r}.ogg`);if(!o.ok)throw new Error(o.status);let a=await o.arrayBuffer(),l=await new Promise((c,h)=>this.ctx.decodeAudioData(a,c,h));this.buffers.set(r,l)}catch(o){console.warn("sound failed",r,o&&o.message)}n++,e&&e(n/i.length)}))}setListener(t){if(!this.ok)return;let e=this.ctx.listener,i=t.position,n=t.matrixWorld.elements,r=-n[8],o=-n[9],a=-n[10],l=n[4],c=n[5],h=n[6];if(e.positionX){let u=this.ctx.currentTime;e.positionX.setValueAtTime(i.x,u),e.positionY.setValueAtTime(i.y,u),e.positionZ.setValueAtTime(i.z,u),e.forwardX.setValueAtTime(r,u),e.forwardY.setValueAtTime(o,u),e.forwardZ.setValueAtTime(a,u),e.upX.setValueAtTime(l,u),e.upY.setValueAtTime(c,u),e.upZ.setValueAtTime(h,u)}else e.setPosition(i.x,i.y,i.z),e.setOrientation(r,o,a,l,c,h)}play(t,e={}){if(!this.ok||this.ctx.state!=="running")return null;let i=this.buffers.get(t);if(!i)return null;let[n,r,o]=Qh[t]||[4,0,1],a=this.ctx.currentTime,l=this.lastPlay.get(t)||-1;if(r>0&&a-l<r)return null;let c=this.voices.get(t);if(c||(c=[],this.voices.set(t,c)),c.length>=n&&this._stop(c[0]),this.active>=Ky&&!e.loop){for(let x of this.voices.values())if(x.length&&!x[0].loop){this._stop(x[0]);break}}this.lastPlay.set(t,a);let h=this.ctx.createBufferSource();h.buffer=i,h.loop=!!e.loop,h.playbackRate.value=e.rate??.94+Math.random()*.12;let u=this.ctx.createGain();u.gain.value=o*(e.volume??1);let f=h.connect(u),d=null;e.pos&&(d=this.ctx.createPanner(),d.panningModel=this.hrtf?"HRTF":"equalpower",d.distanceModel="inverse",d.refDistance=e.ref??4,d.rolloffFactor=1.1,d.maxDistance=150,d.positionX?(d.positionX.value=e.pos.x,d.positionY.value=e.pos.y,d.positionZ.value=e.pos.z):d.setPosition(e.pos.x,e.pos.y,e.pos.z),f=f.connect(d)),f.connect(e.bus==="amb"?this.amb:e.bus==="music"?this.music:this.sfx);let g={name:t,src:h,gain:u,panner:d,loop:!!e.loop,list:c};return h.onended=()=>this._release(g),c.push(g),this.active++,h.start(),g}setVoicePos(t,e){if(!(!t||!t.panner))if(t.panner.positionX){let i=this.ctx.currentTime;t.panner.positionX.setTargetAtTime(e.x,i,.03),t.panner.positionY.setTargetAtTime(e.y,i,.03),t.panner.positionZ.setTargetAtTime(e.z,i,.03)}else t.panner.setPosition(e.x,e.y,e.z)}setVoiceVolume(t,e,i=.1){if(!t)return;let n=(Qh[t.name]||[0,0,1])[2];t.gain.gain.setTargetAtTime(n*e,this.ctx.currentTime,i)}_stop(t){try{t.src.onended=null,t.src.stop()}catch{}this._release(t)}stop(t,e=0){!t||!this.ok||(e>0?(t.gain.gain.setTargetAtTime(0,this.ctx.currentTime,e/3),setTimeout(()=>this._stop(t),e*1e3+50)):this._stop(t))}_release(t){let e=t.list.indexOf(t);e>=0&&(t.list.splice(e,1),this.active--);try{t.src.disconnect(),t.gain.disconnect(),t.panner&&t.panner.disconnect()}catch{}}loop(t,e,i=1,n="amb"){let r=this.loops.get(t);if(r&&r.name!==e&&(this.stop(r,.5),r=null),!r||!r.list.includes(r)){if(r=this.play(e,{loop:!0,volume:1e-4,bus:n,rate:1}),!r)return;this.loops.set(t,r)}this.setVoiceVolume(r,i,.3)}stopLoop(t,e=.4){let i=this.loops.get(t);i&&(this.stop(i,e),this.loops.delete(t))}playMusic(t,e=1.5){if(this.musicName===t||(this.musicName=t,this.musicTrack&&this.stop(this.musicTrack,e),this.musicTrack=null,!t))return;let i=t!=="music_gameover",n=this.play(t,{loop:i,volume:1e-4,bus:"music",rate:1});n?(this.setVoiceVolume(n,1,e/3),this.musicTrack=n):this.musicName=null}stopAll(){for(let t of this.voices.values())for(let e of[...t])this._stop(e);this.loops.clear(),this.musicTrack=null,this.musicName=null}};var os={humanoid:(s={})=>{let t=s.shoulderW??.2,e=s.hipW??.1,i=s.upperArm??.3,n=s.foreArm??.27,r=s.thigh??.45,o=s.shin??.45,a=s.hipH??.98;return[["root",null,0,0,0],["hips","root",0,a,0],["spine","hips",0,.12,0],["chest","spine",0,s.chestH??.2,0],["neck","chest",0,s.neckH??.28,0],["head","neck",0,.08,0],["armL","chest",t,.22,0],["foreL","armL",0,-i,0],["handL","foreL",0,-n,0],["armR","chest",-t,.22,0],["foreR","armR",0,-i,0],["handR","foreR",0,-n,0],["thighL","hips",e,-.05,0],["shinL","thighL",0,-r,0],["footL","shinL",0,-o,0],["thighR","hips",-e,-.05,0],["shinR","thighR",0,-r,0],["footR","shinR",0,-o,0],...s.wings?[["wingL","chest",.12,.18,-.12],["wingR","chest",-.12,.18,-.12]]:[],...s.tail?[["tail","hips",0,0,-.15],["tail2","tail",0,0,-.4]]:[]]},crawler:()=>[["root",null,0,0,0],["hips","root",0,.55,-.35],["spine","hips",0,.02,.3],["chest","spine",0,.02,.32],["neck","chest",0,.06,.25],["head","neck",0,.02,.12],["armL","chest",.2,-.02,.05],["foreL","armL",0,-.3,0],["handL","foreL",0,-.28,0],["armR","chest",-.2,-.02,.05],["foreR","armR",0,-.3,0],["handR","foreR",0,-.28,0],["thighL","hips",.17,-.02,0],["shinL","thighL",0,-.3,0],["footL","shinL",0,-.26,0],["thighR","hips",-.17,-.02,0],["shinR","thighR",0,-.3,0],["footR","shinR",0,-.26,0],["tail","hips",0,.05,-.15],["tail2","tail",0,0,-.45]]},dn=class{constructor(t){this.layout=t,this.bones=[],this.index={};for(let[e,i,n,r,o]of t){let a=new qn;a.name=e,a.position.set(n,r,o),this.index[e]=this.bones.length,this.bones.push(a),i&&this.bones[this.index[i]].add(a)}this.root=this.bones[0],this.root.updateMatrixWorld(!0),this.builder=new se,this._m=new Ut,this._q=new _e}part(t,e,i={}){let n=this.index[t];if(n===void 0)throw new Error("no bone "+t);let r=this.bones[n],o=i.scale??1,a=Array.isArray(o)?new T(...o):new T(o,o,o),l=i.rot||[0,0,0];this._q.setFromEuler(new Re(l[0],l[1],l[2]));let c=new Ut().compose(new T(...i.pos||[0,0,0]),this._q,a),h=new Ut().multiplyMatrices(r.matrixWorld,c);return this.builder.add(e,{...i,matrix:h,bone:n}),this}pair(t,e,i={}){let n=i.pos||[0,0,0],r=i.rot||[0,0,0];return this.part(t+"L",e,i),this.part(t+"R",e,{...i,pos:[-n[0],n[1],n[2]],rot:[r[0],-r[1],-r[2]]}),this}build(t,{radius:e=2,centerY:i=1}={}){return{geometry:this.builder.build({groups:!0,skin:!0}),layout:this.layout,radius:e,centerY:i,materials:t}}};function fn(s,t=!1){let e=[],i={};for(let[a,l,c,h,u]of s.layout){let f=new qn;f.name=a,f.position.set(c,h,u),i[a]=e.length,e.push(f),l&&e[i[l]].add(f)}let n=t?s.materials.map(a=>a.clone()):s.materials,r=new Lr(s.geometry,n);r.add(e[0]),r.updateMatrixWorld(!0),r.bind(new Ur(e)),r.boundingSphere=new ri(new T(0,s.centerY,0),s.radius),r.frustumCulled=!0;let o={};for(let a of e)o[a.name]=a;return{mesh:r,bones:e,index:i,b:o,rest:e.map(a=>a.position.clone())}}var Ks=new Map;function ep({map:s,roughness:t=.75,metalness:e=.05,side:i=bi}={}){return[new je({vertexColors:!0,map:s,roughness:t,metalness:e,side:i}),new ye({vertexColors:!0,toneMapped:!1,side:i})]}function js(){if(Ks.has("soldier"))return Ks.get("soldier");let s=os.humanoid({thigh:.43,shin:.42}),t=new dn(s),e=12749416,i=10119760,n=8025680,r=6249532,o=3096414,a=2372176,l=7030312,c=1906965,h=5196850,u=3420970,f=2762532,d=1774864;t.part("hips",R.capsule(.15,.08,4,14),{pos:[0,-.02,0],scale:[1.15,.8,.85],color:o}),t.part("hips",R.cyl(.178,.178,.065,18),{pos:[0,.075,0],scale:[1,1,.82],color:3879462}),t.part("hips",R.box(.06,.045,.02),{pos:[0,.075,.148],color:10132106});for(let[x,m,p]of[[.16,.05,.4],[-.16,.05,-.4],[.12,-.12,-.6],[-.12,-.12,.6],[0,-.15,0]])t.part("hips",R.box(.085,.09,.06),{pos:[x,.05,m],rot:[0,p,0],color:h}),t.part("hips",R.box(.088,.03,.064),{pos:[x,.09,m],rot:[0,p,0],color:r});t.part("spine",R.capsule(.14,.1,4,14),{pos:[0,.07,0],scale:[1.18,1,.8],color:n}),t.part("chest",R.capsule(.16,.17,6,16),{pos:[0,.12,0],scale:[1.22,1,.8],color:n});for(let x of[1,-1])t.part("chest",R.box(.1,.11,.03),{pos:[x*.09,.14,.125],color:r}),t.part("chest",R.box(.104,.035,.034),{pos:[x*.09,.2,.127],color:5591599}),t.part("chest",R.box(.045,.34,.02),{pos:[x*.115,.13,.133],color:u}),t.part("chest",R.box(.05,.02,.26),{pos:[x*.12,.31,-.02],color:u}),t.part("chest",R.box(.045,.3,.02),{pos:[x*.115,.12,-.14],color:u});t.part("chest",R.torus(.065,.02,6,14),{pos:[0,.31,.01],rot:[Math.PI/2,0,0],color:r}),t.part("chest",R.box(.012,.22,.012),{pos:[0,.16,.135],color:3815978}),t.part("chest",R.box(.34,.42,.17),{pos:[0,.1,-.23],color:6249275}),t.part("chest",R.box(.36,.06,.18),{pos:[0,.3,-.23],color:5262384}),t.part("chest",R.cyl(.07,.07,.36,12),{pos:[0,.37,-.21],rot:[0,0,Math.PI/2],color:4868656}),t.part("chest",R.box(.24,.17,.05),{pos:[0,-.02,-.33],color:h}),t.part("chest",R.box(.07,.22,.12),{pos:[.2,.04,-.23],color:h}),t.part("chest",R.box(.07,.22,.12),{pos:[-.2,.04,-.23],color:h}),t.part("chest",R.box(.3,.025,.02),{pos:[0,.15,-.316],color:u}),t.part("neck",R.cyl(.055,.062,.12,12),{pos:[0,.03,.005],color:e}),t.part("head",R.sphere(.104,18,14),{pos:[0,.1,.005],scale:[.92,1.08,1],color:e}),t.part("head",R.sphere(.084,14,10),{pos:[0,.04,.03],scale:[.95,.72,1],color:i}),t.part("head",R.box(.026,.045,.035),{pos:[0,.088,.104],rot:[-.25,0,0],color:e}),t.part("head",R.box(.04,.008,.012),{pos:[0,.045,.097],color:8014394});for(let x of[1,-1])t.part("head",R.sphere(.026,8,6),{pos:[x*.097,.095,0],scale:[.45,1,.8],color:i}),t.part("head",R.sphere(.013,8,6),{pos:[x*.036,.115,.092],scale:[1.2,.8,.6],color:15789024}),t.part("head",R.sphere(.007,6,4),{pos:[x*.036,.115,.099],color:2365970}),t.part("head",R.box(.04,.009,.012),{pos:[x*.037,.134,.097],rot:[0,0,x*-.12],color:d});t.part("head",new ci(.112,18,8,0,Math.PI*2,0,Math.PI*.5),{pos:[0,.12,-.006],scale:[.96,.85,1.05],color:d}),t.part("head",new ci(.108,16,8,Math.PI*.6,Math.PI*.8,Math.PI*.35,Math.PI*.3),{pos:[0,.1,-.01],color:d});for(let x of["L","R"]){let m=x==="L"?1:-1;t.part("arm"+x,R.sphere(.075,12,10),{pos:[0,-.01,0],scale:[1,.9,1],color:n}),t.part("arm"+x,R.capsule(.062,.12,4,12),{pos:[0,-.1,0],color:n}),t.part("arm"+x,R.torus(.058,.016,6,12),{pos:[0,-.18,0],rot:[Math.PI/2,0,0],color:r}),t.part("arm"+x,R.capsule(.05,.08,4,10),{pos:[0,-.24,0],color:e}),t.part("arm"+x,R.box(.012,.075,.07),{pos:[m*.06,-.07,0],color:4016682}),t.part("arm"+x,R.box(.014,.035,.035),{pos:[m*.061,-.07,0],color:x==="L"?13762071:11549230}),t.part("fore"+x,R.capsule(.046,.17,4,10),{pos:[0,-.12,0],color:e}),t.part("fore"+x,R.cyl(.05,.05,.05,10),{pos:[0,-.235,0],color:f}),t.part("hand"+x,R.box(.075,.09,.042),{pos:[0,-.045,.005],color:f}),t.part("hand"+x,R.box(.07,.06,.035),{pos:[0,-.11,.018],rot:[.35,0,0],color:f}),t.part("hand"+x,R.box(.022,.05,.025),{pos:[m*.042,-.05,.03],rot:[.3,0,m*.4],color:f})}t.part("foreL",R.box(.03,.035,.055),{pos:[.044,-.2,0],color:1381653});for(let x of["L","R"]){let m=x==="L"?1:-1;t.part("thigh"+x,R.capsule(.088,.25,4,12),{pos:[0,-.2,0],color:o}),t.part("thigh"+x,R.box(.03,.12,.11),{pos:[m*.088,-.24,0],color:a}),t.part("shin"+x,R.capsule(.07,.24,4,12),{pos:[0,-.17,0],color:o}),t.part("shin"+x,R.sphere(.07,10,8),{pos:[0,-.02,.055],scale:[1,1.15,.6],color:2763306}),t.part("shin"+x,R.cyl(.078,.074,.16,12),{pos:[0,-.34,0],color:l}),t.part("shin"+x,R.torus(.077,.01,4,12),{pos:[0,-.27,0],rot:[Math.PI/2,0,0],color:4861976}),t.part("foot"+x,R.box(.11,.085,.24),{pos:[0,-.035,.045],color:l}),t.part("foot"+x,R.sphere(.056,10,8),{pos:[0,-.04,.15],scale:[1,.75,1],color:l}),t.part("foot"+x,R.box(.12,.03,.27),{pos:[0,-.078,.05],color:c})}t.part("thighR",R.box(.05,.17,.1),{pos:[-.105,-.17,0],color:2368030}),t.part("thighR",R.box(.02,.03,.1),{pos:[-.1,-.06,0],color:u}),t.part("thighR",R.box(.028,.06,.04),{pos:[-.11,-.06,.01],color:1381653});let g=t.build(ep({map:ae.fabric()}),{radius:1.6,centerY:.9});return Ks.set("soldier",g),g}function ip(s,t,e,i){let[n,r,o]=e,a=me(s.id.length*97),l=(h,u,f)=>t.part(h,R.dodeca(u,0),{color:r,jitter:u*.25,rng:a,flat:!0,...f}),c=i==="runner"?.24:.16;t.part("hips",R.sphere(.15,12,8),{scale:[1.2,.8,.9],color:n}),l("hips",.13,{pos:[0,-.02,.07],scale:[1.4,.8,.6]});for(let h=0;h<3;h++)t.part("spine",R.torus(.09-h*.008,.035,6,12),{pos:[0,.02+h*.07,0],rot:[Math.PI/2,0,0],color:h%2?n:r});t.part("spine",R.cyl(.08,.1,.24,10),{pos:[0,.08,0],color:n}),l("chest",.22,{pos:[0,.14,.01],scale:[1.3,1,.85]}),t.part("chest",R.sphere(.2,12,10),{pos:[0,.12,-.02],scale:[1.25,1,.85],color:n}),t.part("chest",R.sphere(.065,12,10),{pos:[0,.15,.175],color:o,glow:!0});for(let h of[1,-1])t.part("chest",R.box(.02,.2,.02),{pos:[h*.11,.1,.165],rot:[0,0,h*.35],color:o,glow:!0}),l("chest",.12,{pos:[h*.24,.26,0],scale:[1.2,.8,1.1]}),t.part("chest",R.cone(.035,.18,5),{pos:[h*.29,.36,-.02],rot:[0,0,-h*.6],color:r});for(let h=0;h<4;h++)t.part("chest",R.cone(.03,.14+(i==="elite"?.1:0),5),{pos:[0,.3-h*.09,-.2],rot:[-1.1,0,0],color:r});t.part("neck",R.cyl(.05,.07,.14,8),{pos:[0,.03,0],color:n}),t.part("head",R.sphere(.12,14,10),{pos:[0,.09,.03],rot:[-.25,0,0],scale:[.85,1,1.4],color:r}),t.part("head",R.cone(.07,.25,6),{pos:[0,.16,-.1],rot:[-2.1,0,0],color:n});for(let h of[1,-1])t.part("head",R.sphere(.024,8,6),{pos:[h*.048,.1,.135],scale:[1.6,.6,1],color:o,glow:!0}),t.part("head",R.cone(.018,.11,5),{pos:[h*.04,0,.15],rot:[2.5,0,h*.3],color:n});if(i==="spitter"){t.part("neck",R.sphere(.09,12,8),{pos:[0,0,.07],scale:[1,.8,1],color:o,glow:!0});for(let h=0;h<5;h++)t.part("head",R.cone(.03,.16,4),{pos:[(h-2)*.05,.18,-.06],rot:[-.6,0,(h-2)*.3],color:o,glow:!0})}if(i==="elite"){t.part("head",R.cone(.05,.3,4),{pos:[0,.27,-.02],rot:[-.4,0,0],color:r});for(let h of[1,-1])l("chest",.16,{pos:[h*.26,.28,-.02],scale:[1.3,.9,1.3]});t.part("chest",R.box(.36,.5,.03),{pos:[0,-.05,-.22],rot:[.15,0,0],color:n})}for(let h of["L","R"]){let u=h==="L"?1:-1;t.part("arm"+h,R.capsule(.064,.2,4,10),{pos:[0,-.15,0],color:n}),l("arm"+h,.08,{pos:[u*.04,-.1,0],scale:[.8,1.4,1]}),t.part("fore"+h,R.capsule(.055,.2,4,10),{pos:[0,-.14,0],color:n}),l("fore"+h,.07,{pos:[u*.03,-.12,-.02],scale:[.8,1.6,.9]}),t.part("fore"+h,R.box(.012,.18,.012),{pos:[u*.045,-.13,.04],color:o,glow:!0}),t.part("fore"+h,R.cone(.025,.12,5),{pos:[0,-.02,-.07],rot:[-1.9,0,0],color:r}),t.part("hand"+h,R.sphere(.05,8,6),{pos:[0,-.03,0],scale:[1,1.1,.7],color:n});for(let f=-1;f<=1;f++)t.part("hand"+h,R.cone(.014,c,5),{pos:[f*.025,-.08-c*.4,.015],rot:[Math.PI-.25,0,f*.15],color:14209216});t.part("thigh"+h,R.capsule(.08,.28,4,10),{pos:[0,-.2,0],color:n}),l("thigh"+h,.1,{pos:[0,-.18,.05],scale:[.9,1.6,.7]}),t.part("shin"+h,R.capsule(.06,.3,4,10),{pos:[0,-.2,0],color:n}),t.part("shin"+h,R.cone(.035,.14,5),{pos:[0,0,.08],rot:[1.3,0,0],color:r}),l("shin"+h,.07,{pos:[0,-.2,.04],scale:[.9,1.8,.7]});for(let f=-1;f<=1;f++)t.part("foot"+h,R.cone(.025,.16,5),{pos:[f*.035,-.02,.09],rot:[Math.PI/2,0,0],color:r});t.part("foot"+h,R.sphere(.05,8,6),{pos:[0,-.01,-.02],color:n})}}function jy(s,t,e,i){let[n,r,o]=e,a=me(i?991:313),l=(c,h,u)=>t.part(c,R.dodeca(h,0),{color:r,jitter:h*.22,rng:a,flat:!0,...u});t.part("hips",R.sphere(.2,12,8),{scale:[1.3,.8,1],color:n}),l("hips",.16,{pos:[0,-.02,.1],scale:[1.5,.8,.6]}),t.part("spine",R.sphere(.2,12,10),{pos:[0,.1,0],scale:[1.2,1,.9],color:n}),l("chest",.36,{pos:[0,.16,.02],scale:[1.35,1,.95]}),t.part("chest",R.sphere(.34,14,10),{pos:[0,.14,-.04],scale:[1.35,1,.95],color:n}),t.part("chest",R.sphere(.11,14,10),{pos:[0,.16,.3],color:o,glow:!0});for(let c=0;c<6;c++){let h=c/6*Math.PI*2;t.part("chest",R.box(.02,.16,.02),{pos:[Math.cos(h)*.17,.16+Math.sin(h)*.17,.27],rot:[0,0,h+Math.PI/2],color:o,glow:!0})}for(let c of[1,-1]){l("chest",.2,{pos:[c*.36,.3,0],scale:[1.2,.9,1.2]});for(let h=0;h<3;h++)t.part("chest",R.cone(.05,.24,5),{pos:[c*(.33+h*.06),.45,-.05+h*.05],rot:[0,0,-c*(.4+h*.2)],color:r})}for(let c=0;c<5;c++)t.part("chest",R.cone(.05,.22,5),{pos:[0,.4-c*.12,-.3],rot:[-1.2,0,0],color:r});if(i)for(let c=0;c<4;c++)t.part("spine",R.sphere(.05,8,6),{pos:[0,.05+c*.05,-.2],color:o,glow:!0});t.part("neck",R.cyl(.1,.14,.15,8),{pos:[0,0,.05],color:n}),t.part("head",R.sphere(.15,12,10),{pos:[0,.06,.08],scale:[1.1,.95,1.2],color:r}),t.part("head",R.box(.2,.06,.14),{pos:[0,-.02,.15],color:n});for(let c of[1,-1])t.part("head",R.sphere(.03,8,6),{pos:[c*.06,.08,.24],scale:[1.5,.6,1],color:o,glow:!0}),t.part("head",R.cone(.04,i?.4:.22,6),{pos:[c*.12,.2,0],rot:[-.5,0,-c*.5],color:14209216});if(i)for(let c=0;c<5;c++)t.part("head",R.cone(.03,.26,5),{pos:[(c-2)*.06,.22,-.05],rot:[-.3,0,(c-2)*.25],color:o,glow:!0});for(let c of["L","R"]){let h=c==="L"?1:-1;t.part("arm"+c,R.capsule(.12,.2,4,12),{pos:[0,-.16,0],color:n}),l("arm"+c,.13,{pos:[h*.06,-.12,0],scale:[.9,1.4,1.1]}),t.part("fore"+c,R.capsule(.13,.2,4,12),{pos:[0,-.16,0],color:n}),l("fore"+c,.12,{pos:[h*.05,-.16,.02],scale:[1,1.5,1.1]}),t.part("fore"+c,R.box(.02,.24,.02),{pos:[h*.1,-.16,.08],color:o,glow:!0}),t.part("hand"+c,R.dodeca(.13,0),{pos:[0,-.08,.02],scale:[1,1.1,1],color:r,flat:!0});for(let u=-1;u<=1;u++)t.part("hand"+c,R.cone(.025,.12,5),{pos:[u*.05,-.12,.1],rot:[1.4,0,0],color:14209216});t.part("thigh"+c,R.capsule(.12,.2,4,10),{pos:[0,-.17,0],color:n}),l("thigh"+c,.14,{pos:[0,-.15,.06],scale:[1,1.3,.8]}),t.part("shin"+c,R.capsule(.1,.22,4,10),{pos:[0,-.18,0],color:n}),l("shin"+c,.12,{pos:[0,-.16,.05],scale:[1,1.5,.8]}),t.part("foot"+c,R.box(.2,.1,.3),{pos:[0,-.04,.06],color:r});for(let u=-1;u<=1;u++)t.part("foot"+c,R.cone(.03,.12,5),{pos:[u*.06,-.05,.24],rot:[Math.PI/2,0,0],color:14209216})}}function Qy(s,t,e){let[i,n,r]=e,o=me(555),a=(l,c,h)=>t.part(l,R.dodeca(c,0),{color:n,jitter:c*.25,rng:o,flat:!0,...h});t.part("hips",R.sphere(.16,10,8),{scale:[1.2,.8,1.3],color:i}),t.part("spine",R.sphere(.17,10,8),{pos:[0,0,.15],scale:[1.1,.75,1.3],color:i}),t.part("chest",R.sphere(.19,10,8),{pos:[0,0,.1],scale:[1.2,.8,1.2],color:i});for(let[l,c]of[["hips",0],["spine",.15],["chest",.1]])a(l,.17,{pos:[0,.11,c],scale:[1.3,.45,1.2]}),t.part(l,R.cone(.035,.2,5),{pos:[0,.2,c],rot:[-.4,0,0],color:n}),t.part(l,R.sphere(.03,6,4),{pos:[0,.06,c+.12],color:r,glow:!0});t.part("neck",R.cyl(.07,.09,.15,8),{pos:[0,0,.05],rot:[Math.PI/2,0,0],color:i}),t.part("head",R.sphere(.12,12,8),{pos:[0,0,.08],scale:[1.1,.75,1.4],color:n});for(let l of[1,-1])t.part("head",R.sphere(.024,8,6),{pos:[l*.06,.04,.2],scale:[1.5,.7,1],color:r,glow:!0}),t.part("head",R.sphere(.016,8,6),{pos:[l*.03,.06,.23],color:r,glow:!0}),t.part("head",R.cone(.02,.14,5),{pos:[l*.05,-.05,.22],rot:[1.9,0,l*.4],color:14209216});t.part("tail",R.cone(.09,.45,8),{pos:[0,0,-.2],rot:[-Math.PI/2,0,0],color:i}),t.part("tail2",R.cone(.05,.4,6),{pos:[0,0,-.18],rot:[-Math.PI/2,0,0],color:n}),t.part("tail2",R.cone(.03,.14,5),{pos:[0,.05,-.4],rot:[-.6,0,0],color:r,glow:!0});for(let l of["L","R"])for(let[c,h,u]of[["arm","fore","hand"],["thigh","shin","foot"]])t.part(c+l,R.capsule(.05,.22,4,8),{pos:[0,-.15,0],color:i}),a(c+l,.06,{pos:[0,-.12,.03],scale:[.8,1.6,.8]}),t.part(h+l,R.capsule(.035,.22,4,8),{pos:[0,-.14,0],color:n}),t.part(u+l,R.cone(.03,.14,5),{pos:[0,-.04,.03],rot:[Math.PI-.6,0,0],color:14209216})}function tv(s,t,e){let[i,n,r]=e,o=me(777);t.part("hips",R.sphere(.17,10,8),{scale:[1.2,.8,1],color:i}),t.part("spine",R.sphere(.3,16,12),{pos:[0,.12,.04],scale:[1.05,1,1.05],color:i}),t.part("chest",R.sphere(.27,16,12),{pos:[0,.05,.02],color:i});for(let a=0;a<7;a++){let l=o()*Math.PI*2,c=o()*.3;t.part(a<4?"spine":"chest",R.sphere(.07+o()*.06,10,8),{pos:[Math.cos(l)*.22,.06+c,.08+Math.abs(Math.sin(l))*.2],color:r,glow:!0})}for(let a=0;a<5;a++)t.part("chest",R.dodeca(.09,0),{pos:[(o()-.5)*.4,.15+o()*.15,-.2],color:n,flat:!0});t.part("neck",R.cyl(.05,.07,.1,8),{color:i}),t.part("head",R.sphere(.1,12,8),{pos:[0,.07,.04],scale:[.9,.9,1.2],color:n});for(let a of[1,-1])t.part("head",R.sphere(.02,6,4),{pos:[a*.04,.09,.14],color:r,glow:!0});for(let a of["L","R"])t.part("arm"+a,R.capsule(.05,.18,4,8),{pos:[0,-.13,0],color:i}),t.part("fore"+a,R.capsule(.045,.18,4,8),{pos:[0,-.12,0],color:i}),t.part("hand"+a,R.cone(.02,.1,5),{pos:[0,-.05,0],rot:[Math.PI,0,0],color:14209216}),t.part("thigh"+a,R.capsule(.08,.2,4,8),{pos:[0,-.16,0],color:i}),t.part("shin"+a,R.capsule(.065,.22,4,8),{pos:[0,-.17,0],color:n}),t.part("foot"+a,R.box(.1,.06,.18),{pos:[0,-.03,.05],color:n})}function ev(s,t,e){ip(s,t,e,"flyer");let[,i,n]=e,r=new on;r.moveTo(0,0),r.lineTo(.35,.18),r.lineTo(.9,.12),r.lineTo(1.25,-.05),r.lineTo(.95,-.12),r.lineTo(.85,-.32),r.lineTo(.6,-.22),r.lineTo(.45,-.42),r.lineTo(.28,-.24),r.lineTo(.05,-.3),r.lineTo(0,0);let o=new $n(r);o.rotateX(-Math.PI/2);for(let a of["L","R"]){let l=a==="L"?1:-1;t.part("wing"+a,o,{scale:[l,1,1],color:i});for(let c=0;c<3;c++)t.part("wing"+a,R.box(.85-c*.2,.015,.015),{pos:[l*(.4-c*.05),.01,.05+c*.12],rot:[0,l*(-.15-c*.25),0],color:n,glow:!0})}}function Jl(s){if(Ks.has(s.id))return Ks.get(s.id);let t=s.colors,e,i=1.6,n=1,r=bi;switch(s.rig){case"brute":e=new dn(os.humanoid({shoulderW:.36,upperArm:.36,foreArm:.36,thigh:.36,shin:.36,hipH:.84,chestH:.24,neckH:.36,hipW:.15})),jy(s,e,t,s.id==="boss"),i=1.8,n=1.1;break;case"crawler":e=new dn(os.crawler()),Qy(s,e,t),i=1.3,n=.4;break;case"bloater":e=new dn(os.humanoid({hipH:.78,thigh:.36,shin:.36,chestH:.28,neckH:.24,upperArm:.26,foreArm:.24,shoulderW:.26})),tv(s,e,t),i=1.3,n=.9;break;case"flyer":e=new dn(os.humanoid({shoulderW:.2,upperArm:.3,foreArm:.3,thigh:.36,shin:.38,hipH:.82,wings:!0})),ev(s,e,t),i=2,n=.9,r=Fe;break;default:e=new dn(os.humanoid({shoulderW:.24,upperArm:.34,foreArm:.31,thigh:.46,shin:.48,hipH:1,neckH:.3,hipW:.11})),ip(s,e,t,s.id==="runner"?"runner":s.id),i=1.7,n=1}let o=e.build(ep({map:ae.alien(),roughness:.42,metalness:.55,side:r}),{radius:i,centerY:n});return o.glowColor=new _t(t[2]),Ks.set(s.id,o),o}var re=1974049,Ti=3422011,$l=7225119,tu=5582874,tp=8025172;function iv(s){s.add(R.box(.05,.075,.34),{pos:[0,.05,.1],color:Ti}),s.add(R.box(.045,.02,.3),{pos:[0,.095,.1],color:re}),s.add(R.box(.045,.075,.26),{pos:[0,.03,-.2],rot:[-.12,0,0],color:$l,gradient:[.8,1.1]}),s.add(R.box(.048,.11,.05),{pos:[0,0,-.34],rot:[-.12,0,0],color:tu}),s.add(R.box(.035,.11,.045),{pos:[0,-.04,-.01],rot:[.35,0,0],color:tu});for(let t=0;t<4;t++)s.add(R.box(.038,.05,.045),{pos:[0,-.02-t*.04,.12+t*.018],rot:[-.3-t*.05,0,0],color:t%2?Ti:re});return s.add(R.box(.055,.06,.2),{pos:[0,.05,.36],color:$l,gradient:[.8,1.1]}),s.add(R.cyl(.012,.012,.3,8),{pos:[0,.075,.56],rot:[Math.PI/2,0,0],color:re}),s.add(R.cyl(.008,.008,.22,6),{pos:[0,.098,.4],rot:[Math.PI/2,0,0],color:Ti}),s.add(R.box(.01,.035,.012),{pos:[0,.1,.62],color:re}),s.add(R.cyl(.018,.016,.06,8),{pos:[0,.075,.72],rot:[Math.PI/2,0,0],color:re}),s.add(R.box(.02,.03,.04),{pos:[0,.11,.24],color:re}),{grip:[0,-.02,0],fore:[0,.02,.37],muzzle:[0,.075,.76],eject:[-.03,.07,.12]}}function nv(s){s.add(R.box(.05,.08,.26),{pos:[0,.05,.06],color:re}),s.add(R.box(.045,.08,.3),{pos:[0,.02,-.22],rot:[-.14,0,0],color:$l,gradient:[.8,1.1]}),s.add(R.box(.05,.12,.04),{pos:[0,-.01,-.37],rot:[-.14,0,0],color:1710618}),s.add(R.cyl(.015,.015,.62,10),{pos:[0,.075,.5],rot:[Math.PI/2,0,0],color:Ti}),s.add(R.cyl(.014,.014,.5,10),{pos:[0,.04,.42],rot:[Math.PI/2,0,0],color:re}),s.add(R.box(.06,.06,.18),{pos:[0,.04,.34],color:$l,gradient:[.8,1.1]});for(let t=0;t<6;t++)s.add(R.box(.062,.006,.01),{pos:[0,.07,.27+t*.025],color:tu});return s.add(R.box(.012,.012,.012),{pos:[0,.092,.8],color:13684944}),{grip:[0,-.02,0],fore:[0,.01,.34],muzzle:[0,.075,.82],eject:[-.03,.07,.08]}}function sv(s){s.add(R.box(.05,.07,.36),{pos:[0,.04,.1],color:tp}),s.add(R.box(.048,.1,.3),{pos:[0,.01,-.22],rot:[-.08,0,0],color:tp,gradient:[.8,1.1]}),s.add(R.box(.05,.05,.12),{pos:[0,.07,-.25],color:5920320}),s.add(R.box(.035,.1,.045),{pos:[0,-.045,0],rot:[.3,0,0],color:3815980}),s.add(R.box(.04,.07,.07),{pos:[0,-.03,.12],color:re}),s.add(R.cyl(.013,.015,.62,10),{pos:[0,.06,.58],rot:[Math.PI/2,0,0],color:re}),s.add(R.cyl(.02,.02,.08,10),{pos:[0,.06,.9],rot:[Math.PI/2,0,0],color:re}),s.add(R.cyl(.024,.024,.34,14),{pos:[0,.135,.1],rot:[Math.PI/2,0,0],color:re}),s.add(R.cyl(.032,.024,.07,14),{pos:[0,.135,.29],rot:[Math.PI/2,0,0],color:re}),s.add(R.cyl(.03,.024,.06,14),{pos:[0,.135,-.09],rot:[Math.PI/2,0,0],color:re}),s.add(R.cyl(.026,.026,.005,14),{pos:[0,.135,.327],rot:[Math.PI/2,0,0],color:3837912,glow:!1}),s.add(R.box(.02,.04,.03),{pos:[0,.095,.04],color:re}),s.add(R.box(.02,.04,.03),{pos:[0,.095,.18],color:re}),s.add(R.cyl(.01,.01,.06,6),{pos:[-.04,.06,-.02],rot:[0,0,Math.PI/2],color:re}),s.add(R.sphere(.014,8,6),{pos:[-.07,.06,-.02],color:re});for(let t of[1,-1])s.add(R.cyl(.006,.006,.22,6),{pos:[t*.015,.02,.5],rot:[Math.PI/2,0,0],color:re});return{grip:[0,-.03,0],fore:[0,0,.34],muzzle:[0,.06,.95],eject:[-.03,.06,.08],scope:[0,.135,.1]}}function rv(s){return s.add(R.box(.045,.07,.28),{pos:[0,.05,.1],color:re}),s.add(R.box(.035,.1,.04),{pos:[0,-.03,0],rot:[.3,0,0],color:Ti}),s.add(R.box(.03,.17,.035),{pos:[0,-.06,.16],rot:[.12,0,0],color:Ti}),s.add(R.cyl(.02,.02,.2,10),{pos:[0,.055,.32],rot:[Math.PI/2,0,0],color:re}),s.add(R.box(.012,.012,.22),{pos:[.015,.05,-.12],color:Ti}),s.add(R.box(.012,.012,.22),{pos:[-.015,.05,-.12],color:Ti}),s.add(R.box(.045,.06,.015),{pos:[0,.04,-.23],color:re}),s.add(R.box(.02,.03,.06),{pos:[0,.1,.06],color:re}),{grip:[0,-.02,0],fore:[0,-.04,.17],muzzle:[0,.055,.43],eject:[-.03,.06,.08]}}function ov(s){return s.add(R.box(.032,.035,.19),{pos:[0,.06,.07],color:re}),s.add(R.box(.03,.03,.15),{pos:[0,.03,.06],color:Ti}),s.add(R.box(.03,.11,.045),{pos:[0,-.02,0],rot:[.25,0,0],color:2763306}),s.add(R.torus(.02,.004,4,10,Math.PI),{pos:[0,.015,.05],rot:[0,Math.PI/2,Math.PI],color:re}),{grip:[0,-.02,0],fore:[.03,-.035,.01],muzzle:[0,.06,.17],eject:[-.02,.07,.06]}}function av(s,t){s.add(R.box(.13,.14,.32),{pos:[0,.05,.08],color:Ti}),s.add(R.box(.03,.1,.045),{pos:[0,-.06,0],rot:[.3,0,0],color:re}),s.add(R.box(.02,.1,.02),{pos:[0,.17,0],color:re}),s.add(R.box(.02,.02,.24),{pos:[0,.22,.1],color:re}),s.add(R.box(.02,.1,.02),{pos:[0,.17,.2],color:re}),s.add(R.box(.12,.14,.16),{pos:[.13,0,.05],color:3951148}),s.add(R.cyl(.06,.06,.06,12),{pos:[0,.05,.27],rot:[Math.PI/2,0,0],color:re});for(let e=0;e<6;e++){let i=e/6*Math.PI*2;t.add(R.cyl(.011,.011,.6,6),{pos:[Math.cos(i)*.035,Math.sin(i)*.035,.3],rot:[Math.PI/2,0,0],color:re})}return t.add(R.cyl(.05,.05,.02,12),{pos:[0,0,.12],rot:[Math.PI/2,0,0],color:Ti}),t.add(R.cyl(.05,.05,.02,12),{pos:[0,0,.55],rot:[Math.PI/2,0,0],color:Ti}),{grip:[0,-.04,0],fore:[0,.2,.12],muzzle:[0,.05,.92],eject:[-.07,.03,.08],spinOrigin:[0,.05,.3]}}var Js=null;function Pn(s){Js||(Js=new je({vertexColors:!0,map:ae.metal(),roughness:.5,metalness:.45}));let t=new se,e=new se,i={rifle:iv,shotgun:nv,sniper:sv,smg:rv,pistol:ov,minigun:l=>av(l,e)}[s](t),n=new fe,r=new Et(t.build(),Js);r.castShadow=!0,n.add(r);let o=null;e.parts.length&&(o=new Et(e.build(),Js),o.position.fromArray(i.spinOrigin),o.geometry.translate(0,0,-.3),o.position.z=.3,o.castShadow=!0,n.add(o));let a={};for(let l of Object.keys(i))a[l]=new T().fromArray(i[l]);return{group:n,sockets:a,spinner:o}}function Ln(){let s=new se;s.add(R.sphere(.055,12,10),{scale:[1,1.2,1],color:4872748});for(let e=0;e<4;e++)s.add(R.torus(.054-Math.abs(e-1.5)*.01,.006,4,12),{pos:[0,-.04+e*.027,0],rot:[Math.PI/2,0,0],color:3819554});s.add(R.cyl(.02,.022,.03,8),{pos:[0,.075,0],color:6974042}),s.add(R.box(.012,.07,.02),{pos:[.025,.06,0],rot:[0,0,-.3],color:9079418}),s.add(R.torus(.014,.003,4,10),{pos:[-.02,.09,0],color:11579552}),Js||Pn("pistol");let t=new Et(s.build(),Js);return t.castShadow=!0,t}var lv=["spine","chest","neck","head","armL","foreL","handL","armR","foreR","handR","wingL","wingR"],Ze=Math.PI,Te=s=>s*s*(3-2*s),pn=s=>1-(1-s)*(1-s),Dn=class{constructor(t){this.index=t,this.n=Object.keys(t).length,this.r=new Float32Array(this.n*3),this.h=new Float32Array(3),this.g=new Float32Array(6),this.lh=new Float32Array(4),this.rh=new Float32Array(4)}zero(){return this.r.fill(0),this.h.fill(0),this.g.fill(0),this.lh.fill(0),this.rh.fill(0),this}set(t,e,i=0,n=0){let r=this.index[t];return r===void 0?this:(this.r[r*3]=e,this.r[r*3+1]=i,this.r[r*3+2]=n,this)}add(t,e,i=0,n=0){let r=this.index[t];return r===void 0?this:(this.r[r*3]+=e,this.r[r*3+1]+=i,this.r[r*3+2]+=n,this)}gun(t,e,i,n=0,r=0,o=0){return this.g.set([t,e,i,n,r,o]),this}left(t,e,i,n){return this.lh.set([t,e,i,n]),this}right(t,e,i,n){return this.rh.set([t,e,i,n]),this}copy(t){return this.r.set(t.r),this.h.set(t.h),this.g.set(t.g),this.lh.set(t.lh),this.rh.set(t.rh),this}blend(t,e){let i=this.r,n=t.r;for(let r=0;r<i.length;r++)i[r]+=(n[r]-i[r])*e;for(let r=0;r<3;r++)this.h[r]+=(t.h[r]-this.h[r])*e;for(let r=0;r<6;r++)this.g[r]+=(t.g[r]-this.g[r])*e;for(let r=0;r<4;r++)this.lh[r]+=(t.lh[r]-this.lh[r])*e,this.rh[r]+=(t.rh[r]-this.rh[r])*e;return this}blendBones(t,e,i){for(let n of i){let r=this.index[n];if(r!==void 0)for(let o=0;o<3;o++)this.r[r*3+o]+=(t.r[r*3+o]-this.r[r*3+o])*e}for(let n=0;n<6;n++)this.g[n]+=(t.g[n]-this.g[n])*e;for(let n=0;n<4;n++)this.lh[n]+=(t.lh[n]-this.lh[n])*e,this.rh[n]+=(t.rh[n]-this.rh[n])*e}addScaled(t,e){for(let i=0;i<this.r.length;i++)this.r[i]+=t.r[i]*e;for(let i=0;i<3;i++)this.h[i]+=t.h[i]*e}};function So(s,t,e,i,n={}){let r=n.base||0,o=n.knee0||.08;for(let[a,l]of[["L",0],["R",Ze]]){let c=t+l,h=-Math.sin(c)*e+r,u=o+i*Math.max(0,Math.cos(c))+(n.kneeBase||0);s.set("thigh"+a,h,0,a==="L"?.03:-.03),s.set("shin"+a,u),s.set("foot"+a,-(h+u)*.55+(n.foot||0))}}function ap(s,t,e,i,n=.12){s.set("armL",Math.sin(t)*e,0,n),s.set("armR",-Math.sin(t)*e,0,-n),s.set("foreL",-i-Math.max(0,-Math.sin(t))*.3),s.set("foreR",-i-Math.max(0,Math.sin(t))*.3)}function wo(s){s.h[1]=-.45,s.set("thighL",-1.4,0,.08),s.set("shinL",1.4),s.set("footL",0),s.set("thighR",.08,0,-.06),s.set("shinR",1.5),s.set("footR",.6),s.set("spine",.12)}var lp={idle(s,t){let e=Math.sin(t*1.7);s.h[1]=-.012+e*.004,s.set("thighL",-.06,0,.05),s.set("shinL",.1),s.set("footL",-.04),s.set("thighR",.05,0,-.06),s.set("shinR",.08),s.set("footR",-.1),s.set("spine",.02+e*.01),s.set("chest",e*.015),s.set("armL",.05,0,.12),s.set("armR",.05,0,-.12),s.set("foreL",-.2),s.set("foreR",-.2)},locomotion(s,t,e){let i=e.gait,n=i<1?De(.42,.68,i):De(.68,.85,i-1),r=i<1?De(.75,1.35,i):De(1.35,1.7,i-1),o=e.phase;So(s,o,n,r),s.h[1]=-Math.abs(Math.sin(o))*(.03+.03*i)-.02*i,s.set("hips",0,Math.sin(o)*.08,0),s.set("spine",.05+.08*i,-Math.sin(o)*.06),s.set("chest",.02,-Math.sin(o)*.05),ap(s,o,n*.8,.35+.5*Math.min(i,1))},crouch(s,t){wo(s),s.set("spine",.18+Math.sin(t*1.6)*.01)},crouchWalk(s,t,e){let i=e.phase;So(s,i,.38,.9,{base:-.75,knee0:1.1}),s.h[1]=-.3-Math.abs(Math.sin(i))*.02,s.set("spine",.32)},jump(s){s.set("thighL",-.9),s.set("shinL",1.3),s.set("footL",.2),s.set("thighR",-.2),s.set("shinR",.7),s.set("footR",.3),s.set("spine",.12)},fall(s,t){s.set("thighL",-.4),s.set("shinL",.4),s.set("thighR",-.1),s.set("shinR",.6),s.set("armL",-.4,0,.5+Math.sin(t*9)*.05),s.set("armR",-.4,0,-.5)},land(s){s.h[1]=-.2,s.set("thighL",-.7),s.set("shinL",1.2),s.set("footL",-.5),s.set("thighR",-.6),s.set("shinR",1.1),s.set("footR",-.5),s.set("spine",.3)},roll(s,t,e){let i=$t(t/(e.rollTime||.7),0,1),n=Math.sin(Ze*i);s.h[1]=-.6*n,s.h[2]=.15*n,s.set("hips",2*Ze*Te(i)),s.set("thighL",-1.7*n),s.set("shinL",2.2*n),s.set("thighR",-1.5*n),s.set("shinR",2.1*n),s.set("spine",.6*n),s.set("chest",.4*n),s.set("head",.6*n)},death(s,t){let e=$t(t/1.1,0,1),i=pn(e);if(e<.3){let n=e/.3;s.set("thighL",-.5*n),s.set("shinL",1.4*n),s.set("thighR",.1),s.set("shinR",1.6*n),s.h[1]=-.35*n,s.set("spine",-.2*n),s.set("head",-.4*n)}else{let n=Te((e-.3)/.7);s.set("hips",-Ze/2*n),s.h[1]=-.35-.48*n,s.h[2]=-.3*n,s.set("thighL",-.5*(1-n)-.2*n),s.set("shinL",1.4*(1-n)+.3*n),s.set("thighR",.1),s.set("shinR",1.6*(1-n)+.2*n),s.set("spine",-.2*(1-n)),s.set("head",-.4*(1-n)+.3*n,.5*n)}s.set("armL",-.3*i,0,1.3*i),s.set("foreL",-.6*i),s.set("armR",-.6*i,0,-1.1*i),s.set("foreR",-.4*i)},pickup(s,t){wo(s),s.set("spine",.45),s.set("chest",.25)}},eu=[-.135,.19,.33],cp={aim(s,t,e){let i=e.weapon==="pistol",n=e.weapon==="minigun";i?s.gun(-.06,.2,.52,0,.02,0):n?s.gun(-.2,-.06,.32,0,.05,0):s.gun(eu[0],eu[1],eu[2],0,.03,0),s.set("neck",.05,.12),s.set("head",.08,.05,.06)},ready(s,t,e){let i=Math.sin(t*1.7)*.01;e.weapon==="pistol"?s.gun(-.12,-.02,.32,.6+i,.15,0):e.weapon==="minigun"?s.gun(-.2,-.1,.3,.12+i,.1,0):s.gun(-.12,.02,.28,.42+i,.38,.1)},sprint(s,t,e){e.weapon==="pistol"?s.gun(-.15,-.05,.25,1,.2,0):e.weapon==="minigun"?s.gun(-.2,-.12,.28,.3,.2,0):s.gun(-.05,.08,.26,.75,.95,.35)},reload(s,t,e){let i=$t(e.reloadT??0,0,1);s.gun(-.08,.02,.3,.35,.55,.45);let n=[-.04,-.1,.36],r=[.16,-.42,.06],o,a,l,c;if(i<.2){let h=Te(i/.2);[o,a,l]=n,c=h}else if(i<.45){let h=Te((i-.2)/.25);o=De(n[0],r[0],h),a=De(n[1],r[1],h),l=De(n[2],r[2],h),c=1}else if(i<.7){let h=Te((i-.45)/.25);o=De(r[0],n[0],h),a=De(r[1],n[1],h),l=De(r[2],n[2],h),c=1}else{let h=Te((i-.7)/.3);[o,a,l]=n,c=1-h}s.left(o,a,l,c),s.set("head",.35,.25),s.set("chest",.1)},switch(s,t,e){let i=$t(e.switchT??0,0,1),n=Math.sin(Ze*i);s.gun(-.12,.02-.35*n,.28-.1*n,.42+.8*n,.38,.1),s.set("chest",.15*n)},throw(s,t,e){let i=$t(e.throwT??0,0,1);s.gun(.02,-.12,.25,.9,-.5,.3);let n,r,o;if(i<.45){let a=Te(i/.45);n=De(-.25,-.32,a),r=De(0,.42,a),o=De(.2,-.25,a)}else{let a=pn((i-.45)/.55);n=De(-.32,-.1,a),r=De(.42,.25,a),o=De(-.25,.55,a)}s.right(n,r,o,1),s.set("chest",0,i<.45?.35*Te(i/.45):.35-.7*pn((i-.45)/.55))},heal(s,t,e){s.gun(-.12,-.04,.26,.7,.3,.1),s.left(.02,.12+Math.sin(t*6)*.02,.2,1),s.set("head",.4)},interact(s,t){s.gun(-.12,-.02,.26,.6,.4,.1);let e=$t(t/.5,0,1);s.left(.12,.12,.25+.3*Math.sin(Ze*e),1)},pickup(s,t){s.gun(-.12,-.04,.26,.8,.4,.1);let e=$t(t/.45,0,1);s.left(.14,-.55*Math.sin(Ze*e),.38,1),s.set("head",.5*Math.sin(Ze*e))}},cv={hit(s){s.set("spine",-.22),s.set("chest",-.12,.1),s.set("head",-.3,.2),s.h[2]=-.04},recoil(s){s.set("chest",-.06),s.set("head",-.02)}};function Kl(s,t){s.h[1]=-.06,s.set("thighL",-.28,0,.1),s.set("shinL",.55),s.set("footL",-.27),s.set("thighR",-.28,0,-.1),s.set("shinR",.55),s.set("footR",-.27)}var Eo={idle(s,t){Kl(s,t);let e=Math.sin(t*2.1);s.set("spine",.18+e*.03),s.set("chest",.18+e*.02),s.set("neck",-.15),s.set("head",-.2+Math.sin(t*.7)*.15,Math.sin(t*.5)*.4),s.set("armL",-.2,0,.3+e*.04),s.set("armR",-.2,0,-.3-e*.04),s.set("foreL",-.55),s.set("foreR",-.55),s.set("handL",-.3+Math.sin(t*7)*.1),s.set("handR",-.3+Math.cos(t*6)*.1)},move(s,t,e){let i=e.gait,n=e.phase,r=De(.45,.8,i),o=De(.8,1.5,i);So(s,n,r,o,{kneeBase:.3,base:-.15}),s.h[1]=-.06-Math.abs(Math.sin(n))*.05,s.set("hips",0,Math.sin(n)*.12),s.set("spine",.25+.2*i,-Math.sin(n)*.1),s.set("chest",.15+.15*i),s.set("neck",-.2-.2*i),s.set("head",-.15),i>.5?(s.set("armL",-.6+Math.sin(n)*.5,0,.35),s.set("armR",-.6-Math.sin(n)*.5,0,-.35),s.set("foreL",-.9),s.set("foreR",-.9)):ap(s,n,.5,.5,.3)},attack(s,t,e){Kl(s,t);let i=$t(e.attackT??0,0,1),n=e.side||1,r=n>0?"R":"L",o=n>0?"L":"R",a,l;i<.45?(a=Te(i/.45),l=0):(a=1-pn((i-.45)/.55),l=pn($t((i-.45)/.25,0,1))),s.set("arm"+r,-2.4*a-.6*l,0,-n*(.6*a-.4*l)),s.set("fore"+r,-.8*a-.2),s.set("arm"+o,-.4,0,n*.4),s.set("fore"+o,-.7),s.set("spine",.1+.45*l,n*(.4*a-.6*l)),s.set("chest",.1+.2*l,n*(.3*a-.4*l)),s.set("head",-.3*a)},spit(s,t,e){Kl(s,t);let i=$t(e.attackT??0,0,1),n=i<.55?Te(i/.55):1-pn((i-.55)/.45)*1.6;s.set("spine",-.3*n+.1),s.set("chest",-.3*n),s.set("neck",-.4*n),s.set("head",-.3*n),s.set("armL",-.3,0,.6),s.set("armR",-.3,0,-.6),s.set("foreL",-1),s.set("foreR",-1)},roar(s,t,e){Kl(s,t);let i=$t(t/1.2,0,1),n=Math.sin(Ze*i);s.set("spine",-.3*n),s.set("chest",-.25*n),s.set("neck",-.3*n),s.set("head",-.4*n+Math.sin(t*30)*.03*n),s.set("armL",-.6*n,0,1*n+.2),s.set("armR",-.6*n,0,-1*n-.2),s.set("foreL",-1.2*n),s.set("foreR",-1.2*n)},spawn(s,t){let e=$t(t/1,0,1),i=1-Te(e);wo(s);for(let n=0;n<s.r.length;n++)s.r[n]*=i;s.h[1]=-.45*i-.06*(1-i),s.set("spine",.8*i+.2),s.set("head",-.4*i),s.set("armL",-.5*i,0,.4),s.set("armR",-.5*i,0,-.4)},death(s,t){let e=$t(t/1.2,0,1);if(e<.35){let i=Te(e/.35);wo(s);for(let n=0;n<s.r.length;n++)s.r[n]*=i;s.h[1]=-.45*i,s.set("spine",-.4*i),s.set("head",-.6*i),s.set("armL",-.5*i,0,.6*i),s.set("armR",-.3*i,0,-.9*i)}else{let i=Te((e-.35)/.65);wo(s),s.set("hips",Ze/2*i),s.h[1]=-.45-.35*i,s.h[2]=.35*i,s.set("spine",-.4*(1-i)+.1*i),s.set("head",-.6*(1-i)-.3*i,.6*i),s.set("armL",-.5-1.6*i,0,.6+.3*i),s.set("armR",-.3-2*i,0,-.9),s.set("foreL",-.3),s.set("foreR",-.6),s.set("thighL",-1.4*(1-i)),s.set("shinL",1.4*(1-i)+.2),s.set("thighR",.3*i),s.set("shinR",1.5*(1-i))}}},su={idle(s,t){let e=Math.sin(t*1.4);s.h[1]=-.05+e*.01,s.set("thighL",-.2,0,.15),s.set("shinL",.35),s.set("footL",-.15),s.set("thighR",-.2,0,-.15),s.set("shinR",.35),s.set("footR",-.15),s.set("spine",.25+e*.04),s.set("chest",.2+e*.03),s.set("neck",-.3),s.set("head",-.15,Math.sin(t*.4)*.3),s.set("armL",-.15,0,.35),s.set("armR",-.15,0,-.35),s.set("foreL",-.4),s.set("foreR",-.4)},move(s,t,e){let i=e.phase,n=e.gait;So(s,i,.38+.12*n,.7+.3*n,{base:-.12,kneeBase:.15}),s.set("hips",0,Math.sin(i)*.1,Math.sin(i)*.08),s.h[1]=-.05-Math.abs(Math.cos(i))*.06,s.set("spine",.3+.1*n,-Math.sin(i)*.12,-Math.sin(i)*.06),s.set("chest",.2),s.set("neck",-.35),s.set("head",-.1),s.set("armL",Math.sin(i)*.45-.1,0,.4),s.set("armR",-Math.sin(i)*.45-.1,0,-.4),s.set("foreL",-.5),s.set("foreR",-.5)},attack(s,t,e){su.idle(s,t);let i=$t(e.attackT??0,0,1),n,r;i<.5?(n=Te(i/.5),r=0):(n=1-pn((i-.5)/.2>1?1:(i-.5)/.2),r=i<.8?pn((i-.5)/.3):1-Te((i-.8)/.2)),s.set("armL",-2.8*n-.8*r,0,.3),s.set("armR",-2.8*n-.8*r,0,-.3),s.set("foreL",-.6*n),s.set("foreR",-.6*n),s.set("spine",.25-.4*n+.6*r),s.set("chest",.2-.2*n+.3*r),s.h[1]=-.05-.2*r},slam(s,t,e){let i=$t(e.attackT??0,0,1);su.idle(s,t);let n=i<.45?Math.sin(i/.45*Ze*.5):Math.max(0,1-(i-.45)/.12),r=i>.55?1-Te($t((i-.55)/.45,0,1)):0;s.h[1]=.35*n-.3*r,s.set("armL",-2.6*n-.5*r,0,.5),s.set("armR",-2.6*n-.5*r,0,-.5),s.set("thighL",-.6*n-.7*r),s.set("shinL",.9*n+1.2*r),s.set("thighR",-.6*n-.7*r),s.set("shinR",.9*n+1.2*r),s.set("spine",-.2*n+.6*r),s.set("neck",-.3+.2*n)},roar(s,t,e){Eo.roar(s,t,e),s.set("thighL",-.2,0,.2),s.set("thighR",-.2,0,-.2),s.set("shinL",.3),s.set("shinR",.3)},spawn(s,t){Eo.spawn(s,t)},death(s,t){let e=$t(t/1.5,0,1),i=Te(e);s.set("hips",-Ze/2*i),s.h[1]=-.62*i,s.h[2]=-.4*i,s.set("thighL",-.5*i),s.set("shinL",.6*i),s.set("thighR",-.2*i),s.set("shinR",.4*i),s.set("armL",-.5*i,0,1.2*i),s.set("armR",-.5*i,0,-1.2*i),s.set("head",.5*i,.5*i)}};function iu(s,t,e,i){for(let[n,r]of[["L",1],["R",-1]])for(let[o,a,l,c]of[["arm","fore","hand",0],["thigh","shin","foot",Ze]]){let h=t+c+(n==="L"?0:Ze),u=Math.sin(h)*e,f=Math.max(0,Math.cos(h))*i;s.set(o+n,-u*.5,r*u,r*(.95+f)),s.set(a+n,0,0,-r*(1.45-f*.4)),s.set(l+n,0,0,r*.4)}}var Ql={idle(s,t){iu(s,t*.5,.05,0),s.h[1]=-.12+Math.sin(t*2)*.015,s.set("spine",0,Math.sin(t*1.3)*.1),s.set("head",Math.sin(t*.8)*.15,Math.sin(t*.6)*.4),s.set("tail",.3+Math.sin(t*1.7)*.15,Math.sin(t*1.1)*.4),s.set("tail2",.4)},move(s,t,e){let i=e.phase;iu(s,i,.45+.2*e.gait,.5),s.h[1]=-.1-Math.abs(Math.sin(i*2))*.03,s.set("spine",0,Math.sin(i)*.15),s.set("chest",0,-Math.sin(i)*.1),s.set("head",-.1,-Math.sin(i)*.1),s.set("tail",.25,Math.sin(i)*.5),s.set("tail2",.3,Math.sin(i-1)*.4)},attack(s,t,e){let i=$t(e.attackT??0,0,1);Ql.idle(s,t);let n=i<.4?Te(i/.4):1-pn((i-.4)/.6);s.set("hips",-.5*n),s.set("spine",-.2*n),s.set("head",.4*n);for(let[r,o]of[["L",1],["R",-1]])s.set("arm"+r,-1.6*n,0,o*(.9-.4*n)),s.set("fore"+r,-.6*n,0,-o*1.2*(1-n));s.h[1]=-.1+.25*n},spawn(s,t){Ql.idle(s,t),s.h[1]=-.6*(1-Te($t(t,0,1)))},roar(s,t,e){Ql.attack(s,t,{attackT:.4})},death(s,t){let e=Te($t(t/.9,0,1));iu(s,0,0,0);for(let i of["armL","foreL","thighL","shinL","armR","foreR","thighR","shinR"]){let n=s.index[i]*3;s.r[n+2]*=1-e*1.5}s.set("hips",0,0,Ze*e),s.h[1]=-.25*e,s.set("tail",.6*e),s.set("head",.6*e)}},ru={idle(s,t){let e=Math.sin(t*2.5);s.set("thighL",-.1,0,.25),s.set("thighR",-.1,0,-.25),s.set("shinL",.2),s.set("shinR",.2),s.set("spine",.1+e*.05,0,e*.05),s.set("head",-.2,Math.sin(t)*.4),s.set("armL",0,0,.6+e*.1),s.set("armR",0,0,-.6-e*.1),s.set("foreL",-.6),s.set("foreR",-.6)},move(s,t,e){let i=e.phase;So(s,i,.45,.8,{base:-.05}),s.set("thighL",s.r[s.index.thighL*3],0,.22),s.set("thighR",s.r[s.index.thighR*3],0,-.22),s.set("hips",0,0,Math.sin(i)*.18),s.set("spine",.25,0,-Math.sin(i)*.15),s.set("armL",-.8+Math.sin(i*2)*.4,0,.7),s.set("armR",-.8-Math.sin(i*2)*.4,0,-.7),s.set("foreL",-.8),s.set("foreR",-.8),s.set("head",-.3,Math.sin(i*2)*.3),s.h[1]=-Math.abs(Math.sin(i))*.06},attack(s,t,e){ru.idle(s,t*4)},spawn(s,t){Eo.spawn(s,t)},roar(s,t,e){ru.idle(s,t*3)},death(s,t){Eo.death(s,t)}},bo={idle(s,t){let e=Math.sin(t*11);s.set("wingL",0,0,.25+e*.75),s.set("wingR",0,0,-.25-e*.75),s.set("hips",.25),s.set("thighL",.3,0,.1),s.set("thighR",.45,0,-.1),s.set("shinL",.9),s.set("shinR",.7),s.set("footL",.6),s.set("footR",.6),s.set("spine",.1),s.set("chest",.1+e*.04),s.set("head",-.3),s.set("armL",-.6,0,.35),s.set("armR",-.6,0,-.35),s.set("foreL",-.9),s.set("foreR",-.9),s.h[1]=e*.06},move(s,t,e){let i=Math.sin(t*15);bo.idle(s,t),s.set("wingL",0,0,.15+i*.9),s.set("wingR",0,0,-.15-i*.9),s.set("hips",.7),s.set("head",-.8),s.set("thighL",.7),s.set("thighR",.8)},attack(s,t,e){let i=$t(e.attackT??0,0,1);bo.move(s,t,e);let n=Math.sin(Ze*i);s.set("armL",-1.6*n-.4,0,.3),s.set("armR",-1.6*n-.4,0,-.3),s.set("foreL",-.3),s.set("foreR",-.3),s.set("thighL",-.6*n+.3),s.set("thighR",-.6*n+.3)},spawn(s,t){bo.idle(s,t)},roar(s,t){bo.idle(s,t*1.5)},death(s,t){let e=Te($t(t/1,0,1));s.set("wingL",0,0,1.4*e),s.set("wingR",0,0,-1.4*e),s.set("hips",1.2*e,0,t*4),s.set("armL",-1,0,.6),s.set("armR",-1,0,-.6)}},tc={humanoid:Eo,brute:su,crawler:Ql,bloater:ru,flyer:bo},Qb=new T,Un=class{constructor(t,e,i=null){this.inst=t,this.clips=e,this.upperClips=i;let n=t.index;this.pose=new Dn(n),this.a=new Dn(n),this.b=new Dn(n),this.u=new Dn(n),this.ub=new Dn(n),this.tmp=new Dn(n),this.cur=null,this.prev=null,this.t=0,this.pt=0,this.fade=1,this.fadeDur=.2,this.upper=null,this.upperPrev=null,this.ut=0,this.upt=0,this.uFade=1,this.uFadeDur=.2,this.uWeight=0,this.additive=[],this.ctx={}}play(t,e=.2,i=!1){t===this.cur&&!i||(this.prev=this.cur,this.pt=this.t,this.cur=t,this.t=0,this.fade=this.prev?0:1,this.fadeDur=e)}playUpper(t,e=.18,i=!1){t===this.upper&&!i||(this.upperPrev=this.upper,this.upt=this.ut,this.upper=t,this.ut=0,this.uFade=this.upperPrev?0:1,this.uFadeDur=e)}impulse(t,e=1,i=6){for(let n of this.additive)if(n.name===t){n.w=Math.min(1.5,n.w+e);return}this.additive.push({name:t,w:e,decay:i})}update(t){let e=this.ctx;this.t+=t,this.pt+=t,this.fade=Math.min(1,this.fade+t/Math.max(.001,this.fadeDur));let i=this.pose;i.zero(),this.cur&&this.clips[this.cur](i,this.t,e),this.prev&&this.fade<1&&(this.b.zero(),this.clips[this.prev](this.b,this.pt,e),this.tmp.copy(this.b).blend(i,Te(this.fade)),i.copy(this.tmp));let n=this.upper?1:0;this.uWeight+=(n-this.uWeight)*Math.min(1,t*12),this.upperClips&&(this.upper||this.upperPrev)&&this.uWeight>.001&&(this.ut+=t,this.upt+=t,this.uFade=Math.min(1,this.uFade+t/Math.max(.001,this.uFadeDur)),this.u.zero(),this.upper&&this.upperClips[this.upper](this.u,this.ut,e),this.upperPrev&&this.uFade<1&&(this.ub.zero(),this.upperClips[this.upperPrev](this.ub,this.upt,e),this.ub.blend(this.u,Te(this.uFade)),this.u.copy(this.ub)),i.blendBones(this.u,this.uWeight,lv));for(let r=this.additive.length-1;r>=0;r--){let o=this.additive[r];this.tmp.zero(),cv[o.name](this.tmp,0,e),i.addScaled(this.tmp,Math.min(1,o.w)),o.w-=o.decay*t,o.w<=0&&this.additive.splice(r,1)}e.post&&e.post(i),this.apply()}apply(){let{bones:t,rest:e}=this.inst,i=this.pose.r;for(let o=0;o<t.length;o++)t[o].rotation.set(i[o*3],i[o*3+1],i[o*3+2]);let n=this.inst.b.hips,r=e[this.inst.index.hips];n.position.set(r.x+this.pose.h[0],r.y+this.pose.h[1],r.z+this.pose.h[2])}},vo=new T,Qs=new T,tr=new T,Mo=new T,np=new T,nu=new T,sp=new T,jl=new T,er=new T,rp=new Ut,op=new _e,tw=new _e,hv=new T(1,0,0);function ou(s,t,e,i,n,r){let o=t.position.length(),a=e.position.length();vo.copy(s.position),Qs.subVectors(i,vo);let l=Qs.length();if(l<1e-5)return;Qs.multiplyScalar(1/l),l=$t(l,Math.abs(o-a)+.01,(o+a)*.999),tr.subVectors(n,vo).cross(Qs).negate(),tr.lengthSq()<1e-8&&tr.set(1,0,0),tr.normalize();let c=Math.acos($t((o*o+l*l-a*a)/(2*o*l),-1,1));Mo.copy(Qs).applyAxisAngle(tr,c),np.copy(vo).addScaledVector(Mo,o),nu.copy(vo).addScaledVector(Qs,l).sub(np).normalize(),jl.copy(Mo).negate(),er.copy(nu).addScaledVector(Mo,-nu.dot(Mo)),er.lengthSq()<1e-8&&er.copy(tr).cross(jl),er.normalize(),sp.crossVectors(jl,er),rp.makeBasis(sp,jl,er),s.quaternion.setFromRotationMatrix(rp);let h=Math.acos($t((o*o+a*a-l*l)/(2*o*a),-1,1));t.quaternion.setFromAxisAngle(hv,-(Ze-h)),r&&(op.copy(s.quaternion).multiply(t.quaternion).invert(),e.quaternion.copy(op.multiply(r)))}var hp=new T,up=new T,uv=new T,lw=new Ut,dv=new _e().setFromEuler(new Re(-1.25,0,0)),fv=new T(-.7,-.35,-.45),pv=new T(.6,-.55,-.15),To=class{constructor(t,e){this.game=t;let i=e.player;this.maxHealth=i.maxHealth,this.health=i.maxHealth,this.maxArmor=i.maxArmor,this.armor=Math.min(i.startArmor,i.maxArmor),this.grenades=i.grenades,this.maxGrenades=i.maxGrenades,this.pos=new T,this.vel=new T,this.facing=0,this.onGround=!0,this.state="alive",this.crouch=!1,this.crouchT=0,this.rollT=-1,this.rollCd=0,this.rollDir=new T,this.landT=0,this.airT=0,this.hurtT=0,this.invuln=0,this.shieldT=0,this.speedT=0,this.overT=0,this.phase=0,this.stepAcc=0,this.action=null,this.actionT=0,this.actionDur=0,this.inWater=!1,this.inst=fn(js()),this.mesh=this.inst.mesh,this.mesh.castShadow=!0,this.mesh.receiveShadow=!0,t.scene.add(this.mesh),this.anim=new Un(this.inst,lp,cp),this.anim.play("idle",0),this.anim.playUpper("ready",0),this.pivot=new Ee,this.inst.b.chest.add(this.pivot),this.recoilZ=0,this.recoilX=0,this.weapons=[];for(let n of e.loadout){if(!zh[n])continue;let r={...zh[n],...e.weapons[n]||{}};(r.reserve===null||r.reserve==="inf")&&(r.reserve=1/0),(r.maxReserve===null||r.maxReserve==="inf")&&(r.maxReserve=1/0);let o=Pn(n);o.group.visible=!1,this.pivot.add(o.group),this.weapons.push({def:r,mag:r.mag,reserve:r.reserve,model:o,spin:0,spinVel:0})}if(!this.weapons.length)throw new Error("empty loadout");this.cur=0,this.weapons[0].model.group.visible=!0,this.fireCd=0,this.reloadT=-1,this.switchT=-1,this.switchTo=-1,this.throwT=-1,this.grenadeMesh=Ln(),this.grenadeMesh.visible=!1,this.inst.b.handR.add(this.grenadeMesh),this.grenadeMesh.position.set(0,-.1,.04),this.shieldMesh=new Et(new ci(1.15,24,16),new ye({color:7330047,transparent:!0,opacity:.18,blending:ke,depthWrite:!1,toneMapped:!1})),this.shieldMesh.visible=!1,t.scene.add(this.shieldMesh),this.aiming=!1,this.wantFire=!1}get weapon(){return this.weapons[this.cur]}get alive(){return this.state!=="dead"}get speedMul(){return this.speedT>0?1.4:1}get damageMul(){return this.overT>0?1.4:1}spawn(t,e){this.pos.set(t,this.game.world.groundHeight(t,e)+.05,e),this.vel.set(0,0,0),this.mesh.position.copy(this.pos)}startAction(t,e){this.action=t,this.actionT=0,this.actionDur=e}canAct(){return this.alive&&this.rollT<0&&this.reloadT<0&&this.switchT<0&&this.throwT<0&&!this.action}reload(){let t=this.weapon;return!this.alive||this.reloadT>=0||this.switchT>=0||this.throwT>=0?!1:t.mag>=t.def.mag||t.reserve<=0?(t.reserve<=0&&t.mag===0&&this.game.sfx("empty_click"),!1):(this.reloadT=0,this.action=null,this.game.sfx(t.def.reloadSound),!0)}switchWeapon(t=1){!this.alive||this.weapons.length<2||this.switchT>=0||this.throwT>=0||(this.reloadT=-1,this.switchT=0,this.switchTo=(this.cur+t+this.weapons.length)%this.weapons.length,this.game.sfx("weapon_switch"))}throwGrenade(){!this.alive||this.grenades<=0||this.throwT>=0||this.rollT>=0||this.switchT>=0||(this.reloadT=-1,this.throwT=0,this.grenades--,this.grenadeMesh.visible=!0,this.game.sfx("grenade_pin"))}jump(){if(!(!this.alive||!this.onGround||this.rollT>=0)){if(this.crouch){this.crouch=!1;return}this.vel.y=7.2,this.onGround=!1,this.anim.play("jump",.1),this.game.sfx("jump",this.pos)}}toggleCrouch(){!this.alive||this.rollT>=0||(this.crouch=!this.crouch)}roll(t){!this.alive||!this.onGround||this.rollT>=0||this.rollCd>0||(this.rollT=0,this.rollCd=1,this.crouch=!1,t.lengthSq()>.01?this.rollDir.copy(t).normalize():this.rollDir.set(Math.sin(this.facing),0,Math.cos(this.facing)),this.facing=Math.atan2(this.rollDir.x,this.rollDir.z),this.anim.play("roll",.08,!0),this.invuln=.35,this.game.sfx("roll",this.pos))}takeDamage(t,e,i="melee"){if(!this.alive||this.game.cfg.debug.god||this.invuln>0&&i!=="trap")return 0;if(this.shieldT>0)return this.game.fx.sparkle(this.pos.clone().setY(this.pos.y+1),7330047),0;let n=t;if(this.armor>0){let r=Math.min(this.armor,n*.6);this.armor-=r,n-=r,this.armor<=0&&this.game.sfx("armor_break")}return this.health-=n,this.game.stats.damageTaken+=t,this.hurtT=.3,this.anim.impulse("hit",.9,4),this.game.camRig.shake(Math.min(.6,.15+t/60)),this.game.hud.damage(e,this.pos,this.game.camRig.yaw,t),this.game.sfx(Math.random()<.5?"player_hurt_1":"player_hurt_2",null,.9),this.game.haptic(t>25?"heavy":"light"),this.health<=0&&this.die(),n}heal(t){this.health=Math.min(this.maxHealth,this.health+t)}die(){this.health=0,this.state="dead",this.reloadT=this.switchT=this.throwT=-1,this.anim.playUpper(null,.2),this.anim.play("death",.15),this.weapon.model.group.visible=!1,this.game.sfx("player_death"),this.game.onPlayerDeath()}update(t,e){let i=this.game,n=i.world,r=i.camRig;this.invuln=Math.max(0,this.invuln-t),this.rollCd=Math.max(0,this.rollCd-t),this.hurtT=Math.max(0,this.hurtT-t),this.shieldT>0&&(this.shieldT-=t),this.speedT>0&&(this.speedT-=t),this.overT>0&&(this.overT-=t);let o=this.alive;r.flatForward(hp),r.flatRight(up);let a=uv.set(0,0,0);o&&a.addScaledVector(hp,e.moveY).addScaledVector(up,e.moveX);let l=Math.min(1,a.length()),c=this.weapon,h=this.reloadT>=0||this.switchT>=0||this.throwT>=0,u=o&&e.sprint&&l>.5&&!this.aiming&&!this.crouch&&!e.fire&&this.rollT<0&&!h;this.sprinting=u,this.aiming=o&&e.aim&&this.rollT<0&&!u;let f=this.crouch?2:u?7.6:4.6;if(this.aiming&&(f=Math.min(f,3)),f*=c.def.moveMul*this.speedMul,this.inWater&&(f*=.6),this.rollT>=0){this.rollT+=t;let y=8.5*(1-this.rollT/.7*.6);this.vel.x=this.rollDir.x*y,this.vel.z=this.rollDir.z*y,this.rollT>=.7&&(this.rollT=-1)}else if(o){let M=a.x*f,y=a.z*f,_=this.onGround?14:3;this.vel.x+=(M-this.vel.x)*ze(_,t),this.vel.z+=(y-this.vel.z)*ze(_,t)}else this.vel.x*=.9,this.vel.z*=.9;let d=o&&(this.aiming||e.fire||this.fireHold>0);this.fireHold=Math.max(0,(this.fireHold||0)-t),this.rollT<0&&o&&(d?this.facing=go(this.facing,r.yaw+Math.PI,25,t):l>.1&&(this.facing=go(this.facing,Math.atan2(a.x,a.z),12,t))),this.vel.y-=20*t,this.pos.addScaledVector(this.vel,t),n.colliders.resolve(this.pos,.38,1.7);let g=n.groundHeight(this.pos.x,this.pos.z,this.pos.y),x=this.onGround;this.pos.y<=g+.02||this.onGround&&this.pos.y-g<.35&&this.vel.y<=0?(!x&&this.airT>.25&&(this.landT=.22,i.sfx("land",this.pos),i.fx.dust(this.pos,2),this.vel.y<-16&&this.takeDamage((-this.vel.y-16)*4,null,"trap")),this.pos.y=g,this.vel.y=Math.max(0,this.vel.y),this.onGround=!0,this.airT=0):(this.onGround=!1,this.airT+=t),this.inWater=g<Ie-.25,this.crouchT+=((this.crouch&&this.rollT<0?1:0)-this.crouchT)*ze(10,t);let m=Math.hypot(this.vel.x,this.vel.z);this.phase+=m*t*(u?1.05:1.45)*(this.crouch?1.6:1),this.stepAcc+=m*t;let p=u?1.7:this.crouch?.9:1.25;if(this.onGround&&this.stepAcc>p&&o&&this.rollT<0){this.stepAcc=0;let M=this.inWater?"step_water":n.colliders.deckHeight(this.pos.x,this.pos.z,this.pos.y)>-1/0?"step_wood":n.field.pathMask(this.pos.x,this.pos.z)>.4?Math.random()<.5?"step_dirt_1":"step_dirt_2":`step_grass_${1+Math.floor(Math.random()*3)}`;i.sfx(M,null,this.crouch?.4:u?1:.75),this.inWater?i.fx.splash(this.pos.clone().setY(Ie)):u&&i.fx.dust(this.pos,.6)}this._updateWeapons(t,e),this._updateAnimation(t,m,a),this.mesh.position.copy(this.pos),this.mesh.rotation.y=this.facing,this.shieldT>0?(this.shieldMesh.visible=!0,this.shieldMesh.position.set(this.pos.x,this.pos.y+.95,this.pos.z),this.shieldMesh.material.opacity=.14+Math.sin(i.time*8)*.05+(this.shieldT<2?Math.sin(i.time*30)>0?.08:-.08:0)):this.shieldMesh.visible=!1}_updateWeapons(t,e){let i=this.game,n=this.weapon;if(this.fireCd-=t,!this.alive)return;if(n.def.spinUp>0){let o=e.fire&&this.reloadT<0&&this.switchT<0&&this.rollT<0?1:0;n.spin+=(o-n.spin)*ze(o?1/n.def.spinUp*2.2:2.5,t),n.spinVel=n.spin*60,n.model.spinner&&(n.model.spinner.rotation.z+=n.spinVel*t),n.spin>.05?i.audio.loop("minigun","minigun_spin",n.spin,"sfx"):i.audio.stopLoop("minigun",.3)}if(this.reloadT>=0&&(this.reloadT+=t/n.def.reload,this.reloadT>=1)){let o=n.def.mag-n.mag,a=Math.min(o,n.reserve);n.mag+=a,n.reserve!==1/0&&(n.reserve-=a),this.reloadT=-1}if(this.switchT>=0){let o=this.switchT;this.switchT+=t/.55,o<.5&&this.switchT>=.5&&(this.weapon.model.group.visible=!1,this.cur=this.switchTo,this.weapon.model.group.visible=!0,i.hud.weaponChanged()),this.switchT>=1&&(this.switchT=-1)}if(this.throwT>=0){let o=this.throwT;if(this.throwT+=t/.75,o<.55&&this.throwT>=.55){this.grenadeMesh.visible=!1;let a=new T;this.inst.b.handR.getWorldPosition(a);let l=i.camRig.forward(new T);l.y+=.28,l.normalize(),i.projectiles.grenade(a,l.multiplyScalar(Zs.throwSpeed),this)}this.throwT>=1&&(this.throwT=-1)}n.mag===0&&this.reloadT<0&&n.reserve>0&&this.switchT<0&&this.throwT<0&&this.reload();let r=this.reloadT<0&&this.switchT<0&&this.throwT<0&&this.rollT<0&&!this.sprinting&&(n.def.spinUp===0||n.spin>.85);if(e.fire&&(this.fireHold=.6),e.fire&&r&&this.fireCd<=0){if(!n.def.auto&&this._triggerHeld)return;if(n.mag<=0){this._triggerHeld||i.sfx("empty_click"),this._triggerHeld=!0;return}this._triggerHeld=!0,n.mag--;let o=this.overT>0?1.25:1;this.fireCd=n.def.fireInterval/o,i.combat.fire(this,n),this.recoilZ=-.05*Math.min(2,n.def.recoil),this.recoilX=-.06*Math.min(2.5,n.def.recoil),this.anim.impulse("recoil",Math.min(1,n.def.recoil*.3),8),this.action&&(this.action=null)}e.fire||(this._triggerHeld=!1)}muzzleWorld(t){let e=this.weapon;return t.copy(e.model.sockets.muzzle).applyMatrix4(e.model.group.matrixWorld)}_updateAnimation(t,e,i){let n=this.anim,r=n.ctx;if(r.weapon=this.weapon.def.id,r.phase=this.phase,r.reloadT=this.reloadT,r.switchT=this.switchT,r.throwT=this.throwT,r.rollTime=.7,this.alive){let a;this.rollT>=0?a="roll":this.action==="pickup"?a="pickup":!this.onGround&&this.airT>.12?a=this.vel.y>0?"jump":"fall":this.landT>0?a="land":this.crouch?a=e>.4?"crouchWalk":"crouch":a=e>.4?"locomotion":"idle",this.landT-=t,r.gait=this.sprinting?2:$t((e-1.5)/3.5,0,1);let l=e>.4?mo(Math.atan2(this.vel.x,this.vel.z)-this.facing):0;Math.abs(l)>1.9&&(r.phase=-this.phase),n.play(a,a==="land"?.06:.18);let c;this.reloadT>=0?c="reload":this.switchT>=0?c="switch":this.throwT>=0?c="throw":this.action==="heal"?c="heal":this.action==="interact"?c="interact":this.action==="pickup"?c="pickup":this.aiming||this.fireHold>0?c="aim":this.sprinting?c="sprint":c="ready",n.playUpper(c,c==="aim"?.1:.2),this.action&&(this.actionT+=t,this.actionT>=this.actionDur&&(this.action=null));let h=Math.abs(l)<1.9?$t(l,-.9,.9):$t(mo(l+Math.PI),-.9,.9);this.strafe=(this.strafe||0)+((e>.4&&this.rollT<0?h:0)-(this.strafe||0))*ze(8,t);let u=this.game.camRig.pitch;r.post=f=>{if(!this.alive||this.rollT>=0)return;f.add("hips",0,this.strafe,0),f.add("spine",0,-this.strafe*.6,0),f.add("chest",0,-this.strafe*.4,0);let d=this.anim.upper==="aim"?1:.35;f.add("spine",-u*.5*d,0,0),f.add("chest",-u*.5*d,0,0),f.add("head",-u*.25*(1-d),0,0)}}n.update(t),this.recoilZ+=(0-this.recoilZ)*ze(14,t),this.recoilX+=(0-this.recoilX)*ze(12,t);let o=n.pose;if(this.pivot.position.set(o.g[0],o.g[1],o.g[2]+this.recoilZ),this.pivot.rotation.set(o.g[3]+this.recoilX,o.g[4],o.g[5]),this.pivot.updateMatrix(),this.alive){let a=this.weapon.model.sockets,l=mv.copy(this.pivot.quaternion).multiply(dv),c=gv.set(0,1,0).applyQuaternion(l).multiplyScalar(.075),h=xv.copy(a.grip).applyMatrix4(this.pivot.matrix).add(c),u=_v.copy(a.fore).applyMatrix4(this.pivot.matrix).add(c);o.lh[3]>.001&&u.lerp(dp.set(o.lh[0],o.lh[1],o.lh[2]),o.lh[3]),o.rh[3]>.001&&h.lerp(dp.set(o.rh[0],o.rh[1],o.rh[2]),o.rh[3]);let f=this.inst.b;ou(f.armR,f.foreR,f.handR,h,fv,l),ou(f.armL,f.foreL,f.handL,u,pv,o.lh[3]>.5?null:l)}}},mv=new _e,gv=new T,xv=new T,_v=new T,dp=new T;var au=_i(99),fp=new T,lu=new T,pp=new T,cu=new T,ec=class{constructor(t,e,i){this.camera=t,this.world=e,this.settings=i,this.yaw=0,this.pitch=-.12,this.dist=3.4,this.curDist=3.4,this.shoulder=i.shoulder??1,this.curShoulder=this.shoulder,this.aimT=0,this.trauma=0,this.time=0,this.pivot=new T,this.fovBase=i.fov??70,this.zoomFov=50,this.scoped=!1,this.recoilPitch=0,this.recoilYaw=0}addLook(t,e,i){let n=this.settings,r=.0042*(n.sensitivity??1)*(i?(n.aimSensitivity??.6)*(this.scoped?.35:1):1);this.yaw-=t*r,this.pitch-=e*r*(n.invertY?-1:1),this.pitch=$t(this.pitch,-1.15,.85)}kick(t,e){this.recoilPitch+=t,this.recoilYaw+=e}shake(t){this.trauma=Math.min(1,this.trauma+t*(this.settings.cameraShake??1))}forward(t){return t.set(-Math.sin(this.yaw)*Math.cos(this.pitch),Math.sin(this.pitch),-Math.cos(this.yaw)*Math.cos(this.pitch))}flatForward(t){return t.set(-Math.sin(this.yaw),0,-Math.cos(this.yaw))}flatRight(t){return t.set(Math.cos(this.yaw),0,-Math.sin(this.yaw))}update(t,e,i,n,r){this.time+=t;let o=this.recoilPitch*ze(10,t),a=this.recoilYaw*ze(10,t);this.pitch=$t(this.pitch+o,-1.15,.85),this.yaw+=a,this.recoilPitch-=o,this.recoilYaw-=a,this.aimT+=((i?1:0)-this.aimT)*ze(12,t),this.scoped=r&&this.aimT>.6,this.curShoulder+=(this.shoulder-this.curShoulder)*ze(8,t);let c=1.62-.45*e.crouchT+(e.state==="dead"?-.9:0);fp.set(e.pos.x,e.pos.y+c,e.pos.z),this.pivot.lerp(fp,this.pivot.lengthSq()===0?1:ze(18,t));let h=ho.lerp(3.3,this.scoped?.2:1.55,this.aimT)+(e.state==="dead"?2.5:0),u=ho.lerp(.62,this.scoped?.12:.5,this.aimT)*this.curShoulder;this.forward(lu),this.flatRight(pp);let f=cu.copy(this.pivot).addScaledVector(pp,u);f.y+=.08;let d=h,g=lu.clone().negate(),x=this.world.raycastTerrain(f,g,h+.3);x>=0&&(d=Math.min(d,Math.max(.3,x-.35)));let m=this.world.colliders.raycast(f.x,f.y,f.z,g.x,g.y,g.z,h+.3,w=>w.kind!=="rail"&&w.r>.2);m&&(d=Math.min(d,Math.max(.3,m.t-.3))),this.curDist=d<this.curDist?d:this.curDist+(d-this.curDist)*ze(4,t);let p=this.camera;p.position.copy(f).addScaledVector(g,this.curDist);let M=this.world.height(p.position.x,p.position.z)+.25;p.position.y<M&&(p.position.y=M),this.trauma=Math.max(0,this.trauma-t*1.6);let y=this.trauma*this.trauma,_=this.time*22,b=au(_,1.7)*.06*y,E=au(_,9.1)*.06*y,P=au(_,4.4)*.05*y;p.position.x+=b,p.position.y+=E,cu.copy(p.position).add(lu),p.lookAt(cu),p.rotateZ(P);let L=ho.lerp(this.settings.fov??70,n,this.aimT);Math.abs(p.fov-L)>.05&&(p.fov=L,p.updateProjectionMatrix()),p.updateMatrixWorld()}};var mn=new T,Oi=new T,ir=new T,hu=new T,Ge=new T,ic=new T,uu=new T,mp=new _e,du=new T,gp=new T,nc=class{constructor(t){this.game=t}raycast(t,e,i,n=1,r=!1){let o=this.game,a=i,l="none",c=null,h=o.world.raycastTerrain(t,e,i);h>=0&&h<a&&(a=h,l="terrain");let u=o.world.colliders.raycast(t.x,t.y,t.z,e.x,e.y,e.z,a,d=>d.kind!=="rail");u&&u.t<a&&(a=u.t,l="collider",c=u.collider);let f=[];if(!r){for(let d of o.enemies.active){if(!d.alive)continue;let g=d.rayHit(t,e,a);g&&f.push(g)}f.sort((d,g)=>d.t-g.t),f.length>n&&(f.length=n)}return{t:a,kind:l,collider:c,enemies:f}}fire(t,e){let i=this.game,n=e.def,r=i.camera,o=i.stats;r.getWorldDirection(ir),mn.copy(r.position);let a=uu.copy(t.pos).setY(t.pos.y+1.4).sub(mn).dot(ir);mn.addScaledVector(ir,Math.max(0,a)),t.muzzleWorld(hu);let l=t.aiming?n.spreadAim:n.spreadHip;if(t.crouch&&(l*=.7),Math.hypot(t.vel.x,t.vel.z)>1&&(l*=1.25),t.onGround||(l*=1.8),l*=zl,du.set(1,0,0).applyQuaternion(r.quaternion),gp.set(0,1,0).applyQuaternion(r.quaternion),i.cfg.settings.aimAssist&&n.pellets===1&&!i.camRig.scoped){let g=i.enemies.assistTarget(mn,ir,3.2*zl,n.range);g&&ir.lerp(g.sub(mn).normalize(),.65).normalize()}let h=!1,u=t.damageMul;for(let g=0;g<n.pellets;g++){let x=Math.random()*Math.PI*2,m=Math.sqrt(Math.random())*l;Oi.copy(ir).addScaledVector(du,Math.cos(x)*Math.tan(m)).addScaledVector(gp,Math.sin(x)*Math.tan(m)).normalize();let p=this.raycast(mn,Oi,n.range,n.penetration),M=p.t;for(let y of p.enemies){let _=y.t+Math.max(0,a),b=n.damage*u;_>n.falloff&&(b*=Math.max(.35,1-(_-n.falloff)/Math.max(1,n.range-n.falloff)*.65)),Ge.copy(mn).addScaledVector(Oi,y.t);let E=y.enemy.damage(b,Ge,Oi,y.part,{armorPiercing:n.armorPiercing,weapon:n.id});h=!0,y.part==="head"&&o.headshots++,i.hud.hitMarker(y.part==="head",E),M=y.t}if((p.enemies.length<n.penetration||p.enemies.length===0)&&(M=p.t,p.kind!=="none"))if(Ge.copy(mn).addScaledVector(Oi,p.t),p.kind==="terrain"){i.world.field.normal(Ge.x,Ge.z,ic);let y=i.world.isWater(Ge.x,Ge.z);i.fx.impact(Ge,ic,y?"water":(i.world.field.pathMask(Ge.x,Ge.z)>.3,"dirt")),g===0&&i.sfx("impact_dirt",Ge,.8)}else{let y=p.collider;ic.set(Ge.x-y.x,0,Ge.z-y.z).normalize();let _=y.kind==="rock"?"rock":y.kind==="barrel"?"metal":"wood";i.fx.impact(Ge,ic,_),g===0&&i.sfx(_==="rock"?"impact_rock":"impact_wood",Ge,.8),y.prop&&i.props.damage(y.prop,n.damage*u,Ge)}(n.pellets===1||g%3===0)&&(Ge.copy(mn).addScaledVector(Oi,Math.min(M,n.range)),i.fx.tracer(hu,Ge,n.id==="sniper"?500:300))}o.shotsFired++,h&&o.shotsHit++,e.model.group.getWorldQuaternion(mp),i.fx.muzzleFlash(hu,mp,n.id==="shotgun"||n.id==="sniper"?1.5:n.id==="pistol"?.7:1);let f=uu.copy(e.model.sockets.eject).applyMatrix4(e.model.group.matrixWorld);i.fx.shell(f,du.clone().negate(),n.shellScale),i.sfx(n.sound,null,1);let d=n.recoil*(t.aiming?.55:1)*(t.crouch?.75:1);i.camRig.kick(d*.006*(.8+Math.random()*.4),(Math.random()-.5)*d*.004),i.camRig.shake(Math.min(.25,n.recoil*.035)),i.director.noise(t.pos,n.id==="sniper"||n.id==="shotgun"?60:40)}explode(t,e,i,n="world",r={}){let o=this.game,a=o.world.groundHeight(t.x,t.z);o.fx.explosion(t,e*.6,t.y-a<1.5?a:null),o.sfx(Math.random()<.5?"explosion_1":"explosion_2",t,1,8);let l=t.distanceTo(o.player.pos);o.camRig.shake(Math.max(0,.9-l/(e*4))),l<e*2.5&&o.haptic("heavy");for(let c of o.enemies.active){if(!c.alive||c===r.ignore)continue;let h=uu.copy(c.pos).setY(c.pos.y+c.def.height*.5*c.scale).distanceTo(t);if(h<e+c.def.radius*c.scale){let u=1-Math.max(0,h-c.def.radius*c.scale)/e;Oi.copy(c.pos).sub(t).normalize(),c.damage(i*(.35+.65*u),c.pos.clone().setY(c.pos.y+1),Oi,"body",{explosive:!0,weapon:"explosion"}),c.knockback(Oi,6*u)}}if(n!=="enemy"||r.hurtsPlayer!==!1){let c=o.player,h=l;if(h<e){let u=1-h/e,f=n==="player"?.5:1;c.takeDamage(i*.45*(.3+.7*u)*f,t,"explosion"),Oi.copy(c.pos).sub(t).setY(0).normalize(),c.vel.addScaledVector(Oi,7*u),c.vel.y+=3*u}}o.props.explosion(t,e,i),o.director.noise(t,80)}};var sc=new T,yv=new T,fu={x:0,z:0},pu=new T,xp={humanoid:[["head",.17,"head",.1],["chest",.3,"body",.12],["spine",.22,"body",.05],["hips",.22,"body",0],["thighL",.12,"limb",-.2],["thighR",.12,"limb",-.2],["shinL",.1,"limb",-.2],["shinR",.1,"limb",-.2],["foreL",.1,"limb",-.1],["foreR",.1,"limb",-.1]],brute:[["head",.2,"head",.06],["chest",.5,"body",.12],["spine",.32,"body",.08],["hips",.3,"body",0],["thighL",.18,"limb",-.16],["thighR",.18,"limb",-.16],["shinL",.15,"limb",-.16],["shinR",.15,"limb",-.16],["foreL",.18,"limb",-.16],["foreR",.18,"limb",-.16]],crawler:[["head",.16,"head",.06],["chest",.24,"body",.1],["spine",.22,"body",.15],["hips",.2,"body",0],["tail",.12,"limb",0]],bloater:[["head",.13,"head",.06],["spine",.34,"body",.12],["chest",.28,"body",.05],["thighL",.11,"limb",-.15],["thighR",.11,"limb",-.15]],flyer:[["head",.15,"head",.1],["chest",.26,"body",.1],["spine",.2,"body",.05],["hips",.18,"body",0],["wingL",.3,"limb",0],["wingR",.3,"limb",0]]},vv={head:2.2,body:1,limb:.75},mu=null,gu=class{constructor(t,e){if(this.game=t,this.def=e,this.inst=fn(Jl(e),!0),this.mesh=this.inst.mesh,this.mesh.castShadow=t.quality.enemyShadows,this.anim=new Un(this.inst,tc[e.rig]),this.bodyMat=this.mesh.material[0],this.glowMat=this.mesh.material[1],this.glowColor=new _t(e.colors[2]),t.quality.standardMaterials){mu||(mu=ae.glow()),this.glowSprite=new Xn(new Us({map:mu,color:this.glowColor,blending:ke,depthWrite:!1,transparent:!0,opacity:.7,toneMapped:!1}));let i=this.inst.b.chest,n=e.rig==="brute"?.9:e.rig==="bloater"?1.1:.55;this.glowSprite.scale.setScalar(n),this.glowSprite.position.set(0,e.rig==="crawler"?.05:.15,e.rig==="brute"?.32:.2),i.add(this.glowSprite)}this.hitDefs=xp[e.rig]||xp.humanoid,this.spheres=this.hitDefs.map(()=>new T),this.hitFrame=-1,this.pos=new T,this.vel=new T,this.alive=!1,this.active=!1}reset(t,e,i={}){let n=this.def,r=this.game;this.pos.copy(t),this.vel.set(0,0,0),this.scale=n.scale*(i.scaleMul||1),this.maxHp=n.hp*e.hp*(i.hpMul||1),this.hp=this.maxHp,this.dmgMul=e.dmg,this.speedMul=e.speed,this.alive=!0,this.active=!0,this.state="spawn",this.stateT=0,this.attackCd=1+Math.random(),this.specialCd=4+Math.random()*3,this.special2Cd=9,this.dodgeCd=2,this.side=1,this.flash=0,this.deadT=0,this.phase=Math.random()*6,this.growlT=2+Math.random()*5,this.stepAcc=0,this.knock=new T,this.strafeSign=Math.random()<.5?-1:1,this.stuckT=0,this.detour=0,this.lastProgress=1/0,this.fuse=-1,this.summoned=0,this.altitude=n.behavior==="flyer"?4.5+Math.random()*2:0,this.y0=r.world.groundHeight(t.x,t.z),this.pos.y=this.y0+this.altitude,this.yaw=Math.atan2(r.player.pos.x-t.x,r.player.pos.z-t.z),this.mesh.scale.setScalar(this.scale),this.mesh.position.copy(this.pos),this.mesh.rotation.set(0,this.yaw,0),this.mesh.visible=!0,this.bodyMat.emissive.setRGB(0,0,0),this.bodyMat.transparent=!1,this.bodyMat.opacity=1,this.glowSprite&&(this.glowSprite.visible=!0),this.anim.additive.length=0,this.anim.cur=null,this.anim.prev=null,this.anim.play("spawn",0,!0),this.animAcc=0,this.mesh.parent||r.scene.add(this.mesh),r.quietSpawn||(r.fx.portal(this.pos,n.colors[2],n.rig==="brute"?3:2),r.sfx("spawn_portal",this.pos,.9)),n.behavior==="boss"&&(this.state="roar",this.stateT=0,this.anim.play("roar",.2,!0),r.sfx("boss_roar",this.pos,1,30))}get height(){return this.def.height*this.scale}updateSpheres(){if(this.hitFrame!==this.game.frame){this.hitFrame=this.game.frame,this.mesh.updateMatrixWorld(!0);for(let t=0;t<this.hitDefs.length;t++){let[e,,,i]=this.hitDefs[t],n=this.inst.b[e];this.spheres[t].set(0,i,0).applyMatrix4(n.matrixWorld)}}}rayHit(t,e,i){let n=this.pos.y+this.height*.5,r=Math.max(this.height*.7,this.def.radius*this.scale*2.2);if(Gh(t.x,t.y,t.z,e.x,e.y,e.z,this.pos.x,n,this.pos.z,r)<0)return null;this.updateSpheres();let o=i,a=null;for(let l=0;l<this.hitDefs.length;l++){let c=this.spheres[l],h=this.hitDefs[l][1]*this.scale,u=Gh(t.x,t.y,t.z,e.x,e.y,e.z,c.x,c.y,c.z,h);u>=0&&u<o&&(o=u,a=this.hitDefs[l][2])}return a?{enemy:this,t:o,part:a}:null}center(t){return this.updateSpheres(),t.copy(this.spheres[1])}knockback(t,e){let i=this.def.behavior==="tank"||this.def.behavior==="boss"?.15:1;this.knock.addScaledVector(t,e*i)}damage(t,e,i,n="body",r={}){if(!this.alive)return!1;let o=this.game,a=this.def,l=vv[n]||1;!r.explosive&&!r.armorPiercing&&(l*=a.resist),a.behavior==="tank"&&r.weapon==="sniper"&&(l*=1.2);let c=t*l;return this.hp-=c,this.flash=.12,o.fx.alienHit(e,i,a.colors[2],c>60),o.sfx("impact_flesh",e,.9),n==="head"&&o.sfx("headshot",null,.7),Math.random()<.25&&o.sfx(Math.random()<.5?"alien_hurt_1":"alien_hurt_2",this.pos,.8,this.def.rig==="brute"?.7:1.1),this.anim.impulse("hit",Math.min(1,c/40+.3),5),o.director.onDamage(this,c),this.state==="spawn"&&(this.state="chase",this.stateT=0),c>this.maxHp*.35&&a.behavior!=="tank"&&a.behavior!=="boss"&&this.state!=="attack"&&this.knock.addScaledVector(i,2),this.hp<=0?(this.die(r),!0):!1}die(t={}){let e=this.game;this.alive=!1,this.state="dead",this.stateT=0,this.deadT=0,this.anim.play("death",.12,!0),e.sfx(Math.random()<.5?"alien_death_1":"alien_death_2",this.pos,1,this.def.rig==="brute"?.65:this.def.rig==="crawler"?1.3:1);let i=this.pos.clone();i.y+=this.height*.5,e.fx.alienBurst(i,this.def.colors[2],this.def.behavior==="boss"?3:1),this.glowSprite&&(this.glowSprite.visible=!1),this.def.behavior==="exploder"&&(this.mesh.visible=!1,e.combat.explode(i,4.5,this.def.damage*this.dmgMul,"enemy",{ignore:this})),this.def.behavior==="boss"&&(e.camRig.shake(.8),e.sfx("boss_roar",this.pos,1,30)),e.director.onKill(this,t)}update(t){let e=this.game,i=this.def,n=e.player;if(this.stateT+=t,this.flash=Math.max(0,this.flash-t),this.flash>0?this.bodyMat.emissive.copy(this.glowColor).multiplyScalar(this.flash*5):this.fuse>=0?this.bodyMat.emissive.copy(this.glowColor).multiplyScalar(.5+.5*Math.sin(this.stateT*30)):this.bodyMat.emissive.setRGB(0,0,0),this.state==="dead")return this._updateDead(t);let r=n.pos.x-this.pos.x,o=n.pos.z-this.pos.z,a=Math.hypot(r,o);this.dist=a;let l=r/(a||1),c=o/(a||1),h=0,u=0,f=0,d=Math.atan2(l,c),g=0,x=n.alive,m=i.range*this.scale+.4;switch(this.attackCd-=t,this.specialCd-=t,this.special2Cd-=t,this.dodgeCd-=t,this.growlT-=t,this.growlT<=0&&(this.growlT=4+Math.random()*6,a<45&&e.sfx(`growl_${1+Math.floor(Math.random()*3)}`,this.pos,.9,i.rig==="brute"?.6:i.rig==="crawler"?1.4:1)),this.state){case"spawn":this.stateT>1&&(this.state="chase",this.stateT=0);break;case"roar":this.stateT>1.3&&(this.state="chase",this.stateT=0);break;case"attack":{let p=this.attackDur;this.anim.ctx.attackT=this.stateT/p,d=this.attackYaw??d,!this.hitDone&&this.stateT>=p*this.hitAt&&(this.hitDone=!0,this._resolveAttack(a)),this.lunge&&(h=this.lunge.x,u=this.lunge.z,f=this.lunge.s*(1-this.stateT/p)),this.stateT>=p&&(this.state="chase",this.stateT=0,this.lunge=null);break}case"chase":default:{if(!x){g=0,f=0,this.stateT>2&&Math.random()<.01&&this.anim.play("roar",.2,!0);break}let p=i.behavior;if(g=a>16&&p!=="fast"&&p!=="crawler"?.25:1,f=(g>.5?i.run:i.walk)*this.speedMul,p==="flyer")return this._flyer(t,a,l,c),this._finish(t,this.fx,this.fz,this.fs,Math.atan2(l,c),1);let M=l,y=c;if(a>3&&e.flow.direction(this.pos.x,this.pos.z,fu)&&(M=fu.x,y=fu.z),p==="spitter")a<9?(M=-l,y=-c,f=i.walk*this.speedMul,g=.3):a<17&&(M=-c*this.strafeSign,y=l*this.strafeSign,f=i.walk*.7*this.speedMul,g=.25,Math.random()<.005&&(this.strafeSign*=-1)),this.attackCd<=0&&a<24&&a>5&&this._los()&&this._startAttack("spit",1,.6);else if(p==="crawler"){let b=Math.sin(this.stateT*4+this.phase)*.6;a>5&&(M+=-y*b,y+=M*b),a<5&&this.attackCd<=0&&this._startAttack("attack",.75,.45,{lunge:9})}else if(p==="fast"){if(this.dodgeCd<=0&&a<26&&n.aiming){e.camera.getWorldDirection(pu);let b=this.pos.x-e.camera.position.x,E=this.pos.z-e.camera.position.z,P=Math.hypot(b,E)||1;(pu.x*b+pu.z*E)/P>.985&&(this.dodgeCd=2.5+Math.random()*2,this.strafeSign=Math.random()<.5?-1:1,this.knock.set(-c*this.strafeSign*8,0,l*this.strafeSign*8))}a<12&&a>4&&this.specialCd<=0&&(this.specialCd=4,this.chargeT=.8),this.chargeT>0&&(this.chargeT-=t,f*=1.7)}else p==="exploder"?a<2.4&&this.fuse<0&&(this.fuse=.7,e.sfx("bloater_beep",this.pos,1)):p==="tank"?a<9&&this.specialCd<=0&&this._los()&&(this.specialCd=7,this._startAttack("slam",1.4,.55,{slam:7.5})):p==="elite"?a<10&&a>4&&this.specialCd<=0&&(this.specialCd=5,this.knock.set(l*10,0,c*10),e.fx.trail(this.pos.clone().setY(this.pos.y+1),i.colors[2],.4)):p==="boss"&&this._boss(t,a,l,c);if(this.fuse>=0&&(this.fuse-=t,this.fuse<0)){this.hp=0,this.die({selfDestruct:!0});return}if(this.state==="chase"&&a<m&&this.attackCd<=0&&p!=="spitter"&&p!=="exploder"&&(p==="tank"||p==="boss"?this._startAttack("attack",1.3,.62):this._startAttack("attack",p==="fast"?.6:.85,.55)),a<m*.8&&p!=="spitter"&&(f=0),f>0&&(a<this.lastProgress-.5?(this.lastProgress=a,this.stuckT=0):this.stuckT+=t,this.stuckT>1.5&&(this.detour=1.2,this.stuckT=0,this.lastProgress=a,this.strafeSign*=-1)),this.detour>0){this.detour-=t;let b=-y*this.strafeSign,E=M*this.strafeSign;M=b*.8+M*.2,y=E*.8+y*.2}let _=Math.hypot(M,y)||1;h=M/_,u=y/_,(p!=="spitter"||a>17)&&(d=Math.atan2(h,u)),a<6&&(d=Math.atan2(l,c))}}this._finish(t,h,u,f,d,g)}_los(){let t=this.game,e=t.player,i=sc.set(this.pos.x,this.pos.y+this.height*.7,this.pos.z),n=yv.set(e.pos.x,e.pos.y+1.2,e.pos.z).sub(i),r=n.length();return n.multiplyScalar(1/r),t.world.colliders.raycast(i.x,i.y,i.z,n.x,n.y,n.z,r,l=>l.kind!=="rail")?!1:t.world.raycastTerrain(i,n,r)<0}_startAttack(t,e,i,n={}){this.state="attack",this.stateT=0,this.attackDur=e,this.hitAt=i,this.hitDone=!1,this.attackKind=n.slam?"slam":t==="spit"?"spit":n.volley?"volley":"melee",this.slamRadius=n.slam||0,this.side=-this.side,this.anim.ctx.side=this.side,this.anim.play(t,.12,!0),this.attackCd=this.def.cooldown*(.8+Math.random()*.4);let r=this.game.player;if(this.attackYaw=Math.atan2(r.pos.x-this.pos.x,r.pos.z-this.pos.z),n.lunge){let o=r.pos.x-this.pos.x,a=r.pos.z-this.pos.z,l=Math.hypot(o,a)||1;this.lunge={x:o/l,z:a/l,s:n.lunge}}this.attackKind==="melee"&&this.game.sfx("alien_attack",this.pos,.9,this.def.rig==="brute"?.7:1.1)}_resolveAttack(t){let e=this.game,i=e.player,n=this.def;if(!i.alive)return;let r=n.damage*this.dmgMul;if(this.attackKind==="volley"){let o=this.center(sc).clone();o.y+=1;let a=(i.pos.x-this.pos.x)/(t||1),l=(i.pos.z-this.pos.z)/(t||1);for(let c=-2;c<=2;c++){let h=i.pos.clone();h.x+=-l*c*2.2,h.z+=a*c*2.2,h.y+=1,e.projectiles.acid(o,h,r*.35,this)}e.sfx("acid_spit",this.pos,1,12)}else if(this.attackKind==="spit"){let o=this.center(sc).clone();o.y+=.3,e.projectiles.acid(o,i.pos.clone().setY(i.pos.y+1),r,this),e.sfx("acid_spit",this.pos,1)}else if(this.attackKind==="slam"){let o=e.world.groundHeight(this.pos.x,this.pos.z);e.fx.shockwave(new T(this.pos.x,o,this.pos.z),this.slamRadius,n.colors[2]),e.sfx("boss_slam",this.pos,1,10),e.sfx("shockwave",this.pos,1,10),e.camRig.shake(Math.max(.15,.7-t/25)),t<this.slamRadius&&i.onGround&&i.takeDamage(r*.9,this.pos,"shockwave")}else{let o=n.range*this.scale+.9,a=Math.sin(this.yaw),l=Math.cos(this.yaw),c=(i.pos.x-this.pos.x)/(t||1),h=(i.pos.z-this.pos.z)/(t||1);t<o&&a*c+l*h>.3&&Math.abs(i.pos.y-this.pos.y)<2+this.height*.3&&(i.takeDamage(r,this.pos,"melee"),(n.behavior==="tank"||n.behavior==="boss")&&(i.vel.x+=c*8,i.vel.z+=h*8,i.vel.y+=3,e.sfx("boss_slam",this.pos,.8,10)))}}_flyer(t,e,i,n){let r=this.game,o=r.player;if(this.diveCd=(this.diveCd??3)-t,this.diving){let a=o.pos.x-this.pos.x,l=o.pos.y+1.2-this.pos.y,c=o.pos.z-this.pos.z,h=Math.hypot(a,l,c)||1;this.fx=a/h,this.fz=c/h,this.fs=12*this.speedMul,this.altitudeVel=l/h*12,this.diveT+=t,h<1.6&&(o.takeDamage(this.def.damage*this.dmgMul,this.pos,"melee"),this.diving=!1,this.diveCd=3+Math.random()*2),this.diveT>2.5&&(this.diving=!1,this.diveCd=2),this.anim.ctx.attackT=Math.min(1,this.diveT/1.2),this.anim.play("attack",.15)}else{let l=Math.atan2(this.pos.x-o.pos.x,this.pos.z-o.pos.z)+this.strafeSign*.8,c=o.pos.x+Math.sin(l)*9-this.pos.x,h=o.pos.z+Math.cos(l)*9-this.pos.z,u=Math.hypot(c,h)||1;this.fx=c/u,this.fz=h/u,this.fs=Math.min(this.def.walk,u*2)*this.speedMul;let f=this.game.world.groundHeight(this.pos.x,this.pos.z)+this.altitude;this.altitudeVel=(f-this.pos.y)*2,this.diveCd<=0&&e<18&&(this.diving=!0,this.diveT=0,this.game.sfx("wing_flap",this.pos,1)),this.anim.play(e>12?"move":"idle",.2)}Math.random()<t*1.5&&this.game.sfx("wing_flap",this.pos,.5)}_boss(t,e,i,n){let r=this.game,o=this.hp/this.maxHp;if(this.summoned===0&&o<.66||this.summoned===1&&o<.33){this.summoned++,this.state="roar",this.stateT=0,this.anim.play("roar",.2,!0),r.sfx("boss_roar",this.pos,1,30),r.director.summon(this.pos,3+this.summoned);return}if(this.special2Cd<=0&&e>9&&e<30&&this._los()){this.special2Cd=9,this._startAttack("attack",1.2,.45,{volley:!0});return}if(this.specialCd<=0&&e<13){this.specialCd=8,this._startAttack("slam",1.5,.55,{slam:12});return}e>16&&this.chargeCd===void 0&&(this.chargeCd=6),this.chargeCd=(this.chargeCd??6)-t,this.chargeCd<=0&&e>14&&(this.chargeCd=12,this.knock.set(i*14,0,n*14),r.sfx("boss_roar",this.pos,.7,30))}_finish(t,e,i,n,r,o){let a=this.game,l=this.def,c=0,h=0,u=l.radius*this.scale;for(let y of a.enemies.active){if(y===this||!y.alive)continue;let _=this.pos.x-y.pos.x,b=this.pos.z-y.pos.z,E=u+y.def.radius*y.scale,P=_*_+b*b;if(P<E*E&&P>1e-6){let L=Math.sqrt(P);c+=_/L*(E-L),h+=b/L*(E-L)}}let f=e*n,d=i*n;this.vel.x+=(f-this.vel.x)*ze(8,t),this.vel.z+=(d-this.vel.z)*ze(8,t),this.pos.x+=(this.vel.x+this.knock.x)*t+c*.5,this.pos.z+=(this.vel.z+this.knock.z)*t+h*.5,this.knock.multiplyScalar(Math.max(0,1-t*5));let g=l.behavior==="flyer";if(g){this.pos.y+=(this.altitudeVel||0)*t;let y=a.world.groundHeight(this.pos.x,this.pos.z);this.pos.y<y+.6&&(this.pos.y=y+.6)}else{a.world.colliders.resolve(this.pos,u*.8,this.height);let y=a.world.groundHeight(this.pos.x,this.pos.z,this.pos.y+1);this.lunge&&this.state==="attack"?this.pos.y=y+Math.sin(Math.min(1,this.stateT/this.attackDur)*Math.PI)*.8:this.pos.y+=(y-this.pos.y)*Math.min(1,t*15),y<Ie-.3&&this.vel.multiplyScalar(.96)}this.yaw=go(this.yaw,r,10,t);let x=0;this.state==="spawn"&&!g&&(x=-this.height*.8*(1-Math.min(1,this.stateT/.9))),this.mesh.position.set(this.pos.x,this.pos.y+x,this.pos.z),this.mesh.rotation.y=this.yaw;let m=Math.hypot(this.vel.x,this.vel.z);this.phase+=m*t*(l.rig==="brute"?1.1:l.rig==="crawler"?2.4:1.6)/this.scale;let p=this.anim;p.ctx.phase=this.phase,p.ctx.gait=$t(o,0,1),this.state==="chase"&&!g&&(!p.cur||p.cur==="spawn"||p.cur==="attack"||p.cur==="slam"||p.cur==="spit"||p.cur==="roar"||p.cur==="idle"||p.cur==="move")&&(p.cur==="roar"&&p.t<1.2||p.play(m>.3?"move":"idle",.2)),this.stepAcc+=m*t,this.stepAcc>(l.rig==="brute"?1.8*this.scale:1.4)&&(this.stepAcc=0,this.dist<30&&(a.sfx("alien_step",this.pos,l.rig==="brute"?1:.4,l.rig==="brute"?.6:1.2),l.behavior==="boss"&&(a.camRig.shake(.08),a.fx.dust(this.pos,2)))),this.animAcc+=t;let M=this.dist>55?.1:this.dist>35?.05:0;this.animAcc>=M&&(p.update(this.animAcc),this.animAcc=0)}_updateDead(t){let e=this.game;if(this.deadT+=t,this.mesh.visible&&(this.anim.update(t),this.deadT>3.2)){let i=(this.deadT-3.2)/1.3;this.mesh.position.y=this.pos.y-i*this.height*.6}this.deadT>4.5&&(this.active=!1,this.mesh.visible=!1)}},rc=class{constructor(t){this.game=t,this.pools=new Map,this.active=[]}spawn(t,e,i,n){let r=$s[t],o=this.pools.get(t);o||(o=[],this.pools.set(t,o));let a=o.find(l=>!l.active);return a||(a=new gu(this.game,r),o.push(a)),a.reset(e,i,n),this.active.includes(a)||this.active.push(a),a}get aliveCount(){let t=0;for(let e of this.active)e.alive&&t++;return t}assistTarget(t,e,i,n){let r=null,o=i;for(let a of this.active){if(!a.alive||a.state==="spawn")continue;let l=a.center(sc),c=l.x-t.x,h=l.y-t.y,u=l.z-t.z,f=Math.hypot(c,h,u);if(f>n||f<1)continue;let d=Math.acos($t((c*e.x+h*e.y+u*e.z)/f,-1,1));d<o&&(o=d,r=l.clone())}return r}update(t){for(let e=this.active.length-1;e>=0;e--){let i=this.active[e];i.update(t),i.active||this.active.splice(e,1)}}clear(){for(let t of this.active)t.active=!1,t.alive=!1,t.mesh.visible=!1;this.active.length=0}};var Mv=[["grunt",1,1,10],["runner",2,1,7],["crawler",3,1,7],["spitter",4,1.5,5],["tank",6,4,3],["exploder",7,1.5,5],["flyer",8,1.5,5],["elite",10,5,2]],nr=new T,_p=new Sn,yp=new Ut,Ao=class{constructor(t){this.game=t,this.wave=0,this.state="intermission",this.timer=3,this.queue=[],this.spawnT=0,this.combo=1,this.comboT=0,this.bossAlive=null}level(t=this.wave){return{hp:1+.09*(t-1)+Math.max(0,t-15)*.05,dmg:1+.05*(t-1),speed:Math.min(1.3,1+.012*(t-1))}}composeWave(t){let e=t%5===0,i=Math.round(6+t*2.6),n=[];e&&(n.push("boss"),i=Math.round(i*.5));let r=Mv.filter(l=>t>=l[1]),o=r.reduce((l,c)=>l+c[3]*(t-c[1]<2?1.6:1),0),a=0;for(;i>0&&a++<400;){let l=Math.random()*o,c=r[0];for(let h of r)if(l-=h[3]*(t-h[1]<2?1.6:1),l<=0){c=h;break}c[2]>i&&i<4&&(c=r[0]),n.push(c[0]),i-=c[2]}for(let l=n.length-1;l>(e?1:0);l--){let c=(e?1:0)+Math.floor(Math.random()*(l-(e?1:0)+1));[n[l],n[c]]=[n[c],n[l]]}return n}startWave(){let t=this.game;this.wave++,t.stats.wave=this.wave,this.queue=this.composeWave(this.wave),this.waveTotal=this.queue.length,this.state="active",this.spawnT=.5;let e=this.wave%5===0;t.hud.banner(e?`WAVE ${this.wave}`:`WAVE ${this.wave}`,e?"BOSS INCOMING: HIVE TITAN":`${this.waveTotal} hostiles detected`,e),t.sfx(e?"boss_alert":"wave_start"),t.audio.playMusic(e?"music_boss":"music_combat")}noise(){}onDamage(){}onKill(t,e){let i=this.game,n=i.stats;n.kills++,n.killsByType[t.def.id]=(n.killsByType[t.def.id]||0)+1,this.comboT=4,this.combo=Math.min(5,this.combo+.25),n.maxCombo=Math.max(n.maxCombo,this.combo);let r=Math.round(t.def.score*this.combo*(1+this.wave*.05));n.score+=r,i.hud.killFeed(t.def.name,r,this.combo),t.def.behavior==="boss"&&(n.bossesKilled++,this.bossAlive=null,i.hud.bossBar(null));let o=t.pos,a=t.def.coins,l=Math.min(6,Math.ceil(a/3));for(let m=0;m<l;m++){let p=o.clone();p.x+=(Math.random()-.5)*1.5,p.z+=(Math.random()-.5)*1.5,i.pickups.drop("coin",p,{value:Math.max(1,Math.round(a/l))})}let c=i.player,h=c.weapon,u=h.reserve!==1/0&&h.reserve<h.def.mag*2,f=Math.random(),d=null,g=.07+(c.health<c.maxHealth*.4?.12:0),x=.08+(u?.2:0);if(f<g?d="health":f<g+x?d="ammo":f<g+x+.04?d="armor":f<g+x+.07?d="grenade":f<g+x+.09?d="speed":f<g+x+.105?d="upgrade":f<g+x+.115?d="shield":f<g+x+.122&&(d="hpboost"),d&&i.pickups.drop(d,o.clone().add(nr.set(.6,0,.4))),(t.def.behavior==="elite"||t.def.behavior==="boss"||Math.random()<.03)&&i.pickups.drop("gem",o.clone().add(nr.set(-.6,0,.2))),t.def.behavior==="boss")for(let m of["upgrade","shield","hpboost","ammo","health","gem","gem"])i.pickups.drop(m,o.clone().add(nr.set((Math.random()-.5)*4,0,(Math.random()-.5)*4)))}spawnPoint(t){let e=this.game,i=e.player.pos,n=$s[t],r=e.camera;yp.multiplyMatrices(r.projectionMatrix,r.matrixWorldInverse),_p.setFromProjectionMatrix(yp);let o=n.behavior==="crawler",a=o?14:24,l=o?22:40;if(n.behavior!=="flyer"&&n.behavior!=="boss"&&Math.random()<.3)for(let h of e.world.caves){let u=Math.hypot(h.x-i.x,h.z-i.z);if(u>12&&u<45&&e.world.validSpawn(h.x,h.z,.6))return nr.set(h.x,0,h.z).clone()}let c=null;for(let h=0;h<24;h++){let u=Math.random()*Math.PI*2,f=a+Math.random()*(l-a),d=i.x+Math.cos(u)*f,g=i.z+Math.sin(u)*f,x=n.radius*n.scale;if(!e.world.validSpawn(d,g,x)||n.behavior!=="flyer"&&!e.flow.reachable(d,g))continue;let m=e.world.groundHeight(d,g);nr.set(d,m+1,g);let p=nr.clone();if(_p.containsPoint(p)&&h<18){c=c||p;continue}return p.setY(m)}return c?c.setY(e.world.groundHeight(c.x,c.z)):null}summon(t,e){let i=this.game;for(let n=0;n<e;n++){let r=n/e*Math.PI*2,o=t.x+Math.cos(r)*4,a=t.z+Math.sin(r)*4;if(!i.world.validSpawn(o,a,.6))continue;let l=n%2?"crawler":"grunt";i.enemies.spawn(l,new T(o,i.world.groundHeight(o,a),a),this.level())}}update(t){let e=this.game;if(!e.player.alive)return;if(this.comboT-=t,this.comboT<=0&&this.combo>1&&(this.combo=Math.max(1,this.combo-t*.8)),this.state==="intermission"){this.timer-=t,e.hud.countdown(Math.ceil(this.timer)),this.timer<=0&&(e.hud.countdown(null),this.startWave());return}let i=e.quality.maxEnemies+Math.min(6,Math.floor(this.wave/4));if(this.spawnT-=t,this.queue.length&&this.spawnT<=0&&e.enemies.aliveCount<i){let n=this.queue[0],r=this.spawnPoint(n);if(r){this.queue.shift();let o=e.enemies.spawn(n,r,this.level());n==="boss"&&(this.bossAlive=o,e.hud.bossBar(o))}this.spawnT=Math.max(.35,1.5-this.wave*.06)*(.6+Math.random()*.8)}if(this.bossAlive&&e.hud.bossBar(this.bossAlive),!this.queue.length&&e.enemies.aliveCount===0){this.state="intermission",this.timer=6;let n=250*this.wave;e.stats.score+=n,e.hud.banner("WAVE CLEARED",`+${n} survival bonus`,!1),e.sfx("wave_clear"),e.audio.playMusic("music_combat"),e.player.armor=Math.min(e.player.maxArmor,e.player.armor+10)}}remaining(){return this.queue.length+this.game.enemies.aliveCount}};var xu={health:16728128,ammo:15254855,armor:10137792,coin:16761370,gem:4175615,upgrade:13762071,shield:16765498,speed:3837183,grenade:10145074,hpboost:3211104},Ro=null;function bv(){let s=o=>new je({roughness:.5,metalness:.2,...o}),t=s({vertexColors:!0,map:ae.metal()}),e=new ye({vertexColors:!0,toneMapped:!1}),i={},n=(o,a)=>{let l=new fe,c=new se;if(o(c),c.parts.length&&l.add(new Et(c.build(),t)),a){let h=new se;a(h),l.add(new Et(h.build(),e))}return l};i.health=(()=>{let o=new fe,a=new Et(new oi(.62,.42,.3),s({map:ae.medkit()}));o.add(a);let l=new se;return l.add(R.torus(.09,.025,6,12,Math.PI),{pos:[0,.21,0],color:2236962}),l.add(R.box(.64,.05,.32),{pos:[0,-.2,0],color:10489872}),o.add(new Et(l.build(),t)),o})(),i.ammo=(()=>{let o=new fe;o.add(new Et(new oi(.66,.36,.36),s({map:ae.ammo()})));let a=new se;a.add(R.box(.7,.06,.4),{pos:[0,.19,0],color:3097632}),a.add(R.box(.16,.05,.05),{pos:[0,.25,0],color:2236962});for(let l=0;l<4;l++)a.add(R.cyl(.025,.025,.14,8),{pos:[-.15+l*.1,.28,.1],color:13148224});return o.add(new Et(a.build(),t)),o})(),i.armor=n(o=>{o.add(R.capsule(.22,.25,4,12),{scale:[1.15,1,.55],color:6055536}),o.add(R.box(.12,.12,.05),{pos:[-.12,-.05,.13],color:3818056}),o.add(R.box(.12,.12,.05),{pos:[.12,-.05,.13],color:3818056}),o.add(R.box(.4,.05,.05),{pos:[0,.12,.13],color:2764854}),o.add(R.torus(.1,.03,6,12),{pos:[0,.3,0],rot:[Math.PI/2,0,0],color:1710618})}),i.coin=n(o=>{o.add(R.cyl(.24,.24,.06,24),{rot:[Math.PI/2,0,0],color:15905306}),o.add(R.torus(.21,.02,6,24),{pos:[0,0,.03],color:13142544}),o.add(R.box(.05,.22,.02),{pos:[0,0,.035],color:13142544}),o.add(R.torus(.065,.02,6,12,Math.PI*1.2),{pos:[0,.04,.035],rot:[0,0,.6],color:13142544}),o.add(R.torus(.065,.02,6,12,Math.PI*1.2),{pos:[0,-.04,.035],rot:[0,0,Math.PI+.6],color:13142544})}),i.coin.children[0].material=s({vertexColors:!0,metalness:.9,roughness:.25}),i.gem=n(()=>{},o=>{o.add(R.cone(.22,.14,8),{pos:[0,.07,0],color:8378111}),o.add(R.cone(.22,.32,8),{pos:[0,-.16,0],rot:[Math.PI,0,0],color:2064352})}),i.upgrade=n(o=>{o.add(R.box(.7,.4,.4),{color:3948870}),o.add(R.box(.72,.05,.42),{pos:[0,.1,0],color:1974822}),o.add(R.box(.2,.06,.06),{pos:[0,.24,0],color:1710618});for(let a of[-.3,.3])o.add(R.box(.06,.42,.42),{pos:[a,0,0],color:2764339})},o=>{o.add(R.box(.5,.05,.01),{pos:[0,-.06,.205],color:13762071}),o.add(R.box(.08,.08,.01),{pos:[0,.03,.205],color:13762071})}),i.shield=(()=>{let o=new on;o.moveTo(0,.32),o.quadraticCurveTo(.2,.26,.26,.28),o.lineTo(.24,0),o.quadraticCurveTo(.2,-.22,0,-.34),o.quadraticCurveTo(-.2,-.22,-.24,0),o.lineTo(-.26,.28),o.quadraticCurveTo(-.2,.26,0,.32);let a=new Kr(o,{depth:.06,bevelEnabled:!0,bevelSize:.02,bevelThickness:.02,bevelSegments:2});a.translate(0,0,-.03);let l=new fe;l.add(new Et(a,s({color:16761370,metalness:.8,roughness:.3})));let c=new Et(new $n(o),new ye({color:16773274,toneMapped:!1}));return c.scale.setScalar(.7),c.position.z=.06,l.add(c),l})(),i.speed=n(o=>{o.add(R.box(.16,.3,.2),{pos:[0,.12,-.04],color:2052056}),o.add(R.box(.18,.12,.38),{pos:[0,-.06,.04],color:2777855}),o.add(R.box(.2,.04,.4),{pos:[0,-.13,.04],color:15265528})},o=>{for(let a=0;a<3;a++)o.add(R.box(.02,.02,.18),{pos:[.11,0+a*.07,-.25],color:9425151})}),i.grenade=(()=>{let o=new fe,a=Ln();return a.scale.setScalar(2.8),o.add(a),o})(),i.hpboost=n(()=>{},o=>{o.add(R.box(.14,.44,.12),{color:3211104}),o.add(R.box(.44,.14,.12),{color:3211104}),o.add(R.box(.1,.36,.13),{color:14221280}),o.add(R.box(.36,.1,.13),{color:14221280})});let r=new ye({map:ae.glow(),transparent:!0,blending:ke,depthWrite:!1,toneMapped:!1});return i.ringGeo=new Ke(1.4,1.4).rotateX(-Math.PI/2),i.ringMat=r,i}var vp={health:"+40 HEALTH",ammo:"AMMO REFILL",armor:"+50 ARMOR",coin:"",gem:"+1 GEM",upgrade:"GUN OVERCHARGE 20s",shield:"SHIELD 10s",speed:"SPEED BOOST 12s",grenade:"+2 GRENADES",hpboost:"MAX HP +25"},oc=class{constructor(t){this.game=t,Ro||(Ro=bv()),this.items=[],this.pool=new Map}_make(t){let e=this.pool.get(t);e||(e=[],this.pool.set(t,e));let i=e.find(n=>!n.active);if(!i){let n=new fe,r=Ro[t].clone();r.traverse(a=>{a.isMesh&&(a.castShadow=!0)}),n.add(r);let o=new Et(Ro.ringGeo,Ro.ringMat.clone());o.material.color.set(xu[t]),o.material.opacity=.55,n.add(o),i={type:t,root:n,model:r,ring:o,active:!1,pos:new T},e.push(i)}return i}drop(t,e,i={}){let n=this.game,r=this._make(t);return r.active=!0,r.pos.copy(e),r.ground=n.world.groundHeight(e.x,e.z),r.pos.y=r.ground,r.t=Math.random()*6,r.life=i.persist?1/0:t==="coin"?25:35,r.value=i.value||1,r.persistId=i.persistId||null,r.pop=.4,r.interact=t==="upgrade",r.root.visible=!0,r.root.position.copy(r.pos),r.root.parent||n.scene.add(r.root),this.items.push(r),r}spawnWorld(t,e,i){this.drop(t,e,{persist:!0,persistId:i,value:t==="coin"?5:1})}onChunkUnloaded(t){for(let e of this.items)e.persistId&&e.persistId.startsWith(t.key+":")&&this._remove(e);this.items=this.items.filter(e=>e.active)}_remove(t){t.active=!1,t.root.visible=!1}nearestInteractable(t){let e=null,i=2.2;for(let n of this.items){if(!n.active||!n.interact)continue;let r=Math.hypot(n.pos.x-t.x,n.pos.z-t.z);r<i&&(i=r,e=n)}return e}collect(t){let e=this.game,i=e.player,n=e.stats,r=!0;switch(t.type){case"health":i.health>=i.maxHealth?r=!1:(i.heal(40),i.startAction("heal",.8),e.sfx("pickup_health"),e.sfx("heal"));break;case"ammo":{let o=!1;for(let a of i.weapons)a.reserve!==1/0&&a.reserve<a.def.maxReserve&&(a.reserve=Math.min(a.def.maxReserve,a.reserve+Math.max(a.def.mag*2,Math.round(a.def.maxReserve*.4))),o=!0);o?e.sfx("pickup_ammo"):r=!1;break}case"armor":i.armor>=i.maxArmor?r=!1:(i.armor=Math.min(i.maxArmor,i.armor+50),e.sfx("pickup_armor"));break;case"coin":n.coins+=t.value,e.sfx("pickup_coin");break;case"gem":n.gems+=1,e.sfx("pickup_gem");break;case"upgrade":i.overT=20,i.startAction("pickup",.45),e.sfx("pickup_power");for(let o of i.weapons)o.reserve!==1/0&&(o.reserve=Math.min(o.def.maxReserve,o.reserve+o.def.mag));break;case"shield":i.shieldT=10,e.sfx("shield_on");break;case"speed":i.speedT=12,e.sfx("speed_on");break;case"grenade":i.grenades>=i.maxGrenades?r=!1:(i.grenades=Math.min(i.maxGrenades,i.grenades+2),e.sfx("pickup_ammo"));break;case"hpboost":i.maxHealth+=25,i.health=i.maxHealth,e.sfx("pickup_power"),e.sfx("heal");break;default:break}return r?(n.pickups++,e.fx.sparkle(t.pos,xu[t.type]),vp[t.type]&&e.hud.toast(vp[t.type],xu[t.type]),t.persistId&&e.world.collected.add(t.persistId),this._remove(t),!0):!1}update(t){let e=this.game,i=e.player,n=i.alive,r=null;for(let o=this.items.length-1;o>=0;o--){let a=this.items[o];if(!a.active){this.items.splice(o,1);continue}if(a.t+=t,a.life-=t,a.life<=0){this._remove(a),this.items.splice(o,1);continue}let l=i.pos.x-a.pos.x,c=i.pos.z-a.pos.z,h=Math.hypot(l,c);if(n&&(a.type==="coin"||a.type==="gem")&&h<4.5&&h>.01){let f=Math.min(h,12/Math.max(h,.5)*t);a.pos.x+=l/h*f,a.pos.z+=c/h*f,a.ground=e.world.groundHeight(a.pos.x,a.pos.z)}a.pop>0&&(a.pop-=t);let u=a.pop>0?Math.sin((1-a.pop/.4)*Math.PI)*.6:0;if(a.root.position.set(a.pos.x,a.ground+.45+Math.sin(a.t*2.5)*.08+u,a.pos.z),a.model.rotation.y=a.t*1.6,a.ring.position.y=-.43-Math.sin(a.t*2.5)*.08-u,a.ring.material.opacity=.35+Math.sin(a.t*4)*.15,a.root.visible=a.life>5||Math.sin(a.t*18)>-.2,!!n){if(a.interact){h<2.2&&(r=a);continue}h<(a.type==="coin"?.9:1.2)&&Math.abs(i.pos.y-a.ground)<2&&this.collect(a)&&this.items.splice(o,1)}}this.interactable=r}clear(){for(let t of this.items)this._remove(t);this.items.length=0}};var sr=new T,ac=class{constructor(t){this.game=t,this.pending=[]}damage(t,e,i){if(!t.alive)return;let n=this.game;t.type==="crate"?(t.hp-=e,t.hp<=0&&this.breakCrate(t)):t.type==="barrel"&&(t.hp-=e,t.hp<=0?this.detonateBarrel(t,.05):n.fx.smoke(sr.set(t.x,t.y+1.2,t.z),.5))}breakCrate(t){let e=this.game;e.world.destroyProp(t);let i=sr.set(t.x,t.y+.6,t.z);e.fx.impact(i,new T(0,1,0),"wood"),e.fx.impact(i,new T(1,.3,0),"wood"),e.fx.impact(i,new T(-1,.3,0),"wood"),e.fx.dust(i,3,[.5,.36,.22]),e.sfx("crate_break",i,1);let n=Math.random(),r=n<.3?"ammo":n<.45?"health":n<.55?"grenade":n<.62?"armor":n<.66?"upgrade":null;r&&e.pickups.drop(r,new T(t.x,t.y,t.z)),e.pickups.drop("coin",new T(t.x+.4,t.y,t.z),{value:2}),e.stats.cratesBroken++}detonateBarrel(t,e){!t.alive||t.pendingBoom||(t.pendingBoom=!0,this.pending.push({prop:t,t:e}))}explosion(t,e,i){for(let n of this.game.world.props)!n.alive||Math.hypot(n.x-t.x,n.z-t.z)>e+.5||(n.type==="barrel"?this.detonateBarrel(n,.12+Math.random()*.15):n.type==="crate"?this.damage(n,i,t):n.type==="mine"&&n.armed&&(n.armed=!1,n.fuse=.1+Math.random()*.1))}nearestCrate(t){let e=null,i=2.3;for(let n of this.game.world.props){if(!n.alive||n.type!=="crate")continue;let r=Math.hypot(n.x-t.x,n.z-t.z);r<i&&(i=r,e=n)}return e}update(t){let e=this.game,i=e.player;for(let n=this.pending.length-1;n>=0;n--){let r=this.pending[n];if(r.t-=t,r.t<=0){this.pending.splice(n,1);let o=r.prop;if(!o.alive)continue;e.world.destroyProp(o),e.combat.explode(new T(o.x,o.y+.6,o.z),6.5,150,"world"),e.stats.barrels++}}for(let n of e.world.props){if(!n.alive)continue;let r=i.pos.x-n.x,o=i.pos.z-n.z;if(!(r*r+o*o>3600)){if(n.type==="spikes"){if(n.tick-=t,n.tick>0)continue;let a=!1;i.alive&&Math.hypot(r,o)<n.radius&&i.pos.y-n.y<.9&&(i.takeDamage(12,sr.set(n.x,n.y,n.z),"trap"),a=!0);for(let l of e.enemies.active)!l.alive||l.def.behavior==="flyer"||Math.hypot(l.pos.x-n.x,l.pos.z-n.z)<n.radius+l.def.radius*.5&&(l.damage(35,sr.set(l.pos.x,l.pos.y+.3,l.pos.z),new T(0,1,0),"limb",{explosive:!0,weapon:"spikes"}),a=!0);a&&(n.tick=.6,e.sfx("spike_hit",sr.set(n.x,n.y,n.z),1))}else if(n.type==="mine"){let a=n.obj.getObjectByName("light");if(a&&(a.visible=n.armed?Math.sin(e.time*6+n.x)>0:Math.sin(e.time*40)>0),n.armed){let l=i.alive&&Math.hypot(r,o)<n.radius&&i.pos.y-n.y<1;if(!l){for(let c of e.enemies.active)if(c.alive&&c.def.behavior!=="flyer"&&Math.hypot(c.pos.x-n.x,c.pos.z-n.z)<n.radius+.3){l=!0;break}}l&&(n.armed=!1,n.fuse=.35,e.sfx("mine_beep",sr.set(n.x,n.y,n.z),1))}else n.fuse>=0&&(n.fuse-=t,n.fuse<0&&(e.world.destroyProp(n),e.combat.explode(new T(n.x,n.y+.3,n.z),5.5,120,"world"),e.stats.mines++))}}}}};var lc=new T,cc=class{constructor(t){this.game=t,this.list=[],this.puddles=[],this.grenadePool=[],this.acidPool=[],this.acidMat=new ye({color:13172522,toneMapped:!1}),this.acidGeo=new ci(.16,10,8),this.puddleMat=new ye({map:ae.glow(),color:10354478,transparent:!0,opacity:.6,blending:ke,depthWrite:!1,toneMapped:!1}),this.puddleGeo=new Ke(1,1).rotateX(-Math.PI/2)}grenade(t,e,i){let n=this.game,r=this.grenadePool.pop();r||(r=Ln(),r.scale.setScalar(1.6)),r.visible=!0,n.scene.add(r),this.list.push({kind:"grenade",mesh:r,pos:t.clone(),vel:e.clone(),fuse:Zs.fuse,owner:i,spin:new T(8,3,5),bounces:0}),n.stats.grenadesThrown++}acid(t,e,i,n){let r=this.game,o=this.acidPool.pop();o||(o=new Et(this.acidGeo,this.acidMat)),o.visible=!0,r.scene.add(o);let a=e.clone().sub(t),l=Math.hypot(a.x,a.z),c=Math.max(.5,l/16),h=12,u=new T(a.x/c,(a.y+.5*h*c*c)/c,a.z/c);this.list.push({kind:"acid",mesh:o,pos:t.clone(),vel:u,grav:h,damage:i,owner:n,life:4})}update(t){let e=this.game,i=e.world,n=e.player;for(let r=this.list.length-1;r>=0;r--){let o=this.list[r];if(o.kind==="grenade"){o.vel.y-=18*t;let a=o.pos.clone();o.pos.addScaledVector(o.vel,t);let l=o.vel.length();if(l>.01){let h=i.colliders.raycast(a.x,a.y,a.z,o.vel.x/l,o.vel.y/l,o.vel.z/l,l*t+.1,u=>u.kind!=="rail");h&&(lc.set(a.x-h.collider.x,0,a.z-h.collider.z).normalize(),o.pos.copy(a),o.vel.reflect(lc).multiplyScalar(.45),o.bounces++<6&&e.sfx("grenade_bounce",o.pos,.8))}let c=i.groundHeight(o.pos.x,o.pos.z,o.pos.y);o.pos.y<c+.08&&(o.pos.y=c+.08,i.field.normal(o.pos.x,o.pos.z,lc),o.vel.y<-1.5&&o.bounces++<6&&e.sfx("grenade_bounce",o.pos,.7),o.vel.reflect(lc).multiplyScalar(.42),o.spin.multiplyScalar(.6)),o.mesh.position.copy(o.pos),o.mesh.rotation.x+=o.spin.x*t,o.mesh.rotation.y+=o.spin.y*t,o.mesh.rotation.z+=o.spin.z*t,Math.random()<.5&&e.fx.trail(o.pos,16732192,.05),o.fuse-=t,o.fuse<=0&&(e.combat.explode(o.pos.clone().setY(o.pos.y+.3),Zs.radius,Zs.damage*(e.player.damageMul||1),"player"),this._release(o,r))}else if(o.kind==="acid"){o.vel.y-=o.grav*t,o.pos.addScaledVector(o.vel,t),o.life-=t,o.mesh.position.copy(o.pos),Math.random()<.7&&e.fx.trail(o.pos,13172522,.14);let a=!1,l=Math.hypot(n.pos.x-o.pos.x,n.pos.y+1-o.pos.y,n.pos.z-o.pos.z);n.alive&&l<.9&&(n.takeDamage(o.damage,o.pos,"acid"),a=!0);let c=i.groundHeight(o.pos.x,o.pos.z);!a&&o.pos.y<c+.1&&(a=!0),!a&&i.colliders.blocked(o.pos.x,o.pos.z,.1)&&(a=!0),(a||o.life<=0)&&(e.fx.acid(o.pos,14),e.sfx("acid_splash",o.pos,1),o.pos.y-c<1.5&&this._puddle(o.pos.x,c,o.pos.z,o.damage),this._release(o,r))}}for(let r=this.puddles.length-1;r>=0;r--){let o=this.puddles[r];o.t+=t,o.tick-=t,o.mesh.material.opacity=.6*Math.min(1,(4-o.t)/1),o.tick<=0&&n.alive&&Math.hypot(n.pos.x-o.x,n.pos.z-o.z)<1.1&&n.pos.y-o.y<.5&&(o.tick=.5,n.takeDamage(o.dps*.5,null,"acid")),Math.random()<t*6&&e.fx.trail(new T(o.x+(Math.random()-.5),o.y+.05,o.z+(Math.random()-.5)),10354478,.08),o.t>4&&(o.mesh.visible=!1,this.puddles.splice(r,1))}}_puddle(t,e,i,n){let r=this.game,o=this.puddles.length>6?this.puddles.shift():null,a=o?o.mesh:new Et(this.puddleGeo,this.puddleMat.clone());a.visible=!0,a.position.set(t,e+.06,i),a.scale.set(2.4,1,2.4),a.parent||r.scene.add(a),this.puddles.push({mesh:a,x:t,y:e,z:i,t:0,tick:.3,dps:n*.6})}_release(t,e){t.mesh.visible=!1,(t.kind==="grenade"?this.grenadePool:this.acidPool).push(t.mesh),this.list.splice(e,1)}clear(){for(let t=this.list.length-1;t>=0;t--)this._release(this.list[t],t);for(let t of this.puddles)t.mesh.visible=!1;this.puddles.length=0}};var hc=class{constructor(t){this.world=t,this.blocked=new Uint8Array(5184),this.dist=new Uint16Array(5184),this.ox=0,this.oz=0,this.valid=!1,this.timer=0,this.buckets=Array.from({length:16},()=>[]),this.lastX=1e9,this.lastZ=1e9}update(t,e,i){this.timer-=t;let n=Math.hypot(e-this.lastX,i-this.lastZ);this.timer>0&&n<1.5||(this.timer=.35,this.lastX=e,this.lastZ=i,this.build(e,i))}build(t,e){this.ox=Math.floor((t-54)/1.5)*1.5,this.oz=Math.floor((e-54)/1.5)*1.5;let n=this.blocked;n.fill(0);let r=.45,o=this.ox+54,a=this.oz+54;this.world.colliders.query(o,a,56,p=>{if(p.kind==="rail")return;let M=p.r+r,y=Math.max(0,Math.floor((p.x-M-this.ox)/1.5)),_=Math.min(71,Math.floor((p.x+M-this.ox)/1.5)),b=Math.max(0,Math.floor((p.z-M-this.oz)/1.5)),E=Math.min(71,Math.floor((p.z+M-this.oz)/1.5));for(let P=b;P<=E;P++)for(let L=y;L<=_;L++){let w=this.ox+(L+.5)*1.5-p.x,v=this.oz+(P+.5)*1.5-p.z;w*w+v*v<M*M&&(n[P*72+L]=1)}});let l=this.dist;l.fill(65535);let c=Math.floor((t-this.ox)/1.5),h=Math.floor((e-this.oz)/1.5);if(c<0||h<0||c>=72||h>=72){this.valid=!1;return}let u=this.buckets;for(let p of u)p.length=0;let f=h*72+c;l[f]=0,n[f]=0,u[0].push(f);let d=0,g=1,x=10,m=14;for(;g>0;){let p=u[d%16];if(p.length===0){d++;continue}let M=p.pop();if(g--,l[M]!==d)continue;let y=M%72,_=M/72|0;for(let b=-1;b<=1;b++){let E=_+b;if(!(E<0||E>=72))for(let P=-1;P<=1;P++){if(!P&&!b)continue;let L=y+P;if(L<0||L>=72)continue;let w=E*72+L;if(n[w]||P&&b&&(n[_*72+L]||n[E*72+y]))continue;let v=d+(P&&b?m:x);v<l[w]&&(l[w]=v,u[v%16].push(w),g++)}}}this.valid=!0}direction(t,e,i){if(!this.valid)return!1;let n=Math.floor((t-this.ox)/1.5),r=Math.floor((e-this.oz)/1.5);if(n<1||r<1||n>=71||r>=71)return!1;let o=this.dist,l=o[r*72+n],c=0,h=0;for(let g=-1;g<=1;g++)for(let x=-1;x<=1;x++){if(!x&&!g)continue;let m=o[(r+g)*72+(n+x)];m<l&&(l=m,c=x,h=g)}if(l===65535||c===0&&h===0)return!1;let u=this.ox+(n+c+.5)*1.5-t,f=this.oz+(r+h+.5)*1.5-e,d=Math.hypot(u,f)||1;return i.x=u/d,i.z=f/d,!0}isBlocked(t,e){let i=Math.floor((t-this.ox)/1.5),n=Math.floor((e-this.oz)/1.5);return i<0||n<0||i>=72||n>=72?!1:this.blocked[n*72+i]===1}reachable(t,e){if(!this.valid)return!0;let i=Math.floor((t-this.ox)/1.5),n=Math.floor((e-this.oz)/1.5);return i<0||n<0||i>=72||n>=72?!0:this.dist[n*72+i]!==65535}},Dw=72*1.5/2;var He=(s,t="0 0 48 48")=>`<svg viewBox="${t}" xmlns="http://www.w3.org/2000/svg" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round">${s}</svg>`,Ai={fire:He('<circle cx="24" cy="24" r="13"/><circle cx="24" cy="24" r="3" fill="currentColor"/><path d="M24 4v8M24 36v8M4 24h8M36 24h8"/>'),aim:He('<circle cx="24" cy="24" r="15"/><path d="M24 9v7M24 32v7M9 24h7M32 24h7"/><circle cx="24" cy="24" r="2" fill="currentColor"/>'),reload:He('<path d="M38 20a15 15 0 1 0 1 9"/><path d="M39 9v11H28"/>'),jump:He('<circle cx="27" cy="9" r="4" fill="currentColor"/><path d="M18 22l7-6 6 5 6-3M25 16l-4 12 7 5-2 10M21 28l-8 4"/><path d="M8 44h10" />'),crouch:He('<circle cx="22" cy="11" r="4" fill="currentColor"/><path d="M21 17l-3 11h10l3 12M18 28l-6 8 2 6M21 18l9 4 6-3"/>'),grenade:He('<ellipse cx="22" cy="29" rx="11" ry="13"/><path d="M18 16h8v-4h-8zM26 13l8-4M30 14a4 4 0 1 0 6 3"/><path d="M14 27h16M14 33h16"/>'),switch:He('<path d="M8 17h28l-6-6M40 31H12l6 6"/>'),sprint:He('<circle cx="30" cy="8" r="4" fill="currentColor"/><path d="M14 20l8-6 8 3 4 7 6 1M30 17l-6 11 7 6-3 10M24 28l-9 3-5 7"/>'),roll:He('<circle cx="24" cy="24" r="12"/><path d="M24 12a12 12 0 0 1 12 12M36 24l4-5M36 24l-5-3"/><path d="M6 42h36"/>'),interact:He('<path d="M17 25V12a3 3 0 0 1 6 0v11M23 22v-3a3 3 0 0 1 6 0v4M29 23a3 3 0 0 1 6 0v8c0 7-5 12-11 12-5 0-8-3-11-8l-4-7a3 3 0 0 1 5-3l4 5"/>'),pause:He('<path d="M17 12v24M31 12v24" stroke-width="5"/>'),heart:He('<path d="M24 40S8 30 8 18a8 8 0 0 1 16-3 8 8 0 0 1 16 3c0 12-16 22-16 22z" fill="currentColor"/>'),shield:He('<path d="M24 5l15 6v11c0 10-7 18-15 21C16 40 9 32 9 22V11z" fill="currentColor"/>'),coin:He('<circle cx="24" cy="24" r="16" fill="currentColor"/><path d="M28 17h-6a4 4 0 0 0 0 8h4a4 4 0 0 1 0 8h-7M24 13v4M24 33v3" stroke="#000"/>'),gem:He('<path d="M14 8h20l8 11-18 22L6 19z" fill="currentColor"/><path d="M6 19h36M18 8l-4 11 10 22 10-22-4-11" stroke="#000" stroke-width="2"/>'),skull:He('<path d="M12 30v-8a12 12 0 0 1 24 0v8l-4 3v6H16v-6z"/><circle cx="19" cy="24" r="3" fill="currentColor"/><circle cx="29" cy="24" r="3" fill="currentColor"/>'),clock:He('<circle cx="24" cy="24" r="16"/><path d="M24 14v10l7 5"/>'),wave:He('<path d="M6 30c6-10 12-10 18 0s12 10 18 0M6 20c6-10 12-10 18 0s12 10 18 0"/>'),bullets:He('<path d="M12 40V18l4-8 4 8v22zM22 40V18l4-8 4 8v22zM32 40V18l4-8 4 8v22z" fill="currentColor" stroke-width="1.5"/>')};var Pe=(s,t,e="")=>{let i=document.createElement(s);return t&&(i.className=t),e&&(i.innerHTML=e),i},wv=s=>{let t=Math.floor(s/60),e=Math.floor(s%60);return`${t}:${e<10?"0":""}${e}`},uc=class{constructor(t,e){this.game=e,this.root=Pe("div","hud"),t.appendChild(this.root);let i=this.root;this.cache={},this.stats=Pe("div","panel stats",`
      <div class="stat"><i>${Ai.wave}</i><span data-k="wave">WAVE 1</span></div>
      <div class="stat"><i>${Ai.skull}</i><span data-k="kills">0</span></div>
      <div class="stat"><i>${Ai.clock}</i><span data-k="time">0:00</span></div>
      <div class="stat score"><span data-k="score">0</span><b data-k="combo"></b></div>
      <div class="remaining" data-k="remaining"></div>`),i.appendChild(this.stats),this.wallet=Pe("div","panel wallet",`
      <div class="stat coin"><i>${Ai.coin}</i><span data-k="coins">0</span></div>
      <div class="stat gem"><i>${Ai.gem}</i><span data-k="gems">0</span></div>`),i.appendChild(this.wallet),this.radarWrap=Pe("div","radar"),this.radar=Pe("canvas"),this.radar.width=this.radar.height=128,this.radarWrap.appendChild(this.radar),i.appendChild(this.radarWrap),this.pauseBtn=Pe("div","pause-btn",Ai.pause),i.appendChild(this.pauseBtn),this.fps=Pe("div","fps"),i.appendChild(this.fps),this.vitals=Pe("div","panel vitals",`
      <div class="portrait"><img data-k="portrait" alt=""/></div>
      <div class="bars">
        <div class="bar hp"><i>${Ai.heart}</i><div class="fill"></div><span data-k="hp">100/100</span></div>
        <div class="bar ar"><i>${Ai.shield}</i><div class="fill"></div><span data-k="ar">0/100</span></div>
        <div class="buffs" data-k="buffs"></div>
      </div>`),i.appendChild(this.vitals),this.weaponPanel=Pe("div","panel weapon",`
      <img data-k="wicon" alt=""/>
      <div class="ammo"><i>${Ai.bullets}</i><span data-k="ammo">30/120</span></div>
      <div class="nades"><img data-k="nicon" alt=""/><span data-k="nades">3</span></div>
      <div class="wname" data-k="wname"></div>`),i.appendChild(this.weaponPanel),this.nadePanel=this.weaponPanel.querySelector(".nades"),this.cross=Pe("div","crosshair",'<span class="c t"></span><span class="c b"></span><span class="c l"></span><span class="c r"></span><span class="dot"></span>'),i.appendChild(this.cross),this.hit=Pe("div","hitmarker","<span></span><span></span><span></span><span></span>"),i.appendChild(this.hit),this.dmgRing=Pe("div","dmg-ring"),i.appendChild(this.dmgRing),this.vignette=Pe("div","vignette"),i.appendChild(this.vignette),this.scope=Pe("div","scope",'<div class="scope-lens"><span class="sh"></span><span class="sv"></span></div>'),i.appendChild(this.scope),this.bannerEl=Pe("div","banner",'<div class="b-title"></div><div class="b-sub"></div>'),i.appendChild(this.bannerEl),this.countEl=Pe("div","countdown"),i.appendChild(this.countEl),this.feed=Pe("div","killfeed"),i.appendChild(this.feed),this.toasts=Pe("div","toasts"),i.appendChild(this.toasts),this.boss=Pe("div","bossbar",'<div class="bname">HIVE TITAN</div><div class="btrack"><div class="bfill"></div></div>'),i.appendChild(this.boss),this.prompt=Pe("div","prompt"),i.appendChild(this.prompt),this.q={};for(let n of i.querySelectorAll("[data-k]"))this.q[n.dataset.k]=n;this.hpFill=this.vitals.querySelector(".hp .fill"),this.arFill=this.vitals.querySelector(".ar .fill"),this.bossFill=this.boss.querySelector(".bfill"),this.bannerT=0,this.hitT=0,this.dmgT=0,this.radarT=0,this.fpsT=0,this.frames=0,this.spread=0,this.show(!0)}show(t){this.root.style.display=t?"":"none"}setImages(t,e,i){this.weaponIcons=e,t&&(this.q.portrait.src=t),i&&(this.q.nicon.src=i),this.weaponChanged()}_set(t,e){this.cache[t]!==e&&(this.cache[t]=e,this.q[t].textContent=e)}weaponChanged(){var e;let t=(e=this.game.player)==null?void 0:e.weapon;t&&(this.weaponIcons&&this.weaponIcons[t.def.id]&&(this.q.wicon.src=this.weaponIcons[t.def.id]),this._set("wname",t.def.name.toUpperCase()))}banner(t,e,i){this.bannerEl.querySelector(".b-title").textContent=t,this.bannerEl.querySelector(".b-sub").textContent=e||"",this.bannerEl.classList.toggle("danger",!!i),this.bannerEl.classList.remove("show"),this.bannerEl.offsetWidth,this.bannerEl.classList.add("show"),this.bannerT=3}countdown(t){if(t===null){this.countEl.textContent="";return}let e=`NEXT WAVE IN ${t}`;this.countEl.textContent!==e&&(this.countEl.textContent=e)}hitMarker(t,e){this.hit.classList.toggle("head",t),this.hit.classList.toggle("kill",!!e),this.hitT=e?.3:.15,this.hit.style.opacity=1,this.game.sfx("hitmarker",null,e?1:.6)}damage(t,e,i,n){if(this.dmgT=.6,this.vignette.style.opacity=Math.min(.85,.35+n/50),t){let o=Math.atan2(t.x-e.x,t.z-e.z)-(i+Math.PI);this.dmgRing.style.transform=`translate(-50%, -50%) rotate(${-o}rad)`,this.dmgRing.style.opacity=1}}killFeed(t,e,i){let n=Pe("div","kf",`<b>${t.toUpperCase()}</b> +${e}${i>1.01?` <em>x${i.toFixed(2).replace(/0$/,"")}</em>`:""}`);for(this.feed.prepend(n);this.feed.children.length>4;)this.feed.lastChild.remove();setTimeout(()=>n.classList.add("fade"),2200),setTimeout(()=>n.remove(),2800)}toast(t,e){let i=Pe("div","toast",t);for(i.style.borderColor="#"+e.toString(16).padStart(6,"0"),this.toasts.appendChild(i);this.toasts.children.length>3;)this.toasts.firstChild.remove();setTimeout(()=>i.classList.add("fade"),1600),setTimeout(()=>i.remove(),2200)}bossBar(t){if(!t||!t.alive){this.boss.classList.remove("show");return}this.boss.classList.add("show"),this.bossFill.style.width=`${Math.max(0,t.hp/t.maxHp*100)}%`}setPrompt(t){this.cache.prompt!==t&&(this.cache.prompt=t,this.prompt.textContent=t||"",this.prompt.classList.toggle("show",!!t))}update(t){let e=this.game,i=e.player,n=e.stats,r=e.director,o=performance.now();this.frames++,this.fpsStart=this.fpsStart||o,this.fpsT=(o-this.fpsStart)/1e3,this.fpsT>=.5&&(this.fpsValue=this.frames/this.fpsT,this.fpsStart=o,e.cfg.settings.showFps?this.fps.textContent=`${Math.round(this.fpsValue)} FPS`:this.fps.textContent&&(this.fps.textContent=""),this.frames=0,this.fpsT=0),this._set("wave",`WAVE ${Math.max(1,n.wave)}`),this._set("kills",String(n.kills)),this._set("time",wv(n.time)),this._set("score",n.score.toLocaleString("en-US")),this._set("combo",r.combo>1.01?`x${r.combo.toFixed(1)}`:""),this._set("remaining",r.state==="active"?`${r.remaining()} ALIENS LEFT`:""),this._set("coins",String(n.coins)),this._set("gems",String(n.gems));let a=Math.max(0,Math.ceil(i.health));this._set("hp",`${a}/${i.maxHealth}`),this._set("ar",`${Math.ceil(i.armor)}/${i.maxArmor}`);let l=`${Math.max(0,i.health)/i.maxHealth*100}%`;this.cache.hpw!==l&&(this.cache.hpw=l,this.hpFill.style.width=l);let c=`${i.armor/i.maxArmor*100}%`;this.cache.arw!==c&&(this.cache.arw=c,this.arFill.style.width=c);let h=i.weapon;this._set("ammo",`${h.mag}/${h.reserve===1/0?"\u221E":h.reserve}`),this.weaponPanel.classList.toggle("empty",h.mag===0),this.weaponPanel.classList.toggle("reloading",i.reloadT>=0),this._set("nades",String(i.grenades)),e.controls.setBadge("grenade",i.grenades);let u=`${i.shieldT>0?`<b class="sh">SHIELD ${Math.ceil(i.shieldT)}</b>`:""}${i.speedT>0?`<b class="sp">SPEED ${Math.ceil(i.speedT)}</b>`:""}${i.overT>0?`<b class="ov">OVERCHARGE ${Math.ceil(i.overT)}</b>`:""}`;this.cache.buffs!==u&&(this.cache.buffs=u,this.q.buffs.innerHTML=u);let f=h.def,d=Math.hypot(i.vel.x,i.vel.z)>1,g=(i.aiming?f.spreadAim:f.spreadHip)*(d?1.25:1)*(i.crouch?.7:1)*(i.onGround?1:1.8);this.spread+=(g-this.spread)*Math.min(1,t*12);let x=6+this.spread*9+(e.player.fireCd>0?4:0);Math.abs((this.cache.px||0)-x)>.3&&(this.cache.px=x,this.cross.style.setProperty("--gap",`${x}px`));let m=e.camRig.scoped;this.scope.classList.toggle("show",m),this.cross.classList.toggle("hide",m||!i.alive||i.sprinting),this.hitT>0&&(this.hitT-=t,this.hitT<=0&&(this.hit.style.opacity=0)),this.dmgT>0&&(this.dmgT-=t,this.dmgT<=0&&(this.vignette.style.opacity=0,this.dmgRing.style.opacity=0));let p=i.alive&&i.health<i.maxHealth*.3;this.root.classList.toggle("lowhp",p),p?e.audio.loop("heart","low_health",1,"sfx"):e.audio.stopLoop("heart"),this.bannerT>0&&(this.bannerT-=t,this.bannerT<=0&&this.bannerEl.classList.remove("show")),this.radarT-=t,this.radarT<=0&&(this.radarT=.1,this._drawRadar())}_drawRadar(){let t=this.game,e=t.player,i=this.radar.getContext("2d"),n=128,r=60,o=45;i.clearRect(0,0,n,n),i.save(),i.translate(n/2,n/2),i.fillStyle="rgba(8,14,10,0.72)",i.beginPath(),i.arc(0,0,r,0,Math.PI*2),i.fill(),i.strokeStyle="rgba(209,254,23,0.35)",i.lineWidth=1;for(let d of[.33,.66])i.beginPath(),i.arc(0,0,r*d,0,Math.PI*2),i.stroke();i.beginPath(),i.moveTo(-r,0),i.lineTo(r,0),i.moveTo(0,-r),i.lineTo(0,r),i.stroke();let a=t.time*2%(Math.PI*2),l=i.createConicGradient?i.createConicGradient(a-Math.PI/2,0,0):null;l&&(l.addColorStop(0,"rgba(209,254,23,0.25)"),l.addColorStop(.12,"rgba(209,254,23,0)"),l.addColorStop(1,"rgba(209,254,23,0)"),i.fillStyle=l,i.beginPath(),i.arc(0,0,r,0,Math.PI*2),i.fill()),i.strokeStyle="#D1FE17",i.lineWidth=2,i.beginPath(),i.arc(0,0,r,0,Math.PI*2),i.stroke();let c=t.camRig.yaw,h=Math.cos(c),u=Math.sin(c),f=(d,g)=>{let x=d-e.pos.x,m=g-e.pos.z,p=x*h-m*u,M=x*u+m*h;return[p/o*r,M/o*r]};for(let d of t.pickups.items){if(!d.active||d.type==="coin")continue;let[g,x]=f(d.pos.x,d.pos.z);g*g+x*x>r*r||(i.fillStyle="#ffd23a",i.fillRect(g-2,x-2,4,4))}for(let d of t.enemies.active){if(!d.alive)continue;let[g,x]=f(d.pos.x,d.pos.z),m=Math.hypot(g,x);m>r-3&&(g*=(r-3)/m,x*=(r-3)/m);let p=d.def.behavior==="boss";i.fillStyle=p?"#ff2ee6":"#ff3b2f",i.beginPath(),i.arc(g,x,p?5:d.def.rig==="brute"?3.5:2.6,0,Math.PI*2),i.fill()}i.fillStyle="#D1FE17",i.beginPath(),i.moveTo(0,-6),i.lineTo(4.5,5),i.lineTo(0,2.5),i.lineTo(-4.5,5),i.closePath(),i.fill(),i.restore()}};var _u={joystick:{x:.12,y:.74},sprint:{x:.27,y:.52},fire:{x:.885,y:.68},reload:{x:.73,y:.66},aim:{x:.75,y:.87},grenade:{x:.775,y:.46},crouch:{x:.875,y:.39},jump:{x:.96,y:.485},roll:{x:.955,y:.9},switch:{x:.655,y:.66},interact:{x:.6,y:.45}},Mp={fire:{size:96,icon:"fire",label:""},aim:{size:60,icon:"aim"},reload:{size:56,icon:"reload"},jump:{size:56,icon:"jump"},crouch:{size:56,icon:"crouch"},roll:{size:52,icon:"roll"},grenade:{size:56,icon:"grenade"},switch:{size:52,icon:"switch"},sprint:{size:52,icon:"sprint"},interact:{size:64,icon:"interact"}},dc=class{constructor(t,e,i){this.root=t,this.settings=e,this.onLayoutSaved=i,this.layout={..._u,...e.layout||{}},this.state={moveX:0,moveY:0,sprint:!1,fire:!1,aim:!1,lookDX:0,lookDY:0,pressed:new Set,crouch:!1},this.touches=new Map,this.editing=!1,this.enabled=!0,this.keys=new Set,this.el=document.createElement("div"),this.el.className="controls",t.appendChild(this.el),this._buildJoystick(),this.buttons={},this.extra=[];for(let[n,r]of Object.entries(Mp))this._buildButton(n,r);this.applyLayout(),this._bindTouch(),this._bindKeyboard(),window.addEventListener("resize",()=>this.applyLayout())}_buildJoystick(){let t=document.createElement("div");t.className="joy",t.innerHTML='<div class="joy-ring"><span class="joy-arrow up"></span><span class="joy-arrow down"></span><span class="joy-arrow left"></span><span class="joy-arrow right"></span></div><div class="joy-knob"></div>',this.el.appendChild(t),this.joy=t,this.knob=t.querySelector(".joy-knob"),t.dataset.ctl="joystick"}_buildButton(t,e){let i=document.createElement("div");i.className=`btn btn-${t}`,i.dataset.ctl=t,i.innerHTML=Ai[e.icon]+(t==="grenade"?'<span class="btn-badge" data-badge="grenade">3</span>':""),this.el.appendChild(i),this.buttons[t]=i}scale(){let t=Math.min(window.innerWidth,window.innerHeight)/400;return Math.max(.6,Math.min(1.6,t))*(this.settings.controlScale||1)}applyLayout(){let t=this.scale(),e=window.innerWidth,i=window.innerHeight,n=(r,o,a)=>{let l=this.layout[o]||_u[o];r.style.width=r.style.height=`${a}px`,r.style.left=`${Math.round(l.x*e-a/2)}px`,r.style.top=`${Math.round(l.y*i-a/2)}px`};this.joySize=150*t,n(this.joy,"joystick",this.joySize);for(let[r,o]of Object.entries(Mp))n(this.buttons[r],r,o.size*t);this.el.style.opacity=this.settings.controlOpacity??.85}registerExtra(t,e){this.extra.push({id:t,el:e})}setInteractVisible(t){this.buttons.interact.classList.toggle("hidden",!t&&!this.editing)}setActive(t,e){this.buttons[t]&&this.buttons[t].classList.toggle("on",!!e)}setBadge(t,e){let i=this.el.querySelector(`[data-badge="${t}"]`);i&&(i.textContent=e)}consume(t){return this.state.pressed.has(t)?(this.state.pressed.delete(t),!0):!1}takeLook(){let t=this.state.lookDX,e=this.state.lookDY;return this.state.lookDX=0,this.state.lookDY=0,[t,e]}_bindTouch(){let t={passive:!1},e=this.root;e.addEventListener("touchstart",i=>this._onTouchStart(i),t),e.addEventListener("touchmove",i=>this._onTouchMove(i),t),e.addEventListener("touchend",i=>this._onTouchEnd(i),t),e.addEventListener("touchcancel",i=>this._onTouchEnd(i),t),e.addEventListener("mousedown",i=>this._onMouseDown(i)),window.addEventListener("mousemove",i=>this._onMouseMove(i)),window.addEventListener("mouseup",i=>this._onMouseUp(i)),e.addEventListener("contextmenu",i=>i.preventDefault())}_ctlAt(t,e){let i=this.scale(),n=this.layout.joystick,r=n.x*window.innerWidth,o=n.y*window.innerHeight;if(!this.editing)for(let{id:a,el:l}of this.extra){let c=l.getBoundingClientRect();if(c.width&&t>=c.left&&t<=c.right&&e>=c.top&&e<=c.bottom)return a}for(let[a,l]of Object.entries(this.buttons)){if(l.classList.contains("hidden"))continue;let c=l.getBoundingClientRect(),h=6*i;if(t>=c.left-h&&t<=c.right+h&&e>=c.top-h&&e<=c.bottom+h)return a}return Math.hypot(t-r,e-o)<this.joySize*.95||!this.editing&&t<window.innerWidth*.36&&e>window.innerHeight*.38?"joystick":"look"}_press(t,e){let i=this.state;switch(t){case"fire":i.fire=e;break;case"sprint":e&&(i.sprint=!i.sprint);break;case"crouch":e&&i.pressed.add("crouch");break;case"aim":e&&(i.aim=!i.aim);break;default:e&&i.pressed.add(t)}this.buttons[t]&&t!=="sprint"&&t!=="aim"&&this.buttons[t].classList.toggle("down",e),e&&this.onButton&&this.onButton(t)}_onTouchStart(t){if(this.enabled){t.preventDefault(),this.onFirstInput&&this.onFirstInput();for(let e of t.changedTouches){let i=this._ctlAt(e.clientX,e.clientY);if(this.editing){i!=="look"&&this.touches.set(e.identifier,{role:"drag",id:i,x:e.clientX,y:e.clientY});continue}let n={role:i,x:e.clientX,y:e.clientY,sx:e.clientX,sy:e.clientY};this.touches.set(e.identifier,n),i==="joystick"?this._joyMove(e.clientX,e.clientY):i!=="look"&&this._press(i,!0)}}}_onTouchMove(t){if(this.enabled){t.preventDefault();for(let e of t.changedTouches){let i=this.touches.get(e.identifier);if(i){if(i.role==="drag"){this._dragTo(i.id,e.clientX,e.clientY);continue}i.role==="joystick"?this._joyMove(e.clientX,e.clientY):(i.role==="look"||i.role==="fire")&&(this.state.lookDX+=e.clientX-i.x,this.state.lookDY+=e.clientY-i.y),i.x=e.clientX,i.y=e.clientY}}}}_onTouchEnd(t){t.preventDefault();for(let e of t.changedTouches){let i=this.touches.get(e.identifier);if(i){if(this.touches.delete(e.identifier),i.role==="drag"){this._saveLayout();continue}i.role==="joystick"?this._joyRelease():i.role!=="look"&&this._press(i.role,!1)}}}_joyMove(t,e){let i=this.layout.joystick,n=i.x*window.innerWidth,r=i.y*window.innerHeight,o=this.joySize*.42,a=(t-n)/o,l=(e-r)/o,c=Math.hypot(a,l),h=.12;c>1&&(a/=c,l/=c);let u=Math.min(1,c),f=u<h?0:(u-h)/(1-h)/Math.max(u,1e-6);this.state.moveX=a*f*Math.min(1,c),this.state.moveY=-l*f*Math.min(1,c),this.state.stickSprint=c>1.25,this.knob.style.transform=`translate(${a*o}px, ${l*o}px)`,this.joy.classList.add("active")}_joyRelease(){this.state.moveX=0,this.state.moveY=0,this.state.stickSprint=!1,this.knob.style.transform="translate(0px, 0px)",this.joy.classList.remove("active")}_dragTo(t,e,i){this.layout[t]={x:Math.min(.97,Math.max(.03,e/window.innerWidth)),y:Math.min(.97,Math.max(.05,i/window.innerHeight))},this.applyLayout()}_saveLayout(){this.onLayoutSaved&&this.onLayoutSaved({...this.layout})}setEditing(t){this.editing=t,this.el.classList.toggle("editing",t),this.setInteractVisible(t),this._joyRelease()}resetLayout(){this.layout={..._u},this.applyLayout(),this._saveLayout()}_onMouseDown(t){if(!this.enabled)return;this.onFirstInput&&this.onFirstInput();let e=this._ctlAt(t.clientX,t.clientY);if(this.editing){e!=="look"&&(this.mouse={role:"drag",id:e});return}if(e!=="look"&&e!=="joystick"){this.mouse={role:e},this._press(e,!0);return}if(e==="joystick"){this.mouse={role:e},this._joyMove(t.clientX,t.clientY);return}this.mouse={role:"look",x:t.clientX,y:t.clientY},t.button===0&&this.pointerLocked&&(this.state.fire=!0),t.button===2&&(this.state.aim=!this.state.aim)}_onMouseMove(t){if(this.pointerLocked){this.state.lookDX+=t.movementX,this.state.lookDY+=t.movementY;return}if(this.mouse){if(this.mouse.role==="drag"){this._dragTo(this.mouse.id,t.clientX,t.clientY);return}if(this.mouse.role==="joystick"){this._joyMove(t.clientX,t.clientY);return}(this.mouse.role==="look"||this.mouse.role==="fire")&&(this.state.lookDX+=t.clientX-(this.mouse.x??t.clientX),this.state.lookDY+=t.clientY-(this.mouse.y??t.clientY),this.mouse.x=t.clientX,this.mouse.y=t.clientY)}}_onMouseUp(t){this.pointerLocked&&t.button===0&&(this.state.fire=!1),this.mouse&&(this.mouse.role==="drag"?this._saveLayout():this.mouse.role==="joystick"?this._joyRelease():this.mouse.role!=="look"&&this._press(this.mouse.role,!1),this.mouse=null)}_bindKeyboard(){let t={KeyR:"reload",Space:"jump",KeyC:"crouch",KeyG:"grenade",KeyQ:"switch",KeyE:"interact",KeyV:"roll",Escape:"pause",KeyP:"pause"};window.addEventListener("keydown",e=>{!this.enabled||e.repeat||(this.onFirstInput&&this.onFirstInput(),this.keys.add(e.code),t[e.code]&&this._press(t[e.code],!0),e.code==="ShiftLeft"&&(this.state.keySprint=!0),e.code==="KeyF"&&(this.state.fire=!0),e.code==="KeyZ"&&(this.state.aim=!this.state.aim),e.code==="KeyL"&&document.pointerLockElement==null&&this.root.requestPointerLock&&this.root.requestPointerLock(),this._keyMove())}),window.addEventListener("keyup",e=>{this.keys.delete(e.code),t[e.code]&&this._press(t[e.code],!1),e.code==="ShiftLeft"&&(this.state.keySprint=!1),e.code==="KeyF"&&(this.state.fire=!1),this._keyMove()}),document.addEventListener("pointerlockchange",()=>{this.pointerLocked=document.pointerLockElement===this.root})}_keyMove(){let t=this.keys,e=(t.has("KeyD")||t.has("ArrowRight")?1:0)-(t.has("KeyA")||t.has("ArrowLeft")?1:0),i=(t.has("KeyW")||t.has("ArrowUp")?1:0)-(t.has("KeyS")||t.has("ArrowDown")?1:0);if(e||i||this.state.keyMoving){let n=Math.hypot(e,i)||1;this.state.moveX=e/n,this.state.moveY=i/n,this.state.keyMoving=!!(e||i)}}wantsSprint(){return this.state.sprint||this.state.stickSprint||this.state.keySprint}reset(){this.state.fire=!1,this.state.aim=!1,this.state.sprint=!1,this.state.pressed.clear(),this.touches.clear(),this._joyRelease();for(let t of Object.values(this.buttons))t.classList.remove("down","on")}};function Co(s,t,e,i,n,r="image/png"){let o=new wi(i,n,{samples:0});o.texture.colorSpace=Ne;let a=s.getRenderTarget(),l=s.getClearAlpha();s.setClearColor(0,0),s.setRenderTarget(o),s.clear(),s.render(t,e);let c=new Uint8Array(i*n*4);s.readRenderTargetPixels(o,0,0,i,n,c),s.setRenderTarget(a),s.setClearAlpha(l),o.dispose();let h=document.createElement("canvas");h.width=i,h.height=n;let u=h.getContext("2d"),f=u.createImageData(i,n);for(let d=0;d<n;d++){let g=(n-1-d)*i*4;f.data.set(c.subarray(g,g+i*4),d*i*4)}return u.putImageData(f,0,0),h.toDataURL(r,.9)}function Io(s){s.add(new Kn(14675967,4210736,1.6));let t=new An(16777215,2.4);t.position.set(1.5,2,3),s.add(t)}function bp(s){let t={weapons:{}},e=s.toneMapping;{let i=new Gi;Io(i);let n=fn(js());n.b.head.rotation.y=.35,n.b.neck.rotation.x=.05,i.add(n.mesh);let r=new Le(24,1,.05,10);r.position.set(.32,1.78,.95),r.lookAt(0,1.72,0),t.portrait=Co(s,i,r,128,128)}for(let i of["rifle","shotgun","sniper","smg","pistol","minigun"]){let n=new Gi;Io(n);let r=Pn(i);r.group.rotation.y=Math.PI/2,n.add(r.group);let o=new We().setFromObject(r.group),a=o.getCenter(new T),l=o.getSize(new T),c=new Xi(-l.x*.56,l.x*.56,l.x*.28,-l.x*.28,.01,10);c.position.set(a.x,a.y,a.z+2),c.lookAt(a),t.weapons[i]=Co(s,n,c,192,96)}{let i=new Gi;Io(i);let n=Ln();n.rotation.z=-.3,i.add(n);let r=new Xi(-.1,.1,.1,-.1,.01,10);r.position.set(0,.01,1),r.lookAt(0,.01,0),t.grenade=Co(s,i,r,64,64)}return s.toneMapping=e,t}var yu=new T;function wp(){return{score:0,kills:0,killsByType:{},wave:0,time:0,coins:0,gems:0,headshots:0,shotsFired:0,shotsHit:0,damageTaken:0,bossesKilled:0,pickups:0,cratesBroken:0,barrels:0,mines:0,grenadesThrown:0,maxCombo:1}}var vu=class{constructor(){this.running=!1,this.paused=!1,this.frame=0,this.time=0}async boot(t){var f;let e=Hh(Nf(),typeof t=="string"?JSON.parse(t):t||{});this.cfg=e;let i=Oh[e.settings.quality]?e.settings.quality:"MEDIUM";this.qualityName=i,this.quality={...Oh[i]};let n=this.quality,r=document.getElementById("game");this.root=r,this._loading(.05,"Building renderer");let o=new Bl({antialias:n.antialias,powerPreference:"high-performance",stencil:!1});o.setPixelRatio(Math.min(window.devicePixelRatio||1,n.pixelRatio)),this.pixelRatio=o.getPixelRatio(),o.setSize(window.innerWidth,window.innerHeight),o.outputColorSpace=Ne,o.toneMapping=Ya,o.toneMappingExposure=1.05,o.shadowMap.enabled=n.shadows,o.shadowMap.type=i==="HIGH"?Ba:no,r.prepend(o.domElement),this.renderer=o,o.domElement.addEventListener("webglcontextlost",d=>{d.preventDefault(),xi("error",{message:"WebGL context lost"})});let a=new Gi;a.fog=new Ir(Ei.fog,n.fogNear,n.fogFar),this.scene=a,this.camera=new Le(e.settings.fov,window.innerWidth/window.innerHeight,.08,1500),a.add(Kf()),this.skyGroup=a.children[a.children.length-1];let l=new Kn(14084351,5069624,1.25);a.add(l);let c=new An(16773328,2.7);c.castShadow=n.shadows,c.shadow.mapSize.set(n.shadowMapSize,n.shadowMapSize);let h=c.shadow.camera;h.left=-34,h.right=34,h.top=34,h.bottom=-34,h.near=1,h.far=160,c.shadow.bias=-6e-4,c.shadow.normalBias=.04,a.add(c,c.target),this.sun=c,this.stats=wp(),this.audio=new Zl(e.settings,i),this.fx=new Yl(a,n),this.world=new ql(a,n,e.seed),this.flow=new hc(this.world),this.combat=new nc(this),this.enemies=new rc(this),this.director=new Ao(this),this.pickups=new oc(this),this.props=new ac(this),this.projectiles=new cc(this),this.world.onPickupSpawned=(d,g,x)=>this.pickups.spawnWorld(d,g,x),this.world.onChunkUnloaded=d=>this.pickups.onChunkUnloaded(d),this.fx.groundAt=(d,g)=>this.world.groundHeight(d,g),this.fx.onShellLand=d=>{Math.random()<.5&&this.sfx(`shell_${1+Math.floor(Math.random()*3)}`,d,.6)};let u=this.world.field.findDrySpot(0,0);this.world.spawnSafe={x:u.x,z:u.z,r:14},this._loading(.2,"Growing the forest"),await this._tick(),this.world.warmup(u.x,u.z),this._loading(.45,"Deploying soldier"),await this._tick(),this.player=new To(this,e),this.player.spawn(u.x,u.z),this.camRig=new ec(this.camera,this.world,e.settings),this.camRig.yaw=Math.random()*Math.PI*2,this.flow.build(u.x,u.z),this.controls=new dc(r,e.settings,d=>{e.settings.layout=d,xi("layoutSaved",{layout:d})}),this.controls.onFirstInput=()=>this.audio.unlock(),this.hud=new uc(r,this),this.controls.registerExtra("pause",this.hud.pauseBtn),this.controls.registerExtra("switch",this.hud.weaponPanel);try{let d=bp(o);this.icons=d,this.hud.setImages(d.portrait,d.weapons,d.grenade)}catch(d){console.warn("icon render failed",d)}this._loading(.55,"Loading audio"),await this.audio.load("audio/",d=>this._loading(.55+d*.4,"Loading audio")),this._loading(1,"Ready"),window.addEventListener("resize",()=>this._resize()),document.addEventListener("visibilitychange",()=>{document.hidden&&this.running&&!this.over&&this.pause(!0)}),this._resize(),this._fpsWindow=[],this._perfT=0,this.running=!0,this.over=!1,this.mode=e.mode,e.mode==="layout"&&this._enterLayoutMode(),e.mode==="showcase"&&this._enterShowcase(e.shot||"menu"),this.last=performance.now(),this._raf=requestAnimationFrame(d=>this._loop(d)),(f=document.getElementById("loading"))==null||f.classList.add("done"),this.audio.unlock(),this.audio.loop("forest","amb_forest",1,"amb"),this.audio.loop("wind","amb_wind",.5,"amb"),xi("ready",{quality:i,mode:e.mode})}_tick(){return new Promise(t=>setTimeout(t,0))}_loading(t,e){let i=document.getElementById("loading-bar");i&&(i.style.width=`${Math.round(t*100)}%`);let n=document.getElementById("loading-text");n&&e&&(n.textContent=e),xi("loading",{progress:t})}_resize(){var i;let t=window.innerWidth,e=window.innerHeight;this.renderer.setSize(t,e),this.camera.aspect=t/e,this.camera.updateProjectionMatrix(),(i=this.controls)==null||i.applyLayout()}sfx(t,e=null,i=1,n=void 0){let r={volume:i};return e&&(r.pos=e),n!==void 0&&(n>=4?r.ref=n:r.rate=n*(.95+Math.random()*.1)),this.audio.play(t,r)}haptic(t){fo()&&xi("haptic",{kind:t})}_loop(t){this._raf=requestAnimationFrame(n=>this._loop(n));let e=this.cfg.settings.fps===30?1e3/30-3:0;if(t-this.last<e)return;let i=(t-this.last)/1e3;if(this.realDt=i,this.last=t,i>.05&&(i=.05),this.paused){this.renderer.render(this.scene,this.camera);return}i*=this.cfg.debug.timeScale||1,this.update(i),this.renderer.render(this.scene,this.camera),this._adapt()}_adapt(){let t=this.realDt;if(this._perfT+=t,this._fpsWindow.push(t),this._perfT<4)return;let i=1/(this._fpsWindow.reduce((r,o)=>r+o,0)/this._fpsWindow.length);this._fpsWindow.length=0,this._perfT=0,this.avgFps=i;let n=this.cfg.settings.fps===30?30:60;i<n*.8&&this.pixelRatio>.6&&(this.pixelRatio=Math.max(.6,this.pixelRatio-.15),this.renderer.setPixelRatio(this.pixelRatio),xi("perf",{fps:Math.round(i),pixelRatio:this.pixelRatio}))}update(t){this.frame++,this.time+=t;let e=this.player,i=this.controls,n=i.state;if(this.mode==="play"&&e.alive&&(this.stats.time+=t),this.mode==="play"){let[o,a]=i.takeLook();if(this.camRig.addLook(o,a,e.aiming),i.consume("pause")){this.pause();return}i.consume("reload")&&e.reload(),i.consume("jump")&&e.jump(),i.consume("crouch")&&e.toggleCrouch(),i.consume("grenade")&&e.throwGrenade(),i.consume("switch")&&e.switchWeapon(1),i.consume("roll")&&(this.camRig.flatForward(yu).multiplyScalar(n.moveY).add(this.camRig.flatRight(new T).multiplyScalar(n.moveX)),e.roll(yu)),i.consume("interact")&&this._interact(),e.update(t,{moveX:n.moveX,moveY:n.moveY,sprint:i.wantsSprint(),fire:n.fire,aim:n.aim}),i.setActive("aim",e.aiming),i.setActive("sprint",e.sprinting),i.setActive("crouch",e.crouch)}else{let[o,a]=i.takeLook();this.mode!=="showcase"&&this.camRig.addLook(o*.3,0,!1),e.update(t,{moveX:0,moveY:0,sprint:!1,fire:!1,aim:!1})}this.world.update(e.pos),this.flow.update(t,e.pos.x,e.pos.z),this.mode==="play"&&!this.cfg.debug.noDirector&&this.director.update(t),this.enemies.update(t),this.projectiles.update(t),this.props.update(t),this.pickups.update(t);let r=e.weapon.def.id==="sniper";if(this.camRig.update(t,e,e.aiming,e.weapon.def.zoomFov,r),e.mesh.visible=!this.camRig.scoped,this.sun.position.set(e.pos.x+Ei.sunDir.x*60,e.pos.y+Ei.sunDir.y*60,e.pos.z+Ei.sunDir.z*60),this.sun.target.position.copy(e.pos),this.skyGroup.position.copy(this.camera.position),Zh.value=this.time,this.world.water.material.uniforms.uTime.value=this.time,this.fx.update(t,this.camera,this.renderer.domElement.height),this.audio.setListener(this.camera),this._ambience(t),this.mode==="play"){let o=this.pickups.interactable||this.props.nearestCrate(e.pos);i.setInteractVisible(!!o&&e.alive),this.hud.setPrompt(o?this.pickups.interactable?"OPEN GUN UPGRADE CASE":"KICK OPEN CRATE":""),this.hud.update(t)}}_interact(){let t=this.player;if(!t.alive)return;let e=this.pickups.interactable;if(e){t.startAction("pickup",.45),this.pickups.collect(e);return}let i=this.props.nearestCrate(t.pos);i&&(t.startAction("interact",.5),t.facing=Math.atan2(i.x-t.pos.x,i.z-t.pos.z),setTimeout(()=>{i.alive&&this.props.breakCrate(i)},220))}_ambience(t){if(this._ambT=(this._ambT||0)-t,this._ambT>0)return;this._ambT=.5;let e=this.player.pos,i=0;for(let n=0;n<8;n++){let r=n/8*Math.PI*2;for(let o of[4,9,15])if(this.world.height(e.x+Math.cos(r)*o,e.z+Math.sin(r)*o)<Ie){i=Math.max(i,1-o/18);break}}if(i>0?this.audio.loop("water","amb_water",i,"amb"):this.audio.stopLoop("water",1),Math.random()<.08){let n=Math.random()*Math.PI*2;this.audio.play(`bird_${1+Math.floor(Math.random()*3)}`,{pos:yu.set(e.x+Math.cos(n)*20,e.y+8,e.z+Math.sin(n)*20).clone(),bus:"amb",volume:.8})}Math.random()<.03&&this.audio.play("leaves",{bus:"amb",volume:.6})}onPlayerDeath(){this.over||(this.over=!0,this.audio.stopLoop("heart"),this.audio.stopLoop("minigun"),this.camRig.shake(.6),setTimeout(()=>{this.audio.playMusic("music_gameover",.5),this.sfx("game_over");let t=this.stats,e={...t,accuracy:t.shotsFired?Math.round(t.shotsHit/t.shotsFired*100):0,time:Math.round(t.time),maxCombo:Math.round(t.maxCombo*100)/100};xi("gameOver",{stats:e}),fo()||this._showStandaloneGameOver(e)},2600))}_showStandaloneGameOver(t){let e=document.createElement("div");e.className="standalone-over",e.innerHTML=`<h1>GAME OVER</h1><p>Score ${t.score} \xB7 Wave ${t.wave} \xB7 Kills ${t.kills} \xB7 ${t.time}s</p><button id="again">PLAY AGAIN</button>`,this.root.appendChild(e),e.querySelector("#again").onclick=()=>{e.remove(),this.restart()}}pause(t=!0){this.paused||!this.running||(this.paused=!0,this.controls.reset(),this.audio.suspend(),xi("paused",{user:t}),fo()||document.body.classList.add("paused"))}resume(){this.paused&&(this.paused=!1,this.last=performance.now(),this.audio.resume(),document.body.classList.remove("paused"),xi("resumed"))}restart(){this.enemies.clear(),this.pickups.clear(),this.projectiles.clear(),this.audio.stopLoop("heart");let t=this.player.pos.clone();this.scene.remove(this.player.mesh,this.player.shieldMesh),this.stats=wp(),this.director=new Ao(this),this.player=new To(this,this.cfg);let e=this.world.field.findDrySpot(t.x+30,t.z+30);this.player.spawn(e.x,e.z),this.world.spawnSafe={x:e.x,z:e.z,r:14},this.world.warmup(e.x,e.z),this.flow.build(e.x,e.z),this.over=!1,this.hud.bossBar(null),this.hud.weaponChanged(),this.controls.reset(),this.paused=!1,this.audio.resume(),this.audio.playMusic(null),this.last=performance.now(),xi("restarted")}setSettings(t){let e=typeof t=="string"?JSON.parse(t):t;Object.assign(this.cfg.settings,e),this.audio.setVolumes(this.cfg.settings),this.controls.settings=this.cfg.settings,e.layout&&(this.controls.layout={...this.controls.layout,...e.layout}),this.controls.applyLayout(),this.camRig.settings=this.cfg.settings,e.shoulder!==void 0&&(this.camRig.shoulder=e.shoulder)}quit(){this.running=!1,cancelAnimationFrame(this._raf),this.audio.stopAll(),this.audio.suspend()}editLayout(t=!0){this.controls.setEditing(t),this.hud.show(!t),document.body.classList.toggle("layout-edit",t)}resetLayout(){this.controls.resetLayout()}_enterLayoutMode(){let t=document.createElement("div");t.className="layout-bar",t.innerHTML='<span>Drag the controls to place them</span><button data-a="reset">RESET</button><button data-a="done">DONE</button>';let e=i=>{i==="reset"?this.resetLayout():(xi("layoutDone",{layout:this.controls.layout}),fo()||this.editLayout(!1))};for(let i of t.querySelectorAll("button"))i.addEventListener("touchstart",n=>{n.stopPropagation(),n.preventDefault(),e(i.dataset.a)},{passive:!1}),i.addEventListener("mousedown",n=>{n.stopPropagation(),e(i.dataset.a)});document.body.appendChild(t),this.editLayout(!0)}_enterShowcase(t){this.hud.show(!1),this.controls.el.style.display="none",this.showcaseShot=t,this.cfg.debug.noDirector=!0}showcase(t,e){let i=this.renderer;if(t==="menu"){let c=this.world.field,h=null;for(let p=0;p<400&&!h;p++){let M=p*2.39996,y=10+p*.8,_=Math.cos(M)*y,b=Math.sin(M)*y;c.clearing(_,b)<.75||c.pathMask(_,b)>.3||c.height(_,b)<Ie+1||c.normal(_,b,new T).y<.97||(h={x:_,z:b})}h=h||c.findDrySpot(0,0);let u=this.player;this.debug.teleport(h.x,h.z),this.world.update(u.pos,!0),u.facing=.9;let f=new T(Math.sin(u.facing),0,Math.cos(u.facing)),d=new T(f.z,0,-f.x);this.quietSpawn=!0;let g=[["grunt",8,-1.5],["runner",10.5,1.8],["tank",14,-4.2],["crawler",6.2,2.6],["spitter",16,3.8],["grunt",18,.5]];for(let[p,M,y]of g){let _=u.pos.clone().addScaledVector(f,M).addScaledVector(d,y);_.y=this.world.groundHeight(_.x,_.z);let b=this.enemies.spawn(p,_,{hp:1,dmg:0,speed:0});b.state="chase",b.stateT=2,b.yaw=Math.atan2(-f.x,-f.z)+(Math.random()-.5)*.4,b.anim.play("move",0),b.anim.ctx.gait=1,b.anim.ctx.phase=Math.random()*6,b.anim.update(.016),b.mesh.position.copy(_),b.mesh.rotation.y=b.yaw}this.quietSpawn=!1,this.fx.update(5,this.camera,i.domElement.height),u.aiming=!0,u.anim.playUpper("aim",0),u.anim.uWeight=1,u.anim.play("idle",0);let x=this.camera;x.fov=42,x.updateProjectionMatrix();let m=u.pos.clone().addScaledVector(f,-2.4).addScaledVector(d,-4.6);m.y=Math.max(u.pos.y+1.25,this.world.height(m.x,m.z)+1.2),x.position.copy(m),x.lookAt(u.pos.clone().addScaledVector(f,4.2).setY(u.pos.y+1.45)),x.updateMatrixWorld(),this.camRig.yaw=Math.atan2(-f.x,-f.z),this.camRig.pitch=0;for(let p=0;p<3;p++)u._updateAnimation(.016,0,new T);return u.mesh.position.copy(u.pos),u.mesh.rotation.y=u.facing,u.mesh.visible=!0,this.sun.position.set(u.pos.x+Ei.sunDir.x*60,u.pos.y+Ei.sunDir.y*60,u.pos.z+Ei.sunDir.z*60),this.sun.target.position.copy(u.pos),this.skyGroup.position.copy(x.position),this.paused=!0,i.render(this.scene,x),i.domElement.toDataURL("image/jpeg",.88)}let n=new Gi;Io(n);let r,o,a=256,l=256;if(t==="alien"){let c=$s[e],h=fn(Jl(c)),u=new Un(h,tc[c.rig]);u.play("idle",0),u.update(.4),r=h.mesh,r.rotation.y=.45;let f=c.rig==="crawler"?1.2:c.rig==="brute"?2.3:c.rig==="flyer"?1.9:2;o=new Le(30,1,.05,20);let d=f/Math.tan(15*Math.PI/180)*.62;o.position.set(0,f*.55,d),o.lookAt(0,f*.45,0)}else if(t==="soldier"){let c=fn(js());r=c.mesh;let h=this.player,u=Pn(e||"rifle"),f=new Ee;c.b.chest.add(f),f.add(u.group),h.anim.playUpper("ready",0),h.anim.play("idle",0),h.anim.uWeight=1,h._updateAnimation(.016,0,new T),c.bones.forEach((d,g)=>{d.quaternion.copy(h.inst.bones[g].quaternion),d.position.copy(h.inst.bones[g].position)}),f.position.copy(h.pivot.position),f.quaternion.copy(h.pivot.quaternion),u.group.position.copy(h.weapon.model.group.position),r.rotation.y=.5,a=384,l=576,o=new Le(28,a/l,.05,20),o.position.set(0,1,4.3),o.lookAt(0,.95,0)}else if(t==="weapon"){r=Pn(e).group,r.rotation.y=Math.PI/2;let h=new We().setFromObject(r),u=h.getCenter(new T),f=h.getSize(new T);a=512,l=256;let d=Math.max(f.x,f.y*2.3);o=new Xi(-d*.55,d*.55,d*.275,-d*.275,.01,10),o.position.set(u.x,u.y,u.z+2);let g=new An(16777215,1.6);g.position.set(-1,1,2),n.add(g),o.lookAt(u),r.rotation.x=0,r.rotation.z=0}return n.add(r),Co(i,n,o,a,l)}get debug(){let t=this;return{state:()=>({pos:t.player.pos.toArray().map(e=>Math.round(e*100)/100),health:t.player.health,armor:t.player.armor,alive:t.player.alive,weapon:t.player.weapon.def.id,mag:t.player.weapon.mag,reserve:t.player.weapon.reserve,grenades:t.player.grenades,wave:t.director.wave,dirState:t.director.state,enemies:t.enemies.aliveCount,queue:t.director.queue.length,stats:{...t.stats},paused:t.paused,chunks:t.world.chunks.size,props:t.world.props.length,pickups:t.pickups.items.length,fps:t.avgFps,drawCalls:t.renderer.info.render.calls,triangles:t.renderer.info.render.triangles,yaw:t.camRig.yaw,pitch:t.camRig.pitch,crouch:t.player.crouch,anim:t.player.anim.cur,upper:t.player.anim.upper,onGround:t.player.onGround,aiming:t.player.aiming,shield:t.player.shieldT,speed:t.player.speedT}),spawn:(e,i=10,n=0)=>{let r=t.player.pos,o=t.camRig.flatForward(new T),a=Math.atan2(o.x,o.z)+n,l=r.x+Math.sin(a)*i,c=r.z+Math.cos(a)*i,h=t.enemies.spawn(e,new T(l,t.world.groundHeight(l,c),c),t.director.level(Math.max(1,t.director.wave)));return h.state="chase",h.def.id},enemies:()=>t.enemies.active.filter(e=>e.alive).map(e=>({type:e.def.id,hp:Math.round(e.hp),state:e.state,dist:Math.round(e.dist*10)/10,pos:e.pos.toArray().map(i=>Math.round(i*10)/10)})),teleport:(e,i)=>{t.player.spawn(e,i),t.world.update(t.player.pos,!0)},setHealth:e=>{t.player.health=e,e<=0&&t.player.die()},give:e=>t.pickups.drop(e,t.player.pos.clone()),dropAt:(e,i,n)=>t.pickups.drop(e,t.player.pos.clone().add(new T(i,0,n))),killAll:()=>{for(let e of[...t.enemies.active])e.alive&&e.damage(1e6,e.pos.clone(),new T(0,0,1),"body",{explosive:!0})},faceNearest:()=>{let e=t.enemies.active.find(r=>r.alive);if(!e)return!1;let n=e.center(new T).sub(t.camera.position);return t.camRig.yaw=Math.atan2(-n.x,-n.z),t.camRig.pitch=Math.atan2(n.y,Math.hypot(n.x,n.z)),!0},props:e=>t.world.props.filter(i=>i.alive&&(!e||i.type===e)).map(i=>({type:i.type,x:i.x,z:i.z,id:i.id})),startWaveNow:()=>{t.director.state==="intermission"&&(t.director.timer=0)},setTimeScale:e=>{t.cfg.debug.timeScale=e},god:e=>{t.cfg.debug.god=e},director:e=>{t.cfg.debug.noDirector=!e},bridge:()=>window.__bridgeLog.slice(),press:(e,i=!0)=>t.controls._press(e,i)}}},Mu=new vu;window.game=Mu;var Sv=new URLSearchParams(location.search).get("host")==="1";Sv||window.addEventListener("DOMContentLoaded",()=>{let s=new URLSearchParams(location.search),t={};s.get("quality")&&(t.settings={quality:s.get("quality")}),s.get("mode")&&(t.mode=s.get("mode")),s.get("seed")&&(t.seed=+s.get("seed")),s.get("shot")&&(t.shot=s.get("shot")),s.get("loadout")&&(t.loadout=s.get("loadout").split(",")),s.get("fps")&&(t.settings={...t.settings||{},showFps:!0}),setTimeout(()=>{Mu.cfg||Mu.boot(t).catch(e=>{console.error(e),xi("error",{message:String(e&&e.stack||e)})})},s.get("delay")?+s.get("delay"):0)});})();
/*! Bundled license information:

three/build/three.core.js:
three/build/three.module.js:
  (**
   * @license
   * Copyright 2010-2025 Three.js Authors
   * SPDX-License-Identifier: MIT
   *)
*/
