//var ajaxPath = 'http://app.4008988518.com/art-interface/';
var ajaxPath = 'https://www.4008988518.com:8180/art-interface/';
//var ajaxPath = 'http://192.168.10.211:8080/art-interface/';
var imagePath = 'https://app.4008988518.com/image';
function muiAjax(url, json, success){
    //alert(JSON.stringify(json.desStr));
	mui.ajax(ajaxPath+url, {
		data: JSON.stringify(json.desStr),
		headers: json.headers,
		dataType: 'json', //服务器返回json格式数据
		contentType: "application/json",
		type: 'post', 
		timeout: 30000, //超时时间
		success: function(data) {
            //alert(JSON.stringify(data));
			if(success) success(data);
		},
		error: function(xhr, type, errorThrown) {
			//alert(type+' '+xhr);
			//alert(errorThrown);
			
		}
	});
}


function timer(ts, callback) {  
	var data = {};
	data.dd = parseInt(ts / 60 / 60 / 24, 10);//计算剩余的天数
	data.hh = parseInt(ts / 60 / 60 % 24, 10);//计算剩余的小时数  
	data.mm = parseInt(ts / 60 % 60, 10);//计算剩余的分钟数  
	data.ss = parseInt(ts % 60, 10);//计算剩余的秒数  
	
	data.dd = checkTime(data.dd);
	data.hh = checkTime(data.hh);  
	data.mm = checkTime(data.mm);  
	data.ss = checkTime(data.ss);  
	if(callback) callback(data);
}  
function checkTime(i) {    
   if (i < 10) {    
       i = "0" + i;    
    }
   return i;    
}    

/**
分享
HMARTJsObj.fenxiangTitleContentImageUrlSiteUrl(title,content,imagePath+image,'https://app.4008988518.com/art-interface/jsp/voting/getWorks.htm?id='+id);
HMARTJsObj.goBack();

***/