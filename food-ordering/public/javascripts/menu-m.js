$(function() {
	var windowHeight=$(window).height();
	$(".restaurant-content").height(windowHeight-44-39-42);
	var num = null;
	var menuOrder=[];
	var shopId=window.location.pathname.split("/")[5]; //非常不健壮
	localStorage.setItem("shopId",shopId);
	var trueData=null;
	var classifyObj={};
    $(".header-title").text($("#shopName").val());
	$.ajax({
		url: '/shop/account/web/menu-m',
            type: 'POST',
            data: {"shopId":shopId},
            success: function(data, status) {
                if (data.success) {
                    Array.prototype.uniqueFunc = function() {
                    var res = [];
                    var json = {};
                    for (var i = 0; i < this.length; i++) {
                        if (!json[this[i].dishName]) {
                            res.push(this[i]);
                            json[this[i].dishName] = 1;
                        }
                    }
                    return res;
                }
                var dish = data.dish.uniqueFunc();

                    trueData=dish;
                    for(var i=0;i<trueData.length;i++){
                    	if(!classifyObj[trueData[i].category]){
                    		classifyObj[trueData[i].category]=[];
							classifyObj[trueData[i].category].push(trueData[i]);
                    	}else{
                    		classifyObj[trueData[i].category].push(trueData[i]);
                    	}
                    }
                }
            }
	});

    $(".restaurant-menu-item").on("click", loadContent);

	$(document).on("click",".mdish-cartcontrol",changeCart);
	$(document).on("click",".minus-cartcontrol",minusCart);

    $(".mdish-cartcontrol").on("click",changeCart)
	$(".mcart-checkout").on("click",order);
	var loadBefore={};

      Array.prototype.avg=function(key){
    if(this.length==0){
    return 0;
    }
    var sum=0;
    var num=this.length;
    this.forEach(function(cur,ind){
      sum+=cur[key];
    })
    return sum/num;
    }

    function loadContent() {
        num = $(this).find(".category").text();
        var index=$(this).index();
        $(".restaurant-menu-item").eq(index).addClass("active").siblings().removeClass("active");
        if(!loadBefore[num]){
        	var currentData = classifyObj[num];
        var markup = '<div class="restaurant-food-container"> \
        <img width="70" height="70" style="opacity: 1; transition: opacity 0.5s;" src=${dishPic.split("8080")[1]}> \
        <div class="restaurant-food-body"> \
            <p class="restaurant-food-name">${dishName}</p> \
            <div class="restaurant-food-content"> \
                <div class="restaurant-food-info"> \
                    <p class="restaurant-food-about"> \
                        <div class="star-rating" progress-meter="5"> \
                            <div progress-fill=${comment.avg("mark")} style="width:${comment.avg("mark")/5.0*100}%;" class="star-meter"> \
                            </div> \
                        </div> \
                        <span class="color-mute"> \
                            (${comment.length}) \
                        </span> \
                    </p> \
                    <div class="restaurant-food-footer"> \
                        <span class="restaurant-food-price">${price}</span> \
                        <div class="mdish-cartcontrol">+</div> \
                    </div> \
                    <input type="hidden" value=${_id} class="dishId"> \
                </div> \
            </div> \
        </div> \
    </div>';
        $.template("menuClassTemplate", markup);
        loadBefore[num]=$.tmpl("menuClassTemplate", currentData);
        $(".restaurant-food section").html(loadBefore[num]);
    }else{
    	$(".restaurant-food section").html(loadBefore[num]);
    }
    }

    function changeCart(){
    	var num=+$(".ui-quantity").text();
    	var price=+$(this).siblings(".restaurant-food-price").text();
    	var originalPrice=+$(".mcart-price").text();
    	if($(".restaurant-menu-item.active span").length==1){
    		$("<span class='restaurant-menu-tip'>1</span>").insertBefore(".restaurant-menu-item.active span");
    	}else{
    		var tip=$(".restaurant-menu-item.active .restaurant-menu-tip");
    		var orderNum=Number(tip.text());
    		tip.text(++orderNum)
    	}
    	if(!$(this).siblings(".food-num")[0]){
    		$('<div class="minus-cartcontrol">-</div> \
            <span class="food-num">1</span>').insertBefore($(this));
    	}else{
    		var currentNum=$(this).siblings(".food-num").text();
    		$(this).siblings(".food-num").text(++currentNum);
    	}
		$(".ui-quantity").text(++num);
		$(".mcart-price").text(originalPrice+price);
		var dishName=$(this).parents(".restaurant-food-content").siblings(".restaurant-food-name").text();
		var dishPrice=+$(this).siblings(".restaurant-food-price").text();
        var dishId=$(this).parent().siblings(".dishId").val();

        console.log($(this))
		var find=false;
		for(var i=0;i<menuOrder.length;i++){
			if(menuOrder[i].dishName==dishName){
				menuOrder[i].num++;
				menuOrder[i].price+=dishPrice;
                menuOrder[i].dishId=dishId;
				find=true;
				break;
			}
		}
	if(!find){
		var obj={};
				obj.dishName=dishName;
				obj.price=dishPrice;
				obj.num=1;
                obj.dishId=dishId;
				menuOrder.push(obj);
	}
    }
    function minusCart(){
    	var tip=$(".restaurant-menu-item.active .restaurant-menu-tip");
    	var currentNum=$(this).siblings(".food-num").text();
    	var num=+$(".ui-quantity").text();
    	var price=+$(this).siblings(".restaurant-food-price").text();
    	var originalPrice=+$(".mcart-price").text();
    	var dishName=$(this).parents(".restaurant-food-content").siblings(".restaurant-food-name").text();
		var dishPrice=+$(this).siblings(".restaurant-food-price").text();

    	if(tip.text()=="1"){
    		tip.remove();
    		if($(this).siblings(".food-num").text()!="1"){
    			$(this).siblings(".food-num").text(--currentNum);
    		}else{
    			$(this).siblings(".food-num").remove();
    			$(this).remove();
    		}
    	}else{
    		if($(this).siblings(".food-num").text()!="1"){
    			$(this).siblings(".food-num").text(--currentNum);
    		}else{
    			$(this).siblings(".food-num").remove();
    			$(this).remove();
    		}
    		tip.text(tip.text()-1);
    	}
    	$(".ui-quantity").text(--num);
		$(".mcart-price").text(originalPrice-price);

		for(var i=0;i<menuOrder.length;i++){
			if(menuOrder[i].dishName==dishName &&menuOrder[i].num>1){
				console.log(">1")
				menuOrder[i].num--;
				menuOrder[i].price-=dishPrice;
				break;
			}else if(menuOrder[i].dishName==dishName ){
				menuOrder.splice(i, 1);
			}
		}
		console.log(menuOrder)

    }
    function dishOrder(){
        var orderList=[];
        $(".shop-cartbasket-tablerow").each(function() {
            var dishName=$(this).find(".itemname").text(),
                num= +$(this).find("input").attr("value"),
                singlePrice = +$(this).find(".itemtotal").attr("data-single"),
                order={};
                order.dishName=dishName;
                order.num=num;
                order.price=singlePrice*num;
                orderList.push(order);
        });

        localStorage.setItem('orderList',JSON.stringify(orderList));
        localStorage.setItem('totalPrice',$(".shop-cartfooter-text").text());
        window.location="/user/account/web/order";

    }

    function order(){
        if($(".mcart-price").text()=="0"){
            return false;
        }
    	localStorage.setItem('menuOrder',JSON.stringify(menuOrder));
        localStorage.setItem('totalPrice',$(".mcart-price").text());
        window.location="/user/account/web/order/m";
    }

    $(".comment").on("click",function(){
        var shopId=location.href.split("/")[7];
        window.location="/user/account/web/rate/"+shopId+"/m";
    })
 $(".infoTab").on("click",function(){
        var shopId=location.href.split("/")[7];
        window.location="/user/account/web/info/"+shopId+"/m";
    })

 setTimeout(function(){
    $(".restaurant-menu-item").eq(0).click()
 },1000)

})