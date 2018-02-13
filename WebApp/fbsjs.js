$( "#navBar a" ).click(function(){
  $(this).tab('show');
});

var latitude, longitude;
navigator.geolocation.getCurrentPosition(function success(pos) {
  latitude = pos.coords.latitude
  longitude = pos.coords.longitude
});

$('[data-toggle="tooltip"]').tooltip({
  trigger: "manual"
});

// $("#keyword").tooltip('show');

var app = angular.module('fbs', ['ngAnimate']);
app.controller('SearchController', ['$scope', '$http', '$timeout', function($scope, $http, $timeout) {
	$scope.type = "user";
  $scope.isDetailShown = false;
  $scope.isLoaded = true;
  $scope.noDataFound = false;
  $scope.noAlbumsDataFound = false;
  $scope.noPostsDataFound = false;
  $scope.isFavoriteShown = false;

  $scope.favoriteSize = 0;
  $scope.storage = {};
  for (var key in localStorage) {
    if (localStorage.getItem(key)) {
      $scope.favoriteSize++;
      $scope.storage[key] = JSON.parse(localStorage.getItem(key));
    }
  }

	$scope.submit = function() {
    var keyword = $("#keyword").val();
    $scope.isDetailShown = false;

    if (!keyword) {
      $('[data-toggle="tooltip"]').tooltip('show');
    } else if (!$scope.isFavoriteShown) {
      $scope.isLoaded = false;
      $scope.noDataFound = false;
      $scope.data = "";
      $scope.paging = "";
      
      var requestUrl = 'search.php?keyword=' + encodeURI(keyword) + '&type=' + $scope.type
      if ($scope.type == "place" && latitude && longitude) {
        requestUrl += "&latitude=" + latitude + "&longitude=" + longitude;
      }
  		var request = {
  		  method: 'GET',
    	  url: requestUrl
  		};

		$http(request).then(function successCallback(response) {
			$scope.data = response.data.data;
			$scope.paging = response.data.paging;
	        $scope.isLoaded = true;
	        if ($scope.data && $scope.data.length > 0) {
	          $scope.noDataFound = false;
	        } else {
	          $scope.noDataFound = true;
	        }
    	}, function errorCallback(response) {
    		console.log(response);
    	});
		}
	};

	$scope.changeTab = function(type) {
    $scope.isDetailShown = false;
    $('[data-toggle="tooltip"]').tooltip('hide');
    if (type == "favorite") {
      $scope.type = "user";
      $scope.isFavoriteShown = true;
    } else {
      $scope.type = type;
      $scope.isFavoriteShown = false;
      var keyword = $("#keyword").val();
      if (keyword) {
        $scope.submit();
      }
    }
	};

  $scope.inputFocus = function() {
    $('[data-toggle="tooltip"]').tooltip('hide');
  }

	$scope.clear = function() {
  	if ($scope.keyword) {
    		$scope.keyword = "";
  	}
  	$scope.data = "";
  	$scope.paging = "";
    $scope.detail = "";
    $scope.albums = "";
    $scope.posts = "";

    $scope.type = "user";
    $("#user").tab('show');

    $scope.isDetailShown = false;
    $scope.isLoaded = true;
    $scope.noDataFound = false;
    $scope.noAlbumsDataFound = false;
    $scope.noPostsDataFound = false;
    $scope.isFavoriteShown = false;

    $('[data-toggle="tooltip"]').tooltip('hide');
	};

  $scope.addFavorite = function(index) {
    var entry = new Object();
    entry.name = $scope.data[index].name;
    entry.type = $scope.type;
    entry.url = encodeURI($scope.data[index].picture.data.url);
    $scope.favoriteSize++;
    $scope.storage[$scope.data[index].id] = entry;
    localStorage.setItem($scope.data[index].id, JSON.stringify(entry));
  };

  $scope.addFavoriteFromDetail = function() {
    var entry = new Object();
    entry.name = $scope.detail.name;
    entry.type = $scope.type;
    entry.url = encodeURI($scope.detail.picture.data.url);
    $scope.favoriteSize++;
    $scope.storage[$scope.detail.id] = entry;
    localStorage.setItem($scope.detail.id, JSON.stringify(entry));
  };

  $scope.removeFavorite = function(id) {
    $scope.favoriteSize--;
    delete $scope.storage[id];
    localStorage.removeItem(id);
  }

  $scope.showDetail = function(userId) {
    $scope.isDetailShown = true;
    $scope.isLoaded = false;
    $scope.noAlbumsDataFound = false;
    $scope.noPostsDataFound = false;
    $scope.detail = "";
    $scope.albums = "";
    $scope.posts = "";

    var request = {
      method: 'GET',
      url: 'search.php?id=' + userId + "&type=" + $scope.type
    };

    $http(request).then(function successCallback(response) {
      $scope.detail = response.data;
      $timeout(function(){$scope.callAtTimeout(response);}, 500);
    }, function errorCallback(response) {
      console.log(response);
    });
  };

  $scope.callAtTimeout = function(response) {
    $scope.albums = response.data.albums;
    $scope.posts = response.data.posts;
    $scope.isLoaded = true;
    if ($scope.albums) {
      $scope.noAlbumsDataFound = false;
    } else {
      $scope.noAlbumsDataFound = true;
    }
    if ($scope.posts) {
      $scope.noPostsDataFound = false;
    } else {
      $scope.noPostsDataFound = true;
    }
  };

  $scope.backToResult = function() {
    $scope.isDetailShown = false;
  }

	$scope.changePage = function(url) {
    $scope.isLoaded = false;
    $scope.noDataFound = false;
    $scope.data = "";
    $scope.paging = "";

		var request = {
			method: 'GET',
  	  url: url
		};

		$http(request).then(function successCallback(response) {
  		$scope.data = response.data.data;
  		$scope.paging = response.data.paging;
      $scope.isLoaded = true;
      if ($scope.data && $scope.data.length > 0) {
        $scope.noDataFound = false;
      } else {
        $scope.noDataFound = true;
      }
  	}, function errorCallback(response) {
  		console.log(response);
  	});
	};

  $scope.post = function() {
    FB.ui({
      app_id: '169684620204533',
      method: 'feed',
      link: window.location.href,
      picture: $scope.detail.picture.data.url,
      name: $scope.detail.name,
      caption: 'FB SEARCH FROM USC CSCI571',
    }, function(response){
      if (response && !response.error_message)
        alert("Posted Successfully");
      else
        alert("Not Posted");
    });
  };
}]);