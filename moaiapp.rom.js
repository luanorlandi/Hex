
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
      new DataRequest(0, 1276, 0, 0).open('GET', '/main.lua');
    new DataRequest(1276, 2400, 0, 0).open('GET', '/run.bat');
    new DataRequest(2400, 3704, 0, 0).open('GET', '/run2.bat');
    new DataRequest(3704, 4376, 0, 0).open('GET', '/effect/blackscreen.lua');
    new DataRequest(4376, 5163, 0, 0).open('GET', '/effect/blend.lua');
    new DataRequest(5163, 5513, 0, 0).open('GET', '/effect/color.lua');
    new DataRequest(5513, 6101, 0, 0).open('GET', '/file/en.lua');
    new DataRequest(6101, 6750, 0, 0).open('GET', '/file/pt.lua');
    new DataRequest(6750, 7337, 0, 0).open('GET', '/file/saveLocation.lua');
    new DataRequest(7337, 8462, 0, 0).open('GET', '/file/strings.lua');
    new DataRequest(8462, 903662, 0, 0).open('GET', '/font/arial.ttf');
    new DataRequest(903662, 903718, 0, 0).open('GET', '/font/source.txt');
    new DataRequest(903718, 925074, 0, 0).open('GET', '/font/zekton free.ttf');
    new DataRequest(925074, 941887, 0, 0).open('GET', '/game/ai.lua');
    new DataRequest(941887, 949773, 0, 0).open('GET', '/game/board.lua');
    new DataRequest(949773, 951734, 0, 0).open('GET', '/game/hexagon.lua');
    new DataRequest(951734, 952934, 0, 0).open('GET', '/game/lane.lua');
    new DataRequest(952934, 953802, 0, 0).open('GET', '/game/newGame.lua');
    new DataRequest(953802, 954313, 0, 0).open('GET', '/game/player.lua');
    new DataRequest(954313, 959270, 0, 0).open('GET', '/game/turn.lua');
    new DataRequest(959270, 962518, 0, 0).open('GET', '/input/input.lua');
    new DataRequest(962518, 962561, 0, 0).open('GET', '/input/keyboard.lua');
    new DataRequest(962561, 962833, 0, 0).open('GET', '/input/mouse.lua');
    new DataRequest(962833, 963318, 0, 0).open('GET', '/input/touch.lua');
    new DataRequest(963318, 969210, 0, 0).open('GET', '/interface/button.lua');
    new DataRequest(969210, 971013, 0, 0).open('GET', '/interface/interface.lua');
    new DataRequest(971013, 971212, 0, 0).open('GET', '/interface/priority.lua');
    new DataRequest(971212, 971594, 0, 0).open('GET', '/interface/background/background.lua');
    new DataRequest(971594, 985559, 0, 0).open('GET', '/interface/game/gameInterface.lua');
    new DataRequest(985559, 990762, 0, 0).open('GET', '/interface/game/menu.lua');
    new DataRequest(990762, 993398, 0, 0).open('GET', '/interface/intro/introInterface.lua');
    new DataRequest(993398, 995523, 0, 0).open('GET', '/loop/gameLoop.lua');
    new DataRequest(995523, 996106, 0, 0).open('GET', '/loop/introLoop.lua');
    new DataRequest(996106, 996211, 0, 0).open('GET', '/loop/thread.lua');
    new DataRequest(996211, 996940, 0, 0).open('GET', '/math/circle.lua');
    new DataRequest(996940, 998401, 0, 0).open('GET', '/math/rectangle.lua');
    new DataRequest(998401, 998640, 0, 0).open('GET', '/math/utils.lua');
    new DataRequest(998640, 998930, 0, 0).open('GET', '/math/vector.lua');
    new DataRequest(998930, 1000419, 0, 0).open('GET', '/multiplayer/multiplayer.lua');
    new DataRequest(1000419, 1002215, 0, 0).open('GET', '/multiplayer/socket/client.lua');
    new DataRequest(1002215, 1004315, 0, 0).open('GET', '/multiplayer/socket/server.lua');
    new DataRequest(1004315, 1011636, 0, 0).open('GET', '/pathfinding/boardPath.lua');
    new DataRequest(1011636, 1028653, 0, 0).open('GET', '/pathfinding/graph.lua');
    new DataRequest(1028653, 1033668, 0, 0).open('GET', '/pathfinding/hexGrid.lua');
    new DataRequest(1033668, 1035996, 0, 0).open('GET', '/sort/heap.lua');
    new DataRequest(1035996, 1037373, 0, 0).open('GET', '/sort/quickSort.lua');
    new DataRequest(1037373, 1281919, 0, 0).open('GET', '/texture/background/gameBackground.png');
    new DataRequest(1281919, 1305577, 0, 0).open('GET', '/texture/background/smallWindow.png');
    new DataRequest(1305577, 1328939, 0, 0).open('GET', '/texture/background/window.png');
    new DataRequest(1328939, 1340604, 0, 0).open('GET', '/texture/board/hexagon.png');
    new DataRequest(1340604, 1343612, 0, 0).open('GET', '/texture/board/lane.png');
    new DataRequest(1343612, 1343741, 0, 0).open('GET', '/texture/effect/blackscreen.png');
    new DataRequest(1343741, 1346952, 0, 0).open('GET', '/texture/effect/buttonHighlight.png');
    new DataRequest(1346952, 1347079, 0, 0).open('GET', '/texture/effect/whitescreen.png');
    new DataRequest(1347079, 1406440, 0, 0).open('GET', '/texture/interface/11x11.png');
    new DataRequest(1406440, 1456660, 0, 0).open('GET', '/texture/interface/7x7.png');
    new DataRequest(1456660, 1521079, 0, 0).open('GET', '/texture/interface/9x9.png');
    new DataRequest(1521079, 1543827, 0, 0).open('GET', '/texture/interface/about.png');
    new DataRequest(1543827, 1573431, 0, 0).open('GET', '/texture/interface/AI vs human.png');
    new DataRequest(1573431, 1594800, 0, 0).open('GET', '/texture/interface/close.png');
    new DataRequest(1594800, 1613438, 0, 0).open('GET', '/texture/interface/horizontal.png');
    new DataRequest(1613438, 1642781, 0, 0).open('GET', '/texture/interface/human vs AI.png');
    new DataRequest(1642781, 1654017, 0, 0).open('GET', '/texture/interface/human vs human.png');
    new DataRequest(1654017, 1678762, 0, 0).open('GET', '/texture/interface/options.png');
    new DataRequest(1678762, 1700913, 0, 0).open('GET', '/texture/interface/redo.png');
    new DataRequest(1700913, 1724535, 0, 0).open('GET', '/texture/interface/startNewGame.png');
    new DataRequest(1724535, 1746705, 0, 0).open('GET', '/texture/interface/undo.png');
    new DataRequest(1746705, 1772522, 0, 0).open('GET', '/texture/interface/vertical.png');
    new DataRequest(1772522, 1795923, 0, 0).open('GET', '/texture/interface/zoomIn.png');
    new DataRequest(1795923, 1819117, 0, 0).open('GET', '/texture/interface/zoomOut.png');
    new DataRequest(1819117, 1860120, 0, 0).open('GET', '/texture/logo/hex.png');
    new DataRequest(1860120, 1909076, 0, 0).open('GET', '/texture/logo/lua.png');
    new DataRequest(1909076, 1957926, 0, 0).open('GET', '/texture/logo/moai.png');
    new DataRequest(1957926, 1962346, 0, 0).open('GET', '/window/camera.lua');
    new DataRequest(1962346, 1969774, 0, 0).open('GET', '/window/deckManager.lua');
    new DataRequest(1969774, 1974359, 0, 0).open('GET', '/window/window.lua');

    if (!Module.expectedDataFileDownloads) {
      Module.expectedDataFileDownloads = 0;
      Module.finishedDataFileDownloads = 0;
    }
    Module.expectedDataFileDownloads++;

    var PACKAGE_PATH = window['encodeURIComponent'](window.location.pathname.toString().substring(0, window.location.pathname.toString().lastIndexOf('/')) + '/');
    var PACKAGE_NAME = 'C:/Users/Orlandi/Documents/Git/Hex/distribute/html/html-release/www/moaiapp.rom';
    var REMOTE_PACKAGE_NAME = 'moaiapp.rom';
    var PACKAGE_UUID = '4bc35e3f-5239-42a5-92ea-f02b68ba63d9';
  
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
          DataRequest.prototype.requests["/run2.bat"].onload();
          DataRequest.prototype.requests["/effect/blackscreen.lua"].onload();
          DataRequest.prototype.requests["/effect/blend.lua"].onload();
          DataRequest.prototype.requests["/effect/color.lua"].onload();
          DataRequest.prototype.requests["/file/en.lua"].onload();
          DataRequest.prototype.requests["/file/pt.lua"].onload();
          DataRequest.prototype.requests["/file/saveLocation.lua"].onload();
          DataRequest.prototype.requests["/file/strings.lua"].onload();
          DataRequest.prototype.requests["/font/arial.ttf"].onload();
          DataRequest.prototype.requests["/font/source.txt"].onload();
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
          DataRequest.prototype.requests["/sort/quickSort.lua"].onload();
          DataRequest.prototype.requests["/texture/background/gameBackground.png"].onload();
          DataRequest.prototype.requests["/texture/background/smallWindow.png"].onload();
          DataRequest.prototype.requests["/texture/background/window.png"].onload();
          DataRequest.prototype.requests["/texture/board/hexagon.png"].onload();
          DataRequest.prototype.requests["/texture/board/lane.png"].onload();
          DataRequest.prototype.requests["/texture/effect/blackscreen.png"].onload();
          DataRequest.prototype.requests["/texture/effect/buttonHighlight.png"].onload();
          DataRequest.prototype.requests["/texture/effect/whitescreen.png"].onload();
          DataRequest.prototype.requests["/texture/interface/11x11.png"].onload();
          DataRequest.prototype.requests["/texture/interface/7x7.png"].onload();
          DataRequest.prototype.requests["/texture/interface/9x9.png"].onload();
          DataRequest.prototype.requests["/texture/interface/about.png"].onload();
          DataRequest.prototype.requests["/texture/interface/AI vs human.png"].onload();
          DataRequest.prototype.requests["/texture/interface/close.png"].onload();
          DataRequest.prototype.requests["/texture/interface/horizontal.png"].onload();
          DataRequest.prototype.requests["/texture/interface/human vs AI.png"].onload();
          DataRequest.prototype.requests["/texture/interface/human vs human.png"].onload();
          DataRequest.prototype.requests["/texture/interface/options.png"].onload();
          DataRequest.prototype.requests["/texture/interface/redo.png"].onload();
          DataRequest.prototype.requests["/texture/interface/startNewGame.png"].onload();
          DataRequest.prototype.requests["/texture/interface/undo.png"].onload();
          DataRequest.prototype.requests["/texture/interface/vertical.png"].onload();
          DataRequest.prototype.requests["/texture/interface/zoomIn.png"].onload();
          DataRequest.prototype.requests["/texture/interface/zoomOut.png"].onload();
          DataRequest.prototype.requests["/texture/logo/hex.png"].onload();
          DataRequest.prototype.requests["/texture/logo/lua.png"].onload();
          DataRequest.prototype.requests["/texture/logo/moai.png"].onload();
          DataRequest.prototype.requests["/window/camera.lua"].onload();
          DataRequest.prototype.requests["/window/deckManager.lua"].onload();
          DataRequest.prototype.requests["/window/window.lua"].onload();
          Module['removeRunDependency']('datafile_C:/Users/Orlandi/Documents/Git/Hex/distribute/html/html-release/www/moaiapp.rom');

    };
    Module['addRunDependency']('datafile_C:/Users/Orlandi/Documents/Git/Hex/distribute/html/html-release/www/moaiapp.rom');
  
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
