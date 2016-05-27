var routeSearch = function (app,io,mongoose) {
var 
  express = require('express'),
  router = express.Router();

var request = require('request');
var URL = require('URL');
var bodyParser = require('body-parser');
var path = require('path');
app.use(bodyParser.urlencoded({
    extended: true
}));
app.use(bodyParser.json());

router.route('/')
.get(function(req, res) {
        res.send('location');
    })

.post(function(req, res) {
    res.send('location');
})

.put(function(req,res){
    res.json({
        msg:"new search.js router"
    })
});

router.route('/findlocation')

    .post(function(req,res){

     var searchLocation = req.param('locaiton');  
     
      request(
        { method: 'GET',
          header : {'Content-Type' : 'application/json; charset=UTF-8'},
          uri: URL.format({
              protocol: 'http',
              host: 'api.map.baidu.com',
              pathname: '/place/v2/suggestion',
              query: {
                  query: searchLocation,
                  region: '全国',
                  output: 'json',
                  ak: 't7vL8QtOIrdigs8b4l0rKwTreBGWFFhN',
              }
          }),
          json:true,
        }
      , function (error, response, body) {
        //console.log(response);
          res.charset = 'UTF-8';
          if (response) {
            var result = response.body.result;
            for(var i = 0;i<result.length;i++){
                 if (result[i].location == null) {
                    console.log(result[i].name);
                    result.splice(i,1);
                    i=-1;continue;
                }
            }
                res.json({
                res:result
              })
              
              
          }
          else{
          	 res.json({
                res:null
              })
          }
        }
      )

    });

    

  return router;
};

module.exports = routeSearch;
//module.exports = router; 