/*
 *template 拓展JS 
 * Roar..
 */

/** 
 * toString 对象转string
 * @param data 要格式化的日期 
 * @return String
 */
template.helper('toString', function (data) {
	return JSON.stringify(data); 
});	

/**
 *  x + y
 */
template.helper('plus', function (x,y) {
	return parseInt(x) + parseInt(y); 
});	

/** 
 * 对日期进行格式化， 
 * @param date 要格式化的日期 
 * @param format 进行格式化的模式字符串
 *     支持的模式字母有： 
 *     y:年, 
 *     M:年中的月份(1-12), 
 *     d:月份中的天(1-31), 
 *     h:小时(0-23), 
 *     m:分(0-59), 
 *     s:秒(0-59), 
 *     S:毫秒(0-999),
 *     q:季度(1-4)
 * @return String
 * @author yanis.wang
 */
template.helper('dateFormat', function (date, format) {
    date = new Date(parseInt(date));
    var map = {
        "M": date.getMonth() + 1, //月份 
        "d": date.getDate(), //日 
        "h": date.getHours(), //小时 
        "m": date.getMinutes(), //分 
        "s": date.getSeconds(), //秒 
        "q": Math.floor((date.getMonth() + 3) / 3), //季度 
        "S": date.getMilliseconds() //毫秒 
    };
    format = format.replace(/([yMdhmsqS])+/g, function(all, t){
        var v = map[t];
        if(v !== undefined){
            if(all.length > 1){
                v = '0' + v;
                v = v.substr(v.length-2);
            }
            return v;
        }else if(t === 'y'){
            return (date.getFullYear() + '').substr(4 - all.length);
        }
        return all;
    });
    return format;
});

template.helper('timer', function (ts) {
	var retu = [];
	var data = {};
	data.dd = parseInt(ts / 60 / 60 / 24, 10);//计算剩余的天数
	data.hh = parseInt(ts / 60 / 60 % 24, 10);//计算剩余的小时数  
	data.mm = parseInt(ts / 60 % 60, 10);//计算剩余的分钟数  
	data.ss = parseInt(ts % 60, 10);//计算剩余的秒数  

	data.dd   = 10 > data.dd ? "0"+data.dd : data.dd ;
	data.hh   = 10 > data.hh ? "0"+data.hh : data.hh ;
	data.mm = 10 > data.mm ? "0"+data.mm : data.mm ;
	data.ss   = 10 > data.ss ? "0"+data.ss : data.ss ;
	
//	retu.push(data.dd);
	retu.push(data.hh);
	retu.push(data.mm);
	retu.push(data.ss);
	return retu.join(":");
//	return data.dd+"天"+data.hh+"时"+data.mm+"分"+data.ss+"秒"; 
//	return data.dd+":"+data.hh+":"+data.mm+":"+data.ss; 
});	

template.helper('toStar', function (num) {
	var star = "";
	for(var i = 0 ;i < num; i++){
		star+='<span class="mui-icon mui-icon-star"></span>';
	}
	return star; 
});	