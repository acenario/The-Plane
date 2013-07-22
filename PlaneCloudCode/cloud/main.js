
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.afterSave("Reminders", function(request) {
                     
                      
                      var titleText = request.object.get('title');
                      var fromUserName = request.object.get('fromUser');
                      var forUserName = request.object.get('user');
                      var reminderDate = request.object.get('date');
                      
                      var userQuery = new Parse.Query(Parse.Installation);
                      userQuery.equalTo('user', forUserName);
                      
                      Parse.Push.send({
                                      where: userQuery, // Set our Installation query
                                      push_time: reminderDate,
                                      data: {
                                      alert: "New reminder: " + titleText + " " + "from: " + fromUserName,
                                      badge: "Increment"
                                      //reminder: titleText
                                      //sound: "cheering.caf",
    
                                      } //insert ,
                                      //push_time: new Date(reminderDate)
                                      }, {
                                      success: function() {
                                      // Push was successful
                                      },
                                      error: function(error) {
                                      throw "Got an error " + error.code + " : " + error.message;
                                      }
                                      });
                      });

Parse.Cloud.define("getUserObject", function(request, response) {
                   var query = new Parse.Query("UserInfo");
                   query.equalTo("user", request.params.user);
                   query.find({
                              success: function(results) {
                              var sum = 0;
                              for (var i = 0; i < results.length; ++i) {
                              sum += results[i].get("stars");
                              }
                              response.success(sum / results.length);
                              },
                              error: function() {
                              response.error("movie lookup failed");
                              }
                              });
                   });
