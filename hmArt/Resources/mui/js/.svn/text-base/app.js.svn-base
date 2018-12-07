/**
 *  全局JS文件函数
 * @author Roar.
 * @time 2016-09-26 0:41 
 */

/* *
 * 全文配置 
 * */
config = {
	isMock : false, //模拟调试  默认关闭false
	MOCK_KEY : 'MOCK/',	
	HOST : 'https://app.4008988518.com/art-interface/',
	JsWeb : 'hmqq-jsweb://app.4008988518.com/art-interface/',
	HOST_IMG : 'https://app.4008988518.com/image'
}
if(mui.os.ios){
	var hmqq_device = 'ios';
}else{
	var hmqq_device = 'android';
}
/* *
 * app全局对象
 * @function ajax 提供请求函数
 * */
app = {
	HMARTJsObj : function(data,callback){
		callback = callback || mui.noop;
		if(typeof(HMARTJsObj) == "undefined"){
			eval("("+callback+"())");
		}else{
			HMARTJsObj.encryptParams(JSON.stringify(data), callback);
		}
	},
	checkLogin : function(data, callback){
		callback = callback || mui.noop;
		if(typeof(HMARTJsObj) == "undefined"){
			var param = '{"loginStatus":1,"mobile":"17600819708"}';
			winLoad.checkLoginCallback(param);
		}else{
			HMARTJsObj.checkLogin(JSON.stringify(data), callback);
		}
	},
	phoneCallByApp :function(){
		HMARTJsObj.phoneCallByApp('致电','','4008988518','1');
	},
	fenxing :function(title,content,image, type, id, integralType){
		var url = config.HOST+'fengxiang.htm?type='+type+'&id='+id;
		if(mui.os.ios){
			if(typeof integralType=='undefined'){
				HMARTJsObj.fenxiangTitleContentImageUrlSiteUrlTypeId(title,content,image,url,0,0);
			}else{
				HMARTJsObj.fenxiangTitleContentImageUrlSiteUrlTypeId(title,content,image,url,integralType,id);
			}
		}else{
			if(typeof integralType=='undefined'){
				HMARTJsObj.fenxiangTitleContentImageUrlSiteUrl(title,content,image,url);
			}else{
				HMARTJsObj.fenxiangTitleContentImageUrlSiteUrl(title,content,image,url,integralType,id);
			}
		}
	},
	getHardwareInfo : function(callback){
		if(typeof(HMARTJsObj) == "undefined"){
			var param = '{"deviceId":"17600819708"}';
			winLoad.getHardwareInfo(param);
		}else{
			HMARTJsObj.getHardwareInfo(callback);
		}
	},
	sendDataToNative: function(data){
		if(mui.os.ios){
            var notiClass = plus.ios.importClass("NSNotificationCenter");
        		notiClass.defaultCenter().postNotificationNameobject("SendDataToNative",data);
        }else if(mui.os.android){
            alert('安卓未实现原生监听消息通知，消息内容：'+data);
        }
	},
	pushView : function(url){
		pageIndex = 1;
		if(typeof plus=="object"){
			app.sendDataToNative(url);
		}else{
			if(url.indexOf('remote://') == 0){
				url = config.JsWeb+url.substring(9);
				if(url.indexOf('?') > 0){
					url += '&random='+Math.random();
				}else{
					url += '?random='+Math.random();
				}
			}
			window.location.href = url;
		}
	},
	load : {
		init : function(callback){
			callback = callback || mui.noop;
			app.load.header(callback);
			mui.back = function() {
			    if(typeof HMARTJsObj=="object"){
                    HMARTJsObj.goBack();
                }else{
                    app.sendDataToNative('goBack');
                }
			}
			/** 5+ WebView集成方式 通知***/
			mui.plusReady(function(){
				var url = window.location.search; //获取url中"?"符后的字串
				appParams = new Object();
				if (url.indexOf("?") != -1) {
				  	var str = url.substr(1);
				  	strs = str.split("&");
				  	for(var i = 0; i < strs.length; i ++) {
				   		appParams[strs[i].split("=")[0]]=(strs[i].split("=")[1]);
				  	}
				}
				onARTJsObjReady();
			});
		},
		header : function(callback){
			callback = callback || mui.noop;
			if(mui.os.ios){
				mui('header').each(function(){
					this.classList.add('headt-22');
				});
				mui('.mui-content').each(function(){
					this.classList.add('paddingt-66');
				});
				setTimeout(function(){
					mui('.mui-pull-top-pocket').each(function(){
						this.classList.add('paddingt-66');
					});
				},500);
			}else if(mui.os.android){
				callback();
			}
		},
		mock : function(callback){
			callback = callback || mui.noop;
			if(window.location.href.indexOf("https://") == 0){
				console.log("开启Mock调试数据模式.!")
				config.isMock = true;
//				winLoad.init();
//				winBind.init();
				onARTJsObjReady();
				callback();
			}
		}
	},
	ajax : function(option,successCallback,errorCallback){
		successCallback = successCallback || mui.noop;
		errorCallback = errorCallback || mui.noop;
		option['param'] = option['param'] || {};
		option['DESStr'] = option['param']['desStr'] || option['DATA'];
		option['HEADER'] = option['param']['headers'] || {"reqld":"H5001","reqVersion":"01"};
		console.log(option['URL'])
		//调试模式
		if(config.isMock){
			if(option['URL'].indexOf(config.MOCK_KEY) == -1){
				option['URL'] = config.MOCK_KEY+option['URL'];
			}
		}
		var checkLoginCallback = function(){
			app.ajax(option,successCallback,errorCallback);
		};		
		app.loadding.show();
		mui.ajax({
			headers: option['HEADER'],
			type:option['TYPE'],
			url: config.HOST+option['URL'],
			data:option['DESStr'],
			dataType: 'json',
			contentType: "application/json",
			timeout: 45000, //超时时间
			success : function(data){
				app.loadding.hide();
				if(data.result == 100){
					app.checkLogin(1, 'checkLoginCallback');
					//app.DateUtil.initCountdown();
				}else if(data.result == 1){
					data.imagePath = config.HOST_IMG;
					successCallback(data);
				}else{
					if(errorCallback) errorCallback(data);
					else app.toAlert(data.message);
				}
			},
			error : function(xhr, type, errorThrown){				
				app.loadding.hide();
				app.toast("网络繁忙,请稍后重试");
				//mui.alert("["+option['URL']+"] Post到火星就失踪啦 ! 赶紧上报.!");
				//errorCallback(xhr, type, errorThrown);
			}
		});
	},
	ajax2 : function(option,successCallback,errorCallback,isLoading){
		isLoading = isLoading || false;
		successCallback = successCallback || mui.noop;
		errorCallback = errorCallback || mui.noop;
		option['param'] = option['param'] || {};
		option['DESStr'] = option['param']['desStr'] || option['DATA'];
		option['HEADER'] = option['param']['headers'] || {"reqld":"H5001","reqVersion":"01"};
		console.log(option['URL'])
		//调试模式
		if(config.isMock){
			if(option['URL'].indexOf(config.MOCK_KEY) == -1){
				option['URL'] = config.MOCK_KEY+option['URL'];
			}
		}
		var checkLoginCallback = function(){
			app.ajax(option,successCallback,errorCallback);
		};
		if(isLoading==true)		app.loadding.show();
		
		mui.ajax({
			headers: option['HEADER'],
			type:option['TYPE'],
			url: config.HOST+option['URL'],
			data:option['DESStr'],
			dataType: 'json',
			contentType: "application/json",
			timeout: 45000, //超时时间
			success : function(data){
				app.loadding.hide();
				if(data.result == 100){
					app.checkLogin(1, 'checkLoginCallback');
					//app.DateUtil.initCountdown();
				}else if(data.result == 1){
					data.imagePath = config.HOST_IMG;
					successCallback(data);
				}else{
					if(errorCallback) errorCallback(data);
					else app.toAlert(data.message);
				}
			},
			error : function(xhr, type, errorThrown){
				app.loadding.hide();
				app.toast("网络繁忙,请稍后重试");
				//mui.alert("["+option['URL']+"] Post到火星就失踪啦 ! 赶紧上报.!");
				//errorCallback(xhr, type, errorThrown);
			}
		});
	},
	DateUtil : {
		timer : function(ts, callback){
			//var ts = (new Date(2018, 11, 11, 9, 0, 0)) - (new Date());//计算剩余的毫秒数  
			var data = {};
			data.dd = parseInt(ts / 60 / 60 / 24, 10);//计算剩余的天数
			data.hh = parseInt(ts / 60 / 60 % 24, 10);//计算剩余的小时数  
			data.mm = parseInt(ts / 60 % 60, 10);//计算剩余的分钟数  
			data.ss = parseInt(ts % 60, 10);//计算剩余的秒数  

			data.dd   = data.dd ;
			data.hh   = 10 > data.hh ? "0"+data.hh : data.hh ;
			data.mm = 10 > data.mm ? "0"+data.mm : data.mm ;
			data.ss   = 10 > data.ss ? "0"+data.ss : data.ss ;
			if(callback) callback(data);
		},
		timerfx : function(ts){
			var retu = [],data = {};
			data.dd = parseInt(ts / 60 / 60 / 24, 10);//计算剩余的天数
			data.hh = parseInt(ts / 60 / 60 % 24, 10);//计算剩余的小时数  
			data.mm = parseInt(ts / 60 % 60, 10);//计算剩余的分钟数  
			data.ss = parseInt(ts % 60, 10);//计算剩余的秒数  
			if(data.dd>0){
				//data.hh = parseInt(data.hh+data.dd*24);
				retu.push(data.dd);
			} 
			retu.push(10 > data.hh ? "0"+data.hh : data.hh);
			retu.push(10 > data.mm ? "0"+data.mm : data.mm);
			retu.push(10 > data.ss ? "0"+data.ss : data.ss);
			return retu.join(":");
		},
		onTimeout : function(ts,self){
			ts = ts -1;
			self.setAttribute("time",ts);
			self.innerText = app.DateUtil.timerfx(ts);
			setTimeout(function(){
				if(ts > 0){
					app.DateUtil.onTimeout(ts,self);
				}
			},1000);
		}, 
		initCountdown : function(){
			setTimeout(function(){
				mui(".timer").each(function(){
					var time = this.getAttribute("time");
					this.classList.add('timer0');
					this.classList.remove('timer');
					app.DateUtil.onTimeout(time,this);
				});
			},1000);
		}
	},
	scroll : {
		option : {
			id : '', // true 为没有下一页   false：可以继续下一页
			scrollDom : mui(".mui-scroll-wrapper")[0], // 滚动容器
			up : function(target){}
		},
		init : function(option){
			app.scroll.option = mui.extend(app.scroll.option,option);
			app.scroll.onScroll();//注册滚动事件
		},
		onScroll : function(){
			app.scroll.option.scrollDom.addEventListener('scroll', function(e) {
				var clientHeight = e.target.parentNode.clientHeight;
				var scrollHeight = e.target.parentNode.scrollHeight;
				if(clientHeight >= scrollHeight){
					var up = this.getAttribute("up");
					if(up == 'true'){
//						mui("header h1")[0].innerHTML = mui("header h1")[0].innerHTML+":"+this.id.substring(7,8)+':';
						this.setAttribute("up",'false');
						app.scroll.option.up(this);
					}
				}
			});
		}
	},
	parseDom : function(arg){
　　 var objE = document.createElement("div");
　　 objE.innerHTML = arg;
　　 return objE.childNodes;
	},
	toAlert : function(msg) {
		alert(msg);
	}
}
 
