module.exports = function(mongoose) {
	var OrderSchema = new mongoose.Schema({
      	user:{type: mongoose.Schema.Types.ObjectId, ref:'Account'},
      	shop:{type: mongoose.Schema.Types.ObjectId, ref:'Shop'},
      	date:{type: Date,default: Date.now},
      	shippedDate:{type: Date, default: Date.now},
      	confirmedDate:{type: Date, default: Date.now},
      	dishs:{type: [{
        	//shopId:{type: String},
	    	itemId:{type: String},
	        amount:{type: Number}
	      }]},
	    address:   {type: {
	    	name: { type: String},
	      	phone: { type: String},
	      	addr: { type: String}
	    }},
	    price:{type:Number},
	    message:{type:String},
	    status:{type:String,enum:['created','shipped','confirmed']},
	    comment:{type:{
	        date:{type: Date,default: Date.now},
	        userId:{type: mongoose.Schema.Types.ObjectId, ref:'Account'},
	        content:{type: String},
	        mark:{type:Number}
	      }} 
	});


var Order = mongoose.model('Order', OrderSchema);

var addOrder = function(userId,shopId,dishs,address,price,message,callback){

	var tempOrder = new Order({
		user:userId,
		shop:shopId,
		dishs:dishs,
		address:address,
		price:price,
		message:message,
		status:'created'
	});

	tempOrder.save(function(err,doc){
		if (err) {
			console.log(err);
			//callback(err);
		}
		callback(doc);

	});

}

var changeOrderStatus = function(shopId,orderId,status,callback){
	
	if (String(status).valueOf() == String("shipped").valueOf()) {
		Order.update({_id:orderId,shop:shopId},{$set:{status:status,shippedDate:new Date}},{upsert:false,runValidators: true},
			function(err){
				console.log(err);
				Order.findOne({_id:orderId},function(err,doc){
					//console.log(doc);
					callback(doc);
					
				})
		})
	} 
	else if (String(status).valueOf() == String("confirmed").valueOf()) {
		Order.update({_id:orderId,shop:shopId},{$set:{status:status,confirmedDate:new Date}},{upsert:false,runValidators: true},
			function(err){
				console.log(err);
				Order.findOne({_id:orderId},function(err,doc){
					//console.log(doc);
					callback(doc);
					
				})
		})
	}
	else {
		Order.update({_id:orderId,shop:shopId},{$set:{status:status}},{upsert:false,runValidators: true},
			function(err){
				console.log(err);
				Order.findOne({_id:orderId},function(err,doc){
					//console.log(doc);
					callback(doc);
					
				})
		})
	}
};

var addComment = function(shopId,orderId,userId,comment,callback) {
       Order.update({_id:orderId,shop:shopId}, {$set: {comment:{
          "userId":userId,
          "content":comment.content,
          "mark":comment.mark
        }}},{upsert:true},
      function (err) {
        console.log(err)
        callback(err);
    });
};

var findById = function(orderId,callback) {
	Order.findOne({_id:orderId}).populate({
		path:'shop'
	}).exec(function(err,doc){
		//console.log(doc.dishs[0].itemId);
		// console.log('order find order');
		// console.log(doc);
		// for(var i = 0; i < doc.shop.dish.length; i++) {
		// 	for (var j = 0; j < doc.dishs.length; j++){
		// 		if (String(doc.shop.dish[i]._id).valueOf() == String(doc.dishs[j].itemId).valueOf()){
		// 		console.log(doc.shop.dish[i]);				
		// 		}
				
		// 	}
		// }

		callback(doc);
	})
}

	return {
	  	addOrder:addOrder,
	  	changeOrderStatus:changeOrderStatus,
	  	addComment:addComment,
	  	findById:findById
  	}
}