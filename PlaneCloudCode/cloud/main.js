
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
                                      alert: "Remember: " + titleText + " " + "from: " + fromUserName,
                                      badge: "Increment"
                                      //r: "n"
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