var loadding = true;
app.loadding = {
	init : function(){
		var loadd = document.createElement("div");
		loadd.className = 'loadding-ant  no1-active';
		loadd.innerHTML = "<div class='span'><div class='mui-spinner'></div></div>";
		mui('body')[0].appendChild(loadd);
	},
	show : function(){
		if(loadding == true){
			if(!mui('.loadding-ant')[0]){
				app.loadding.init();
			}
			mui('.loadding-ant')[0].setAttribute("class","loadding-ant load-active");
		}
	},
	hide : function(){
		if(mui('.loadding-ant')[0]){
			mui('.loadding-ant')[0].setAttribute("class","loadding-ant");
		}
	}
}

app.alert = {
	init : function(){
		var loadding = document.createElement("div");
		loadding.className = 'alert-ant no1-active';
		loadding.innerHTML = '<div class="mui-popup mui-popup-in" style="display: block;"><div class="mui-popup-inner"><div class="mui-popup-title"></div><div class="mui-popup-text">是否确定删除订单？</div></div><div class="mui-popup-buttons"><span class="mui-popup-button">确定</span><span class="mui-popup-button">取消</span></div></div>';
		loadding.innerHTML += '<div class="mui-popup-backdrop mui-active" style="display: block;"></div>';
		mui('body')[0].appendChild(loadding);
	},
	show : function(){
		if(!mui('.alert-ant')[0]){
			app.loadding.init();
		}
		mui('.loadding-ant')[0].setAttribute("class","loadding-ant load-active");
	},
	hide : function(){
		mui('.loadding-ant')[0].setAttribute("class","loadding-ant");
	}
}

