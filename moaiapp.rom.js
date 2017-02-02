
var Module;
if (typeof Module === 'undefined') Module = eval('(function() { try { return Module || {} } catch(e) { return {} } })()');
(function() {

    function fetchRemotePackage(packageName, callback, errback) {
      var xhr = new XMLHttpRequest();
      xhr.open('GET', packageName, true);
      xhr.responseType = 'arraybuffer';
      xhr.onprogress = function(event) {
        var url = packageName;
        if (event.loaded && event.total) {
          if (!xhr.addedTotal) {
            xhr.addedTotal = true;
            if (!Module.dataFileDownloads) Module.dataFileDownloads = {};
            Module.dataFileDownloads[url] = {
              loaded: event.loaded,
              total: event.total
            };
          } else {
            Module.dataFileDownloads[url].loaded = event.loaded;
          }
          var total = 0;
          var loaded = 0;
          var num = 0;
          for (var download in Module.dataFileDownloads) {
          var data = Module.dataFileDownloads[download];
            total += data.total;
            loaded += data.loaded;
            num++;
          }
          total = Math.ceil(total * Module.expectedDataFileDownloads/num);
          if (Module['setStatus']) Module['setStatus']('Downloading data... (' + loaded + '/' + total + ')');
        } else if (!Module.dataFileDownloads) {
          if (Module['setStatus']) Module['setStatus']('Downloading data...');
        }
      };
      xhr.onload = function(event) {
        var packageData = xhr.response;
        callback(packageData);
      };
      xhr.send(null);
    };

    function handleError(error) {
      console.error('package error:', error);
    };
  
      var fetched = null, fetchedCallback = null;
      fetchRemotePackage('moaiapp.rom', function(data) {
        if (fetchedCallback) {
          fetchedCallback(data);
          fetchedCallback = null;
        } else {
          fetched = data;
        }
      }, handleError);
    
  function runWithFS() {

function assert(check, msg) {
  if (!check) throw msg + new Error().stack;
}
Module['FS_createPath']('/', 'effect', true, true);
Module['FS_createPath']('/', 'file', true, true);
Module['FS_createPath']('/', 'font', true, true);
Module['FS_createPath']('/', 'game', true, true);
Module['FS_createPath']('/', 'input', true, true);
Module['FS_createPath']('/', 'interface', true, true);
Module['FS_createPath']('/interface', 'background', true, true);
Module['FS_createPath']('/interface', 'game', true, true);
Module['FS_createPath']('/interface', 'intro', true, true);
Module['FS_createPath']('/', 'loop', true, true);
Module['FS_createPath']('/', 'math', true, true);
Module['FS_createPath']('/', 'multiplayer', true, true);
Module['FS_createPath']('/multiplayer', 'socket', true, true);
Module['FS_createPath']('/', 'pathfinding', true, true);
Module['FS_createPath']('/', 'sort', true, true);
Module['FS_createPath']('/', 'texture', true, true);
Module['FS_createPath']('/texture', 'background', true, true);
Module['FS_createPath']('/texture', 'board', true, true);
Module['FS_createPath']('/texture', 'effect', true, true);
Module['FS_createPath']('/texture', 'interface', true, true);
Module['FS_createPath']('/texture', 'logo', true, true);
Module['FS_createPath']('/', 'window', true, true);

    function DataRequest(start, end, crunched, audio) {
      this.start = start;
      this.end = end;
      this.crunched = crunched;
      this.audio = audio;
    }
    DataRequest.prototype = {
      requests: {},
      open: function(mode, name) {
        this.name = name;
        this.requests[name] = this;
        Module['addRunDependency']('fp ' + this.name);
      },
      send: function() {},
      onload: function() {
        var byteArray = this.byteArray.subarray(this.start, this.end);
        if (this.crunched) {
          var ddsHeader = byteArray.subarray(0, 128);
          var that = this;
          requestDecrunch(this.name, byteArray.subarray(128), function(ddsData) {
            byteArray = new Uint8Array(ddsHeader.length + ddsData.length);
            byteArray.set(ddsHeader, 0);
            byteArray.set(ddsData, 128);
            that.finish(byteArray);
          });
        } else {
          this.finish(byteArray);
        }
      },
      finish: function(byteArray) {
        var that = this;
        Module['FS_createPreloadedFile'](this.name, null, byteArray, true, true, function() {
          Module['removeRunDependency']('fp ' + that.name);
        }, function() {
          if (that.audio) {
            Module['removeRunDependency']('fp ' + that.name); // workaround for chromium bug 124926 (still no audio with this, but at least we don't hang)
          } else {
            Module.printErr('Preloading file ' + that.name + ' failed');
          }
        }, false, true); // canOwn this data in the filesystem, it is a slide into the heap that will never change
        this.requests[this.name] = null;
      },
    };
      new DataRequest(0, 1211, 0, 0).open('GET', '/main.lua');
    new DataRequest(1211, 2335, 0, 0).open('GET', '/run.bat');
    new DataRequest(2335, 3007, 0, 0).open('GET', '/effect/blackscreen.lua');
    new DataRequest(3007, 3794, 0, 0).open('GET', '/effect/blend.lua');
    new DataRequest(3794, 4144, 0, 0).open('GET', '/effect/color.lua');
    new DataRequest(4144, 4671, 0, 0).open('GET', '/file/comoJogar.txt');
    new DataRequest(4671, 4719, 0, 0).open('GET', '/file/gameOver.txt');
    new DataRequest(4719, 4736, 0, 0).open('GET', '/file/iniciarNovoJogo.txt');
    new DataRequest(4736, 4809, 0, 0).open('GET', '/file/menuNovoJogo.txt');
    new DataRequest(4809, 4817, 0, 0).open('GET', '/file/resolutionDefault.lua');
    new DataRequest(4817, 900017, 0, 0).open('GET', '/font/arial.ttf');
    new DataRequest(900017, 921373, 0, 0).open('GET', '/font/zekton free.ttf');
    new DataRequest(921373, 938614, 0, 0).open('GET', '/game/ai.lua');
    new DataRequest(938614, 946640, 0, 0).open('GET', '/game/board.lua');
    new DataRequest(946640, 948616, 0, 0).open('GET', '/game/hexagon.lua');
    new DataRequest(948616, 949874, 0, 0).open('GET', '/game/lane.lua');
    new DataRequest(949874, 950744, 0, 0).open('GET', '/game/newGame.lua');
    new DataRequest(950744, 951269, 0, 0).open('GET', '/game/player.lua');
    new DataRequest(951269, 956330, 0, 0).open('GET', '/game/turn.lua');
    new DataRequest(956330, 959629, 0, 0).open('GET', '/input/input.lua');
    new DataRequest(959629, 959672, 0, 0).open('GET', '/input/keyboard.lua');
    new DataRequest(959672, 959958, 0, 0).open('GET', '/input/mouse.lua');
    new DataRequest(959958, 960443, 0, 0).open('GET', '/input/touch.lua');
    new DataRequest(960443, 966284, 0, 0).open('GET', '/interface/button.lua');
    new DataRequest(966284, 967448, 0, 0).open('GET', '/interface/interface.lua');
    new DataRequest(967448, 967647, 0, 0).open('GET', '/interface/priority.lua');
    new DataRequest(967647, 968029, 0, 0).open('GET', '/interface/background/background.lua');
    new DataRequest(968029, 982123, 0, 0).open('GET', '/interface/game/gameInterface.lua');
    new DataRequest(982123, 987489, 0, 0).open('GET', '/interface/game/menu.lua');
    new DataRequest(987489, 990124, 0, 0).open('GET', '/interface/intro/introInterface.lua');
    new DataRequest(990124, 992324, 0, 0).open('GET', '/loop/gameLoop.lua');
    new DataRequest(992324, 992907, 0, 0).open('GET', '/loop/introLoop.lua');
    new DataRequest(992907, 993012, 0, 0).open('GET', '/loop/thread.lua');
    new DataRequest(993012, 993728, 0, 0).open('GET', '/math/circle.lua');
    new DataRequest(993728, 995291, 0, 0).open('GET', '/math/rectangle.lua');
    new DataRequest(995291, 995530, 0, 0).open('GET', '/math/utils.lua');
    new DataRequest(995530, 995820, 0, 0).open('GET', '/math/vector.lua');
    new DataRequest(995820, 997343, 0, 0).open('GET', '/multiplayer/multiplayer.lua');
    new DataRequest(997343, 999164, 0, 0).open('GET', '/multiplayer/socket/client.lua');
    new DataRequest(999164, 1001279, 0, 0).open('GET', '/multiplayer/socket/server.lua');
    new DataRequest(1001279, 1008852, 0, 0).open('GET', '/pathfinding/boardPath.lua');
    new DataRequest(1008852, 1025941, 0, 0).open('GET', '/pathfinding/graph.lua');
    new DataRequest(1025941, 1031029, 0, 0).open('GET', '/pathfinding/hexGrid.lua');
    new DataRequest(1031029, 1033469, 0, 0).open('GET', '/sort/heap.lua');
    new DataRequest(1033469, 1034155, 0, 0).open('GET', '/sort/insertionSort.lua');
    new DataRequest(1034155, 1035504, 0, 0).open('GET', '/sort/quickSort.lua');
    new DataRequest(1035504, 1280050, 0, 0).open('GET', '/texture/background/gameBackground.png');
    new DataRequest(1280050, 1303708, 0, 0).open('GET', '/texture/background/smallWindow.png');
    new DataRequest(1303708, 1327070, 0, 0).open('GET', '/texture/background/window.png');
    new DataRequest(1327070, 1338735, 0, 0).open('GET', '/texture/board/hexagon.png');
    new DataRequest(1338735, 1349586, 0, 0).open('GET', '/texture/board/hexagon2.png');
    new DataRequest(1349586, 1352594, 0, 0).open('GET', '/texture/board/lane.png');
    new DataRequest(1352594, 1352723, 0, 0).open('GET', '/texture/effect/blackscreen.png');
    new DataRequest(1352723, 1355934, 0, 0).open('GET', '/texture/effect/buttonHighlight.png');
    new DataRequest(1355934, 1356061, 0, 0).open('GET', '/texture/effect/whitescreen.png');
    new DataRequest(1356061, 1415422, 0, 0).open('GET', '/texture/interface/11x11.png');
    new DataRequest(1415422, 1465642, 0, 0).open('GET', '/texture/interface/7x7.png');
    new DataRequest(1465642, 1530061, 0, 0).open('GET', '/texture/interface/9x9.png');
    new DataRequest(1530061, 1545018, 0, 0).open('GET', '/texture/interface/AI vs human.png');
    new DataRequest(1545018, 1549300, 0, 0).open('GET', '/texture/interface/close.png');
    new DataRequest(1549300, 1567938, 0, 0).open('GET', '/texture/interface/horizontal.png');
    new DataRequest(1567938, 1573612, 0, 0).open('GET', '/texture/interface/howToPlay.png');
    new DataRequest(1573612, 1588016, 0, 0).open('GET', '/texture/interface/human vs AI.png');
    new DataRequest(1588016, 1599252, 0, 0).open('GET', '/texture/interface/human vs human.png');
    new DataRequest(1599252, 1606916, 0, 0).open('GET', '/texture/interface/options.png');
    new DataRequest(1606916, 1611865, 0, 0).open('GET', '/texture/interface/redo.png');
    new DataRequest(1611865, 1616457, 0, 0).open('GET', '/texture/interface/startNewGame.png');
    new DataRequest(1616457, 1621388, 0, 0).open('GET', '/texture/interface/undo.png');
    new DataRequest(1621388, 1647205, 0, 0).open('GET', '/texture/interface/vertical.png');
    new DataRequest(1647205, 1653220, 0, 0).open('GET', '/texture/interface/zoomIn.png');
    new DataRequest(1653220, 1659133, 0, 0).open('GET', '/texture/interface/zoomOut.png');
    new DataRequest(1659133, 1719013, 0, 0).open('GET', '/texture/logo/lua.jpg');
    new DataRequest(1719013, 1779233, 0, 0).open('GET', '/texture/logo/moai.jpg');
    new DataRequest(1779233, 1783653, 0, 0).open('GET', '/window/camera.lua');
    new DataRequest(1783653, 1790874, 0, 0).open('GET', '/window/deckManager.lua');
    new DataRequest(1790874, 1793258, 0, 0).open('GET', '/window/window.lua');

    if (!Module.expectedDataFileDownloads) {
      Module.expectedDataFileDownloads = 0;
      Module.finishedDataFileDownloads = 0;
    }
    Module.expectedDataFileDownloads++;

    var PACKAGE_PATH = window['encodeURIComponent'](window.location.pathname.toString().substring(0, window.location.pathname.toString().lastIndexOf('/')) + '/');
    var PACKAGE_NAME = 'C:/Users/Orlandi/Documents/Git/Hex/distribute/html/html-debug/www/moaiapp.rom';
    var REMOTE_PACKAGE_NAME = 'moaiapp.rom';
    var PACKAGE_UUID = 'dd4bbea8-f925-48bc-b022-e24152a9bee2';
  
    function processPackageData(arrayBuffer) {
      Module.finishedDataFileDownloads++;
      assert(arrayBuffer, 'Loading data file failed.');
      var byteArray = new Uint8Array(arrayBuffer);
      var curr;
      
      // copy the entire loaded file into a spot in the heap. Files will refer to slices in that. They cannot be freed though.
      var ptr = Module['_malloc'](byteArray.length);
      Module['HEAPU8'].set(byteArray, ptr);
      DataRequest.prototype.byteArray = Module['HEAPU8'].subarray(ptr, ptr+byteArray.length);
          DataRequest.prototype.requests["/main.lua"].onload();
          DataRequest.prototype.requests["/run.bat"].onload();
          DataRequest.prototype.requests["/effect/blackscreen.lua"].onload();
          DataRequest.prototype.requests["/effect/blend.lua"].onload();
          DataRequest.prototype.requests["/effect/color.lua"].onload();
          DataRequest.prototype.requests["/file/comoJogar.txt"].onload();
          DataRequest.prototype.requests["/file/gameOver.txt"].onload();
          DataRequest.prototype.requests["/file/iniciarNovoJogo.txt"].onload();
          DataRequest.prototype.requests["/file/menuNovoJogo.txt"].onload();
          DataRequest.prototype.requests["/file/resolutionDefault.lua"].onload();
          DataRequest.prototype.requests["/font/arial.ttf"].onload();
          DataRequest.prototype.requests["/font/zekton free.ttf"].onload();
          DataRequest.prototype.requests["/game/ai.lua"].onload();
          DataRequest.prototype.requests["/game/board.lua"].onload();
          DataRequest.prototype.requests["/game/hexagon.lua"].onload();
          DataRequest.prototype.requests["/game/lane.lua"].onload();
          DataRequest.prototype.requests["/game/newGame.lua"].onload();
          DataRequest.prototype.requests["/game/player.lua"].onload();
          DataRequest.prototype.requests["/game/turn.lua"].onload();
          DataRequest.prototype.requests["/input/input.lua"].onload();
          DataRequest.prototype.requests["/input/keyboard.lua"].onload();
          DataRequest.prototype.requests["/input/mouse.lua"].onload();
          DataRequest.prototype.requests["/input/touch.lua"].onload();
          DataRequest.prototype.requests["/interface/button.lua"].onload();
          DataRequest.prototype.requests["/interface/interface.lua"].onload();
          DataRequest.prototype.requests["/interface/priority.lua"].onload();
          DataRequest.prototype.requests["/interface/background/background.lua"].onload();
          DataRequest.prototype.requests["/interface/game/gameInterface.lua"].onload();
          DataRequest.prototype.requests["/interface/game/menu.lua"].onload();
          DataRequest.prototype.requests["/interface/intro/introInterface.lua"].onload();
          DataRequest.prototype.requests["/loop/gameLoop.lua"].onload();
          DataRequest.prototype.requests["/loop/introLoop.lua"].onload();
          DataRequest.prototype.requests["/loop/thread.lua"].onload();
          DataRequest.prototype.requests["/math/circle.lua"].onload();
          DataRequest.prototype.requests["/math/rectangle.lua"].onload();
          DataRequest.prototype.requests["/math/utils.lua"].onload();
          DataRequest.prototype.requests["/math/vector.lua"].onload();
          DataRequest.prototype.requests["/multiplayer/multiplayer.lua"].onload();
          DataRequest.prototype.requests["/multiplayer/socket/client.lua"].onload();
          DataRequest.prototype.requests["/multiplayer/socket/server.lua"].onload();
          DataRequest.prototype.requests["/pathfinding/boardPath.lua"].onload();
          DataRequest.prototype.requests["/pathfinding/graph.lua"].onload();
          DataRequest.prototype.requests["/pathfinding/hexGrid.lua"].onload();
          DataRequest.prototype.requests["/sort/heap.lua"].onload();
          DataRequest.prototype.requests["/sort/insertionSort.lua"].onload();
          DataRequest.prototype.requests["/sort/quickSort.lua"].onload();
          DataRequest.prototype.requests["/texture/background/gameBackground.png"].onload();
          DataRequest.prototype.requests["/texture/background/smallWindow.png"].onload();
          DataRequest.prototype.requests["/texture/background/window.png"].onload();
          DataRequest.prototype.requests["/texture/board/hexagon.png"].onload();
          DataRequest.prototype.requests["/texture/board/hexagon2.png"].onload();
          DataRequest.prototype.requests["/texture/board/lane.png"].onload();
          DataRequest.prototype.requests["/texture/effect/blackscreen.png"].onload();
          DataRequest.prototype.requests["/texture/effect/buttonHighlight.png"].onload();
          DataRequest.prototype.requests["/texture/effect/whitescreen.png"].onload();
          DataRequest.prototype.requests["/texture/interface/11x11.png"].onload();
          DataRequest.prototype.requests["/texture/interface/7x7.png"].onload();
          DataRequest.prototype.requests["/texture/interface/9x9.png"].onload();
          DataRequest.prototype.requests["/texture/interface/AI vs human.png"].onload();
          DataRequest.prototype.requests["/texture/interface/close.png"].onload();
          DataRequest.prototype.requests["/texture/interface/horizontal.png"].onload();
          DataRequest.prototype.requests["/texture/interface/howToPlay.png"].onload();
          DataRequest.prototype.requests["/texture/interface/human vs AI.png"].onload();
          DataRequest.prototype.requests["/texture/interface/human vs human.png"].onload();
          DataRequest.prototype.requests["/texture/interface/options.png"].onload();
          DataRequest.prototype.requests["/texture/interface/redo.png"].onload();
          DataRequest.prototype.requests["/texture/interface/startNewGame.png"].onload();
          DataRequest.prototype.requests["/texture/interface/undo.png"].onload();
          DataRequest.prototype.requests["/texture/interface/vertical.png"].onload();
          DataRequest.prototype.requests["/texture/interface/zoomIn.png"].onload();
          DataRequest.prototype.requests["/texture/interface/zoomOut.png"].onload();
          DataRequest.prototype.requests["/texture/logo/lua.jpg"].onload();
          DataRequest.prototype.requests["/texture/logo/moai.jpg"].onload();
          DataRequest.prototype.requests["/window/camera.lua"].onload();
          DataRequest.prototype.requests["/window/deckManager.lua"].onload();
          DataRequest.prototype.requests["/window/window.lua"].onload();
          Module['removeRunDependency']('datafile_C:/Users/Orlandi/Documents/Git/Hex/distribute/html/html-debug/www/moaiapp.rom');

    };
    Module['addRunDependency']('datafile_C:/Users/Orlandi/Documents/Git/Hex/distribute/html/html-debug/www/moaiapp.rom');
  
    if (!Module.preloadResults) Module.preloadResults = {};
  
      Module.preloadResults[PACKAGE_NAME] = {fromCache: false};
      if (fetched) {
        processPackageData(fetched);
        fetched = null;
      } else {
        fetchedCallback = processPackageData;
      }
    
  }
  if (Module['calledRun']) {
    runWithFS();
  } else {
    if (!Module['preRun']) Module['preRun'] = [];
    Module["preRun"].push(runWithFS); // FS is not initialized yet, wait for it
  }

})();
