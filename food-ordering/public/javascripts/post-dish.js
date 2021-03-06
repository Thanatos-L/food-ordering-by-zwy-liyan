$(function() {
    var shopId=localStorage.getItem("socketShop")
    var tagAction = {
        remove: function() {
            $(this).parent(".tag-wrp").remove();
        },
        add: function(self) {
            var content = $(self).val().trim();
            if (content !== "") {
                var newTag = "<div class='tag-wrp'><span class='tag'>" + content +
                    "</span><span class='delete'>×</span></div>";
                $(self).parent().find($(".labels")).append(newTag);
            }
            $(self).val("");
        }
    };

    var uploadPic = {
        add: function(files) {
            var len = files.length > 9 ? 9 : files.length;
            var lTitle=$('<li class="lTitle"><div class="dishImg">Image</div><div class="dishName">Dish Name</div><div class="price">Dish Price</div><div class="category">Category</div></li>')
                lTitle.appendTo($(".dishPreview ul"));
            for (var i = 0; i < len; i++) {
                var file = files[i];
                var imageType = /^image\//;
                if (!imageType.test(file.type)) {
                    continue;
                }
                
                var list = $('<li class="lContent"><div class="dishImg"><img alt="" ></div> \
                        <input type="text" class="dishName"> \
                        <input type="number" class="price"> \
                        <input type="text" class="category"> \
                        </li>')
                var img = list.find("img");

                list.appendTo($(".dishPreview ul"));
                var reader = new FileReader();
                reader.onload = (function(aImg) {
                    return function(e) {
                        aImg.attr("src",e.target.result);
                    };
                })(img);
                reader.readAsDataURL(file);
            }
            $(".uploadPicBtn").hide();
            $("#articlePostBtn").show();
        }
    };

    var uploadBtn = $(".uploadPic");
    uploadBtn.on("change", function() {
        console.log(this.files)
        uploadPic.add(this.files);
    });


    $(".uploadPicBtn").on("click", function() {
        uploadBtn[0].click();
    });

    $(document).on("click", "#articlePostBtn", function() {
        var dish = []
        var num = $(".dishPreview li").length;
        for (var index = 1; index < num; index++) {
            dish[index] = {}
            dish[index].dishName = $(".dishName").eq(index).val();
            dish[index].price = $(".price").eq(index).val();
            dish[index].category = $(".category").eq(index).val();
            dish[index].index = index;
        }
        console.log(dish)

        $.ajax({
            url: '/shop/account/dish',
            data: {
                "dish": dish
            },
            type: 'PUT',
            //contentType: false,
            //processData: false, 
            success: function(data, status) {
                if (data.code == 200) {
                   // alert("上传成功dish");
                    console.log(data.dishes);
                    var originalDishes = data.dishes;
                    var newDishes = [];
                    for (var i = 0; i < originalDishes.length; i++) {
                        if (!originalDishes[i].dishPic) {
                            newDishes.push(originalDishes[i]._id);
                        }
                    }
                    console.log("newDishes",newDishes)
                    var data = new FormData();
                    $.each($(".uploadPic")[0].files, function(i, file) {
                        data.append(i+1, file);
                        //console.log('photo['+i+']', file)
                    })
                    data.append('shopName', $("#shopName").val());
                    for (var i = 1,len=dish.length; i <len ; i++) {
                        data.append('dishNames' + i, dish[i].dishName);
                        data.append('dishId' + i, newDishes[newDishes.length-len+i]);
                    }
                    $.ajax({
                        url: '/shop/account/createDishPic/',
                        data: data,
                        type: 'POST',
                        contentType: false,
                        processData: false,
                        success: function(data, status) {
                            if (data.code == 200) {
                              setTimeout(window.location="/shop/account/web/menu",1000)
                                
                            } else {
                                console.log(data)
                            }
                        },
                        error: function(data, status) {
                            if (data.code != 200) {
                                alert("upload fail!");
                            }
                        }
                    });
                }
            },
            error: function(data, status) {
                if (data.code != 200) {
                    alert("上传shibai");
                }
            }
        });
    })

    $(document).on("click", ".delete", tagAction.remove);
    $(document).on("keydown", "input[type='text']", function(event) {
        if (event.keyCode == 13) {
            tagAction.add(this);
            return false;
        }
    });


})