app.toast = function(message, delay){
	var toast = document.createElement('div');
	toast.classList.add('mui-toast-container');
	toast.innerHTML = '<div class="' + 'mui-toast-message' + '">' + message + '</div>';
	toast.addEventListener('webkitTransitionEnd', function() {
		if (!toast.classList.contains('mui-active')) {
			toast.parentNode.removeChild(toast);
		}
	});
	document.body.appendChild(toast);
	toast.offsetHeight;
	toast.classList.add('mui-active');
	var t = 3000;
	if(delay) t = delay;
	setTimeout(function() {
		toast.classList.remove('mui-active');
	}, t);
}

app.confirm =  {
	option : {
		message :  '是否确认当前操作?',
		title : '', 
		btnArray : ['取消','确认'],
		callback : function(){}
	},
	init : function(option){
		app.confirm.option = mui.extend(app.confirm.option,option);
		var div_ = document.getElementById("app-confirm") || document.createElement("div");
		div_.id = 'app-confirm';
		div_.innerHTML = '';
		var html = '<div class="mui-popup mui-popup-in" >';
			html += '<div class="mui-popup-inner">';
				html += '<div class="mui-popup-title">'+app.confirm.option.title+'</div>';
				html += '<div class="mui-popup-text">'+app.confirm.option.message+'</div>';
			html += '</div>';
			html += '<div class="mui-popup-buttons">';
			mui(app.confirm.option.btnArray).each(function(i,btn){
				html += '<span class="mui-popup-button btnArray" index="'+i+'">'+btn+'</span>';
			});
			html += '</div></div>';
			html += '<div class="mui-popup-backdrop mui-active" style="display: block;"></div>';
			div_.innerHTML = html;
			
			mui('body')[0].appendChild(div_);
			
			mui('.mui-popup-buttons').on("tap","span",function(){
				var i = this.getAttribute('index');
				app.confirm.option.callback(i);
				div_.innerHTML = '';
			});
	}
}
app.saveIMGS = {
		init: function(){
			mui.init( {
				gestureConfig:{
					longtap: true, //默认为false
				}
			})
			mui.previewImage({zoom: false});
			mui("img").each(function () {
				this.addEventListener("longtap",function(){
//					if(mui.os.android){
						var imgurl = this.src;
						var name = imgurl.split('/')[imgurl.split('/').length-1].split('.jpg')[0];
						app.confirm.init({
							message: '是否保存图片？',
							btnArray : ['取消','确认'],
							callback: function(i) {
							if(i==1){
								if(mui.os.android){
									HMARTJsObj.saveImage(imgurl,'hmqq',name,'app.saveIMGS.result');
								}else{
									if(typeof(HMARTJsObj) == "undefined"){
										var data = {
												method:'saveImage',
												image: imgurl
											};
										window.webkit.messageHandlers.AppModel.postMessage(data);
									}else{
										HMARTJsObj.saveImage(imgurl,'app.saveIMGS.result');
									}
								}
							}
							}
						})	
//					}					
				})
			});
			mui('#__MUI_PREVIEWIMAGE').on('longtap','img',function(){
//				if(mui.os.android){
					var imgurl=this.src;
					var name=imgurl.split('/')[imgurl.split('/').length-1].split('.jpg')[0];
					app.confirm.init({
						message:'是否保存图片',
						btnArray:['取消','确认'],
						callback:function(i){
						if(i==1){
							if(mui.os.android){
								HMARTJsObj.saveImage(imgurl,'hmqq',name,'app.saveIMGS.result');
							}else{
								if(typeof(HMARTJsObj) == "undefined"){
									var data = {
											method:'saveImage',
											image: imgurl
										};
									window.webkit.messageHandlers.AppModel.postMessage(data);
								}else{
									HMARTJsObj.saveImage(imgurl,'app.saveIMGS.result');
								}
							}
						}
						}
					})
//				}
			})
		},
		result : function(data){
			if(data=='true'){
				if(mui.os.android){
					app.toast('已保存到/storage/emulated/0/hmqq文件夹下')
				}else{
					app.toast('图片保存成功')
				}
			}else{
				app.toast('保存失败')
			}
		}
	
}
/* *
 * 全局请求域配置
 * */
