
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
Module['FS_createPath']('/file', 'languages', true, true);
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
    new DataRequest(1276, 1948, 0, 0).open('GET', '/effect/blackscreen.lua');
    new DataRequest(1948, 2735, 0, 0).open('GET', '/effect/blend.lua');
    new DataRequest(2735, 3085, 0, 0).open('GET', '/effect/color.lua');
    new DataRequest(3085, 3672, 0, 0).open('GET', '/file/saveLocation.lua');
    new DataRequest(3672, 5219, 0, 0).open('GET', '/file/strings.lua');
    new DataRequest(5219, 5864, 0, 0).open('GET', '/file/languages/cs.lua');
    new DataRequest(5864, 6866, 0, 0).open('GET', '/file/languages/de.lua');
    new DataRequest(6866, 8057, 0, 0).open('GET', '/file/languages/el.lua');
    new DataRequest(8057, 8653, 0, 0).open('GET', '/file/languages/en.lua');
    new DataRequest(8653, 9344, 0, 0).open('GET', '/file/languages/es.lua');
    new DataRequest(9344, 9981, 0, 0).open('GET', '/file/languages/fr.lua');
    new DataRequest(9981, 10599, 0, 0).open('GET', '/file/languages/hu.lua');
    new DataRequest(10599, 11345, 0, 0).open('GET', '/file/languages/id.lua');
    new DataRequest(11345, 12032, 0, 0).open('GET', '/file/languages/it.lua');
    new DataRequest(12032, 12686, 0, 0).open('GET', '/file/languages/nl.lua');
    new DataRequest(12686, 13341, 0, 0).open('GET', '/file/languages/pt.lua');
    new DataRequest(13341, 14039, 0, 0).open('GET', '/file/languages/ro.lua');
    new DataRequest(14039, 15097, 0, 0).open('GET', '/file/languages/ru.lua');
    new DataRequest(15097, 15732, 0, 0).open('GET', '/file/languages/sv.lua');
    new DataRequest(15732, 16395, 0, 0).open('GET', '/file/languages/tr.lua');
    new DataRequest(16395, 17413, 0, 0).open('GET', '/file/languages/uk.lua');
    new DataRequest(17413, 28973, 0, 0).open('GET', '/font/LICENSE-NotoSans-Regular.txt');
    new DataRequest(28973, 443793, 0, 0).open('GET', '/font/NotoSans-Regular.ttf');
    new DataRequest(443793, 460477, 0, 0).open('GET', '/game/ai.lua');
    new DataRequest(460477, 468363, 0, 0).open('GET', '/game/board.lua');
    new DataRequest(468363, 470324, 0, 0).open('GET', '/game/hexagon.lua');
    new DataRequest(470324, 471524, 0, 0).open('GET', '/game/lane.lua');
    new DataRequest(471524, 472392, 0, 0).open('GET', '/game/newGame.lua');
    new DataRequest(472392, 472903, 0, 0).open('GET', '/game/player.lua');
    new DataRequest(472903, 477860, 0, 0).open('GET', '/game/turn.lua');
    new DataRequest(477860, 481108, 0, 0).open('GET', '/input/input.lua');
    new DataRequest(481108, 481151, 0, 0).open('GET', '/input/keyboard.lua');
    new DataRequest(481151, 481423, 0, 0).open('GET', '/input/mouse.lua');
    new DataRequest(481423, 481908, 0, 0).open('GET', '/input/touch.lua');
    new DataRequest(481908, 487800, 0, 0).open('GET', '/interface/button.lua');
    new DataRequest(487800, 489603, 0, 0).open('GET', '/interface/interface.lua');
    new DataRequest(489603, 489802, 0, 0).open('GET', '/interface/priority.lua');
    new DataRequest(489802, 490184, 0, 0).open('GET', '/interface/background/background.lua');
    new DataRequest(490184, 504130, 0, 0).open('GET', '/interface/game/gameInterface.lua');
    new DataRequest(504130, 509326, 0, 0).open('GET', '/interface/game/menu.lua');
    new DataRequest(509326, 511915, 0, 0).open('GET', '/interface/intro/introInterface.lua');
    new DataRequest(511915, 514040, 0, 0).open('GET', '/loop/gameLoop.lua');
    new DataRequest(514040, 514980, 0, 0).open('GET', '/loop/introLoop.lua');
    new DataRequest(514980, 515085, 0, 0).open('GET', '/loop/thread.lua');
    new DataRequest(515085, 515814, 0, 0).open('GET', '/math/circle.lua');
    new DataRequest(515814, 517275, 0, 0).open('GET', '/math/rectangle.lua');
    new DataRequest(517275, 517514, 0, 0).open('GET', '/math/utils.lua');
    new DataRequest(517514, 517804, 0, 0).open('GET', '/math/vector.lua');
    new DataRequest(517804, 519293, 0, 0).open('GET', '/multiplayer/multiplayer.lua');
    new DataRequest(519293, 521025, 0, 0).open('GET', '/multiplayer/socket/client.lua');
    new DataRequest(521025, 523125, 0, 0).open('GET', '/multiplayer/socket/server.lua');
    new DataRequest(523125, 530446, 0, 0).open('GET', '/pathfinding/boardPath.lua');
    new DataRequest(530446, 547399, 0, 0).open('GET', '/pathfinding/graph.lua');
    new DataRequest(547399, 552414, 0, 0).open('GET', '/pathfinding/hexGrid.lua');
    new DataRequest(552414, 554742, 0, 0).open('GET', '/sort/heap.lua');
    new DataRequest(554742, 556119, 0, 0).open('GET', '/sort/quickSort.lua');
    new DataRequest(556119, 800665, 0, 0).open('GET', '/texture/background/gameBackground.png');
    new DataRequest(800665, 824323, 0, 0).open('GET', '/texture/background/smallWindow.png');
    new DataRequest(824323, 847685, 0, 0).open('GET', '/texture/background/window.png');
    new DataRequest(847685, 859350, 0, 0).open('GET', '/texture/board/hexagon.png');
    new DataRequest(859350, 862358, 0, 0).open('GET', '/texture/board/lane.png');
    new DataRequest(862358, 862487, 0, 0).open('GET', '/texture/effect/blackscreen.png');
    new DataRequest(862487, 880078, 0, 0).open('GET', '/texture/effect/buttonHighlight.png');
    new DataRequest(880078, 880205, 0, 0).open('GET', '/texture/effect/whitescreen.png');
    new DataRequest(880205, 939566, 0, 0).open('GET', '/texture/interface/11x11.png');
    new DataRequest(939566, 989786, 0, 0).open('GET', '/texture/interface/7x7.png');
    new DataRequest(989786, 1054205, 0, 0).open('GET', '/texture/interface/9x9.png');
    new DataRequest(1054205, 1076953, 0, 0).open('GET', '/texture/interface/about.png');
    new DataRequest(1076953, 1106557, 0, 0).open('GET', '/texture/interface/AI vs human.png');
    new DataRequest(1106557, 1127926, 0, 0).open('GET', '/texture/interface/close.png');
    new DataRequest(1127926, 1146564, 0, 0).open('GET', '/texture/interface/horizontal.png');
    new DataRequest(1146564, 1175907, 0, 0).open('GET', '/texture/interface/human vs AI.png');
    new DataRequest(1175907, 1187143, 0, 0).open('GET', '/texture/interface/human vs human.png');
    new DataRequest(1187143, 1211888, 0, 0).open('GET', '/texture/interface/options.png');
    new DataRequest(1211888, 1234039, 0, 0).open('GET', '/texture/interface/redo.png');
    new DataRequest(1234039, 1257661, 0, 0).open('GET', '/texture/interface/startNewGame.png');
    new DataRequest(1257661, 1279831, 0, 0).open('GET', '/texture/interface/undo.png');
    new DataRequest(1279831, 1305648, 0, 0).open('GET', '/texture/interface/vertical.png');
    new DataRequest(1305648, 1329049, 0, 0).open('GET', '/texture/interface/zoomIn.png');
    new DataRequest(1329049, 1352243, 0, 0).open('GET', '/texture/interface/zoomOut.png');
    new DataRequest(1352243, 1393246, 0, 0).open('GET', '/texture/logo/hex.png');
    new DataRequest(1393246, 1442202, 0, 0).open('GET', '/texture/logo/lua.png');
    new DataRequest(1442202, 1491052, 0, 0).open('GET', '/texture/logo/moai.png');
    new DataRequest(1491052, 1495472, 0, 0).open('GET', '/window/camera.lua');
    new DataRequest(1495472, 1502641, 0, 0).open('GET', '/window/deckManager.lua');
    new DataRequest(1502641, 1507226, 0, 0).open('GET', '/window/window.lua');

    if (!Module.expectedDataFileDownloads) {
      Module.expectedDataFileDownloads = 0;
      Module.finishedDataFileDownloads = 0;
    }
    Module.expectedDataFileDownloads++;

    var PACKAGE_PATH = window['encodeURIComponent'](window.location.pathname.toString().substring(0, window.location.pathname.toString().lastIndexOf('/')) + '/');
    var PACKAGE_NAME = 'D:/Git/Hex/distribute/html/html-release/www/moaiapp.rom';
    var REMOTE_PACKAGE_NAME = 'moaiapp.rom';
    var PACKAGE_UUID = '6cb9b887-afc5-46bd-a9bd-3c4e52a52753';
  
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
          DataRequest.prototype.requests["/effect/blackscreen.lua"].onload();
          DataRequest.prototype.requests["/effect/blend.lua"].onload();
          DataRequest.prototype.requests["/effect/color.lua"].onload();
          DataRequest.prototype.requests["/file/saveLocation.lua"].onload();
          DataRequest.prototype.requests["/file/strings.lua"].onload();
          DataRequest.prototype.requests["/file/languages/cs.lua"].onload();
          DataRequest.prototype.requests["/file/languages/de.lua"].onload();
          DataRequest.prototype.requests["/file/languages/el.lua"].onload();
          DataRequest.prototype.requests["/file/languages/en.lua"].onload();
          DataRequest.prototype.requests["/file/languages/es.lua"].onload();
          DataRequest.prototype.requests["/file/languages/fr.lua"].onload();
          DataRequest.prototype.requests["/file/languages/hu.lua"].onload();
          DataRequest.prototype.requests["/file/languages/id.lua"].onload();
          DataRequest.prototype.requests["/file/languages/it.lua"].onload();
          DataRequest.prototype.requests["/file/languages/nl.lua"].onload();
          DataRequest.prototype.requests["/file/languages/pt.lua"].onload();
          DataRequest.prototype.requests["/file/languages/ro.lua"].onload();
          DataRequest.prototype.requests["/file/languages/ru.lua"].onload();
          DataRequest.prototype.requests["/file/languages/sv.lua"].onload();
          DataRequest.prototype.requests["/file/languages/tr.lua"].onload();
          DataRequest.prototype.requests["/file/languages/uk.lua"].onload();
          DataRequest.prototype.requests["/font/LICENSE-NotoSans-Regular.txt"].onload();
          DataRequest.prototype.requests["/font/NotoSans-Regular.ttf"].onload();
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
          Module['removeRunDependency']('datafile_D:/Git/Hex/distribute/html/html-release/www/moaiapp.rom');

    };
    Module['addRunDependency']('datafile_D:/Git/Hex/distribute/html/html-release/www/moaiapp.rom');
  
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
