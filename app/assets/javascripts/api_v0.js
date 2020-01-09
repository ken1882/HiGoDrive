/************************************ USER ************************************/

// return user info (object)
function getUserInfo(userId) {
  let userInfo = undefined;
  $.ajax({
    method: "GET",
    url: "/api/v0/users/" + userId,
    data: null,
    dataType: "json",
    success: function (result) {
      userInfo = result;
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: false
  });
  return userInfo;
}

// return current_user.id
function getCurrentUser() {
  let currentUserId = undefined;
  $.ajax({
    method: "POST",
    url: "/api/v0/currentuser",
    data: {
      authenticity_token: Util.AuthToken,
    },
    dataType: "json",
    success: function (result) {
      currentUserId = result.uid;
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: false
  });
  return currentUserId;
}

function checkUsernameExist(username) {
  let isUsernameExist = undefined;
  $.ajax({
    method: "POST",
    url: "/api/v0/checkusername",
    data: {
      authenticity_token: Util.AuthToken,
      username: username
    },
    dataType: "json",
    success: function (result) {
      isUsernameExist = result.message;
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: false
  });
  return isUsernameExist;
}

function checkPhoneExist(phone) {
  let isPhoneExist = undefined;
  $.ajax({
    method: "POST",
    url: "/api/v0/checkphone",
    data: {
      authenticity_token: Util.AuthToken,
      phone: phone
    },
    dataType: "json",
    success: function (result) {
      isPhoneExist = result.message;
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: false
  });
  return isPhoneExist;
}

function checkEmailExist(email) {
  let isEmailExist = undefined;
  $.ajax({
    method: "POST",
    url: "/api/v0/checkemail",
    data: {
      authenticity_token: Util.AuthToken,
      email: email
    },
    dataType: "json",
    success: function (result) {
      isEmailExist = result.message;
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: false
  });
  return isEmailExist;
}

// return user id if target user exist else null
function searchUser(username) {
  let targetUserId = undefined;
  $.ajax({
    method: "GET",
    url: "/api/v0/users/search/" + username,
    data: null,
    dataType: "json",
    success: function (result) {
      targetUserId = result.uid;
    },
    error: function(xhr) {
      targetUserId = null;
    },
    async: false
  });
  return targetUserId;
}

function uploadLicense(license) {
  $.ajax({
    method: "POST",
    url: "/api/v0/upload_license",
    data: {
      authenticity_token: Util.AuthToken,
      driver_license: license.driverLicense,
      vehicle_license: license.vehicleLicense,
      exterior: license.exterior,
      plate: license.plate,
      model: license.model
    },
    dataType: "json",
    success: null,
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: true
  });
}

function acceptLicense(uid) {
  $.ajax({
    method: "POST",
    url: "/api/v0/accept_license",
    data: {
      authenticity_token: Util.AuthToken,
      id: uid
    },
    dataType: "json",
    success: null,
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: true
  });
}

function rejectLicense(uid) {
  $.ajax({
    method: "POST",
    url: "/api/v0/reject_license",
    data: {
      authenticity_token: Util.AuthToken,
      id: uid
    },
    dataType: "json",
    success: null,
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: true
  });
}

/************************************ TASK ************************************/

// return [current task id, next task id]
function getNextTask(taskId) {
  let nextTask = undefined;
  $.ajax({
    method: "GET",
    url: "/api/v0/next_task",
    data: { id: taskId },
    dataType: "json",
    success: function (result) {
      nextTask = result;
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: false
  });
  return nextTask;
}

// return task info
function getTask(taskId) {
  let taskInfo = {};
  $.ajax({
    method: "GET",
    url: "/api/v0/tasks/" + taskId,
    data: null,
    dataType: "json",
    success: function (result) {
      taskInfo["dest"] = JSON.parse(result.dest);
      taskInfo["driver_id"] = result.driver_id;
      taskInfo["driver_name"] = result.driver_name;
      taskInfo["author_id"] = result.author_id;
      taskInfo["author_name"] = result.author_name;
      taskInfo["status"] = result.status;
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
      taskInfo = undefined;
    },
    async: false
  });
  return taskInfo;
}

function createTask(dest, departTime, equipments, preorder, driverId) {
  let taskId = 0;
  let taskInfo = {
    authenticity_token: Util.AuthToken,
    dest: JSON.stringify(dest),
    depart_time: departTime,
    equipments: equipments,
    preorder: preorder
  };
  if (driverId) {
    taskInfo.driver_id = driverId;
  }
  $.ajax({
    method: "POST",
    url: "/api/v0/tasks",
    data: taskInfo,
    dataType: "json",
    success: function (result) {
      taskId = result.id;
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: false
  });
  return taskId;
}

function cancelTask(taskId) {
  $.ajax({
    method: "POST",
    url: "/api/v0/task/cancel",
    data: {
      authenticity_token: Util.AuthToken,
      id: taskId
    },
    dataType: "json",
    success: function (result) {
      console.log(result);
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: true
  });
}

function getEngagingTask() {
  let tasks = undefined;
  $.ajax({
    method: "GET",
    url: "/api/v0/tasks_engaging",
    data: null,
    dataType: "json",
    success: function (result) {
      tasks = result;
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: false
  });
  return tasks;
}

function getTaskHistory() {
  let tasks = undefined;
  $.ajax({
    method: "GET",
    url: "/api/v0/tasks_history",
    data: null,
    dataType: "json",
    success: function (result) {
      tasks = result;
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: false
  });
  tasks.sort(function(a, b) { return b.id - a.id; });
  return tasks;
}

function finishTask(taskId) {
  $.ajax({
    method: "POST",
    url: "/api/v0/task/finish",
    data: {
      authenticity_token: Util.AuthToken,
      id: taskId
    },
    dataType: "json",
    success: function (result) {
      console.log(result);
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: true
  });
}

function acceptTask(taskId,
                    successCallback = undefined,
                    errorCallback = undefined) {
  $.ajax({
    method: "POST",
    url: "/api/v0/task/accept",
    data: {
      authenticity_token: Util.AuthToken,
      id: taskId
    },
    dataType: "json",
    success: function (result) {
      if (typeof successCallback == "function") {
        successCallback();
      }
      console.log(result);
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
      if (typeof errorCallback == "function") {
        errorCallback();
      }
    },
    async: true
  });
}

function rejectTask(taskId, reason) {
  $.ajax({
    method: "POST",
    url: "/api/v0/task/reject",
    data: {
      authenticity_token: Util.AuthToken,
      id: taskId,
      reason: reason
    },
    dataType: "json",
    success: function (result) {
      console.log(result);
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: true
  });
}

function engageTask(taskId) {
  $.ajax({
    method: "POST",
    url: "/api/v0/task/engage",
    data: {
      authenticity_token: Util.AuthToken,
      id: taskId
    },
    dataType: "json",
    success: function (result) {
      console.log(result);
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: true
  });
}

function getTaskReport(taskId) {
  let report = undefined;
  $.ajax({
    method: "GET",
    url: "/api/v0/tasks/" + taskId + "/reports",
    data: null,
    dataType: "json",
    success: function (result) {
      report = result;
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: false
  });
  return report;
}

function reportTask(taskId, comment) {
  $.ajax({
    method: "POST",
    url: "/api/v0/tasks/" + taskId + "/reports",
    data: {
      authenticity_token: Util.AuthToken,
      id: taskId,
      comment: comment
    },
    dataType: "json",
    success: function (result) {
      console.log(result);
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: true
  });
}

function createTaskReview(taskId, score, comment) {
  $.ajax({
    method: "POST",
    url: "/api/v0/tasks/" + taskId + "/reviews",
    data: {
      authenticity_token: Util.AuthToken,
      id: taskId,
      score: score,
      comment: comment
    },
    dataType: "json",
    success: function (result) {
      console.log(result);
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: true
  });
}

function getTaskReview(taskId) {
  let review = undefined;
  $.ajax({
    method: "GET",
    url: "/api/v0/tasks/" + taskId + "/reviews",
    data: { id: taskId },
    dataType: "json",
    success: function (result) {
      review = result;
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: false
  });
  return review;
}

/***************************** PUSH NOTIFICATION *****************************/
function getReadNotification() {

}

function getUnreadNotification() {

}

/******************************* ADMINISTRATION *******************************/
function getReportList() {
  let reports = undefined;
  $.ajax({
    method: "GET",
    url: "/api/v0/reports",
    data: null,
    dataType: "json",
    success: function (result) {
      reports = result;
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: false
  });
  return reports;
}

function getUnprocessedLicenses() {
  let licenses = undefined;
  $.ajax({
    method: "GET",
    url: "/api/v0/unprocessed_licenses",
    data: null,
    dataType: "json",
    success: function (result) {
      licenses = result;
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: false
  });
  return licenses;
}

function finishReport(taskId) {
  $.ajax({
    method: "POST",
    url: "/api/v0/finish_report/" + taskId,
    data: {
      authenticity_token: Util.AuthToken,
      id: taskId
    },
    dataType: "json",
    success: function(r) {
      console.log(r);
    },
    error: function(xhr) {
      console.log("An error occured:", xhr.status, xhr.statusText);
    },
    async: true
  });
}