api = {
	main : { /* 主页 api */
		search : { /*banner列表查询*/
			TYPE : "POST",
			URL	: 'advert/search.htm',
			DATA : {
				adPos : '003' //必选 固定值003
			}
		},
		homeiocn : { /*推荐图标 查询*/
			TYPE : "POST",
			URL	: 'apphome/homeiocn.htm',
			DATA : {
				
			}
		},
		seckill : { /*秒杀查询*/
			TYPE : "POST",
			URL	: 'apphome/seckill.htm',
			DATA : {}
		},
		sepcial : {/*推荐专场查询*/
			TYPE : "POST",
			URL	: 'apphome/sepcial.htm',
			DATA : {}
		},
		artRec : {/*精品推荐查询*/
			TYPE : "POST",
			URL	: 'apphome/artRec.htm',
			DATA : {}
		}
	},
	sepcial :{
		list : {
			TYPE : "POST",
			URL	: 'special/search.htm',
			DATA : {
				pageIndex : 1,
				pageSize :10,
				other:{}
			}
		},
		detail : { //专场说明
			TYPE : "POST",
			URL	: 'special/detail.htm',
			DATA : {
				id : ''
			}
		}
	},
	store : { /* 商店 api */
		shop : {
			search : {
				TYPE : "POST",
				URL	: '/shop/search.htm',
				DATA : {
					pageIndex : 1,
					pageSize :10,
					other : {
						keywork : '' //关键字
					}
				}
			},
			list : {
				TYPE : "POST",
				URL	: 'shop/list.htm',
				DATA : {
					pageIndex : 1,
					pageSize :10,
					other : {
						keywork : '' //关键字
					}
				}
			},
			detail : {
				TYPE : "POST",
				URL	: 'shop/detail.htm',
				DATA : {
					shopId: ''
				}
			},
			homeArt : {
				TYPE : "POST",
				URL	: 'shop/homeArt.htm',
				DATA : {
					sellerId: ''
				}
			}
			
		},
		search : { // 列表查询
			TYPE : "POST",
			URL	: 'awo/search.htm',
			DATA : {
				pageIndex : 1,
				pageSize :30,
				other : {
					type : '', //0：一口价；1:正在paimai；2：预展；3：历史；不传查全部
					classifyCode : '',//分类id
					sellerId :'',//商家id
					sepcialId:'',//专场ID
					keywork : '',//
					minPrice : '',//最小金额
					maxPrice : '',//最大金额
					sort :'0',	//排序字段 0:综合,1:价格;2:浏览量;3:最新上线
					order :'' //排序方向
				}
			}
		},
		classfiy : { //分类查询
			TYPE : "POST",
			URL	: 'classfiy/search.htm',
			DATA : {
				id : '' //分类id;不传查全部分类
			}
		},
		detail : { //详情
			TYPE : "POST",
			URL	: 'awo/detail.htm',
			DATA : {
				sellerId : 0,//商家id
				ownerId : ''
			}
		},
		subscribe : { //开拍提醒
			TYPE : "POST",
			URL	: 'awo/subscribe.htm',
			DATA : {
				ownerId : ''//ownerId
			}
		},
		records : { //出价记录
			TYPE : "POST",
			URL	: 'awo/records.htm',
			DATA : {
				id : ''//ownerId
			}
		},
		createOder : { // 立即购买
			TYPE : "POST",
			URL	: 'awo/createOder.htm',
			DATA : {
				type : 1, //默认值 1   2：限时秒杀
				id : '', //默认ownerId  type=2时传seckillId
				mobile : ''
			}
		},
		bidding : { //我要出价
			TYPE : "POST",
			URL	: 'awo/bidding.htm',
			DATA : {
				price : '', //金额
				id : '', //ownerId
				mobile : ''
			}
		},
		agentPrice : { //我要出价
			TYPE : "POST",
			URL	: 'awo/agentPrice.htm',
			DATA : {
				price : '', //金额
				id : '', //ownerId
				mobile : ''
			}
		}
	},
	auction : { /* paimai api */
		auction : { /* paimai 列表 */
			TYPE : "POST",
			URL	: 'awo/auction.htm',
			DATA : {
				pageIndex : 1,
				pageSize :10,
				other : {
					type : 1, //1:正在paimai；2：预展；3：历史
					classifyCode : ''
				}
			}
		}
	},
	fixed : { /* fixed api */
		
	},
	my : {
		getCount : {
			TYPE : "POST",
			URL	: 'member/getCount.htm',
			DATA : {mobile : ''}
		},
		logout : {
			TYPE : "POST",
			URL	: '/member/logout.htm',
			DATA : {mobile : ''}
		},
		getLoginMobile :{
			TYPE : "POST",
			URL	: 'getLoginMobile.htm',
			DATA : {}
		},
		updatePwd : {
			TYPE : "POST",
			URL	: 'member/uppwd.htm',
			DATA : {oldPwd : '',newPwd : ''}
		},
		consignee : {
			list : {
				TYPE : "POST",
				URL	: 'consignee/list.htm',
				DATA : {mobile : ''}
			},
			update : { /* 新增或修改地址 */
				TYPE : "POST",
				URL	: 'consignee/update.htm',
				DATA : {
					id : '',//修改时不为空
					mobile : '',
					name : '',
					tel : '',
					defaults : true, //默认收货地址
					addr : ''
				}
			},
			del : {
				TYPE : "POST",
				URL	: 'consignee/del.htm',
				DATA : {id:'',mobile : ''}
			},
			defaults : {
				TYPE : "POST",
				URL	: 'consignee/default.htm',
				DATA : {id:'',mobile : ''}
			}
		},
		voucher : { /* 我的优惠券 */
			TYPE : "POST",
			URL	: 'voucher/search.htm',
			DATA : {
				pageIndex : 1,
				pageSize :10,
				other : {
					type : 1, //1:正常；2：已使用; 3：已过期
					mobile : '' //登录用户手机号
				}
			}
		},
		auctions : { /* 我的paimai */
			myAuction : { // paimai的
				TYPE : "POST",
				URL	: 'auctions/myAuction.htm',
				DATA : {
					pageIndex : 1,
					pageSize :30,
					other : {
						mobile : '' //登录用户手机号
					}
				}
			},
			mySuccAuction : {// 竞买的
				TYPE : "POST",
				URL	: 'auctions/mySuccAuction.htm',
				DATA : {
					pageIndex : 1,
					pageSize :30,
					other : {
						mobile : '' //登录用户手机号
					}
				}
			}
		},
		order : {
			list : {
				TYPE : "POST",
				URL	: 'order/search.htm',
				DATA : {
					pageIndex : 1,
					pageSize :10,
					other : {
						mobile : '', //登录用户手机号
						type : "0" //0:全部；1：待支付；2：待发货；3：待签收
					}
				}
			},
			prePayment : {
				TYPE : "POST",
				URL	: 'order/prePayment.htm',
				DATA : {
					mobile : '', //登录用户手机号
					orderIds : "" 
				}
			},
			createPayment : {
				TYPE : "POST",
				URL	: 'order/createPayment.htm',
				DATA : {
					mobile : '', //登录用户手机号
					orderIds : '',
					consigneeId:'',
					voucherId:'',
					type:'1'
				}
			},
			groupDetial : {
				TYPE : "POST",
				URL	: 'order/groupDetial.htm',
				DATA : {
					groupId : ''
				}
			},
			queryExpress : {
				TYPE : "POST",
				URL	: 'order/queryExpress.htm',
				DATA : {
					groupId : ''
				}
			},
			detial : {
				TYPE : "POST",
				URL	: 'order/detial.htm',
				DATA : {
					mobile : '', //登录用户手机号
					orderId : ''
				}
			},
			signFor : {
				TYPE : "POST",
				URL	: 'order/signFor.htm',
				DATA : {
					groupId : '',
					orderId: ''
				}
			},
			refund : {
				TYPE : "POST",
				URL	: 'order/refund.htm',
				DATA : {
					orderId : ''
				}
			},
			cancel : {
				TYPE : "POST",
				URL	: 'order/cancel.htm',
				DATA : {
					orderId : ''
				}
			},
			refundList : {
				TYPE : "POST",
				URL	: 'order/refundList.htm',
				DATA : {
					pageIndex : 1,
					pageSize :10
				}
			}
		},
		favorite : {
			artwork : {
				TYPE : "POST",
				URL	: 'favorite/artwork.htm',
				DATA : {
					pageIndex : 1,
					pageSize :30,
					other : {
						mobile : '', //登录用户手机号
					}
				}
			},
			stowArt : {
				TYPE : "POST",
				URL	: 'favorite/stowArt.htm',
				DATA : {
					ownerId : ''
				}
			},
			shop : {
				TYPE : "POST",
				URL	: 'favorite/shop.htm',
				DATA : {
					pageIndex : 1,
					pageSize :30,
					other : {
						mobile : '', //登录用户手机号
					}
				}
			},
			stowShop : {
				TYPE : "POST",
				URL	: 'favorite/stowShop.htm',
				DATA : {
					shopId : ''
				}
			}
		},
		refund : { /* 退款申请 */
			TYPE : "POST",
			URL	: 'order/refund.htm',
			DATA : {
				orderId : '',
				remark:'',
				image:''
			}
		},
		subscribe : {
			artwork : {
				TYPE : "POST",
				URL	: 'subscribe/artwork.htm',
				DATA : {
					pageIndex : 1,
					pageSize :10,
					other : {
						mobile : '', //登录用户手机号
					}
				}
			},
			cancelArt : {
				TYPE : "POST",
				URL	: 'subscribe/cancelArt.htm',
				DATA : {
					ownerId : ''
				}
			}
		},
		deposit : {
			serach : {
				TYPE : "POST",
				URL	: 'deposit/serach.htm',
				DATA : {
					mobile : '', //登录用户手机号
				}
			},
			refund :{
				TYPE : "POST",
				URL	: 'deposit/refund.htm',
				DATA : {
					type : ''
				}
			},
			recharge : {
				TYPE : "POST",
				URL	: 'deposit/recharge.htm',
				DATA : {
					type : '',
					payType : '',
					amount : '' 
				}
			},
			user : {
				TYPE : "POST",
				URL	: 'deposit/user.htm',
				DATA : {
					pageIndex : 1,
					pageSize :10,
					other : {
						mobile : '', //登录用户手机号
					}
				}
			},
			seller : {
				TYPE : "POST",
				URL	: 'deposit/seller.htm',
				DATA : {
					pageIndex : 1,
					pageSize :10,
					other : {
						mobile : '', //登录用户手机号
					}
				}
			}
		},
		wxJsPayStatus: {
			TYPE : "POST",
			URL	: '/payment/status.htm',
			DATA : {paySerialNo:''}
		}
	},
	push : {
		list: {
			TYPE : "POST",
			URL	: 'pushNotice/search.htm',
			DATA : {
				pageIndex : 1,
				pageSize :10,
				other: {
					deviceId : '' //设备ID
				}
			}
		},
		getCount: {
			TYPE : "POST",
			URL	: 'pushNotice/getCount.htm',
			DATA : {
				deviceId : '' //设备ID
			}
		}
	},
	sysNews : {
		list: {
			TYPE : "POST",
			URL	: 'sysNews/search.htm',
			DATA : {
				pageIndex : 1,
				pageSize :10
			}
		}
	},
	shopNews : {
		list: {
			TYPE : "POST",
			URL	: 'shopNews/search.htm',
			DATA : {
				pageIndex : 1,
				pageSize :10,
				other:{
					shopId :''
				}
			}
		}
	},
	vf : {
		list: {
			TYPE : "POST",
			URL	: 'vf/list.htm',
			DATA : {
				sellerId :''
			}
		},
		get: {
			TYPE : "POST",
			URL	: 'vf/get.htm',
			DATA : {
				id :''
			}
		}
	},
	seckill : {
		title: {
			TYPE : "POST",
			URL	: 'seckill/title.htm',
			DATA : {
				pageIndex : 1,
				pageSize :10
			}
		},
		list: {
			TYPE : "POST",
			URL	: 'seckill/list.htm',
			DATA : {
				pageIndex : 1,
				pageSize :30,
				other:{
					factoryId:''
				}
			}
		},
		detail: {
			TYPE : "POST",
			URL	: 'seckill/detail.htm',
			DATA : {
				seckillId : ''
			}
		}
	},
	other : { /* 其他 api */
		appVersion:{
			cuurVer:'',
			TYPE : "POST",
			URL	: 'apphome/appVersion.htm',
			DATA : {
				type : ''
			}
		},sysVersion:{//系统版本
            TYPE : "POST",
            URL	: 'device/getDeviceVersion.htm',
            DATA : {
                device : ''//设备型号
            }
        }
	}
}

function loadJs(jssrc){
    //得到html的头部dom
    var theHead = document.getElementsByTagName('head').item(0);
    //创建脚本的dom对象实例
    var myScript = document.createElement('script');
    myScript.src = jssrc;           //指定脚本路径
    myScript.type = 'text/javascript';  //指定脚本类型
    myScript.defer = true;              //程序下载完后再解析和执行
    theHead.appendChild(myScript);      //把dom挂载到头部
}

/** js加载初始化页面 返回按钮\IOS状态栏高度/  ***/
//阻尼系数
var deceleration = mui.os.ios?0.003:0.0009;
app.load.init();
function pageWillRefresh(){
	refresh = true;
	if(typeof(pageRefresh) != "undefined"){
		pageRefresh();
	}
//	if(typeof(refresh) == "undefined"){
//		refresh = false;
//	}else{
//		refresh = true;
//		if(typeof(pageRefresh) != "undefined"){
//			pageRefresh();
//		}
//	}
//	alert(refresh);
}
