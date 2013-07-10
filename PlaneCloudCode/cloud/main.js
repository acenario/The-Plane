
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.afterSave("Reminders", function(request) {
                      // Our "Comment" class has a "text" key with the body of the comment itself
                      
                      var titleText = request.object.get('title');
                      var fromUserName = request.object.get('fromUser');
                      var forUserName = request.object.get('user');
                      
                      //var pushQuery = new Parse.Query(Parse.Installation);
                      //pushQuery.equalTo('deviceType', 'ios');
                      var userQuery = new Parse.Query(Parse.Installation);
                      userQuery.equalTo('user', forUserName);
                      
                      
                      Parse.Push.send({
                                      where: userQuery, // Set our Installation query
                                      data: {
                                      alert: "New reminder: " + titleText,
                                      badge: "Increment",
                                      sound: "cheering.caf",
                                      title: "Reminder from: " + fromUserName
    
                                      }
                                      }, {
                                      success: function() {
                                      // Push was successful
                                      },
                                      error: function(error) {
                                      throw "Got an error " + error.code + " : " + error.message;
                                      }
                                      });
                      });
