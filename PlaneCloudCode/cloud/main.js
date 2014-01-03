
//Use Parse.Cloud.define to define as many cloud functions as you want.
//For example:

Parse.Cloud.define("hello", function(request, response) {
	response.success("Hello world!");
});

Parse.Cloud.afterSave("Reminders", function(request) {


	var titleText = request.object.get('title');
	var fromUserName = request.object.get('fromUser');
	var forUserName = request.object.get('user');
	var reminderDate = request.object.get('date');
	var isParent = request.object.get('isParent');
	var isChild = request.object.get('isChild');
	var parent = request.object.get('parent');
	

	if (isParent == false || isParent == null) {
		var userQuery = new Parse.Query(Parse.Installation);


		userQuery.equalTo('user', forUserName);

		Parse.Push.send({
			where: userQuery, // Set our Installation query
			push_time: reminderDate,
			data: {
				alert: "Remember: " + titleText + " " + "from: " + fromUserName,
				badge: "Increment",
				//r: "n"
				//reminder: titleText
				sound: "alertSound.caf"

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

	}

	if (isChild == true) {
		if (parent != null) {
			parent.addUnique('children',request.object);			
			parent.save(null, {
				success: function(parentReminder) {
					// Execute any logic that should take place after the object is saved.
					alert('Child added with objectId: ' + parent.id);
				},
				error: function(parentReminder, error) {
					// Execute any logic that should take place if the save fails.
					// error is a Parse.Error with an error code and description.
					alert('Failed to add child, with error code: ' + error);
				}
			});

		}	
	}
	

});


Parse.Cloud.job("schedulingFuture", function(status) {
	// Set up to modify user data
	Parse.Cloud.useMasterKey();
	// Query for all users
	var reminder = Parse.Object.extend("Reminders");
	var query = new Parse.Query(reminder);
	query.equalTo("archived", true);
	query.each(function(rem) {
		//Get Date
		//var tdo = rem.object.get('date');
		//status.message("" + tdo);
		//Check date
		//TO-DO
		rem.set("archived", false);
		return rem.save();
	}).then(function() {
		// Set the job's success status
		//status.success("Successfully ran future scheduling job.");
	}, function() {
		// Set the job's error status
		//status.error("Uh oh, something went wrong.");
	});
});