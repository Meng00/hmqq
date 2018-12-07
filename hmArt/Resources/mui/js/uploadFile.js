$(function(){
	initUploadFileHtml();
});

function initUploadFileHtml(fun){
	if($('#uploadImgFrame').length<1)$('body').append('<iframe id="uploadImgFrame" name="uploadImgFrame" style="display: none;"><script type="text/javascript">function file_callback(){alert(111);}</script></iframe>');
	$('body').append('<script>var fileCallback; var fileType;</script>');
	if(fun) fun();
}

function htmlUploadImgFile(id, append){
	htmlUploadFile(id, 1, append);
}

/**
 * 上传文件按钮触发函数
 * @param id 显示层Id
 * @param fileType 1: 图片 
 * @param append 是否多图
 */
function htmlUploadFile(id, fileType, append){
	uploadFile(function(data){
		if(data && data.result == 1){
			alert('上传成功');
			if(fileType == 1){
				if(append) $('#'+id).append('<div><img style="width: 200px;" src="'+imagePath+data.uri+'" value="'+data.uri+'"/>&nbsp;<span style="cursor: pointer;" onclick="htmlFileDel(this);">X</span></div>');
				else $('#'+id).html('<div"><img style="width: 200px;" src="'+imagePath+data.uri+'" value="'+data.uri+'"/>&nbsp;<span style="cursor: pointer;" onclick="htmlFileDel(this);">X</span></div>');
			}
		}else{
			if(data && data.message) alert(data.message);
			else alert('上传失败');
		}
	},fileType);
}

function uploadFile(callBack,type){
	initUploadFileHtml(function(){
		fileType = type;
		fileCallback = function(data){ if(callBack) callBack(data); };
	});
	
}

function htmlFileDel(id){
	$(id).parent().remove();
}

function htmlShowImg(id ,images){
	if(images && images.length > 0 ){
	    $((images).split(',')).each(function(i,obj){
	    	$('#'+id).append('<div><img style="width: 200px;" src="'+imagePath+obj+'" value="'+obj+'"/>&nbsp;<span style="cursor: pointer;" onclick="htmlFileDel(this);" style="cursor:pointer">X</span></div>');
	    });
	}
}

function htmlDelImg(id){
	$('#'+id).html('');
}

function htmlInputImg(id){
	var imgStr = "";
	$('#'+id+' img').each(function(i,img){
		imgStr = imgStr+ ','+ $(img).attr('value');
	});
	if(imgStr.length>1)imgStr = imgStr.substring(1);
	return imgStr;
}

function submitFile(thisFile){
	if(fileCheckIsFile($(thisFile).val())){
		//showLoading();
		app.loadding.show();
		$(thisFile).parent().submit();
	}
}

function file_callback(result){
	var data = eval("(" + result + ")");
	//hideLoading();
	app.loadding.hide();
	if(fileCallback) fileCallback(data);
}

//校验图片类型
function fileCheckIsFile(fileName){
	if(!fileName){
		alert('请选择需要上传的文件！');
		return false;
	}
// 	var f_type = fileName.substr(fileName.lastIndexOf('.') + 1, fileName.length);
//	if(fileType){
//		var inputType = new Array();
//		if(fileType == 1) inputType = new Array("jpg","jpeg","gif","png");
//		var isTrueFile = false;
//	 	$(inputType).each(function(i,type){
//			if(f_type.toLowerCase() == type.toLowerCase()){
//				isTrueFile = true;
//	     		return;
//			}	
//	 	});
//	 	if(!isTrueFile){
//	 		alert('文件类型错误,请选择正确的文件格式！');
//	 	}
//	 	return isTrueFile;
//	}
	return true;
		
	
}
